public class sendEmailCaseCTRL {
    public boolean jsDebug{get;set;}
    public string apexCaseId{get;set;}
    public String additionalToAddress {get;set;}
    public String senderAddress {get;set;}
    public String templateId {get;set;}
    public Boolean isFeedView{get;set;}//MMOSCATELLI 25022019: ICF CR
    
    public sendEmailCaseCTRL (ApexPages.StandardController stdController)
    {
        Id user_debug_id;
        try
        {
            user_debug_id = (AAI_Code_Variables__c.getAll()).get('JS_USER_DEBUG') != null ? (AAI_Code_Variables__c.getAll()).get('JS_USER_DEBUG').Value__c : null;
        }
        catch (Exception e)
        {
            user_debug_id = null;
        }
        if (user_debug_id != null && (user_debug_id  == UserInfo.getUserId()))
        {
            jsDebug= true;
        }
        else
        {
            jsDebug=false;
        }
        apexCaseId=ApexPages.currentPage().getParameters().get('p3_lkid');
        additionalToAddress = ApexPages.currentPage().getParameters().get('p24');
        senderAddress=  ApexPages.currentPage().getParameters().get('p26');
        templateId = ApexPages.currentPage().getParameters().get('template_id');

        //MMOSCATELLI 25022019: ICF CR — START
        isFeedView =(ApexPages.currentPage().getParameters().get('isFeedView')=='true')?true:false;
        String AccountId = ApexPages.currentPage().getParameters().get('p2_lkid');

        if(String.isNotBlank(AccountId) && String.isBlank(additionalToAddress) && Accountid.startsWith('001'))
        {           
            Case c = [Select suppliedEmail, accountid from Case where id=:apexCaseId];
            Account a =[Select id, RecordTypeId,Additional_Email__c,PersonEmail,Account_email__c,Subject_email__c,IsPersonAccount,CIF_PersonalEmail__c,CIF_Work_email__c,CIF_PersonEmail__c,Claim_PersonalEmail__c,RecordType.DeveloperName,AAI_Agency__c,AAI_Agency__r.Agency_email__c,AAI_Agency_Reference_Code__c from Account where id=:AccountId];
            User CurrentUser = [Select IsPortalEnabled,Email from User where id=: UserInfo.GetUserId() ]; // NOPMD  Fix CRUD violation

            List<Account> AccLst = new List<Account>();
            AccLst.add(a);

            additionalToAddress = VFC14_SendEmailView.setToAddress(AccLst,CurrentUser.IsPortalEnabled,c);
        }
        //MMOSCATELLI 25022019: ICF CR — END

        //p24 additionalToAddress
        //p26 SENDER (FROM)
        //template_id

    }

    @AuraEnabled
    public static ResponseDto populateTemplate (String templateId, String caseId)
    {

        String contactId = null;
        String caseCheckStr = null;
        if (caseId!='') caseCheckStr = caseId;
        List<Case> caseList =[SELECT AccountId, Account.AAI_Agency_Reference_Code__c,Account.RecordType.DeveloperName FROM Case WHERE Id = :caseId];
        if (caseList.size()>0)
        {
            String accountId = caseList[0].AccountId;
            List<Contact> contactList = [SELECT Id FROM Contact WHERE AccountId = :accountId];
            if (contactList.size()>0) contactId = contactList[0].Id; //No multiple contacts in AXA

        }
        Messaging.SingleEmailMessage email= new Messaging.SingleEmailMessage();
        email = Messaging.renderStoredEmailTemplate (templateId,contactId,caseCheckStr);
        String body = email.getHtmlBody();
        String subject = email.getSubject();
        ResponseDto response = new ResponseDto();
        response.isSuccess = true;
        response.message = '';
        response.values.put('body',body);
        response.values.put('subject',subject);
        //DEFAULT BCC PART
        EmailTemplate singleTemplate = [SELECT DeveloperName FROM EmailTemplate WHERE Id = :templateId ]; // NOPMD  Fix CRUD violation
        String singleTemplateDevName = singleTemplate.DeveloperName;
        list<Case_Email_Agency_Notification__mdt> templateSettings = new List<Case_Email_Agency_Notification__mdt>();
        templateSettings = [SELECT Notify_Agency__c FROM Case_Email_Agency_Notification__mdt WHERE Template_Developer_Name__c = :singleTemplateDevName ]; // NOPMD  Fix CRUD violation
        if (templateSettings.size()>0)
        {
            Boolean notificationCheck = templateSettings[0].Notify_Agency__c;
            if(notificationCheck && caseList.size()>0 && caseList[0].AccountId!= null  && (caseList[0].Account.RecordType.DeveloperName == 'B2B_Client'|| caseList[0].Account.RecordType.DeveloperName == 'B2C_Client' ))
            {
                String agencyCode = caseList[0].Account.AAI_Agency_Reference_Code__c;
                Account agencyAccount = [SELECT Id,Agency_email__c FROM Account WHERE RecordType.DeveloperName ='Agency' AND Agency_Code__c = :agencyCode  LIMIT 1]; // NOPMD  Fix CRUD violation
                if (agencyAccount.Agency_email__c!= null && agencyAccount.Agency_email__c != '')
                {
                    response.values.put('defaultBCC',agencyAccount.Agency_email__c);
                }
                else
                {
                    //IF the email is not present, I default it to a standard format
                    String agCodeFourDigits = agencyCode.removeStart('00');
                    String BCCAgencyAddress = 'AG'+agCodeFourDigits+'@AXA-AGENZIE.IT';
                    response.values.put('defaultBCC',BCCAgencyAddress);                    
                }
            }
        }
        return response;


    }

