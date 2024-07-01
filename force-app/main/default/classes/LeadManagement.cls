/*
 * -----------------------------------------------------------------------------------------------------------------------
 * Log History
 * ID 001 
 * Initiative Lead Management Sprint 45: New logic of deduplication post assignment.
 * date: 28/06/2017
 * author: Juana Valenzuela
 * -----------------------------------------------------------------------------------------------------------------------
*/

public class LeadManagement 
{
    public static Map<String,Id> LeadGroup ( list <Lead> nLead) {
        System.debug('#@#@# nLead '+nLead);
        String ThePrefix = 'Coda_Agenzia_';
        Map<Id,String> mapShare = new Map<Id,String>();
        Set<String> queueNames = new Set<String>(); //Agency_Code__c
        Set<String> agencyCodes = new Set<String>();
        for (Lead uLead : nLead) 
        {
            if (uLead.Agency_Code__c != null && uLead.Agency_Code__c != '')
            {
                agencyCodes.add(uLead.Agency_Code__c);
            }
            system.debug('+++++++agencyCodes'+agencyCodes);
        }       
        Map<String,Boolean> theAgencies = getAgencies(agencyCodes); //list of the agencies and active flag
        system.debug('++++theAgencies'+theAgencies );

        for (Lead uLead : nLead) 
        {
            if (uLead.Agency_Code__c != null && uLead.Agency_Code__c != '')
            {
                Boolean isActive = theAgencies.get (uLead.Agency_Code__c);
                if (isActive==true) //it may be null in the event of invalid agency code
                {
                    String currentQueue = ThePrefix+''+uLead.Agency_Code__c;
                    system.debug('++++currentQueue'+currentQueue);
                    queueNames.add(currentQueue);
                    mapShare.put(uLead.Id, currentQueue);
                }
            }
        }
        Map<String,Id> theGroupMap = getGroupNameWithId(queueNames);
        system.debug('+++++++queueNames'+queueNames);
        
        return theGroupMap;
    }
    
    public static Map<String,Id> getGroupNameWithId(Set<String> groupNames){
    
        Map<String,Id> NameId_groups = new Map<String,Id>();
        system.debug('++++++groupNames'+groupNames);
        List<Group> groups = [Select id, name,developername from group where type = 'Queue' and developername in :groupNames ];// NOPMD  Fix CRUD violation , Select g.Type, g.Name,g.developername, g.Id, g.Email, g.DoesSendEmailToMembers, g.DoesIncludeBosses From Group g where g.type = 'Queue' 
        for (Group gi : groups){
            NameId_groups.put(gi.developername, gi.id);
        }
        return NameId_groups;
    }      

    public static Map<String,Boolean> getAgencies(Set<String> agencyCodes){
        Recordtype AgencyRecordtype = [SELECT ID,developername from Recordtype where developername='Agency'  Limit 1]; // NOPMD  Fix CRUD violation
        system.debug('+++++AgencyRecordtype'+AgencyRecordtype );
        Map<String,Boolean> TheAgencies = new Map<String,Boolean>();
        List<Account> Agencies = [SELECT Name, Active__c,Agency_Code__c,Id FROM Account where agency_code__c in :agencyCodes AND Recordtypeid=:AgencyRecordtype.ID ]; // NOPMD  Fix CRUD violation, Select g.Type, g.Name,g.developername, g.Id, g.Email, g.DoesSendEmailToMembers, g.DoesIncludeBosses From Group g where g.type = 'Queue' 
        for (Account gi : Agencies){
            system.debug('++++gi.Agency_Code__c'+gi.Agency_Code__c);
            system.debug('++++++gi.Active__c'+gi.Active__c);
            system.debug('++++++gi.Name'+gi.Name);
            TheAgencies.put(gi.Agency_Code__c, gi.Active__c);
        }
        return TheAgencies;
    } 
    
