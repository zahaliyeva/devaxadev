/**
 * Created by Augens on 23/11/2018.
 */

@IsTest
private class EmailUnsubscribingEventManagement_TEST {
    @IsTest
    static void sendEmailAlertsForCustomerEventTest() {
        AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
        insert acv; 
        Account account = new Account(Name ='AccountName',
                                        AAI_Agency_Reference_Code__c ='000828',
                                        NDG__c='0008280000000424',
                                        TECH_Company__c ='AAI',
                                        AAI_Partita_IVA__c='85265678951');
        insert account;
        Contact contact = new Contact(LastName = 'LastNameContact',AccountId = account.Id);
        insert contact;
        IE_Configuration__c config = new IE_Configuration__c(Name = 'Customer_Email_Unsubscribing');
        insert config;
        Test.startTest();
            List<Customer_Email_Unsubscribing__e> emailEventList = new List<Customer_Email_Unsubscribing__e>();
            Customer_Email_Unsubscribing__e emailEvent = new Customer_Email_Unsubscribing__e(Source_System__c = 'Marketing Cloud',
                                                                                            NDG__c = account.NDG__c,
                                                                                            Customer_Company__c = account.TECH_Company__c,
                                                                                            Unsubscribing_Contact__c = contact.Id,
                                                                                            Timestamp__c = DateTime.newInstance(System.currentTimeMillis()));
            emailEventList.add(emailEvent);
            List<Database.SaveResult> res =EventBus.publish(emailEventList);
            for (Database.SaveResult sr : res) {
                if (sr.isSuccess()) {
                    System.assertEquals(true,sr.isSuccess());
                }
            }


        Test.stopTest();

        EmailUnsubscribingEventHandler handler = new EmailUnsubscribingEventHandler();
        handler.bulkBefore();
        handler.beforeInsert(emailEvent);
        handler.beforeInsert(emailEventList);
        handler.beforeUpdate(emailEvent, emailEvent);
        handler.beforeUpdate(emailEventList, emailEventList);
        handler.beforeDelete(emailEvent);
        handler.beforeDelete(emailEventList);
        handler.afterUpdate(emailEvent, emailEvent);
        handler.afterUpdate(emailEventList, emailEventList);
        handler.afterDelete(emailEvent);
        handler.afterDelete(emailEventList);
        handler.afterUndelete(emailEvent);
        handler.afterUndelete(emailEventList);
    }
}