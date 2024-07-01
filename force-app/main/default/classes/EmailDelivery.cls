public class EmailDelivery implements Queueable {
    
    private String type;
    
    private List<SObject> targets;
    private String SenderDisplayName;
    private String ReplyToEmail;
    private Boolean saveAsActivity;
    private Boolean notifyErrors;
    private Integer transactionLimit;

    //TEMPLATE
    private EmailTemplate et;

    //HTML
    private String attach_name;
    private String attach_content;
    private String subject;
    private String mailContent;

    /*
        ATTENTION POINT: this class manages send email to only to User, Contact, Lead, or Person objects
        Sending Email with setTargetObjectId does not count against email limit
        This class uses Queueable Jobs so this limit is applied: https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_gov_limits.htm#asyncExecutionLimit
        If email is sent to Users the Boolean parameter "saveAsActivity" must be set to FALSE
    */


    /*
    USAGE CLASS EmailDelivery:

        //TYPE = 'TEMPLATE'
        String EmailTemplateName = 'CloseCase';
        EmailTemplate et = [select id from emailtemplate where developername =:EmailTemplateName];
        SObject toRecs = [select id, name, email from user where id = :UserInfo.getUserId()];
        //SObject toRecs = [select id, email from lead where id = '00Q7E00000C5307'];
        List<SObject> toSobj = new List<SObject>(); toSobj.add(toRecs); //toSobj.add(toRecs); toSobj.add(toRecs);
        Integer transactionLimit = 4;

        system.debug(toSobj.size());
        EmailDelivery ed = new EmailDelivery('TEMPLATE', toSobj, 'SenderDisplayName', 'do-not-reply@emailemail.email', false, false, transactionLimit, et, null, null, null, null);
        System.enqueueJob(ed);


        //TYPE = 'HTML'
        SObject toRecs = [select id, name, email from user where id = :UserInfo.getUserId()];
        //SObject toRecs = [select id, email from lead where id = '00Q7E00000C5307'];
        List<SObject> toSobj = new List<SObject>(); toSobj.add(toRecs); //toSobj.add(toRecs); toSobj.add(toRecs);
        Integer transactionLimit = 2;

        system.debug(toSobj.size());
        EmailDelivery ed = new EmailDelivery('HTML', toSobj, 'SenderDisplayName', 'do-not-reply@emailemail.email', false, false, transactionLimit, null, 'attach.txt', 'content attachement', 'email subject', 'email content');
        System.enqueueJob(ed);



    */
    public EmailDelivery(
                            String type, List<SObject> targets, String SenderDisplayName, String ReplyToEmail, boolean saveAsActivity, boolean notifyErrors, Integer transactionLimit, 
                            EmailTemplate et,
                            String attach_name, String attach_content, String subject, String mailContent
                        ) 
    {
  
        this.type = type;

        this.targets = targets;
        this.SenderDisplayName = SenderDisplayName;
        this.ReplyToEmail = ReplyToEmail;
        this.saveAsActivity = saveAsActivity;
        this.notifyErrors = notifyErrors;
        this.transactionLimit = transactionLimit;

        //TYPE = 'TEMPLATE'
        this.et = et;

        //TYPE = 'HTML'
        this.attach_name = attach_name;
        this.attach_content = attach_content;
        this.subject = subject;
        this.mailContent = mailContent;

    }

    /*
    USAGE METHOD sendMailTemplated:

        User toRecord = [select id, name, email from user where id = :UserInfo.getUserId()];
        String EmailTemplateName = 'CloseCase';
        EmailTemplate et = [select id from emailtemplate where developername =:EmailTemplateName];
        String SenderDisplayName = 'SenderDisplayName';
        String ReplyToEmail = 'do-not-reply@emailemailemail.it';
        Boolean saveAsActivity = false;
        Boolean notifyErrors = false;
        EmailDelivery.sendMailTemplated(toRecord, SenderDisplayName, ReplyToEmail, saveAsActivity, notifyErrors, et);

    */
    public static void sendMailTemplated(SObject targetObj, String SenderDisplayName, String ReplyToEmail, boolean saveAsActivity, boolean notifyErrors,
                                            EmailTemplate et )
    {

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setTargetObjectId(targetObj.get('id')+'');
        email.setTemplateId(et.id); 
        email.setSenderDisplayName(SenderDisplayName);
        email.setReplyTo(ReplyToEmail);
        email.saveAsActivity = saveAsActivity;

        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email}); 

        if (notifyErrors==true) 
        {
            EmailDelivery.notifyDeliveryErrors(r);
        }
             
    }

    /*
        List<User> toRecord = [select id, name, email from user where id = :UserInfo.getUserId()];
        String EmailTemplateName = 'CloseCase';
        EmailTemplate et = [select id from emailtemplate where developername =:EmailTemplateName];
        String SenderDisplayName = 'SenderDisplayName';
        String ReplyToEmail = 'do-not-reply@emailemailemail.it';
        Boolean saveAsActivity = false;
        Boolean notifyErrors = false;
        EmailDelivery.sendMailTemplatedList(toRecord, SenderDisplayName, ReplyToEmail, saveAsActivity, notifyErrors, et);
    */

    public static void sendMailTemplatedList(List<SObject> targetObjs, String SenderDisplayName, String ReplyToEmail, boolean saveAsActivity, boolean notifyErrors,
                                            EmailTemplate et )
    {

        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();

        for(SObject targetObj: targetObjs) 
        {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setTargetObjectId(targetObj.get('Id')+'');
            email.setTemplateId(et.id); 
            email.setSenderDisplayName(SenderDisplayName);
            email.setReplyTo(ReplyToEmail);
            email.saveAsActivity = saveAsActivity;  
            //Id theId = '00Q7E00000C6opR';
            //email.setWhatId(theId); SendEmail failed. First exception on row 0; first error: INVALID_ID_FIELD, WhatId is not available for sending emails to UserIds.
            mails.add(email);
        }

        Messaging.SendEmailResult [] r = Messaging.sendEmail(mails);
        
        if (notifyErrors==true) 
        {
            EmailDelivery.notifyDeliveryErrors(r);
        }
             
    }




    /*
    USAGE METHOD sendMailHtml:

        SObject toRecord = [select id, name, email from user where id = :UserInfo.getUserId()];
        String SenderDisplayName = 'SenderDisplayName';
        String ReplyToEmail = 'do-not-reply@emailemailemail.it';
        Boolean saveAsActivity = false;
        Boolean notifyErrors = false;
        String attach_name =  'attach.txt';
        String attach_content = 'content attachement'; 
        String subject = 'email subject';
        String mailContent = 'email content';
        EmailDelivery.sendMailHtml(toRecord, SenderDisplayName, ReplyToEmail, saveAsActivity, notifyErrors, attach_name, attach_content, subject, mailContent);

    */
    public static void sendMailHtml(SObject targetObj, String SenderDisplayName, String ReplyToEmail, boolean saveAsActivity, boolean notifyErrors,
                                                    String attach_name, String attach_content, String subject, String mailContent)
    {

        blob attBlob = null;
        Messaging.EmailFileAttachment att = new Messaging.EmailFileAttachment();
        if (attach_name != null) {attBlob = Blob.valueOf(attach_content);}
        if (attach_name!= null) {att.setFileName(attach_name);
        att.setBody(attBlob);}
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setSubject(subject);
        email.setTargetObjectId(targetObj.get('id')+'');
        email.setSenderDisplayName(SenderDisplayName);
        email.setReplyTo(ReplyToEmail);
        email.saveAsActivity = saveAsActivity;
        email.setHtmlBody(mailContent);
        if (attach_name != null) {email.setFileAttachments(new Messaging.EmailFileAttachment[]{att});}

        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        
        if (notifyErrors==true) 
        {
            EmailDelivery.notifyDeliveryErrors(r);
        }
     
    } 


    public static void sendMailHtmlList(List<SObject> targetObjs, String SenderDisplayName, String ReplyToEmail, boolean saveAsActivity, boolean notifyErrors,
                                                    String attach_name, String attach_content, String subject, String mailContent)
    {

        
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();

        for(SObject targetObj: targetObjs) 
        {
            blob attBlob = null;
            Messaging.EmailFileAttachment att = new Messaging.EmailFileAttachment();
            if (attach_name != null) {attBlob = Blob.valueOf(attach_content);}
            if (attach_name!= null) {att.setFileName(attach_name);
            att.setBody(attBlob);}
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setSubject(subject);
            email.setTargetObjectId(targetObj.get('id')+'');
            email.setSenderDisplayName(SenderDisplayName);
            email.setReplyTo(ReplyToEmail);
            email.saveAsActivity = saveAsActivity;
            email.setHtmlBody(mailContent);
            if (attach_name != null) {email.setFileAttachments(new Messaging.EmailFileAttachment[]{att});}
            mails.add(email);
        }
        Messaging.SendEmailResult [] r = Messaging.sendEmail(mails);
        
        if (notifyErrors==true) 
        {
            EmailDelivery.notifyDeliveryErrors(r);
        }
     
    } 

    public void execute(QueueableContext context)
    {
        
        system.debug('+++++this.targets: '+this.targets);

        List<Sobject> currentTargets = new List<SObject>();
        List<SObject> remainingTargets = new List<SObject>();

        Integer counter = 0;
        for (SObject u : this.targets) 
        {
            counter++; 
            if (counter <= transactionLimit)
            {
                currentTargets.add(u);
            }
            else
            {
                remainingTargets.add(u);
            }
        }

        if (this.type == 'TEMPLATE')
        {
            sendMailTemplatedList(currentTargets, this.SenderDisplayName , this.ReplyToEmail, this.saveAsActivity, this.notifyErrors,
                this.et);
        }
        else if (this.type == 'HTML')
        {
            sendMailHtmlList(currentTargets, this.SenderDisplayName , this.ReplyToEmail, this.saveAsActivity, this.notifyErrors,
                this.attach_name, this.attach_content, this.subject, this.mailContent);
        }

        if (remainingTargets.size()>0)
        {
            EmailDelivery edNew;

            if (this.type == 'TEMPLATE')
            {
                edNew = new EmailDelivery(this.type, remainingTargets, this.SenderDisplayName , this.ReplyToEmail , this.saveAsActivity, this.notifyErrors, this.transactionLimit, 
                    this.et, 
                    null, null, null, null);
            }
            else if (this.type == 'HTML')
            {
                edNew = new EmailDelivery(this.type, remainingTargets, this.SenderDisplayName , this.ReplyToEmail , this.saveAsActivity, this.notifyErrors, this.transactionLimit, 
                    null, 
                    this.attach_name, this.attach_content, this.subject, this.mailContent);
            }

            System.enqueueJob(edNew);
            
        }

    }

    //OK
    public static Set<Id> getUsersIdThatBelongsToGroup(Set<Id> groupIds)
    {

        Set<Id> UserIds = new Set<Id>();
        List<GroupMember> listGroupMember = [SELECT GroupId,Id,UserOrGroupId FROM GroupMember where GroupId in :groupIds];

        for (GroupMember gm : listGroupMember)
        {
            String left3 = (gm.UserOrGroupId+'').substring(0,3);
            if(left3!='00G')
            {
                UserIds.add(gm.UserOrGroupId);
            }
        }

        return UserIds;
    }

    /*
    Set<String> groupOrQueueDevNameSet = new Set<String> {'00G24000000S3iK'};
    List<SObject> usersReturn = EmailDelivery.getUsersThatBelongsToGroup(groupOrQueueDevNameSet);
    system.debug(usersReturn);
    */

    public static List<SObject> getUsersThatBelongsToGroup(Set<Id> ownersId)
    {

        List<SObject> usersReturn = new List<SObject>();

        Set<Id> UserIds  = new Set<Id>();
        Set<Id> GroupIds = new Set<Id>();

        for (String s : ownersId)
        {
            
            String left3 = s.substring(0,3);
            system.debug('++++left3:'+left3);
            if(left3!='00G')
            {
                UserIds.add(s);
                system.debug('++++ != OOG:');
            }
            else  
            {
                GroupIds.add(s);
                system.debug('++++ == OOG:');
            }
        }

        system.debug('++++++++++++UserIds'+UserIds);
        UserIds.addAll(EmailDelivery.getUsersIdThatBelongsToGroup(GroupIds));
        system.debug('++++++++++++UserIds'+UserIds);

        usersReturn = [select id, email,FirstName,LastName from user where id in : UserIds and IsActive = true];
        return usersReturn; 

    }


    public static void notifyDeliveryErrors(List<Messaging.SendEmailResult> results)
    {   
        String senderrors = '';
        Boolean needSend = false;
        for (Messaging.SendEmailResult res : results)
        { 
            senderrors += res.getErrors();
            if (res.getErrors().size()>0)
            {
                needSend = true;
            }
        } 
        if (needSend==true)
        {
            EmailDelivery.sendMailHtml(new User(id=UserInfo.getUserId()), 'message@undelivered.errors', 'do-not-reply@messageundelivered.errors', false, false, 'errors.txt', senderrors, 'send fails', 'see attachment for detail'); 
        }
    }

    
   
    
    
    
}