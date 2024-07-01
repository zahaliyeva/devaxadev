@isTest
public class ContentDocumentLink_TEST {
    
    @testSetup static void setup() 
    {
      //MDANTONIO 09/04/2019 popolamento custom settings per classi di test - start
        ServiceUtilsClass.populateCustomSettingsForTests();
        //MDANTONIO 09/04/2019 popolamento custom settings per classi di test - end
        List<Profile> profiles = [SELECT Id, Name FROM Profile WHERE Name IN ('AAI - Supporto HD2 BIZ')];
        Id pHD2BIZ;
        if(profiles.size() > 0)
        {
            for(Profile p: profiles)
            {
                if(p.Name == 'AAI - Supporto HD2 BIZ')
                {
                    pHD2BIZ = p.Id;
                }
            }
        } 
        User HD2BIZ = new User(Username                     = 'supportHD2BIZ@axa.test.com',
                               LastName                     = 'testuserHD2BIZ',
                               LanguageLocaleKey            = 'it',
                               FirstName                    = 'testHD2BIZ',
                               Email                        = 'test@testHD2BIZ.com', 
                               Alias                        = 'testd',
                               TimeZoneSidKey               = 'Europe/Dublin',
                               LocaleSidKey                 = 'it_IT',
                               EmailEncodingKey             = 'UTF-8',
                               ProfileId                    = pHD2BIZ,
                               UserPermissionsKnowledgeUser = true);
        insert HD2BIZ;
    }
    
    static testMethod void testmethod1() 
    {
        User    HD2BIZ      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'supportHD2BIZ@axa.test.com' LIMIT 1];
        Case cCase = new Case(OwnerId= HD2BIZ.Id,Status = 'Open', Phone_Call_Ids__c='', Origin='Portale Assistenza', Category__c='ATR', SubCategory__c='', recordtypeid = [SELECT id from RecordType WHERE DeveloperName = 'Assistenza_Agenti'].Id);
        insert cCase;
        system.runAs(HD2BIZ)
        {
            Blob beforeblob=Blob.valueOf('Unit Test Attachment Body');
            
            ContentVersion cv = new ContentVersion();
            cv.title = 'test content trigger';           
			cv.PathOnClient = cv.title + '.' + 'CSV';			
            cv.VersionData =beforeblob;          
            insert cv;         
            
            ContentVersion testContent = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cv.Id];
            
            
            ContentDocumentLink contentlink=new ContentDocumentLink();
            contentlink.LinkedEntityId=cCase.id;
            contentlink.ShareType = 'V';
            contentlink.ContentDocumentId=testcontent.ContentDocumentId;
            insert contentlink;
        }
    }
    
}