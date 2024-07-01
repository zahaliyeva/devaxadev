public with sharing class LghtCaseCommunicationsController extends RLY_Behaviour {

	public class LghtCaseCommunicationsException extends Exception {}

	public class CommunicationsData extends LghtResponse{
		@AuraEnabled public List<CommunicationData> elements = new List<CommunicationData>();
    }
    
    public class CommunicationData{
        @AuraEnabled public String Id;
        @AuraEnabled public String Image;
        @AuraEnabled public Datetime StartDate;
        @AuraEnabled public String Type;
        @AuraEnabled public String TypeLabel;
        @AuraEnabled public String SObjectName;
        @AuraEnabled public String Channel;
        @AuraEnabled public String Sender;
        @AuraEnabled public String Recipient;
        @AuraEnabled public String CustomerType;
        @AuraEnabled public SObject ObjectData;
    }
    
    @AuraEnabled
    public static CommunicationsData getCommunications(String recordId){
        DebugStart('LghtCaseCommunicationsController', 'getCommunications');
        Debug('recordId', recordId);

        CommunicationsData response = new CommunicationsData();

        try{
            String staticResoucePath = LghtCaseCommunicationsController.getStaticResoucePath('lghtCaseCommunications');

            Case caseTemp = [
                SELECT id, Owner.Name
                FROM Case
                WHERE id = :recordId
            ];
            /**
             * Storico Conversazioni
             */
            List<Storico_conversazioni__c> storicoConversazioni = [
                SELECT id, Description__c, CreatedDate, CreatedBy.Name, Owner.Name, Tech_Profilo_Utente__c 
                FROM Storico_conversazioni__c  
                WHERE Connected_case__c = :recordId
            ];

            for(Storico_conversazioni__c element : storicoConversazioni){
                CommunicationData elementAdd = new CommunicationData();
                elementAdd.Id = element.Id;
                elementAdd.Type = 'Storico Conversazioni';
                elementAdd.TypeLabel = 'Commento Case';
                elementAdd.SObjectName = 'Storico_conversazioni__c';
                elementAdd.StartDate = element.CreatedDate;
                elementAdd.Channel = element.Description__c;
                elementAdd.Sender = element.CreatedBy.Name;
                elementAdd.Recipient = element.Tech_Profilo_Utente__c;
                elementAdd.Image = staticResoucePath + '/comments.png';
                elementAdd.ObjectData = element;

                response.elements.add(elementAdd);
            }
                        
            /**
             * Email Message
             */
            List<EmailMessage> emailMessage = [
                SELECT id, CreatedDate, CreatedBy.Name, TextBody, FromName, ToAddress 
                FROM EmailMessage
                WHERE ParentId = :recordId
            ];

            for(EmailMessage element : emailMessage){
                CommunicationData elementAdd = new CommunicationData();
                elementAdd.Id = element.Id;
                elementAdd.Type = 'Email Message';
                elementAdd.TypeLabel = 'Email';
                elementAdd.SObjectName = 'EmailMessage';
                elementAdd.StartDate = element.CreatedDate;
                elementAdd.Channel = element.TextBody;
                elementAdd.Sender = element.FromName;
                elementAdd.Recipient = element.ToAddress;
                elementAdd.Image = staticResoucePath + '/email.png';
                elementAdd.ObjectData = element;

                response.elements.add(elementAdd);
            }

            /**
             * Live Chat Transcript
             */
            List<LiveChatTranscript> liveChatTranscripts = [
                SELECT id, CreatedDate, CreatedBy.Name, Contact.Name, Owner.Name, Body  
                FROM LiveChatTranscript
                WHERE Case.Id = :recordId
            ];

            for(LiveChatTranscript element : liveChatTranscripts){
                CommunicationData elementAdd = new CommunicationData();
                elementAdd.Id = element.Id;
                elementAdd.Type = 'Live Chat Transcript';
                elementAdd.TypeLabel = 'Chat';
                elementAdd.SObjectName = 'LiveChatTranscript';
                elementAdd.StartDate = element.CreatedDate;
                elementAdd.Channel = element.Body;
                elementAdd.Sender = element.Contact.Name;
                elementAdd.Recipient = element.Owner.Name;
                elementAdd.Image = staticResoucePath + '/chat.png';
                elementAdd.ObjectData = element;

                response.elements.add(elementAdd);
            }

            /**
             * Storico Chiamate
             */
            List<Storico_Chiamate__c> storicoChiamate = [
                SELECT id, CreatedDate, Agente__r.Name, Owner.Name 
                FROM Storico_Chiamate__c
                WHERE Case__c = :recordId
            ];

            for(Storico_Chiamate__c element : storicoChiamate){
                CommunicationData elementAdd = new CommunicationData();
                elementAdd.Id = element.Id;
                elementAdd.Type = 'Storico Chiamate';
                elementAdd.TypeLabel = 'Chiamata';
                elementAdd.SObjectName = 'Storico_Chiamate__c';
                elementAdd.StartDate = element.CreatedDate;
                elementAdd.Channel = '';
                elementAdd.Sender = element.Agente__r.Name;
                elementAdd.Recipient = element.Owner.Name;
                elementAdd.Image = staticResoucePath + '/phone.png';
                elementAdd.ObjectData = element;

                response.elements.add(elementAdd);
            }

            /**
             * Communications to Customer
             */
            List<Communications_to_customer__c> communicationsToCustomer = [
                SELECT Id, CreatedDate, Message__c, Communication_Description__c, CreatedBy.Name, AccountId__r.Name, Tipologia_Destinatario__c, Process__c
                FROM Communications_to_customer__c 
                WHERE CaseId__c = :recordId
            ];

            Datetime dateCtC = communicationsToCustomer[0].CreatedDate;
            List<Milestone_Tracking__c> milestonTracking = [
                SELECT Id, Case_Owner_Name__c
                FROM Milestone_Tracking__c
                WHERE Case__c = :recordId AND (SupportStartDate__c < :dateCtC AND (SupportEndDate__c < :dateCtC OR SupportEndDate__c = null))	
            ];

            for(Communications_to_customer__c element : communicationsToCustomer){
                CommunicationData elementAdd = new CommunicationData();
                elementAdd.Id = element.Id;
                elementAdd.Type = 'SMS';
                elementAdd.TypeLabel = 'SMS';
                elementAdd.SObjectName = 'Communications_to_customer__c';
                elementAdd.StartDate = element.CreatedDate;
                if(element.Process__c == 'HALLMARKS'){
                elementAdd.Channel = element.Communication_Description__c;
                }else{
                elementAdd.Channel = element.Message__c;
                }
                if(element.Process__c == 'HALLMARKS'){
                elementAdd.Sender = milestonTracking[0].Case_Owner_Name__c;
                }else{
                elementAdd.Sender = element.CreatedBy.Name;
                }
                elementAdd.Recipient = element.AccountId__r.Name;
                elementAdd.CustomerType = element.Tipologia_Destinatario__c;
                elementAdd.Image = staticResoucePath + '/sms.png';
                elementAdd.ObjectData = element;

                response.elements.add(elementAdd);
            }

            response.isSuccess = true;
        }catch(LghtCaseCommunicationsException ex){
            response.errorMessage = ex.getMessage();
        }catch(Exception ex){
            response.errorMessage = ex.getMessage();
        }

        Debug('response', response);
        DebugEnd();
        return response;
    }

    public static String getStaticResoucePath(String name){

        StaticResource static_resource = [
            SELECT Id, Name, SystemModStamp                      
            FROM StaticResource 
            WHERE Name = :name
            LIMIT 1
        ];

        return '/resource/' + String.valueOf(((DateTime)static_resource.get('SystemModStamp')).getTime()) + '/' + static_resource.get('Name');
    }
}