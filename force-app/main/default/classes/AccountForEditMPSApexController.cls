public with sharing class AccountForEditMPSApexController {
   
    public class GetDataDTO {
        @AuraEnabled
        public String Name = ' NAME ';
        @AuraEnabled
        public String FirstName = ' NAME ';
        @AuraEnabled
        public String LastName = 'LastName';
    }
    /**Constructor VOID */
    public AccountForEditMPSApexController() {

    }

    @AuraEnabled
    public static GetDataDTO getAccountData(Id recordId){
        System.debug('### recordId: ' + recordId);
        try {
            
            Account queriedAccount = [SELECT Name, Additional_Email__c, Additional_Phone__c, Additional_Comments__c  
                                        FROM Account 
                                             where id = :recordId limit 1];


            GetDataDTO response = new GetDataDTO();

            if(String.isNotBlank(queriedAccount.Name)){
                response.Name = queriedAccount.Name;
                /*response.FirstName = queriedAccount.FirstName;
                response.LastName = queriedAccount.LastName;*/
            }
 
            return response;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}