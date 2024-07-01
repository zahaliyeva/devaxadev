global class BatchSandboxLead implements Database.Batchable<sObject> {

    global Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('BatchSandboxLead.start');
        if(![SELECT IsSandbox FROM Organization].isSandbox && !Test.isRunningTest()){
              throw new DmlException('Clean Object only for Sandbox Environment');
        }
        return Database.getQueryLocator([SELECT Id, Fax, MobilePhone, Phone, Email, EmailBouncedReason, TECH_Lead_owner_email__c
                                         FROM Lead 
                                         ORDER BY LastModifiedDate desc]);
    }
    
    global void execute(Database.BatchableContext bc, List<Lead> leads){
        System.debug('BatchSandboxLead.execute');
        for(Lead l: leads) {
            l.Email = 'emailtestsfdcpre@dominiotest.axa';
            l.EmailBouncedReason = 'emailtestsfdcpre@dominiotest.axa';
            l.TECH_Lead_owner_email__c = 'emailtestsfdcpre@dominiotest.axa';
            l.Fax = '35000000';
            l.MobilePhone = '3470000000';
            l.Phone = '35000000';
        }
        update leads;
    }
    
    global void finish(Database.BatchableContext bc){
      System.debug('BatchSandboxLead.finish');
    }
}