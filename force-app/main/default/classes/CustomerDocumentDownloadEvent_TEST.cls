/**
 * Created by Augens on 23/11/2018.
 */

@IsTest
private class CustomerDocumentDownloadEvent_TEST {
    @IsTest
    static void sendDownloadAlertEmailsTest() {
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
            List<Customer_Document_Download__e> dwlList = new List<Customer_Document_Download__e>();
                Customer_Document_Download__e  customerDocumentDownload = new Customer_Document_Download__e(Source_System__c = 'Marketing Cloud',
                                                                                                                NDG__c = account.NDG__c,
                                                                                                                Customer_Company__c = account.TECH_Company__c,
                                                                                                                Fiscal_Identifier__c = account.Fiscal_ID__c,
                                                                                                                Product_Name__c = 'Attestato di rischio auto',
                                                                                                                Timestamp__c = DateTime.newInstance(System.currentTimeMillis()));
                dwlList.add(customerDocumentDownload);
                List<Database.SaveResult> res =EventBus.publish(dwlList);
                for (Database.SaveResult sr : res) {
                    if (sr.isSuccess()) {
                        System.assertEquals(true,sr.isSuccess());
                    }
                }
        Test.stopTest();
    }
}