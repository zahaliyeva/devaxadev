public with sharing class CommentToSolutionServer {
    
    //agencyHDChartsCTRL
    //back con gestione URL
    public string apexCaseId{get;set;}
    
    public CommentToSolutionServer(ApexPages.StandardController stdController)
    {
        apexCaseId = ApexPages.currentPage().getParameters().get('id');
    }
    
    @AuraEnabled
    public static boolean checkError(String cCase)
    {
        String status = [SELECT Status FROM Case WHERE Id =: cCase].Status;
        if (!status.equalsIgnoreCase('Soluzione proposta')) 
        {
            return true;      
        }
        return false;
    }
    
    @AuraEnabled
    public static Storico_conversazioni__c saveComment(String cmt, String cCase)
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
        if(skipValidation != null) {
            skipValidation.BypassValidationRules__c= true;
            upsert skipValidation; // NOPMD  Fix CRUD violation
        }
        //OAVERSANO 11/10/2018 : Modello di Assistenza -- END
        Case ca = [SELECT CaseNumber, Status, OwnerId, Owner.Name, ProfileNameOwner__c, QueueNameOwner__c, RoleNameOwner__c FROM Case WHERE Id =: cCase];
        //OAVERSANO 10/12/2018 : modifica CaseStatus Storico Conversazioni -- START
        String oldCaseStatus = ca.Status;
        //OAVERSANO 10/12/2018 : modifica CaseStatus Storico Conversazioni -- END
        ca.Status = 'Soluzione rifiutata';
        update ca;
        //OAVERSANO 11/10/2018 : Modello di Assistenza -- START
        if (skipValidation!=null)
        {
            skipValidation.BypassValidationRules__c= false;
            
            update skipValidation; // NOPMD  Fix CRUD violation
            
        }
        //OAVERSANO 11/10/2018 : Modello di Assistenza -- END
        String OrgEmail    = (MPS_Code_Variables__c.getAll()).get('ModelloAssistenzaOrgEmail') != null ? (MPS_Code_Variables__c.getAll()).get('ModelloAssistenzaOrgEmail').Value__c : null;

        runQueryWOS queryRunner = new runQueryWOS();
       // User u = queryRunner.getUser(ca);
 
        Modello_di_Assistenza__mdt mdAss = [SELECT Id, Email_Template__c // NOPMD  Fix CRUD violation
                                                FROM Modello_di_Assistenza__mdt 
                                                WHERE DeveloperName  = 'TemplateCommentaSoluzione'
                                                LIMIT 1];

        String emTemplate = mdAss.Email_Template__c;
            
      EmailTemplate etem = [SELECT Markup, Subject, HtmlValue, body // NOPMD  Fix CRUD violation
                  FROM EmailTemplate 
                      WHERE DeveloperName =: emTemplate LIMIT 1];
       List<Messaging.SingleEmailMessage> listEmail = new List<Messaging.SingleEmailMessage>();
      Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
    String htmlBody = etem.HtmlValue;
    //System.debug('htmlBody pre: ' + htmlBody);
    String subject = etem.Subject;
    String body    = etem.body;
    subject  = subject.replace('{!Case.CaseNumber}', ca.CaseNumber);
        subject  = subject.replace('{!Case.Status}', ca.Status);
    htmlBody = htmlBody.replace('{!Case.User__c}', ca.Owner.Name);
        body     = body.replace('{!Case.User__c}', ca.Owner.Name);
        htmlBody = htmlBody.replace('{!Case.CaseNumber}', ca.CaseNumber);
        body     = body.replace('{!Case.CaseNumber}', ca.CaseNumber);
        /*String url = '';
        if(Network.communitiesLanding() <> null) {
            url = ((Network.communitiesLanding()).geturl()).replace('home/home.jsp',''+ca.Id);
        } else {
            String PartnerUrl = [Select BaseURL__c from User where id=:UserInfo.getUserId() limit 1].BaseURL__c;
            url = (PartnerUrl.replace('--c.','.')).replace('visual.force','my.salesforce')+''+ca.Id;
        } */
        
        String url = [SELECT OrgLink__c 
                      FROM Modello_di_Assistenza__mdt 
                      WHERE DeveloperName = 'Redirect'
                      LIMIT 1].OrgLink__c;
        htmlBody = htmlBody.replace('{!Case.Link}', url + cCase);    
        body     = body.replace('{!Case.Link}', url + cCase);
        htmlBody = htmlBody.replace('{!Case.Description}', String.valueOf(cmt));    
        body     = body.replace('{!Case.Description}', String.valueOf(cmt));
    //System.debug('htmlBody: ' + htmlBody);
    email.setHtmlBody(htmlBody);
    email.setSubject(subject);
       email.setTargetObjectId(ca.OwnerId);

        if(String.isNotBlank(OrgEmail))
            email.setOrgWideEmailAddressId(OrgEmail);

    email.saveAsActivity = false;
    listEmail.add(email);
      Messaging.SendEmailResult [] results = queryRunner.sendEmail(listEmail);
        
        String rTId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Agente'].Id;
       
        Id idProfile       = UserInfo.getProfileId();
        String profileName = 'Agente';//[Select Name from Profile WHERE Id =: idProfile LIMIT 1].Name;
        String userRole    = '-';
        
        //Storico_conversazioni__c sc = new Storico_conversazioni__c( Description__c = cmt, Connected_case__c = cCase, CaseStatus__c = 'Soluzione rifiutata', Type__c = 'Soluzione non accettata', RecordTypeId = rTId,  Profilo_utente__c = profileName, Ruolo_utente__c = userRole ); //OAVERSANO 10/12/2018 : modifica CaseStatus Storico Conversazioni
        //MDANTONIO 05/04/2019 : Tracciamento destinatario commento - start
        //Storico_conversazioni__c sc = new Storico_conversazioni__c( Description__c = cmt, Connected_case__c = cCase, CaseStatus__c = oldCaseStatus, Type__c = 'Soluzione non accettata', RecordTypeId = rTId,  Profilo_utente__c = profileName, Ruolo_utente__c = userRole ); //OAVERSANO 10/12/2018 : modifica CaseStatus Storico Conversazioni
        String ownerProfileOrQueue = String.valueOf(ca.OwnerId).startsWith('00G') ? ca.QueueNameOwner__c : ca.ProfileNameOwner__c;
        System.debug('===> ownerProfileOrQueue: ' + ownerProfileOrQueue);
        String destinatario = ModelloDiAssistenzaUtils.getDestinatario(ownerProfileOrQueue, ca.RoleNameOwner__c, ca.OwnerId);
        System.debug('===> destinatario conversazione: ' + destinatario);
        Storico_conversazioni__c sc = new Storico_conversazioni__c( Description__c = cmt, Connected_case__c = cCase, CaseStatus__c = oldCaseStatus, Type__c = 'Soluzione non accettata', RecordTypeId = rTId,  Profilo_utente__c = profileName, Ruolo_utente__c = userRole, Destinatario_Commento__c = destinatario ); //OAVERSANO 10/12/2018 : modifica CaseStatus Storico Conversazioni
        //MDANTONIO 05/04/2019 : Tracciamento destinatario commento - end
        
        insert sc; // NOPMD  Fix CRUD violation
        
        return sc;
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

            User u = [SELECT Name FROM User WHERE Id =: ca.OwnerId ]; // NOPMD  Fix CRUD violation

            return u;

        }

        public Messaging.SendEmailResult[] sendEmail (List<Messaging.SingleEmailMessage> listEmail){

            return Messaging.sendEmail(listEmail);

        }
    }
}