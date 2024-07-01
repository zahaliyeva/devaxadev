public with sharing class MobilityCampaignProcessing extends MobilityAbstract{

	public class MobilityCampaignProcessingException extends Exception {}
	public class MobilityCampaignProcessingResponse extends MobilityResponse {
		@AuraEnabled public Campaign campaign;
		@AuraEnabled public User currentUser;
		@AuraEnabled public Map<String,String> campaignMemberStatus 		= new Map<String,String>();
		@AuraEnabled public Map<String,String> campaignMemberSubStatus 		= new Map<String,String>();
		@AuraEnabled public Map<String,String> listOwner 					= new Map<String,String>();
		@AuraEnabled public Map<String,String> nodes 						= new Map<String,String>();
		@AuraEnabled public Map<String,String> clientIndices 				= new Map<String,String>();
		@AuraEnabled public Map<String,String> priorityValues 				= new Map<String,String>();
		@AuraEnabled public Map<String,String> opportunityValues 			= new Map<String,String>();
		@AuraEnabled public Map<String,String> contactValues 				= new Map<String,String>();

	}

	public static Campaign getCampaign(String campaignId){
		return [
			SELECT Name, Recordtype.DeveloperName, Contact_Value__c, IncentiveCampaign__c, Type
			FROM Campaign
			WHERE Id =:campaignId
			LIMIT 1
		];
	}

	public static Map<String,String> getCampaignMemberStatus(String campaignId, String developerName){
		List<CampaignMemberStatus> campaignMemberStatus = [
			SELECT Id, Label, SortOrder 
			FROM CampaignMemberStatus
			WHERE CampaignId = :campaignId
		];

		Map<String,String> listStatus = new Map<String,String>();
		for(CampaignMemberStatus status : campaignMemberStatus){
			if (status.Label != 'Richiesta informazioni' && status.Label != 'In preparazione') {
			    if (!(developerName == 'Marketing_Campaign' && status.Label == 'Escluso')){
			    	listStatus.put(status.Label, status.Label);
			    }
			}

		}

		return listStatus;
	}

	public static List<String> listNodes(String nodesString){
		if(String.isNotBlank(nodesString)){
			List<String> nodes = nodesString.split(';');

			return MobilityCampaignProcessing.cleanNodes(nodes);
		}

		return null;
	}

	public static List<String> cleanNodes(List<String> nodes){
		List<String> nodesClean = new List<String>();
		for(String node : nodes){
			if(String.isNotBlank(node)) nodesClean.add(node.remove('DIF_'));
		}

		return nodesClean;
	}

	public static Map<String,String> retrieveNodesMap(String agencyCode, String nodesString){
		return MobilityCampaignProcessing.retrieveNodesMap(agencyCode, nodesString, null);
	}

	public static Map<String,String> retrieveNodesMap(String agencyCode, String nodesString, List<Node__c> nodes){
		Map<string,String> result = new Map<String,String>();

		if(nodes == null) nodes = MobilityCampaignProcessing.retrieveNodes(agencyCode, nodesString);
		if(nodes == null) return null;
		
		for(Node__c node : nodes){
			result.put(node.Node_unique_code__c + ' - ' + node.Node_description__c, node.Node_unique_code__c);
		}

		return result;
	}

	public static List<Node__c> retrieveNodes(String agencyCode, String nodesString){
		List<String> nodes = MobilityCampaignProcessing.listNodes(nodesString);
		if(nodes == null) return null;

		if(nodes.contains(agencyCode)){
			String keySearch = agencyCode + '%';
			return [
				SELECT Node_unique_code__c, Node_description__c 
				FROM Node__c 
				WHERE Node_unique_code__c 
				LIKE :keySearch 
				AND Node_level__c >= 7 
				AND Node_level__c <= 9 
				ORDER BY Node_unique_code__c ASC
			];
		}

		return [
			SELECT Node_unique_code__c, Node_description__c 
			FROM Node__c 
			WHERE (Node_unique_code__c IN :nodes OR Parent_node_unique_code__c IN :nodes) 
			AND Node_level__c >= 7 
			AND Node_level__c <= 9 
			ORDER BY Node_unique_code__c ASC
		];
	}

	public static Map<String,String> getClientIndexMap(){
		Map<string,String> result = new Map<String,String>();

		List<AccountClientIndex__c> listData = MobilityCampaignProcessing.getClientIndex();

		for(AccountClientIndex__c indexData : listData){
			result.put(indexData.Client_Index_Name__c, indexData.Client_Index_Name__c);
		}

		return result;
	}

	public static List<AccountClientIndex__c> getClientIndex(){
		return [
			SELECT Id, Name, Client_Index_Name__c, Client_Index_Number__c 
			FROM AccountClientIndex__c 
			ORDER BY SortOrder__c
		];
	}

	public static Map<string,String> getClientPriority(){
		Map<string,String> result = new Map<String,String>();

		Schema.DescribeFieldResult fieldResult = Schema.CampaignMember.Contact_Priority__c.getDescribe();
        List<Schema.PicklistEntry> fieldDescribe = fieldResult.getPicklistValues();

        for (Schema.PicklistEntry valueList : fieldDescribe) {
            result.put(valueList.getLabel(), valueList.getValue());
        }

        return result;
	}

	public static Map<string,String> getSubStatus(String recordtype){
		Map<string,String> result = new Map<String,String>();
		
		List<String> campaignMemberStatus = new List<String>();
		for (CampaignMemb_Sub_Status__c subStatus : CampaignMemb_Sub_Status__c.getall().values()) {
		    if (subStatus.Campaign_Record_Type__c.contains(recordtype)){
		    	campaignMemberStatus.add(subStatus.Name);
		    }
		}

		Schema.DescribeFieldResult fieldDescribe = CampaignMember.Sottostato__c.getDescribe();
		List<Schema.PicklistEntry> listPicklistEntry = fieldDescribe.getPicklistValues();
		for (Schema.PicklistEntry picklistEntrypick: listPicklistEntry) {
		    if (campaignMemberStatus.contains(picklistEntrypick.getValue()))
		        result.put(picklistEntrypick.getLabel(), picklistEntrypick.getValue());
		}

		return result;
	}

	public static Map<String,String> getOpportunityStatus(){
		Map<string,String> result = new Map<String,String>();

        result.put('Trattativa aperta', 'Trattativa aperta');
        result.put('Preventivo emesso', 'Preventivo emesso');
        result.put('Vinta', 'Vinta');
        result.put('Persa', 'Persa');

        return result;
	}

	public static Map<String,String> getContactValues(String contactValueString){
		if(contactValueString == null) return null;

		Map<string,String> result = new Map<String,String>();
		List<String> values = contactValueString.split(';');

		for (String value : values) {
		    if(String.isNotBlank(value)) result.put(value, value);
		}

		return result;
	}

	public static SObjectTable.SObjectStrategy getCampaignMember(String campaignId){
		return MobilityCampaignProcessing.getCampaignMember(campaignId, null, null);
	}

	public static SObjectTable.SObjectStrategy getCampaignMember(String campaignId, User currentUser, List<Node__c> nodesRetrieve){
		DebugStart('MobilityCampaignProcessing', 'getCampaignMember');
		Debug('campaignId', campaignId);
		Debug('currentUser', currentUser);
		Debug('nodesRetrieve', nodesRetrieve);

		if(currentUser == null) currentUser = MobilityUserController.getCurrentUser();
		String agencyCode = currentUser.Agency_Code__c;
		String nodesString = currentUser.Nodes__c;

		Debug('agencyCode', agencyCode);
		Debug('nodesString', nodesString);

		SObjectTable.SObjectStrategy strategy = new SObjectTable.SObjectStrategy();

		strategy.sobjectName = 'CampaignMember';
		strategy.fieldsSet = new Set < String > {
			'Id',
			'CreatedDate',
			'Account_NDG__c',
			'TECH_Account_Name__c',
			'TECH_Account_Active_Insurance_Contracts__c',
			'Tot_pol_a_scad__c',
			'TECH_Account_Active_Campaigns__c',
			'Prox_data_scad__c',
			'TECH_Client_Index__c',
			'Num_pol_prox_scad__c',
			'TECH_First_expiration_date__c',
			'Premio_prox_scad__c',
			'TECH_task_date_created__c',
			'LoB_possedute__c',
			'CampaignId',
			'Cliente_prioritario__c',
			'Contact_Priority__c',
			'Contact.Account.Active_Campaigns__c',
			'Contact.Account.Active_Insurance_Contracts__c',
			'Contact.Account.Client_Index__c',
			'Contact.Account.First_expiration_date__c',
			'Contact.Account.Id',
			'Contact.Account.IsPersonAccount',
			'Contact.Account.Name',
			'Contact.Account.Promotional_privacy__c',
			'Contact.Account.Recordtype.Name',
			'ContactId',
			'Data_Enrichment_Target_Consensus__c',
			'Data_Enrichment_Target_Email__c',
			'Data_Enrichment_Target_Other__c',
			'Data_Enrichment_Target_Phone__c',
			'Informative_Contact_Outcome__c',
			'LastModifiedDate',
			'LeadId',
			'Nodes__c',
			'Note__c',
			'Number_of_contact_attempts__c',
			'Owner__c',
			'Owner__r.Name',
			'Partner_Role_Visibility__c',
			'Sottostato__c',
			'Stato_Opportunit_Custom__c',
			'Status',
			'Name',
			'Fiscal_Code__c',
			'Vat_Number__c',
			'DAC_Certificato__c',
			'ndg_certificato__c',
			'flg_attivo__c',
			'target_2018__c',
			'stop_carta_2018__c',
			'firma_digitale_2018__c',
			'codice_nodo_OMNIA__c',
			'Nodo_Omnia_produttore__c',
			'Email_errata__c',
			'Codice_Agenzia_Subagente__c',
			'Tipo_errore__c'
		};

		strategy.addFilter('CampaignId', new Set<Object>{campaignId});
		strategy.addFilter('Partner_Role_Visibility__c', new Set<Object>{'true'});

		if(String.isNotBlank(agencyCode)){
			strategy.addFilter('Agency_Code__c', new Set<Object>{agencyCode});
		}

		List<String> nodes = MobilityCampaignProcessing.listNodes(nodesString);

		if(nodes != null && nodes.contains(agencyCode)){
			String filterNode = '!LIKE(%' + agencyCode + '%)';
			
			strategy.addFilter('Nodes__c', new Set<Object>{filterNode});
		}else{
			if(nodesRetrieve == null ) nodesRetrieve = MobilityCampaignProcessing.retrieveNodes(agencyCode, nodesString);

			List<String> filterNodes = new List<String>();
			if(nodesRetrieve != null){
				for(Node__c node : nodesRetrieve){
					String filter = String.format('Nodes__c LIKE \'\'%{0}%\'\'', new List<Object> {
						node.Node_unique_code__c
					});

					filterNodes.add(filter);
				}
			}

			if(filterNodes.size() > 0){
				String filterString = String.join(filterNodes, ' OR ');
				String filterQuery = '!QUERY(' + filterString + ')';
				
				strategy.addFilter('Nodes__c', new Set<Object>{filterQuery});
			}
		}
		
		DebugEnd();
		return strategy;
	}

	public static Map<String, String> getOwerList(String campaignId, SObjectTable.SObjectStrategy strategy){
		DebugStart('MobilityCampaignProcessing', 'getOwerList');
		Debug('campaignId', campaignId);

		Map<String, String> result = new Map<String, String>();

		SObjectTable.QueryType queryType = strategy.getQueryType();
		queryType.limitRecords = 0;
		queryType.offsetRecords = -1;
		queryType.fieldsSet = new Set<String>{'Owner__c', 'Owner__r.Name OwnerName'}; 
		queryType.groupBy = new Set<String>{'Owner__c', 'Owner__r.Name'}; 

		String query =  queryType.getQuery();
		Debug('query', query);

		List<AggregateResult> aggreateResults = Database.query(query);
		for(AggregateResult aggregate : aggreateResults){
			String ownerId = (String)aggregate.get('Owner__c');
			String ownerName = (String)aggregate.get('OwnerName');

			result.put(ownerName, ownerId);
		}

		DebugEnd();
		return result;
	}

	@AuraEnabled
	public static MobilityCampaignProcessingResponse initData(String campaignId){
		DebugStart('MobilityCampaignProcessing', 'initData');

		MobilityCampaignProcessingResponse response = new MobilityCampaignProcessingResponse();

		try {
			Campaign campaign = MobilityCampaignProcessing.getCampaign(campaignId);

			User currentUser = MobilityUserController.getCurrentUser();
			response.currentUser = currentUser;
			
			String agencyCode = currentUser.Agency_Code__c;
			String nodesString = currentUser.Nodes__c;
			String contactValueString = campaign.Contact_Value__c;

			List<Node__c> listNodeObject = MobilityCampaignProcessing.retrieveNodes(agencyCode, nodesString);

			Map<String,String> nodes = MobilityCampaignProcessing.retrieveNodesMap(agencyCode, nodesString, listNodeObject);
			response.nodes = nodes;
			
			Map<String,String> clientIndices = MobilityCampaignProcessing.getClientIndexMap();
			response.clientIndices = clientIndices;
			
			Map<String,String> opportunityStatus = MobilityCampaignProcessing.getOpportunityStatus();
			response.opportunityValues = opportunityStatus;
			
			Map<String,String> priorityValues = MobilityCampaignProcessing.getClientPriority();
			response.priorityValues = priorityValues;

			Map<String,String> subStatus = MobilityCampaignProcessing.getSubStatus(campaign.Recordtype.DeveloperName);
			response.campaignMemberSubStatus = subStatus;

			Map<String,String> contactValues = MobilityCampaignProcessing.getContactValues(contactValueString);
			response.contactValues = contactValues;

			SObjectTable.SObjectStrategy strategy = MobilityCampaignProcessing.getCampaignMember(campaignId, currentUser, listNodeObject);
			
			response.campaign = campaign;
			response.campaignMemberStatus = MobilityCampaignProcessing.getCampaignMemberStatus(campaignId, campaign.Recordtype.DeveloperName);
			response.listOwner = MobilityCampaignProcessing.getOwerList(campaignId, strategy);

			response.isSuccess = true;
		} catch (MobilityCampaignProcessingException ex) {
			response.errorMessage = ex.getMessage();
		}

		Debug('response', response);
		DebugEnd();
		return response;
	}


}