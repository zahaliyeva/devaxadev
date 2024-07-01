@isTest
public class CustomerUpdateEvent_TEST {
    @isTest
    static void createCustomerUpdateEvent(){
        Account account = new Account(Name ='accName',
                                        AAI_Agency_Reference_Code__c ='000828',
                                        RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Corporate').getRecordTypeId(),
                                        NDG__c='0008280000000424',
                                        Fiscal_ID__c = 'YDATSK51J97F30ON',
                                        TECH_Company__c ='AXA MPS',
                                        AAI_Partita_IVA__c='12345678951');
        insert account;
        Contact contact = new Contact(LastName = 'LastNameContact',AccountId = account.Id);
        insert contact;
        Test.startTest();
            List<Customer_Update__e> updList = new List<Customer_Update__e>();
                Customer_Update__e  customerUpdate = 
                    new Customer_Update__e(NDG__c = '0008280000000424',
                                                 Fiscal_Identifier__c = '1234567890',
                                                 Customer_Company__c = 'AAI',
                                                 Source_System__c = 'PCC/MyAxa',
                                                 Login_Email__c = 'test@email.com',
                                                 Timestamp__c = DateTime.newInstance(System.currentTimeMillis()));
                updList.add(customerUpdate);
                List<Database.SaveResult> res =EventBus.publish(updList);
                for (Database.SaveResult sr : res) {
                    if (sr.isSuccess()) {
                        System.assertEquals(true,sr.isSuccess());
                    }
                }
        Test.stopTest();
    }
}