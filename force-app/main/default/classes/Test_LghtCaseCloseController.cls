@isTest
public class Test_LghtCaseCloseController {
    @testSetup
    static void createTestData() {
        //Create BusinessHours
        ID BusinessHoursDefault = [SELECT id FROM businesshours WHERE isDefault = TRUE LIMIT 1].id;
        List<MPS_Code_Variables__c> listCustomSetting = new List<MPS_Code_Variables__c>();
        listCustomSetting.add(new MPS_Code_Variables__c(Name = 'BusinessHours_Default', Value__c = BusinessHoursDefault));
        insert listCustomSetting;
        //Create IE_Configuration__c
        IE_Configuration__c conf = new IE_Configuration__c(
            Name = 'SILVA_Generic',
            ClientId__c = '12345',
            Client_Secret__c = '12345',
            EndPoint__c = 'prova_endpoint',
            Silva_Token_Expiration_DateTime__c = (System.now() - 1)
        );
        IE_Configuration__c conf2 = new IE_Configuration__c(
            Name = 'SILVA_Get_Token',
            ClientId__c = '1e996a35',
            Client_Secret__c = 'TE4gXhSMRh9Z8uQzHA6lw8tbB0LHxC5Lg0rIqSRt_zdJskRxzqrNzw',
            EndPoint__c = 'https://maam-stg.axa.com/maam/v2/token',
            Silva_Token_Expiration_DateTime__c = (System.now() - 1)
        );
        insert conf;
        insert conf2;
        //Create Application_EAGP__c
        Application_EAGP__c newApp = new Application_EAGP__c(
            Name = 'Test App',
            Prefix__c = '',
            External_Id__c = 'Test',
            Service_Offering__c = 'Test Silva',
            Silva_Integration__c = true
        );
        insert newApp;
        Application_EAGP__c app = [SELECT Id, Name, Prefix__c, External_Id__c, Service_Offering__c FROM Application_EAGP__c LIMIT 1];
        //Create Case
        Case c = new Case(
            Description = 'Test Class',
            Tipologia_Ticket_Silva__c = 'Incident',
            Subject = 'Test',
            Application_EAGP__c = app.Id
        );
        insert c;
        Case c2 = new Case(Description = 'Test Class', Subject = 'Test', Application_EAGP__c = app.Id);
        insert c2;
    }

    @isTest
    static void testCallout() {
        Test.setMock(HttpCalloutMock.class, new Test_SILVA_Mock());
        IE_Configuration__c conf = [
            SELECT id, Name, Silva_Token_Expiration_DateTime__c
            FROM IE_Configuration__c
            WHERE Name = 'SILVA_Get_Token'
            LIMIT 1
        ];
        Case c = [SELECT Id, Description, Tipologia_Ticket_Silva__c FROM Case WHERE Tipologia_Ticket_Silva__c = 'Incident' LIMIT 1];
        Test.startTest();
        LghtCaseCloseController.updateCase(c);
        Test.stopTest();
    }
    @isTest
    static void testCallout2() {
        Test.setMock(HttpCalloutMock.class, new Test_SILVA_Mock());
        IE_Configuration__c conf = [
            SELECT id, Name, Silva_Token_Expiration_DateTime__c
            FROM IE_Configuration__c
            WHERE Name = 'SILVA_Get_Token'
            LIMIT 1
        ];
        Case c2 = [SELECT Id, Description, Tipologia_Ticket_Silva__c FROM Case WHERE Tipologia_Ticket_Silva__c != 'Incident' LIMIT 1];
        Test.startTest();
        LghtCaseCloseController.updateCase(c2);
        Test.stopTest();
    }
}