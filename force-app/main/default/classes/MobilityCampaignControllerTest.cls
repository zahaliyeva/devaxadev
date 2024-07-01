@isTest
class MobilityCampaignControllerTest {
	@isTest
	static void testCampaignList() {

		List<Campaign> campaigns = new List<Campaign>();
		for (Integer count = 0;
		     count < 100;
		     count++) {
			campaigns.add(new Campaign(Name = 'Campagna ' + count, Status = 'planned'));
		}
		insert campaigns;
        
        List< Object> ids = new List< Object>();
        ids.add(campaigns[0].Id);
        Map<String,List< Object>> map2 = new Map<String,List< Object>>();
        map2.put('CampaignId',ids);
        
        User User1 = new User();
        Account Account1 = new Account(Name = 'Alberto');
        Account1.Ndg__c = '123';
        insert Account1;
        Map<String,List< Object>> Map1 = new Map<String,List< Object>>();
        
		Test.startTest();
		String campaignId = String.valueOf(campaigns[0].Id);
        Id UserId = User1.Id;

		MobilityCampaignController.getCampaigns();
		MobilityCampaignController.getCollaborators(campaignId);
		//MobilityCampaignController.getStatus();
        MobilityCampaignController.getCampaignCustomer(10,'35010000000033');
        MobilityCampaignController.getCounters(CampaignId,UserId);
        MobilityCampaignController.applyNGD(Map1);
        MobilityCampaignController.getCampaignsTest(10,2,Map1,'Name','ASC','Name');
        MobilityCampaignController.getOpportunity(10,2,Map1,'Name','ASC','Name');
		MobilityCampaignController.getActivities(10,2,Map1,'Subject','ASC','Subject');
		MobilityCampaignController.getHistory(10,2,Map1,'Subject','ASC','Subject');        
        //MobilityCampaignController.getRecordType(campaignId);
        //MobilityCampaignController.getCampaignTitle(campaignId);
        MobilityCampaignController.getDataEnrichment(10,2,map2,'Sottostato__c','ASC','Sottostato__c');
        MobilityCampaignController.getInformative(10,2,map2,'Status','ASC','Status');
        MobilityCampaignController.getAgency(10,2,map2,'Status','ASC','Status');
        MobilityCampaignController.getMarketing(10,2,map2,'Status','ASC','Status');
        MobilityCampaignController.getCountersWidget(3);

		System.assertEquals(campaignId != null, true,'campagna deve essere inserita OK');
        
		Test.stopTest();
	}

	@isTest
	public static void MobilityCampaignProcessingCoverage() {

		Campaign cmp1 = new Campaign(Name = 'Test Campaign 1',
                                     Startdate = system.today()-1,
                                     enddate = system.today(),
                                     Type = 'TCM',
                                     Status = 'On-going');
        insert cmp1;

		CampaignMemberStatus cms= new CampaignMemberStatus( CampaignId = cmp1.id, IsDefault = true, Label = 'On-going');
		insert cms;

		AccountClientIndex__c aci= new AccountClientIndex__c (Name='Test',Client_Index_Name__c='Client1', Client_Index_Number__c=1);
		insert aci;

		CampaignMemb_Sub_Status__c cmss= new CampaignMemb_Sub_Status__c(Name='Invio cartaceo',Campaign_Record_Type__c='DummyRT');
		insert cmss;

		Node__c nodo = new Node__c ();
    	nodo.Agency_holder__c = 'NODO Holder';
   		nodo.Node_unique_code__c= '000024';
    	nodo.Parent_node_unique_code__c= 'A001';
    	nodo.Tree_name__c= 'DIF';
    	nodo.Blacklist_Processi__c= 'Rinnovi';
    	nodo.Node_description__c= 'Agency Away from Home';
    	nodo.Node_level__c= 8;
    
    	NodeHandler.setDeactivateTrigger(true);//avoid trigger for this node, non rules 
    	insert nodo;
		NodeHandler.setDeactivateTrigger(false);

		user u=[select Id, Agency_code__c, Nodes__c from user where id= :UserInfo.getUserId() limit 1];
		U.Nodes__c='000001;000024';
		u.Agency_code__c='000003';

		SObjectTable.SObjectStrategy strategy=new SObjectTable.SObjectStrategy();
		strategy.sobjectName = 'CampaignMember';

		Test.startTest();
		Map<String,String> result = MobilityCampaignProcessing.retrieveNodesMap('000024','000024;000001');
		List<String> result2 = MobilityCampaignProcessing.listNodes('');
		Map<string,String> result3 = MobilityCampaignProcessing.getSubStatus('DummyRT');
		Map<String,String> result4 = MobilityCampaignProcessing.getContactValues('a;b;c');
		MobilityCampaignProcessing.getCampaignMember(cmp1.id,u,null);
		MobilityCampaignProcessing.getOwerList(cmp1.id,strategy);
		MobilityCampaignProcessing.initData(cmp1.id);
		Test.stopTest();

		Map<String,String> expres=new Map<String,String>();
		expres.put('000024 - Agency Away from Home','000024');

		Map<String,String> expres3=new Map<String,String>();
		expres3.put('Invio cartaceo','Invio cartaceo');

		Map<String,String> expres4=new Map<String,String>();
		expres4.put('a','a');
		expres4.put('b','b');
		expres4.put('c','c');

		Assert.areEqual(expres, result);
		Assert.areEqual(null, result2);
		Assert.areEqual(expres3, result3);
		Assert.areEqual(expres4, result4);


	}

	/*static testMethod void testCampaignMembers() {
		CampaignMember mem = new CampaignMember();
		mem.Campaign.Status = 'Planned';
		mem.Contact.Account.NDG__c = '12345';
		mem.Campaign.RecordType.DeveloperName = 'Agency_campaign';
		insert (mem);

		Test.startTest();

		Integer limitRows = 5;
		String ndgId = '12345';

		MobilityCampaignController.getCampaignCustomer(limitRows, ndgId);

		Test.stopTest();
	}*/
}