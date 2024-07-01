@isTest
private class ZTestAdminManagement {
    
    @testSetup static void setup() {
        User adminU = new User(
                Alias = 'standt',
                Email = 'admin.standarduser@testorg.com.mailinator', 
                EmailEncodingKey = 'UTF-8',
                LastName = 'Testingadmin',
                LanguageLocaleKey = 'en_US', 
                LocaleSidKey = 'en_US',
                ProfileId = AP_Constants.getProfileAdminId(), 
                TimeZoneSidKey = 'America/Los_Angeles',
                UserName = 'admin.standarduser@testorg.com.mailinator');
        insert adminU;
        
        Profile mktgP = [SELECT Id FROM Profile WHERE Name = 'AAI - Marketing Avanzato' LIMIT 1]; 
        User mktgU = new User(
                Alias = 'stanmkt',
                Email = 'marketing.standarduser@testorg.com.mailinator', 
                EmailEncodingKey = 'UTF-8',
                LastName = 'Testingmarketing',
                LanguageLocaleKey = 'en_US', 
                LocaleSidKey = 'en_US',
                ProfileId = mktgP.Id, 
                TimeZoneSidKey = 'America/Los_Angeles',
                UserName = 'marketing.standarduser@testorg.com.mailinator');
        insert mktgU;
    }
    
    static testMethod void Test_EtlUserTest() {
        // check that the ETL User is not able to edit an Admin user
        Profile etlP = [SELECT Id FROM Profile WHERE Name = 'Integration ETL' LIMIT 1]; 
        User etlU = new User(
                Alias = 'standt',
                Email = 'etl.standarduser@testorg.com.mailinator', 
                EmailEncodingKey = 'UTF-8',
                LastName = 'Testingetl',
                LanguageLocaleKey = 'en_US', 
                LocaleSidKey = 'en_US',
                ProfileId = etlP.Id, 
                TimeZoneSidKey = 'America/Los_Angeles',
                UserName = 'etl.standarduser@testorg.com.mailinator');
        insert etlU;
        
        System.runAs(etlU) {
            List<User> userList = [SELECT Id, ProfileId, Username
                                   FROM User 
                                   WHERE Username = 'admin.standarduser@testorg.com.mailinator' OR Username = 'marketing.standarduser@testorg.com.mailinator'
                                   ORDER BY Username];
            try {
                userList = AdminManagement.checkListOfUsers(userList);
                User adminU3 = new User(
                        Alias = 'standt',
                        Email = 'admin3.standarduser@testorg.com.mailinator', 
                        EmailEncodingKey = 'UTF-8',
                        LastName = 'Testingadmin',
                        LanguageLocaleKey = 'en_US', 
                        LocaleSidKey = 'en_US',
                        ProfileId = AP_Constants.getProfileAdminId(), 
                        TimeZoneSidKey = 'America/Los_Angeles',
                        UserName = 'admin3.standarduser@testorg.com.mailinator');
                System.debug('### adminU3 ' + adminU3);
            
                insert adminU3;
            } catch (Exception e) {
                // the adminU3 should not be created
                List<User> userList2 = [SELECT Id, ProfileId, Username
                                       FROM User 
                                       WHERE Username = 'admin3.standarduser@testorg.com.mailinator' AND CreatedById =: etlU.Id];
                System.assertEquals(userList2.size(), 0);
            }
        }
    }
    
    static testMethod void Test_AdminUserTest() {
        // check that the Admin User is able to edit an Admin user
        Profile adminP = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1]; 
        User adminU = new User(
                Alias = 'standt',
                Email = 'admin2.standarduser@testorg.com.mailinator', 
                EmailEncodingKey = 'UTF-8',
                LastName = 'Testingadmin',
                LanguageLocaleKey = 'en_US', 
                LocaleSidKey = 'en_US',
                ProfileId = adminP.Id, 
                TimeZoneSidKey = 'America/Los_Angeles',
                UserName = 'admin2.standarduser@testorg.com.mailinator');
        insert adminU;
        
        System.runAs(adminU) {
            List<User> userList = [SELECT Id, ProfileId, Username
                                   FROM User 
                                   WHERE Username = 'admin.standarduser@testorg.com.mailinator' OR Username = 'marketing.standarduser@testorg.com.mailinator'
                                   ORDER BY Username];
            userList = AdminManagement.checkListOfUsers(userList);
            System.assertEquals(userList.size(), 2);
            System.assertEquals(userList[0].Username, 'admin.standarduser@testorg.com.mailinator');
            
            User adminU3 = new User(
                    Alias = 'standt',
                    Email = 'admin3.standarduser@testorg.com.mailinator', 
                    EmailEncodingKey = 'UTF-8',
                    LastName = 'Testingadmin',
                    LanguageLocaleKey = 'en_US', 
                    LocaleSidKey = 'en_US',
                    ProfileId = AP_Constants.getProfileAdminId(), 
                    TimeZoneSidKey = 'America/Los_Angeles',
                    UserName = 'admin3.standarduser@testorg.com.mailinator');
            insert adminU3;
            // the adminU3 should be created
            List<User> userList2 = [SELECT Id, ProfileId, Username
                                   FROM User 
                                   WHERE Username = 'admin3.standarduser@testorg.com.mailinator' AND CreatedById =: adminU.Id];
            System.assertEquals(userList2.size(), 1);
        }
    }
    
}