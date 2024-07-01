/*------------------------------------------------------------------------
Author:        --
Company:       --
Class:         AccountHandler_Helper
Description:   Class for avoiding duplicate CODE on trigger and Batch LIKE Before or After INSERT, class
               used by batch and trigger 

ND:             Importan 

26/11/2021     Created - *-+
----------------------------------------------------------------------------*/
public without sharing class AccountHandler_Helper {
  
  

    public final String objectShare = 'AccountShare';  
    public final String parentId = 'accountid';
    public final String rawCause = 'Manual'; 
    public final String accessLevelName = 'AccountAccessLevel';
    public final String accessLevelvalue = 'Edit'; //'None','Read','Edit','All'
    public final String accessLevelvalueAgency = 'Read'; //'None','Read','Edit','All'
    public final String separatorOfGroups = ';';
    public final String fieldNameOfGroup ='Nodes__c';
    public final ID agencyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Agency').getRecordTypeId();
    
     //public final Recordtype agencyRecordTypeId = [select id FROM recordtype WHERE developername='Agency' limit 1];
   
    ///**********user info on batch????? */
    public final Id AXA_TECHNICAL_USER_ID = (AAI_Code_Variables__c.getAll()).get('AXA_TECHNICAL_USER_ID') != null ? (AAI_Code_Variables__c.getAll()).get('AXA_TECHNICAL_USER_ID').Value__c : UserInfo.getUserId();     /** */

  
    public AccountHandler_Helper() {

    }
    
    
    public void linkAgencyToAccount(List<Account> scope){
        try{  
            Map<String,Id> mapUniqueNameToIdAgencyAccount = NodeManagementAgency.getMapUniqueNameToIdAgencyAccount(scope);
            for(Account account_pivot : scope){
                Id agencyAccountId = mapUniqueNameToIdAgencyAccount.containsKey(account_pivot.AAI_Agency_Reference_Code__c)
                ? mapUniqueNameToIdAgencyAccount.get(account_pivot.AAI_Agency_Reference_Code__c) : null;
                //relazione Account con AgencyCode
                if (agencyAccountId!=null)
                    account_pivot.AAI_Agency__c = agencyAccountId;
                account_pivot.Last_Node_Modify_Date__c = null;
            }
        }
        catch(Exception e){
            System.debug(System.LoggingLevel.ERROR,'Exception: ' + e.getmessage() + '\tStackTrace: '+e.getStackTraceString());
        }
    }
     
    public List<Account> BeforeOperationsAccounts(List<Account> scope){

        List<Account> AccountsForAfterOperations = new List<Account>(); //used to avoid 
        System.debug('Into the Before Operations Account with -'+scope.size()+'-records to process');
     	try{  
            Map<String,Id> mapUniqueNameToIdAgencyAccount = NodeManagementAgency.getMapUniqueNameToIdAgencyAccount(scope);
    
            //SET  owner To Utente Tecnico if  Standar User Profile and Account is from AAI
            for(Account account_pivot : scope){
                //**********USER INFO on batch ????? */
                if (account_pivot.TECH_COMPANY__C == 'AAI' ){// controlare 
                    account_pivot.ownerid = AXA_TECHNICAL_USER_ID;
            	}
                
                //DF Added check to avoid MPS validation rule 20170502
                Id agencyAccountId = mapUniqueNameToIdAgencyAccount.containsKey(account_pivot.AAI_Agency_Reference_Code__c)
                ? mapUniqueNameToIdAgencyAccount.get(account_pivot.AAI_Agency_Reference_Code__c) : null;
                //relazione Account con AgencyCode
                if (agencyAccountId!=null)
                    account_pivot.AAI_Agency__c = agencyAccountId;
            
             }          
            // node__c � cambiato. id.277 evolutiva *-+ 02-03-2022
            System.debug('*-+ 277 '+scope.toString());
            if(!AccountsForAfterOperations.isEmpty())
            updateBlackListProcessAccount(AccountsForAfterOperations);
        }
        catch(Exception e){
            System.debug(System.LoggingLevel.ERROR,'Exception: ' + e.getmessage() + '\tStackTrace: '+e.getStackTraceString());
        }
        return AccountsForAfterOperations;
    }

    public void AfterOperationsAccounts(List<Account> scope){

            System.debug('Into the After Operations Account with -'+scope.size()+'-records to process'); 
     try{ 
            Map<Id,sObject> mapSObjAgency = new Map<Id,sObject>(); // map for agency accounts
            Map<Id,sObject> mapSObj = new Map<Id,sObject>(); // map for all other type of account

            for (Account account_pivot : scope){
                if (account_pivot.RecordTypeId == agencyRecordTypeId) {
                        mapSObjAgency.put(account_pivot.id, account_pivot); 
                } else {
                        mapSObj.put(account_pivot.id, account_pivot); 
                }
            } 
            System.debug('+++++++Num-Accounts RType Agency -'+mapSObjAgency.size());
            System.debug('+++++++Num-Accounts RType Others -'+mapSObj.size());

            // create the Sharing Records for Account depend on field --Nodes__c-- per Agencys on Nodes
            if (!mapSObj.isEmpty()) {
                RecordSharing.shareRecordBasedOnField(mapSObj, objectShare, parentId, rawCause, accessLevelName, accessLevelvalue, fieldNameOfGroup, separatorOfGroups); 
            }

            if (!mapSObjAgency.isEmpty()) {
                RecordSharing.shareRecordBasedOnField(mapSObjAgency, objectShare, parentId, rawCause, accessLevelName, accessLevelvalueAgency, fieldNameOfGroup, separatorOfGroups);
            }
        }catch(Exception e){
        System.debug(System.LoggingLevel.ERROR,'Exception: ' + e.getmessage() + '\tStackTrace: '+e.getStackTraceString());
        }
    }

    public void updateBlackListProcessAccount(List < Account > scope) {

    try {

        Map < Integer, Account > accountsToUpdate = new Map < Integer, Account > (); // map account to integer cont++
        Map < Integer, String > accountsMappingNodes = new Map < Integer, String > (); //map account to integer cont++ and Nodes  String
        Map < String, List < String >> nodesBlackListMap = new Map < String, List < String >> (); // mapping code node => blacklist processi

        Set < String > nodesUniqueCode = new Set < String > ();
        Set < String > setBlackListProcessNodes = new Set < String > ();

        integer i = 0;// used because there is'nt ID ..in before insert !
        for (Account tempPivot: scope) {
            accountsToUpdate.put(i, tempPivot);
            accountsMappingNodes.put(i, tempPivot.Nodes__c);
            if(tempPivot.Nodes__c != null)
            nodesUniqueCode.addAll(String.valueOf(tempPivot.Nodes__c).split(';'));
            i++;
        }
        List < Node__c > nodesBlackList = [Select Node_unique_code__c, Blacklist_Processi__c from Node__c
            where 
            Blacklist_Processi__c != ' ' and 
            Node_unique_code__c in: nodesUniqueCode];

        for (Node__c nodeTemp: nodesBlackList) // mapping Nodes - process n-- like ('000024'=>process1;process2;...)
            nodesBlackListMap.put(nodeTemp.Node_unique_code__c, nodeTemp.Blacklist_Processi__c.split(';'));
        
        String formatWoutKeys = null;
        for (Integer j: accountsToUpdate.keySet()) {

            //update field is on a Work flow, every time that Blacklist_Processi__c is changed save profile name
            // if the last user changing the Blacklist_Processi__c was a NFE user, dont change field blacklist *-+ 08-03-2022
            boolean NonProfileNFE = accountsToUpdate.get(j).Blacklist_Proce_Last_Mod_UserProfile__c != null ? 
            accountsToUpdate.get(j).Blacklist_Proce_Last_Mod_UserProfile__c.startsWith('NFE') ? false:true 
            :true ;

            if(accountsMappingNodes.get(j)!= null && NonProfileNFE){
                for (String nodesAll: accountsMappingNodes.get(j).split(';')) { // FOR per quantita max d Nodi x Account (10)
                    if (nodesBlackListMap.containsKey(nodesAll)) {
                        setBlackListProcessNodes.addAll(nodesBlackListMap.get(nodesAll));
                    }
                }
                //create the list of process on BlckList in the format of Multipicklist field -- string;string;string --
                if (setBlackListProcessNodes != null && setBlackListProcessNodes.size() != 0) {
                    formatWoutKeys = setBlackListProcessNodes.toString().replace('{', '');
                    formatWoutKeys = formatWoutKeys.replace('}', '');
                    formatWoutKeys = formatWoutKeys.replaceAll(',', ';');
                }
                //aggiorna field w new values etheir is blank or null
                accountsToUpdate.get(j).Blacklist_Processi__c = formatWoutKeys;       
                //clear all var for new itteration
                formatWoutKeys = null;
                setBlackListProcessNodes.clear();
            }
         }
           
     }catch(Exception err){
         System.debug(err.getStackTraceString());
        }
    }
     //Davide Pagano Nodo Omnia
     public void NodoOmnia (List<Account> scope){

        List < String > LCodP = new List < String >();
        List < Node__c > LNode = new List < Node__c >();
        Map < String,id > CodiceIdNodoMapa = new Map < String,id >();

        try{
            for (Account tempPivot: scope) {
                LCodP.add(tempPivot.Ccod_Produttore__c);
            }
                LNode = [ Select id,Node_unique_code__c from Node__c where Node_unique_code__c in: LCodP ];

            if(!LNode.isEmpty()){
                for (node__c TN : LNode){
                    if(TN.Node_unique_code__c != null)
                    CodiceIdNodoMapa.put(TN.Node_unique_code__c,TN.id);
                }
            }
            if(!scope.isEmpty()){
                for (Account tempPivot: scope) {
                    if(CodiceIdNodoMapa.containsKey(tempPivot.Ccod_Produttore__c)){             
                                tempPivot.Nodo_Omnia__c = CodiceIdNodoMapa.get(tempPivot.Ccod_Produttore__c);
                        }
                    }
            } 


        }catch(Exception e){
                System.debug(System.LoggingLevel.ERROR,'Exception: ' + e.getmessage() + '\tStackTrace: '+e.getStackTraceString());
        }
    }
}