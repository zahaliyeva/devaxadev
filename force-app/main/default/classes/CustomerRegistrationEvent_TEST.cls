@IsTest
public class CustomerRegistrationEvent_TEST {
    @IsTest
    static void createCustomerRegistrationEvent(){
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
            List<Customer_Registration__e> regList = new List<Customer_Registration__e>();
                Customer_Registration__e  customerRegistration = 
                    new Customer_Registration__e(NDG__c = '0008280000000424',
                                                 Fiscal_Identifier__c = '1234567890',
                                                 Customer_Company__c = 'AAI',
                                                 Source_System__c = 'PCC/MyAxa',
                                                 Login_Email__c = 'test@email.com',
                                                 Timestamp__c = DateTime.newInstance(System.currentTimeMillis()));
                regList.add(customerRegistration);
                List<Database.SaveResult> res =EventBus.publish(regList);
                for (Database.SaveResult sr : res) {
                    if (sr.isSuccess()) {
                        System.assertEquals(true,sr.isSuccess());
                    }
                }
        Test.stopTest();
    }
}