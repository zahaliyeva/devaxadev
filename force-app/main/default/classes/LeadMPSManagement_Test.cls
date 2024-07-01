@isTest
public class LeadMPSManagement_Test {
    @testSetup static void methodName(){
        
        List<Lead> LeadList = new List<Lead>();
        LeadList.add(new Lead(agency_Code__c = '000127', LastName = 'test'));
        LeadList.add(new Lead(agency_Code__c = '', LastName = 'test1'));
        LeadList.add(new Lead(agency_Code__c = '000000', LastName = 'test2'));
        
        insert LeadList;
	}
    
    @isTest
	public static void testSendToAgency(){
        Test.startTest();
        ID leadId = [SELECT id FROM Lead WHERE agency_Code__c = '000127' limit 1].Id;
        ID leadId2 = [SELECT id FROM Lead WHERE agency_Code__c = null limit 1].Id;
        ID leadId3 = [SELECT id FROM Lead WHERE agency_Code__c = '000000' limit 1].Id;
        LeadMPSManagement.SendToAgency(leadId);
        LeadMPSManagement.SendToAgency(leadId2);
        LeadMPSManagement.SendToAgency(leadId3);
        Test.stopTest();
        
    }
    
    @isTest
	public static void testRejectLead(){
        Test.startTest();
        ID leadId = [SELECT id FROM Lead limit 1].Id;
        LeadMPSManagement.RejectLead(leadId);
        //LeadMPSManagement.SendToAgency(leadId);
        Test.stopTest();
        
    }
    
}