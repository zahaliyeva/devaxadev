public with sharing class SchedaClienteVoiceCallController {
    
        @AuraEnabled
        public static List<VoiceCall> getVCall(String accountId) {
            return [SELECT Id, LOB__c, CreatedDate, FromPhoneNumber, Owner.Name, Gestione_Chiamata__c, IVR_Name__c from VoiceCall  where Account__c =:accountId order by CreatedDate desc LIMIT 5 ];
         
        }
    
    }