public class MobilityQuotazioniEcommerceController {
    
   @AuraEnabled
    public static String  getRTDevName(Id qId) {        
      return [SELECT RecordType.DeveloperName FROM Quotazione__c WHERE id =: qId LIMIT 1].RecordType.DeveloperName;       
    }

}