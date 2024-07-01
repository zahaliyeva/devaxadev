@isTest
private class CommunicationToCustomerEventHandler_TEST {
    
    @TestSetup
    static void makeData(){
        Account account = new Account(Name = 'Account Name');
        insert account;
        Contact contact = new Contact(FirstName = 'Name', LastName = 'LastName', AccountId = account.Id);
        insert contact;
    }

    @IsTest 
    public static void testInsertEvents(){
        Test.startTest();
        CommunicationToCustomer__e event = new CommunicationToCustomer__e(AccountId__c = [SELECT Id from Account limit 1].Id);
        Database.SaveResult sr = EventBus.publish(event);
        Test.stopTest();
        List<Communications_to_customer__c> communications = [SELECT Contact__r.Id from Communications_to_customer__c];
        System.assertEquals(1, communications.size());
        System.assertEquals([SELECT Id from Contact LIMIT 1].Id, communications[0].Contact__r.Id);
    }

    @IsTest  
    public static void testEmptyMethods(){
        List<CommunicationToCustomer__e> events = new List<CommunicationToCustomer__e>();
        CommunicationToCustomer__e event = new CommunicationToCustomer__e();
        CommunicationToCustomerEventHandler handler = new CommunicationToCustomerEventHandler();
        handler.beforeInsert(events);
        handler.beforeUpdate(event, event);
        handler.beforeUpdate(events, events);
        handler.beforeDelete(event);
        handler.beforeDelete(events);
        handler.afterInsert(event);
        handler.afterUpdate(event, event);
        handler.afterUpdate(events, events);
        handler.afterDelete(event);
        handler.afterDelete(events);
        handler.afterUndelete(events);
        handler.afterUndelete(event);
        handler.bulkBefore();
    }
    
    @IsTest 
    public static void testInsertEventsNoAAI(){
        Test.startTest();
        CommunicationToCustomerNoAAI__e event = new CommunicationToCustomerNoAAI__e(AccountId__c = [SELECT Id from Account limit 1].Id);
        Database.SaveResult sr = EventBus.publish(event);
        Test.stopTest();
        List<Communications_to_customer__c> communications = [SELECT Contact__r.Id from Communications_to_customer__c];
        System.assertEquals(1, communications.size());
        System.assertEquals([SELECT Id from Contact LIMIT 1].Id, communications[0].Contact__r.Id);
    }

    @IsTest  
    public static void testEmptyMethodsNoAAI(){
        List<CommunicationToCustomerNoAAI__e> events = new List<CommunicationToCustomerNoAAI__e>();
        CommunicationToCustomerNoAAI__e event = new CommunicationToCustomerNoAAI__e();
        CommunicationToCustomerNoAAIEventHandler handler = new CommunicationToCustomerNoAAIEventHandler();
        handler.beforeInsert(events);
        handler.beforeUpdate(event, event);
        handler.beforeUpdate(events, events);
        handler.beforeDelete(event);
        handler.beforeDelete(events);
        handler.afterInsert(event);
        handler.afterUpdate(event, event);
        handler.afterUpdate(events, events);
        handler.afterDelete(event);
        handler.afterDelete(events);
        handler.afterUndelete(events);
        handler.afterUndelete(event);
        handler.bulkBefore();
    }
}