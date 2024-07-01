//da modificare ed aggiungere altri campi d mails creati nel tempo

public class BatchSandboxAccount implements Database.Batchable<sObject> {

    public Database.QueryLocator start(Database.BatchableContext bc) {
      System.debug('BatchSandboxAccount.start');
      if(![SELECT IsSandbox FROM Organization].isSandbox && !Test.isRunningTest()){
          throw new DmlException('Clean Object only for Sandbox Environment');
      }
        return Database.getQueryLocator([SELECT Id, Account_email__c, Additional_Email__c, Agency_email__c, Claim_PersonalEmail__c, 
                                                Mail_Registrazione_Area_Clienti__c, 
                                                PersonEmail, PersonEmailBouncedReason, 
                                                Subject_email__c, Additional_Phone__c, Claim_PersonalMobile__c, Fax, 
                                                MobilePhone__c, PersonAssistantPhone, PersonHomePhone, 
                                                PersonMobilePhone, PersonOtherPhone, Phone, RecordType.DeveloperName 
                                         FROM Account 
                                         ORDER BY LastModifiedDate desc]);
    }
    
    public void execute(Database.BatchableContext bc, List<Account> accounts){
      System.debug('BatchSandboxAccount.execute');
        for(Account account: accounts) {
            System.debug('*** ACCOUNT RECORD TYPE: '+ account.RecordType.DeveloperName);
            account.Account_email__c = 'emailtestsfdcpre@dominiotest.axa ';
            account.Additional_Email__c = 'emailtestsfdcpre@dominiotest.axa ';
            account.Agency_email__c = 'emailtestsfdcpre@dominiotest.axa ';
            account.Claim_PersonalEmail__c = 'emailtestsfdcpre@dominiotest.axa ';
            account.Mail_Registrazione_Area_Clienti__c = 'emailtestsfdcpre@dominiotest.axa ';
            account.Subject_email__c = 'emailtestsfdcpre@dominiotest.axa ';
            account.Additional_Phone__c = '3470000000';
            account.Claim_PersonalMobile__c = '3470000000';
            account.Fax = '35000000';
            account.MobilePhone__c = '3470000000';
            account.Phone = '3470000000';
            /* ---- CAMPI CHE VANNO IN ERRORE ---- */
            //account.PersonAssistantPhone = '3470000000';
            //account.PersonHomePhone = '35000000';
            //account.PersonMobilePhone = '3470000000';
            //account.PersonOtherPhone = '3470000000';
            //account.PersonEmail = 'emailtestsfdcpre@dominiotest.axa ';
            //account.PersonEmailBouncedReason = 'emailtestsfdcpre@dominiotest.axa ';
            /* ----------------------------------- */
        }
        update accounts;
    }
    
    public void finish(Database.BatchableContext bc){
      System.debug('BatchSandboxAccount.finish');
    }
}