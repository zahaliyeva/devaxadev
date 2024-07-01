/*------------------------------------------------------------------------------------------
Author:        Orlando Aversano
Company:       Deloitte
Class:         LightningProponiSoluzioneCTRL
Description:   Apex class used to execute all the logics internal to the 
Lightning component ProponiSoluzioneLightningCmp related to Caring Angel

History

23/7/2018      Created 
-------------------------------------------------------------------------------------------*/
public class LightningProponiSoluzioneCTRL {
    
    private final Id cas;
    public Boolean jsDebug                  {get;set;}
    public String solution                  {get;set;}
    public String caseNumber                {get;set;}
    public String caseStatus                {get;set;}
    public Boolean caseisClosed             {get;set;}     
    public Boolean OwnerIsQueue             {get;set;}   
    
    public LightningProponiSoluzioneCTRL(ApexPages.StandardController stdController) {
        
        Id user_debug_id;
        try{
            user_debug_id = (AAI_Code_Variables__c.getAll()).get('JS_USER_DEBUG') != null ? (AAI_Code_Variables__c.getAll()).get('JS_USER_DEBUG').Value__c : null;
        } catch (Exception e) {
            user_debug_id = null;
        }
        
        if(user_debug_id != null && (user_debug_id  == UserInfo.getUserId())){
            jsDebug= true;
        } else {
            jsDebug=false;
        }
        cas=ApexPages.currentPage().getParameters().get('id');
        if(cas!=null){
            Case c = [SELECT Id, Status, CaseNumber, Details_of_Solution__c,isClosed,OwnerId FROM Case WHERE ID =:cas LIMIT 1];
            solution = (c.Details_of_Solution__c!=null)?c.Details_of_Solution__c:'';
            caseNumber = (c.CaseNumber!=null)?c.CaseNumber:'';
            caseStatus = (c.Status!=null)?c.Status:'';
            caseisClosed = c.isClosed;
            String CaseOwner = c.OwnerId;
            OwnerIsQueue = (CaseOwner.startsWith('00G'))?true:false;
        }
        
    }
    
    @AuraEnabled
    public static Case GetCaseInfo(String caseId) { 
        system.debug('GetCaseInfo');
        Case CasetoReturn;
        if(String.isNotBlank(caseId)){
            Case c = [SELECT Id, Status, CaseNumber, Details_of_Solution__c,isClosed,OwnerId, Recordtype.Name FROM Case WHERE ID =:caseId LIMIT 1];
            
            CasetoReturn = c;
        }
        return CasetoReturn;
    }
    
    @AuraEnabled
    public static buttonToReturn buttonVisible() { 
        system.debug('GetCaseInfo');
        
        //OAVERSANO 17/10/2018 : Caring Angel -- START
        buttonToReturn btn = new buttonToReturn();
        Id idProfile       = UserInfo.getProfileId();
        String profileName = '';
        List<User> CurrentUser = [Select Profile.Name, UserRole.Name from User where id=:UserInfo.getUserId()  limit 1]; // NOPMD  Fix CRUD violation
		
        if(CurrentUser.size()>0)
        {
        	profileName = CurrentUser[0].Profile.Name;
        }
        btn.ProponiSoluzione = false;
        btn.NewCommentAndAttachment = false;
        btn.ChiudiCase = false;
        if(profileName.equalsIgnoreCase('AAI - Supporto HD2 BIZ') || profileName.equalsIgnoreCase('AAI - Supervisor Supporto HD2 BIZ'))
        //OAVERSANO 12/11/2018 : Nuovo Modello di Assistenza Biz -- START
        {
            btn.ProponiSoluzione = true;
            btn.isHD2Biz = true;
        }
        //Giorgio Bonifazi : BugFIX 512 -- START
        if(profileName.equalsIgnoreCase('AAI - Supporto HD2 BIZ') || profileName.equalsIgnoreCase('AAI - Supervisor Supporto HD2 BIZ')|| profileName.equalsIgnoreCase('AAI - Supervisor Supporto HD2') || profileName.equalsIgnoreCase('AAI - Supporto HD2') )
        
        {
            btn.SendSMS = false;
            
        }
        //Giorgio Bonifazi : BugFIX 512 -- END

        //OAVERSANO 12/11/2018 : Nuovo Modello di Assistenza Biz -- END
        //OAVERSANO 17/10/2018 : Caring Angel -- END
        if(MPS_Code_Variables__c.getValues('ProponiSoluzioneHD2')!=null)
        {
            if(String.isNotBlank(MPS_Code_Variables__c.getValues('ProponiSoluzioneHD2').value__c))
            {
                if(MPS_Code_Variables__c.getValues('ProponiSoluzioneHD2').value__c == 'true' && !profileName.equalsIgnoreCase('Caring Angel - Supporto HD2'))
                    btn.ProponiSoluzione = true;
            }
        }
      	//OAVERSANO 18/10/2018 : Caring Angel -- START
      	if(!profileName.equalsIgnoreCase('Caring Angel - Supporto HD2'))
            btn.NewCommentAndAttachment = true;
      	if(profileName.equalsIgnoreCase('Caring Angel - Supporto HD2'))
            btn.ChiudiCase = true;
        return btn;
        //OAVERSANO 18/10/2018 : Caring Angel -- END
        
    }
    
