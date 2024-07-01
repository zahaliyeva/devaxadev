trigger SendEmail on SendEmail__e(after insert) {

    Id supportoSicurezzaOrgWideEmailAddressId = [select id, Address, DisplayName from OrgWideEmailAddress where DisplayName = 'Servizio Clienti AXA Assicurazioni' and Address = 'infoaxa@axa.it' LIMIT 1].Id;
    EmailTemplate emailTemplate = [select Id, Subject, HtmlValue, Body, DeveloperName from EmailTemplate where DeveloperName = 'File_Upload_Security'];

    for(SendEmail__e event : Trigger.new){
        if('Invalid Extension'.equalsIgnoreCase(event.Type__c)){
            Messaging.reserveSingleEmailCapacity(1);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
      
            String[] toAddresses = new String[] {event.Recipient__c}; 
            mail.setToAddresses(toAddresses);  
    
            mail.setSubject(emailTemplate.Subject);

            String htmlBody = emailTemplate.HtmlValue;
            htmlBody = htmlBody.replace('{!TextBody}', event.CaseSubjectReference__c);
            htmlBody = htmlBody.replace('{!AttachmentName}', event.AttachmentName__c);

            String plainBody = emailTemplate.Body;
            plainBody = plainBody.replace('{!TextBody}', event.CaseSubjectReference__c);
            plainBody = plainBody.replace('{!AttachmentName}', event.AttachmentName__c);
 
            mail.setHtmlBody(htmlBody);
            mail.setPlainTextBody(plainBody);
    
            mail.setOrgWideEmailAddressId(supportoSicurezzaOrgWideEmailAddressId);

            // Send the email you have created.
            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {mail};
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            if (results[0].success) {
                System.debug('The email was sent successfully.');
            } else {
                System.debug('The email failed to send: '
                    + results[0].errors[0].message);
            }
        }
    }
}