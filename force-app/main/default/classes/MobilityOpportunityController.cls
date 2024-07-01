public with sharing class MobilityOpportunityController extends MobilityAbstract{
	
	public class MobilityOpportunityException extends Exception {}
	public class MobilityOpportunityMemberResponse extends MobilityResponse{
		@AuraEnabled public List<Opportunity> listOpportunity = new List<Opportunity>();
		@AuraEnabled public Account account;
		@AuraEnabled public Contact contact;
		@AuraEnabled public CampaignMember campaignMember;
		@AuraEnabled public Campaign campaign;
		@AuraEnabled public Opportunity opportunity;
	}

	public class MobilityDaolResponse extends MobilityResponse {
	    @AuraEnabled public String RGICommand;
	    @AuraEnabled public String utente;
	    @AuraEnabled public String codiceAgenzia;
	    @AuraEnabled public String codiceNDG;
	    @AuraEnabled public String keySFDC;
	    @AuraEnabled public String descSFDC;
	}

	@AuraEnabled
	public static MobilityOpportunityMemberResponse getOpportunityMember(String campaignMemberId){
		DebugStart('MobilityOpportunityController', 'getOpportunityMember');

		MobilityOpportunityMemberResponse response = new MobilityOpportunityMemberResponse();

		try {

			response.campaignMember = [
				SELECT Id, Status, ContactId, Contact.AccountId, Contact.Account.PersonMailingAddress, 
					Contact.Account.NDG__c, Contact.Name, CampaignId, Campaign.RecordType.DeveloperName, Owner__c, 
					Not_Interested_Reason__c, Lead.Name, Lead.Id, Number_of_contact_attempts__c, 
					Nodes__c,Campaign_member_related_opportunity__c, Informative_Contact_Outcome__c 
				FROM CampaignMember 
				WHERE Id=:campaignMemberId 
				LIMIT 1
			];

			response.account = response.campaignMember.Contact.Account;
			response.contact = response.campaignMember.Contact;

			response.campaign = [
				SELECT Id, Name, ASA__c
				FROM Campaign
				WHERE id = :response.campaignMember.CampaignId
			];

			response.listOpportunity = [
				SELECT Id 
				FROM Opportunity 
				WHERE Account.Id = :response.campaignMember.Contact.AccountId
				AND StageName = 'Open' 
				AND Numero_proposte__c = 0
			];

			response.isSuccess = true;
		} catch (MobilityOpportunityException ex) {
			response.errorMessage = ex.getMessage();
		}

		Debug('response', response);
		DebugEnd();
		return response;
	}

	//Account.Id = :response.campaignMember.Contact.AccountId
	@AuraEnabled
	public static SObjectTable.TablePagination getOpportunityMemberGrid(Integer page, Integer perPage, Map < String, List < Object >> filters, String orderField, String orderName, String search) {
		DebugStart('MobilityOpportunityController', 'getOpportunityMemberGrid');
		Debug('page', page);
		Debug('perPage', perPage);
		Debug('filters', filters);
		Debug('orderField', orderField);
		Debug('orderName', orderName);
		Debug('search', search);

		SObjectTable.SObjectStrategy strategy = new SObjectTable.SObjectStrategy();
		strategy.fieldsSet = new Set < String > {
			'Id',
			'Name',
			'StageName',
			'ASA_Description__c',
			'Prodotto__c',
			'CreatedDate',
			'Amount'
		};

		strategy.sobjectName = 'Opportunity';
		strategy.searchColumns = new Set < String > {
			'Name',
			'StageName',
			'ASA_Description__c',
			'Prodotto__c'
		};

		strategy.addFilter('StageName', new Set < Object > {
			'Open'
		});

		strategy.addFilter('Numero_proposte__c', new Set < Object > {
			'!NUMBER(0)'
		});

		strategy.setOrderDesc('CreatedDate');

		//INPUT DATA
		strategy.perPage = perPage;
		strategy.page = page;
		strategy.searchString = search;
		strategy.setOrder(orderField, orderName, true);
		strategy.addFilters(filters, true);

		//RESPONSE
		SObjectTable.TablePagination tableElement = SObjectTable.paginationData(strategy);
		tableElement.columns = new List < String > {
			'Name',
			'ASA_Description__c',
			'StageName',
			'Prodotto__c',
			'CreatedDate',
			'Amount'
		};
		tableElement.labels = new Map < String, String > {
			'Name' => 'Nome trattativa',
			'ASA_Description__c' => 'ASA Description',
			'StageName' => 'Fase',
			'Prodotto__c' => 'Prodotto',
			'CreatedDate' => 'Data creazione',
			'Amount' => 'Ammontare'
		};

		DebugEnd();
		return tableElement;
	}

	@AuraEnabled
	public static MobilityOpportunityMemberResponse createOpprotunityMember(String campaignMemberId){
		DebugStart('MobilityOpportunityController', 'createOpprotunityMember');

		MobilityOpportunityMemberResponse response = MobilityOpportunityController.getOpportunityMember(campaignMemberId);

		try {
			if(!response.isSuccess) throw new MobilityOpportunityException(response.errorMessage);

			String accountId = response.campaignMember.Contact.AccountId;
			if(accountId == null) throw new MobilityOpportunityException('Account not found');

			RecordType opportunityRecordType = [
				SELECT Id 
				FROM RecordType 
				WHERE SObjectType = 'Opportunity' 
				AND DeveloperName = 'Opportunita_AXA_Assicurazioni'
			];
			
			Opportunity opportunity = new Opportunity();
			opportunity.Name = 'OPP-XXXXXXX';
			opportunity.AccountId = accountId;
			opportunity.StageName = 'Open';
			opportunity.CloseDate = Date.Today().addMonths(1);
			opportunity.RecordTypeId = opportunityRecordType.Id;
			opportunity.Codice_ASA__c = response.campaign.ASA__c;
			opportunity.CampaignId = response.campaign.Id;
			insert opportunity;

			String nameOpp = [
				SELECT Name
				FROM Opportunity
				WHERE Id = :opportunity.Id
			].Name;
			opportunity.Name = nameOpp;

			response.opportunity = opportunity;
			response.isSuccess = true;
		} catch (MobilityOpportunityException ex) {
			response.errorMessage = ex.getMessage();
		}

		Debug('response', response);
		DebugEnd();
		return response;
	}

	@AuraEnabled
	public static MobilityDaolResponse createProposal(String campaignMemberId){
	    DebugStart('MobilityOpportunityController', 'createProposal');

	    MobilityDaolResponse response = new MobilityDaolResponse();

	    try {

	        MobilityOpportunityController.MobilityOpportunityMemberResponse context = MobilityOpportunityController.createOpprotunityMember(campaignMemberId);

	        CampaignMember campaignMember = context.campaignMember;
	        campaignMember.Campaign_member_related_opportunity__c = context.opportunity.Id;
	        campaignMember.Status = 'Interessato';
	        campaignMember.Owner__c = Userinfo.getUserId();
	        update campaignMember;

	        User currentUser = MobilityUserController.getCurrentUser();

	        response.RGICommand         = 'NewProp';
	        response.utente             = currentUser.CommunityNickname;
	        response.codiceAgenzia      = currentUser.Agency_Code__c;
	        response.codiceNDG          = context.account.NDG__c;
	        response.keySFDC            = context.opportunity.Id;
	        response.descSFDC           = context.opportunity.Name;

	        response.isSuccess = true;
	    } catch (MobilityOpportunityException ex) {
	        response.errorMessage = ex.getMessage();
	    }

	    Debug('response', response);
	    DebugEnd();
	    return response;
	}

	@AuraEnabled
	public static MobilityDaolResponse setProposal(String campaignMemberId, String opportunityId){
	    DebugStart('MobilityOpportunityController', 'setProposal');

	    MobilityDaolResponse response = new MobilityDaolResponse();

	    try {
	        CampaignMember campaignMember = [
	            SELECT Id, Name, Status, Campaign_member_related_opportunity__c 
	            FROM CampaignMember 
	            WHERE Id =: campaignMemberId 
	            LIMIT 1
	        ];

	        campaignMember.Campaign_member_related_opportunity__c = opportunityId;
	        update campaignMember;


			MobilityOpportunityMemberResponse context = MobilityOpportunityController.getOpportunityMember(campaignMemberId);
	        User currentUser = MobilityUserController.getCurrentUser();
	        
	        Opportunity opportunity = [
	        	SELECT Id, Name
	        	FROM Opportunity
	        	WHERE Id = :opportunityId
	        ];

	        response.RGICommand         = 'NewProp';
	        response.utente             = currentUser.CommunityNickname;
	        response.codiceAgenzia      = currentUser.Agency_Code__c;
	        response.codiceNDG          = context.account.NDG__c;
	        response.keySFDC            = opportunity.Id;
	        response.descSFDC           = opportunity.Name;
	        
	        response.isSuccess = true;
	    } catch (MobilityOpportunityException ex) {
	        response.errorMessage = ex.getMessage();
	    }

	    Debug('response', response);
	    DebugEnd();
	    return response;
	}

}