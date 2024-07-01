@IsTest
public class DIF_Events_ProbabiliDoppiSchedulerTest {
    

    @TestSetup
    static void makeData(){
        DIF_Events_ProbabiliDoppi_Batch_TEST.setup();
    }

    
    @IsTest
    static void testScheduler1(){
        Test.startTest();
        // This test runs a scheduled job at midnight Sept. 3rd. 2022
        Integer days = System.now().day() ;
        //String CRON_EXP = '0 0 0 '+days+' 3 ? 2022';
        Integer month = System.now().month();
        Integer year = System.now().year()+1;
        String CRON_EXP = '0 0 0 '+days+' '+month+' ? '+year;

        // Schedule the test job
        String jobId = System.schedule('DIF_Events_ProbabiliDoppiScheduler', CRON_EXP, new DIF_Events_ProbabiliDoppiScheduler1());
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

    @IsTest
    static void testScheduler2(){
        Test.startTest();
        // This test runs a scheduled job at midnight Sept. 3rd. 2022
        //String CRON_EXP = '0 0 0 '+days+' 3 ? 2022';
        Integer days = System.now().day();
        Integer month = System.now().month();
        Integer year = System.now().year()+1;
        String CRON_EXP = '0 0 0 '+days+' '+month+' ? '+year;
        // Schedule the test job
        String jobId = System.schedule('CampagnaInformativaBatchTest', CRON_EXP, new DIF_Events_ProbabiliDoppiScheduler2());
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

    @IsTest
    static void testScheduler3(){
        Test.startTest();
        // This test runs a scheduled job at midnight Sept. 3rd. 2022
        //String CRON_EXP = '0 0 0 '+days+' 3 ? 2022';
        Integer days = System.now().day() ;
        Integer month = System.now().month();
        Integer year = System.now().year()+1;
        String CRON_EXP = '0 0 0 '+days+' '+month+' ? '+year;
        // Schedule the test job
        String jobId = System.schedule('CampagnaInformativaBatchTest', CRON_EXP, new DIF_Events_ProbabiliDoppiScheduler3());
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