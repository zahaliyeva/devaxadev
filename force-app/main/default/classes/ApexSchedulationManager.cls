/*------------------------------------------------------------------------
Author:        Davide Fabris (Originally made by Lorenzo Santoro)
Company:       Deloitte
Class:         ApexSchedulationManager 
Description:   Class that supports the D-FLEX implementation. See custom Setting "Apex_Schedulation_Manager__c"
History
-06/06/2015   Davide Fabris - Created
----------------------------------------------------------------------------*/

public class ApexSchedulationManager {
    

     
    public static String getScheduleString(String minutes)
    {    
        Datetime SchedTime = Datetime.now();
        SchedTime=SchedTime.addMinutes(Integer.valueOf(minutes));
        
        String min = String.valueOf(SchedTime.minute());
        String hh = String.valueOf(SchedTime.hour());
        String dd = String.valueOf(SchedTime.day());
        String mm = String.valueOf(SchedTime.month());
        String yy = String.valueOf(SchedTime.year());
             
        return '0 ' + min + ' ' + hh + ' ' + dd + ' ' + mm + ' ? ' + yy;   
    }
        

    public static void sendMailPlus(User toUser, String attach_name, String attach_content, String subject, String mailContent)
    {
        blob attBlob = null;
        Messaging.EmailFileAttachment att = new Messaging.EmailFileAttachment();
        if (attach_name != null) {attBlob = Blob.valueOf(attach_content);}
        if (attach_name!= null) {att.setFileName(attach_name);
        att.setBody(attBlob);}
        Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
        email.setSubject(subject);
        email.setTargetObjectId(toUser.Id);
        email.saveAsActivity = false;
        email.setHtmlBody(mailContent);
        if (attach_name != null) {email.setFileAttachments(new Messaging.EmailFileAttachment[]{att});}
        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});      
    }        
        

}