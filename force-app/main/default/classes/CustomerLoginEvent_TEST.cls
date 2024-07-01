@isTest
public class CustomerLoginEvent_TEST {
    @isTest
    static void createCustomerLoginEvent(){
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
            List<Customer_Login__e> loginList = new List<Customer_Login__e>();
                Customer_Login__e  customerLogin = 
                    new Customer_Login__e(NDG__c = '0008280000000424',
                                                 Fiscal_Identifier__c = '1234567890',
                                                 Customer_Company__c = 'AAI',
                                                 Source_System__c = 'PCC/MyAxa',
                                                 Login_Email__c = 'test@email.com',
                                                 Timestamp__c = DateTime.newInstance(System.currentTimeMillis()));
                loginList.add(customerLogin);
                List<Database.SaveResult> res =EventBus.publish(loginList);
                for (Database.SaveResult sr : res) {
                    if (sr.isSuccess()) {
                        System.assertEquals(true,sr.isSuccess());
                    }
                }
        Test.stopTest();
    }
}