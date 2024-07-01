public  without sharing  class EmailNotificationAgenzia {
    
    @InvocableMethod(label = 'Invio Notifica a Coda Agenzia')
    public static void SendEmailNotification(List<PBInputs> request){

    try { //for exc add after *-+ 05-12-2022 
            
        System.debug('Invio Notifica a Coda Agenzia.SendEmailNotification START');  
        System.debug('Invio Notifica a Coda Agenzia.SendEmailNotification params request all in bulk' + request +' -size total -'+ request.size()); 
  
        String SenderID = [Select id from OrgWideEmailAddress where DisplayName='Agenzie AXA' limit 1].Id;
        EmailTemplate emailTemplate_sinistri = [Select Id,Subject,Body,HtmlValue From EmailTemplate where DeveloperName ='Avviso_assegnazione_case_verso_Agente_Da_Advisor_Sinistri_In'];
    

        List<String> ListTemplatesReq = new List<String>();
        Map<String,String> InternalMapTemplates = new Map<String,String> ();

        List<String> ListCaseAgenzias = new List<String>();
        Map<String,String> InternalCaseAgenzias = new Map<String,String> ();

        List<String> ListCaseOwner = new List<String>();
        List<String> ListUsersIdsQueuemembers = new List<String>();
        Map<String,String> InternalMapQueueMembers = new Map<String,String> ();
        Map<String,String> MapQueueMembersEmails = new Map<String,String> ();
        Map<String,String> MapMailsByQueueEnd = new Map<String,String> ();

        for(PBInputs request_pivot: request){  //for bulking add after deploy *-+ 05-12-2022 
            ListTemplatesReq.add(request_pivot.templateApiName);
            ListCaseAgenzias.add(request_pivot.caseObj.Agenzia__c);
            ListCaseOwner.add(request_pivot.caseObj.OwnerId);// deve essere una CODA queue 
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

        List<GroupMember> ListGroupMembersAll = [Select UserOrGroupId,GroupID from GroupMember where GroupID in: ListCaseOwner];
        for(GroupMember groupMember_pivot: ListGroupMembersAll){

            if(String.valueOf(groupMember_pivot.UserOrGroupId).startsWithIgnoreCase('005'))  {  // for mapping Queue, and List of User Ids
                if(InternalMapQueueMembers.containsKey(groupMember_pivot.GroupID)){
                    String tempBuffer = InternalMapQueueMembers.get(groupMember_pivot.GroupID);
                    tempBuffer += groupMember_pivot.UserOrGroupId + ',';
                    InternalMapQueueMembers.put(groupMember_pivot.GroupID, tempBuffer);
                }
                else {
                    String tempBuffer = '';
                    tempBuffer += groupMember_pivot.UserOrGroupId + ',';
                    InternalMapQueueMembers.put(groupMember_pivot.GroupID, tempBuffer);
                }
            ListUsersIdsQueuemembers.add(groupMember_pivot.UserOrGroupId); //for query emails of all users
            }
        }

        List<User> GroupMemberList = [Select id, email from user where id in:ListUsersIdsQueuemembers and isActive = true];
        for(User user_pivot: GroupMemberList){
            MapQueueMembersEmails.put(user_pivot.Id, user_pivot.email);
        }
        //mail a tutti user dentro una queue
        for(String queueId_pivot:InternalMapQueueMembers.keySet()){
            String tempBufferEmails = '';
            for(String userId_pivot:MapQueueMembersEmails.keySet()){
                if(InternalMapQueueMembers.get(queueId_pivot).containsIgnoreCase(userId_pivot)){
                    tempBufferEmails += MapQueueMembersEmails.get(userId_pivot) + ';';
                }
            }
            MapMailsByQueueEnd.put(queueId_pivot, tempBufferEmails);
        }


        Map<String,String> MapAccountAndContacts = new Map<String,String> ();

        List<AggregateResult> contactList = [SELECT max(Id)Id,AccountId FROM Contact where AccountId in :InternalCaseAgenzias.keySet() group by AccountId ];
        for(AggregateResult contact_pivot: contactList){
            MapAccountAndContacts.put(String.valueOf(contact_pivot.get('AccountId')), String.valueOf(contact_pivot.get('Id')));
        }
        System.debug('MapAccountAndContacts** '+ MapAccountAndContacts.toString());

        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> ();

        for(PBInputs request_pivot: request){
            String AgencyToSendMainContact = request_pivot.caseObj.Agenzia__c;
            String OwnerCaseQueue = request_pivot.caseObj.OwnerId;
            String DeveloperNameEmailTemplate = request_pivot.templateApiName;
            String GroupEmailQueue = request_pivot.GroupMail;

            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();

            if(String.isNotEmpty(MapMailsByQueueEnd.get(OwnerCaseQueue)) || String.isNotEmpty(GroupEmailQueue)){
                List<String> emails = new List<String>();

                if(String.isNotEmpty(GroupEmailQueue))
                    emails.add(GroupEmailQueue);
                
                if(String.isNotEmpty(MapMailsByQueueEnd.get(OwnerCaseQueue)))    
                    emails.addAll(MapMailsByQueueEnd.get(OwnerCaseQueue).split(';'));
    
                if (MapAccountAndContacts.keySet().size()>0 && String.isNotBlank(AgencyToSendMainContact))         
                    message.setTargetObjectId(MapAccountAndContacts.get(AgencyToSendMainContact));
                
                message.setTreatTargetObjectAsRecipient(false);
                message.setsaveAsActivity(false);
                message.setTemplateID(InternalMapTemplates.get(DeveloperNameEmailTemplate));  
                message.setWhatId(request_pivot.caseObj.Id);        
                message.setOrgWideEmailAddressId(SenderID);        
                message.setToAddresses(emails);
    
                // last update 04-11-2021 after chang categry cases *-+
                if(request_pivot.caseObj.Category__c == 'SINISTRI_CHECK_IN' || request_pivot.caseObj.Category__c == 'Sinistri Check IN'  )
                    message.setTemplateID(emailTemplate_sinistri.Id); 
                
                messages.add(message);
                  
            }
        }
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages,false);
         
        for(Messaging.SendEmailResult sendedPivot:results ){
            if (sendedPivot.success)             
            System.debug('InviaADestNotificaFeedBackCase.SendEmailNotification The email was sent successfully.'+sendedPivot.success);
            else 
            System.debug('InviaADestNotificaFeedBackCase.SendEmailNotification The email failed to send: '+sendedPivot.getErrors());

        }

        System.debug('InviaADestNotificaFeedBackCase.SendEmailNotification END');  
    }catch (Exception e){ 
        ApplicationLogHelper.ERROR('EmailNotificationAgenzia','InvocableMethod on PB: '+ e.getMessage(), e.getStackTraceString()); 
        }
    }
    
    
    
    
    //input details that comes to apex from Process Builder
    public class PBInputs{
        
        @InvocableVariable
        public Case caseObj;
        
        @InvocableVariable 
        public String templateApiName;
        
        @InvocableVariable
        public String GroupMail;
    }
}