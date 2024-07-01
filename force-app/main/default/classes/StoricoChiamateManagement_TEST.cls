/**
 * Created by Augens on 20/11/2018.
 */

@IsTest
public class StoricoChiamateManagement_TEST {
    
    //MDANTONIO 09/04/2019 popolamento custom settings per classi di test - start
    @testSetup static void setup(){
        ServiceUtilsClass.populateCustomSettingsForTests();
    }
    //MDANTONIO 09/04/2019 popolamento custom settings per classi di test - end

    @IsTest static void afterInsertTriggerTest(){
        Profile p =  [SELECT Id FROM Profile WHERE Name='SmartCenter AMF Advisor - Lightning'];
        User u = new User( Alias = 'guest',
                            Email='SmartCenter@testorg.com',
                            LastName='Testing',
                            FirstName = 'test',
                            LanguageLocaleKey='en_US',
                            EmailEncodingKey='UTF-8',
                            TimeZoneSidKey = 'Europe/Dublin',
                            LocaleSidKey='en_US',
                            ProfileId = p.Id,
                            UserName='testStoricCallInsert@italy.axa.test.com',
                            CommunityNickname='tst');
        insert u;
        Account a = new Account(Name = 'accTest',
                               OwnerId = u.Id);
            insert a;
        
        System.runAs(u){
            
            Case c = new Case(Category__c='Auto');
            insert c;
            Storico_Chiamate__c sc = new Storico_Chiamate__c(Case__c = c.Id,
                                                             Customer__c = a.Id);
            Test.startTest();
                Database.SaveResult result = Database.insert(sc, false);
                System.assertEquals(true,result.isSuccess());
            Test.stopTest();
        }
    }
    @IsTest static void afterUpdateTriggerTest(){
        //MOSCATELLI_M 11/12/2018: Accesso a registrazioni audio -- START
        IE_Configuration__c IEC = new IE_Configuration__c(Name = 'STORM Save Recording',
          Type__c = 'WebService',
          Direction__c = 'OUTBOUND',
          EndPoint__c = 'https://mockbin.org/bin/5c5736a6-27e7-41c6-ae26-8ebc201b81fc',
          Insert_IR_WS__c = false,
          log_records_flag__c = true
         );
        insert IEC;

        AAI_Code_Variables__c Acv = new AAI_Code_Variables__c(Name='STORMRecSaving_AuthKEY',Value__c='passw');
        insert Acv;

        AP17_STORMSavePhoneRecording_Mock_TEST mockServer = new AP17_STORMSavePhoneRecording_Mock_TEST();
        mockServer.TestCase = 'test_one';
        Boolean no_error =true;
        Test.setMock(HttpCalloutMock.class, mockServer);
        //MOSCATELLI_M 11/12/2018: Accesso a registrazioni audio -- END


        Test.startTest();
            Account a1 = new Account(Name = 'accTest1');
            insert a1;
            Case c1 = new Case(Category__c='Auto');
            insert c1;
            Storico_Chiamate__c sc = new Storico_Chiamate__c(Case__c = c1.Id,
                                                             Customer__c = a1.Id);
            insert sc;
            sc.Email_Modified__c = true;
            Database.SaveResult result = Database.Update(sc, false);
            System.assertEquals(true,result.isSuccess());
        Test.stopTest();
    }

}