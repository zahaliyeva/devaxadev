@isTest
public class LightningAccountEditApexControllerTest {
    @testSetup private static void createData(){
    }
    
    @isTest static void test() {
        Test.startTest();
        Account acct = new Account(FirstName = 'Account', LastName = 'SFDC', AAI_Codice_fiscale__c = 'MCCGNN88P14F839W', Fiscal_ID__c = 'MCCGNN88P14F839W', RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2C Client').getRecordTypeId());
        insert acct;
        Storico_Chiamate__c st = new Storico_Chiamate__c(Call_ID__c='89078');
        insert st;
        LightningAccountEditApexController.getData(acct.Id, st.Id);
        Test.stopTest();          
    }
}