    @future
    public static void reassingLeadAAI(Set<id> myIds){
    
        List<Lead> rList = [SELECT Id,TECH_COMPANY__C,Agency_Code__c,Codice_Sub_Agenzia__c,Landing_Page__c, LeadSource, OwnerId, Owner.Name, Dettaglio__c,Custom_Lead_Owner__c,Sub_agenzie_gia_assegnate__c,Agenzie_gia_assegnate__c,TECH_Massively_uploaded_web_lead__c,TECH_Send_Email_Notification__c,Numero_assegnazioni_eseguite__c FROM Lead Where Id IN :myIds FOR UPDATE]; //CAPOBIANCO_A 26/07/2017 Added the extraction of TECH_Massively_uploaded_web_lead__c
        List<Lead> rListToUpdate = new List<Lead>();
        system.debug('#@#@# rlist '+rlist);
        
        
        String ThePrefix = 'Coda_Agenzia_';
        Id defaultGroup;
        
        //DF Added check to reassign to users
       Id CurrentUserId = UserInfo.getuserid();
       User CurrentUser = [SELECT Id, Name, Profile.Name FROM User WHERE Id =:CurrentUserId  limit 1]; // NOPMD  Fix CRUD violation

       //boolean needreassignment = false;
       boolean isCurrentUserAgent = false;
       if ( CurrentUser.Profile.Name!= null && String.isNotBlank(CurrentUser.Profile.Name) &&
           (CurrentUser.Profile.Name.containsIgnoreCase('AAI - Vendite Avanzato') || (CurrentUser.Profile.Name == 'AAI - Vendite Base'))) {
           isCurrentUserAgent = true;
       }
       Database.DMLOptions dmo = new Database.DMLOptions(); 
        dmo.EmailHeader.triggerUserEmail = false; 
        // DF end of variables required for  reassignment to users
        
        
        List<Group> groups = [Select id, name,developername from group where type = 'Queue' and developername = 'AAI_Lead_Queue' ]; // NOPMD  Fix CRUD violation
        Integer size = groups.size();
        if(size>0)
        {
            defaultGroup = groups[0].Id ;
        }
        
        Map<String,Id> theGroupMap = LeadManagement.LeadGroup (rList);
        System.debug('+++++++++++++++ theGroupMap: '+theGroupMap); //

        //BOVOLENTA_D added owner blacklist - do not assign to current user if owner is a specific queue
        Map<Id,Boolean> leadQueuesNotSearchable = new Map<Id,Boolean>();
        Id wrongContactLeadQueue = UtilityClass.retrieveGroupId('Queue','Coda_Lead_Contatto_Errato');
        leadQueuesNotSearchable.put(wrongContactLeadQueue,true);
        Id toBeProcessedLeadReassigned = UtilityClass.retrieveGroupId('Queue','Coda_Lead_Da_Processare_Riassegnate');
        leadQueuesNotSearchable.put(toBeProcessedLeadReassigned,true);
        Id doesNotAnswerLeadReassigned = UtilityClass.retrieveGroupId('Queue','Coda_Lead_Non_Risponde_Riassegnate');
        leadQueuesNotSearchable.put(doesNotAnswerLeadReassigned,true);
        Id leadsWithoutPhone = UtilityClass.retrieveGroupId('Queue','Coda_Web_Lead_senza_telefono');
        leadQueuesNotSearchable.put(leadsWithoutPhone,true);
        Id leadRemovedWebQueue = UtilityClass.retrieveGroupId('Queue','Coda_lead_web_duplicati_ass_rimossa');
        leadQueuesNotSearchable.put(leadRemovedWebQueue,true); 




        for(Lead a : rList)
        {   
            Boolean endStateQueue = leadQueuesNotSearchable.get(a.OwnerId);
            if(a.TECH_Company__c=='AAI' && isCurrentUserAgent && String.valueOf(a.OwnerId).left(3) == '00G' && endStateQueue != true ) {//Assign to current user if it is from agency and lead is still in queue // && (a.Custom_Lead_Owner__c!= null && String.valueOf(a.Custom_Lead_Owner__c).left(3) == '00G')
                //reassigning to users 
                a.OwnerId=CurrentUserId;
                a.TECH_Send_Email_Notification__c=false;
                system.debug('++++assigning lead to user'+ CurrentUser.Name);
                a.setOptions(dmo);
                rListToUpdate.add(a);
            } else {
                //if(a.TECH_COMPANY__C == 'AAI' && a.Landing_Page__c!=null ) included logic for massive upload
                system.debug('+++++++a.Landing_Page__c'+a.Landing_Page__c);
                system.debug('+++++++a.LeadSource'+a.LeadSource);
                system.debug('+++++++a.Dettaglio__c'+a.Dettaglio__c);
                if(a.TECH_COMPANY__C == 'AAI' && (a.LeadSource=='Web' || a.LeadSource=='External List' ) && !isCurrentUserAgent ) //assigning to queue only if current user is NOT from agency
                {
                    String currentQueue = ThePrefix+''+a.Agency_Code__c;
                    Id QueueId = theGroupMap.containsKey(currentQueue) ? theGroupMap.get(currentQueue) : defaultGroup;
                    System.debug('+++++++++++++++ QueueId: '+QueueId);
                    a.ownerid = QueueId;
                    //CAPOBIANCO_A 17/07/2017 SPRINT 46--START 
                    //Needed to assure the correct working of the decisional motor reassignment process
                    a.Agenzie_gia_assegnate__c = a.Agency_Code__c+';'; 
                    if(a.Codice_Sub_Agenzia__c == null || a.Codice_Sub_Agenzia__c == ''){
                        a.Sub_agenzie_gia_assegnate__c = '-'+';';
                        a.Agenzie_gia_assegnate_complete__c = a.Agency_Code__c+';'; 
                    } else {
                        a.Sub_agenzie_gia_assegnate__c = a.Codice_Sub_Agenzia__c+';';
                        a.Agenzie_gia_assegnate_complete__c = a.Codice_Sub_Agenzia__c+';';
                    }
                    //CAPOBIANCO_A 17/07/2017 SPRINT 46--END
                    String detailedSource = ''+a.Dettaglio__c;
                    
                    //Added exceptions in order not to send this email on csv loading
                    //CAPOBIANCO_A 26/07/2017 BUGFIX - START 
                    //if (a.LeadSource=='External List' || detailedSource.equalsIgnoreCase('Salva quotazione') ) a.TECH_Send_Email_Notification__c = false;
                    if (a.TECH_Massively_uploaded_web_lead__c==true && a.LeadSource != 'Web') a.TECH_Send_Email_Notification__c = false;
                      rListToUpdate.add(a);

                    //CAPOBIANCO_A 26/07/2017 BUGFIX - END
                }
            }
        system.debug('********************'+a.OwnerId);
        //BOVOLENTA_D 26/09/2017 DEPLOYMENT PROCESS EMAIL BUGFIX - START 
        if(Test.isRunningTest()){
            a.TECH_Send_Email_Notification__c = false;
        }

        //END
        }
        //update rListToUpdate;
        Database.update(rListToUpdate,false); //CAPOBIANCO_A 02/10/2017
    }

