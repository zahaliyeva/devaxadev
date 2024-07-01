@isTest 
private class CampagnaInformativaStopCartaBatchTest {
    
    @TestSetup
    static void setup(){
        Id recordTypeId = RecordTypeUtility.getRecordTypeIdByDeveloperName('Account', 'B2B_Client');
        Account accountOK = new Account(Name = 'Account OK', RecordTypeId = recordTypeId);
        insert accountOK;
        Contact contact = new Contact(AccountId = accountOK.Id, LastName='Contact OK');
        insert contact;
        Account accountKO = new Account(Name = 'Account KO', RecordTypeId = recordTypeId);
        insert accountKO;
        insert new Massive_Communication__c(Type__c = 'Paper', PrivacyEmail__c = 'nd', Status__c='Pending',Tech_status_update_date__c=system.today().addDays(-7), Account__c = accountOK.id);
        insert new Massive_Communication__c(Type__c = 'Paper', PrivacyEmail__c = 'nd', Status__c='Pending',Tech_status_update_date__c=system.today().addDays(-7), Account__c = accountKO.id);
    }

    @IsTest 
    static void testBatchOK(){ 
        test.startTest();
        database.executeBatch(new CampagnaInformativaStopCartaBatch());
        test.stopTest();
        Account account = [SELECT Id FROM Account WHERE Name = 'Account OK'];
        Massive_Communication__c communication = [Select Contact__c from Massive_Communication__c where Account__c = :account.Id limit 1];
        System.assertEquals(true, String.isNotBlank(communication.Contact__c), 'Contatto valorizzato correttamente');
    }

    
    @IsTest 
    static void testBatchKO(){ 
        test.startTest();
        database.executeBatch(new CampagnaInformativaStopCartaBatch());
        test.stopTest();
        Account account = [SELECT Id FROM Account WHERE Name = 'Account OK'];
        Massive_Communication__c communication = [Select Contact__c, Log__c from Massive_Communication__c where Account__c != :account.Id limit 1];
        System.assertEquals(true, String.isBlank(communication.Contact__c), 'Contatto non valorizzato');
        System.assertEquals(true, 'Campagna Informativa StopCarta: Massive_Communication__c.Account__r.Contact non valorizzato'.equals(communication.Log__c), 'Contatto non valorizzato');
    }

    @IsTest
    static void testScheduler(){
        Test.startTest();
        // This test runs a scheduled job at midnight Sept. 3rd. 2022
        //String CRON_EXP = '0 0 0 '+days+' 3 ? 2022';
        Integer days = System.now().day();
        Integer month = System.now().month();
        Integer year = System.now().year()+1;
        String CRON_EXP = '0 0 0 '+days+' '+month+' ? '+year;
        // Schedule the test job
        String jobId = System.schedule('CampagnaInformativaBatchTest', CRON_EXP, new CampagnaInformativaStopCartaBatch());
        // Get the information from the CronTrigger API object 
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId]; 
        // Verify the expressions are the same System.assertEquals(CRON_EXP, ct.CronExpression); 
        // Verify the job has not run 
        System.assertEquals(0, ct.TimesTriggered, 'Job has not run'); 
        // Verify the next time the job will run 
        String String_month = String.valueOf(month).length()==1 ? '0'+String.valueOf(month) : String.valueOf(month);
        String String_days = String.valueOf(days).length()==1 ? '0'+String.valueOf(days) : String.valueOf(days);
        System.assertEquals(year+'-'+String_month+'-'+String_days+' 00:00:00', String.valueOf(ct.NextFireTime), 'Job will run'); 
        Test.stopTest();       
    }
}