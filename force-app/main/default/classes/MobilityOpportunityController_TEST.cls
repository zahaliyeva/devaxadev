@isTest
public class MobilityOpportunityController_TEST {
	
    @TestSetup
    public static void setup(){
        campaign cam = new campaign(name = 'test');
        insert cam;
        Account a = new Account(Name = 'test test');
        insert a;
        contact con = new Contact(Lastname = 'test', AccountId = a.id);
        insert con;
        campaignMember cm = new campaignMember(campaignId = cam.Id, ContactId = con.Id);
        insert cm;
        Opportunity op = new Opportunity(name = 'OPP test', StageName = 'Closed/won', CloseDate = date.today().addDays(1));
        insert op;
    }
    
    @isTest
    public static void method1(){
        
        MobilityOpportunityController.createOpprotunityMember([Select id from campaignMember limit 1].Id);
    }
    
    @isTest
    public static void method2(){
        Map < String, List < Object >> filters = new Map < String, List < Object >>{
            'name' => new List<String>{'OPP test'}
        };
        MobilityOpportunityController.getOpportunityMemberGrid(1, 5, filters, '', '', '');
    }
   
    @isTest
    public static void method3(){
        MobilityOpportunityController.createProposal([Select id from campaignMember limit 1].Id);
    }
    
     @isTest
    public static void method4(){
        MobilityOpportunityController.setProposal([Select id from campaignMember limit 1].Id, [Select id from Opportunity limit 1].Id);
    }
}