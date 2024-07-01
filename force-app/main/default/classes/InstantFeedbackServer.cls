public with sharing class InstantFeedbackServer {
    
    public string apexCaseId{get;set;}
    public string apexOrigin{get;set;}
    public string apexRecordType{get;set;}
    public string theme{get;set;}
    
    public InstantFeedbackServer(ApexPages.StandardController stdController)
    {
        theme = UserInfo.getUiThemeDisplayed();
    
        if(String.isNotBlank(ApexPages.currentPage().getParameters().get('attachedRecords')))
        {
            //system.debug('##attachedRecords: '+ApexPages.currentPage().getParameters().get('attachedRecords'));
            Map<String, Object> MapPageAttachedRecords = (Map<String, Object>)JSON.deserializeUntyped(ApexPages.currentPage().getParameters().get('attachedRecords'));
            apexCaseId = (String)MapPageAttachedRecords.get('CaseId');     
            apexOrigin = AP_Constants.rtFeedbackFromChat;
            apexRecordType = AP_Constants.rtChatSurveyFeedback;        
        }
        else
        {
            apexCaseId     = ApexPages.currentPage().getParameters().get('id');
            apexOrigin     = ApexPages.currentPage().getParameters().get('origin');
            apexRecordType = ApexPages.currentPage().getParameters().get('recordType');            
        }         
    }


    public class checkResults
    {
        @AuraEnabled public Boolean showError;
        @AuraEnabled public String ErrorMsg;
        @AuraEnabled public String OrgUrl;
        public checkResults()
        {
            this.showError=false;
            this.ErrorMsg='';
            this.OrgUrl='';
        }
    }
    
    @AuraEnabled
    public static Feedback_Configuration__c getFeedbackConfiguration(String caseOrigin, String caseId)
    {

        Case c = [SELECT RecordType.Name,Complainant__c From Case Where Id =: caseId ]; // NOPMD  Fix CRUD violation
        String caseRecordType = c.RecordType.Name;
        String Richiedente = c.Complainant__c;


       String AllValues = 'All';
        Map<String,Feedback_Configuration__c>FeedbckConfMap=new Map<String,Feedback_Configuration__c>();
        Feedback_Configuration__c fc = new Feedback_Configuration__c();

        for(Feedback_Configuration__c fcm:[SELECT Id,Case_Record_Type__c,Complainant__c,Question_1__c,Question_2__c,Welcome_Message__c,Case_Origin__c,Error_Message__c FROM Feedback_Configuration__c  WHERE Rule_Active__c = true ]) // NOPMD  Fix CRUD violation
        {
           FeedbckConfMap.put(fcm.Case_Record_Type__c+'|'+fcm.Complainant__c+'|'+fcm.Case_Origin__c,fcm);    
        }
		
        system.debug('FeedbckConfMap: '+FeedbckConfMap);
        system.debug('caseRecordType: '+caseRecordType);
        system.debug('Richiedente: '+Richiedente);
        system.debug('caseOrigin: '+caseOrigin);

        if(FeedbckConfMap.containsKey(caseRecordType+'|'+Richiedente+'|'+caseOrigin))
            fc = FeedbckConfMap.get(caseRecordType+'|'+Richiedente+'|'+caseOrigin);                           
        else if(FeedbckConfMap.containsKey(caseRecordType+'|'+AllValues+'|'+caseOrigin))
            fc = FeedbckConfMap.get(caseRecordType+'|'+AllValues+'|'+caseOrigin);             
        
        else if(FeedbckConfMap.containsKey(AllValues+'|'+Richiedente+'|'+caseOrigin))
            fc = FeedbckConfMap.get(AllValues+'|'+Richiedente+'|'+caseOrigin);
        else
            fc = FeedbckConfMap.get(AllValues+'|'+AllValues+'|'+caseOrigin);                 
  
        //Feedback_Configuration__c fc = [SELECT Welcome_Message__c, Question_1__c, Question_2__c FROM Feedback_Configuration__c WHERE Case_Origin__c =: caseOrigin AND Case_Record_Type__c =: caseRecordType];
        return fc;
    }
    
    @AuraEnabled
    //public static boolean checkError(String cCase)
    public static checkResults checkError(String cCase,String SurveyOrigin)
    {
       // String Status = [SELECT Status FROM Case WHERE Id =: cCase].Status;
       // String Origin = [SELECT Origin FROM Case WHERE Id =: cCase].Origin;
       	//OAVERSANO 11/12/2018 : Enhancement NMA Biz -- START
        //Case c = [Select Origin,Status,isClosed,OwnerId,Supporto_HD2_Biz__c from Case where id=: cCase limit 1];
		Case c = [Select Origin,Status,isClosed,OwnerId, ProfileNameOwner__c, QueueNameOwner__c, RoleNameOwner__c from Case where id=: cCase limit 1];
		//OAVERSANO 11/12/2018 : Enhancement NMA Biz -- END
        String Status = c.Status;
        String Origin = c.Origin;
        String url = '';
   
        checkResults cr = new checkResults();

        if(Network.communitiesLanding() <> null) {
            url = ((Network.communitiesLanding()).geturl()).replace('home/home.jsp','');
        } else {
            String PartnerUrl = [Select BaseURL__c from User where id=:UserInfo.getUserId() limit 1].BaseURL__c;
            url = (PartnerUrl.replace('--c.','.')).replace('visual.force','my.salesforce');
        }

        cr.OrgUrl = url;


        if(c.isClosed || Status.equalsIgnoreCase('Chiuso d\'ufficio') || Status.equalsIgnoreCase('Closed') || Status.equalsIgnoreCase('Chiuso in autonomia'))
        {
            cr.showError=true;
            cr.ErrorMsg='La funzionalità non è disponibile in quanto la richiesta è stata già evasa.';
            return cr; 
        }
        else if(!Status.equalsIgnoreCase('Soluzione proposta') && SurveyOrigin<>AP_Constants.rtFeedbackFromChat)
        {
            cr.showError=true;
            cr.ErrorMsg='La funzionalità non è disponibile non essendo stata ancora proposta alcuna soluzione da parte del Supporto.';
            return cr;             
        }
        else if(SurveyOrigin<>AP_Constants.rtFeedbackFromChat)
        {
            //OAVERSANO 11/10/2018 : Modello di Assistenza -- START
            List<bypass__c> skipValidations = [select Id, Name, SetupOwnerId, SetupOwner.Name, BypassTrigger__c, BypassValidationRules__c, BypassWorkflows__c from Bypass__c ]; // NOPMD  Fix CRUD violation
            system.debug('skipValidations: '+skipValidations);
            bypass__c skipValidation;
            for(bypass__c bp : skipvalidations)
            {
                if(bp.SetupOwnerId == UserInfo.getProfileId())
                    skipValidation = bp;
            }
            if(skipValidation != null) 
            {
                skipValidation.BypassValidationRules__c= true;
                upsert skipValidation; // NOPMD  Fix CRUD violation
            }

            //OAVERSANO 11/10/2018 : Modello di Assistenza -- END
            Case ca = new Case(id=cCase,Status = 'Risolto',OwnerId=c.OwnerId);

            //MOSCATELLI_M 25/10/2018: NMA Business -- START
            String CaseOwner = '';
			
			//OAVERSANO 11/12/2018 : Enhancement NMA Biz -- START
            /*if(c.Supporto_HD2_Biz__c)
            {
                runQueryWOS queryRunner = new runQueryWOS();
                User CasOwn = queryRunner.getUser(ca);
                CaseOwner = CasOwn.Profile.Name;

                if(CaseOwner.indexOf('HD2')<>-1)
                {
                    ca.Supporto_HD2_Biz__c = false;
                    ca.Risolto_da_HD2_Biz__c = true;
                }
            }*/
            //OAVERSANO 11/12/2018 : Enhancement NMA Biz -- END
            //MOSCATELLI_M 25/10/2018: NMA Business -- END 

            //OAVERSANO 20/09/2018 : Nuovo Modello di Assistenza -- START
            Boolean isSuccessUpdate = false;
            
            try
            {
                isSuccessUpdate = true;
                update ca;
                //OAVERSANO 11/10/2018 : Modello di Assistenza -- START
                if (skipValidation!=null)
                {
                    skipValidation.BypassValidationRules__c= false;
                    
                    update skipValidation; // NOPMD  Fix CRUD violation
                }
                //OAVERSANO 11/10/2018 : Modello di Assistenza -- END
                Id idProfile       = UserInfo.getProfileId();
                String profileName = [Select Name from Profile WHERE Id =: idProfile LIMIT 1].Name;
                String userRole    = '-';

                if(profileName.contains('Vendite'))
                    profileName = 'Agente';
                
                String categ = '';
                
                String rTId2 = [SELECT Id FROM RecordType WHERE DeveloperName = 'Agente'].Id;

                //MDANTONIO 02/04/2019 : storicizzazione valore “Preso in carico” - start
                //Storico_conversazioni__c sc = new Storico_conversazioni__c ( Connected_case__c = cCase, CaseStatus__c = c.Status, Type__c = 'Risoluzione ticket confermata', RecordTypeId = rTId2, Profilo_utente__c = profileName, Ruolo_utente__c = userRole );
                String caseStatus = c.Status.equals(AP_Constants.caseStatusAssigned) ? 'Preso in carico' : c.Status;
                //MDANTONIO 05/04/2019 : destinatario commento - start
                String ownerProfileOrQueue = String.valueOf(c.OwnerId).startsWith('00G') ? c.QueueNameOwner__c : c.ProfileNameOwner__c;
                System.debug('===> ownerProfileOrQueue: ' + ownerProfileOrQueue);
                String destinatario = ModelloDiAssistenzaUtils.getDestinatario(ownerProfileOrQueue, c.RoleNameOwner__c, c.OwnerId);
                //MDANTONIO 05/04/2019 : destinatario commento - start
                Storico_conversazioni__c sc = new Storico_conversazioni__c ( Connected_case__c = cCase, CaseStatus__c = caseStatus, Type__c = 'Risoluzione ticket confermata', RecordTypeId = rTId2, Profilo_utente__c = profileName, Ruolo_utente__c = userRole, Destinatario_Commento__c = destinatario);
                //MDANTONIO 02/04/2019 : storicizzazione valore “Preso in carico” - end
                
                insert sc; // NOPMD  Fix CRUD violation
                
               
            }
            catch(exception ex)
            {
                isSuccessUpdate = false;
                cr.showError=true;
                cr.ErrorMsg='La funzionalità non è disponibile. Contattare l\'amministratore di sistema '+ex.getMessage();
                return cr;                  
            }
            
            try
            {
                //MDANTONIO 03/04/2019 - sospensione inoltro email per accettazione soluzione - start
                boolean sendIt = MPS_Code_Variables__c.getValues('SendEmailForAcceptedSolution').Value__c == 'TRUE';
                System.debug('===> sendIt: ' + sendIt);
                //MDANTONIO 03/04/2019 - sospensione inoltro email per accettazione soluzione - end
                if(sendIt && isSuccessUpdate)
                {
        
                    /*ca.Status = 'Risolto';
                    update ca;*/
                    Case cs = [SELECT id, OwnerId, CaseNumber, Status, Owner.Name FROM CASE WHERE Id =:ca.id ];
                    runQueryWOS queryRunner = new runQueryWOS();
                    User u = queryRunner.getUser(cs);
                    
                    //User u = [SELECT Name FROM User WHERE Id =: ca.OwnerId];
                    
                    Modello_di_Assistenza__mdt mdAss = [SELECT Id, Email_Template__c // NOPMD  Fix CRUD violation
                                                        FROM Modello_di_Assistenza__mdt 
                                                        WHERE DeveloperName  = 'Template_Conferma_Soluzione' 
                                                        LIMIT 1];
                    
                    //System.debug(' ===> mdAss: ' + mdAss);
                    
                    String emTemplate = mdAss.Email_Template__c;
                    
                    EmailTemplate etem = [SELECT Markup, Subject, HtmlValue, body // NOPMD  Fix CRUD violation
                                          FROM EmailTemplate 
                                          WHERE DeveloperName =: emTemplate  LIMIT 1];   
                    List<Messaging.SingleEmailMessage> listEmail = new List<Messaging.SingleEmailMessage>();
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    String htmlBody = etem.HtmlValue;
                    //System.debug('htmlBody pre: ' + htmlBody);
                    String subject = etem.Subject;
                    String body    = etem.body;
                    subject  = subject.replace('{!Case.CaseNumber}', cs.CaseNumber);
                    subject  = subject.replace('{!Case.Status}', cs.Status);
                    htmlBody = htmlBody.replace('{!Case.User__c}', cs.Owner.Name);      
                    body     = body.replace('{!Case.User__c}', cs.Owner.Name);
                    
                    htmlBody = htmlBody.replace('{!Case.CaseNumber}', cs.CaseNumber);    
                    body     = body.replace('{!Case.CaseNumber}', cs.CaseNumber);
                    String urlEmail = [SELECT OrgLink__c 
                                       FROM Modello_di_Assistenza__mdt 
                                       WHERE DeveloperName = 'Redirect'
                                       LIMIT 1].OrgLink__c;
                    htmlBody = htmlBody.replace('{!Case.Link}', urlEmail + cCase);    
                    body     = body.replace('{!Case.Link}', urlEmail + cCase);
                    //System.debug('htmlBody: ' + htmlBody); 
                    email.setHtmlBody(htmlBody);
                    email.setSubject(subject);
                    email.setTargetObjectId(cs.OwnerId);
                    email.saveAsActivity = false;
                    listEmail.add(email);
                    Messaging.SendEmailResult [] results = queryRunner.sendEmail(listEmail);
                    //Messaging.SendEmailResult [] results = Messaging.sendEmail(listEmail);
                    
                    if (results[0].success) 
                    {
                        System.debug('The email was sent successfully.');
                    } 
                    else 
                    {
                        System.debug('The email failed to send: ' + results[0].errors[0].message);
                    }                    
                }
            }
            catch(exception ex)
            {
                system.debug('The email failed to send in catch: '+ex.getMessage());                   
            }
            //OAVERSANO 20/09/2018 : Nuovo Modello di Assistenza -- END
        }

/*
        if (!Status.equalsIgnoreCase('Soluzione proposta') && !Origin.equalsIgnoreCase('Chat')) 
        {
            return true;      
        }
        return false;*/
        return cr;
    }
    
    //OAVERSANO 16/10/2018 : Fix Instant Feedback -- START
    @AuraEnabled
    public static checkResults checkEmailFeedbackCTRL(String cCase)
    {
        checkResults cr = new checkResults();
        List<Feedback__c> feedbackList = [SELECT Id, Survey_Origin__c  from Feedback__c WHERE Complaint__c =: cCase AND Survey_Origin__c = 'Email'];
        if(!feedbackList.isEmpty())
        {
            cr.showError=true;
            cr.ErrorMsg='Attenzione ! È stato già fornito un feedback per la richiesta.' ;
        }
        else
        {
            cr.showError=false;
            cr.ErrorMsg='';
        }
        String url = '';
    if(Network.communitiesLanding() <> null) {
            url = ((Network.communitiesLanding()).geturl()).replace('home/home.jsp','');
        } else {
            String PartnerUrl = [Select BaseURL__c from User where id=:UserInfo.getUserId() limit 1].BaseURL__c;
            url = (PartnerUrl.replace('--c.','.')).replace('visual.force','my.salesforce');
        }

        cr.OrgUrl = url;
    return cr;
    }

    //OAVERSANO 16/10/2018 : Fix Instant Feedback -- END

    @AuraEnabled
    //public static checkResults saveFeedback(Decimal serviceSpeed, Decimal answerCompleteness, String cmt, String origin, String recordType, String cCase)
    //public static Feedback__c saveFeedback(Decimal serviceSpeed, Decimal answerCompleteness, String cmt, String origin, String recordType, String cCase)
    public static checkResults saveFeedback(Decimal overallRating, String cmt, String origin, String recordType, String cCase) //OAVERSANO 05/03/2019 : NMA Enhancement VII
    {
        checkResults cr = new checkResults();

        Savepoint sp = Database.setSavepoint();

        try
        {
            Id rTId = [SELECT Id FROM RecordType WHERE DeveloperName =: recordType].Id;
            
            Case ca = [SELECT CaseNumber, Status, OwnerId,Owner.Name,User__c,User__r.Name,Agency_Code__c FROM Case WHERE Id =: cCase];
            
            //OAVERSANO 25/01/2019 : NMA Fix -- START
            //Feedback__c f = new Feedback__c ( Agent_ID__c=ca.User__r.Name,Agency_Code__c=ca.Agency_Code__c,Survey_Origin__c = origin, Rating1__c = serviceSpeed, Rating2__c = answerCompleteness, Complaint__c = cCase, RecordTypeId = rTId, FeedbackComments__c = cmt );
            //OAVERSANO 05/03/2019 : NMA Enhancement VII -- START
            //Feedback__c f = new Feedback__c ( Agent_ID__c=ca.User__r.Name,Agency_Code__c=ca.Agency_Code__c,Survey_Origin__c = origin, Rating1__c = answerCompleteness, Rating2__c = serviceSpeed, Complaint__c = cCase, RecordTypeId = rTId, FeedbackComments__c = cmt );
            Feedback__c f = new Feedback__c ( Agent_ID__c=ca.User__r.Name,Agency_Code__c=ca.Agency_Code__c,Survey_Origin__c = origin, Valutazione_complessiva_Agente__c = overallRating, Complaint__c = cCase, RecordTypeId = rTId, FeedbackComments__c = cmt );  
            //OAVERSANO 05/03/2019 : NMA Enhancement VII -- END
            //OAVERSANO 25/01/2019 : NMA Fix -- END
            insert f;
            
            //ca.Status = 'Risolto';
            //update ca;
            
            //OAVERSANO 20/09/2018 : Nuovo Modello di Assistenza -- START 
            if (cmt.length() == 0)
            {
                cmt = 'Case risolto, feedback senza commento';
            }
            //OAVERSANO 20/09/2018 : Nuovo Modello di Assistenza -- END

            String categ = '';
            if (recordType.equalsIgnoreCase('ChatSurvey')) { categ = 'Feedback post-chat'; }
            if (recordType.equalsIgnoreCase('GeneralFeedback')) { categ = 'Feedback su richiesta evasa'; }
            if (recordType.equalsIgnoreCase('Front_end_agenti')) { categ = 'Feedback su richiesta evasa'; }
            
            String rTId2 = [SELECT Id FROM RecordType WHERE DeveloperName = 'Agente'].Id;
        
            Id idProfile       = UserInfo.getProfileId();
            String profileName = [Select Name from Profile WHERE Id =: idProfile LIMIT 1].Name;
            String userRole    = '-';

            if(profileName.contains('Vendite'))
                profileName = 'Agente';
            //MDANTONIO 02/04/2019 : storicizzazione valore “Preso in carico” - start
            //Storico_conversazioni__c sc = new Storico_conversazioni__c ( Description__c = cmt, Connected_case__c = cCase, CaseStatus__c = ca.Status, Type__c = categ, RecordTypeId = rTId2, Profilo_utente__c = profileName, Ruolo_utente__c = userRole ); 
            String caseStatus = ca.Status.equals(AP_Constants.caseStatusAssigned) ? 'Preso in carico' : ca.Status;
            Storico_conversazioni__c sc = new Storico_conversazioni__c ( Description__c = cmt, Connected_case__c = cCase, CaseStatus__c = caseStatus, Type__c = categ, RecordTypeId = rTId2, Profilo_utente__c = profileName, Ruolo_utente__c = userRole );
            //MDANTONIO 02/04/2019 : storicizzazione valore “Preso in carico” - end
            
            insert sc; // NOPMD  Fix CRUD violation
        }
        catch(exception e)
        {
            String error = e.getMessage();
            Database.rollback(sp);
            cr.showError=true;
            cr.ErrorMsg='La funzionalità non è disponibile. Contattare l\'amministratore di sistema '+error;
            return cr; 
        }

        return cr;
        //return f;
    }
    
    @AuraEnabled
    public static String getOrgURL()
    {
        //String url = [SELECT OrgLink__c FROM Modello_di_Assistenza__mdt WHERE DeveloperName='Redirect'].OrgLink__c;
        String url = '';
        if(Network.communitiesLanding() <> null) {
            url = ((Network.communitiesLanding()).geturl()).replace('home/home.jsp','');
        } else {
            String PartnerUrl = [Select BaseURL__c from User where id=:UserInfo.getUserId() limit 1].BaseURL__c;
            url = (PartnerUrl.replace('--c.','.')).replace('visual.force','my.salesforce');
        }
        return url;
    }

    public without sharing class runQueryWOS {

        public runQueryWOS(){
        }

        public User getUser (Case ca){
            //system.debug('@@ca: '+ca);
            User u = [SELECT Name,Profile.Name FROM User WHERE Id =: ca.OwnerId ]; // NOPMD  Fix CRUD violation

            return u;

        }

        public Messaging.SendEmailResult[] sendEmail (List<Messaging.SingleEmailMessage> listEmail){

            return Messaging.sendEmail(listEmail);

        }
    }
}