    //OAVERSANO 18/10/2018 : Caring Angel -- START
 	public class buttonToReturn {

		@AuraEnabled public Boolean ProponiSoluzione;
		@AuraEnabled public Boolean NewCommentAndAttachment;
		@AuraEnabled public Boolean ChiudiCase;
		@AuraEnabled public Boolean isHD2Biz; //OAVERSANO 12/11/2018 : Nuovo Modello di Assistenza Biz
        @AuraEnabled public Boolean SendSMS; //Giorgio Bonifazi: Bug Fix 512 
    	public buttonToReturn(){}

    
    }
    //OAVERSANO 18/10/2018 : Caring Angel -- END


    @AuraEnabled
    public static String UpdateSolutionDetail(String caseId, String value) { 
        system.debug('UpdateSolutionDetail');
        String toReturn;
        if(String.isNotBlank(caseId) && String.isNotBlank(value))
        {
            
            Case cs = [SELECT Id, Status, CaseNumber, User__c, User__r.Name, Details_of_Solution__c, Oggetto_Apertura_Case__c, Data_soluzione_proposta__c,Description FROM CASE WHERE Id =:caseId]; //Giorgio Bonifazi fix EmailTemplate
            //OAVERSANO 10/12/2018 : modifica CaseStatus Storico Conversazioni -- START
            //MDANTONIO 02/04/2019 : storicizzazione valore “Preso in carico” - start
            //String oldCaseStatus = cs.Status;
            String oldCaseStatus = cs.Status.equals(AP_Constants.caseStatusAssigned) ? 'Preso in carico' : cs.Status;
            //MDANTONIO 02/04/2019 : storicizzazione valore “Preso in carico” - end
            //OAVERSANO 10/12/2018 : modifica CaseStatus Storico Conversazioni -- END
            // SALVADOR PROFILI E RUOLI IN STORICO CONVERSAZIONI - BEGIN
            //MOSCATELLI_M 25/10/2018: NMA Business -- START
            //Id idProfile       = UserInfo.getProfileId();
            String profileName = '';
            String techProfileName = '';
            String userRole    = '-';
            User CurrentUser = [Select UserRole.Name,Profile.Name from User where id=: UserInfo.getUserId() limit 1][0];

            if((CurrentUser.Profile.Name).indexOf('HD1')<>-1)
            {
                profileName = 'Primo Livello';

                if((CurrentUser.Profile.Name).indexOf('HD1 BIZ')<>-1)
                    techProfileName = 'Primo Livello Business';
                //MOSCATELLI 11/02/2019: Lob Contabilità -- START
                else if(CurrentUser.UserRole.Name=='HD1 Contabilita' || (CurrentUser.Profile.Name).contains('HD1 Contabilità'))
                    techProfileName ='Primo Livello Contabilità';
                else if(CurrentUser.UserRole.Name=='HD1 Contenzioso' || (CurrentUser.Profile.Name).contains('HD1 Contenzioso'))
                    techProfileName ='Primo Livello Contenzioso';
                //MOSCATELLI 11/02/2019: Lob Contabilità -- END
                else
                    techProfileName = 'Primo Livello IT';
            }
            else if((CurrentUser.Profile.Name).indexOf('HD2')<>-1)
            {
                profileName = 'Secondo Livello';

                userRole = CurrentUser.UserRole.Name;

                if((CurrentUser.Profile.Name).indexOf('HD2 BIZ')<>-1)
                    techProfileName = 'Secondo Livello Business';
                else
                    techProfileName = 'Secondo Livello IT';
            }
            //MOSCATELLI_M 25/10/2018: NMA Business -- END

            String OrgEmail    = (MPS_Code_Variables__c.getAll()).get('ModelloAssistenzaOrgEmail') != null ? (MPS_Code_Variables__c.getAll()).get('ModelloAssistenzaOrgEmail').Value__c : null;
            // SALVADOR PROFILI E RUOLI IN STORICO CONVERSAZIONI - END
            cs.Details_of_Solution__c = value;
            cs.Status = AP_Constants.caseStatusSoluzioneProposta;
            cs.Data_soluzione_proposta__c = system.now();
            Storico_conversazioni__c stoConv = new Storico_conversazioni__c(Connected_case__c = cs.Id,
                                                                            //CaseStatus__c = AP_Constants.caseStatusSoluzioneProposta, //OAVERSANO 10/12/2018 : modifica CaseStatus Storico Conversazioni
                                                                            CaseStatus__c = oldCaseStatus, //OAVERSANO 10/12/2018 : modifica CaseStatus Storico Conversazioni
                                                                            Description__c = value,
                                                                            Type__c = AP_Constants.stoConvTypeSoluzione,
                                                                            RecordTypeId = Schema.SObjectType.Storico_conversazioni__c.getRecordTypeInfosByName().get(AP_Constants.rtstoConvAgente).getRecordTypeId(),
                                                                            // SALVADOR PROFILI E RUOLI IN STORICO CONVERSAZIONI - BEGIN
                                                                            Profilo_utente__c = profileName,
                                                                            Ruolo_utente__c = userRole,
                                                                            //MDANTONIO 03/04/2019 : Tracciamento destinatario commento - start
                                                                            Destinatario_Commento__c = 'Agente',
                                                                            //MDANTONIO 03/04/2019 : Tracciamento destinatario commento - end
                                                                            // SALVADOR PROFILI E RUOLI IN STORICO CONVERSAZIONI - END
                                                                            Tech_Profilo_Utente__c = techProfileName//MOSCATELLI_M 25/10/2018: NMA Business
                                                                            );
            Savepoint sp = Database.setSavepoint();
            try{
                Database.update(cs);
                insert stoConv; // NOPMD  Fix CRUD violation

                String emTemplate = '';
                Modello_di_Assistenza__mdt mdAss = [SELECT Id, DeveloperName, Email_Template__c // NOPMD  Fix CRUD violation
                                                FROM Modello_di_Assistenza__mdt 
                                                WHERE DeveloperName  = 'TemplateInvioSoluzione' 
                                                LIMIT 1];
                if(mdAss!=null && cs.User__c!=null)
                {
                    emTemplate = mdAss.Email_Template__c;
                    
                    EmailTemplate etem = [SELECT Markup, Subject, HtmlValue, body // NOPMD  Fix CRUD violation
                                            FROM EmailTemplate 
                                            WHERE DeveloperName =:emTemplate ];
                    // SALVADOR CASE LINK EMAIL - BEGIN
                    String url = [SELECT OrgLink__c 
                                  FROM Modello_di_Assistenza__mdt 
                                  WHERE DeveloperName = 'RedirectCommunity'
                                  LIMIT 1].OrgLink__c;    
                    url = url + caseId; 
                    String urlNFE = [SELECT OrgLink__c 
                    FROM Modello_di_Assistenza__mdt 
                    WHERE DeveloperName = 'RedirectCommunityNFE'
                    LIMIT 1].OrgLink__c + caseId;
                    
                    // SALVADOR CASE LINK EMAIL - END
                    List<Messaging.SingleEmailMessage> listEmail = new List<Messaging.SingleEmailMessage>();
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    String htmlBody = etem.HtmlValue;
                    system.debug('htmlBody pre: '+htmlBody);
                    String subject = etem.Subject;
                    String body = etem.body;
                    subject = subject.replace('{!Case.CaseNumber}',cs.CaseNumber);
                    subject = subject.replace('{!Case.Oggetto_Apertura_Case__c}',((cs.Oggetto_Apertura_Case__c==null)?'':string.valueof(cs.Oggetto_Apertura_Case__c)));
                    htmlBody = htmlBody.replace('{!Case.CaseNumber}',cs.CaseNumber);
                    htmlBody = htmlBody.replace('{!Case.User__c}',cs.User__r.Name);
                    htmlBody = htmlBody.replace('{!Case.Details_of_Solution__c}',((cs.Details_of_Solution__c==null)?'':string.valueof(cs.Details_of_Solution__c)));
                    //Giorgio Bonifazi fix EmailTemplate -- START
                    htmlBody = htmlBody.replace('{!Case.Oggetto_Apertura_Case__c}',((cs.Oggetto_Apertura_Case__c==null)?'':string.valueof(cs.Oggetto_Apertura_Case__c)));
                    htmlBody = htmlBody.replace('{!Case.Description}',((cs.Description==null)?'':string.valueof(cs.Description)));
                    //Giorgio Bonifazi fix EmailTemplate -- END
                    //htmlBody = htmlBody.replace('{!Case.Link}','https://login.salesforce.com/' +cs.Id ); 
                    // SALVADOR CASE LINK EMAIL - BEGIN
                    if(htmlBody.contains('{!Case.Link1}')){
                        htmlBody = htmlBody.replace('{!Case.Link1}', url );
                        htmlBody = htmlBody.replace('{!Case.Link2}', urlNFE ); 
                        body = body.replace('{!Case.Link1}', url ); 
                        body = body.replace('{!Case.Link2}', urlNFE ); 
                    }
                    else{
                    htmlBody = htmlBody.replace('{!Case.Link}', url ); 
                        body = body.replace('{!Case.Link}', url );
                    }
                    
                    // SALVADOR CASE LINK EMAIL - END
                    body = body.replace('{!Case.CaseNumber}',cs.CaseNumber);
                    body = body.replace('{!Case.User__c}',cs.User__r.Name);
                    body = body.replace('{!Case.Details_of_Solution__c}',((cs.Details_of_Solution__c==null)?'':string.valueof(cs.Details_of_Solution__c)));
                    //Giorgio Bonifazi fix EmailTemplate -- START
                    body = body.replace('{!Case.Oggetto_Apertura_Case__c}',((cs.Oggetto_Apertura_Case__c==null)?'':string.valueof(cs.Oggetto_Apertura_Case__c)));
                    body = body.replace('{!Case.Description}',((cs.Description==null)?'':string.valueof(cs.Description)));
                    //Giorgio Bonifazi fix EmailTemplate -- END
                    //body = body.replace('{!Case.Link}','https://login.salesforce.com/' +cs.Id );
                    // SALVADOR CASE LINK EMAIL - BEGIN
                    
                    // SALVADOR CASE LINK EMAIL - END
                    
                    system.debug('htmlBody: '+htmlBody);
                    email.setHtmlBody(htmlBody);
                    email.setSubject(subject);
                                    
                    email.setTargetObjectId(cs.User__r.Id);

                    if(String.isNotBlank(OrgEmail))
                        email.setOrgWideEmailAddressId(OrgEmail);
                        
                    email.saveAsActivity = false;
                    listEmail.add(email);
                    Messaging.SendEmailResult [] results = Messaging.sendEmail(listEmail);
                    
                    if (results[0].success) 
                    {
                        System.debug('The email was sent successfully.');
                        toReturn = 'OK';
                    } 
                    else 
                    {
                        System.debug('The email failed to send: ' + results[0].errors[0].message);
                        toReturn = 'KO|FallitoSi è verificato il seguente errore:\n'+results[0].errors[0].message+'\nContattare l\'amministratore di sistema.';
                        Database.rollback(sp);
                    }
                }
                else
                {
                    toReturn = 'KO|FallitoÈ necessario associare un agente al case per poter proporre una soluzione.';
                    Database.rollback(sp);
                }
            } catch (Exception ex){
                System.debug('There was an exception: ' + ex.getMessage());
                toReturn = 'KO|FallitoAttenzione! Si è verificato il seguente errore: \n'+ex.getMessage()+'\nRiprova più tardi, se il problema persiste contattaci telefonicamente.';
                Database.rollback(sp);
            }
        }
        else
        {
            toReturn =  'KO|FallitoSi è verificato un errore.\nContattare l\'amministratore di sistema.';
        }
        return toReturn;
    }
    
