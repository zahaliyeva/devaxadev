public with sharing class CloseCaseServer {
    
    public string apexCaseId{get;set;}
    public String apexCaseStatus	{get;set;} //OAVERSANO 05/12/2018 FIX
    
    public CloseCaseServer(ApexPages.StandardController stdController)
    {
        apexCaseId = ApexPages.currentPage().getParameters().get('id');
        apexCaseStatus = ApexPages.currentPage().getParameters().get('caseStatus');
    }

    ///new
    public class doInitResults
    {
        @AuraEnabled public Boolean isAvailable;
        @AuraEnabled public String OrgUrl;

        public doInitResults()
        {
            this.isAvailable = true;
            this.OrgUrl='';
        }
    }
    ///new
    
    @AuraEnabled
   // public static Storico_conversazioni__c closeCase(String cmt, String cCase)
    public static String closeCase(String cmt, String cCase, String CaseStatus)
    {
        /*Case ca = [SELECT CaseNumber, Status, OwnerId FROM Case WHERE Id =: cCase];
        ca.Status = 'Chiuso in autonomia';
        update ca;*/
        
        //User u = [SELECT Name FROM User WHERE Id =: ca.OwnerId];
 //
        //Modello_di_Assistenza__mdt mdAss = [SELECT Id, Email_Template__c
        //                                        FROM Modello_di_Assistenza__mdt 
        //                                        WHERE DeveloperName  = 'TemplateChiusuraUfficioCase'
        //                                        LIMIT 1];
//
        //String emTemplate = mdAss.Email_Template__c;
        //          
        //EmailTemplate etem = [SELECT Markup, Subject, HtmlValue, body 
        //                    FROM EmailTemplate 
        //                    WHERE DeveloperName =: emTemplate];
        //List<Messaging.SingleEmailMessage> listEmail = new List<Messaging.SingleEmailMessage>();
        //Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        //String htmlBody = etem.HtmlValue;
        //System.debug('htmlBody pre: ' + htmlBody);
        //String subject = etem.Subject;
        //String body    = etem.body;
        //subject  = subject.replace('{!Case.CaseNumber}', ca.CaseNumber);
        //subject  = subject.replace('{!Case.Status}', ca.Status);
        //htmlBody = htmlBody.replace('{!Case.User__c}', u.Name); 
        //htmlBody = htmlBody.replace('{!Storico_conversazioni__c.Description__c}', String.valueOf(cmt));
        //body     = body.replace('{!Case.User__c}', u.Name);
        //body     = body.replace('{!Storico_conversazioni__c.Description__c}', String.valueOf(cmt));
        //System.debug('htmlBody: ' + htmlBody);
        //email.setHtmlBody(htmlBody);
        //email.setSubject(subject);
        //email.setTargetObjectId(ca.OwnerId);
        //email.saveAsActivity = false;
        //listEmail.add(email);
        //Messaging.SendEmailResult [] results = Messaging.sendEmail(listEmail);
        //
        //if (results[0].success) {
        //    System.debug('The email was sent successfully.');
        //} else {
        //    System.debug('The email failed to send: ' + results[0].errors[0].message);
        //}        
        
        String rTId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Agente'].Id;        
       // Storico_conversazioni__c sc = new Storico_conversazioni__c ( Description__c = cmt, Connected_case__c = cCase, CaseStatus__c = 'Chiuso in autonomia', Type__c = 'Chiudi case', RecordTypeId = 'fdfsdfs' );
        String errorMgs='';
        //OAVERSANO 11/10/2018 : Modello di Assistenza -- START
        List<bypass__c> skipValidations = [select Id, Name, SetupOwnerId, SetupOwner.Name, BypassTrigger__c, BypassValidationRules__c, BypassWorkflows__c from Bypass__c ];
      system.debug('skipValidations: '+skipValidations);
        bypass__c skipValidation;
        for(bypass__c bp : skipvalidations)
        {
            if(bp.SetupOwnerId == UserInfo.getProfileId())
                skipValidation = bp;
        }
        if(skipValidation != null) {
            skipValidation.BypassValidationRules__c= true;
            upsert skipValidation;
        }
        //OAVERSANO 11/10/2018 : Modello di Assistenza -- END
        try
        {   
            Id idProfile       = UserInfo.getProfileId();
            // String profileName = [Select Name from Profile WHERE Id =: idProfile LIMIT 1].Name;
            // String userRole    = '-';
            system.debug('CaseStatus: '+CaseStatus);
            //MDANTONIO 02/04/2019 : storicizzazione valore “Preso in carico” - start
            //Storico_conversazioni__c sc = new Storico_conversazioni__c ( Description__c = cmt, Connected_case__c = cCase, CaseStatus__c = CaseStatus, Type__c = 'Annullamento richiesta', RecordTypeId = rTId, Profilo_utente__c = 'Agente', Ruolo_utente__c = '-' );
            CaseStatus = CaseStatus.equals(AP_Constants.caseStatusAssigned) ? 'Preso in carico' : CaseStatus;
            Storico_conversazioni__c sc = new Storico_conversazioni__c ( Description__c = cmt, Connected_case__c = cCase, CaseStatus__c = CaseStatus, Type__c = 'Annullamento richiesta', RecordTypeId = rTId, Profilo_utente__c = 'Agente', Ruolo_utente__c = '-' );
            //MDANTONIO 02/04/2019 : storicizzazione valore “Preso in carico” - start
  
            insert sc;

            Case ca = new Case(id=cCase);
            ca.Status = AP_Constants.caseStatusRisoltoInAutonomia;
            update ca;
            //OAVERSANO 11/10/2018 : Modello di Assistenza -- START
            if (skipValidation!=null)
          {
                skipValidation.BypassValidationRules__c= false;
                update skipValidation;
            }
            //OAVERSANO 11/10/2018 : Modello di Assistenza -- END
        }
        catch(exception ex)
        {
            errorMgs = 'Non è stato possibile procedere con la richiesta. Contattare l\'amministratore di sistema: '+ex.getMessage();
        }

        return errorMgs;
    }
    
    @AuraEnabled
    //public static String getOrgURL(){
        public static doInitResults getOrgURL(String cCase){
        //String url = [SELECT OrgLink__c FROM Modello_di_Assistenza__mdt WHERE DeveloperName='Redirect'].OrgLink__c;
        String url = '';
        
        Boolean CaseClosed = [Select isclosed from Case where id=:cCase].isclosed;
        if(!CaseClosed)
        {           
            if(Network.communitiesLanding() <> null) {
                url = ((Network.communitiesLanding()).geturl()).replace('home/home.jsp','');
            } else {
                String PartnerUrl = [Select BaseURL__c from User where id=:UserInfo.getUserId() limit 1].BaseURL__c;
                url = (PartnerUrl.replace('--c.','.')).replace('visual.force','my.salesforce');
            }
        }

        doInitResults dnr = new doInitResults();

        dnr.OrgUrl = url;
        
        if(CaseClosed)
            dnr.isAvailable = false;
        
        return dnr;

        //return url;
    }
}