public with sharing class NFE_CrmSendEmailCase {

    @AuraEnabled
    public static String getToAddress(String caseId) {

        String toAddress = '';
        List<Case> cases = [SELECT SuppliedEmail, AccountId
                            FROM Case
                            WHERE Id = :caseId
                            LIMIT 1];
        if (cases != null && !cases.isEmpty() && cases[0].AccountId != null) {
            List<Account> accLst =[SELECT Id, RecordTypeId,Additional_Email__c,PersonEmail,Account_email__c,Subject_email__c,IsPersonAccount,CIF_PersonalEmail__c,CIF_Work_email__c,CIF_PersonEmail__c,Claim_PersonalEmail__c,RecordType.DeveloperName,AAI_Agency__c,AAI_Agency__r.Agency_email__c,AAI_Agency_Reference_Code__c
                                   FROM Account
                                   WHERE Id = :cases[0].AccountId
                                   LIMIT 1];
            User CurrentUser = [SELECT IsPortalEnabled,Email FROM User WHERE Id = :UserInfo.getUserId()];
            toAddress = VFC14_SendEmailView.setToAddress(accLst, CurrentUser.IsPortalEnabled, cases[0]);
        }
        System.debug('ToAddress ' + toAddress);
        return toAddress;

    }

}