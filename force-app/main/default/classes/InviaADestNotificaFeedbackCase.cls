public  without sharing  class InviaADestNotificaFeedbackCase {
    
    @InvocableMethod(label = 'Invia Notifica a Split Account.Destinatario_notifica_Feedback_Case__c')
    public static void SendEmailNotification(List<PBInputs> request){
     
    try {
            
        System.debug('InviaADestNotificaFeedBackCase.SendEmailNotification START');  
        System.debug('InviaADestNotificaFeedBackCase.SendEmailNotification params request all in bulk' + request +' -size total -'+ request.size()); 

        String SenderID = [Select id from OrgWideEmailAddress where DisplayName='Agenzie AXA' limit 1].Id;

        List<String> ListTemplatesReq = new List<String>();
        Map<String,String> InternalMapTemplates = new Map<String,String> ();

        List<String> ListCaseAgenzias = new List<String>();
        Map<String,String> InternalCaseAgenzias = new Map<String,String> ();

        for(PBInputs request_pivot: request){ //for bulking add after deploy *-+ 05-12-2022 
            ListTemplatesReq.add(request_pivot.templateApiName);
            ListCaseAgenzias.add(request_pivot.caseObj.Agenzia__c);
        }
 
        List<EmailTemplate> emailTemplate = [Select Id,Subject,Body,HtmlValue,DeveloperName From EmailTemplate where DeveloperName in: ListTemplatesReq ];
        for(EmailTemplate email_pivot:emailTemplate){
            InternalMapTemplates.put(email_pivot.DeveloperName, email_pivot.Id);
        }
        
        System.debug('InternalMapTemplates** '+ InternalMapTemplates.toString());

        List<Account> acc = [Select Destinatario_notifica_Feedback_Case__c from Account where Id in: ListCaseAgenzias ];
        for(Account acc_pivot:acc){
            InternalCaseAgenzias.put(acc_pivot.Id, String.valueOf(acc_pivot.Destinatario_notifica_Feedback_Case__c));
        }
        System.debug('InternalCaseAgenzias** '+ InternalCaseAgenzias.toString());

        Map<String,String> MapAccountAndContacts = new Map<String,String> ();

        List<AggregateResult> contactList = [SELECT max(Id)Id,AccountId FROM Contact where AccountId in :InternalCaseAgenzias.keySet() group by AccountId ];
        for(AggregateResult contact_pivot: contactList){
            MapAccountAndContacts.put(String.valueOf(contact_pivot.get('AccountId')), String.valueOf(contact_pivot.get('Id')));
        }
        System.debug('MapAccountAndContacts** '+ MapAccountAndContacts.toString());

        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> ();

        for(PBInputs request_pivot: request){
            String AgencyToSendMainContact = request_pivot.caseObj.Agenzia__c;
            String DeveloperNameEmailTemplate = request_pivot.templateApiName;

            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();

            if (MapAccountAndContacts.keySet().size()>0 && String.isNotBlank(AgencyToSendMainContact))         
                message.setTargetObjectId(MapAccountAndContacts.get(AgencyToSendMainContact));
    
            message.setTreatTargetObjectAsRecipient(false);
            message.setsaveAsActivity(false);
            message.setTemplateID(InternalMapTemplates.get(request_pivot.templateApiName));  
            message.setWhatId(request_pivot.caseObj.Id);  
            message.toAddresses = InternalCaseAgenzias.get(AgencyToSendMainContact).split(';');
            message.setOrgWideEmailAddressId(SenderID);
                 
            messages.add(message);
        } 

        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages,false);

        for(Messaging.SendEmailResult sendedPivot:results ){
            if(sendedPivot.success)
            System.debug('InviaADestNotificaFeedBackCase.SendEmailNotification success-'+sendedPivot.success);
            else
            System.debug('InviaADestNotificaFeedBackCase.SendEmailNotification ERROR'+sendedPivot.getErrors());
        }

        System.debug('InviaADestNotificaFeedBackCase.SendEmailNotification END and OUT loop request');        
    }catch (Exception e){ 
        ApplicationLogHelper.ERROR('InviaADestNotificaFeedbackCase','InvocableMethod on PB: '+ e.getMessage(), e.getStackTraceString()); 
        }
    }
    
    
    
    
    //input details that comes to apex from Process Builder
    public class PBInputs{
        
        @InvocableVariable
        public Case caseObj;
        
        @InvocableVariable 
        public String templateApiName;
        
    }
}