    //Start - 001: Replaced by the new method leadDeduplicationCheck that considers the new logic based on First Name, Last Name
    // and CAP for Leads and Fiscal Code or PIVA for Clients (persona fisica or persona giuridica)
/*
    public static List<Lead> SetDuplicateFlag(List<Lead> rList) {
        Set<String> LeadInputKey = new Set<String>();
        set<String> InputAgCode = new set<String>();
        set<Id> InputLead_ID = new set<Id>();
        
        //checking duplicates on the passed list
        for (Lead l : rList)  { 
            boolean isNewLead=LeadInputKey.add(l.TECH_DeduplicationKey__c);
            system.debug('+++++++++++++++++++l.TECH_DeduplicationKey__c'+l.TECH_DeduplicationKey__c);
            //Not necessary but makes the search faster
            if (l.Agency_Code__c!=null && l.Agency_Code__c !='')
            {   
                InputAgCode.add(l.Agency_Code__c);
            }
            
            if (isNewLead) {
                l.Deduplication_Required__c=false;
            } else {
                l.Deduplication_Required__c=true; 
            }
            
            if (l.id!=null) {// added to avoid duplicates with themselves on update
                InputLead_ID.add(l.id);
            }
        }
        system.debug('+++++++++++++++++++inputkeys'+LeadInputKey);

        List<Lead> ExistingLeads = new list<Lead>();
        List<Account> ExistingAccounts  = new list<Account>();
    //    string queryAcc = 'SELECT Id,TECH_DeduplicationKey__c FROM Account Where TECH_DeduplicationKey__c =\''+LeadInputKey+'\'';
    //    string queryLead = 'SELECT Id,TECH_DeduplicationKey__c FROM Lead Where TECH_DeduplicationKey__c =\''+LeadInputKey+'\' AND isconverted=false AND Id !=\''+InputLead_ID+'\' ';
        system.debug('+++++++++++++++++++InputAgCode'+InputAgCode);
        if (InputAgCode.size()>0)
        {
            ExistingLeads=[SELECT Id,TECH_DeduplicationKey__c FROM Lead Where Agency_Code__c IN:InputAgCode AND TECH_DeduplicationKey__c IN:LeadInputKey AND isconverted=false AND Id NOT IN:InputLead_ID ];
            ExistingAccounts=[SELECT Id,TECH_DeduplicationKey__c FROM Account Where AAI_Agency_Reference_Code__c IN:InputAgCode AND TECH_DeduplicationKey__c IN:LeadInputKey ];
        }else
        {
            return rlist; //exiting to avoid full table scans
        }
    //    system.debug('+++++++++++++++++++Existing Account Query'+queryAcc);
        //checking duplicates on  existing leads and accounts
    //    List<Lead> ExistingLeads=[SELECT Id,TECH_DeduplicationKey__c FROM Lead Where Agency_Code__c IN:InputAgCode AND TECH_DeduplicationKey__c IN:LeadInputKey AND isconverted=false AND Id NOT IN:InputLead_ID ];
    //    List<Account> ExistingAccounts=[SELECT Id,TECH_DeduplicationKey__c FROM Account Where AAI_Agency_Reference_Code__c IN:InputAgCode AND TECH_DeduplicationKey__c IN:LeadInputKey ];
    //    List<Lead> ExistingLeads = Database.query(queryAcc);
    //    List<Account> ExistingAccounts = Database.query(queryLead);

        Set<String> ExistingLeadKey = new Set<String>();
        for (Lead thislead :ExistingLeads) {
            ExistingLeadKey.add(thislead.TECH_DeduplicationKey__c);
        }
        system.debug('++++++++++++++++++foundLeadskeys'+ExistingLeadKey);

        
        Set<String> ExistingAccountKey = new Set<String>();
        for (Account thisAccount :ExistingAccounts) {
            ExistingAccountKey.add(thisAccount.TECH_DeduplicationKey__c);
        }
        system.debug('++++++++++++++++++foundAccountskeys'+ExistingAccountKey);

        
        Set<String> LeadInputKeyCheck = new Set<String>();//Set to check again against given list

        for (Lead l : rList) { 
            
            if (ExistingLeadKey.contains(l.TECH_DeduplicationKey__c)) {
                l.Deduplication_Required__c=true;
                system.debug('++++++++++++++Duplicatefound'+l+' with key '+l.TECH_DeduplicationKey__c);
            } else {
                //l.Deduplication_Required__c=false; otherwise i nullify the check in the input list
                system.debug('++++++++++++++DuplicateNOTfound on existing lead'+l);
            }
            
            if (ExistingAccountKey.contains(l.TECH_DeduplicationKey__c)) {
                l.Deduplication_Required__c=true;
                system.debug('++++++++++++++Duplicatefound'+l+' with key '+l.TECH_DeduplicationKey__c);
            } else {
                //l.Deduplication_Required__c=false; otherwise i nullify the check in the input list
                system.debug('++++++++++++++DuplicateNOTfound in account'+l);
            }
        }
        
        return rlist;
    }
    */
    
    /** [16/05/2017]JV: Initiative: Lead-Management
    * Method that verifies if it is a duplicated Lead: 
    * 1. Verifies if there is another Lead with the same FirstName, LastName and CAP
    * 2. Verifies if the Company is present and in case, compares the Lead based on Partita IVA or PostalCode 
    * 3. Verifies if there is another account with the same Codice Fiscale or, if not present, FirstName, LastName and CAP (only Persona Juridica)
    * @param updatedLead: Lead for which has been changed the Status
    * @return TRUE if the Lead is duplicated with a Lead or B2B client, FALSE otherwise
    */
    public static Boolean verifyDuplicateLead(Lead updatedLead){
        Boolean duplicatedLead = false;
        //1. Verifies if there is another Lead with the same FirstName, LastName and CAP
        Boolean isDuplicatedWithLead = false;
        Boolean isDuplicatedWithClient = false;  

        if(updatedLead.AAI_Partita_IVA__c != null && updatedLead.AAI_Partita_IVA__c != ''){
        Map <Id, Lead> duplicatedLeadMap = new Map <Id, Lead>([SELECT Id FROM Lead WHERE Agency_Code__c = :updatedLead.Agency_Code__c AND AAI_Partita_IVA__c = :updatedLead.AAI_Partita_IVA__c AND IsConverted = false ]);
        duplicatedLeadMap.remove(updatedLead.Id);
            if (!duplicatedLeadMap.isEmpty()){              
                duplicatedLead = true;
                isDuplicatedWithLead = true;

                system.debug('+++Lead duplicated with Lead+++');
                  
            }    

        }   

        else if(updatedLead.Fiscal_ID__c != null && updatedLead.Fiscal_ID__c != ''){
        Map <Id, Lead> duplicatedLeadMap = new Map <Id, Lead>([SELECT Id FROM Lead WHERE Agency_Code__c = :updatedLead.Agency_Code__c AND Fiscal_ID__c = :updatedLead.Fiscal_ID__c AND IsConverted = false ]);
        duplicatedLeadMap.remove(updatedLead.Id);
            if (!duplicatedLeadMap.isEmpty()){              
                duplicatedLead = true;
                isDuplicatedWithLead = true;

                system.debug('+++Lead duplicated with Lead+++');
                  
            }    

        }

        else if(updatedLead.PostalCode != null && updatedLead.PostalCode != ''){
            system.debug('***DENTRO IF DUPLICATED LEAD***');  
            // FMarchese 14/09/2017: added Company Name control in the query              
            Map <Id, Lead> duplicatedLeadMap = new Map <Id, Lead>([SELECT Id FROM Lead WHERE Agency_Code__c = :updatedLead.Agency_Code__c  AND ((LastName = :updatedLead.LastName AND FirstName = :updatedLead.FirstName) OR (Company = :updatedLead.Company AND Company != null )) AND IsConverted = false AND PostalCode = :updatedLead.PostalCode]);
            //Remove the current Lead from duplicatedLeadMap
            duplicatedLeadMap.remove(updatedLead.Id);
            if (!duplicatedLeadMap.isEmpty()){              
                duplicatedLead = true;
                isDuplicatedWithLead = true;

                system.debug('+++Lead duplicated with Lead+++');
                  
            }           
        }
        if(isDuplicatedWithLead)
            return duplicatedLead;      
        else{  
        
        system.debug('***** IN ELSE');  

            Id b2bClientRecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'B2B_Client'].Id;
            Id b2cClientRecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'B2C_Client'].Id;
            Map <Id,Account> accDuplicatedMap;
            //2. Verifies if the Company is present and in case, compares the Lead based on Partita IVA or PostalCode (only Persona Giuridica)
            // DA INCLUDERE NELLA SPRINT 45 
            // FMarchese 14/09/2017: check on the Company name dismissed in order to align deduplication controls (verifyDuplicateLead called on EditLeadLDSCtrl  & leadDeduplicationCheck called on LeadHandler)
            // if present, deduplication works on Fiscal code or PIva
           /* if(updatedLead.Company != null && updatedLead.Company != ''){*/
                if(updatedLead.AAI_Partita_IVA__c != null && updatedLead.AAI_Partita_IVA__c != ''){
                    system.debug('inside Partita Partita_IVA__c control');
                    accDuplicatedMap = new Map<Id,Account>([SELECT Id FROM Account WHERE RecordTypeId = :b2bClientRecordTypeId AND /*Name = :updatedLead.Company AND*/ AAI_Partita_IVA__c = :updatedLead.AAI_Partita_IVA__c]);
                    if(!accDuplicatedMap.isEmpty())
                        duplicatedLead = true;                      
                }else if(updatedLead.PostalCode != null && updatedLead.PostalCode != '' && updatedLead.Company != null && updatedLead.Company != ''){
                    accDuplicatedMap = new Map<Id,Account>([SELECT Id FROM Account WHERE RecordTypeId = :b2bClientRecordTypeId AND Name = :updatedLead.Company AND PersonMailingPostalCode = :updatedLead.PostalCode]);
                    if(!accDuplicatedMap.isEmpty())
                        duplicatedLead = true;  
                }
           // }
                                        
