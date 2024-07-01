@IsTest
public class MobilityCustomLayoutTest {
    static testMethod void testCustomLayout() {
        
        Account acc = New Account(FirstName = 'Paolo',LastName = 'Fermi');
        insert acc;
        String accountId = String.valueOf(acc.Id);
        
        List<String> fields = new List<String>();
        fields.add('FirstName');
        fields.add('LastName');
     
        Test.startTest();
        MobilityCustomLayout.getLayout('Campaign',accountId,'Agency_Campaign','Detail');
        MobilityCustomLayout.getSections('Campaign','Agency_Campaign','Detail');
        MobilityCustomLayout.getSectionsByName('MobilityCampaignList');
        MobilityCustomLayout.getFields(accountId,'Detail');
        MobilityCustomLayout.getConfig('MobilityCampaignList','Campaign','Agency_Campaign','Detail');
        MobilityCustomLayout.getFieldsDefinition('Account',fields);
        MobilityCustomLayout.getRecordType('Account',accountId);
        MobilityCustomLayout.save(acc);

        System.assertEquals(accountId != null, true,'Account deve essere inserita OK');
        Test.stopTest();
        
    }

}