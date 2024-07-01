public without sharing class NewMilestoneTrackingManagement {
    public static boolean runMilestoneTracking = true; 
    static private list<Schema.PicklistEntry> PicklistEntries = Case.Status.getDescribe().getPicklistValues();
    static private map<String,String> ApiToLabel = new Map<String, String>();
	static String defaultKey = [Select value__c from NewWorkingTimesMapping__mdt where developername = 'DefaultRole'].value__c;
    
        
    
    static public void processMilestoneandWorkingTime(List<Case> Cases, Map<String,Case> OldValues,Map<String,String> ownerIdProfileNameMap, Map<String, String> ownerIdRoleNameMap){
        if(runMilestoneTracking){
            runMilestoneTracking = false;
        try{
        for(Schema.PicklistEntry PE : PicklistEntries){
            ApiToLabel.put(PE.getValue(),PE.getLabel());
        }
            
            system.debug('List Case in input: ' + Cases);
        List<Case> caseList = [SELECT Id,CaseNumber, Current_Owner_Queue__c, HD3_IT__c, Status, CaseMilestone_StartDate__c, Owner.Profile.Name, // NOPMD  Fix CRUD violation
                  RecordType.DeveloperName, OwnerId, Owner.UserRole.Name, Tempo_in_gestione_HD3__c,
                  Time_With_Support__c, Time_With_Customer__c, Time_With_Agent__c, Priority,
                  MilestoneFlag__c, isClosed, Durata_lavorazione_uffici_tecnici__c,Tipologia_Case__c,
                  Owner.Name, Owner.FirstName, Owner.LastName, CreatedById, CreatedBy.ProfileID,CreatedBy.Name, CreatedBy.Profile.Name, LastModifiedById,QueueNameOwner__c,Case_Team_Members_Role__c,
                  (SELECT id, StartDate, CompletionDate, IsCompleted
                  FROM CaseMilestones 
                  WHERE IsCompleted = false)
                  FROM Case 
                  WHERE Id IN:Cases ];
       
        Map<String,ID> BusinessHoursMap = new Map<String,Id>();
        for(BusinessHours b : [Select Name, Id from BusinessHours ]){ // NOPMD  Fix CRUD violation
            BusinessHoursMap.put(b.name,b.ID);
        }
        Set<String> RecTypes = new Set<String>();
        for(case c : caseList){
            recTypes.add(c.RecordType.DeveloperName);
        }
        
        List<Milestone_Tracking__c> OldMilestoneTrackings = [SELECT Case__c, id, // NOPMD  Fix CRUD violation
                                                             CaseStatus__c, Gruppo_di_Lavoro__c,
                                                             OwnerId, SupportEndDate__c,
                                                             SupportStartDate__c,
                                                             TimeSpent__c,UserProfile__c,
                                                             CaseFieldToUpdate__c,
                                                             UserRole__c,
                                                             Working_Time__r.time_spent__c,
                                                             Working_Time__r.UserProfile__c,
                                                             Working_Time__r.UserRole__c,
                                                             CreatedDate,
															 Tipologia_di_Tempo__c,
                                                             Ruolo_Team_Member_di_Partenza__c
                                                             FROM Milestone_Tracking__c 
                                                             WHERE Case__c in:caseList 
                                                             ORDER BY Case__c,
                                                             SupportStartDate__c desc,
                                                             createdDate desc];
        String IdAdministrator = '';
        
        User u = [SELECT Id FROM User WHERE Profile.Name IN ('System Administrator','Amministratore del sistema') AND Alias ='utte'  LIMIT 1]; // NOPMD  Fix CRUD violation
        
        if(u!=null)
        {
            IdAdministrator = u.Id;
        }
        else{
            System.debug('Id Utente Tecnico non presente');
        }
        Map<String,TeamMemberMap__mdt> TeamMemberConfigMap = new Map<String,TeamMemberMap__mdt>();
        for(TeamMemberMap__mdt temp : [SELECT Profilo_Advisor__c, // NOPMD  Fix CRUD violation
                                                      Ruolo_Advisor__c,
                                                      Ruolo_Team_Member__c,
                                       CaseRecordType__c,
                                       BusinessHoursName__c,
                                                      SLA__c 
                                       FROM TeamMemberMap__mdt
                                       WHERE CaseRecordType__c in :recTypes or CaseRecordType__c = '*' 
                                      	]){
            String tempKey;
            if(temp.Ruolo_Advisor__c == null){
                tempKey = temp.CaseRecordType__c.toLowerCase()+'_'+temp.Profilo_Advisor__c.toLowerCase()+'_*';
            }
            else{
                tempKey = temp.CaseRecordType__c.toLowerCase()+'_'+temp.Profilo_Advisor__c.toLowerCase()+'_'+temp.Ruolo_Advisor__c.toLowerCase();
            }
            TeamMemberConfigMap.put(tempKey,temp);
            
        }
        
        Map<Id,List<Milestone_Tracking__c>> caseIdMilestoneTrackingMap = new Map<Id,List<Milestone_Tracking__c>>();
        Map<String,NewWorkingTimesMapping__mdt> ConfigurationMap = new Map<String,NewWorkingTimesMapping__mdt>();
        for(NewWorkingTimesMapping__mdt conf : [Select DeveloperName, value__c, Key__c from NewWorkingTimesMapping__mdt ]){ // NOPMD  Fix CRUD violation
            ConfigurationMap.put(conf.DeveloperName, conf);
        }
        //Map<Id,List<Working_Times__c>> caseIdMilestoneTrackingMap = new Map<Id,List<Working_Times__c>>();
        ID CaseTemp = null;
        List<Milestone_Tracking__c> tempList = new List<Milestone_Tracking__c>();
        For(Milestone_Tracking__c temp : OldMilestoneTrackings){
            if(CaseTemp == null){
                CaseTemp = temp.Case__c;
            }
            if(temp.Case__c != CaseTemp){
                caseIdMilestoneTrackingMap.put(CaseTemp,tempList);
                tempList = new List<Milestone_Tracking__c>{temp};// Case 07185006 - BUG - Anomalia Case CTL *-+ 05-12-2022
                CaseTemp = temp.Case__c;
            }
            else{
                tempList.add(temp);
            }
        }
        caseIdMilestoneTrackingMap.put(CaseTemp,tempList);
        List<String> fieldControl = new List<String>();
        if(ConfigurationMap.containsKey('FieldControl')){
            fieldControl = ConfigurationMap.get('FieldControl').value__c.split(';');
        }
        List<Milestone_Tracking__c> MTToUpdate = new List<Milestone_Tracking__c>();
        List<Milestone_Tracking__c> MTToInsert = new List<Milestone_Tracking__c>();
        List<Working_Times__c> WTToUpdate = new List<Working_Times__c>();
        List<Case> CsToUpdate = new List<Case>();
        for(Case c : caseList){
            Case old = OldValues.get(c.Id);
            SObject caseNewSObj = c;
            SObject caseOldSObj = old;
            boolean calculate = false;
            system.debug('+++ Old values: '+old.get('CaseNumber'));
            if(caseOldSObj != null){
                   for(String s : fieldControl){
                       if(old.get('CaseNumber') == null || (String) caseNewSObj.get(s) != (String)caseOldSObj.get(s)){
                           calculate = true;
                       }
                   }
                
                if(!calculate){
                    if(caseIdMilestoneTrackingMap.get(c.Id) == null){
                        
                       	Map<String, Object> CaseMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(caseOldSObj));
                        CaseMap.remove('CaseNumber');
                        caseOldSObj = (SObject) JSON.deserialize( JSON.serialize( CaseMap ), SObject.class );
                        calculate = true;
                    }
                }
                
                   if (calculate){
                       ParameterWrapper p = new ParameterWrapper();
                       p.caseNew = c;
                       p.caseOld = caseOldSObj;
                       p.MilestoneTrackingList = caseIdMilestoneTrackingMap.get(c.Id);
                       OBJWrapper result;
                       result = calculateMilestones(p,ownerIdProfileNameMap,ownerIdRoleNameMap,ConfigurationMap,IdAdministrator,TeamMemberConfigMap,BusinessHoursMap);
                       if(result != null){
                           if(result.MTToUpdate != null  && !result.MTToUpdate.isEmpty()){
                               
                               MTToUpdate.addAll(result.MTToUpdate);
                               
                           }
                           if(result.MTToInsert != null && !result.MTToInsert.isEmpty() ){
                               MTToInsert.addAll(result.MTToInsert);
                           }
                           if(result.WTToUpdate != null && !result.WTToUpdate.isEmpty()){
                               WTToUpdate.addAll(result.WTToUpdate);
                           }
                           if(result.CaseToUpdate != null && !result.CaseToUpdate.isEmpty() ){
                               CsToUpdate.addAll(result.CaseToUpdate);
                           }
                       }
                   } 
            }
        }
        
            if(!MTToInsert.isEmpty()){
                //insert ;
                Database.SaveResult[] srList = Database.insert(MTToInsert, false);
                List<ApplicationLogHelper.ErrorWrapper> Errors = new List<ApplicationLogHelper.ErrorWrapper>();
                Integer i = 0;
                for (Database.SaveResult sr : srList){

                    if (!sr.isSuccess()){
                        String ErrorMessage = '';
                        String ErrorDetail = 'Insert MilestoneTracking on caseId: ' + MTToInsert.get(i).Case__c;
                        for(Database.Error err : sr.getErrors()){
                            ErrorMessage += err.message + '\n';
                        }
                        Errors.add(new ApplicationLogHelper.ErrorWrapper(ErrorMessage, ErrorDetail));

                    }
                    i++;
                }
                if(!Errors.isEmpty()){
                    ApplicationLogHelper.LogErrors('NewMilestoneTrackingManagement', Errors);
                }
            }
            if(!MTToUpdate.isEmpty()){
                update MTToUpdate; // NOPMD  Fix CRUD violation
            }
            if(!CsToUpdate.isEmpty()){
                update CsToUpdate; // NOPMD  Fix CRUD violation
            }
            if(!WTToUpdate.isEmpty()){
                update WTToUpdate; // NOPMD  Fix CRUD violation
            }
            
        }catch(Exception ex){
            try{
            ApplicationLogHelper.ERROR('NewMilestoneTrackingManagement', ex.getmessage(), ex.getStackTraceString());
            }catch(Exception e){
                System.debug(System.LoggingLevel.ERROR,'Exception: ' + e.getmessage() + '\tStackTrace: '+e.getStackTraceString());
            }
        }
    }
    }
    
    Static OBJWrapper calculateMilestones(ParameterWrapper input,Map<String,String> ownerIdProfileNameMap, Map<String, String> ownerIdRoleNameMap,Map<String,NewWorkingTimesMapping__mdt> ConfigurationMap, String IdAdministrator,Map<String,TeamMemberMap__mdt>TeamMemberConfigMap, Map<String,ID> BusinessHoursMap){
        SObject caseNew = input.caseNew, caseOld = input.caseOld;
        case cFull = input.caseNew;
        Case cToUpdate =  new Case(Id = input.caseNew.Id);
        String BusinessHoursName = 'Default';
        String Key, KeyWithoutRole;
        String KeyWithoutRT, KeyWithoutRoleAndRT;
        Set<Case> CasesToUpdate = new Set<Case>();
    
        TeamMemberMap__mdt key2;
            if(ownerIdProfileNameMap.containsKey(String.valueOf(cFull.OwnerId))
               && ownerIdProfileNameMap.get(String.valueOf(cFull.OwnerId)) != null
               && ownerIdRoleNameMap.containsKey(String.valueOf(cFull.OwnerId)) 
               && ownerIdRoleNameMap.get(String.valueOf(cFull.OwnerId)) != null
               ){
                Key = cFull.Recordtype.DeveloperName.toLowerCase()+'_'+ownerIdProfileNameMap.get(String.valueOf(cFull.OwnerId)).toLowerCase() +'_'+ ownerIdRoleNameMap.get(String.valueOf(cFull.OwnerId)).toLowerCase();
                KeyWithoutRole = cFull.Recordtype.DeveloperName.toLowerCase()+'_'+ownerIdProfileNameMap.get(String.valueOf(cFull.OwnerId)).toLowerCase()+'_*';
                KeyWithoutRT = '*_'+ownerIdProfileNameMap.get(String.valueOf(cFull.OwnerId)).toLowerCase() +'_'+ ownerIdRoleNameMap.get(String.valueOf(cFull.OwnerId)).toLowerCase();
                KeyWithoutRoleAndRT = '*_'+ownerIdProfileNameMap.get(String.valueOf(cFull.OwnerId)).toLowerCase()+'_*';
                system.debug('Profilo : ' + ownerIdProfileNameMap.get(String.valueOf(cFull.OwnerId)) + ', Ruolo : '+ownerIdRoleNameMap.get(String.valueOf(cFull.OwnerId)));
            	system.debug('Chiavi: '+Key+'    '+KeyWithoutRole);
            }
            if(Key!= null && KeyWithoutRole != null && KeyWithoutRT!= null && KeyWithoutRoleAndRT!= null){
                for(String k : TeamMemberConfigMap.keySet()){
                    system.debug('Chiave: '+k);
                }
                if(TeamMemberConfigMap.containsKey(Key)){
                    key2 = TeamMemberConfigMap.get(Key);
                    if(TeamMemberConfigMap.get(Key).BusinessHoursName__c!= null)
                    	BusinessHoursName = TeamMemberConfigMap.get(Key).BusinessHoursName__c;
                }
                else if(TeamMemberConfigMap.containsKey(KeyWithoutRT)){
                    key2 = TeamMemberConfigMap.get(KeyWithoutRT);
                    if(TeamMemberConfigMap.get(KeyWithoutRT).BusinessHoursName__c!= null)
                    	BusinessHoursName = TeamMemberConfigMap.get(KeyWithoutRT).BusinessHoursName__c;
                }
                else if(TeamMemberConfigMap.containsKey(KeyWithoutRole)){
                    key2 = TeamMemberConfigMap.get(KeyWithoutRole);
                    if(TeamMemberConfigMap.get(KeyWithoutRole).BusinessHoursName__c!= null)
                    	BusinessHoursName = TeamMemberConfigMap.get(KeyWithoutRole).BusinessHoursName__c;
                }
                else if(TeamMemberConfigMap.containsKey(KeyWithoutRoleAndRT)){
                    key2 = TeamMemberConfigMap.get(KeyWithoutRoleAndRT);
                    if(TeamMemberConfigMap.get(KeyWithoutRoleAndRT).BusinessHoursName__c!= null)
                    	BusinessHoursName = TeamMemberConfigMap.get(KeyWithoutRoleAndRT).BusinessHoursName__c;
                }
                else{
                    key2 = TeamMemberConfigMap.get(defaultKey.toLowerCase());
                    if(TeamMemberConfigMap.get(defaultKey.toLowerCase()).BusinessHoursName__c!= null)
                    	BusinessHoursName = TeamMemberConfigMap.get(defaultKey.toLowerCase()).BusinessHoursName__c;
                }
            }
        String defaultHoursId;
        if(BusinessHoursMap.containsKey(BusinessHoursName)){
            defaultHoursId = BusinessHoursMap.get(BusinessHoursName);
        }
        OBJWrapper temp = new OBJWrapper();
        
        String caseStatusLabel, oldCaseStatusLabel;
        if(ApiToLabel.containsKey(cFull.Status) && ApiToLabel.containsKey((String)caseOld.get('Status'))){
            caseStatusLabel = ApiToLabel.get(cFull.Status);
            oldCaseStatusLabel = ApiToLabel.get((String)caseOld.get('Status'));
        }
        
        Boolean recordTrovato = false;
        String profileToSet = '';
        List<Working_Times__c> workingTimes = new List<Working_Times__c>();
        List<Milestone_Tracking__c> MilestoneTrackingList = input.MilestoneTrackingList;
        
        system.debug('++++++LIST: '+MilestoneTrackingList);
        if(MilestoneTrackingList != null && !MilestoneTrackingList.isEmpty()){
            Milestone_Tracking__c old = MilestoneTrackingList.get(0);
            Double timeSinceLastChangeOwner = BusinessHours.diff(defaultHoursId, old.SupportStartDate__c, System.now())/3600000.0; 
            if(old.TimeSpent__c!=null){
                old.TimeSpent__c = old.TimeSpent__c+timeSinceLastChangeOwner;
                working_times__c wt = old.Working_time__r;
                if(wt.Time_Spent__c != null)
                	wt.Time_Spent__c += timeSinceLastChangeOwner;
                else
                    wt.Time_Spent__c = timeSinceLastChangeOwner;
                workingTimes.add(wt);
                //old.Working_Time__r.Time_Spent__c = old.Working_Time__r.Time_Spent__c+timeSinceLastChangeOwner;
            }
            else{
                old.TimeSpent__c = timeSinceLastChangeOwner;
                working_times__c wt = old.Working_time__r;
                if(wt.Time_Spent__c != null)
                wt.Time_Spent__c += timeSinceLastChangeOwner;
                else
                    wt.Time_Spent__c = timeSinceLastChangeOwner;
                workingTimes.add(wt);
            }

            
            //Per i tempi di gruppo modificare il valore del campo "Team Member Role" del dettaglio tempo di lavorazione con il ruolo dell'utente nel team member che prende in carico il case dalla coda.
			if(((String)caseOld.get('OwnerId')).startsWith('00G') && ((String)caseNew.get('OwnerId')).startsWith('005')){
                old.UserProfile__c=   Key2?.Ruolo_Team_Member__c;
            }
            //end
            
            if(old.caseFieldToUpdate__c != null){
                SObject c = caseNew;
                if(c.get(old.caseFieldToUpdate__c) != null){
                    c.put(old.caseFieldToUpdate__c, ((Double)c.get(old.caseFieldToUpdate__c))+timeSinceLastChangeOwner);
                }
                else
                    c.put(old.caseFieldToUpdate__c,timeSinceLastChangeOwner);
                
                cToUpdate = (Case)c;
            }
            
            temp.WTToUpdate.addAll(workingTimes);
            old.SupportEndDate__c = system.now();
            temp.MTToUpdate.add(old);
            /*for(Milestone_Tracking__c MT :  MilestoneTrackingList){
                system.debug('+++Statuses: '+MT.CaseStatus__c+' '+oldCaseStatusLabel+' '+MT.OwnerId+ ' ' +(ID)caseOld.get('OwnerID') );
                /*if(MT.CaseStatus__c.equals((String)caseOld.get('Status')) && 
                   (MT.OwnerId.equals((ID)caseOld.get('OwnerID')) || 
                    (MT.Gruppo_di_lavoro__c!=null && MT.Gruppo_di_lavoro__c.equals(ownerIdProfileNameMap.get((String)caseOld.get('OwnerID')))) 
                   )
                    ){
                    Double timeSinceLastChangeOwner = BusinessHours.diff(defaultHoursId, MT.SupportStartDate__c, System.now())/3600000.0; 
                    if(MT.TimeSpent__c!=null){
                        MT.TimeSpent__c = MT.TimeSpent__c+timeSinceLastChangeOwner;
                        MT.Working_Time__r.Time_Spent__c = MT.Working_Time__r.Time_Spent__c+timeSinceLastChangeOwner;
                    }
                    else{
                        MT.TimeSpent__c = timeSinceLastChangeOwner;
                        
                    }
                    MT.SupportEndDate__c = system.now();
                    temp.MTToUpdate.add(MT);
                }--- comment here ---
                
                
                if(!temp.MTToUpdate.contains(MT)){
                if((MT.CaseStatus__c.equals(caseStatusLabel) && 
                   (MT.OwnerId.equals((ID)caseNew.get('OwnerID')) || 
                  	IdAdministrator.equals(MT.OwnerId) && ((String)caseNew.get('OwnerId')).startsWith('00G') 
                    && (MT.Gruppo_di_lavoro__c==(String)caseNew.get('QueueNameOwner__c'))) ) && (String)caseNew.get('HD3_IT__c') == (String)caseOld.get('HD3_IT__c')){
                    cToUpdate.CaseMilestone_StartDate__c = system.now();
                    MT.SupportStartDate__c = system.now();
                    temp.MTToUpdate.add(MT);
                    recordTrovato = true;
                    CasesToUpdate.add(cToUpdate);
                }
            }
                
            }*/
        }
        if(!recordTrovato /*&& 
           ((caseNew.get('HD3_IT__c') != caseOld.get('HD3_IT__c')) || 
            (caseNew.get('OwnerId') != caseOld.get('OwnerId') || caseNew.get('Status')!=caseOld.get('Status')) ||
           	caseOld.get('CaseNumber')== null)*/){
               
            system.debug('Nuova Milestone');
            Milestone_Tracking__c MT = new Milestone_Tracking__c();
          
            //Aggiungere un campo sui dettagli tempi di lavorazione "Ruolo Team Member di Partenza", attualmente c'è quello di destinazione
            Milestone_Tracking__c old = (MilestoneTrackingList != null && MilestoneTrackingList.size()!= 0)? MilestoneTrackingList.get(0): null;
			if(old != null){
                if(old.Tipologia_di_Tempo__c=='Tempo Gruppo')
                   MT.Ruolo_Team_Member_di_Partenza__c= old.Ruolo_Team_Member_di_Partenza__c;
                else
                    MT.Ruolo_Team_Member_di_Partenza__c= old.UserProfile__c;
            }
            //end


		  MT.SupportStartDate__c = system.now();
            if((Boolean) caseNew.get('isClosed')){
                MT.SupportEndDate__c = system.now();
            }
            MT.Case__c = (ID) caseNew.get('Id');
            MT.CaseStatus__c = caseStatusLabel;
            MT.TimeSpent__c = 0;
            if(AP_Constants.caseStatusGestioneHD3.equalsIgnoreCase(MT.CaseStatus__c)){
            if(caseNew.get('HD3_IT__c') != null ){
                MT.Gruppo_di_lavoro__c = (String)caseNew.get('HD3_IT__c');
                    
                }
                else{
                    MT.Gruppo_di_lavoro__c = 'HD3';
                }
                MT.CaseFieldToUpdate__c = 'Tempo_in_gestione_HD3__c';
                MT.UserProfile__c = 'HD3';
            }
            else{
                for(String CMkey : ConfigurationMap.keySet()){
                    if(CMkey.startsWith('GruppoDiLavoroCustom')){
                        if(ConfigurationMap.get(CMkey) != null && ConfigurationMap.get(CMkey).Key__c != null)
                            for(String value : ConfigurationMap.get(CMkey).Key__c.split(';')){
                            if(value.equalsIgnoreCase((String)caseNew.get('Status'))){
                                MT.Gruppo_di_lavoro__c = ConfigurationMap.get(CMkey).Value__c;
                            }
                        }
                    }
                }   
                if(MT.Gruppo_di_lavoro__c == null || String.isBlank(MT.Gruppo_di_lavoro__c))
                    if(caseNew.get('Current_Owner_Queue__c') != null){
                        Case tempCase = (Case) caseNew;
                        String CurrOwnQueue;
                        if(((String)tempCase.OwnerId).startsWith('00G')){
                            if(!tempCase.Owner.Name.equals(tempCase.Current_Owner_Queue__c.replace('_',' ')))
                                CurrOwnQueue = tempCase.Owner.Name;
                            else{
                                CurrOwnQueue = tempCase.Current_Owner_Queue__c.replace('_',' ');
                            }
                        }
                        else{
                            CurrOwnQueue = tempCase.Current_Owner_Queue__c.replace('_',' ');
                        }
                         
                        MT.Gruppo_di_lavoro__c = ((String)caseNew.get('Current_Owner_Queue__c')).startsWith('Coda_Agenzia')?
                                                    'AGENT':CurrOwnQueue;
                    }
                else{
                    MT.Gruppo_di_lavoro__c = cFull.Tipologia_Case__c;
                }
            }
            if(ownerIdRoleNameMap.containsKey((String)caseNew.get('OwnerId'))){
     	        MT.UserRole__c = ownerIdRoleNameMap.get((String)caseNew.get('OwnerId'));
            }
            else{
                Mt.UserRole__c = '';
            }
            if(!((String)caseNew.get('OwnerId')).startsWith('00G')){
                if(key2 != null){
                    if(MT.Gruppo_di_Lavoro__c == 'AGENT' || MT.Gruppo_di_Lavoro__c == 'CLIENTE'){
                        MT.UserProfile__c = MT.Gruppo_di_Lavoro__c;
                        MT.CaseFieldToUpdate__c = 'Time_With_Customer__c';
                    }
                    else
                    MT.UserProfile__c = Key2.Ruolo_Team_Member__c;
					
                    //Aggiunta di un campo sul case che sia la concatenazione dei Team Member Role: ogni volta che viene creato un record di tempi di lavorazione (o di dettagli tempi di lavorazione, in valutazione lato tecnico la soluzione migliore) viene concatenato il valore del ruolo team member.
					if( String.isBlank(cToUpdate.Case_Team_Members_Role__c))					
                        cToUpdate.Case_Team_Members_Role__c = Key2.Ruolo_Team_Member__c+';';                     
                    else
						if(!((cToUpdate.Case_Team_Members_Role__c).contains(Key2.Ruolo_Team_Member__c)))
						  cToUpdate.Case_Team_Members_Role__c += Key2.Ruolo_Team_Member__c+';';
					 //end  
					   
                    MT.TeamMemberSLA__c = Key2.SLA__c;
                    if(MT.UserProfile__c.Contains('HD1') && (MT.CaseFieldToUpdate__c == null || String.isBlank(MT.CaseFieldToUpdate__c))){
                        MT.CaseFieldToUpdate__c = 'Time_With_Support__c';
            }
                    else if(MT.UserProfile__c.Contains('HD2') && (MT.CaseFieldToUpdate__c == null|| String.isBlank(MT.CaseFieldToUpdate__c))){
                        MT.CaseFieldToUpdate__c = 'Durata_lavorazione_uffici_tecnici__c';
                }
                    
                }
            }
            else{
                MT = mapQueueProfile(MT);
                }
            String newOwner;
            
               
                
            newOwner = ((String) caseNew.get('OwnerId')).startsWith('00G') ? IdAdministrator : (String) caseNew.get('OwnerId');
            system.debug((String) caseNew.get('OwnerId'));
            MT.RecordTypeWorkingItem__c = ((String) caseNew.get('OwnerId')).startsWith('00G') ? AP_Constants.rtWorkTimCoda:AP_Constants.rtWorkTimUser;
            MT.OwnerID = MT.Owner__c = newOwner;
            ModelloDiAssistenzaUtils.setCaseHistory(MT,(Case) caseNew, (Case) caseOld);
            temp.MTToInsert.add(MT);
            cToUpdate.CaseMilestone_StartDate__c = system.now();
            CasesToUpdate.add(cToUpdate);
            temp.CaseToUpdate = CasesToUpdate;
        }
        
        return temp;
    }
    
    private static Milestone_Tracking__c mapQueueProfile(Milestone_Tracking__c MT){
        
        String value = 'Coda HD1 IT';
        if(MT.Gruppo_di_lavoro__c != null && String.isNotBlank(MT.Gruppo_di_lavoro__c)){
            if('AGENT'.equalsIgnoreCase(MT.Gruppo_di_lavoro__c)){
                MT.UserProfile__c = 'AGENT';
                MT.CaseFieldToUpdate__c = 'Time_With_Customer__c';
            }
            else{
                if(MT.Gruppo_di_lavoro__c.containsIgnoreCase('HD1 Contenzioso')){
                    value = 'Coda HD1 Contenzioso';
                    
                }
                else if(MT.Gruppo_di_lavoro__c.containsIgnoreCase('HD1 Contabilita')){
                    value = 'Coda HD1 Contabilita';
                    
                }
                else if(MT.Gruppo_di_lavoro__c.containsIgnoreCase('BIZ')){
                    value = MT.Gruppo_di_lavoro__c.contains('HD1')? 'Coda HD1 BIZ':'Coda HD2 BIZ';
                    
                }
                else if(MT.Gruppo_di_lavoro__c.containsIgnoreCase('IT')){
                    value = MT.Gruppo_di_lavoro__c.contains('HD1')? 'Coda HD1 IT':'Coda HD2 IT';
                }
                else if(MT.Gruppo_di_lavoro__c.containsIgnoreCase('Sinistri Danni Banca')){
                    value = 'Coda HD1 Customer Operation';
                    
                }
                String CurrOwnQueue = MT.Gruppo_di_lavoro__c.replaceAll(' ','_');
                List<Mapping_code__mdt> mapCode = [SELECT Coda_DevName__c, Queue_Type__c from Mapping_code__mdt where Coda_DevName__c =: CurrOwnQueue ]; // NOPMD  Fix CRUD violation
                if(!mapCode.isEmpty()){
                    if('HD1'.equalsIgnoreCase(mapCode.get(0).Queue_Type__c)){
                        MT.CaseFieldToUpdate__c = 'Time_With_Support__c';
                    }
                    else if('HD2'.equalsIgnoreCase(mapCode.get(0).Queue_Type__c)){
                        MT.CaseFieldToUpdate__c = 'Durata_lavorazione_uffici_tecnici__c';
                    }
                }
                
                if(String.isBlank(MT.CaseFieldToUpdate__c)){
                    MT.CaseFieldToUpdate__c = MT.Gruppo_di_lavoro__c.contains('HD1')? 'Time_With_Support__c':'Durata_lavorazione_uffici_tecnici__c';
                }
                
                MT.UserProfile__c = value;
            }
        }
        
        
        
        
        return MT;
    }
    
    private class OBJWrapper{
		List<Milestone_Tracking__c> MTToUpdate;
		List<Milestone_Tracking__c> MTToInsert;
        List<Working_Times__c> WTToUpdate;
		Set<Case> CaseToUpdate;
		
        public OBJWrapper(){
            MTToUpdate = new List<Milestone_Tracking__c>();
            MTToInsert = new List<Milestone_Tracking__c>();
            WTToUpdate = new List<Working_Times__c>();
            CaseToUpdate = new Set<Case>();
        }        
    }
    
    private class ParameterWrapper{
        Case caseNew;
        SObject caseOld;
        List<Milestone_Tracking__c> MilestoneTrackingList;
        
    }
    
    
}