    @AuraEnabled
    public static Map<String,String> getEmailFolders ()
    {
        Map<String,String> folders = new Map<String,String>();
        List<Folder> queriedFolders = [SELECT AccessType,CreatedById,CreatedDate,DeveloperName,Id,IsReadonly,LastModifiedById,LastModifiedDate,Name,NamespacePrefix,SystemModstamp,Type FROM Folder WHERE Type = 'Email' ORDER BY Name];
        for (Folder f :queriedFolders)
        {
            folders.put(f.Id,f.Name);
        }

        return folders;
    }

    @AuraEnabled
    public static Map<String,String> getEmailTemplates (String folderId)
    {
        Map<String,String> emailTemplates = new Map<String,String>();
        List<EmailTemplate> queriedEmails = [SELECT Id,Name FROM EmailTemplate WHERE FolderId = :folderId  ORDER BY Name]; // NOPMD  Fix CRUD violation
        for (EmailTemplate f :queriedEmails)
        {
            emailTemplates.put(f.Id,f.Name);
        }

        return emailTemplates;
    }

    //MMOSCATELLI 25022019: ICF CR — START
    public class FromObject
    {
        @AuraEnabled public Map<String,String> OrgWideAddrMap;
        @AuraEnabled public Boolean isUserAgent;
        @AuraEnabled public String ccAddress; //OAVERSANO 06/03/2019 : ICF CR
        @AuraEnabled public String DefaultTemplateId;

        public FromObject()
        {
            this.OrgWideAddrMap = new Map<String,String>();
            this.isUserAgent = false;
            this.ccAddress = ''; //OAVERSANO 06/03/2019 : ICF CR
            this.DefaultTemplateId='';
        }
    }
    //MMOSCATELLI 25022019: ICF CR — END    

