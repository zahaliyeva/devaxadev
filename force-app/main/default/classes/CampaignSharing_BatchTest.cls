@isTest
public class CampaignSharing_BatchTest {

    @testSetup 
    static void Method1(){

    Id rtByName = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Marketing_campaign').getRecordTypeId();
	
        
    Campaign cp = new Campaign(
            Name = 'CampagnaTest',
            IsActive = true,
            Status = 'On-going',
            RecordTypeID = rtByName,
            TECH_CampagnaLavorata__c = 'Da Lavorare',
            StartDate = Date.today(),
            EndDate = Date.today()+3,
        	Agencies_in_Target__c = '001622;001622000123;001622000124;001622000125'
        );
        insert cp;
    }
    @isTest
  	public static void execBatch() 
	{
        Test.startTest();
        CampaignSharing_Batch batch = new CampaignSharing_Batch();
        Database.executeBatch(batch, 200);
        Test.stopTest();  
        
        
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
        String jobId = System.schedule('Run_Batch_Campaign_Sharing', CRON_EXP, new CampaignSharing_Batch());
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