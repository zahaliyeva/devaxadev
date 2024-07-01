/*------------------------------------------------------------------------------------------
Author:        Marco Moscatelli
Company:       Deloitte
Class:         CaseHandler
Description:   Trigger Handler for the Case SObject. This class implements the ITrigger  
               interface to help ensure the trigger code is bulkified and all in one place.  

History

17/05/2018     Created 
-------------------------------------------------------------------------------------------*/
public with sharing class CaseHandler implements ITrigger  
{ 

    public final Map<String, Schema.RecordTypeInfo> MapCaseRecordType = new Map<String, Schema.RecordTypeInfo> ();
    //OAVERSANO 26/07/2018: Nuovo Modello di Assistenza -- START                         
    public final Map<String,String> MapRecNameToDevelopername = new Map<String,String>();
    //OAVERSANO 26/07/2018: Nuovo Modello di Assistenza -- END
    public final String EntId;
    public final String EntGDPRId;
    public final String EntGDPRId2;
    public final String EntGDPRId3;
    public final String EntAssAgenti;
    public final String EntCaringAngel;
    public final String EntReclamo; //OAVERSANO 18/01/2019 : Gestione Reclami
    public final Id defaultHoursId;
    public final String bhGDPR;
    public static Boolean firstRunStatus = true;
    public static Boolean firstRunChar = true;
    public static Boolean AfterInsertNotDone = true;
    public static Boolean AfterUpdateNotDone = true;
    public static Boolean RunTrigger = true;
    public CaseManagement.Outcome outc;   

    public final String objectShare = 'CaseShare';  
    public final String parentId = 'CaseId';
    public final String rawCause = 'Manual'; 
    public final String accessLevelName = 'CaseAccessLevel';
    //public final String accessLevelvalue = 'Edit'; //'None','Read','Edit','All'//MOSCATELLI_M 07/11/2018: CTL Acquisto
    public final String separatorOfGroups = ';';
    public final String fieldNameOfGroupAgencyCode ='Agency_Code__c';
    public final String fieldNameOfGroupAccountNodes ='Account_Nodes__c';
    public final String ICFAgentiHours;//MMOSCATELLI 28/03/2019: ICF CR2
    
    private static ModelloDiAssistenzaUtils.UserInformation ModUtUserInfo;
    private static List<Case_Categorization__mdt> caseCategorizationList;
    public final Set<String> originAICategorization = new Set<String>{'Web','BranchMain','Webform privato','Webform pubblico'};
    // Constructor  
    public CaseHandler()
    {  
        //OAVERSANO 04/04/2019 : query reduction -- START
        for(MPS_Code_Variables__c MPSCv: MPS_Code_Variables__c.getAll().values())
        {
            if((MPSCv.Name).equalsIgnoreCase('Gestione SLA SmartCenter'))
                EntId = MPSCv.Value__c;
            else if((MPSCv.Name).equalsIgnoreCase('Gestione SLA GDPR Smart Center'))
                EntGDPRId = MPSCv.Value__c;
            else if((MPSCv.Name).equalsIgnoreCase('Gestione SLA GDPR Smart Center 2'))
                EntGDPRId2 = MPSCv.Value__c;
            else if((MPSCv.Name).equalsIgnoreCase('Gestione SLA GDPR Smart Center 3'))
                EntGDPRId3 = MPSCv.Value__c;
            else if((MPSCv.Name).equalsIgnoreCase('Gestione SLA Assistenza Agenti'))
                EntAssAgenti = MPSCv.Value__c;
            else if((MPSCv.Name).equalsIgnoreCase('Gestione SLA Caring Angel'))
                EntCaringAngel = MPSCv.Value__c;
            else if((MPSCv.Name).equalsIgnoreCase('Gestione SLA Reclamo'))
                EntReclamo = MPSCv.Value__c;
            else if((MPSCv.Name).equalsIgnoreCase('BusinessHours_Default'))
                defaultHoursId = MPSCv.Value__c;
            else if((MPSCv.Name).equalsIgnoreCase('BusinessHours_GDPR'))
                bhGDPR = MPSCv.Value__c;
            else if((MPSCv.Name).equalsIgnoreCase('BusinessHours_AAI_Agency_CTL'))
                ICFAgentiHours = MPSCv.Value__c;

        }  
        /*for(Entitlement et: [SELECT Id,Name from Entitlement where Status = 'Active'])
        {
          system.debug('@@et: '+et);
            if(et.Name == 'Gestione SLA SmartCenter')
                EntId = et.id;
            else if(et.Name == 'Gestione SLA GDPR Smart Center')
                EntGDPRId = et.id;
            else if(et.Name == 'Gestione SLA GDPR Smart Center 2')
                EntGDPRId2 = et.id;
            else if(et.Name == 'Gestione SLA GDPR Smart Center 3')
                EntGDPRId3 = et.id;
            else if(et.Name == 'Gestione SLA Assistenza Agenti')
                EntAssAgenti = et.id;
            else if(et.Name == 'Gestione SLA Caring Angel')
                EntCaringAngel = et.id;
            //OAVERSANO 18/01/2019 : Gestione Reclami -- START
            else if(et.Name == 'Gestione SLA Reclamo')
                EntReclamo = et.id;
            //OAVERSANO 18/01/2019 : Gestione Reclami -- END
        }
       
        

        for(BusinessHours bh: [select Id,IsDefault,Name from BusinessHours where IsActive =true])
        {
            if(bh.Name == 'Default')
                defaultHoursId = bh.Id;
            else if(bh.Name == 'GDPR')
                bhGDPR = bh.Id;
            //MMOSCATELLI 28/03/2019: ICF CR2 --START
            else if(bh.Name=='AAI_Agency_CTL')
                ICFAgentiHours = bh.Id;
            //MMOSCATELLI 28/03/2019: ICF CR2 -- END
        }*/
        //OAVERSANO 04/04/2019 : query reduction -- END
        outc = new CaseManagement.Outcome();

        String[] types = new String[]{'Case'}; 
        List<Schema.DescribeSobjectResult> results = Schema.describeSObjects(types); 

        for (Schema.RecordTypeInfo ri: results[0].getRecordTypeInfos()) 
        { 
            MapCaseRecordType.put(ri.getRecordTypeId(), ri);
            MapRecNameToDevelopername.put(ri.getName(), ri.getDeveloperName()); //OAVERSANO 18/01/2019 : Gestione Reclami 
        }

        //OAVERSANO 18/01/2019 : Gestione Reclami -- START
        //OAVERSANO 26/07/2018: Nuovo Modello di Assistenza -- START                         
        /*MapRecNameToDevelopername.put('Sinistri Danni Banca','Sinistri_Danni_Banca');
        MapRecNameToDevelopername.put('Motor','Motor');
        MapRecNameToDevelopername.put('Non Motor','NonMotor');
        MapRecNameToDevelopername.put('Axa Assicurazioni','Axa_Assicurazioni');
        MapRecNameToDevelopername.put('Quadra','Quadra');  
        MapRecNameToDevelopername.put('AMPS Financial','AMPS_Financial');
        MapRecNameToDevelopername.put('Family Protect','Family_Protect');
        MapRecNameToDevelopername.put('Close the loop','Close_the_loop');
        MapRecNameToDevelopername.put('Buon Lavoro','Buon_Lavoro');
        MapRecNameToDevelopername.put('Assistenza Agenti','Assistenza_Agenti');
        MapRecNameToDevelopername.put('Caring Angel','Caring_Angel');//MMOSCATELLI 05/10/2018: Caring Angel
        MapRecNameToDevelopername.put('Agenzia dipendenti','Agenzia_dipendenti');//OAVERSANO 09/01/2019 : Agenzia diretta
        MapRecNameToDevelopername.put('Reclamo','Reclamo');//OAVERSANO 15/01/2019 : Gestione Reclami*/
        //OAVERSANO 26/07/2018: Nuovo Modello di Assistenza -- END
        //OAVERSANO 18/01/2019 : Gestione Reclami -- END
        
        
        if(caseCategorizationList == null){
            caseCategorizationList = [ SELECT LOB__c, Category__c, RecordTypeDevName__c FROM    Case_Categorization__mdt];
        }

    }  

    /**  
    * BULK 
    *  
    * Those methods are called prior to execution of a trigger. Use those to cache  
    * any data required into maps prior execution of the trigger.  
    */ 

    public void bulkBefore()
    {  

    }  

    public void bulkAfter()
    {  

    }  
 
    /*BEFORE SINGLE METHOD*/
    public void beforeInsert(SObject so)
    {  

    }  

    public void beforeUpdate(SObject oldSo, SObject so)
    {  

    }  

    public void beforeDelete(SObject so)
    {     

    }
    
    /*BEFORE LIST METHOD*/
    public void beforeInsert(List<SObject> soList)
    {      
        List<Case> Cases = soList;
        system.debug('+++++CasesDB: '+Cases);
        //MOSCATELLI_M 02/07/2018: Easy Azienda --START
        Map<String,User> MapAAIAgent = new Map<String,User>();
        Set<String> CaseAAIAgent = new Set<String>();
        Set<String> ownerIdSet = new Set<String>();  
        Set<String> queueIdSet = new Set<String>(); 
        Map<String,String> ownerIdNameMap = new Map<String,String>();
        Map<String,String> ownerIdProfileNameMap = new Map<String,String>(); 
        //MOSCATELLI_M 25/10/2018: NMA Business -- START
        Set<String> AgencySet = new Set<String>();
        Map<String,Account> MapAgencies = new Map<String,Account>(); 
        //MOSCATELLI_M 25/10/2018: NMA Business -- END

        //MOSCATELLI 22/01/2019: Reclami -- START
        Map<String,Account> MapCaseAccount = new map<String, Account>();
        Set<String> AccountsSet = new Set<String>();
        //MOSCATELLI 22/01/2019: Reclami -- END
        Id motorRT=Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(AP_Constants.rtCaseMotor).getRecordTypeId();
        Id nonMotorRT=Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(AP_Constants.rtCaseNonMotor).getRecordTypeId();
        Id AAIRT=Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(AP_Constants.rtCaseAAI).getRecordTypeId();
        Map<Id,Case>parentCaseIdToCaseMap=new Map<Id,Case>();

        for(SObject c : soList){

            parentCaseIdToCaseMap.put((Id)c.get('ParentId'),(Case)c);

            if(String.isNotBlank((String)c.get('User__c')))
                CaseAAIAgent.add((String)c.get('User__c'));

            if(String.valueOf(c.get('OwnerId')).startsWith('005'))
                ownerIdSet.add((String)c.get('OwnerId'));
            else
                queueIdSet.add((String)c.get('OwnerId')); 

            //MOSCATELLI_M 25/10/2018: NMA Business -- START
            if(String.isNotBlank((String)c.get('Agency_Code__c')))
               AgencySet.add((String)c.get('Agency_Code__c'));
            //MOSCATELLI_M 25/10/2018: NMA Business -- END

            //MOSCATELLI 22/01/2019: Reclami -- START
            if(String.isNotBlank((String)c.get('AgentName__c')) || String.isNotBlank((String)c.get('AccountId')))
            {
                if(String.isNotBlank((String)c.get('AgentName__c')))
                    AccountsSet.add((String)c.get('AgentName__c'));
                else if(String.isNotBlank((String)c.get('AccountId')))
                    AccountsSet.add((String)c.get('AccountId'));
            }             
            //MOSCATELLI 22/01/2019: Reclami -- END             
       
          // d.pirelli 02/12/2019: Case Categorization from webform --START
              if(originAICategorization.contains((String)c.get('Origin')))
            {    
                if(String.isNotBlank((String)c.get('Category__c') ) && String.isNotBlank((String)c.get('RecordtypeId')))
                {                
                    for ( Case_Categorization__mdt caseCategorization : caseCategorizationList){
                        if ( caseCategorization.Category__c.equalsIgnoreCase( (String)c.get('Category__c') ) && caseCategorization.RecordTypeDevName__c.equalsIgnoreCase(MapRecNameToDevelopername.get(MapCaseRecordType.get((String)c.get('RecordtypeId')).getName()))){
                            System.debug('### ciao');
                            c.put('LOB__c', caseCategorization.Lob__c);   
                        }
                    }
                   
                }
            }
          // d.pirelli 02/12/2019: Case Categorization from webform --END        
        }

        List<Case>parentCases=[select closeddate from case where id in :parentCaseIdToCaseMap.keySet() and ClosedDate!=null and ClosedDate!=LAST_N_DAYS:14 ]; // NOPMD  Fix CRUD violation          
        for(Case parentCase: parentCases){
            Case newCase=parentCaseIdToCaseMap.get(parentCase.Id);
            if(newCase.RecordTypeId==motorRT || newCase.RecordTypeId==nonMotorRT || newCase.RecordTypeId==AAIRT
            && !newCase.SuppliedEmail.contains('@axa.') && !newCase.SuppliedEmail.contains('@cfwidiba.')
            && !newCase.SuppliedEmail.contains('@pfwidiba.') && !newCase.SuppliedEmail.contains('@bu.fruendo.')
            && !newCase.SuppliedEmail.contains('@widiba.') && !newCase.SuppliedEmail.contains('@mps.')
            && !newCase.SuppliedEmail.contains('speechtotextaxa@hotmail.com.') && newCase.SuppliedEmail!=null){
                newCase.Origin='Email';
                newCase.Status='Open';
                if(newCase.RecordTypeId==AAIRT) newCase.Priority='High';
                else newCase.Priority='Medium';
            }
        }

        if(ModUtUserInfo == null && (ownerIdSet.size()>0 || queueIdSet.size()>0))
        {
            ModUtUserInfo = ModelloDiAssistenzaUtils.getProfileAndRole(ownerIdSet, queueIdSet);
            ownerIdNameMap = ModUtUserInfo.mapNameToId; 
            ownerIdProfileNameMap = ModUtUserInfo.mapProfileToId;           
        }

        if(CaseAAIAgent.size()>0)
        {
            //MOSCATELLI_M 25/10/2018: NMA Business -- START
            //for(User u:[Select Id, Name, FirstName, LastName, CommunityNickname, isActive, Email, Agency_Code__c from User where profile.name in ('AAI - Vendite Avanzato','AAI - Vendite Base') and Id in:CaseAAIAgent])
            for(User u:[Select Id, Name, FirstName, LastName, CommunityNickname, isActive, Email, Agency_Code__c, Contact.AccountId from User where profile.name in ('AAI - Vendite Avanzato','AAI - Vendite Base','AAI - Vendite solo Assistenza', 'NFE - AAI - Vendite Base', 'NFE - AAI - Vendite Avanzato', 'NFE - AAI - Vendite solo Assistenza') and Id in:CaseAAIAgent ]) // NOPMD  Fix CRUD violation
            {
            //MOSCATELLI_M 25/10/2018: NMA Business -- END
                MapAAIAgent.put(u.Id,u);
            }            
        }
        //MOSCATELLI_M 02/07/2018: Easy Azienda --END 

        //MOSCATELLI_M 25/10/2018: NMA Business -- END  
        if(AgencySet.size()>0)
        {
            for(Account a: [Select Id,Agency_Code__c,Agency_email__c from Account where Recordtype.Name = 'Agency' and Agency_Code__c in: AgencySet ]) // NOPMD  Fix CRUD violation
            {
                MapAgencies.put(a.Agency_Code__c,a);
            }
        }
        //MOSCATELLI_M 25/10/2018: NMA Business -- END  


        //MOSCATELLI 22/01/2019: Reclami -- START
        if(AccountsSet.size()>0)
        {
            for(Account a : [Select id,name,Account_email__c,Additional_Email__c,Subject_email__c,PersonEmail,RecordtypeId,Recordtype.developername,CIF_PersonalEmail__c,CIF_Work_email__c,CIF_PersonEmail__c,Claim_PersonalEmail__c from Account where id in: AccountsSet])
            {
                MapCaseAccount.put(a.id,a);
                
                system.debug('MapCaseAccount:'+MapCaseAccount);
            }
        }
        //MOSCATELLI 22/01/2019: Reclami -- END

        //CaseManagement.SetInitialValues(Cases,defaultHoursId,bhGDPR,Entid,EntGDPRId,EntGDPRId2,EntGDPRId3,EntAssAgenti,MapAAIAgent,MapCaseRecordType,MapRecNameToDevelopername,ownerIdNameMap,ownerIdProfileNameMap);
        //OAVERSANO 18/01/2019 : Gestione Reclami -- START
        //CaseManagement.SetInitialValues(Cases,defaultHoursId,bhGDPR,Entid,EntGDPRId,EntGDPRId2,EntGDPRId3,EntAssAgenti,EntCaringAngel,MapAAIAgent,MapCaseRecordType,MapRecNameToDevelopername,ownerIdNameMap,ownerIdProfileNameMap, MapAgencies); //OAVERSANO 16/10/2018 : Caring Angel
        CaseManagement.SetInitialValues(Cases,defaultHoursId,bhGDPR,Entid,EntGDPRId,EntGDPRId2,EntGDPRId3,EntAssAgenti,EntCaringAngel,EntReclamo,MapAAIAgent,MapCaseRecordType,MapRecNameToDevelopername,ownerIdNameMap,ownerIdProfileNameMap, MapAgencies, MapCaseAccount); 
        //OAVERSANO 18/01/2019 : Gestione Reclami -- END
        // FM_13/07/2018: Nuovo Modello d'assistenza --- START
        //CaseManagement.ShareWithFullAgency(soList);
        // FM_13/07/2018: Nuovo Modello d'assistenza --- END
    }  

    public void beforeUpdate(List<SObject> oldSoList, List<SObject> soList)
    {
        List<Case> Cases = soList;
        system.debug('+++++CasesDB: '+Cases);
        List<Case> OldValues = oldSoList;
        Set<String> CaseAccount = new Set<String>();
        Map<String,String> MapAssociatedPolicies = new map<String,String>();
        List<String> CaseIdLstStatus = new list<String>();
        Set<Id> idListTaskToClose = new Set<Id>();
        List<Case>FieldModified = new List<Case>();
        Map<String,Case>FieldModifiedOld = new Map<String,Case>();
        Map<String,Account> MapCaseAccount = new map<String, Account>();
        Set<String> CaseAccountid = new Set<String>();
        Set<String> AccountIdForPolicyList = new Set<String>();
        Map<String, Schema.SObjectType> m = Schema.getGlobalDescribe();
        Schema.SObjectType o = m.get('Case');
        list<Schema.SObjectField> fieldList = o.getDescribe().fields.getMap().values();
        List<String> Fields = new List<String>();
        Map<String,Schema.DisplayType> MapFieldTypes = new  Map<String,Schema.DisplayType>();
        //MOSCATELLI_M 02/07/2018: Easy Azienda --START
        Map<String,User> MapAAIAgent = new Map<String,User>();
        Set<String> CaseAAIAgent = new Set<String>();
        //MOSCATELLI_M 02/07/2018: Easy Azienda --END    
        //Antonino Massarotti
        List<Case> newList = new List<Case>();
        for(SObject temp:soList){
            newList.add((case)temp);
        }
        List<ID> OwnerList = new List<ID>();
        for(sObject c:soList){
            if (Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById().get(((Case)c).RecordTypeId).getName() != 'Sinistri Danni Banca') {
            	OwnerList.add(((Case)c).ownerId);    
            }
        }
        Map<ID, Group> queueidNameMap = OwnerList != null && !OwnerList.isEmpty() ? new Map<ID, Group>([Select Id, DeveloperName From Group where type = 'queue']) : new Map<ID, Group>();
        Map<ID, Case> LastHD2QueueMap = newList != null && !newList.isEmpty() ? new Map<ID,Case>([Select Id, TECH_LastHD2Queue__c From case where id in :newList]) : new Map<ID,Case>();
            
        //Antonino Massarotti
        //OAVERSANO 23/07/2018: Nuovo Modello di Assistenza -- START
        Map<String,String> ownerIdProfileNameMap = new Map<String,String>();
        Map<String,String> ownerIdRoleNameMap = new Map<String,String>();
        Map<String,String> ownerIdNameMap = new Map<String,String>();
        Set<String> ownerIdSet = new Set<String>();  
        Set<String> queueIdSet = new Set<String>();  
        //MOSCATELLI_M 25/10/2018: NMA Business -- START
        Set<String> AgencySet = new Set<String>();
        Map<String,Account> MapAgencies = new Map<String,Account>(); 
        //MOSCATELLI_M 25/10/2018: NMA Business -- END
        //OAVERSANO 23/07/2018: Nuovo Modello di Assistenza -- END

        for(Schema.SObjectField s : fieldList)
        {
           Fields.add(s.getDescribe().getName());    
           MapFieldTypes.put(s.getDescribe().getName(),s.getDescribe().getType());           
        } 

        List<Case>CharacteristicsModified = new List<Case>();
        List<String> ListInsertedPolicyId = new list<String>();
        Map<String,InsurancePolicy__c> MapInsertedPolicy = new Map<String,InsurancePolicy__c>();
        String[] FieldsMod = new String[]{'Category__c',
                                            'SubCategory__c',
                                            'Origin',
                                            'AccountId',
                                            'AgentName__c',
                                            'Prodotto__c',
                                            'Distribution_Network__c',
                                            'TECH_eKomi_comment__c',
                                            'SuppliedEmail',
                                            'TECH_Automatic_Emails_Sent__c',
                                            'Inform_Customers_with_Alerts__c',
                                            'Feedback_Provided_to_Customer__c',
                                            'Ownerid',
                                            'Phone_Call_Ids__c',
                                            'LinkToPolicy__c',
                                            'Customer_Service_Model__c',
                                            'RecordtypeId',
                                            'All_Tasks_Close_Date__c',
                                            'Data_completamento_Task_DPO__c',
                                            'Data_ricezione_richiesta_DPO__c',
                                            'Data_completamento_Task_interni__c',
                                            'User__c',//MOSCATELLI_M 02/07/2018: Easy Azienda
                                            'Case_sollecitato__c'//MOSCATELLI_M 23/01/2019: NMA Enhancement V
                                        }; 
         
        
        integer counter=0;

        List<Case> newVal = new List<Case>();
        Map<String,Case> oldValMap = new Map <String,Case>();
        Boolean ModifiedFields = false;
        Boolean ModifiedStatus = false;
        
        for(SObject c:soList)
        {
            newVal.add((Case)c);
            oldValMap.put((String)c.get('Id'),(Case)oldSoList[counter]);
            CaseIdLstStatus.add((String)c.get('Id'));
             system.debug('******** STATUS c.get(Status):'+c.get('Status'));
             system.debug('******** STATUS oldSoList[counter].get(Status):'+oldSoList[counter].get('Status'));
            if(c.get('Status')<>oldSoList[counter].get('Status'))            
                ModifiedStatus = true;                        
      
      //OAVERSANO 23/07/2018: Nuovo Modello di Assistenza -- START
      if(String.valueOf(c.get('OwnerId')).startsWith('005'))
        ownerIdSet.add((String)c.get('OwnerId'));
      else
        queueIdSet.add((String)c.get('OwnerId'));
      if(String.valueOf(oldSoList[counter].get('OwnerId')).startsWith('005'))
        ownerIdSet.add((String)oldSoList[counter].get('OwnerId'));
      else
        queueIdSet.add((String)oldSoList[counter].get('OwnerId'));
      //OAVERSANO 23/07/2018: Nuovo Modello di Assistenza -- END

            for(String s : FieldsMod)
            {
                if(c.get(s)<>oldSoList[counter].get(s))
                {
                    ModifiedFields = true;
                }
            }
            //Massarotti Antonino 30/11/2019 -- START
               if(!((String)c.get('OwnerId')).equals((String)oldSoList[counter].get('OwnerId'))){
                   if(String.ValueOf(c.get('OwnerId')).startsWith('00G')){
                        	
                    		//((case)c).Current_Owner_Queue__c = queueidNameMap.get(String.valueOf(c.get('OwnerId'))) != null ? queueidNameMap.get(String.valueOf(c.get('OwnerId'))).DeveloperName : null;
                       if(((case)c) != null && ((case)c).Current_Owner_Queue__c != null &&((case)c).Current_Owner_Queue__c.contains('HD1')){
                           ((case)c).TECH_FirstHD1Agent__c = '';
                           }
                   } /*c.Current_Owner_Queue__c = queueidNameMap.get(String.valueOf(OldValues.get(c.Id).OwnerId)).DeveloperName;*/
                    else if(String.ValueOf(c.get('OwnerId')).startsWith('005')){
                        if(((case)c).Current_Owner_Queue__c != null)
                            if(((case)c).Current_Owner_Queue__c.contains('HD1') && String.isBlank(((case)c).TECH_FirstHD1Agent__c))
                                ((case)c).TECH_FirstHD1Agent__c = String.ValueOf(c.get('OwnerId'));
                            /*else if(((String)oldSoList[counter].get('OwnerId')).startsWith('005')){
                            	if((String.ValueOf(c.get('OwnerId')).equals(((Case)c).TECH_FirstHD1Agent__c)))
                                	((case)c).Current_Owner_Queue__c = ((Case)c).TECH_LastHD1Queue__c;
                            }*/
                    }
                   if(String.isNotBlank(((case)c).Current_Owner_Queue__c) && ((case)c).Current_Owner_Queue__c.contains('HD2')){
                       if(LastHD2QueueMap.containsKey(((case)c).Id)){
                           if(LastHD2QueueMap.get(((case)c).Id).TECH_LastHd2Queue__c != null)
                       			if(!LastHD2QueueMap.get(((case)c).Id).TECH_LastHd2Queue__c.equals(((case)c).Current_Owner_Queue__c))
                                	((case)c).Mixed_Management__c = true;
                           		((case)c).TECH_LastHD2Queue__c = ((case)c).Current_Owner_Queue__c;
                       		}
                       /*
                       	if(((case)c).TECH_LastHD2Queue__c != Null && ((case)c).TECH_LastHD2Queue__c != ((case)c).Current_Owner_Queue__c){
							((case)c).Mixed_Management__c = true;
                            
                       	}
                        ((case)c).TECH_LastHD2Queue__c = ((case)c).Current_Owner_Queue__c;
                       */
                   }
                   else if(String.isNotBlank(((case)c).Current_Owner_Queue__c) && !((case)c).Current_Owner_Queue__c.contains('HD2')&& !((case)c).Current_Owner_Queue__c.contains('HD3') 
                           && !((case)c).Current_Owner_Queue__c.contains('Coda_Agenzia')){
                       ((Case)c).TECH_LastHD1Queue__c = ((case)c).Current_Owner_Queue__c;
                   }
                        
                        
                }
            else if(String.isBlank(((case)c).Current_Owner_Queue__c) && 
                           (oldSoList[counter].get('RecordTypeId') != c.get('RecordTypeId')) && 
                           Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById().get(((Case)c).RecordTypeId).getName() == AP_Constants.rtCaseAAIName){
                               ((Case)c).TECH_LastHD1Queue__c = ((case)c).Current_Owner_Queue__c = AP_Constants.rtCaseAAI;
                }
                //Massarotti Antonino 30/11/2019 -- END
            if(!ModifiedFields && Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById().get(((Case)c).RecordTypeId).getName() == AP_Constants.rtCaseAAIName){
                 if(String.isNotBlank((String)c.get('Agency_Code__c')))
            		AgencySet.add((String)c.get('Agency_Code__c'));
                
            }
            if(ModifiedFields)
            {
                FieldModified.add((Case)c);
                FieldModifiedOld.put((String)c.get('id'),(Case)oldSoList[counter]);

                if(String.isNotBlank((String)c.get('Accountid')) && (c.get('Accountid')<>oldSoList[counter].get('Accountid')))
                {
                    ((case)c).Agency_Code__c = (((case)c).TECH_Agency_Code__c == null || String.isBlank(((case)c).TECH_Agency_Code__c))?((case)c).Agency_Code__c:((case)c).TECH_Agency_Code__c;
                    CaseAccountid.add((String)c.get('Accountid'));
                }

                if(String.isNotBlank((String)c.get('AgentName__c')) && (c.get('AgentName__c')<>oldSoList[counter].get('AgentName__c')))
                {
                    CaseAccountid.add((String)c.get('AgentName__c'));
                }                
                      
                if((c.get('LinkToPolicy__c') <> oldSoList[counter].get('LinkToPolicy__c')) && String.isNotBlank((String)c.get('LinkToPolicy__c')))
                    ListInsertedPolicyId.add((String)c.get('LinkToPolicy__c'));

                //MOSCATELLI_M 02/07/2018: Easy Azienda -- START
                if(String.isNotBlank((String)c.get('User__c')) && (c.get('User__c')<>oldSoList[counter].get('User__c')))
                {
                    CaseAAIAgent.add((String)c.get('User__c'));
                }                
                //MOSCATELLI_M 02/07/2018: Easy Azienda -- END   

                //MOSCATELLI_M 25/10/2018: NMA Business -- START
                if(String.isNotBlank((String)c.get('Agency_Code__c')))
                   AgencySet.add((String)c.get('Agency_Code__c'));
                //MOSCATELLI_M 25/10/2018: NMA Business -- END    
            }

            counter++;
        }
        
        //OAVERSANO 23/07/2018: Nuovo Modello di Assistenza -- START
        //ownerIdProfileNameMap = ModelloDiAssistenzaUtils.getProfileNameFromId(ownerIdSet, queueIdSet);
        //ownerIdRoleNameMap = ModelloDiAssistenzaUtils.getRoleNameFromId(ownerIdSet);
        if(ModUtUserInfo == null){
            ModUtUserInfo = ModelloDiAssistenzaUtils.getProfileAndRole(ownerIdSet, queueIdSet);
        }
        ownerIdProfileNameMap = ModUtUserInfo.mapProfileToId;
        ownerIdRoleNameMap = ModUtUserInfo.mapRoleToId;
        ownerIdNameMap = ModUtUserInfo.mapNameToId;

        /*List<User> userOwner = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Id IN:ownerIdSet];
        for(User owner: userOwner)
        {
            ownerIdProfileNameMap.put(owner.Id,owner.Profile.Name);
            ownerIdRoleNameMap.put(owner.Id,owner.UserRole.Name);
        }
        List<QueuesObject> queueOwner = [SELECT Id, Queue.Name, QueueId FROM QueuesObject WHERE QueueId IN :queueIdSet];
        for(QueuesObject owner: queueOwner)
            ownerIdProfileNameMap.put(owner.QueueId,owner.Queue.Name);*/
        //OAVERSANO 23/07/2018: Nuovo Modello di Assistenza -- END
        if(!ModifiedFields){
        	if(AgencySet.size()>0)
            {
                for(Account a: [Select Id,Agency_Code__c, Agency_Email__c from Account where Recordtype.Name = 'Agency' and Agency_Code__c in: AgencySet ]) // NOPMD  Fix CRUD violation
                {
                    MapAgencies.put(a.Agency_Code__c,a);
                }
            }
            integer count = 0;
            for(SObject c:soList){
                Case temp = (Case) c;
                if( String.isnotblank(temp.Agency_Code__c) && MapAgencies.get(temp.Agency_Code__c) != null && ( (temp.Agency_Code__c <> OldValues.get(count).Agency_Code__c) || (temp.Agenzia__c == null)) ){
                     temp.Agenzia__c = MapAgencies.get(temp.Agency_Code__c).Id;
                     temp.Agency_Email__c = MapAgencies.get(temp.Agency_Code__c).Agency_Email__c;
                }
                count++;
            }
        }
        if(ModifiedStatus)
        {
            //outc = CaseManagement.StatusModificationProcesses(CaseIdLstStatus,newVal,oldValMap,EntId,MapCaseRecordType,defaultHoursId,bhGDPR,EntGDPRId);
            //OAVERSANO 18/01/2019 : Gestione Reclami -- START
            //outc = CaseManagement.StatusModificationProcesses(CaseIdLstStatus,newVal,oldValMap,EntId,MapCaseRecordType,defaultHoursId,bhGDPR,EntGDPRId,EntGDPRId2,EntGDPRId3,EntAssAgenti,EntCaringAngel,ownerIdProfileNameMap,ownerIdRoleNameMap,MapRecNameToDevelopername,ownerIdNameMap);//OAVERSANO 23/07/2018: Nuovo Modello di Assistenza
            outc = CaseManagement.StatusModificationProcesses(CaseIdLstStatus,newVal,oldValMap,EntId,MapCaseRecordType,defaultHoursId,bhGDPR,ICFAgentiHours,EntGDPRId,EntGDPRId2,EntGDPRId3,EntAssAgenti,EntCaringAngel,EntReclamo,ownerIdProfileNameMap,ownerIdRoleNameMap,MapRecNameToDevelopername,ownerIdNameMap);
            //OAVERSANO 18/01/2019 : Gestione Reclami -- END 
            
            Map<Id,Case> CaseList = outc.CasList;
            
            idListTaskToClose = outc.TaskToClose;

            if(idListTaskToClose.size()>0)
            {               
                if(!system.isFuture())
                    AP03TaskSetCaseStatus.closeTask(idListTaskToClose);
            }

            if(firstRunStatus)
                firstRunStatus= false;
            {
                system.debug('AlreadyRun Status');
                //return;
            }            
        }
        
        if(ModifiedFields)
        {
            if(CaseAccountid.size()>0)
            {
                for(Account a : [Select id,name,Account_email__c,Additional_Email__c,Subject_email__c,PersonEmail,RecordtypeId,Recordtype.developername,CIF_PersonalEmail__c,CIF_Work_email__c,CIF_PersonEmail__c,Claim_PersonalEmail__c from Account where id in: CaseAccountId])
                {
                    MapCaseAccount.put(a.id,a);
                    
                    system.debug('MapCaseAccount:'+MapCaseAccount);
                }
                            
                for(AggregateResult at: [SELECT CUID__C, COUNT(ID) FROM INSURANCEPOLICY__C WHERE CUID__C in: CaseAccountId and CUID__C!=null and CUID__C!='' GROUP BY CUID__C HAVING COUNT(ID) =1]) // NOPMD  Fix CRUD violation
                {
                    AccountIdForPolicyList.add(string.valueOf(at.get('CUID__c')));
                    system.debug('AccountIdForPolicyList:'+AccountIdForPolicyList);
                }
            } 

            //MOSCATELLI_M 02/07/2018: Easy Azienda -- START 
            if(CaseAAIAgent.size()>0)
            {
                //MOSCATELLI_M 25/10/2018: NMA Business -- START
                //for(User u:[Select Id, Name, FirstName, LastName, CommunityNickname, isActive, Email, Agency_Code__c from User where profile.name in ('AAI - Vendite Avanzato','AAI - Vendite Base') and Id in:CaseAAIAgent])
                for(User u:[Select Id, Name, FirstName, LastName, CommunityNickname, isActive, Email, Agency_Code__c, Contact.AccountId from User where profile.name in ('AAI - Vendite Avanzato','AAI - Vendite Base','AAI - Vendite solo Assistenza', 'NFE - AAI - Vendite Base', 'NFE - AAI - Vendite Avanzato', 'NFE - AAI - Vendite solo Assistenza') and Id in:CaseAAIAgent ]) // NOPMD  Fix CRUD violation
                //MOSCATELLI_M 25/10/2018: NMA Business -- END
                {
                    MapAAIAgent.put(u.Id,u);
                }
            }  
            //MOSCATELLI_M 02/07/2018: Easy Azienda -- END  

            //MOSCATELLI_M 25/10/2018: NMA Business -- START
            if(AgencySet.size()>0)
            {
                for(Account a: [Select Id,Agency_Code__c, Agency_Email__c from Account where Recordtype.Name = 'Agency' and Agency_Code__c in: AgencySet ]) // NOPMD  Fix CRUD violation
                {
                    MapAgencies.put(a.Agency_Code__c,a);
                }
            }
            //MOSCATELLI_M 25/10/2018: NMA Business -- END   
                
            if(ListInsertedPolicyId.size()>0 || AccountIdForPolicyList.size()>0)
            {
                for(InsurancePolicy__c pol: [Select id,CUID__c from InsurancePolicy__c where (Id in:ListInsertedPolicyId or CUID__c in:AccountIdForPolicyList) ]) // NOPMD  Fix CRUD violation
                {
                    if(ListInsertedPolicyId.contains(pol.id))
                        MapInsertedPolicy.put(pol.id,pol);

                    if(AccountIdForPolicyList.contains(pol.CUID__c))
                        MapAssociatedPolicies.put(pol.CUID__c,pol.id);
                } 

                system.debug('MapInsertedPolicy:'+MapInsertedPolicy);
                system.debug('MapAssociatedPolicies:'+MapAssociatedPolicies);
            }           
            
            //outc = CaseManagement.CharacteristicsModificationProcesses(newVal,oldValMap,Entid,MapCaseAccount,MapAssociatedPolicies,MapInsertedPolicy,defaultHoursId,bhGDPR,EntGDPRId,EntGDPRId2,EntGDPRId3,MapAAIAgent);
            //outc = CaseManagement.CharacteristicsModificationProcesses(newVal,oldValMap,Entid,MapCaseAccount,MapAssociatedPolicies,MapInsertedPolicy,defaultHoursId,bhGDPR,EntGDPRId,EntGDPRId2,EntGDPRId3,EntAssAgenti,MapAAIAgent,ownerIdProfileNameMap,MapCaseRecordType,MapRecNameToDevelopername,ownerIdNameMap); //OAVERSANO 26/07/2018: Nuovo Modello di Assistenza
            //outc = CaseManagement.CharacteristicsModificationProcesses(newVal,oldValMap,Entid,MapCaseAccount,MapAssociatedPolicies,MapInsertedPolicy,defaultHoursId,bhGDPR,EntGDPRId,EntGDPRId2,EntGDPRId3,EntAssAgenti,EntCaringAngel,MapAAIAgent,ownerIdProfileNameMap,MapCaseRecordType,MapRecNameToDevelopername,ownerIdNameMap,MapAgencies); //OAVERSANO 16/10/2018 : Caring Angel
            //outc = CaseManagement.CharacteristicsModificationProcesses(newVal,oldValMap,Entid,MapCaseAccount,MapAssociatedPolicies,MapInsertedPolicy,defaultHoursId,bhGDPR,EntGDPRId,EntGDPRId2,EntGDPRId3,EntAssAgenti,EntCaringAngel,EntReclamo,MapAAIAgent,ownerIdProfileNameMap,MapCaseRecordType,MapRecNameToDevelopername,ownerIdNameMap,MapAgencies); //OAVERSANO 18/01/2019 : Gestione Reclami
            outc = CaseManagement.CharacteristicsModificationProcesses(newVal,oldValMap,Entid,MapCaseAccount,MapAssociatedPolicies,MapInsertedPolicy,defaultHoursId,bhGDPR,EntGDPRId,EntGDPRId2,EntGDPRId3,EntAssAgenti,EntCaringAngel,EntReclamo,MapAAIAgent,ownerIdProfileNameMap,ownerIdRoleNameMap,MapCaseRecordType,MapRecNameToDevelopername,ownerIdNameMap,MapAgencies, ICFAgentiHours); //OAVERSANO 11/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991
            Map<Id,Case> CaseList = outc.CasList;
   
            if(firstRunChar)
                firstRunChar= false;
            {
                system.debug('AlreadyRun Charact');
                //return;
            }                       
        }
       
    }  

    public void beforeDelete(List<SObject> soList){     

    } 
    
    /*AFTER SINGLE METHOD*/
    public void afterInsert(SObject so)
    {  

    }         

    public void afterUpdate(SObject oldSo, SObject so)
    {  

    }  

    public void afterDelete(SObject so)
    {  

    }
    
    public void afterUndelete(SObject so)
    {  

    }

    /*AFTER LIST METHOD*/
    public void afterInsert(List<SObject> soList)
    {  
      
      
        List<Case> Cases = soList;
        system.debug('+++++CasesDB: '+Cases);
        Set<String> AccountIds = new Set<String>();

        for(SObject c : soList)
        {
            if(String.isNotBlank((String)c.get('AccountId')))
                AccountIds.add((String)c.get('AccountId'));
        }
        CaseManagement.AfterInsertProcess(Cases,AccountIds,MapCaseRecordType,MapRecNameToDevelopername);
        
        // FM_13/07/2018: Nuovo Modello d'assistenza --- START
        List<Case> rList = (List<Case>) soList;
 
        Map<Id,sObject> mapSObj = new Map<Id,sObject>();
        Map<Id,sObject> mapSObjReadOnly = new Map<Id,sObject>();//MOSCATELLI_M 07/11/2018: CTL Acquisto
		List<VoiceCall> VcToUpdate = new List<VoiceCall>();
        for (SObject sObj : soList)
        {
            //MOSCATELLI_M 07/11/2018: CTL Acquisto -- START
            //DANTONIO_M 26/11/2018: modifica sharing Case -- START
            System.debug('===> Record developer name: ' + MapRecNameToDevelopername.get(MapCaseRecordType.get((String)sObj.get('RecordtypeId')).getName()));
            System.debug('===> Constant: ' + Ap_Constants.rtCaseAssistenzaAgenti);
            System.debug('===> Case: ' + sObj);
            if(!MapRecNameToDevelopername.get(MapCaseRecordType.get((String)sObj.get('RecordtypeId')).getName())
                    .equals(Ap_Constants.rtCaseAssistenzaAgenti)
					 &&
               !MapRecNameToDevelopername.get(MapCaseRecordType.get((String)sObj.get('RecordtypeId')).getName())
                    .equals(Ap_Constants.rtCaseCaringSalute)
              &&
                    !(MapRecNameToDevelopername.get(MapCaseRecordType.get((String)sObj.get('RecordtypeId')).getName())
                    .equals(Ap_Constants.rtCaseAAI))){
            //DANTONIO_M 26/11/2018: modifica sharing Case -- END
                System.debug('===> Case: ' + sObj);
                System.debug('===> readOnly');
                mapSObjReadOnly.put(sObj.id,sObj);
            }
            else{
                System.debug('===> edit');
            //MOSCATELLI_M 07/11/2018: CTL Acquisto -- END
                mapSObj.put(sObj.id, sObj); 
            }
            if(sobj.get('TECH_Voice_Call__c') != null){
                String AgentCode;
                Id AccountId;

                if(sobj.get('AccountId') != null){
                    AccountId = (Id) sobj.get('AccountId');
                }
                else if(sobj.get('AgentName__c') != null){
                    AccountId = (Id) sobj.get('AgentName__c');
                }
                
                
                VoiceCall vc = new VoiceCall(
                    Id = (Id)sobj.get('TECH_Voice_Call__c'), 
                    relatedRecordId = (Id)sobj.get('Id'),
                    Agent__c = (Id)sobj.get('User__c'),
                    Account__c = AccountId
                    );
                if(sobj.get('TECH_Agent_Code__c') != null)
                    vc.Agent_Code__c = (String) sobj.get('TECH_Agent_Code__c');
                VcToUpdate.add(vc);
            }
        } 
        
        if(RecordSharing.runModelloDiAssistenzaInsert)
        {   
            system.debug('Insert***');    
            RecordSharing.runModelloDiAssistenzaInsert = false; 
        //SHARING AGENZIE
            //MOSCATELLI_M 07/11/2018: CTL Acquisto -- START
            //RecordSharing.shareRecordBasedOnField(mapSObj, objectShare, parentId, rawCause, accessLevelName, accessLevelvalue, fieldNameOfGroup, separatorOfGroups);
            if(!mapSObj.isEmpty())
                RecordSharing.shareRecordBasedOnField(mapSObj, objectShare, parentId, rawCause, accessLevelName, 'Edit', fieldNameOfGroupAgencyCode, separatorOfGroups);            
            if(!mapSObjReadOnly.isEmpty())
                RecordSharing.shareRecordBasedOnField(mapSObjReadOnly, objectShare, parentId, rawCause, accessLevelName, 'Read', fieldNameOfGroupAccountNodes, separatorOfGroups);            
            //MOSCATELLI_M 07/11/2018: CTL Acquisto -- END
        }
        //SHARING HD2
        CaseManagement.ShareWithHD2Roles(soList);
        // FM_13/07/2018: Nuovo Modello d'assistenza --- END


        if(AfterInsertNotDone)
            AfterInsertNotDone = false;
        else
        {
            system.debug('After Insert AlreadyRun');
        }
        if(!VcToUpdate.isEmpty()){
            try{
                update VCToUpdate;
            }
            catch(Exception e){
                    ApplicationLogHelper.ERROR('CaseHandler', e.getMessage(), e.getStackTraceString());
                
            }
        }
    } 
    
    public void afterUpdate(List<SObject> oldSoList, List<SObject> soList)
    {  
        List<Case> newVal = new List<Case>();
        List<Case> allNewCases = soList;
        system.debug('+++++CasesDB: '+allNewCases );
        Map<String,Case> oldValMap = new Map <String,Case>();
        Set<String> CaseAccountid = new Set<String>();
        Map<String,Account> MapCaseAccount = new map<String, Account>();

    //OAVERSANO 26/07/2018: Nuovo Modello di Assistenza -- START                         
        
        Map<String,String> ownerIdProfileNameMap = new Map<String,String>();
        Map<String,String> ownerIdRoleNameMap = new Map<String,String>();
        Map<String,String> ownerIdNameMap = new Map<String,String>();
        Set<String> ownerIdSet = new Set<String>();  
        Set<String> queueIdSet = new Set<String>();  
        //OAVERSANO 26/07/2018: Nuovo Modello di Assistenza -- END
        
        Integer counter = 0;

        for(SObject c:soList)
        {  
          //OAVERSANO 26/07/2018: Nuovo Modello di Assistenza -- START
          if(String.valueOf(c.get('OwnerId')).startsWith('005'))
        ownerIdSet.add((String)c.get('OwnerId'));
      else
        queueIdSet.add((String)c.get('OwnerId'));
      if(String.valueOf(oldSoList[counter].get('OwnerId')).startsWith('005'))
        ownerIdSet.add((String)oldSoList[counter].get('OwnerId'));
      else
        queueIdSet.add((String)oldSoList[counter].get('OwnerId'));
      //OAVERSANO 26/07/2018: Nuovo Modello di Assistenza -- END
            newVal.add((Case)c);
            oldValMap.put((String)c.get('Id'),(Case)oldSoList[counter]);
      //system.debug('oldValMap: '+JSON.serializePretty(oldValMap));
            if(String.isNotBlank((String)c.get('Accountid')) && (c.get('Accountid')<>oldSoList[counter].get('Accountid')))
            {
                CaseAccountid.add((String)c.get('Accountid'));
            }  
            // found on controll for Case 07185006 - BUG - Anomalia Case CTL *-+ 05-12-2022
            counter++;
        }
    
        if(CaseAccountid.size()>0)
        {
            for(Account a : [Select id,Recordtype.developername from Account where id in: CaseAccountId])
            {
                MapCaseAccount.put(a.id,a);
                
                system.debug('MapCaseAccount:'+MapCaseAccount);
            }

            //CaseManagement.AfterUpdateProcess(newVal,oldValMap,MapCaseAccount);     //OAVERSANO 23/07/2018: Nuovo Modello di Assistenza 
        }
        
        //OAVERSANO 26/07/2018: Nuovo Modello di Assistenza -- START
       /*
        ownerIdProfileNameMap = ModelloDiAssistenzaUtils.getProfileNameFromId(ownerIdSet, queueIdSet);
        ownerIdRoleNameMap = ModelloDiAssistenzaUtils.getRoleNameFromId(ownerIdSet);*/
        if(ModUtUserInfo == null){
            ModUtUserInfo = ModelloDiAssistenzaUtils.getProfileAndRole(ownerIdSet, queueIdSet);
        }
        ownerIdProfileNameMap = ModUtUserInfo.mapProfileToId;
        ownerIdRoleNameMap = ModUtUserInfo.mapRoleToId;
        ownerIdNameMap = ModUtUserInfo.mapNameToId;



    /*List<User> userOwner = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Id IN:ownerIdSet];
    for(User owner: userOwner)
    {
       ownerIdProfileNameMap.put(owner.Id,owner.Profile.Name);
       ownerIdRoleNameMap.put(owner.Id,owner.UserRole.Name);
    }
     List<QueuesObject> queueOwner = [SELECT Id, Queue.Name, QueueId FROM QueuesObject WHERE QueueId IN :queueIdSet];
     for(QueuesObject owner: queueOwner)
       ownerIdProfileNameMap.put(owner.QueueId,owner.Queue.Name);*/
    //OAVERSANO 26/07/2018: Nuovo Modello di Assistenza -- END

    CaseManagement.AfterUpdateProcess(newVal,oldValMap,MapCaseAccount,MapCaseRecordType,MapRecNameToDevelopername,ownerIdProfileNameMap,ownerIdRoleNameMap);     //OAVERSANO 23/07/2018: Nuovo Modello di Assistenza
    
        // FM_13/07/2018: Nuovo Modello d'assistenza --- START
        List<Case> rList = (List<Case>) soList;
 
        Map<Id,sObject> mapSObj = new Map<Id,sObject>();
        Map<Id,sObject> mapSObjReadOnly = new Map<Id,sObject>();//MOSCATELLI_M 07/11/2018: CTL Acquisto

        for (SObject sObj : soList)
        {
            //MOSCATELLI_M 07/11/2018: CTL Acquisto -- START
            //DANTONIO_M 26/11/2018: modifica sharing Case -- START
            if(!MapRecNameToDevelopername.get(MapCaseRecordType.get((String)sObj.get('RecordtypeId')).getName())
                    .equals(Ap_Constants.rtCaseAssistenzaAgenti)
					 &&
               !MapRecNameToDevelopername.get(MapCaseRecordType.get((String)sObj.get('RecordtypeId')).getName())
                    .equals(Ap_Constants.rtCaseCaringSalute)
                    &&
                    !(MapRecNameToDevelopername.get(MapCaseRecordType.get((String)sObj.get('RecordtypeId')).getName())
                    .equals(Ap_Constants.rtCaseAAI))){
            //DANTONIO_M 26/11/2018: modifica sharing Case -- END
                mapSObjReadOnly.put(sObj.id,sObj);
            }
            else{
            //MOSCATELLI_M 07/11/2018: CTL Acquisto -- END
                mapSObj.put(sObj.id, sObj);         
            }
        } 
        
        if(RecordSharing.runModelloDiAssistenzaUpdate)
        {
            system.debug('Update***');  
            RecordSharing.runModelloDiAssistenzaUpdate = false;
        //SHARING AGENTI
            //MOSCATELLI_M 07/11/2018: CTL Acquisto -- START
            //RecordSharing.shareRecordBasedOnField(mapSObj, objectShare, parentId, rawCause, accessLevelName, accessLevelvalue, fieldNameOfGroup, separatorOfGroups);
            if(!mapSObj.isEmpty())
                RecordSharing.shareRecordBasedOnField(mapSObj, objectShare, parentId, rawCause, accessLevelName, 'Edit', fieldNameOfGroupAgencyCode, separatorOfGroups);            
            if(!mapSObjReadOnly.isEmpty())
                RecordSharing.shareRecordBasedOnField(mapSObjReadOnly, objectShare, parentId, rawCause, accessLevelName, 'Read', fieldNameOfGroupAccountNodes, separatorOfGroups);            
            //MOSCATELLI_M 07/11/2018: CTL Acquisto -- END   
        }     
        //SHARING HD2
        CaseManagement.ShareWithHD2Roles(soList);
        // FM_13/07/2018: Nuovo Modello d'assistenza --- END 

        if(AfterUpdateNotDone){
          AfterUpdateNotDone = false;
        }
        else        
            system.debug('After Update AlreadyRun'); 

              
    }  
    
    public void afterDelete(List<SObject> soList)
    {  

    }
    
    public void afterUndelete(List<SObject> soList){ 
 
       
    }

    public void andFinally(){  

    }      
}