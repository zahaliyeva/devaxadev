/**  http://developer.force.com/cookbook/recipe/trigger-pattern-for-tidy-streamlined-bulkified-triggers

 * Class AccountHandler  

 *  

 * Trigger Handler for the Account SObject. This class implements the ITrigger  

 * interface to help ensure the trigger code is bulkified and all in one place.  

 */ 

public without sharing class AccountHandler implements ITrigger  

{     
    //for Disable triggers UPDATEs for a BatchRunAccountTriggers 
    private static boolean DeactivateTrigger = false;
    private static boolean ForceActivateTrigger = false;

    // Member variable to hold the Id's of Account 'in use'  
    private Set<Id> RecordsInUse = new Set<Id>();  
    
    
    public final String objectShare = 'AccountShare';  
    public final String parentId = 'accountid';
    public final String rawCause = 'Manual'; 
    public final String accessLevelName = 'AccountAccessLevel';
    public final String accessLevelvalue = 'Edit'; //'None','Read','Edit','All'
    public final String accessLevelvalueAgency = 'Read'; //'None','Read','Edit','All'

    public final String separatorOfGroups = ';';
    public final String fieldNameOfGroup ='Nodes__c';
    //public final Recordtype agencyRecordTypeId = [select id FROM recordtype WHERE developername='Agency' limit 1];
    
    //public final Id AXA_TECHNICAL_USER_ID = (AAI_Code_Variables__c.getAll()).get('AXA_TECHNICAL_USER_ID').Value__c; 
    public final Id AXA_TECHNICAL_USER_ID = (AAI_Code_Variables__c.getAll()).get('AXA_TECHNICAL_USER_ID') != null ? (AAI_Code_Variables__c.getAll()).get('AXA_TECHNICAL_USER_ID').Value__c : UserInfo.getUserId();

    private AccountHandler_Helper Account_helper = new AccountHandler_Helper();

    // Constructor  

    public AccountHandler()  
    {  

    }  
    //get boolean for know if is Batch RUN
    public static boolean DeactivateTrigger(){
         return DeactivateTrigger;
         }
    //set get boolean for Batch RUN
    public static void setDeactivateTrigger(Boolean flag) {
         DeactivateTrigger = flag ; 
        }  
        
    //get boolean for know if is Batch RUN
    public static boolean ForceActivateTrigger(){
        return ForceActivateTrigger;
        }
    //set get boolean for Batch RUN
    public static void setForceActivateTrigger(Boolean flag) {
        ForceActivateTrigger = flag ; 
       }  
   

    /**  

     * bulkBefore  

     *  

     * This method is called prior to execution of a BEFORE trigger. Use this to cache  

     * any data required into maps prior execution of the trigger.  

     */ 

    public void bulkBefore()  
    {  

    }  

       

    public void bulkAfter()  
    {  

    }  

           

    public void beforeInsert(SObject so)  
    { 

    }  
    
    public void beforeInsert(List<SObject> soList)  
    {  
        List<Account> AccNeedsLookup = new List<Account>();

        List<Account> AccountsChangedNodes = new List<Account>();
        List<Account> NewrList = (List<Account>) soList;
        List<Account> linkToAgencyList = new List<Account>();
        // 26-11-2021 *-+
        if(!NewrList.isEmpty()) {
            Account_helper.BeforeOperationsAccounts(NewrList);
        }
        
        //for per vedere se node e valorizato e tech AAI 
        for(Account account_temp: NewrList){
            //Se non è visibile allora non dare visibilita ai nodi
            if(account_temp.isHidden__c == true) {
                account_temp.Nodes__c = '';
            }

            if(String.isNotBlank(account_temp.Nodes__c))
            	AccountsChangedNodes.add(account_temp);
            if(String.isNotBlank(account_temp.AAI_Agency_Reference_Code__c)){
                linkToAgencyList.add(account_temp);
            }// Davide Pagano Nodo Omnia
            if(String.isNotBlank(account_temp.Ccod_Produttore__c)){
                AccNeedsLookup.add(account_temp);
            }
        } 
        //node__c è cambiato. id.277 evolutiva *-+ 02-03-2022
        
        if(!linkToAgencyList.isEmpty()){
            Account_helper.linkAgencyToAccount(linkToAgencyList);
        }
        if(!AccountsChangedNodes.isEmpty()) {
            Account_helper.updateBlackListProcessAccount(AccountsChangedNodes);
        }
          //Davide Pagano Nodo Omnia
          if(!AccNeedsLookup.isEmpty()) {
            Account_helper.NodoOmnia(AccNeedsLookup);
        }
        
    }   
    
    public void beforeUpdate(SObject oldSo, SObject so)  
    {  
        
        Account oldAcc = (Account) oldSo;
        Account acc = (Account) So;
        if(oldAcc.isPartner == true && acc.isPartner == false)
        { 
            //This code has been introduced to prevent that Administrator could disable Agency Account.
            //Disabling partner Account has a huge impact all over the organization
            Integer i = 0/0;
        }

    }  

        
    public void beforeUpdate(List<SObject> oldSoList, List<SObject> soList)  
    {
        List<Account> AccNeedsLookup = new List<Account>();

    
        List<Account> NewrList = (List<Account>) soList;
        List<Account> AccountsChanged = new List<Account>();
        List<Account> AccountsChangedNodes = new List<Account>();
        Map <id,Account> mapaOld = new Map <id,Account> ((List<Account>) oldSoList);

        Id profileId=userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;

        //LINK ACCOUNT TO PARTNER ACCOUNT (RECORD TYPE "AGENCY") BASED ON FIELD AAI_Agency_Reference_Code__c

        for(Account account_pivot : NewrList){
            //Se sto nascondendo il claim allora rimuovo i nodi
            if(account_pivot.isHidden__c == true && mapaOld.get(account_pivot.id).isHidden__c == false){
                account_pivot.Nodes__c = '';
            }else if (mapaOld.get(account_pivot.id).isHidden__c == true && account_pivot.isHidden__c == false && String.isBlank(account_pivot.Nodes__c) && profileName == 'System Administrator') {
                account_pivot.addError('Contestualmente all\'impostazione del flag isHidden=false è necessario popolare il campo Nodes');
            }
            // è cambiato la agency code ?
            if(account_pivot.AAI_Agency_Reference_Code__c != mapaOld.get(account_pivot.id).AAI_Agency_Reference_Code__c){
                AccountsChanged.add(account_pivot);
            }else // è cambiato Company code ?
            if (account_pivot.TECH_COMPANY__C != mapaOld.get(account_pivot.id).TECH_COMPANY__C){
                AccountsChanged.add(account_pivot);  
            }else // node__c è cambiato. id.277 evolutiva *-+ 02-03-2022
            if (account_pivot.Nodes__c != mapaOld.get(account_pivot.id).Nodes__c){
                AccountsChangedNodes.add(account_pivot);  
            }else// Davide Pagano Nodo Omnia
            If(account_pivot.Ccod_Produttore__c != mapaOld.get(account_pivot.id).Ccod_Produttore__c ){
                AccNeedsLookup.add(account_pivot);
        } 
    }// end for new list of accounts changs 
        //26-11-2021 *-+
        if(!AccountsChanged.isEmpty()) {
            Account_helper.BeforeOperationsAccounts(AccountsChanged);
            Account_helper.linkAgencyToAccount(AccountsChanged);
        }//node__c è cambiato. id.277 evolutiva *-+ 02-03-2022
        if(!AccountsChangedNodes.isEmpty()) {
            Account_helper.updateBlackListProcessAccount(AccountsChangedNodes);
        }   //Davide Pagano Nodo Omnia
        if(!AccNeedsLookup.isEmpty()) {
            Account_helper.NodoOmnia(AccNeedsLookup);
        }
    
  
  
    }    

    /**  

     * beforeDelete  

     *  

     * This method is called iteratively for each record to be deleted during a BEFORE  

     * trigger.  

     */ 

    public void beforeDelete(SObject so)  
    {     

    }  
    
    public void beforeDelete(List<SObject> soList)  
    {  

    } 

    public void afterInsert(SObject so)  
    {  

    }  


    public void afterInsert(List<SObject> soList)  
    {
        
        
        // 26-11-2021 *-+   
        if(soList?.size() > 0) {
            Account_helper.AfterOperationsAccounts(soList);
        }
    } 
       

    public void afterUpdate(SObject oldSo, SObject so)  
    {  

    }  

    public void afterUpdate(List<SObject> oldSoList, List<SObject> soList)  
    {

        List<Account> NewrList = (List<Account>) soList;
        List<Account> AccountsChanged = new List<Account>();
        Map <id,Account> mapaOld = new Map <id,Account> ((List<Account>) oldSoList);
         
        system.debug('+++++++processing :'+ NewrList.size() + ' -Accounts in this trigger afterupdate');
        // is really used??? this boolean
    
        for(Account account_pivot : NewrList ) {
            if(account_pivot.Nodes__c != mapaOld.get(account_pivot.id).Nodes__c ||  
               (account_pivot.Last_Node_Modify_Date__c != null)){
                AccountsChanged.add(account_pivot);
            }// end IF changed Nodes__c or FORCE_VISIBILITY_SHARE  
        }
        //26-11-2021 *-+
        if(AccountsChanged?.size() > 0) {
            Account_helper.AfterOperationsAccounts(AccountsChanged);
        }

    }  

    public void afterDelete(SObject so)  
    {  

    }  
    
    public void afterUndelete(SObject so)  
    {  

    }  
    
    public void afterDelete(List<SObject> soList)  
    {  

    }  

    public void afterUndelete(List<SObject> soList)  
    {  
        //26-11-2021 *-+
        List<Account> NewrList = (List<Account>) soList;
        if(NewrList?.size() > 0) {
            Account_helper.AfterOperationsAccounts(NewrList);
        }
    }         

    /**  

     * andFinally  

     *  

     * This method is called once all records have been processed by the trigger. Use this   

     * method to accomplish any final operations such as creation or updates of other records.  

     */ 

    public void andFinally()  

    {  


    }  
    
//////////////////////////////////////////////////
        ////////////////////Account Management Methods
//////////////////////////////////////////////////
    @future
    public static void setTechnicalUserOwnerId(List<id> accountIdList)
    {
        system.debug('*********FUTURE SET OWNER ');
        List<SObject> accList  = [select id, OwnerId from account where id in :accountIdList];
        Id techid = (AAI_Code_Variables__c.getAll()).get('AXA_TECHNICAL_USER_ID') != null ? (AAI_Code_Variables__c.getAll()).get('AXA_TECHNICAL_USER_ID').Value__c : UserInfo.getUserId();
        for (SObject s : accList)
        {  
            s.put('OwnerId', techid );
          //  s.put('TECH_SkipTrigger__c', true);
        }
        update accList;
    }
    
    public static boolean checkCSVisibility() {
        //with this method I check on Custom settings for the boolean to force the calculation of visibility
        
       boolean FORCE_VISIBILITY_SHARE = true;
        
        try {
            AAI_Code_Variables__c CV =  AAI_Code_Variables__c.getValues('FORCE_VISIBILITY_SHARE');
            FORCE_VISIBILITY_SHARE = Boolean.ValueOf(CV.value__c);
        } catch (exception e) {
            FORCE_VISIBILITY_SHARE = true;
        }
        
        return FORCE_VISIBILITY_SHARE;
    }
    

}