    //OAVERSANO 18/12/2018 : Enhancement NMA Biz III -- START
    @AuraEnabled
    public static ResponseDto deleteAttachments(List<String> attachmentIds) //delete attachments related to a Case
    {
    	List<ContentVersion> conVerList = [SELECT Id, VersionData, ContentDocumentId, Title, ContentSize FROM ContentVersion WHERE Id IN:attachmentIds ]; // NOPMD  Fix CRUD violation
        List<String> contentDocLinkToDelete = new List<String>();
        for(ContentVersion conVer : conVerList)
        {
        	contentDocLinkToDelete.add(conVer.ContentDocumentId);
        }
        Database.delete(contentDocLinkToDelete);
        ResponseDto serverResponse = new ResponseDto(true,'Attachments deleted');
        
        return serverResponse;     
    }
    
    public class ResponseDto { // Object to better handle errors from http://blog.terrasky.com/blog/how-to-handle-apex-errors-for-lightning-component-implementations
        @AuraEnabled public Boolean isSuccess { get; set; }
        @AuraEnabled public String message { get; set; }
        @AuraEnabled public Map<Object, Object> values { get; set; }
        public ResponseDto(Boolean isSuccess, String msg){
            this.isSuccess = isSuccess;
            this.message = msg;
            this.values = new Map<Object, Object>();
        }   
        
        public ResponseDto(){
            this.isSuccess = False;
            this.message = '';
            this.values = new Map<Object, Object>();
        }       
    }
	//OAVERSANO 18/12/2018 : Enhancement NMA Biz III -- END

}