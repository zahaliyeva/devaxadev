public without sharing class InsertAMLEmailMessage {
    
    @InvocableMethod(label ='Insert AML Email Message')    
    public static void insertMessage(List<Case> cases){
        System.debug('Insert Email Message Start');
        List<EmailMessage> ems = new List<EmailMessage>();
        ApexComponent ac = [SELECT id, name, Markup FROM ApexComponent WHERE Name = 'AMLEmailTemplateComponent'];
        List<Id> ContactIds = new List<Id>();        
        for(Case c : cases){
            if(c.ContactId != null){
                ContactIds.add(c.ContactId);
            }   
        }
        Email_Template_Configuration__mdt aml_Reminder_Email = Email_Template_Configuration__mdt.getInstance('AML_Reminder_Email');
        
        List<Contact> contacts = [SELECT id, Name FROM Contact WHERE id in: ContactIds];
        for(Case c: cases){
            EmailMessage em = new EmailMessage();
            em.Subject = aml_Reminder_Email.Subject__c + c.TECHThreadId__c;
            em.FromAddress = aml_Reminder_Email.FromAddress__c;
            em.fromName = aml_Reminder_Email.fromName__c;
            em.ToAddress = c.SuppliedEmail;
            em.ParentId = c.id;
            ems.add(em);
            if(contacts.size() > 0 ){
            for(Contact co : contacts){
                if(c.ContactId != null){
                    if(c.ContactId == co.Id){
                        em.HtmlBody = ac.Markup.replace('{!thisCase.Contact.Name}', co.Name);
                    }
                } else {
                   em.HtmlBody = ac.Markup.replace('{!thisCase.Contact.Name}', '');
                }
            }
        } else {
            em.HtmlBody = ac.Markup.replace('{!thisCase.Contact.Name}', '');
        }
        }  
        if(ems.size()>0)
            insert ems;
        System.debug('Email Messages Created: ' + ems);
    }
}