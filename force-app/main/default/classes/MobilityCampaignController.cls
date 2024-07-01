public with sharing class MobilityCampaignController extends MobilityAbstract {

	public class MobilityCampaignException extends Exception {}
	public class MobilityCampaignResponse extends MobilityResponse {}
	public class MobilityCampaignNavigateResponse extends MobilityResponse {
		@AuraEnabled public String campaignMemberId;
	}

	public class MobilityGetCounter extends MobilityResponse{
		@AuraEnabled public List<Campaign> campaignsList;
		@AuraEnabled public Map<String,Decimal> getCampaignsCounters = new Map<String,Decimal>();
		@AuraEnabled public Map<String,Decimal> getCampaignClosedMember = new Map<String,Decimal>();
		@AuraEnabled public Map<String,Decimal> getCampaignPriority = new Map<String,Decimal>();
	}

	@AuraEnabled(cacheable = true) public static List<Campaign> getCampaigns() {
		DebugStart('MobilityCampaignController', 'getCampaigns');

		List<Campaign> campaigns = MobilityCampaignController.getCampaigns(100);
		Debug('campaigns', campaigns);

		DebugEnd();
		return campaigns;
	}

	@AuraEnabled public static List<Campaign> getCampaigns(Integer limitRows) {
		DebugStart('MobilityCampaignController', 'getCampaigns');
		Debug('limitRows', limitRows);
        List < Campaign > campaigns;
		User userCurrent = MobilityUserController.getCurrentUser();
        if(userCurrent.Profile.Name.equalsIgnoreCase('NFE - AAI - Vendite Solo Assistenza')){
            campaigns = new List<Campaign>();
        }
        else{
            campaigns= [
			SELECT Id, Name, NumberOfContacts, NumberOfLeads, NumberOfClosed__c, NumberOfPriority__c, EndDate, RecordType.DeveloperName
			FROM Campaign
			WHERE Status IN('Planned', 'On-going')
			AND RecordType.DeveloperName IN('Data_Enrichment_Campaign', 'Informative_Campaign', 'Marketing_campaign', 'Agency_campaign')
			ORDER BY TECH_Order_Index__c DESC
			LIMIT: limitRows
		];
        }
		Debug('campaigns', campaigns);

		DebugEnd();
		return campaigns;
	}

	public static Map<String,Decimal> getCountValues(List<AggregateResult> counterTarget){
		Map<String,Decimal> result = new Map<String,Decimal>();

		for (AggregateResult ct: counterTarget) {
			Decimal countData = (Decimal) ct.get('countData');
			String campaignId = (String) ct.get('CampaignId');
			result.put(CampaignId, countData);
		}

		return result;
	}

	@AuraEnabled public static MobilityCampaignController.MobilityGetCounter getCountersWidget(Integer limitRows) {
		DebugStart('MobilityCampaignController', 'getCountersWidget');

		MobilityGetCounter response = new MobilityGetCounter();

		try{
			User userCurrent = MobilityUserController.getCurrentUser();

			List < Campaign > campaigns = MobilityCampaignController.getCampaigns(limitRows);
			response.campaignsList = campaigns;
			Debug('campaigns', campaigns);


			List < String > ids = new List < String > ();
			for (Campaign campaign: campaigns) {
				ids.add(campaign.Id);
			}
			Debug('ids', ids);

			List<AggregateResult> counterTarget = [ // NOPMD  Fix CRUD violation
				SELECT Count(Id) countData, CampaignId
				FROM CampaignMember
				WHERE CampaignId in: ids
				AND Agency_Code__c = :userCurrent.Agency_Code__c
				AND Partner_Role_Visibility__c = true
				
				GROUP BY CampaignId
			];

			List<AggregateResult> counterTargetClosed = [ // NOPMD  Fix CRUD violation
				SELECT count(id) countData, CampaignId
				FROM CampaignMember
				WHERE CampaignId in: ids
				AND Status NOT IN ('Da assegnare', 'Da contattare', 'Da lavorare')
				AND Agency_Code__c = :userCurrent.Agency_Code__c
				AND Partner_Role_Visibility__c = true
				
				GROUP BY CampaignId
			];

			List<AggregateResult> counterPriority = [ // NOPMD  Fix CRUD violation
				SELECT count(id) countData, CampaignId
				FROM CampaignMember
				WHERE CampaignId in: ids
				//AND Sottostato__c IN ('Richiesta di contatto da Email', 'Richiesta di contatto da Email', 'Richiesta di contatto da SMS')
				AND Cliente_Prioritario__c = true
				AND Agency_Code__c = :userCurrent.Agency_Code__c
				AND Partner_Role_Visibility__c = true
				
				GROUP BY CampaignId
			];

			Debug('counterTarget', counterTarget);
			Debug('getCampaignsCounters', response.getCampaignsCounters);
			Debug('counterTargetClosed', counterTargetClosed);
			Debug('counterPriority', counterPriority);

			response.getCampaignsCounters = MobilityCampaignController.getCountValues(counterTarget);
			response.getCampaignClosedMember = MobilityCampaignController.getCountValues(counterTargetClosed);
			response.getCampaignPriority = MobilityCampaignController.getCountValues(counterPriority);
			
			Debug('getCampaignClosedMember', response.getCampaignClosedMember);

			response.isSuccess = true;
		}catch(MobilityCampaignException ex){
			response.errorMessage = ex.getMessage();
		}

		Debug('response', response);
		DebugEnd();
		return response;
	}

	@AuraEnabled(cacheable = true) public static List < CampaignMember > getCampaignCustomer(Integer limitRows, String ndgId) {
		DebugStart('MobilityCampaignController', 'getCampaignCustomer');
		Debug('limitRows', limitRows);
		Debug('ndgId', ndgId);

		List < CampaignMember > campaignCustomers = [
			SELECT Id, Campaign.Id, Contact.Account.NDG__c, Campaign.Name, Campaign.EndDate,
			Campaign.RecordType.DeveloperName,Campaign.Campagna_creata_da_Direzione_Agente__c, Status
			FROM CampaignMember
			WHERE Campaign.Status IN('Planned', 'On-going') AND Campaign.RecordType.DeveloperName IN('Data_Enrichment_Campaign', 'Informative_Campaign', 'Marketing_campaign', 'Agency_campaign') AND Contact.Account.NDG__c =: ndgId
			ORDER BY Campaign.EndDate ASC
			LIMIT: limitRows
		];

		Debug('campaignCustomers', campaignCustomers);

		DebugEnd();
		return campaignCustomers;
	}

	@AuraEnabled(cacheable = true) public static CampaignMember getCampaignMember(String campaignId, String ndgId) {
		DebugStart('MobilityCampaignController', 'getCampaignCustomer');
		Debug('campaignId', campaignId);
		Debug('ndgId', ndgId);

		CampaignMember campaignCustomer = [
			SELECT Id, Campaign.Id, Contact.Account.NDG__c, Campaign.Name, Campaign.EndDate,
			Campaign.RecordType.DeveloperName, Status
			FROM CampaignMember
			WHERE Contact.Account.NDG__c =: ndgId
			AND Campaign.Id =: campaignId
			LIMIT 1
		];

		Debug('campaignCustomer', campaignCustomer);

		DebugEnd();
		return campaignCustomer;
	}

	@AuraEnabled 
	public static Map < String, String > getCollaborators(String campaignId) {
		DebugStart('MobilityCampaignController', 'getCollaborators');
		Debug('campaignId', campaignId);

		List<AggregateResult> ownerList = [SELECT Owner__r.Name ownerName, Owner__r.Id ownerId
			FROM CampaignMember
			WHERE Owner__r.isActive = true
			AND CampaignId =: campaignId
			GROUP BY Owner__r.Name, Owner__r.Id
		];

		Map<String, String> result = new Map<String, String>();
		for (AggregateResult campaignMember: ownerList) {
			result.put((String) campaignMember.get('ownerId'), (String) campaignMember.get('ownerName'));
		}

		DebugEnd();
		return result;
	}

	@AuraEnabled 
	public static MobilityCampaignCounters getCounters(String campaignId, String collaboratorId) {
		DebugStart('MobilityCampaignController', 'getCounters');
		Debug('campaignId', campaignId);
		Debug('collaboratorId', collaboratorId);

		User userCurrent = MobilityUserController.getCurrentUser();

		MobilityCampaignCounters counters = new MobilityCampaignCounters(campaignId, collaboratorId, userCurrent.Agency_Code__c);

		DebugEnd();
		return counters;
	}

	public static Set < Object > applyNGD(Map < String, List < Object >> filters) {
		DebugStart('MobilityCampaignController', 'applyNGD');
		Debug('filters', filters);

		String ngdId = null;
		List < Object > ndgList = filters.get('NDG__c');
		Set < Object > campaignIds = new Set < Object > ();
		if (ndgList != null && ndgList.size() > 0) {
			ngdId = (String) ndgList.get(0);

			List < CampaignMember > campaignMembers = MobilityCampaignController.getCampaignCustomer(9999, ngdId);
			for (CampaignMember campaignMember: campaignMembers) {
				campaignIds.add(campaignMember.CampaignId);
			}

			filters.remove('NDG__c');
		} else {
			DebugEnd();
			return null;
		}

		DebugEnd();
		return campaignIds;
	}

	@AuraEnabled
	public static Map<String, Object> campaignsCounters(List<String> ids){
		User userCurrent = MobilityUserController.getCurrentUser();
		Map<String,Decimal> getCampaignsCounters;
		Map<String,Decimal> getCampaignClosedMember;
		Map<String,Decimal> getCampaignPriority;
        if(userCurrent.Profile.Name.equalsIgnoreCase('NFE - AAI - Vendite Solo Assistenza')){
            getCampaignsCounters = new Map<String, Decimal>();
			getCampaignClosedMember = new Map<String, Decimal>();
			getCampaignPriority = new Map<String, Decimal>();
        }
        else{
		List<AggregateResult> counterTarget = [ // NOPMD  Fix CRUD violation
			SELECT Count(Id) countData, CampaignId
			FROM CampaignMember
			WHERE CampaignId in: ids
			AND Agency_Code__c = :userCurrent.Agency_Code__c
			AND Partner_Role_Visibility__c = true
			
			GROUP BY CampaignId
		];

		List<AggregateResult> counterTargetClosed = [ // NOPMD  Fix CRUD violation
			SELECT count(id) countData, CampaignId
			FROM CampaignMember
			WHERE CampaignId in: ids
			AND Status NOT IN ('Da assegnare', 'Da contattare', 'Da lavorare')
			AND Agency_Code__c = :userCurrent.Agency_Code__c
			AND Partner_Role_Visibility__c = true
			
			GROUP BY CampaignId
		];

		List<AggregateResult> counterPriority = [ // NOPMD  Fix CRUD violation
			SELECT count(id) countData, CampaignId
			FROM CampaignMember
			WHERE CampaignId in: ids
			//AND Sottostato__c IN ('Richiesta di contatto da Email', 'Richiesta di contatto da Email', 'Richiesta di contatto da SMS')
			AND Cliente_Prioritario__c = true
			AND Agency_Code__c = :userCurrent.Agency_Code__c
			AND Partner_Role_Visibility__c = true
			
			GROUP BY CampaignId
		];

            getCampaignsCounters = MobilityCampaignController.getCountValues(counterTarget);
            getCampaignClosedMember = MobilityCampaignController.getCountValues(counterTargetClosed);
            getCampaignPriority = MobilityCampaignController.getCountValues(counterPriority);
        }
		Map<String, Object> result = new Map<String,Object>();
		result.put('getCampaignsCounters', getCampaignsCounters);
		result.put('getCampaignClosedMember', getCampaignClosedMember);
		result.put('getCampaignPriority', getCampaignPriority);

		return result;
	}

	@AuraEnabled 
	public static SObjectTable.TablePagination getCampaignsTest(Integer page, Integer perPage, Map < String, List < Object >> filters, String orderField, String orderName, String search) {
		DebugStart('MobilityCampaignController', 'getCampaignsTest');
		Debug('page', page);
		Debug('perPage', perPage);
		Debug('filters', filters);
		Debug('orderField', orderField);
		Debug('orderName', orderName);
		Debug('search', search);

		Set < Object > campaignIds = MobilityCampaignController.applyNGD(filters);
		System.debug('campaignIds: ' + campaignIds);

		SObjectTable.SObjectStrategy strategy = new SObjectTable.SObjectStrategy();
		strategy.fieldsSet = new Set < String > {
			'Id',
			'Name',
			'NumberOfContacts',
			'NumberOfLeads',
			'NumberOfClosed__c',
			'NumberOfPriority__c',
			'StartDate',
			'EndDate',
			'Type',
			'Status',
			'RecordType.DeveloperName',
			'CampaignType__c',
			'TECH_Order_Index__c',
			'Campagna_creata_da_Direzione_Agente__c',
			'IncentiveCampaign__c'
		};

		strategy.sobjectName = 'Campaign';
		strategy.searchColumns = new Set < String > {
			'Name',
			'Status',
			'Type'
		};

		strategy.addFilter('Status', new Set < Object > {
			'Planned',
			'On-going',
			'Completed',
			'Aborted'
		});
		strategy.addFilter('RecordType.DeveloperName', new Set < Object > {
			'Data_Enrichment_Campaign',
			'Informative_Campaign',
			'Marketing_campaign',
			'Performa_campaign',
			'Informative_Campaign_PCC_MyAXA',
			'Agency_campaign'
		});

		strategy.addFilter('Campagna_creata_da_Direzione_Agente__c',  new Set < Object > {
			false
		});

		if (campaignIds != null) {
			if (campaignIds.size() == 0) {
				Blob requestBlob = Blob.valueOf(String.valueOf(DateTime.now().getTime()));
				Blob hash = Crypto.generateDigest('MD5', requestBlob);

				campaignIds.add(EncodingUtil.convertToHex(hash));
				strategy.addFilter('Name', campaignIds);
			} else {
				strategy.addFilter('Id', campaignIds);
			}
		}

		strategy.setOrderDesc('TECH_Order_Index__c');

		//INPUT DATA
		strategy.perPage = perPage;
		strategy.page = page;
		strategy.searchString = search;
		strategy.setOrder(orderField, orderName, true);
		strategy.addFilters(filters, true);

		//RESPONSE
		SObjectTable.TablePagination tableElement; 
        User userCurrent = MobilityUserController.getCurrentUser();
        if(userCurrent.Profile.Name.equalsIgnoreCase('NFE - AAI - Vendite Solo Assistenza')){
           tableElement=new SObjectTable.TablePagination(new List<Object>(), 0, 1, 1, 1, 0);
		}
        else{
           tableElement = SObjectTable.paginationData(strategy);
        }
		tableElement.columns = new List < String > {
			'Name',
			'CampaignType__c',
			'Type',
			'StartDate',
			'EndDate',
			'Status'
		};
		tableElement.labels = new Map < String, String > {
			'Name' => 'Nome',
			'Type' => 'Tipologia',
			'StartDate' => 'Data inizio',
			'EndDate' => 'Data fine',
			'Status' => 'Stato',
			'CampaignType__c' => 'Tipo Campagna'
		};

		//ADD COUNTERS
		List<String> campaignsIds = new List<String>();
		for(Object element : tableElement.elements){
			Campaign campaign = (Campaign)element;

			campaignsIds.add(campaign.Id);
		}

		//tableElement.additionalData = MobilityCampaignController.campaignsCounters(campaignsIds);

		DebugEnd();
		return tableElement;
	}

	@AuraEnabled(cacheable = true)
	public static SObjectTable.TablePagination getOpportunity(Integer page, Integer perPage, Map < String, List < Object >> filters, String orderField, String orderName, String search) {
		DebugStart('MobilityCampaignController', 'getOpportunity');
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
			'Amount',
			'CreatedDate',
			'CloseDate',
			'Account.Name',
			'Account.NDG__c',
			'Owner.Name',
			'CampaignId'
		};

		strategy.sobjectName = 'Opportunity';

		strategy.searchColumns = new Set < String > {
			'Name',
			'StageName',
			'Account.Name'
		};

		//setOrderDesc
		//setOrderAsc
		strategy.setOrderDesc('CreatedDate');

		//INPUT DATA
		strategy.perPage = perPage;
		strategy.page = page;
		strategy.searchString = search;
		strategy.setOrder(orderField, orderName, true);
		strategy.addFilters(filters, true);

		/**
         * Retrieve Current User
         */
        User currentUser = [ // NOPMD  Fix CRUD violation
            SELECT CommunityNickname, Email, Profile.Name, UserRole.Name, UserRole.PortalRole
            FROM User
            WHERE Id =: Userinfo.getUserId() 
        ];
		String currentRole = currentUser.UserRole.PortalRole;

		if(currentRole == 'Worker'){
			strategy.addFilter('OwnerId', new Set<Object>{Userinfo.getUserId()});
		}

		//RESPONSE
		SObjectTable.TablePagination tableElement = SObjectTable.paginationData(strategy);
		tableElement.columns = new List < String > {
			'Name',
			'StageName',
			'Amount',
			'CreatedDate',
			'CloseDate',
			'Account',
			'Owner'
		};

		tableElement.labels = new Map < String, String > {
			'Name' => 'Nome trattativa',
			'StageName' => 'Fase',
			'Amount' => 'Ammontare',
			'CreatedDate' => 'Data creazione',
			'CloseDate' => 'Data chiusura',
			'Account' => 'Nome cliente',
			'Owner' => 'Nome completo titolare'
		};

		Debug('tableElement', tableElement);
		DebugEnd();
		return tableElement;
	}

	@AuraEnabled(cacheable = true) public static SObjectTable.TablePagination getActivities(Integer page, Integer perPage, Map < String, List < Object >> filters, String orderField, String orderName, String search) {
		DebugStart('MobilityCampaignController', 'getActivities');
		Debug('page', page);
		Debug('perPage', perPage);
		Debug('filters', filters);
		Debug('orderField', orderField);
		Debug('orderName', orderName);
		Debug('search', search);

		SObjectTable.SObjectStrategy strategy = new SObjectTable.SObjectStrategy();
		strategy.fieldsSet = new Set < String > {
			'Id',
			'Subject',
			'Who.Name',
			'Owner.Name',
			'ActivityDate',
			'Status',
			'Priority',
			'WhatId'
		};

		strategy.sobjectName = 'Task';

		strategy.searchColumns = new Set < String > {
			'Subject',
			'Who.Name',
			'Owner.Name',
			'Status',
			'Priority'
		};

		strategy.addFilter('Status', new Set < Object > {
			'Open'
		});

		//setOrderDesc
		//setOrderAsc
		strategy.setOrderAsc('ActivityDate');

		//INPUT DATA
		strategy.perPage = perPage;
		strategy.page = page;
		strategy.searchString = search;
		strategy.setOrder(orderField, orderName, true);
		strategy.addFilters(filters, true);

		//RESPONSE
		SObjectTable.TablePagination tableElement = SObjectTable.paginationData(strategy);
		tableElement.columns = new List < String > {
			'Subject',
			'Who',
			'Owner',
			'ActivityDate',
			'Status',
			'Priority'
		};

		tableElement.labels = new Map < String, String > {
			'Subject' => 'Oggetto',
			'Who' => 'Nome',
			'Owner' => 'Assegnato a',
			'ActivityDate' => 'Data limite',
			'Status' => 'Stato',
			'Priority' => 'Priorità'
		};

		Debug('tableElement', tableElement);
		DebugEnd();
		return tableElement;
	}

	@AuraEnabled(cacheable = true) public static SObjectTable.TablePagination getHistory(Integer page, Integer perPage, Map < String, List < Object >> filters, String orderField, String orderName, String search) {
		DebugStart('MobilityCampaignController', 'getHistory');
		Debug('page', page);
		Debug('perPage', perPage);
		Debug('filters', filters);
		Debug('orderField', orderField);
		Debug('orderName', orderName);
		Debug('search', search);

		SObjectTable.SObjectStrategy strategy = new SObjectTable.SObjectStrategy();
		strategy.fieldsSet = new Set < String > {
			'Id',
			'Subject',
			'Who.Name',
			'Owner.Name',
			'ActivityDate',
			'Status',
			'LastModifiedDate',
			'WhatId'
		};

		strategy.sobjectName = 'Task';

		strategy.searchColumns = new Set < String > {
			'Subject',
			'Who.Name',
			'Owner.Name'
		};

		strategy.addFilter('Status', new Set < Object > {
			'Completed'
		});

		//setOrderDesc
		//setOrderAsc
		strategy.setOrderDesc('LastModifiedDate');

		//INPUT DATA
		strategy.perPage = perPage;
		strategy.page = page;
		strategy.searchString = search;
		strategy.setOrder(orderField, orderName, true);
		strategy.addFilters(filters, true);

		//RESPONSE
		SObjectTable.TablePagination tableElement = SObjectTable.paginationData(strategy);
		tableElement.columns = new List < String > {
			'Subject',
			'Who',
			'ActivityDate',
			'Owner',
			'LastModifiedDate'
		};

		tableElement.labels = new Map < String, String > {
			'Subject' => 'Oggetto',
			'Who' => 'Nome',
			'ActivityDate' => 'Data limite',
			'Owner' => 'Assegnato a',
			'LastModifiedDate' => 'Data/ora ultima modifica'
		};

		Debug('tableElement', tableElement);
		DebugEnd();
		return tableElement;
	}

	@AuraEnabled
	public static SObjectTable.TablePagination getDataEnrichment(Integer page, Integer perPage, Map < String, List < Object >> filters, String orderField, String orderName, String search) {
		DebugStart('MobilityCampaignController', 'getDataEnrichment');
		Debug('page', page);
		Debug('perPage', perPage);
		Debug('filters', filters);
		Debug('orderField', orderField);
		Debug('orderName', orderName);
		Debug('search', search);
		Debug('campaignId', filters.get('CampaignId'));

		String campaignId = (String)(filters.get('CampaignId'))[0];

		SObjectTable.SObjectStrategy strategy = MobilityCampaignProcessing.getCampaignMember(campaignId);

		strategy.searchColumns = new Set < String > {
			'TECH_Account_Name__c',
			'Status',
			'Sottostato__c',
			'Nodes__c',
			'Owner__r.Name'
		};

		//setOrderDesc
		//setOrderAsc
		//strategy.setOrderAsc('StartDateTime');

		//INPUT DATA 
		strategy.perPage = perPage;
		strategy.page = page;
		strategy.searchString = search;
		strategy.setOrder(orderField, orderName, true);
		strategy.addFilters(filters, true);

		//RESPONSE
		SObjectTable.TablePagination tableElement = SObjectTable.paginationData(strategy);
		tableElement.columns = new List < String > {
			'TECH_Account_Name__c',
			'TECH_Account_Active_Insurance_Contracts__c',
			'TECH_Account_Active_Campaigns__c',
			'TECH_Client_Index__c',
			'Contact_Priority__c',
			'TECH_First_expiration_date__c',
			'Status',
			'Sottostato__c',
			'Nodes__c',
			'Owner__r',
			'Data_Enrichment_Target_Phone__c',
			'Data_Enrichment_Target_Email__c',
			'Data_Enrichment_Target_Consensus__c',
			'Data_Enrichment_Target_Other__c',
			'LastModifiedDate'
		};

		tableElement.labels = new Map < String, String > {
			'TECH_Account_Name__c' => 'Nome e Cognome',
			'TECH_Account_Active_Insurance_Contracts__c' => 'Polizze attive',
			'TECH_Account_Active_Campaigns__c' => 'Campagne attive',
			'TECH_Client_Index__c' => 'Indice Cliente',
			'Contact_Priority__c' => 'Propensione acquisto',
			'TECH_First_expiration_date__c' => 'Prima Scadenza',
			'Status' => 'Stato',
			'Sottostato__c' => 'Tracking contatto',
			'Nodes__c' => 'Nodo',
			'Owner__r' => 'Titolare',
			'Data_Enrichment_Target_Phone__c' => 'Cellulare',
			'Data_Enrichment_Target_Email__c' => 'E-mail',
			'Data_Enrichment_Target_Consensus__c' => 'Consensi',
			'Data_Enrichment_Target_Other__c' => 'Altri dati',
			'LastModifiedDate' => 'Ultima modifica' //formato dd-MM-yyyy HH:mm:ss
		};

		Debug('tableElement', tableElement);
		DebugEnd();
		return tableElement;
	}

	@AuraEnabled
	public static SObjectTable.TablePagination getInformative(Integer page, Integer perPage, Map < String, List < Object >> filters, String orderField, String orderName, String search) {
		DebugStart('MobilityCampaignController', 'getInformative');
		Debug('page', page);
		Debug('perPage', perPage);
		Debug('filters', filters);
		Debug('orderField', orderField);
		Debug('orderName', orderName);
		Debug('search', search);
		Debug('campaignId', filters.get('CampaignId'));

		String campaignId = (String)(filters.get('CampaignId'))[0];

		SObjectTable.SObjectStrategy strategy = MobilityCampaignProcessing.getCampaignMember(campaignId);

		strategy.searchColumns = new Set < String > {
			'TECH_Account_Name__c',
			'Status',
			'Nodes__c',
			'Informative_Contact_Outcome__c',
			'Owner__r.Name'
		};

		//setOrderDesc
		//setOrderAsc
		//strategy.setOrderAsc('StartDateTime');

		//INPUT DATA 
		strategy.perPage = perPage;
		strategy.page = page;
		strategy.searchString = search;
		strategy.setOrder(orderField, orderName, true);
		strategy.addFilters(filters, true);

		//RESPONSE
		SObjectTable.TablePagination tableElement = SObjectTable.paginationData(strategy);
		tableElement.columns = new List < String > {
			'TECH_Account_Name__c',
			'TECH_Account_Active_Insurance_Contracts__c',
			'TECH_Account_Active_Campaigns__c',
			'TECH_Client_Index__c',
			'TECH_First_expiration_date__c',
			'Status',
			'Informative_Contact_Outcome__c',
			'Nodes__c',
			'Owner__r',
			'LastModifiedDate'
		};

		tableElement.labels = new Map < String, String > {
			'TECH_Account_Name__c' => 'Nome e Cognome',
			'TECH_Account_Active_Insurance_Contracts__c' => 'Polizze attive',
			'TECH_Account_Active_Campaigns__c' => 'Campagne attive',
			'TECH_Client_Index__c' => 'Indice Cliente',
			'TECH_First_expiration_date__c' => 'Prima Scadenza',
			'Status' => 'Stato',
			'Informative_Contact_Outcome__c' => 'Esito di contatto informativo',
			'Nodes__c' => 'Nodo',
			'Owner__r' => 'Titolare',
			'LastModifiedDate' => 'Ultima modifica effettutata' //formato dd-MM-yyyy HH:mm:ss
		};

		Debug(' tableElement', tableElement);
		DebugEnd();
		return tableElement;
	}

	@AuraEnabled
	public static SObjectTable.TablePagination getAgency(Integer page, Integer perPage, Map < String, List < Object >> filters, String orderField, String orderName, String search) {
		DebugStart(' MobilityCampaignController', ' getAgency ');
		Debug(' page', page);
		Debug(' perPage', perPage);
		Debug(' filters', filters);
		Debug(' orderField', orderField);
		Debug(' orderName', orderName);
		Debug(' search', search);
		Debug('campaignId', filters.get('CampaignId'));

		String campaignId = (String)(filters.get('CampaignId'))[0];

		SObjectTable.SObjectStrategy strategy = MobilityCampaignProcessing.getCampaignMember(campaignId);

		strategy.searchColumns = new Set < String > {
			'TECH_Account_Name__c',
			'Status',
			'Nodes__c',
			'Owner__r.Name',
			'Stato_Opportunit_Custom__c'
		};

		//setOrderDesc
		//setOrderAsc
		//strategy.setOrderAsc('StartDateTime');

		//INPUT DATA 
		strategy.perPage = perPage;
		strategy.page = page;
		strategy.searchString = search;
		strategy.setOrder(orderField, orderName, true);
		strategy.addFilters(filters, true);

		//RESPONSE
		SObjectTable.TablePagination tableElement = SObjectTable.paginationData(strategy);
		tableElement.columns = new List < String > {
			'TECH_Account_Name__c',
			'TECH_Account_Active_Insurance_Contracts__c',
			'TECH_Account_Active_Campaigns__c',
			'TECH_Client_Index__c',
			'TECH_First_expiration_date__c',
			'Status',
			'Nodes__c',
			'Owner__r',
			'Stato_Opportunit_Custom__c',
			'TECH_task_date_created__c'
		};

		tableElement.labels = new Map < String, String > {
			'TECH_Account_Name__c' => 'Nome e Cognome',
			'TECH_Account_Active_Insurance_Contracts__c' => 'Polizze attive',
			'TECH_Account_Active_Campaigns__c' => 'Campagne attive',
			'TECH_Client_Index__c' => 'Indice Cliente',
			'TECH_First_expiration_date__c' => 'Prima Scadenza',
			'Status' => 'Stato',
			'Nodes__c' => 'Nodo',
			'Owner__r' => 'Titolare',
			'Stato_Opportunit_Custom__c' => 'Stato Trattativa',
			'TECH_task_date_created__c'=> 'Ultimo contatto' //formato dd-MM-yyyy
		};

		Debug(' tableElement', tableElement);
		DebugEnd();
		return tableElement;
	}

	@AuraEnabled
	public static SObjectTable.TablePagination getMarketing(Integer page, Integer perPage, Map < String, List < Object >> filters, String orderField, String orderName, String search) {
		DebugStart(' MobilityCampaignController', ' getMarketing ');
		Debug(' page', page);
		Debug(' perPage', perPage);
		Debug(' filters', filters);
		Debug(' orderField', orderField);
		Debug(' orderName', orderName);
		Debug('campaignId', filters.get('CampaignId'));

		String campaignId = (String)(filters.get('CampaignId'))[0];

		SObjectTable.SObjectStrategy strategy = MobilityCampaignProcessing.getCampaignMember(campaignId);

		strategy.searchColumns = new Set < String > {
			'TECH_Account_Name__c',
			'Status',
			'Sottostato__c',
			'Nodes__c',
			'Owner__r.Name',
			'Stato_Opportunit_Custom__c'
		};

		//setOrderDesc
		//setOrderAsc
		//strategy.setOrderAsc('StartDateTime');

		//INPUT DATA 
		strategy.perPage = perPage;
		strategy.page = page;
		strategy.searchString = search;
		strategy.setOrder(orderField, orderName, true);
		strategy.addFilters(filters, true);

		//RESPONSE
		SObjectTable.TablePagination tableElement = SObjectTable.paginationData(strategy);
		tableElement.columns = new List < String > {
			'TECH_Account_Name__c',
			'TECH_Account_Active_Insurance_Contracts__c',
			'TECH_Account_Active_Campaigns__c',
			'TECH_Client_Index__c',
			'Contact_Priority__c',
			'TECH_First_expiration_date__c',
			'Status',
			'Sottostato__c',
			'Nodes__c',
			'Owner__r',
			'Stato_Opportunit_Custom__c',
			'TECH_task_date_created__c'
		};

		tableElement.labels = new Map < String, String > {
			'TECH_Account_Name__c' => 'Nome e Cognome',
			'TECH_Account_Active_Insurance_Contracts__c' => 'Polizze attive',
			'TECH_Account_Active_Campaigns__c' => 'Campagne attive',
			'TECH_Client_Index__c' => 'Indice Cliente',
			'Contact_Priority__c' => 'Propensione acquisto',
			'TECH_First_expiration_date__c' => 'Prima Scadenza',
			'Status' => 'Stato',
			'Sottostato__c' => 'Tracking contatto',
			'Nodes__c' => 'Nodo',
			'Owner__r' => 'Titolare',
			'Stato_Opportunit_Custom__c' => 'Stato Trattativa',
			'TECH_task_date_created__c'=> 'Ultimo contatto' //formato dd-MM-yyyy
		};

		Debug(' tableElement', tableElement);
		DebugEnd();
		return tableElement;
	}

	@AuraEnabled public static MobilityCampaignNavigateResponse navitateByCustomer(String campaignId, String ndgId) {
		DebugStart('MobilityCampaignController', 'navitateByCustomer');

		MobilityCampaignNavigateResponse response = new MobilityCampaignNavigateResponse();

		try {
			CampaignMember campaignMember = MobilityCampaignController.getCampaignMember(campaignId, ndgId);

			response.campaignMemberId = campaignMember.Id;
			response.isSuccess = true;
		} catch (MobilityCampaignException ex) {
			response.errorMessage = ex.getMessage();
		}

		Debug('response', response);
		DebugEnd();
		return response;
	}

	// metodo prende il picklist da metadata per AF, per la configurazione dei Recordtypes x opzioni della picklist
	@AuraEnabled
    public static List < Map < String, String >> getPickListValuesFromMTD() {
        List < Map < String, String >> options = new List < Map < String, String >> ();
       
		List<Lista_Campagne_NFE_filtro__mdt> listMtdsRecords = [select Label__c, Value__c, Developer_Value__c from Lista_Campagne_NFE_filtro__mdt ]; // NOPMD  Fix CRUD violation

        for (Lista_Campagne_NFE_filtro__mdt f: listMtdsRecords) {
            Map < String, String > values = new Map < String, String > {
                'label' => f.Label__c,
                'value' => f.Developer_Value__c
            };
			
            options.add(values);
        }
        return options;
    }
}