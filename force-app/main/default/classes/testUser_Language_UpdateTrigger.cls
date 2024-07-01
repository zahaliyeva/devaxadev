@isTest
private class testUser_Language_UpdateTrigger{
    static testMethod void testUser_Language_Update(){
        Profile prf = [Select id from Profile where name = 'System Administrator'];  
        test.startTest();
        User usr=new User(FirstName='Santhosh',LastName = 'Chinnas', Alias = 'schinnas', Email = 'schinnas@san.com', Username = 'schinnas@ins.deloitte.com', CommunityNickname = 'Sandy', LanguageLocaleKey = 'en_US',TimeZoneSidKey='Europe/Paris',Profileid = prf.Id,LocaleSidKey='en_US',EmailEncodingKey='ISO-8859-1');
        insert usr;
        
        usr = [select LanguageLocaleKey from User where id =: usr.Id];

        
       // Test that the trigger correctly updated the price
       usr.LanguageLocaleKey = 'nl_NL';
       update usr;
       usr.LanguageLocaleKey = 'en_US';
       update usr;
       usr.LanguageLocaleKey = 'fr';
       update usr;
       usr.LanguageLocaleKey = 'it';
       update usr;
       test.stopTest();
    }
}