            //3. Verifies if there is another account with the same Codice Fiscale or, if not present, FirstName, LastName and CAP (only Persona Fisica)    
            //else{
                else if(updatedLead.Fiscal_ID__c != null && updatedLead.Fiscal_ID__c != ''){
                    accDuplicatedMap = new Map<Id,Account>([SELECT Id FROM Account WHERE RecordTypeId = :b2cClientRecordTypeId AND AAI_Codice_Fiscale__c = :updatedLead.Fiscal_ID__c]);
                    if(!accDuplicatedMap.isEmpty()){
                        isDuplicatedWithClient = true;
                        duplicatedLead = true;
                    }
                }else if(updatedLead.PostalCode != null && updatedLead.PostalCode != '' && updatedLead.FirstName != null && updatedLead.FirstName != '' && updatedLead.LastName != null && updatedLead.LastName != '' ){
                    accDuplicatedMap = new Map<Id,Account>([SELECT Id FROM Account WHERE RecordTypeId = :b2cClientRecordTypeId AND LastName = :updatedLead.LastName AND FirstName = :updatedLead.FirstName AND PersonMailingPostalCode = :updatedLead.PostalCode]);
                    if(!accDuplicatedMap.isEmpty()){
                        duplicatedLead = true;
                        isDuplicatedWithClient = true;
                    }                       
                }               
            //}
        }
        return duplicatedLead;
    }
 
    /* Dismissed, introduced field TECH_DeduplicationKey__c and written new method logic
    public static List<Lead> SetDuplicateFlag(List<Lead> rList) {
        //given a list of leads checks if they are duplicates and set the Deduplication_Required__c to true or false
        Set<String> LeadInputKeySetFN_LN_AgCode = new Set<String>();
        List<String> LeadInputFN = new List<String>();
        List<String> LeadInputLN = new List<String>();
        List<String> LeadInputAgCode = new List<String>();
        
        
        for (Lead l : rList)
        { 
            //l.TECH_Name__c = l.firstname != null ? l.firstname + ' ' + l.lastname : l.lastname;  
            // to fill the TECHname
            LeadInputFN.add(l.FirstName);
            LeadInputLN.add(l.LastName);
            LeadInputAgCode.add(l.Agency_Code__c);
            boolean isNewLead=LeadInputKeySetFN_LN_AgCode.add(l.FirstName.tolowercase()+l.LastName.tolowercase()+l.Agency_Code__c);
            if (isNewLead) {
                l.Deduplication_Required__c=false;
            } else {
                l.Deduplication_Required__c=true; 
            }
        }
        system.debug('++++++++++++++++++rList check on 1stdeduplication'+rlist);
        system.debug('++++++++++++++++++thisleadskeys'+LeadInputKeySetFN_LN_AgCode);
        
        List<Lead> ExistingLeads=[SELECT Id,FirstName, LastName, Agency_Code__c FROM Lead Where FirstName IN:LeadInputFN AND LastName IN :LeadInputLN AND Agency_Code__c IN:LeadInputAgCode AND isconverted=false];
        List<Account> ExistingAccounts=[SELECT Id,FirstName,LastName,AAI_Agency_Reference_Code__c FROM Account Where FirstName IN:LeadInputFN AND LastName IN :LeadInputLN AND AAI_Agency_Reference_Code__c IN:LeadInputAgCode];
        system.debug('++++++++++++++++++foundLead'+ExistingLeads);
        system.debug('++++++++++++++++++foundAccounts'+ExistingAccounts);

        Set<String> ExistingLeadKeyFN_LN_AgCode = new Set<String>();
        for (Lead thislead :ExistingLeads) {
            ExistingLeadKeyFN_LN_AgCode.add(thislead.FirstName.tolowercase()+thislead.LastName.tolowercase()+thislead.Agency_Code__c);
        }
        system.debug('++++++++++++++++++foundLeadskeys'+ExistingLeadKeyFN_LN_AgCode);

        
        Set<String> ExistingAccountKeyFN_LN_AgCode = new Set<String>();
        for (Account thisAccount :ExistingAccounts) {
            ExistingAccountKeyFN_LN_AgCode.add(thisAccount.FirstName.tolowercase()+thisAccount.LastName.tolowercase()+thisAccount.AAI_Agency_Reference_Code__c);
        }
        system.debug('++++++++++++++++++foundAccountskeys'+ExistingAccountKeyFN_LN_AgCode);

        
        for (Lead l : rList)
        { 
            if (ExistingLeadKeyFN_LN_AgCode.contains(l.FirstName.tolowercase()+l.LastName.tolowercase()+l.Agency_Code__c)) {
                l.Deduplication_Required__c=true;
                system.debug('++++++++++++++Duplicatefound'+l+' with key '+l.FirstName.tolowercase()+l.LastName.tolowercase()+l.Agency_Code__c);
            } else {
                //l.Deduplication_Required__c=false; otherwise i nullify the check in the input list
                system.debug('++++++++++++++DuplicateNOTfound'+l);
            }
            
            if (ExistingAccountKeyFN_LN_AgCode.contains(l.FirstName.tolowercase()+l.LastName.tolowercase()+l.Agency_Code__c)) {
                l.Deduplication_Required__c=true;
                system.debug('++++++++++++++Duplicatefound'+l+' with key '+l.FirstName.tolowercase()+l.LastName.tolowercase()+l.Agency_Code__c);
                } else {
                if (!l.Deduplication_Required__c) {
                    //l.Deduplication_Required__c=false; otherwise i nullify the check in the input list
                    system.debug('++++++++++++++DuplicateNOTfound in account'+l);
                    }
                }
        }
                system.debug('++++++++++++++++++rList check on 2nd deduplication'+rlist);

        return rlist;
    } */

    /**
    * Initiative: Lead-Management Sprint 45: Method that identifies duplicated Leads with Leads or Clients depending the agency
    * @author Juana Valenzuela
    * @date 28/06/2017
    * @param rlist: List of Leads to control (inserted or updated)
*/
    public static void leadDeduplicationCheck(List<Lead> rList){
        List<Lead> existingLeadList = new List<Lead>();
        Map<Id,Lead> duplicatedLeadsMap = new Map<Id,Lead>();
        List<String> leadAgencyList = new List<String>();
        List<String> leadFirstNameList = new List<String>();
        List<String> leadLastNameList = new List<String>();
        List<String> leadPostalCodeList = new List<String>();
        List<Lead> leadsNotDuplicatedWithLeads = new List<Lead>();
        List<String> leadPIVAList = new List<String>();
        List<String> leadFiscalCodeList = new List<String>();
        List<String> leadCompanyList = new List<String>();
        List<String> leadCAPList = new List<String>();
        List<String> leadNameList = new List<String>();
        List<String> leadCAP2List = new List<String>();
        List<String> leadAgencyList2 = new List<String>();
        //1. Verifies if there is another Lead with the same FirstName, LastName and CAP for the specific agency
        for(Lead tempLead:rList){
            if(String.isNotBlank(tempLead.FirstName))
                leadFirstNameList.add(tempLead.FirstName);
            if(String.isNotBlank(tempLead.LastName))
                leadLastNameList.add(tempLead.LastName);
            if(String.isNotBlank(tempLead.PostalCode))
                leadPostalCodeList.add(tempLead.PostalCode);
            if(String.isNotBlank(tempLead.Agency_Code__c))
                leadAgencyList.add(tempLead.Agency_Code__c);
            
            if(String.isNotBlank(tempLead.AAI_Partita_IVA__c))
                leadPIVAList.add(tempLead.AAI_Partita_IVA__c);                        
            
            if(String.isNotBlank(tempLead.Fiscal_ID__c))
                leadFiscalCodeList.add(tempLead.Fiscal_ID__c);
            
            if(String.isNotBlank(tempLead.Company))
                leadCompanyList.add(tempLead.Company);

        }
        //String existingLeadsQuery = 'SELECT Id,LastName,FirstName,Company,PostalCode,Agency_Code__c,Fiscal_ID__c,AAI_Partita_IVA__c FROM Lead WHERE Agency_Code__c IN :leadAgencyList AND IsConverted=FALSE AND ((LastName IN: leadLastNameList AND FirstName IN: leadFirstNameList AND PostalCode IN:leadPostalCodeList) OR (PostalCode IN:leadPostalCodeList AND Company IN:leadCompanyList) OR (AAI_Partita_IVA__c IN: leadPIVAList) OR (Fiscal_ID__c IN: leadFiscalCodeList))';    
        String existingLeadsQuery = 'SELECT Id,LastName,FirstName,Company,PostalCode,Agency_Code__c,Fiscal_ID__c,AAI_Partita_IVA__c FROM Lead WHERE Agency_Code__c IN :leadAgencyList AND IsConverted=FALSE ';

        String sWhereConds ='';

        //CAPOBIANCO_A 27/09/2017 BUGFIX - START
        /*if(leadLastNameList.size()>0 && leadFirstNameList.size()>0 && leadPostalCodeList.size()>0)
        {
            sWhereConds = ' (LastName IN: leadLastNameList AND FirstName IN: leadFirstNameList AND PostalCode IN:leadPostalCodeList) ';
        }

        if(leadPostalCodeList.size()>0 && leadCompanyList.size()>0) 
        {
            if(String.isnotblank(sWhereConds))
                sWhereConds+=' OR (PostalCode IN:leadPostalCodeList AND Company IN:leadCompanyList) ';
            else
                sWhereConds+=' (PostalCode IN:leadPostalCodeList AND Company IN:leadCompanyList) ';
        }*/

        if(leadLastNameList.size()>0 && leadFirstNameList.size()>0)
        {
            sWhereConds = ' (LastName IN: leadLastNameList AND FirstName IN: leadFirstNameList ';
        }

        if(leadPostalCodeList.size()>0) 
        {
            if(String.isnotblank(sWhereConds))
                sWhereConds+=' AND PostalCode IN:leadPostalCodeList) ';
            else
                sWhereConds+=' (PostalCode IN:leadPostalCodeList) ';
        }

        else if(leadPostalCodeList.size()==0)
        {
            if(String.isnotblank(sWhereConds))
                sWhereConds+=') ';
        }

        if(leadPostalCodeList.size()>0 && leadCompanyList.size()>0) 
        {
            if(String.isnotblank(sWhereConds))
                sWhereConds+=' OR (PostalCode IN:leadPostalCodeList AND Company IN:leadCompanyList) ';
            else
                sWhereConds+=' (PostalCode IN:leadPostalCodeList AND Company IN:leadCompanyList) ';
        }
        //CAPOBIANCO_A 27/09/2017 BUGFIX - END

        if(leadPIVAList.size()>0) 
        {
            if(String.isnotblank(sWhereConds))
                sWhereConds+=' OR (AAI_Partita_IVA__c IN: leadPIVAList) ';
            else
                sWhereConds+=' (AAI_Partita_IVA__c IN: leadPIVAList) ';
        }

        if(leadFiscalCodeList.size()>0) 
        {
            if(String.isnotblank(sWhereConds))
                sWhereConds+=' OR (Fiscal_ID__c IN: leadFiscalCodeList) ';
            else
                sWhereConds+=' (Fiscal_ID__c IN: leadFiscalCodeList) ';
        }

        if(String.isnotblank(sWhereConds))
           existingLeadsQuery = existingLeadsQuery + ' AND ('+sWhereConds+')'; 

        system.debug('##: '+existingLeadsQuery);
        existingLeadList = Database.query(String.escapeSingleQuotes(existingLeadsQuery));
        Map<String,List<Lead>> mapAgencyLeadList = new Map<String,List<Lead>>(); 
        for(Lead temExistingLead:existingLeadList){
            if(mapAgencyLeadList.get(temExistingLead.Agency_Code__c)==null)
                mapAgencyLeadList.put(temExistingLead.Agency_Code__c,new List<Lead>());
            mapAgencyLeadList.get(temExistingLead.Agency_Code__c).add(temExistingLead);   
        }
        for(Lead tempLead:rList){
            tempLead.Deduplication_Required__c = false; //CAPOBIANCO_A 27/09/2017 BUGFIX 
            Boolean isDuplicatedWithLead = false;
            if(mapAgencyLeadList.get(tempLead.Agency_Code__c) != null){
                List<Lead> agencyLeadList = mapAgencyLeadList.get(tempLead.Agency_Code__c);
                System.debug('#@#@# agency lead list size '+agencyLeadList.size()); //CAPOBIANCO_A 02/10
                for(Lead tempAgencyLead:agencyLeadList){
                    if(tempLead.Id != tempAgencyLead.Id){
                        if(String.isNotBlank(tempLead.AAI_Partita_IVA__c) && tempLead.AAI_Partita_IVA__c == tempAgencyLead.AAI_Partita_IVA__c){ //CAPOBIANCO_A 27/09 BUGFIX - Added the isNotBlank Check
                            system.debug('****JV - is duplicated with lead');
                            tempLead.Deduplication_Required__c = true; 
                            duplicatedLeadsMap.put(tempLead.Id,tempLead); 
                            isDuplicatedWithLead = true;  
                        } else if(String.isNotBlank(tempLead.Fiscal_ID__c) && tempLead.Fiscal_ID__c == tempAgencyLead.Fiscal_ID__c){ //CAPOBIANCO_A 27/09 BUGFIX - Added the isNotBlank Check
                            system.debug('****JV - is duplicated with lead');
                            tempLead.Deduplication_Required__c = true; 
                            duplicatedLeadsMap.put(tempLead.Id,tempLead); 
                            isDuplicatedWithLead = true; 
                        }
                        // FMarchese: added deduplication check on Company and Postal code  
                        else if(String.isNotBlank(tempLead.Company) && //CAPOBIANCO_A 27/09 BUGFIX - Added the isNotBlank Checks
                                String.isNotBlank(tempLead.PostalCode) &&
                                tempLead.Company == tempAgencyLead.Company &&
                                tempLead.PostalCode == tempAgencyLead.PostalCode){
                                system.debug('****JV - is duplicated with lead');
                                tempLead.Deduplication_Required__c = true; 
                                duplicatedLeadsMap.put(tempLead.Id,tempLead); 
                                isDuplicatedWithLead = true;  

                        }else if(String.isNotBlank(tempLead.LastName) && //CAPOBIANCO_A 27/09 BUGFIX - Added the isNotBlank Checks
                                String.isNotBlank(tempLead.FirstName) &&
                                String.isNotBlank(tempLead.PostalCode) &&
                                tempLead.LastName == tempAgencyLead.LastName &&
                                tempLead.FirstName == tempAgencyLead.FirstName &&
                                tempLead.PostalCode == tempAgencyLead.PostalCode){
                                system.debug('****JV - is duplicated with lead');
                                tempLead.Deduplication_Required__c = true; 
                                duplicatedLeadsMap.put(tempLead.Id,tempLead); 
                                isDuplicatedWithLead = true; 
                        }
                    }                             
                }     
            }
            if(!isDuplicatedWithLead){
                if(tempLead.Agency_Code__c != null){
                    leadsNotDuplicatedWithLeads.add(tempLead);
                    if(tempLead.AAI_Partita_IVA__c != null && tempLead.AAI_Partita_IVA__c != ''){
                        leadPIVAList.add(tempLead.AAI_Partita_IVA__c);                        
                    }
                    else if(tempLead.Fiscal_ID__c != null && tempLead.Fiscal_ID__c != ''){
                        leadFiscalCodeList.add(tempLead.Fiscal_ID__c);
                    }
                    else if(tempLead.PostalCode != null && tempLead.PostalCode != '' && tempLead.Company != null && tempLead.Company != ''){
                        leadCompanyList.add(tempLead.Company);
                        leadCAPList.add(tempLead.PostalCode);
                    }
                     else if(tempLead.PostalCode != null && tempLead.PostalCode != '' && tempLead.FirstName != null && tempLead.FirstName != '' && tempLead.LastName != null && tempLead.LastName != ''){
                        leadNameList.add(tempLead.FirstName+' '+tempLead.LastName);
                        leadCAP2List.add(tempLead.PostalCode);
                    }
                    leadAgencyList2.add(tempLead.Agency_Code__c);
             
             }   
            }
             
        }
        //2. Verifies if the Lead is duplicated with a client according to the PIVA (Persona giuridica) or Codice Fiscale (Persona fisica)
        //(Persona giuridica)
        if(leadsNotDuplicatedWithLeads.size()>0){
            Map <String,List<Account>> accDuplicatedClientsMap = new Map<String,List<Account>>();
            if(leadPIVAList.size()>0){
                Id b2bClientRecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'B2B_Client'].Id;
                for(Account tempAccount:[SELECT Id,AAI_Partita_IVA__c,AAI_Agency_Reference_Code__c,FirstName,LastName, Name, Recordtype.DeveloperName // NOPMD  Fix CRUD violation, CAPOBIANCO_A 02/10/2017 Added the extraction of Recordtype.Developername 
                                        FROM Account 
                                        WHERE RecordTypeId = :b2bClientRecordTypeId AND 
                                            AAI_Agency_Reference_Code__c IN :leadAgencyList2 AND  
                                            AAI_Partita_IVA__c IN :leadPIVAList ]){
                    if(accDuplicatedClientsMap.get(tempAccount.AAI_Agency_Reference_Code__c) == null)
                            accDuplicatedClientsMap.put(tempAccount.AAI_Agency_Reference_Code__c,new List<Account>());
                        accDuplicatedClientsMap.get(tempAccount.AAI_Agency_Reference_Code__c).add(tempAccount);     
                }    
            }
            if(leadFiscalCodeList.size()>0){
                system.debug('**** leadFiscalCodeList: ' + leadFiscalCodeList);
                Id b2cClientRecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'B2C_Client'].Id;
                for(Account tempAccount:[SELECT Id,AAI_Agency_Reference_Code__c,AAI_Codice_Fiscale__c,AAI_Partita_IVA__c,FirstName,LastName, Name, Recordtype.DeveloperName // NOPMD  Fix CRUD violation, CAPOBIANCO_A 02/10/2017 Added the extraction of Recordtype.Developername 
                                        FROM Account 
                                        WHERE RecordTypeId=:b2cClientRecordTypeId AND 
                                                AAI_Agency_Reference_Code__c IN :leadAgencyList2 AND 
                                                ( AAI_Codice_Fiscale__c IN :leadFiscalCodeList OR AAI_Partita_IVA__c IN :leadFiscalCodeList  ) ]){
                    if(accDuplicatedClientsMap.get(tempAccount.AAI_Agency_Reference_Code__c) == null)
                            accDuplicatedClientsMap.put(tempAccount.AAI_Agency_Reference_Code__c,new List<Account>());
                        accDuplicatedClientsMap.get(tempAccount.AAI_Agency_Reference_Code__c).add(tempAccount); 
                }
            }
            if(leadCompanyList.size()>0 && leadCAPList.size()>0){
                Id b2bClientRecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'B2B_Client'].Id;
                for(Account tempAccount:[SELECT Id,Name,BillingPostalCode,AAI_Agency_Reference_Code__c,AAI_Partita_IVA__c,Recordtype.DeveloperName // NOPMD  Fix CRUD violation, CAPOBIANCO_A 02/10/2017 Added the extraction of AAI_Partita_IVA__c and Recordtype.Developername 
                                        FROM Account 
                                        WHERE RecordTypeId = :b2bClientRecordTypeId AND 
                                            AAI_Agency_Reference_Code__c IN :leadAgencyList2 AND
                                            Name IN :leadCompanyList AND
                                            BillingPostalCode IN: leadCAPList ]){
                    if(accDuplicatedClientsMap.get(tempAccount.AAI_Agency_Reference_Code__c) == null)
                            accDuplicatedClientsMap.put(tempAccount.AAI_Agency_Reference_Code__c,new List<Account>());
                        accDuplicatedClientsMap.get(tempAccount.AAI_Agency_Reference_Code__c).add(tempAccount);     
                }    
            }
            if(leadNameList.size()>0 && leadCAP2List.size()>0){
                Id b2cClientRecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'B2C_Client'].Id;
                for(Account tempAccount:[SELECT Id,Name,PersonMailingPostalCode,AAI_Agency_Reference_Code__c,AAI_Codice_Fiscale__c,AAI_Partita_IVA__c,Recordtype.DeveloperName // NOPMD  Fix CRUD violation, CAPOBIANCO_A 02/10/2017 added the extraction of AAI_Codice_Fiscale__c and Recordtype.Developername
                                        FROM Account 
                                        WHERE RecordTypeId = :b2cClientRecordTypeId AND 
                                            AAI_Agency_Reference_Code__c IN :leadAgencyList2 AND
                                            Name IN :leadNameList AND
                                            PersonMailingPostalCode IN: leadCAP2List ]){
                    if(accDuplicatedClientsMap.get(tempAccount.AAI_Agency_Reference_Code__c) == null)
                            accDuplicatedClientsMap.put(tempAccount.AAI_Agency_Reference_Code__c,new List<Account>());
                        accDuplicatedClientsMap.get(tempAccount.AAI_Agency_Reference_Code__c).add(tempAccount);     
                }    
            }
            for(Lead tempLead:leadsNotDuplicatedWithLeads){
                Boolean isDuplicatedWithClient = false;
                if(accDuplicatedClientsMap.get(tempLead.Agency_Code__c) != null){
                    List<Account> agencyClientList = accDuplicatedClientsMap.get(tempLead.Agency_Code__c);
                    System.debug('#@#@ agencyClientListsize '+agencyClientList.size()); 
                    for(Account tempAgencyClient:agencyClientList){
                        //CAPOBIANCO_A 02/10/2017 BUGFIX -- START
                        /*
                        if(tempLead.AAI_Partita_IVA__c != null && tempLead.AAI_Partita_IVA__c == tempAgencyClient.AAI_Partita_IVA__c){
                            system.debug('****JV - is duplicated with client B2B');
                            tempLead.Deduplication_Required__c = true; 
                            duplicatedLeadsMap.put(tempLead.Id,tempLead); 
                            isDuplicatedWithClient = true;
                        }else if(tempLead.Fiscal_ID__c != null && tempLead.Fiscal_ID__c == tempAgencyClient.AAI_Codice_Fiscale__c){
                            system.debug('****JV - is duplicated with client B2C');
                            tempLead.Deduplication_Required__c = true;
                            duplicatedLeadsMap.put(tempLead.Id,tempLead);
                            isDuplicatedWithClient = true;   
                        }else if(tempLead.Company != null && tempLead.Company == tempAgencyClient.Name && tempLead.PostalCode != null && tempLead.PostalCode == tempAgencyClient.BillingPostalCode){
                            system.debug('****JV - is duplicated with client B2B');
                            tempLead.Deduplication_Required__c = true;
                            duplicatedLeadsMap.put(tempLead.Id,tempLead);
                            isDuplicatedWithClient = true;   
                        }else if(tempLead.Name != null && tempLead.Name == tempAgencyClient.Name && tempLead.PostalCode != null && tempLead.PostalCode == tempAgencyClient.PersonMailingPostalCode){
                            system.debug('****JV - is duplicated with client B2C');
                            tempLead.Deduplication_Required__c = true;
                            duplicatedLeadsMap.put(tempLead.Id,tempLead);
                            isDuplicatedWithClient = true;   
                        } */
                        if(tempAgencyClient.RecordType.DeveloperName == 'B2B_Client')
                        {
                            if(tempLead.AAI_Partita_IVA__c != null && tempLead.AAI_Partita_IVA__c == tempAgencyClient.AAI_Partita_IVA__c)
                            {
                                system.debug('****JV - is duplicated with client B2B');
                                tempLead.Deduplication_Required__c = true; 
                                duplicatedLeadsMap.put(tempLead.Id,tempLead); 
                                isDuplicatedWithClient = true;
                            } else if(tempLead.Company != null && tempLead.Company == tempAgencyClient.Name && tempLead.PostalCode != null && tempLead.PostalCode == tempAgencyClient.BillingPostalCode)
                            {
                                system.debug('****JV - is duplicated with client B2B');
                                tempLead.Deduplication_Required__c = true;
                                duplicatedLeadsMap.put(tempLead.Id,tempLead);
                                isDuplicatedWithClient = true;
                            }
                        }
                        else if(tempAgencyClient.RecordType.DeveloperName == 'B2C_Client')
                        {
                            if(tempLead.Fiscal_ID__c != null && (tempLead.Fiscal_ID__c == tempAgencyClient.AAI_Codice_Fiscale__c || tempLead.Fiscal_ID__c == tempAgencyClient.AAI_Partita_IVA__c))
                            {
                                system.debug('****JV - is duplicated with client B2C');
                                tempLead.Deduplication_Required__c = true;
                                duplicatedLeadsMap.put(tempLead.Id,tempLead);
                                isDuplicatedWithClient = true;   
                            }
                            else if(tempLead.Name != null && tempLead.Name == tempAgencyClient.Name && tempLead.PostalCode != null && tempLead.PostalCode == tempAgencyClient.PersonMailingPostalCode)
                            {
                                system.debug('****JV - is duplicated with client B2C');
                                tempLead.Deduplication_Required__c = true;
                                duplicatedLeadsMap.put(tempLead.Id,tempLead);
                                isDuplicatedWithClient = true;
                            }
                        }
                         //CAPOBIANCO_A 02/10/2017 BUGFIX -- END
                    }        
                }    
            }    
        }       
    } 
    
    public static void setASA(List<Lead> rList){
    
        //FM --- added for Revisione RT Lead e Opportunità su SFDC START
                
                for (Lead l: rList){
                
                string landingpage = l.Landing_Page__c;

                
                if(l.Landing_Page__c!='Pagina Prodotto AXA' && l.Landing_Page__c != 'Trova Agente' && l.Landing_Page__c != 'Siti Agenti'){
                 
                        LeadAssignmentConfiguration__c maplandingpage = LeadAssignmentConfiguration__c.getValues(l.Landing_Page__c);

                        
                        MappingASA__c mapASA = MappingASA__c.getValues(String.valueOf(Integer.valueOf(mapLandingPage.ASA__c)));
                        
                        l.Codice_ASA__c = String.valueOf(Integer.valueOf(mapLandingPage.ASA__c));
                        l.ASA__c = mapASA.ASA__c;
                        l.ASA_Description__c = String.valueOf(Integer.valueOf(mapLandingPage.ASA__c))+' - '+l.ASA__c;
                        
                            if(String.valueOf(Integer.valueOf(mapLandingPage.Sub_ASA__c))!=null){
                            string NameSottoASA = String.valueOf(Integer.valueOf(mapLandingPage.ASA__c))+'.'+String.valueOf(Integer.valueOf(mapLandingPage.Sub_ASA__c));
                            MappingSottoASA__c mapSottoASA = MappingSottoASA__c.getValues(NameSottoASA);
    
                            l.Codice_Sotto_ASA__c = String.valueOf(Integer.valueOf(mapLandingPage.Sub_ASA__c));
                            l.Sotto_ASA__c= mapSottoASA.Sotto_ASA__c;
                            l.Sotto_ASA_Description__c = String.valueOf(Integer.valueOf(mapLandingPage.ASA__c))+'.'+String.valueOf(Integer.valueOf(mapLandingPage.Sub_ASA__c))+' '+l.Sotto_ASA__c;
                            }               
                }else{
                
                    Map<String,LeadAssignmentConfiguration__c> configurationMap = LeadAssignmentConfiguration__c.getAll();
                    Map<String,LeadAssignmentConfiguration__c> mapProductToConfiguration = new Map <String,LeadAssignmentConfiguration__c>();
                    
                     for(String configurationName : configurationMap.keySet())
                            {
                            LeadAssignmentConfiguration__c configuration = configurationMap.get(configurationName);
                            
                            if(String.isNotBlank(configuration.Prodotto__c))
                            {
                                mapProductToConfiguration.put(configuration.Prodotto__c, configuration);
                            }
                            }
                            
                     LeadAssignmentConfiguration__c config = mapProductToConfiguration.get(l.Prodotto__c);
                     
                     if(config!=null){   
                     
                         if(String.valueOf(Integer.valueOf(config.Sub_ASA__c))!=null){
    
                             string NameSottoASA = String.valueOf(Integer.valueOf(config.ASA__c))+'.'+String.valueOf(Integer.valueOf(config.Sub_ASA__c));
                             MappingSottoASA__c mapSottoASA = MappingSottoASA__c.getValues(NameSottoASA);
    
                             l.Codice_Sotto_ASA__c=String.valueOf(Integer.valueOf(config.Sub_ASA__c));
                             l.Sotto_ASA__c= mapSottoASA.Sotto_ASA__c;
                             l.Sotto_ASA_Description__c = String.valueOf(Integer.valueOf(config.ASA__c))+'.'+String.valueOf(Integer.valueOf(config.Sub_ASA__c))+' '+l.Sotto_ASA__c;
                             system.debug('++++'+NameSottoASA);
    
                         }
                        
                     MappingASA__c mapASA = MappingASA__c.getValues(String.valueOf(Integer.valueOf(config.ASA__c)));

                                
                     l.Codice_ASA__c = String.valueOf(Integer.valueOf(config.ASA__c));
                     l.ASA__c = mapASA.ASA__c;
                     l.ASA_Description__c = String.valueOf(Integer.valueOf(config.ASA__c))+' - '+l.ASA__c;
                     
                     }
                     
                }
                }
                                
                 //FM --- end      
    }  
}