    @AuraEnabled
    //MMOSCATELLI 25022019: ICF CR — START 
    //public static Map<String,String> getFromList ()
    public static FromObject getFromList ()
    //MMOSCATELLI 25022019: ICF CR — END 
    {
        Map<String,String> fromList = new Map<String,String>();
        String UserId=UserInfo.GetUserId();
        User CurrentUser = new User();
        CurrentUser=[SELECT Id,CommunityNickname,Email,FirstName,LastName,Profile.Name FROM User WHERE Id=:UserId  Limit 1]; // NOPMD  Fix CRUD violation

        //MMOSCATELLI 25022019: ICF CR — START
        List<OrgWideEmailAddress> queriedAdd = new List<OrgWideEmailAddress>();
        FromObject FromObj = new FromObject();

        if((CurrentUser.Profile.Name).indexOf('AAI - Vendite')<>-1)
        {
        	FromObj.isUserAgent = true;
        	//OAVERSANO 06/03/2019 : ICF CR -- START
        	Boolean switchFromOrgWideAddress = false;
        	String OrgWideAddressID = '';
        	for(MPS_Code_Variables__c MPSCv: MPS_Code_Variables__c.getAll().values())
            {
                if((MPSCv.Name).contains('sendEmailCase_switchFromOrgWideAddress'))
                {
                	if(MPSCv.Value__c!=null && MPSCv.Value__c == 'true')
                	{
	                	switchFromOrgWideAddress = true;
                	}
                }
                if((MPSCv.Name).contains('sendEmailCase_FromAddressAgent'))
                {
                	if(MPSCv.Value__c!=null)
                	{
                		OrgWideAddressID = MPSCv.Value__c;
                	}
                }
                if((MPSCv.Name).contains('sendEmailCase_DefaultAgentTemplate'))
                {
                    if(MPSCv.Value__c!=null)
                    {
                        FromObj.DefaultTemplateId = MPSCv.Value__c;
                    }
                }
            }   
            if(switchFromOrgWideAddress)
            {
            	if(String.isNotBlank(OrgWideAddressID))
            	{
            		List<OrgWideEmailAddress> orgWideEmail = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Id =: OrgWideAddressID ]; // NOPMD  Fix CRUD violation
            		if(!orgWideEmail.isEmpty())
            		{
            			fromList.put(orgWideEmail[0].Address,orgWideEmail[0].DisplayName+'  -  <'+orgWideEmail[0].Address+'>');
            		}
            	}
            	FromObj.ccAddress = CurrentUser.Email;
            }
            else
            {            
            	fromList.put(CurrentUser.Email,CurrentUser.FirstName +' '+ CurrentUser.LastName+'  -  <'+CurrentUser.Email+'>');
            }
            //OAVERSANO 06/03/2019 : ICF CR -- END
        }
        //MMOSCATELLI 25022019: ICF CR — END
        
       // fromList.put(CurrentUser.Email,CurrentUser.FirstName +' '+ CurrentUser.LastName+'  -  <'+CurrentUser.Email+'>');

        //MMOSCATELLI 25022019: ICF CR — START
        if(!FromObj.isUserAgent)
        {
            queriedAdd = [SELECT Address,CreatedById,CreatedDate,DisplayName,Id,IsAllowAllProfiles,LastModifiedById,LastModifiedDate,SystemModstamp FROM OrgWideEmailAddress  ORDER BY DisplayName]; // NOPMD  Fix CRUD violation
            
            for (OrgWideEmailAddress f :queriedAdd)
            {
                fromList.put(f.Address,f.DisplayName+'  -  <'+f.Address+'>');
            }
        }

        //return fromList;
        FromObj.OrgWideAddrMap = fromList;
        
