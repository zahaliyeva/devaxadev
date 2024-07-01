@isTest
public class SchedaClienteControllerTest {
    
    @TestSetup
    public static void makeData(){
        AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
        insert acv;
        ServiceUtilsClass.populateCustomSettingsForTests();
        Id recordtypeId = [Select Id from Recordtype Where Name = 'B2B Client' and sObjecttype='Account'].Id;
        Account account = new Account(Name = 'Duplicated',
            RecordtypeId = recordtypeId,
            AAI_Codice_fiscale__c = 'BB176176abcdefgh',
            AAI_Agency_Reference_Code__c = '004610',
            State__c = 'ATTIVO');
        insert account;
        Contact contact = new Contact(LastName = 'test');
        insert contact;
        contact.AccountId = account.Id;
        update contact;
        Case aCase = new Case(
            AccountId = account.Id,
            Status    = 'Open',
            Origin    = 'Email');
        insert aCase;
        Campaign campaign = new campaign(Name ='TestCampaign2');
        insert campaign;
        CampaignMember campaignMember = new CampaignMember(CampaignId = campaign.Id,
                contactId = contact.Id,
                Sottostato__c='SMS non recapitabile');
        insert campaignMember;
        Id PolicyRTId = Schema.SObjectType.InsurancePolicy__c.getRecordTypeInfosByName().get('Non Auto').getRecordTypeId();
        InsurancePolicy__c polizza = new InsurancePolicy__c(Name = '123123123',
                                                            CUID__c = account.Id,
                                                            Status__c = 'ATTIVO',
                                                            TECH_Company__c = 'AAI',
                                                            Line__c ='1',
                                                            Sub_ASA__c = 'b',
                                                            Last_Premium_Paid__c = 1,
                                                            RecordtypeId = PolicyRTId);
        insert polizza;
    }

    @isTest 
    public static void testController(){
        Test.startTest();
        Account account = [SELECT Id from Account LIMIT 1];
        account.TECH_Company__c = 'AXA QUADRA ASSICURAZIONI DANNI';
        update account; 
        SchedaClienteController.getWrapper(account.Id);
        account.TECH_Company__c = 'MPS';
        update account; 
        SchedaClienteController.getWrapper(account.Id);
        account.TECH_Company__c = 'AAF';
        update account; 
        SchedaClienteController.getWrapper(account.Id);
        account.TECH_Company__c = 'AAI';
        update account;
        SchedaClienteController.getWrapper(account.Id);
        account.TECH_Company__c = 'AMF';
        update account;
        SchedaClienteController.getWrapper(account.Id);
        account.Nodes__c = '001040';
        account.TECH_Company__c = 'AAI';
        update account;
        SchedaClienteController.getWrapper(account.Id);
        Test.stopTest();

    }

}