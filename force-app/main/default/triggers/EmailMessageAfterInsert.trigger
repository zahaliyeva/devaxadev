trigger EmailMessageAfterInsert on EmailMessage (before insert, after insert) {
/* 
--------------------------------------------------------------------------------------
-- - Name          : EmailMessageAfterInsert
-- - Author        : Spoon Consulting 
-- - Description   : Trigger after insert on EmailMessage
--
-- Maintenance History: 
--
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  -------------------------------------------------------
-- 10-03-2015   HDU    1.0     Initial Version(AP07)                  
--------------------------------------------------------------------------------------
**********************************************************************

*/  
    //ZA BUGFIX
    system.debug('EmailMessageAfterInsert skipTrigger:'+EmailMessageSkipTriggerInvocable.skipTrigger);
    If(EmailMessageSkipTriggerInvocable.skipTrigger==null || !EmailMessageSkipTriggerInvocable.skipTrigger) {
    //OAVERSANO 03/07/2019 : Sito Impresa (validazione visura camerale) -- START
    String templateIDVisuraCamerale = '';
    String defaultBusinessHoursId = '';
    for(MPS_Code_Variables__c MPSCv: MPS_Code_Variables__c.getAll().values())
    {
        if((MPSCv.Name).equalsIgnoreCase('SitoImpresa_templateId')){
            if(String.isNotBlank(MPSCv.Value__c))
            {
                templateIDVisuraCamerale = MPSCv.Value__c;
            }
        }
        else if((MPSCv.Name).equalsIgnoreCase('BusinessHours_Default')){
            if(String.isNotBlank(MPSCv.Value__c))
            {
                defaultBusinessHoursId = MPSCv.Value__c; 
            }
        }
    }
    //OAVERSANO 03/07/2019 : Sito Impresa (validazione visura camerale) -- END
    //MDANTONIO 02/07/2019 Email to Case chiusi - start
    List<Case> relatedCasesList = new list<Case>();
    Map<Id,Case> relatedCaseListMap = new Map<Id,Case>();
    List<Id> caseIdList = new List<Id>();
    //MDANTONIO 10/07/2019 Email to Case chiusi fix incoming - start
    List<String> caseWithIncomingEmailMessageId = new List<Id>();
    //MDANTONIO 10/07/2019 Email to Case chiusi fix incoming - end
    //Giorgio Bonifazi - Descrizione Case Figlio -- START
    String NewDescription;
    //Giorgio Bonifazi - Descrizione Case Figlio -- END
    String caseKeyPrefix = AP_Constants.CaseKeyPrefix;
    Map<Id,EmailMessage> idEmailMessageMap = new Map<Id,EmailMessage>();
    for(integer iCase = 0;iCase<trigger.size;iCase++){
        if(String.ValueOf(trigger.new[iCase].parentId).startsWith(caseKeyPrefix)){
            caseIdList.add(trigger.new[iCase].parentId);
            //MDANTONIO 10/07/2019 Email to Case chiusi fix incoming - start
            if(trigger.new[iCase].incoming){
                caseWithIncomingEmailMessageId.add(trigger.new[iCase].parentId);
				idEmailMessageMap.put(trigger.new[iCase].parentId,trigger.new[iCase] );
            }
            //MDANTONIO 10/07/2019 Email to Case chiusi fix incoming - end
        }
    }

    if(Trigger.isBefore){
       
        //MDANTONIO 10/07/2019 Email to Case chiusi fix incoming - start
        //Giorgio Bonifazi - Gestione Case Chiusi START
        relatedCasesList =[Select id, Status, Origin, (SELECT id, Incoming, CreatedBy.Alias from EmailMessages Where incoming = true), IsClosed, LOB__c, Category__c, SubCategory__c, SubCategoryDetail__c, AccountId, Complainant__c, Distribution_Network__c, Casenumber, Requested_Documents__c, TECH_Sollecito_1_VC__c, TECH_Sollecito_2_VC__c, Oggetto_Apertura_Case__c, TECHThreadId__c, User__c, OwnerId, Automatic_Closure_Activation_DT__c,Priority,RecordTypeId,Description from Case where id in:caseWithIncomingEmailMessageId]; //OAVERSANO 08/04/2019 : AXA Assistance 

        relatedCaseListMap = new Map<Id,Case>([Select id, Status, Origin, (SELECT id, Incoming, CreatedBy.Alias from EmailMessages Where incoming = false), IsClosed, LOB__c, Category__c, SubCategory__c, SubCategoryDetail__c, AccountId, Complainant__c, Distribution_Network__c, Casenumber, Requested_Documents__c, TECH_Sollecito_1_VC__c, TECH_Sollecito_2_VC__c, Oggetto_Apertura_Case__c, TECHThreadId__c, User__c, OwnerId, Automatic_Closure_Activation_DT__c,Priority,RecordTypeId,Description from Case where id in:caseWithIncomingEmailMessageId]);
        //Giorgio Bonifazi - Gestione Case Chiusi END
        System.debug('===> RelatedCasesList for incoming email messages: ' + relatedCasesList);
        //MDANTONIO 10/07/2019 Email to Case chiusi fix incoming - end
        List<Case> caseToInsert = new List<Case>();
        Map<Id, Case> mapOldNewCase = new Map<Id,Case>();
        AssignmentRule AR = new AssignmentRule();
        AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;

        for(Case c : relatedCasesList ){
            if(c.isClosed && (c.EmailMessages.size() > 0 || ( c.EmailMessages.size() == 0 && relatedCaseListMap.get(c.Id).EmailMessages.size() > 0))){
                //Giorgio Bonifazi - Descrizione Case Figlio -- START
                if((idEmailMessageMap.get(c.Id).textBody + c.Description).length() <= 32000){
                NewDescription = idEmailMessageMap.get(c.Id).textBody + '\n' + '--------------'+'\n'+'Descrizione del case padre:'+'\n'+ c.Description;}
                else{ NewDescription = (idEmailMessageMap.get(c.Id).textBody + '\n' + '--------------'+'\n'+'Descrizione del case padre:'+'\n'+ c.Description).substring(0,32000);}
                //Giorgio Bonifazi - Descrizione Case Figlio -- END

                Case relatedCase = new Case(RecordTypeId = c.RecordTypeId, 
                            Category__c = c.Category__c, 
                            SubCategory__c = c.SubCategory__c,
                            SubCategoryDetail__c = c.SubCategoryDetail__c, 
                            LOB__c = c.LOB__c, 
                            AccountId = c.AccountId,
                            Complainant__c = c.Complainant__c, 
                            Origin = c.Origin, 
                            ParentId = c.Id, 
                            Distribution_Network__c = c.Distribution_Network__c,
                            //Giorgio Bonifazi - Gestione Case Chiusi START
                            Oggetto_Apertura_Case__c = c.Oggetto_Apertura_Case__c,

                            Description = NewDescription,
                            SuppliedEmail = idEmailMessageMap.get(c.Id).FromAddress
                             );
                            //Giorgio Bonifazi - Gestione Case Chiusi END
                relatedCase.setOptions(dmlOpts);
                mapOldNewCase.put(c.Id, relatedCase);
                caseToInsert.add(relatedCase);
            }
        }
        Database.SaveResult[] sr = Database.insert(caseToInsert);
        for(integer i = 0;i<trigger.size;i++){
            if(String.ValueOf(trigger.new[i].parentId).startsWith(caseKeyPrefix)
                    && mapOldNewCase.keySet().contains(trigger.new[i].parentId)){
                System.debug('===> newCase.Id: ' + mapOldNewCase.get(trigger.new[i].parentId).Id);
                Case newCase = mapOldNewCase.get(trigger.new[i].parentId);
                trigger.new[i].parentId = newCase.Id;
                String orgId = String.valueOf(UserInfo.getOrganizationId()).substring(0, 15);
                String newCaseId = String.valueOf(newCase.Id).substring(0, 15);
                String threadId = 'ref:_' + orgId.substring(0,5) + orgId.substring(orgId.length()-10, orgId.length()).replace('0', '') + '._' + newCaseId.substring(0,5) + newCaseId.substring(newCaseId.length()-10, newCaseId.length()).replace('0', '').substring(0,5) + ':ref';
                System.debug('===> threadId ' + threadId);
                trigger.new[i].Subject = threadId;
                System.debug('===> trigger.new[i] ' + trigger.new[i]);
            }
        }
    }
    if(Trigger.isAfter){
        //MDANTONIO 10/07/2019 Email to Case chiusi fix incoming - start
        //Giorgio Bonifazi - Gestione Case Chiusi START
        relatedCasesList =[Select id, Status, IsClosed, LOB__c, Category__c,TECH_notAAI__c, SubCategory__c, SubCategoryDetail__c, AccountId, Distribution_Network__c, Casenumber, Requested_Documents__c, TECH_Sollecito_1_VC__c, TECH_Sollecito_2_VC__c, Oggetto_Apertura_Case__c, TECHThreadId__c, User__c, OwnerId, Automatic_Closure_Activation_DT__c,Priority,RecordTypeId,Description,(Select id, status,HierarchyLevel1__c from Tasks where status =: AP_Constants.taskStatusPending), (SELECT id, Incoming, CreatedBy.Alias from EmailMessages) from Case where id in:caseIdList]; //OAVERSANO 08/04/2019 : AXA Assistance
        //Giorgio Bonifazi - Gestione Case Chiusi END 
        System.debug('===> RelatedCasesList: ' + relatedCasesList);
        Set<Id> closedCasesIdList = new Set<Id>();
        for(Case c : relatedCasesList){
            if(c.isClosed){
                closedCasesIdList.add(c.Id);
            }
        }
        //MDANTONIO 10/07/2019 Email to Case chiusi fix incoming - end
    //MDANTONIO 02/07/2019 Email to Case chiusi - end
        System.Debug('## >>> Start of EmailMessageAfterInsert <<< run by ' + UserInfo.getName());
        //variable  
        //CAPOBIANCO_A 30/03/2017 BUGFIX --- START
        //set<Id> AP07setCasesId = new set<Id>(); 
        Map <Id,String> AP07mapCasesIdToAddress = new map <Id,String>();
        Map <Id,String> AP07mapCasesIdToAddressDac = new map <Id,String>();
        //CAPOBIANCO_A 30/03/2017 BUGFIX --- END

        List<Case> listCaseToUpdate = new List<Case>(); //CAPOBIANCO_A 13/06/2017 BUGFIX UPDATE NEL FOR
        
        //MOSCATELLI_M 28/10/2016: Evo71-ConnectedHome -- START
        Set<String> AP13InboundEmail = new set<String>();
        Set<String> AP13OutboundEmail = new set<String>();
        //MOSCATELLI_M 28/10/2016: Evo71-ConnectedHome -- END
        
        //MOSCATELLI_M 14032016: EVO50-----START
        //MDANTONIO 02/07/2019 Email to Case chiusi - start
        //String caseKeyPrefix = AP_Constants.CaseKeyPrefix;
        
        //List<Id> CaseIdList = new List<Id>();
        //List<Case> RelatedCasesList = new list<Case>();
        //MDANTONIO 02/07/2019 Email to Case chiusi - end
        
        List<Task> TaskToUpdate = new list <Task>();//RANIELLO_V 27042016: EVO-52

        //MOSCATELLI_M 07/09/2018: Modello assistenza -- START
        Map<String, Schema.RecordTypeInfo> MapCaseRecordType = new Map<String, Schema.RecordTypeInfo> ();
        Map<String, Schema.RecordTypeInfo> MapStoricoRecordType = new Map<String, Schema.RecordTypeInfo> ();
        List<Storico_conversazioni__c> SCList = new List <Storico_conversazioni__c>();
        List<Case> NotifyHD2Case = new List<Case>();

        String[] types = new String[]{'Case'}; 
        List<Schema.DescribeSobjectResult> results = Schema.describeSObjects(types); 

        for (Schema.RecordTypeInfo ri: results[0].getRecordTypeInfos()) 
        { 
            MapCaseRecordType.put(ri.getRecordTypeId(), ri);
        } 

        String[] types2 = new String[]{'Storico_conversazioni__c'}; 
        List<Schema.DescribeSobjectResult> results1 = Schema.describeSObjects(types2); 

        for (Schema.RecordTypeInfo ri: results1[0].getRecordTypeInfos()) 
        { 
            MapStoricoRecordType.put(ri.getDeveloperName(),ri);
        }         
        //MOSCATELLI_M 07/09/2018: Modello assistenza -- END
        
        for(integer iCase = 0;iCase<trigger.size;iCase++)
        {
            //MOSCATELLI_M 28/10/2016: Evo71-ConnectedHome -- START
            if(String.ValueOf(trigger.new[iCase].parentId).startsWith(caseKeyPrefix))
            {            
                //MDANTONIO 02/07/2019 Email to Case chiusi - start
                //CaseIdList.add(trigger.new[iCase].parentId);
                //MDANTONIO 02/07/2019 Email to Case chiusi - end

                system.debug('##initial query: '+Limits.getQueries());
                
                system.debug('#ExtPartConf: '+ExternalPartnersInvolvement__c.getAll().values());
                
                for(ExternalPartnersInvolvement__c ExtPartConf: ExternalPartnersInvolvement__c.getAll().values())
                {
                    system.debug('##ex: '+ExtPartConf.Email__c);
                    
                    //OAVERSANO 25/02/2019 : FIX Apertura automatica Task -- START
                    //if(ExtPartConf.Email__c == trigger.new[iCase].ToAddress || ExtPartConf.Email_AAI__c == trigger.new[iCase].ToAddress || ExtPartConf.Email_Quadra__c == trigger.new[iCase].ToAddress)
                    if(String.isNotBlank(trigger.new[iCase].ToAddress) && (ExtPartConf.Email__c == trigger.new[iCase].ToAddress || ExtPartConf.Email_AAI__c == trigger.new[iCase].ToAddress || ExtPartConf.Email_Quadra__c == trigger.new[iCase].ToAddress))
                    {
                        AP13OutboundEmail.add(ExtPartConf.Name+'|'+system.now()+'|'+trigger.new[iCase].parentId);
                    }
                    //else if(ExtPartConf.Email__c == trigger.new[iCase].FromAddress || ExtPartConf.Email_AAI__c == trigger.new[iCase].FromAddress || ExtPartConf.Email_Quadra__c == trigger.new[iCase].FromAddress)
                    else if(String.isNotBlank(trigger.new[iCase].FromAddress) && (ExtPartConf.Email__c == trigger.new[iCase].FromAddress || ExtPartConf.Email_AAI__c == trigger.new[iCase].FromAddress || ExtPartConf.Email_Quadra__c == trigger.new[iCase].FromAddress))
                    {
                        AP13InboundEmail.add(ExtPartConf.Name+'|'+system.now()+'|'+trigger.new[iCase].parentId);   
                    }
                    //OAVERSANO 25/02/2019 : FIX Apertura automatica Task -- END
                }
                
                system.debug('##final query: '+Limits.getQueries());
                system.debug('## '+trigger.new[iCase].ToAddress+' '+trigger.new[iCase].FromAddress+' '+AP13OutboundEmail+' '+AP13InboundEmail);
            }
            //MOSCATELLI_M 28/10/2016: Evo71-ConnectedHome -- END
        }  
        
        //MDANTONIO 02/07/2019 Email to Case chiusi - start
        //RelatedCasesList =[Select id, Status, Casenumber, Oggetto_Apertura_Case__c, TECHThreadId__c, User__c, OwnerId,Automatic_Closure_Activation_DT__c,RecordTypeId,(Select id, status,HierarchyLevel1__c from Tasks where status =: AP_Constants.taskStatusPending) from Case where id in:CaseIdList]; //RANIELLO_V 27042016: EVO-52
        //MDANTONIO 02/07/2019 Email to Case chiusi - end

        //OAVERSANO 08/04/2019 : AXA Assistance -- START
        Boolean fireTrigger = false;
        for(Case cas:RelatedCasesList)
        {
            if((MapCaseRecordType.get(cas.RecordTypeId).getDeveloperName() == Ap_Constants.rtCaseSinistro))
            {
                if(cas.EmailMessages.size() == 1)
                {
                    if(cas.EmailMessages[0].Incoming && cas.EmailMessages[0].CreatedBy.Alias == 'utte')
                        fireTrigger = true;
                }
            }
        }
        
        
        
        Map <Id,Case> RelatedCasesMap = new map<Id,Case>(RelatedCasesList);
        Map <Id,Case> dacCasesMap = new map<Id,Case>();   
        //MOSCATELLI_M 14032016: EVO50-----END


        for (Integer i=0;i < trigger.size ;i++){
            /*if(PAD.canTrigger('AP07')){
                if(trigger.new[i].parentId != null && trigger.new[i].Incoming){
                    //CAPOBIANCO_A 30/03/2017 BUGFIX --- START
                    //AP07setCasesId.add(trigger.new[i].parentId);
                    AP07mapCasesIdToAddress.put(trigger.new[i].parentId,trigger.new[i].ToAddress);
                    //CAPOBIANCO_A 30/03/2017 BUGFIX --- END
                }//end of check 
            }//end of check Bypass*/
            
            //MOSCATELLI_M 14032016: EVO50-----START
            if(String.ValueOf(trigger.new[i].parentId).startsWith(caseKeyPrefix))
            {
                //MDANTONIO 02/07/2019 Email to Case chiusi - start
                //if(trigger.new[i].Incoming && RelatedCasesMap.containsKey(trigger.new[i].parentId))
                if(trigger.new[i].Incoming && RelatedCasesMap.containsKey(trigger.new[i].parentId) 
                    && !closedCasesIdList.contains(RelatedCasesMap.get(trigger.new[i].parentId).Id))
                //MDANTONIO 02/07/2019 Email to Case chiusi - end
                {
                    Case Relatedcase = RelatedCasesMap.get(trigger.new[i].parentId);

                    System.debug(' ==> case: ' + Relatedcase);
                    if(!Test.isRunningTest())
                        if(Relatedcase.TECH_notAAI__c){
                            RelatedCase.TECH_InvioNotificaMailCase__c = AP_Constants.TemplateInvioNotificaMPS;
                        }

                    if(RelatedCasesMap.get(trigger.new[i].parentId).Priority == 'DAC AXA Agenti' && (MapCaseRecordType.get(RelatedCasesMap.get(trigger.new[i].parentId).RecordTypeId).getDeveloperName() == Ap_Constants.rtCaseDACAgenti)){
                        dacCasesMap.put(Relatedcase.Id, Relatedcase);
                        AP07mapCasesIdToAddressDac.put(trigger.new[i].parentId,trigger.new[i].FromAddress);
                    }

                    if(PAD.canTrigger('AP07') && (MapCaseRecordType.get(RelatedCasesMap.get(trigger.new[i].parentId).RecordTypeId).getDeveloperName() <> Ap_Constants.rtCaseAssistenzaAgenti))
                    {
                        AP07mapCasesIdToAddress.put(trigger.new[i].parentId,trigger.new[i].ToAddress);
                    }
                    
                    //RANIELLO_V 27042016: EVO-52-----START             
                    List<Task> NotClosedTasks = new List<Task>(RelatedCase.Tasks);              
                    
                    if(Relatedcase.Status == AP_Constants.caseStatusPending && !NotClosedTasks.isEmpty()) //if(!NotClosedTasks.isEmpty()) -- CAPOBIANCO_A 14/06/2017 EVO 85
                    {
                        for (integer itask=0; itask<NotClosedTasks.size(); itask++)
                        {
                            if(NotClosedTasks[itask].HierarchyLevel1__c!='')
                            {
                                Task Attivita = new Task(id=NotClosedTasks[itask].Id,Status= AP_Constants.taskStatusInformationReceived);
                                TaskToUpdate.add(Attivita);
                            }
                        }                    
                    }
                    //RANIELLO_V 27042016: EVO-52-----END
                 
                    if(Relatedcase.Status == AP_Constants.caseStatusPending)
                    {
                        Relatedcase.Status = AP_Constants.caseStatusInformationReceived;
                        //OAVERSANO 03/07/2019 : Sito Impresa (validazione visura camerale) -- START
                        if(Relatedcase.Requested_Documents__c == true)
                        {
                            Relatedcase.Requested_Documents__c = false;
                        }
                        if(RelatedCase.TECH_Sollecito_1_VC__c!=null)
                            RelatedCase.TECH_Sollecito_1_VC__c = null;
                        if(RelatedCase.TECH_Sollecito_2_VC__c!=null)
                            RelatedCase.TECH_Sollecito_2_VC__c = null;
                        //OAVERSANO 03/07/2019 : Sito Impresa (validazione visura camerale) -- END
                    }
                    //CAPOBIANCO_A 13/06/2017 EVO 85 -- START
                    else if(Relatedcase.Status == AP_Constants.caseStatusVerificaAttAntiRic || Relatedcase.Status == 'Inviata raccomandata QADV')
                    {
                        Relatedcase.Status = AP_Constants.caseStatusInfoAntiRicReceived;
                    }
                    //CAPOBIANCO_A 13/06/2017 EVO 85 -- END

                       //update Relatedcase;
                    
                    //MOSCATELLI_M 07/09/2018: Modello assistenza -- START
                  /*  else if(Relatedcase.Status == Ap_Constants.caseStatusGestioneHD3 && (MapCaseRecordType.get(RelatedCasesMap.get(trigger.new[i].parentId).RecordTypeId).getDeveloperName() == Ap_Constants.rtCaseAssistenzaAgenti))
                    {
                        Relatedcase.Status = Ap_Constants.caseStatusGestioneSpecialistica;
                        Storico_conversazioni__c sc = new Storico_conversazioni__c (Recordtypeid = MapStoricoRecordType.get('Supporto').getRecordTypeId(),Description__c = trigger.new[i].Subject, Connected_case__c = trigger.new[i].parentId, CaseStatus__c = RelatedCasesMap.get(trigger.new[i].parentId).Status, Type__c = 'Email di risposta da HD3' );
                        SCList.add(sc);
                        NotifyHD2Case.add(Relatedcase);                                              
                    }*/
                    //MOSCATELLI_M 07/09/2018: Modello assistenza -- END

                    listCaseToUpdate.add(Relatedcase); //CAPOBIANCO_A 13/06/2017 BUGFIX UPDATE NEL FOR
                }
                //OAVERSANO 03/07/2019 : Sito Impresa (validazione visura camerale) -- START
                else if(!trigger.new[i].Incoming && RelatedCasesMap.containsKey(trigger.new[i].parentId) && !closedCasesIdList.contains(RelatedCasesMap.get(trigger.new[i].parentId).Id))
                {
                    Case Relatedcase = RelatedCasesMap.get(trigger.new[i].parentId);
                    system.debug('@@trigger.new[i].HtmlBody@@@: '+trigger.new[i].HtmlBody);
                    if(String.isNotBlank(trigger.new[i].HtmlBody) && trigger.new[i].HtmlBody.contains(templateIDVisuraCamerale))
                    {
                        Relatedcase.Status = AP_Constants.caseStatusPending;
                        Relatedcase.Requested_Documents__c = true;
                        Relatedcase = ServiceUtilsClass.setSitoImpresaAlertsAndClosure(Relatedcase, defaultBusinessHoursId);
                        listCaseToUpdate.add(Relatedcase);
                    }
                }
                //OAVERSANO 03/07/2019 : Sito Impresa (validazione visura camerale) -- END
                //MOSCATELLI_M 07/09/2018: Modello assistenza -- START
                /*else if(!trigger.new[i].Incoming && RelatedCasesMap.containsKey(trigger.new[i].parentId))
                {
                    Case Relatedcase = RelatedCasesMap.get(trigger.new[i].parentId);
                    
                    if(Relatedcase.Status == Ap_Constants.caseStatusGestioneSpecialistica && (MapCaseRecordType.get(RelatedCasesMap.get(trigger.new[i].parentId).RecordTypeId).getDeveloperName() == Ap_Constants.rtCaseAssistenzaAgenti))
                    {
                        Relatedcase.Status = Ap_Constants.caseStatusGestioneHD3;
                        Storico_conversazioni__c sc = new Storico_conversazioni__c (Recordtypeid = MapStoricoRecordType.get('Supporto').getRecordTypeId(),Description__c = trigger.new[i].Subject, Connected_case__c = trigger.new[i].parentId, CaseStatus__c = RelatedCasesMap.get(trigger.new[i].parentId).Status, Type__c = 'Email per richiesta info ad HD3' );
                        SCList.add(sc);
                        listCaseToUpdate.add(Relatedcase);                                               
                    }

                }*/
                //MOSCATELLI_M 07/09/2018: Modello assistenza -- END
            }
            //MOSCATELLI_M 14032016: EVO50-----END
            
        }//end of loop trigger

        System.Debug('## >>> AP07mapCasesIdToAddressDac ' + AP07mapCasesIdToAddressDac);
        Map<Id, Case> dacCase = new Map<Id, Case>();
        if(AP07mapCasesIdToAddressDac.size()>0)
        {
            dacCase = AP07CaseEmailAlert.checkSenderDACAndNotifyEmailAlert(AP07mapCasesIdToAddressDac, dacCasesMap);    
        }
        
        List<Case> filteredCases = new List<Case>();
        for(Case c : listCaseToUpdate){
            if(dacCase.keyset().contains(c.Id)){
                filteredCases.add(dacCase.get(c.Id));
            } else {
                filteredCases.add(c);
            }
        }
        //RANIELLO_V 27042016: EVO-52 -- START
        system.debug('TaskToUpdate :'+TaskToUpdate);
        if(AP07mapCasesIdToAddressDac.size()>0)
        {
            CaseHandler.AfterUpdateNotDone = false;
            ModelloDiAssistenzaUtils.runModelloDiAssistenza = false;
            CaseHandler.AfterUpdateNotDone = false;
            SinistriUtils.runSinistriUtils = false;
            SinistriUtils.runProcessTeamAndMilestone = false;
        }
        update TaskToUpdate;
        //RANIELLO_V 27042016: EVO-52 -- END
        //update listCaseToUpdate; //CAPOBIANCO_A 13/06/2017 BUGFIX UPDATE NEL FOR
        if(AP07mapCasesIdToAddressDac.size()>0)
        {
            CaseHandler.AfterUpdateNotDone = true;
            ModelloDiAssistenzaUtils.runModelloDiAssistenza = true;
        }
        //OAVERSANO 08/04/2019 : AXA Assistance -- START
        if(fireTrigger)
        {
            CaseHandler.AfterUpdateNotDone = true;
            SinistriUtils.runSinistriUtils = true;
            SinistriUtils.runProcessTeamAndMilestone = true;
        }
        //OAVERSANO 08/04/2019 : AXA Assistance -- END
        update filteredCases; //CAPOBIANCO_A 13/06/2017 BUGFIX UPDATE NEL FOR
        //MOSCATELLI_M 07/09/2018: Modello assistenza -- START
        if(SCList.size()>0)
            insert SCList;

        if(NotifyHD2Case.size()>0)
            AP07CaseEmailAlert.notifyhd2(NotifyHD2Case);
        //MOSCATELLI_M 07/09/2018: Modello assistenza -- END
        
        //CAPOBIANCO_A 30/03/2017 BUGFIX --- START
        /*System.Debug('## >>> AP07setCasesId ' + AP07setCasesId);
        if(PAD.canTrigger('AP07') && AP07setCasesId.size()>0)
        {
            AP07CaseEmailAlert.notifyEmailAlert(AP07setCasesId);    
        }*/
        System.Debug('## >>> AP07mapCasesIdToAddress ' + AP07mapCasesIdToAddress);
        if(PAD.canTrigger('AP07') && AP07mapCasesIdToAddress.size()>0)
        {
            AP07CaseEmailAlert.notifyEmailAlert(AP07mapCasesIdToAddress);    
        }
        //CAPOBIANCO_A 30/03/2017 BUGFIX --- END
        //MOSCATELLI_M 28/10/2016: Evo71-ConnectedHome -- START
        if(AP13InboundEmail.size()>0 || AP13OutboundEmail.size()>0)
          AP13_TaskAutomaticOpening.ExternalPartnerTracingTask(AP13InboundEmail,AP13OutboundEmail);
        //MOSCATELLI_M 28/10/2016: Evo71-ConnectedHome -- END
            
    }
}
}//end of trigger