        return FromObj;
        //MMOSCATELLI 25022019: ICF CR — END
    }    

    @AuraEnabled 
    public static ResponseDto sendMailMethod(String recordId, List<String> toAddresses, List<String> CCAddresses, List<String> BCCAddresses,
                                      String selectedFrom, String mSubject, String mBody,List<String> attachmentIds){
        ResponseDto serverResponse = new ResponseDto();
        List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();     
        try{
            // EMAIL
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

            String contactId = null;
            String caseCheckStr = null;
            List<Case> caseList =[SELECT AccountId, Account.AAI_Agency_Reference_Code__c FROM Case WHERE Id = :recordId];
            if (caseList.size()>0)
            {
                String accountId = caseList[0].AccountId;
                List<Contact> contactList = [SELECT Id FROM Contact WHERE AccountId = :accountId];
                if (contactList.size()>0) 
                {
                    contactId = contactList[0].Id; //No multiple contacts in AXA
                    mail.setTargetObjectId(contactId);
                }

            }
            mail.setWhatId(recordId);
            mail.setTreatTargetObjectAsRecipient(false);
            mail.setSaveAsActivity(true);

            // TO FIELDS
            mail.setToAddresses(toAddresses);
            mail.setCcAddresses(CCAddresses);
            mail.setBccAddresses(BCCAddresses);

            // FROM
            String UserId=UserInfo.GetUserId();
            User CurrentUser = new User();
            CurrentUser=[SELECT Id,CommunityNickname,Email,FirstName,LastName,Profile.Name,IsPortalEnabled FROM User WHERE Id=:UserId  Limit 1]; // NOPMD  Fix CRUD violation
            String userMail = CurrentUser.Email;

            if (selectedFrom==userMail)
            {//Sent from current user
                //mail.setReplyTo(selectedFrom); 
                mail.setReplyTo(userMail);
                mail.setSenderDisplayName(CurrentUser.LastName+' '+CurrentUser.FirstName);             
            }else
            {//Sent from OWA
                OrgWideEmailAddress owa = [select id, Address, DisplayName from OrgWideEmailAddress where Address = :selectedFrom  limit 1]; // NOPMD  Fix CRUD violation
                mail.setOrgWideEmailAddressId(owa.id);
            }

            // CONTENT
            mail.setSubject(mSubject);
            mail.setHtmlBody(mBody);
            //ATTACHMENTS
            mail.setEntityAttachments(attachmentIds);
            // SEND
            mails.add(mail);
            //MMOSCATELLI 25022019: ICF CR — START
            //Messaging.sendEmail(mails);
            Messaging.SendEmailResult [] results = Messaging.sendEmail(mails);

            for(Messaging.SendEmailResult re : results)
            {
                if (re.success) 
                {
                    System.debug('The email was sent successfully.');

                    EmailMessage emailMsg = new EmailMessage(); // Created a EmailMessage and copy all details from above.

                    if(!CurrentUser.IsPortalEnabled)
                    {
                        emailMsg.FromAddress = selectedFrom;
                        emailMsg.FromName = mail.getSenderDisplayName();
                        emailMsg.ToAddress=listStringToSingle(mail.getToAddresses());
                        emailMsg.CcAddress=listStringToSingle(mail.getCCAddresses());
                        emailMsg.BCcAddress=listStringToSingle(mail.getBCCAddresses());
                        emailMsg.Subject=mSubject;
                        emailMsg.HtmlBody=mBody;
                        emailMsg.ParentId = recordId; //Attach with the case
                        emailMsg.MessageDate = system.now();
                        emailMsg.Status = '3';

                        insert emailMsg; // NOPMD  Fix CRUD violation
                    }

                    List<String> AttachmentNames = new List<String>();
                    List<ContentDocumentLink> newAttachList = new list<ContentDocumentLink>();
                    List<ContentDocumentLink> AttachListTORemove = new list<ContentDocumentLink>();
                    List<ContentDocument> DocumentsToDelete = new List<ContentDocument>();

                    if(attachmentIds.size()>0)
                    {
                        for(ContentDocumentLink CdL: [select Id, LinkedEntityId, ContentDocument.LatestPublishedVersion.Title, ContentDocumentid,IsDeleted, SystemModstamp, ShareType, Visibility from ContentDocumentLink where LinkedEntityId =:recordId and ContentDocument.LatestPublishedVersionId in:attachmentIds ]) // NOPMD  Fix CRUD violation
                        {
                            if(AttachmentNames.indexOf(CdL.ContentDocument.LatestPublishedVersion.Title)==-1)
                                AttachmentNames.add(CdL.ContentDocument.LatestPublishedVersion.Title);

                            if(!CurrentUser.IsPortalEnabled)
                            {
                                ContentDocumentLink UpdCdl = Cdl.clone();
                                UpdCdl.LinkedEntityId=emailMsg.Id;
                                UpdCdl.ShareType = 'V';
                                newAttachList.add(UpdCdl);
                                AttachListTORemove.add(Cdl);
                            }
                            ContentDocument contDoc = new ContentDocument(Id = CdL.ContentDocumentid);
                            DocumentsToDelete.add(contDoc);
                        }
                    } 

                    if(!CurrentUser.IsPortalEnabled)
                    {      
                        insert newAttachList; // NOPMD  Fix CRUD violation
                        delete AttachListTORemove; // NOPMD  Fix CRUD violation
                    }
                  /*  else
                        Database.delete(DocumentsToDelete);*/


                    Datetime currentDT = datetime.now();

                    Task emailTask = new Task();
                    emailTask.Subject = 'Email: '+mSubject;
                    emailTask.ActivityDate = Date.today();
                    String TaskDescription ='';// CurrentUser.FirstName+' '+CurrentUser.LastName+' '+currentDT+'\n';
                    TaskDescription = TaskDescription+'Mittente: '+selectedFrom+'\n';
                    TaskDescription = TaskDescription+'Destinatario: '+listStringToSingle(mail.getToAddresses())+'\n';
                    TaskDescription = TaskDescription+'Allegato: '+listStringToSingle(AttachmentNames)+'\n\n';
                    TaskDescription = TaskDescription+'Oggetto: '+mSubject+'\n';
                    TaskDescription = TaskDescription+'Corpo: '+mBody.stripHtmlTags()+'\n';
                    emailTask.Tipo_Attivit__c = 'Email';
                    emailTask.Type='Email';
                    emailTask.Description=TaskDescription;
                    emailTask.Status = 'Completed';

                    if(recordId!= null && recordId != '')
                    {
                        emailTask.WhatId = recordId;
                    }

                    //Database.insert(emailTask); //OAVERSANO 22/07/2019 fix email triplicate
                                                                           
                    serverResponse.isSuccess = true;
                    serverResponse.message = 'Email inviata';                  
                } 
                else 
                {
                    System.debug('The email failed to send: ' + re.errors[0].message);
                }
            }
            //MMOSCATELLI 25022019: ICF CR — END

            //CREATE TRACKING OBJECTS

            /*Datetime currentDT = datetime.now();

            Task emailTask = new Task();
            emailTask.Subject = 'Email: '+mSubject;
            emailTask.ActivityDate = Date.today();
            String TaskDescription ='';// CurrentUser.FirstName+' '+CurrentUser.LastName+' '+currentDT+'\n';
            TaskDescription = TaskDescription+'Additional To: '+listStringToSingle(mail.getToAddresses())+'\n';
            TaskDescription = TaskDescription+'CC: '+listStringToSingle(mail.getCCAddresses())+'\n';
            TaskDescription = TaskDescription+'BCC: '+listStringToSingle(mail.getBCCAddresses())+'\n';
            TaskDescription = TaskDescription+'Attachments: '+listStringToSingle(attachmentIds)+'\n\n';
            TaskDescription = TaskDescription+'Subject: '+mSubject+'\n';
            TaskDescription = TaskDescription+'Body: '+mBody+'\n';
            emailTask.Description=TaskDescription;
            emailTask.Status = 'Completed';
            if(recordId!= null && recordId != '')
            {
                emailTask.WhatId = recordId;
            }
            Database.insert(emailTask);

            //MOVE ATTACHMENTS
            if(attachmentIds.size()>0){
                List<Attachment> attachList = [SELECT Id, ParentId,Body,Name FROM Attachment WHERE Id in :attachmentIds];
                List<Attachment> newAttachList = new list<Attachment>();
                for (Attachment a :attachList)
                {
                    Attachment newAtt= a.clone(false, true, false, false);
                    newAtt.ParentId = emailMsg.Id;
                    newAttachList.add(newAtt);
                }
                Database.Insert (newAttachList);
                Database.delete(attachmentIds); 
            }
            serverResponse.isSuccess = true;
            serverResponse.message = 'Email inviata';*/

        }      
        catch (Exception e)
        {
            serverResponse.message= 'Si è verificato un errore nell\'invio della mail: '+e.getMessage();
        }
        return serverResponse;
    }

    @AuraEnabled
    public static ResponseDto deleteAttachments (List<String> attachmentIds, String recordId)
    {  
        //MMOSCATELLI 25022019: ICF CR — START
        //Database.delete(attachmentIds);
        List<ContentDocument> DocumentsToDelete = new List<ContentDocument>();
        
        if(attachmentIds.size()>0)
        {
            for(ContentDocumentLink CdL: [select ContentDocumentid from ContentDocumentLink where LinkedEntityId =:recordId and ContentDocument.LatestPublishedVersionId in:attachmentIds ]) // NOPMD  Fix CRUD violation
            {
                ContentDocument contDoc = new ContentDocument(Id = CdL.ContentDocumentid);
                DocumentsToDelete.add(contDoc);
            }
        } 

        try
        {
            delete DocumentsToDelete;
        }
        catch(exception ex)
        {
            system.debug('Error on delete: '+ex.getMessage());
        }
        //MMOSCATELLI 25022019: ICF CR — END
        
        ResponseDto serverResponse = new ResponseDto(true,'Attachments deleted');
        
        return serverResponse;        
    }  

    public static String listStringToSingle (List<String> currentList)
    {
        String returnString= '';
        for (String s :currentList)
        {
            returnString = returnString+s+';';
        }
        if(returnString.endsWith(';')) returnString.removeEnd(';');
        return returnString;

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
}