@isTest
public without sharing class LghtSendWhatsappOutboundApexController_T {
    
    @testSetup static void setup() 
    {
        ServiceUtilsClass.populateCustomSettingsForTests();
        Account acct = new Account(Name = 'SFDC Account');
        insert acct;
        Id accId     = acct.Id;

        Contact con = new Contact(FirstName = 'Joe',
                                  LastName  = 'Smith',
                                  Phone     = '415.555.1212',
                                  AccountId = accId);
        insert con;
        Id conId    = con.Id;
        
        
        Case caseObj1 = new Case(ContactId = conId,
                                 AccountId = accId,
                                 Status    = 'Open',
                                 Origin    = 'Whatsapp');
        insert caseObj1;
    }
    
    @isTest
    public static void test_getMessagesTemplates() {
        LghtSendWhatsappOutboundApexController.OutboundMessagingTemplate res = LghtSendWhatsappOutboundApexController.getMessagesTemplates('Whatsapp');

        System.assert(res != null );
        System.assert(res.templatesConfig != null);
        System.assert(res.templates != null);
    }

    @isTest
    public static void test_updateCase() {
        Case c = [SELECT Id, OutboundMessagingTemplate__c FROM Case LIMIT 1];
        
        System.assert(c.OutboundMessagingTemplate__c == null);

        c.OutboundMessagingTemplate__c = 'Whatsapp_Inizia';
        LghtSendWhatsappOutboundApexController.updateCase(c);

        c = [SELECT Id, OutboundMessagingTemplate__c FROM Case LIMIT 1];

        System.assertEquals('Whatsapp_Inizia', c.OutboundMessagingTemplate__c);

    }
}