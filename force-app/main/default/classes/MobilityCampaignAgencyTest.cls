@isTest
public class MobilityCampaignAgencyTest {
    @testSetup private static void createData(){
        
    }
    
    @isTest static void test() {

        Campaign temp = new Campaign ();
        temp.Name = 'campagnaNuova';
        insert temp;

        Test.startTest();
        List< Object> ids = new List< Object>();
        ids.add(temp.Id);
        Map<String,List< Object>> map2 = new Map<String,List< Object>>();
        map2.put('CampaignId',ids);
        MobilityCampaignAgency.getAgency(10,2,map2,'Status','ASC','Status');
        System.assertEquals(temp.id != null, true,'campagna deve essere inserita OK');
        Test.stopTest();          
    }
}