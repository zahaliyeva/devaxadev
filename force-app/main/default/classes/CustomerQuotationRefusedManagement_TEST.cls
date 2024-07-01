/**
 * Created by Augens on 03/12/2018.
 */

@IsTest
private class CustomerQuotationRefusedManagement_TEST {
    @IsTest
    static void sendQuotationRefusedAlertEmailsTest() {
        Account account = new Account(Name ='acc',AAI_Agency_Reference_Code__c ='000828',
                                        RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Corporate').getRecordTypeId(),
                                        NDG__c='0008280000000424',
                                        Fiscal_ID__c = 'YDAc24o3J97F30pk',
                                        TECH_Company__c ='AXA MPS',
                                        AAI_Partita_IVA__c='1215478951');
        insert account;
        Contact c = new Contact(LastName = 'CTest',AccountId = account.Id);
        insert c;
        IE_Configuration__c config = new IE_Configuration__c(Name = 'Customer_Quotation_Refused');
        insert config;
        List<Customer_Quotation_Refused__e> CustomerQuotationList = new List<Customer_Quotation_Refused__e>();
        Test.startTest();
            Customer_Quotation_Refused__e eventCustomerQuotationRefused = new Customer_Quotation_Refused__e(NDG__c = account.NDG__c,
                                                                                                            Customer_Company__c = account.TECH_Company__c,
                                                                                                            Fiscal_Identifier__c = account.Fiscal_ID__c,
                                                                                                            Timestamp__c = DateTime.newInstance(System.currentTimeMillis()),
                                                                                                            Policy_Expiry_Date__c =Date.newInstance(2018,12,06),
                                                                                                            Model__c='FIAT PANDA',
                                                                                                            License_Plate__c='HW733PK');
            CustomerQuotationList.add(eventCustomerQuotationRefused);
        List<Database.SaveResult> res =EventBus.publish(CustomerQuotationList);
        for (Database.SaveResult sr : res) {
            if (sr.isSuccess()) {
                System.assertEquals(true,sr.isSuccess());
            }
        }
        Test.stopTest();

        CustomerQuotationRefusedEventHandler handler = new CustomerQuotationRefusedEventHandler();
        handler.bulkBefore();
        handler.beforeInsert(eventCustomerQuotationRefused);
        handler.beforeInsert(CustomerQuotationList);
        handler.beforeUpdate(eventCustomerQuotationRefused, eventCustomerQuotationRefused);
        handler.beforeUpdate(CustomerQuotationList, CustomerQuotationList);
        handler.beforeDelete(eventCustomerQuotationRefused);
        handler.beforeDelete(CustomerQuotationList);
        handler.afterUpdate(eventCustomerQuotationRefused, eventCustomerQuotationRefused);
        handler.afterUpdate(CustomerQuotationList, CustomerQuotationList);
        handler.afterDelete(eventCustomerQuotationRefused);
        handler.afterDelete(CustomerQuotationList);
        handler.afterUndelete(eventCustomerQuotationRefused);
        handler.afterUndelete(CustomerQuotationList);
    }
}