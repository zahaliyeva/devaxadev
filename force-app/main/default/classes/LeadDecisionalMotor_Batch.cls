/*-------------------------------------------------------------------------------------------------------------------------
Author:        Andrea Capobianco
Company:       Deloitte
Class:         LeadDecisionalMotor_Batch
Description:   
History

06/07/2017     Andrea Capobianco - Created
----------------------------------------------------------------------------------------------------------------------------
* Id: 001
* description: Lead Management Sprint 46: Send email notifications
* date: 10/07/2017
* author: Juana Valenzuela
----------------------------------------------------------------------------------------------------------------------------*/
global class LeadDecisionalMotor_Batch implements Database.Batchable<sObject>,Database.Stateful,Schedulable
{
  
    global string performquery;
    global string CLASS_NAME = (!Test.isRunningTest())?'LeadDecisionalMotor_Batch':'testBatch';
    public Lead currentLead {get;set;}
    public boolean hasBeenScheduled = false;
    public DateTime currentHour = system.now();
    public Map<Id,Set<String>> mapIdLeadToSetOfAgencyCodesForReassignation {get;set;}
    public Map<Id,Set<String>> mapIdLeadToSetOfQueueNameForReassignation {get;set;}
    public Map<Id,Set<String>> mapIdLeadToSetOfAgencyCodesAlreadyAssigned {get;set;}
    public Map<Id,List<DateTime>> mapLeadIdToStatusChanges {get;set;}
    public List<Lead> listUpdatedLead {get;set;}
    public map<String,Id> mapAgencyIdToAgencyCode {get;set;}
    public map<Id,Decimal> mapAgencyIdToAssegnazioniWeek {get;set;}
    public map<Id,Decimal> mapAgencyIdToAssegnazioniToday {get;set;}
    public map<String,Id> mapQueueCodeToId {get;set;}
    public Set<String> setActiveAgencyCodes {get;set;}

    public Id toBeProcessedQueueId = [SELECT Id From Group WHERE Type = 'Queue' and DeveloperName = 'Coda_Lead_Da_Processare_Riassegnate' limit 1].Id;
    public Id doesNotAnswerQueueId = [SELECT Id From Group WHERE Type = 'Queue' and DeveloperName = 'Coda_Lead_Non_Risponde_Riassegnate' limit 1].Id;
    public Id removedAssignmentQueueId = [SELECT Id From Group WHERE Type = 'Queue' and DeveloperName = 'Coda_lead_web_duplicati_ass_rimossa' limit 1].Id;

    //getting the business hours
    public Id BHoursBefore = [SELECT id FROM BusinessHours WHERE Name = 'AAI_Agency_BeforeLunch'].Id;
    public Id BHoursAfter = [SELECT id FROM BusinessHours WHERE Name = 'AAI_Agency_AfterLunch'].Id;

    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        String lastNDays = String.valueOf(Integer.valueOf(LeadAssignmentConfiguration__c.getValues('Last n days for Lead duplication').DaysLimit__c));
        String DettagliFonteLead = LeadAssignmentConfiguration__c.getValues('Dettagli fonte Lead').Lead_Dettaglio__c;
        System.debug('#@#@# lastNDays '+lastNDays);

        return Database.getQueryLocator(
            //Start - 001
            'SELECT Id,FirstName,Ultima_data_di_riassegnazione__c,Status,OwnerId,Agenzie_per_riassegnazione__c,Azioni_intraprese_sul_Lead__c,TECH_isECommerceLead__c,Numero_assegnazioni_eseguite__c,TECH_Send_Email_Notification__c,Agenzie_gia_assegnate__c,Agenzie_gia_assegnate_complete__c,Sub_agenzie_gia_assegnate__c,Agency_Code__c,Tipologie_per_riassegnazione__c,Tipologie_per_riassegnazione_riordinata__c, Codice_Sub_Agenzia__c,Dettaglio__c,TECH_Email_Does_Not_Answer__c,Agenzie_per_riassegnazione_riordinata__c, RecordType.Name, RecordType.DeveloperName from Lead where CreatedDate = LAST_N_DAYS:'+lastNDays+' AND Agenzie_per_riassegnazione__c != null AND Landing_Page__c != \'Siti Agenti\' AND Provenienza_Campagne_Agenti__c = null AND LeadSource = \'Web\' AND (Status = \'To be processed\' OR Status = \'Does not answer\') AND (TECH_isECommerceLead__c = false OR (TECH_isECommerceLead__c = true AND Dettaglio__c in '+DettagliFonteLead+')) AND OwnerId != \''+toBeProcessedQueueId+'\' AND OwnerId != \''+doesNotAnswerQueueId+'\' AND  OwnerId != \''+removedAssignmentQueueId+'\''
            //End - 001
        );
    }

    global void execute(Database.BatchableContext bc, List<Lead> scope){

        // for each Lead in scope,save the list of the agencies and their related Queue for the reassignment
        // returned by Noovle in a Set, and put them in a map that links them to the Lead Id
        Set<Id> setIdLeadToUpdate = new Set<Id>();
        Set<String> setAllAgencyCodes = new Set<String>();
        Set<String> setAllQueueNames = new Set<String>();
        Map<String,Map<String, String>> subAgencyCode = new Map<String,Map<String, String>>();
        mapIdLeadToSetOfAgencyCodesForReassignation = new Map<Id,Set<String>>();
        mapIdLeadToSetOfQueueNameForReassignation = new Map<Id,Set<String>>();
        mapIdLeadToSetOfAgencyCodesAlreadyAssigned = new Map<Id,Set<String>>();
        mapLeadIdToStatusChanges = new Map <Id,List<DateTime>>();
        listUpdatedLead = new List<Lead>();
        mapAgencyIdToAgencyCode = new Map<String,Id>();
        mapAgencyIdToAssegnazioniWeek = new Map<Id,Decimal>();
        mapAgencyIdToAssegnazioniToday = new Map<Id,Decimal>();
        mapQueueCodeToId = new Map<String,Id>();
        setActiveAgencyCodes = new Set<String>();

        String giorno = String.valueOf(system.now().day());
        String mese = String.valueOf(system.now().month());
        String anno = String.valueOf(system.now().year());
        String ora = String.valueOf(system.now().hour());
        String minuti = String.valueOf(system.now().minute());
        String oggi = giorno+'/'+mese+'/'+anno+' ore '+ora+':'+minuti;

        System.debug('Scope: ' + scope);

        //DISMISSED BECAUSE THE REASSIGNATION DOESNT COUNT ON THE AGENCY LIMITS
        //Decimal assignationLimitToday = LeadAssignmentConfiguration__c.getValues('LimitAssignmentNumberToday').DaysLimit__c;
        //Decimal assignationLimitThisWeek = LeadAssignmentConfiguration__c.getValues('LimitAssignmentNumberWeek').DaysLimit__c;
        
        //getting the time limits in milliseconds
        Double toBeProcessedLimitInMilliseconds = LeadAssignmentConfiguration__c.getValues('ToBeProcessedTimeLimitHours').HoursLimit__c*60*60*1000;
        Double toBeProcessedOutsourceLimitInMilliseconds = LeadAssignmentConfiguration__c.getValues('ToBeProcessedOutsourceTimeLimitHours').HoursLimit__c*60*60*1000;
        Double doesNotAnswerFirstLimitInMilliseconds = LeadAssignmentConfiguration__c.getValues('doesNotAnswerFirstTimeLimitHours').HoursLimit__c*60*60*1000;
        Double doesNotAnswerSecondLimitInMilliseconds = LeadAssignmentConfiguration__c.getValues('doesNotAnswerSecondTimeLimitHours').HoursLimit__c*60*60*1000;

        //for each lead in scope, populating 6 sets:
        //the first one containing the ids of the leads in scope
        //the second one containing all the agency codes for reassignation for the single lead
        //the third one contains all the list of agency codes for reassignation,for all the leads in scope
        //the fourth one containing all the queue names of the agencies for reassignation, for the single lead
        //the fifth one contaning all the queue names of the agencies for reassignation, for all the leads in scope
        //the sixth one containing all the agency codes of the agencies to whom the lead has already been assigned to
        for(Lead l: scope)
        {
            Set<String> setSingleLeadAgencyCodesForReassignation = new Set<String>();
            Set<String> setSingleLeadQueueNameRiassegnazione = new Set<String>();
            Set<String> setSingleLeadAgencyCodesAlreadyAssigned = new Set<String>();
            Set<String> setSingleLeadAgenciestoRemove = new Set<String>();

            System.debug('#@#@# l.FirstName ' + l.FirstName);
            System.debug('#@#@# l.Tipologie_per_riassegnazione__c ' + l.Tipologie_per_riassegnazione__c);

            String listAgenciesForReassignation = '';
            String listSubAgenciesForReassignation = '';
            if(String.isNotBlank(l.Agenzie_per_riassegnazione_riordinata__c))
            {
                listAgenciesForReassignation = l.Agenzie_per_riassegnazione_riordinata__c;
                listSubAgenciesForReassignation = l.Tipologie_per_riassegnazione_riordinata__c;
            }
            else
            {
                listAgenciesForReassignation = l.Agenzie_per_riassegnazione__c;
                listSubAgenciesForReassignation = l.Tipologie_per_riassegnazione__c;
            }

            System.debug('#@#@# listAgenciesForReassignation ' + listAgenciesForReassignation);
            System.debug('#@#@# listSubAgenciesForReassignation ' + listSubAgenciesForReassignation);

            // NTORREGGIANI 11/07/2018 - SPRINT 72 START
            List<String> listListAgenciesForReassignation = new List<String>();
            List<String> listListSubAgenciesForReassignation = new List<String>();
            Map<String, String> leadSubAgencyCode = new Map<String, String>();
            if(listSubAgenciesForReassignation != null){
                listListAgenciesForReassignation = (listAgenciesForReassignation).split(';');
                listListSubAgenciesForReassignation = (listSubAgenciesForReassignation).split(';');
                for(Integer i = 0; i<listListAgenciesForReassignation.size(); i++){
                    leadSubAgencyCode.put(listListAgenciesForReassignation.get(i), listListSubAgenciesForReassignation.get(i));
                }
                System.debug('#@#@# leadSubAgencyCode ' + leadSubAgencyCode);
                subAgencyCode.put(l.Id, leadSubAgencyCode);
            }
            // NTORREGGIANI 11/07/2018 - SPRINT 72 END

            //1st Set
            setIdLeadToUpdate.add(l.Id);

            if(String.isNotBlank(listAgenciesForReassignation))
            {
                for(String s : (listAgenciesForReassignation).split(';'))
                {
                    //2nd Set 
                    setSingleLeadAgencyCodesForReassignation.add(s);
                    //3rd Set
                    setAllAgencyCodes.add(s);
                    //4th Set
                    setSingleLeadQueueNameRiassegnazione.add('Coda_Agenzia_'+s);
                    //5th Set
                    setAllQueueNames.add('Coda_Agenzia_'+s);
                }

                for(String s : (listAgenciesForReassignation).split(';'))
                {
                    setSingleLeadAgenciestoRemove.add(s);
                    
                    if(s == L.Agency_Code__c)
                    {
                        break;
                    }
                }

                for(String ag : setSingleLeadAgenciestoRemove){

                    setSingleLeadAgencyCodesForReassignation.remove(ag);
                }

            }
            if(String.isNotBlank(l.Agenzie_gia_assegnate__c))
            {
                for(String ss: (l.Agenzie_gia_assegnate__c).split(';'))
                {
                    //6th Set
                    setSingleLeadAgencyCodesAlreadyAssigned.add(ss);
                }
            }
            //then saving the sets for the single lead in a map that links them to the lead id
            mapIdLeadToSetOfAgencyCodesForReassignation.put(l.id,setSingleLeadAgencyCodesForReassignation);
            mapIdLeadToSetOfQueueNameForReassignation.put(l.id,setSingleLeadQueueNameRiassegnazione);
            mapIdLeadToSetOfAgencyCodesAlreadyAssigned.put(l.id,setSingleLeadAgencyCodesAlreadyAssigned);
        }

        System.debug('#@#@# mapIdLeadToSetOfAgencyCodesForReassignation '+mapIdLeadToSetOfAgencyCodesForReassignation);
        System.debug('#@#@# mapIdLeadToSetOfQueueNameForReassignation '+mapIdLeadToSetOfQueueNameForReassignation);

        //Retrieving all the active agencies and their queues for all the leads in scope
        List<Account> listActiveAgencies = [SELECT Id,Agency_Code__c From Account Where RecordType.Name = 'Agency' AND Agency_Code__c IN: setAllAgencyCodes AND Active__c = true AND Accordo_Digitale__c = true];
        List<Group> listQueues = [SELECT Id,DeveloperName From Group WHERE Type = 'Queue' and DeveloperName IN: setAllQueueNames];
        //DISMISSED
        //List<Assegnazioni__c> listAssegnazioniWeek = [SELECT Id,Account__c, Numero_Assegnazioni__c,CreatedDate FROM Assegnazioni__c WHERE Account__c IN: listActiveAgencies AND CreatedDate = This_Week];

        System.debug('#@#@ list active agencies'+listActiveAgencies);
        System.debug('#@#@ list queues'+listQueues);

        //Retrieving the datetime of all the status changes for the leads in scope and populating a map that relates them to the lead id
        List<LeadHistory> listAllLeadsAllStatusChanges = [SELECT CreatedDate,LeadId FROM LeadHistory WHERE Field = 'Status' AND LeadId IN: setIdLeadToUpdate ORDER BY CreatedDate DESC NULLS LAST];

        for(Id id: setIdLeadToUpdate) 
        {
            List<DateTime> listSingleLeadAllStatusChanges = new List<DateTime>();
            for(LeadHistory lh: listAllLeadsAllStatusChanges)
            {
                if(lh.LeadId == id)
                {
                    listSingleLeadAllStatusChanges.add(lh.CreatedDate);
                }
            }
            mapLeadIdToStatusChanges.put(id, listSingleLeadAllStatusChanges);
        }

        System.debug('#@#@# Map Lead Id to List status changes'+mapLeadIdToStatusChanges);

        //Populating 4 maps: 
        //the 1st one containing the the agency code and the Id of the agency
        //the 2nd one containing the Id of the agency and its number of assignations for today
        //the 3rd one containing the Id of the agency and its number of assignations for the week
        //the 4th one containing the agency code of the agency and the id of the related queue 
        for(Account agenzia: listActiveAgencies)
        {
            setActiveAgencyCodes.add(agenzia.Agency_Code__c);
            mapAgencyIdToAgencyCode.put(agenzia.Agency_Code__c,agenzia.Id);
            
            //DISMISSED
            //Decimal numeroAssegnazioniToday = 0;
            //Decimal numeroAssegnazioniThisWeek = 0;
            /*for(Assegnazioni__c assegnazioni: listAssegnazioniWeek)
            {
                if(assegnazioni.Account__c == agenzia.Id)
                {
                    numeroAssegnazioniThisWeek = numeroAssegnazioniThisWeek+assegnazioni.Numero_Assegnazioni__c;
                    if(assegnazioni.CreatedDate.isSameDay(system.today()))
                    {   
                        numeroAssegnazioniToday = assegnazioni.Numero_Assegnazioni__c;
                    }
                }
            }*/
            //mapAgencyIdToAssegnazioniToday.put(agenzia.Id,numeroAssegnazioniToday);
            //mapAgencyIdToAssegnazioniWeek.put(agenzia.Id,numeroAssegnazioniThisWeek);
        }

        for(Group g: listQueues)
        {
            mapQueueCodeToId.put(String.valueOf(g.DeveloperName).right(6),g.Id);
        }

        System.debug('#@#@ mapAgencyIdToAgencyCode'+mapAgencyIdToAgencyCode);
        System.debug('#@#@ map queues'+mapQueueCodeToId);

        // process each batch of records
        //001 - Start
        List<Lead> leadForEmailAgency = new List<Lead>();
        List<Lead> leadForEmailLead = new List<Lead>();
        List<Id> reassignedToAgencyLeadId = new List<Id>(); //US 639 - lead ids used to act on activities
        //001 - End
        for (Lead lead : scope) 
        {
            System.debug(' ===> broken lead: ' + lead);
            Boolean agencyFound = false;
            Boolean toBeProcessedLimitTrespassed = false;
            Boolean doesNotAnswerFirstLimitTrespassed = false;
            Boolean doesNotAnswerSecondLimitTrespassed = false;
            Map<String, String> leadSubAgencyCode = new Map<String, String>();
            if(subAgencyCode.containsKey(lead.Id)){
                leadSubAgencyCode = subAgencyCode.get(lead.Id);
            }

            if(lead.status == 'To be processed' && lead.Ultima_data_di_riassegnazione__c != null)
            {   
                Double HoursBefore = BusinessHours.diff(BHoursBefore,lead.Ultima_data_di_riassegnazione__c , system.now());          
                Double HoursAfter = BusinessHours.diff(BHoursAfter,lead.Ultima_data_di_riassegnazione__c , system.now());         
                Double businessTimeSinceLastReassignation = HoursBefore+HoursAfter;
                Double timeToCheck = 'Outsource'.equalsIgnoreCase(lead.recordType.DeveloperName) ? toBeProcessedOutsourceLimitInMilliseconds : toBeProcessedLimitInMilliseconds; 
                
                if(businessTimeSinceLastReassignation > timeToCheck)
                {
                    toBeProcessedLimitTrespassed = true;
                }
                system.debug('#@#@ business time since last reassignation '+businessTimeSinceLastReassignation);
                system.debug('#@#@ to be processed trespassed '+toBeProcessedLimitTrespassed);
            }
            
            if(lead.Status == 'Does not answer')
            {
                Double timeSinceLastStatusBefore = BusinessHours.diff(BHoursBefore,mapLeadIdToStatusChanges.get(lead.Id).get(0), system.now());
                Double timeSinceLastStatusAfter = BusinessHours.diff(BHoursAfter,mapLeadIdToStatusChanges.get(lead.Id).get(0), system.now());
                Double businessTimeSinceLastStatusChange = timeSinceLastStatusBefore+timeSinceLastStatusAfter;

                if(businessTimeSinceLastStatusChange > doesNotAnswerFirstLimitInMilliseconds)
                {
                    doesNotAnswerFirstLimitTrespassed = true;
                }

                if(businessTimeSinceLastStatusChange > doesNotAnswerSecondLimitInMilliseconds)
                {
                    doesNotAnswerSecondLimitTrespassed = true;
                }

                system.debug('#@#@ business time since last status change '+businessTimeSinceLastStatusChange);
                system.debug('#@#@ does not answer first limit '+doesNotAnswerFirstLimitTrespassed);
                system.debug('#@#@ does not answer second limit '+doesNotAnswerSecondLimitTrespassed);
            }

            if( lead.Status == 'To be processed' && toBeProcessedLimitTrespassed)
            {
                //if the Lead has agencies for reassignation
                if (mapIdLeadToSetOfAgencyCodesForReassignation.get(lead.Id).size() != 0)
                {
                    for(String agencyCode: mapIdLeadToSetOfAgencyCodesForReassignation.get(lead.Id))
                    {
                        //if the lead has not been already assigned to the agency and the agency is active
                        if(!(mapIdLeadToSetOfAgencyCodesAlreadyAssigned.get(lead.id).contains(agencyCode))&&setActiveAgencyCodes.contains(agencyCode))
                        {   
                            //DISMISSED
                            //getting the number of assignation from the agency code
                            /*
                            Boolean allowedToAssign = false;
                            Decimal numeroAssegnazioniAgenziaThisWeek = mapAgencyIdToAssegnazioniWeek.get(mapAgencyIdToAgencyCode.get(agencyCode));
                            Decimal numeroAssegnazioniAgenziaToday = mapAgencyIdToAssegnazioniToday.get(mapAgencyIdToAgencyCode.get(agencyCode));
                            
                            if(   numeroAssegnazioniAgenziaThisWeek<assignationLimitThisWeek
                                && numeroAssegnazioniAgenziaToday<assignationLimitToday)
                            {
                                allowedToAssign = true;
                            }
                            System.debug('#@# numeroAssegnazioniAgenziaToday '+numeroAssegnazioniAgenziaToday);
                            System.debug('#@# numeroAssegnazioniThisWeek '+numeroAssegnazioniAgenziaThisWeek);
                            System.debug('#@# allowedToAssign'+allowedToAssign);

                            //if(allowedToAssign) //if it's less than the limits configured, assign to the agency
                            {*/
                                
                            lead.OwnerId = mapQueueCodeToId.get(agencyCode);
                            lead.Agency_Code__c = agencyCode;
                            String subAgency = '-';
                            if(leadSubAgencyCode.isEmpty() || leadSubAgencyCode.get(agencyCode) == '-'){
                                lead.Codice_Sub_Agenzia__c = '';
                            } else {
                                lead.Codice_Sub_Agenzia__c = leadSubAgencyCode.get(agencyCode);
                                subAgency = lead.Codice_Sub_Agenzia__c;
                            }
                            
                            lead.Ultima_data_di_riassegnazione__c = system.now();

                            if(String.isBlank(lead.Azioni_intraprese_sul_Lead__c))
                            {
                                lead.Azioni_intraprese_sul_Lead__c = oggi+'\n Lead assegnato all\'agenzia '+agencyCode+' dal motore decisionale';
                            }
                            else {
                                lead.Azioni_intraprese_sul_Lead__c = 'Ultima riassegnazione automatica del Lead: '+oggi+'\n Lead assegnato all\'agenzia '+agencyCode+' dal motore decisionale';
                            }
                            lead.Numero_assegnazioni_eseguite__c = lead.Numero_assegnazioni_eseguite__c+1;
                            //CAPOBIANCO_A 26/07/2017 -- START
                            //lead.Codice_Sub_Agenzia__c = '';
                            //CAPOBIANCO_A 26/07/2017 -- END
                            lead.Agenzie_gia_assegnate__c = (lead.Agenzie_gia_assegnate__c == null || lead.Agenzie_gia_assegnate__c == '')? agencyCode+';':lead.Agenzie_gia_assegnate__c+agencyCode+';';
                            lead.Sub_agenzie_gia_assegnate__c = (lead.Sub_agenzie_gia_assegnate__c == null || lead.Sub_agenzie_gia_assegnate__c == '')? subAgency+';':lead.Sub_agenzie_gia_assegnate__c+subAgency+';';
                            System.debug(' ===> lead.Agenzie_gia_assegnate_complete__c: ' + lead.Agenzie_gia_assegnate_complete__c);
                            System.debug(' ===> lead.Agency_Code__c: ' + lead.Agency_Code__c);
                            System.debug(' ===> subAgency: ' + subAgency);
                            if(subAgency == '-'){
                                lead.Agenzie_gia_assegnate_complete__c = lead.Agenzie_gia_assegnate_complete__c + lead.Agency_Code__c + ';';                                 
                            } else {
                                lead.Agenzie_gia_assegnate_complete__c = lead.Agenzie_gia_assegnate_complete__c + subAgency + ';';
                            }
                            listUpdatedLead.add(lead);
                            agencyFound = true;
                            //001 - Start
                            lead.TECH_Send_Email_Notification__c = true;
                            system.debug('****JV - num. assegnazioni eseguite: ' + lead.Numero_assegnazioni_eseguite__c);
                            system.debug('****JV - dettaglio fonte: ' + lead.Dettaglio__c);
                            Decimal numFirstRiassignment = 2;
                            system.debug('****JV - first riassignment: ' + numFirstRiassignment);
                            if(lead.Dettaglio__c == 'Richiedi appuntamento' && lead.Numero_assegnazioni_eseguite__c == numFirstRiassignment)
                                lead.Send_Email_Lead__c = true;
                            leadForEmailAgency.add(lead);
                            leadForEmailLead.add(lead);
                            reassignedToAgencyLeadId.add(lead.id);
                            //001 - End
                            break;
                            //}
                        }
                    }
                }
                // if the lead doesn't have agencies for reassignation, or a valid agency hasn't been found, reassign it to the queue
                if((mapIdLeadToSetOfAgencyCodesForReassignation.get(lead.Id).size() == 0 || agencyFound == false) && lead.OwnerId != toBeProcessedQueueId)
                {
                    lead.OwnerId = toBeProcessedQueueId;
                    lead.Agency_Code__c = '';
                    //CAPOBIANCO_A 26/07/2017 -- START
                    lead.Codice_Sub_Agenzia__c = '';
                    //CAPOBIANCO_A 26/07/2017 -- END
                    lead.Azioni_intraprese_sul_Lead__c = 'Lead riassegnato alla coda generica per mancata lavorazione entro i limiti temporali configurati';
                    lead.TECH_Send_Email_Notification__c = false;
                    
                    //DISMISSED
                    //lead.Ultima_data_di_riassegnazione__c = system.now();
                    //lead.Numero_assegnazioni_eseguite__c = lead.Numero_assegnazioni_eseguite__c+1;
                    listUpdatedLead.add(lead);   
                }
            }
            else if(lead.Status == 'Does not answer' && doesNotAnswerFirstLimitTrespassed){  
                //Start - 001
                if( !lead.TECH_Email_Does_Not_Answer__c){
                    lead.TECH_Email_Does_Not_Answer__c = true;
                    listUpdatedLead.add(lead);
                }
                //End - 001
                else{
                    if( doesNotAnswerSecondLimitTrespassed && lead.OwnerId != doesNotAnswerQueueId){  
                        lead.OwnerId = doesNotAnswerQueueId;
                        //lead.Agency_Code__c = ''; BOVOLENTA_D SPRINT 59
                        //CAPOBIANCO_A 26/07/2017 -- START
                        //lead.Codice_Sub_Agenzia__c = '';
                        //CAPOBIANCO_A 26/07/2017 -- END                        
                        lead.Azioni_intraprese_sul_Lead__c = 'Lead riassegnato alla coda generica per mancata lavorazione entro i limiti temporali configurati';
                        lead.TECH_Send_Email_Notification__c = false;

                        //DISMISSED
                        //lead.Ultima_data_di_riassegnazione__c = system.now();
                        //lead.Numero_assegnazioni_eseguite__c = lead.Numero_assegnazioni_eseguite__c+1;
                        listUpdatedLead.add(lead);
                    }    
                }        
            }
        } 

        if(listUpdatedLead.size()!=0)
        {
            Database.update(listUpdatedLead,false);
            
            //BOVOLENTA_D US 639
            if (reassignedToAgencyLeadId.size()>0) 
            {
                LeadEngineUtility.handleRelatedActivities(reassignedToAgencyLeadId);
            }
        }
    }
   

    global void Execute(SchedulableContext SC)
    {  
        System.abortJob(SC.getTriggerId());        
        
        LeadDecisionalMotor_Batch b = new LeadDecisionalMotor_Batch();
         b.setHasBeenScheduled(true);
        
        Apex_Schedulation_Manager__c asm = Apex_Schedulation_Manager__c.getInstance(CLASS_NAME);
        
        Database.ExecuteBatch(b,Integer.valueOf(asm.Scope__c));      
    }    

    global void finish(Database.BatchableContext BC)
    {
        Apex_Schedulation_Manager__c asm = Apex_Schedulation_Manager__c.getInstance(CLASS_NAME);
        
        //Plan New Execution if needed  
        if (asm.Autoschedule__c && hasBeenScheduled==true) 
        { 
            String sch = '';
            if (asm.Expression__c != null)
            { 
                sch = asm.Expression__c;

                //CAPOBIANCO_A 28/09/2017 - START
                if((30 <= system.now().minute()) && (system.now().minute() <= 59))
                {
                    sch = asm.Expression_Bis__c;
                }
                //CAPOBIANCO_A 28/09/2017 - END
            } 
            else
            { 
                sch = ApexSchedulationManager.getScheduleString(asm.Frequency__c+'');
            }
            
            //Launch this batch only between 8-20
            Datetime CurrentTime = Datetime.now();
            if (CurrentTime.hour()>=8 && CurrentTime.hour()<=20)
            {
                //schedule as explained by the Custom Setting
                system.Schedule(asm.name+String.ValueOf(System.currentTimeMillis()),sch,new LeadDecisionalMotor_Batch());
            } 
            else
            {
                //Schedule for 8 in the morning after. the string format is 'ss min hh dd mm DOW yy'
                sch ='00 00 08';
                
                if (CurrentTime.hour()>20) 
                {//must go for tomorrow
                    sch = sch+' '+CurrentTime.addDays(1).day();
                    sch = sch+ ' ' +CurrentTime.addDays(1).month();
                    sch = sch+' ? ';//any day of the week
                    sch = sch+' '+CurrentTime.addDays(1).Year();
                } else 
                {//is early in the morning, just scheduling for today at 8
                    sch = sch+' '+CurrentTime.day();
                    sch = sch+ ' ' +CurrentTime.month();
                    sch = sch+' ? ';//any day of the week
                    sch = sch+' '+CurrentTime.Year();
                }
                system.Schedule(asm.name+String.ValueOf(System.currentTimeMillis()),sch,new LeadDecisionalMotor_Batch());
            }
        } 
        
    }
    
    public void setHasBeenScheduled(boolean b)
    { 
        hasBeenScheduled = b;
    } 
}