/*-------------------------------------------------------------------------------------------------------------------------
Author:        Marco Moscatelli
Company:       Deloitte
Class:         AP15_NewSmartCenterUsrConfig_Batch_TEST
Description:   Test for the batch that associates the new Users created for the AMPS Smart Center to the CallCenter adapter
               developed from Content Guru
History

20/12/2016     Marco Moscatelli - Created
----------------------------------------------------------------------------------------------------------------------------*/
@isTest
public class AP15_NewSmartCenterUsrConfig_Batch_TEST 
{
	static User UserAdmin;
    static List<User> UserTest;
    static Id ProfileAdv;
    static Apex_Schedulation_Manager__c ASM_CS;
    static Id CallId;
    static list <New_SmartCenter_Users_Call_Center_Config__c> ConfList;
    
    static
    {
        ASM_CS= new Apex_Schedulation_Manager__c(
                                                Name='AP15_Test',
                                                Autoschedule__c=true,
                                                Expression__c='',
                                                Frequency__c=5,
                                                Scope__c=20,
                                                Send_Log__c=true
                                            );
        insert ASM_CS;
        
        userAdmin = new User(Username = 'testclassAdmAP15@test.com',
                            LastName = 'adminuser',
                            LanguageLocaleKey = 'en_US',
                            FirstName = 'test',
                            Email = 'test@test.com',
                            Alias = 'testadm',
                            TimeZoneSidKey = 'Europe/Dublin',
                            LocaleSidKey = 'en_US',
                            EmailEncodingKey = 'UTF-8',
                            ProfileId = AP_Constants.getProfileAdminId());
                        
        insert userAdmin;
        
        integer i=1;
        
        UserTest = new list<User>();
        
        for (Profile idprof:[Select Id from profile where name in ('SmartCenter Motor Advisor','SmartCenter Motor Manager','SmartCenter Non Motor Advisor','SmartCenter Non Motor Manager')])
        {      
            User UsTest = new User(Username = 'testclassAP15_'+String.valueOf(i)+'@test.com',
                            LastName = 'testuser'+String.valueOf(i),
                            LanguageLocaleKey = 'en_US',
                            FirstName = 'test',
                            Email = 'test'+String.valueOf(i)+'@test.com',
                            Alias = 'test',
                            TimeZoneSidKey = 'Europe/Dublin',
                            LocaleSidKey = 'en_US',
                            EmailEncodingKey = 'UTF-8',
                            ProfileId = idprof.id);
            
            UserTest.add(UsTest);
            
            i++;
        }
                        
        insert UserTest;  
        System.assertEquals('testclassAdmAP15@test.com',userAdmin.Username);       
    }
    
    static testMethod void testBatch()
    {
    	system.runAs(userAdmin)    
        {   
            test.startTest();
            
            ConfList = new list <New_SmartCenter_Users_Call_Center_Config__c>{
                															  new New_SmartCenter_Users_Call_Center_Config__c(name='1',
                                                                                                                             Profile_Name_Call_Center__c='SmartCenter Motor Advisor'),
                															  new New_SmartCenter_Users_Call_Center_Config__c(name='3',
                                                                                                                             Profile_Name_Call_Center__c='SmartCenter Motor Manager')                                                                              
            };
            insert ConfList;  
            

            
			AP15_NewSmartCenterUsrConfig_Batch B = new AP15_NewSmartCenterUsrConfig_Batch();
            //Database.ExecuteBatch(B);
           	String sch = ApexSchedulationManager.getScheduleString('1');
    		System.Schedule('AP15_NewSmartCenterUsrConfig_Batch_TEST', sch, B);
            
            test.stopTest();
            System.assertEquals('SmartCenter Motor Advisor', ConfList[0].Profile_Name_Call_Center__c); 
        }
    }
    
}