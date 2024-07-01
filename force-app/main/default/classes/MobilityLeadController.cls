public with sharing class MobilityLeadController extends MobilityAbstract{ 
	public class MobilityLeadException extends Exception{
	}

	public class MobilityLeadEmailResponse extends MobilityResponse{
		@AuraEnabled public String fromEmail;
		@AuraEnabled public String toEmail;
		@AuraEnabled public Lead lead;
		@AuraEnabled public User currentUser;

	}

	public class MobilityLeadResponse extends MobilityResponse{
		@AuraEnabled public List<Account> results;
		@AuraEnabled public Boolean isDuplicated;
		@AuraEnabled public Boolean isDuplicatedContext;
		@AuraEnabled public Boolean canConvertLead;
		@AuraEnabled public Boolean hasDuplicateLead;
		@AuraEnabled public String currentUserId = UserInfo.getuserid();
	}

	public class MobilityLeadActivitiesResponse extends MobilityResponse{
		@AuraEnabled public List<Event> listEvent;
		@AuraEnabled public List<Task> listTask;
	}

	public class MobilityCountryCodesResponse extends MobilityResponse{
		@AuraEnabled public List<String> countries;
	}

	public class MobilityTimeStock{
		@AuraEnabled public Integer days;
		@AuraEnabled public Integer hours;
		@AuraEnabled public Integer minutes;
		@AuraEnabled public Integer seconds;
		@AuraEnabled public String stringValue;
	}

	@AuraEnabled
	public static ContactHistoryCTRL.ResponseDto getContactHistory(Integer limitRows, String leadId){
		List < Id > ids = new List < Id > {
			leadId
		};
		Integer limitResult = limitRows;

		ContactHistoryCTRL.ResponseDto response = ContactHistoryCTRL.getHistoryItemWrappers(ids, limitResult);

		return response;
	}

	@AuraEnabled
	public static SObjectTable.TablePagination getContactHistoryPage(String leadId, Integer page, Integer perPage, Integer maxPerPage, Integer lengthList){
		ContactHistoryCTRL.ResponseDto response = MobilityLeadController.getContactHistory(99, leadId);

		List<ContactHistoryCTRL.HistoryItemWrapper> datalist = (List<ContactHistoryCTRL.HistoryItemWrapper>)response.values.get('ContactHistoryList');

		System.debug(datalist);

		SObjectTable.TablePagination pagination = new SObjectTable.TablePagination(
			datalist, //elements
		datalist.size(),  //total
		page,  //page
		perPage,  //perPage
		maxPerPage,  //maxPerPage
		lengthList,  //lengthList
		true //hasFullData
		);

		System.debug(JSON.serialize(pagination));

		return pagination;
	}

	@AuraEnabled
	public static SObjectTable.TablePagination getAgencyUsers(Integer page, Integer perPage){
		DebugStart('MobilityLeadController', 'getAgencyUsers');

		Integer lengthList = 5;
		Integer maxPerPage = 100;
		String phone;
		agencyQueueManagerUtilities.ResponseDto agencyUsers = agencyQueueManagerUtilities.getAgencyUsers('Lead');
		List<agencyQueueManagerUtilities.userInQueue> elements = (List<agencyQueueManagerUtilities.userInQueue>)agencyUsers.values.get('userList');

		List<Map<String, Object>> datalist = new List<Map<String, Object>>();

		if (elements != null){
			for (agencyQueueManagerUtilities.userInQueue userQueue : elements){
				Map<String, Object> value = new Map<String, Object>();

				User singleUser = (User)userQueue.singleUser;
				if(phone == null && singleUser.Contact != null && singleUser.contact.Account != null){
					phone = singleUser.contact.Account.MobilePhone__c;
				}
				value.put('Id', singleUser.Id);
				value.put('UserName', singleUser.UserName);
				value.put('CommunityNickname', singleUser.CommunityNickname);
				value.put('ProfileName', singleUser.Profile.Name);
				value.put('IsActive    ', singleUser.IsActive);
				value.put('UserRoleName', singleUser.UserRole.Name);
				value.put('Email', singleUser.Email);
				value.put('FirstName', singleUser.FirstName);
				value.put('LastName', singleUser.LastName);
				value.put('Agency_code__c', singleUser.Agency_code__c);
				value.put('Nodes__c', singleUser.Nodes__c);
				value.put('isInQueue', userQueue.isInQueue);

				datalist.add(value);
			}
		}

		SObjectTable.TablePagination tableElement = new SObjectTable.TablePagination(
			datalist, //elements
		datalist.size(),  //total
		page,  //page
		perPage,  //perPage
		maxPerPage,  //maxPerPage
		lengthList,  //lengthList
		true //hasFullData
		);

		tableElement.columns = new List<String>{
			'FirstName', 
			'LastName', 
			'UserName', 
			'Nodes__c', 
			'Email', 
			'ProfileName', 
			'UserRoleName'
		};

		tableElement.labels = new Map<String, String>{
			'FirstName' => Label.leadQueue_firstName, 
			'LastName' => Label.leadQueue_lastName, 
			'UserName' => Label.leadQueue_userName, 
			'Nodes__c' => Label.leadQueue_nodes, 
			'Email' => Label.leadQueue_email, 
			'ProfileName' => Label.leadQueue_profileName, 
			'UserRoleName' => Label.leadQueue_userRoleName
		};

		if (String.isNotBlank(agencyUsers.message)){
			tableElement.Message = agencyUsers.message;
		}

		if(String.isNotBlank(phone)){
			tableElement.additionalData.put('MobilePhone', phone);
		}
		
		Debug('tableElement', tableElement);
		DebugEnd();
		return tableElement;
	}

	@AuraEnabled
	public static MobilityLeadResponse saveAgencyUsers(Map<String, Boolean> selectedIds){
		DebugStart('MobilityLeadController', 'saveAgencyUsers');

		MobilityLeadResponse response = new MobilityLeadResponse();

		try{
			List<String> listIds = new List<String>(selectedIds.keySet());
			Debug('selectedIds', selectedIds);
			Debug('listIds', listIds);

			List <User> users = [ // NOPMD  Fix CRUD violation
				SELECT
				Username,
				IsActive,
				Agency_code__c,
				Abilitazione_CTL__c,
				Abilitazione_IVASS41__c
			                    FROM User
				WHERE Id IN: listIds 
			];

			Debug('users', users);

			List<Boolean> listBoolean = new List<Boolean>();
			for (String key : selectedIds.keySet()){
				Boolean value = selectedIds.get(key);

				listBoolean.add(value);
			}

			Debug('listBoolean', listBoolean);

			agencyQueueManagerUtilities.ResponseDto responseDto = agencyQueueManagerUtilities.saveUpdateRequest(listBoolean, users, 'Lead');

			if (!responseDto.isSuccess) throw new MobilityLeadException(responseDto.message);

			response.isSuccess = true;
		} catch (MobilityLeadException ex){
			response.errorMessage = ex.getMessage();
		}

		Debug('response', response);
		DebugEnd();
		return response;
	}

	@AuraEnabled(cacheable = true)
	public static List<Lead> getLeads(){
		return MobilityLeadController.getLeads(100);
	}

	@AuraEnabled(cacheable = true)
	public static List<Lead> getLeads(Integer limitRows){
		DebugStart('MobilityLeadController', 'getLeads');
		Debug('limitRows', limitRows);
		List<Lead> leadList;
		User userCurrent = MobilityUserController.getCurrentUser();
		if (!userCurrent.Profile.Name.equalsIgnoreCase('NFE - AAI - Vendite Solo Assistenza')){
             leadList = [
			SELECT Id, Gi_cliente_AXA__c, Name, Landing_Page__c, Phone, Email, Status
			            FROM lead
            WHERE RecordType.DeveloperName IN('Lead_AXA_Assicurazioni', 'eCommerce','Lead_MPS')
			AND Status IN('Appointment', 'Call again', 'To be Processed')
			AND IsConverted = false
			            ORDER BY TECH_Order_Index__c desc
			LIMIT: limitRows
		];

			Debug('leadList', leadList);
			DebugEnd();
        }
        else{
			leadList = new List<Lead>();
		}
		return leadList;
	}

	@AuraEnabled
	public static SObjectTable.TablePagination getLeadListView(Integer page, Integer perPage, Map<String, List<Object>> filters, String orderField, String orderName, String search){
		SObjectTable.SObjectStrategy strategy = new SObjectTable.SObjectStrategy();
		strategy.fieldsSet = new Set<String>{'Id', 'LeadSource', 'Dettaglio__c', 'Name', 'Company', 'State', 'Phone', 'Email', 'Status', 'Owner.Name', 'CreatedDate', 'Data_scadenza_polizza_c_o_concorrente__c', 'RecordType.DeveloperName', 'TECH_Order_Index__c', 'Landing_Page__c'};

		strategy.sobjectName = 'Lead';

		strategy.searchColumns = new Set<String>{'LeadSource', 'Dettaglio__c', 'Name', 'Company', 'State', 'Phone', 'Email', 'Status', 'Owner.Name'};

		strategy.addFilter('RecordType.DeveloperName', new Set<Object>{'Lead_AXA_Assicurazioni', 'eCommerce', 'Lead_MPS'});

		strategy.addFilter('IsConverted', new Set<Object>{'false'});

		//setOrderDesc
		//setOrderAsc
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
		if (userCurrent.Profile.Name.equalsIgnoreCase('NFE - AAI - Vendite Solo Assistenza')){
			tableElement = new SObjectTable.TablePagination(new List<Object>(), 0, 1, 1, 1, 0);
		} else{
			tableElement = SObjectTable.paginationData(strategy);
		}

		tableElement.columns = new List<String>{'LeadSource', 'Dettaglio__c', 'Name', 'Company', 'Phone', 'Email', 'Status', 'Owner', 'CreatedDate', 'Landing_Page__c'};

		tableElement.labels = new Map<String, String>{'LeadSource' => Label.leadListView_columns_sourceLead, 'Dettaglio__c' => Label.leadListView_columns_detailSourceLead, 'Name' => Label.leadListView_columns_extendedName, 'Company' => Label.leadListView_columns_businessName, 'Phone' => Label.leadListView_columns_phone, 'Email' => Label.leadListView_columns_email, 'Status' => Label.leadListView_columns_statusLead, 'Owner' => Label.leadListView_columns_aliasOwner, 'CreatedDate' => Label.leadListView_columns_createdDate, 'Landing_Page__c' => 'Origine'};


		System.debug('Result: ' + JSON.serialize(tableElement));

		return tableElement;
	}


	@AuraEnabled
	public static SObjectTable.TablePagination proxyGetListView(Integer page, Integer perPage, Map<String, List<Object>> filters, String orderField, String orderName, String search, String defaultFilter){

		system.debug('defaultFilter: '+defaultFilter); 
		List<ListViewCustomFilters__mdt> metadataList = [SELECT Field__c, Value__c FROM ListViewCustomFilters__mdt WHERE FilterName__c =: defaultFilter ]; // NOPMD  Fix CRUD violation
		Map<String, Set<Object>> defaultFilters = new Map<String, Set<Object>>();
		for(ListViewCustomFilters__mdt temp : metadataList){
			if(defaultFilters.containsKey(temp.Field__c)){
				defaultFilters.get(temp.Field__c).add(temp.Value__c);
			}
			else{
				defaultFilters.put(temp.Field__c, new Set<Object> {temp.Value__c});
			}
		}

		SObjectTable.SObjectStrategy strategy = new SObjectTable.SObjectStrategy();
		strategy.fieldsSet = new Set<String>{
			'Id', 
			'LeadSource', 
			'Dettaglio__c', 
			'Name', 
			'Company', 
			'State', 
			'Phone', 
			'Email', 
			'Status', 
			'Owner.Name', 
			'CreatedDate', 
			'Data_scadenza_polizza_c_o_concorrente__c', 
			'RecordType.DeveloperName', 
			'TECH_Order_Index__c', 
			'Landing_Page__c'};

		strategy.sobjectName = 'Lead';
		
		strategy.searchColumns = new Set<String>{
			'LeadSource', 
			'Dettaglio__c', 
			'Name', 
			'Company', 
			'State', 
			'Phone', 
			'Email', 
			'Status', 
			'Owner.Name'
		};

		strategy.addFilter('RecordType.DeveloperName', new Set<Object>{
			'Lead_AXA_Assicurazioni', 
			'eCommerce', 
			'Lead_MPS',
			'Outsource'
		});

		strategy.addFilter('IsConverted', new Set<Object>{
			'false'
		});
		for(String key : defaultFilters.keySet()){
			strategy.addFilter(key, defaultFilters.get(key));
		}
		//setOrderDesc
		//setOrderAsc
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
		if (userCurrent.Profile.Name.equalsIgnoreCase('NFE - AAI - Vendite Solo Assistenza')){
			tableElement = new SObjectTable.TablePagination(new List<Object>(), 0, 1, 1, 1, 0);
		} else{
			tableElement = SObjectTable.paginationData(strategy);
		}

		tableElement.columns = new List < String > {
			'LeadSource',
			'Dettaglio__c',
			'Landing_Page__c', 
			'Name',
			'Company',
			'Phone',
			'Email',
			'Status',
			'Owner',
			'CreatedDate' 
		};

		tableElement.labels = new Map < String, String > {
			'LeadSource' => Label.leadListView_columns_sourceLead,
			'Dettaglio__c' => Label.leadListView_columns_detailSourceLead,
			'Landing_Page__c' => 'Origine', 
			'Name' => Label.leadListView_columns_extendedName,
			'Company' => Label.leadListView_columns_businessName,
			'Phone' => Label.leadListView_columns_phone,
			'Email' => Label.leadListView_columns_email,
			'Status' => Label.leadListView_columns_statusLead,
			'Owner' => Label.leadListView_columns_aliasOwner,
			'CreatedDate' => Label.leadListView_columns_createdDate 
		};


		System.debug('Result: ' + JSON.serialize(tableElement));

		return tableElement;
		//return getLeadListView(page, perPage,filters, orderField, orderName,search);

	}

	@AuraEnabled
	public static SObjectTable.TablePagination getEvent(Integer page, Integer perPage, Map<String, List<Object>> filters, String orderField, String orderName, String search){
		DebugStart('MobilityLeadController', 'getEvent');
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
			'StartDateTime',
			'Owner.Name',
			'WhoId'
		};

		strategy.sobjectName = 'Event';

		strategy.searchColumns = new Set < String > {
			'Subject',
			'Owner.Name'
		};

		//filters.put('StartDateTime',new List<Object>{ADESSO}); La StartDateTime deve essere maggiore di adesso

		//setOrderDesc
		//setOrderAsc
		strategy.setOrderAsc('StartDateTime');

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
			'StartDateTime', //nel formato gg/mm/aaaa hh.mm
			'Owner'
		};

		tableElement.labels = new Map < String, String > {
			'Subject' => Label.leadDetail_columns_subject,
			'ActivityDate' => Label.leadDetail_columns_limitDate,
			'Owner' => Label.leadDetail_columns_owner
		};

		Debug('tableElement', tableElement);
		DebugEnd();
		return tableElement;
	}

	@AuraEnabled
	public static SObjectTable.TablePagination getQuotations(Integer page, Integer perPage, Map<String, List<Object>> filters, String orderField, String orderName, String search){
		DebugStart('MobilityLeadController', 'getQuotations');
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
			'Origine__c',
			'CreatedDate',
			'Premium__c',
			'Lead__c'
		};

		strategy.sobjectName = 'Quotazione__c';

		strategy.searchColumns = new Set < String > {
			'Name',
			'Origine__c'
		};

		//setOrderDesc
		//setOrderAsc
		strategy.setOrderAsc('CreatedDate');

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
			'Origine__c',
			'CreatedDate',
			'Premium__c'
		};

		tableElement.labels = new Map < String, String > {
			'Name' => Label.leadDetail_columns_quotationsName,
			'Origine__c' => Label.leadDetail_columns_source,
			'CreatedDate' => Label.leadDetail_columns_createdDate,
			'Premium__c'  => Label.leadDetail_columns_prize
		};

		Debug('tableElement', tableElement);
		DebugEnd();
		return tableElement;
	}

	@AuraEnabled
	public static SObjectTable.TablePagination getTask(Integer page, Integer perPage, Map<String, List<Object>> filters, String orderField, String orderName, String search){
		DebugStart('MobilityLeadController', 'getTask');
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
			'ActivityDate',
			'Status',
			'Priority',
			'Owner.Name',
			'WhoId'
		};

		strategy.sobjectName = 'Task';

		strategy.searchColumns = new Set < String > {
			'Subject',
			'Status',
			'Priority',
			'Owner.Name'
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
			'ActivityDate',
			'Status',
			'Priority',
			'Owner'
		};

		tableElement.labels = new Map < String, String > {
			'Subject' => Label.leadDetail_columns_subject,
			'ActivityDate' => Label.leadDetail_columns_limitDate,
			'Status' => Label.leadDetail_columns_status,
			'Priority' => Label.leadDetail_columns_priority,
			'Owner' => Label.leadDetail_columns_owner
		};

		Debug('tableElement', tableElement);
		DebugEnd();
		return tableElement;
	}

	@AuraEnabled
	public static MobilityLeadResponse changeOwner(List<String> entityIds, String queueId, String typeOwner){
		DebugStart('MobilityLeadController', 'changeOwner');

		MobilityLeadResponse response = new MobilityLeadResponse();
		try{
			String ownerId = null;

			if ('queue'.equalsIgnoreCase(typeOwner)){
				QueueSobject queueObject = [SELECT QueueId FROM QueueSobject WHERE Id = :queueId ]; // NOPMD  Fix CRUD violation
				if(queueObject == null) throw new MobilityLeadException('Queue not found');
				ownerId = queueObject.QueueId;
			} else{
				ownerId = queueId;
			}

			List<Lead> result = (List<Lead>)MobilityUserController.changeOwnerData('Lead', entityIds, ownerId);
			for (Lead lead : result){

				lead.TECH_Send_Email_Notification__c = false;
			}

			Debug('result', result);

			Database.SaveResult[] saveResult = Database.update(result);
			Debug('saveResult', saveResult);

			response.isSuccess = true;
		} catch (DmlException ex){
			response.errorMessage = ex.getMessage();
		} catch (MobilityLeadException ex){
			response.errorMessage = ex.getMessage();
		}

		Debug('response', response);
		DebugEnd();
		return response;
	}

	@AuraEnabled(cacheable = true)
	public static MobilityLeadController.MobilityTimeStock getTimeStock(String leadId){
		MobilityTimeStock response = new MobilityTimeStock();
		String giacenza;
		Double leadExistanceHours;
		Id bHoursBefore;
		Id bHoursAfter;
		String timeinBH;

		bHoursBefore = [SELECT id FROM BusinessHours WHERE Name = 'AAI_Agency_BeforeLunch'].Id;
		bHoursAfter = [SELECT id FROM BusinessHours WHERE Name = 'AAI_Agency_AfterLunch'].Id;

		Lead LeadToUpdLst = [Select Ultima_data_di_riassegnazione__c, Contact_Date__c from lead where id =: leadId ]; // NOPMD  Fix CRUD violation

		if (LeadToUpdLst.Ultima_data_di_riassegnazione__c != null){

			if (LeadToUpdLst.Contact_Date__c != null){
				Double HoursBefore = BusinessHours.diff(bHoursBefore, LeadToUpdLst.Ultima_data_di_riassegnazione__c, LeadToUpdLst.Contact_Date__c) / 3600000.0;
				Double HoursAfter = BusinessHours.diff(bHoursAfter, LeadToUpdLst.Ultima_data_di_riassegnazione__c, LeadToUpdLst.Contact_Date__c) / 3600000.0;
				leadExistanceHours = HoursBefore + HoursAfter;
				system.debug(LeadToUpdLst.Contact_Date__c + '     ' + LeadToUpdLst.Ultima_data_di_riassegnazione__c + '     ' + leadExistanceHours);
			} else{
				Double HoursBefore = BusinessHours.diff(bHoursBefore, LeadToUpdLst.Ultima_data_di_riassegnazione__c, system.now()) / 3600000.0;
				Double HoursAfter = BusinessHours.diff(bHoursAfter, LeadToUpdLst.Ultima_data_di_riassegnazione__c, system.now()) / 3600000.0;
				leadExistanceHours = HoursBefore + HoursAfter;
				system.debug(system.now()+'     ' + LeadToUpdLst.Ultima_data_di_riassegnazione__c + '     ' + leadExistanceHours);

			}

			if (leadExistanceHours > 0){

				Integer Ore = 0;
				Integer Minuti = 0;
				Integer Giorni = 0;
				Integer Secondi = 0;
				if (leadExistanceHours >= 8){
					Giorni = Integer.valueof(leadExistanceHours / 8);

					if (leadExistanceHours - Giorni > 0){
						Ore = Integer.valueof(leadExistanceHours - 8 * Giorni);
						Minuti = Integer.valueof(Math.ceil((leadExistanceHours - Ore - Giorni * 8) * 60));

						if (Minuti > 0){
							Secondi = Integer.valueof((((leadExistanceHours - Ore - Giorni * 8) * 60)-Minuti) * 100);

							if (Secondi < 0)
								Secondi = 0;
						}

					}

					timeinBH = Giorni + ' Giorni, ' + Ore + ' Ore, ' + Minuti + ' Minuti';
					response.days = Giorni;
					response.hours = Ore;
					response.minutes = Minuti;
					response.stringValue = timeinBH;

				} else{

					Ore = Integer.valueof(leadExistanceHours);
					Minuti = Integer.valueof(Math.ceil((leadExistanceHours - Ore) * 60));
					Secondi = 0;

					if (Minuti < 0)
						Minuti = 0;
					else{
						Secondi = Integer.valueof((((leadExistanceHours - Ore) * 60)-Minuti) * 100);

						if (Secondi < 0)
							Secondi = 0;
					}

					//Integer Secondi = ((leadExistanceHours- Ore )*60) - Minuti;
					timeinBH = Ore + ' Ore, ' + Minuti + ' Minuti';

					response.hours = Ore;
					response.minutes = Minuti;
					response.stringValue = timeinBH;

				}

			}
		}
		System.debug('TimeStock: ' + response);
		return response;
	}

	@AuraEnabled(cacheable = true)
	public static MobilityLeadActivitiesResponse getCountActivities(String leadId){
		DebugStart('MobilityLeadController', 'getCountActivities');

		MobilityLeadActivitiesResponse response = new MobilityLeadActivitiesResponse();
		try{

			Lead currentLead = [
				SELECT Id, Agency_Code__c
			                    FROM Lead
				WHERE Id = :leadId
			];

			Datetime dateStart = Datetime.now();
			Datetime dateEnd = Datetime.newInstance(
				Date.today().addDays(1),
				Time.newInstance(0, 0, 0, 0)
			);

			response.listEvent = [
				SELECT Id, Subject, StartDateTime, EndDateTime, Who.Name
			                      FROM Event
				WHERE WhoId = :leadId
				AND RecordType.DeveloperName = 'AAI_Event'
				AND CreatedBy.Agency_Code__c =: currentLead.Agency_Code__c
			];

			response.listTask = [
				SELECT Id, WhoId
			                     FROM Task
				WHERE WhoId = :leadId
				AND RecordType.DeveloperName = 'Generico'
				AND CreatedBy.Agency_Code__c =: currentLead.Agency_Code__c
			];

			response.isSuccess = true;
		} catch (MobilityLeadException ex){
			response.errorMessage = ex.getMessage();
		}

		Debug('response', response);
		DebugEnd();
		return response;
	}

	@AuraEnabled
	public static MobilityLeadResponse getAccountReference(String keyword){
		DebugStart('MobilityLeadController', 'getAccountReference');
		Debug('keyword', keyword);

		String keywordToSearch = '%' + keyword.trim()+'%';

		MobilityLeadResponse response = new MobilityLeadResponse();

		try{

			response.results = [
				SELECT Id, FirstName, LastName, Name 
			                    FROM Account
				WHERE Recordtype.Name IN ('B2B Client','B2C Client')
				AND Name LIKE :keywordToSearch 
				LIMIT 5
			];

			Debug('results', response.results);

			response.isSuccess = true;
		} catch (MobilityLeadException ex){
			response.errorMessage = ex.getMessage();
		}

		Debug('response', response);
		DebugEnd();

		return response;
	}

	@AuraEnabled(cacheable = true)
	public static Map<String, String> getSubStatusList(){
		Map<String, String> options = new Map<String, String>();

		Schema.DescribeFieldResult fieldResult = Schema.Lead.Sottostato_del_lead__c.getDescribe();

		list<Schema.Picklistentry> values = fieldResult.getPickListValues();
		for (Schema.PicklistEntry value : values)
			options.put(value.getLabel(), value.getValue());
		return options;
	}

	@AuraEnabled(cacheable = true)
	public static List<Group> getQueueAxa(){
		return [SELECT Id FROM Group WHERE Type = 'Queue' AND Group.DeveloperName = 'Coda_Lead_Contatto_Errato' ]; // NOPMD  Fix CRUD violation
	}

	public static void validateConvertLead(Lead lead){
		if (String.isNotBlank(lead.FirstName) && String.isNotBlank(lead.LastName) && String.isNotBlank(lead.Fiscal_ID__c)){
			if(!MobilityLeadController.checkFiscalCode(lead.Fiscal_ID__c)) throw new MobilityLeadException('Il codice fiscale deve essere lungo 16 caratteri');
		}

		if (String.isNotBlank(lead.Company) && String.isNotBlank(lead.AAI_Partita_IVA__c)){
			if(!MobilityLeadController.checkVATNum(lead.AAI_Partita_IVA__c)) throw new MobilityLeadException('La partita IVA deve essere lunga 11 caratteri');
		}

		if (String.isNotBlank(lead.Fiscal_ID__c)){
			if (String.isBlank(lead.FirstName)){
				throw new MobilityLeadException('E neccesario valorizzare il campo Nome');
			} else if (String.isBlank(lead.LastName)){
				throw new MobilityLeadException('È neccesario valorizzare il campo Cognome');
			}
		} else if (String.isNotBlank(lead.AAI_Partita_IVA__c)){
			if(String.isBlank(lead.Company)) throw new MobilityLeadException('È neccesario valorizzare il campo Ragione Sociale');
		} else if (String.isBlank(lead.Fiscal_ID__c) && String.isBlank(lead.AAI_Partita_IVA__c)){
			throw new MobilityLeadException('È neccesario valorizzare il Codice fiscale o la Partita Iva');
		}
	}

	public static Boolean checkFiscalCode(String fiscalCode){
		return fiscalCode.length() == 16;
	}

	public static Boolean checkVATNum(String vanNumber){
		return vanNumber.length() == 11;
	}

	@AuraEnabled(cacheable = true)
	public static MobilityLeadResponse canConvertLead(String leadId){
		DebugStart('MobilityLeadController', 'canConvertLead');

		MobilityLeadResponse response = new MobilityLeadResponse();

		try{
			Lead currentLead = [
				SELECT 
					Id,
					FirstName,
					LastName,
					Fiscal_ID__c,
					AAI_Partita_IVA__c,
					Company,
					Agency_Code__c,
					TECH_DeduplicationKey__c
			                    FROM Lead
				WHERE Id = :leadId
			];

			Map<Id, Lead> duplicatedLeadMap = new Map<Id, Lead>([SELECT Id, FirstName, LastName FROM Lead WHERE Agency_Code__c = :currentLead.Agency_Code__c AND TECH_DeduplicationKey__c = :currentLead.TECH_DeduplicationKey__c AND IsConverted=false]);
			duplicatedLeadMap.remove(leadId);
			response.hasDuplicateLead = !duplicatedLeadMap.isEmpty();

			MobilityLeadController.validateConvertLead(currentLead);

			response.canConvertLead = true;
			response.isSuccess = true;
		} catch (MobilityLeadException ex){
			response.errorMessage = ex.getMessage();
		}

		Debug('response', response);
		DebugEnd();

		return response;
	}

	@AuraEnabled(cacheable = true)
	public static MobilityLeadResponse getDuplicatedCheck(String leadId){
		DebugStart('MobilityLeadController', 'getAccountReference');

		MobilityLeadResponse response = new MobilityLeadResponse();

		try{
			Lead currentLead = [
				SELECT 
					Id,
					LastName,
					FirstName,
					Company,
					OwnerId,
					PostalCode,
					AAI_Partita_IVA__c,
					Agency_Code__c,
					Fiscal_ID__c,
					TECH_Company__c
			                    FROM Lead
				WHERE Id = :leadId
			];

			//Logica su profili non neccesaria in mobility
			//User currentUser = [
			//    SELECT Id, Name, Profile.Name
			//    FROM User
			//    WHERE Id =:response.currentUserId LIMIT 1
			//];

			//Set<String> profilesAvailable = new Set<String>{
			//    'NFE - AAI - Vendite Avanzato',
			//    'NFE - AAI - Vendite Base'
			//};

			response.isDuplicated = LeadManagement.verifyDuplicateLead(currentLead);
			response.isDuplicatedContext = (currentLead.TECH_Company__c == 'AAI' && String.valueOf(currentLead.OwnerId).left(3) == '00G');
		} catch (MobilityLeadException ex){
			response.errorMessage = ex.getMessage();
		}

		Debug('response', response);
		DebugEnd();

		return response;
	}

	@AuraEnabled
	public static MobilityLeadEmailResponse getLeadEmail(String leadId){
		DebugStart('MobilityLeadController', 'getAccountReference');

		MobilityLeadEmailResponse response = new MobilityLeadEmailResponse();

		try{

			User currentUser = MobilityUserController.getCurrentUser();
			Lead currentLead = [
				SELECT Id, Email, Name
			                    FROM Lead
				WHERE Id = :leadId
			];

			response.lead = currentLead;
			response.currentUser = currentUser;

			response.fromEmail = currentUser.Email;
			response.toEmail = currentLead.Email;

			response.isSuccess = true;
		} catch (MobilityLeadException ex){
			response.errorMessage = ex.getMessage();
		}

		Debug('response', response);
		DebugEnd();
		return response;
	}

	@AuraEnabled
	public static MobilityCountryCodesResponse getCountryCodes(){
		DebugStart('MobilityLeadController', 'getCountryCodes');

		MobilityCountryCodesResponse response = new MobilityCountryCodesResponse();

		try{
			List<MappingCountry__c> countries = [ // NOPMD  Fix CRUD violation
				SELECT Id, IsDeleted, Name, SetupOwnerId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, CountryISOcode__c, CountrySFDC__c 
				FROM MappingCountry__c 
			];

			List<String> countriesList = new List<String>();
			for (MappingCountry__c countryData : countries){
				countriesList.add(countryData.CountrySFDC__c);
			}

			response.countries = countriesList;
			response.isSuccess = true;
		} catch (MobilityLeadException ex){
			response.errorMessage = ex.getMessage();
		}

		Debug('response', response);
		DebugEnd();
		return response;
	}

	@AuraEnabled
	public static SObjectTable.TablePagination searchDuplicates(Integer page, Integer perPage, Map<String, List<Object>> filters, String orderField, String orderName, String search){
		SObjectTable.SObjectStrategy strategy = new SObjectTable.SObjectStrategy();
		strategy.fieldsSet = new Set < String > {
			'Id',
			'LeadSource',
			'Dettaglio__c',
			'Name',
			'Company',
			'State',
			'Phone',
			'Email',
			'Status',
			'Owner.Name',
			'CreatedDate',
			'Data_scadenza_polizza_c_o_concorrente__c',
			'RecordType.DeveloperName',
			'TECH_Order_Index__c'
		};

		strategy.sobjectName = 'Lead';

		strategy.searchColumns = new Set < String > {
			'Company',
			'Fiscal_ID__c',
			'AAI_Partita_IVA__c'
		};

		strategy.addFilter('RecordType.DeveloperName', new Set < Object > {
			'Lead_AXA_Assicurazioni',
			'eCommerce'
		});

		strategy.addFilter('IsConverted', new Set < Object > {
			'false'
		});

		//setOrderDesc
		//setOrderAsc
		strategy.setOrderDesc('TECH_Order_Index__c');

		//INPUT DATA
		strategy.perPage = perPage;
		strategy.page = page;
		strategy.searchString = search;
		strategy.setOrder(orderField, orderName, true);
		strategy.addFilters(filters, true);

		//RESPONSE
		SObjectTable.TablePagination tableElement = SObjectTable.paginationData(strategy);
		tableElement.columns = new List < String > {
			'LeadSource',
			'Dettaglio__c',
			'Name',
			'Company',
			'State',
			'Phone',
			'Email',
			'Status',
			'Owner',
			'CreatedDate',
			'Data_scadenza_polizza_c_o_concorrente__c'
		};

		tableElement.labels = new Map < String, String > {
			'LeadSource' => Label.leadListView_columns_sourceLead,
			'Dettaglio__c' => Label.leadListView_columns_detailSourceLead,
			'Name' => Label.leadListView_columns_extendedName,
			'Company' => Label.leadListView_columns_businessName,
			'State' => Label.leadListView_columns_state,
			'Phone' => Label.leadListView_columns_phone,
			'Email' => Label.leadListView_columns_email,
			'Status' => Label.leadListView_columns_statusLead,
			'Owner' => Label.leadListView_columns_aliasOwner,
			'CreatedDate' => Label.leadListView_columns_createdDate,
			'Data_scadenza_polizza_c_o_concorrente__c' => Label.leadListView_columns_expirationDate
		};


		System.debug('Result: ' + JSON.serialize(tableElement));

		return tableElement;
	}

	@AuraEnabled
	public static Boolean changeLeadOwner(String LeadId){
		try{
		List<Lead> leadList = [Select ownerId, Owner.Name from Lead where id  = :LeadId];
			if (!leadList.isEmpty()){
				Lead l = leadList.get(0);
				String owner = String.valueOf(l.ownerId);
				if (owner.startsWith('00G')){
					if (l.Owner.name.contains('Coda Agenzia')){

						l.ownerId = UserInfo.getUserId();
						update l;
						return true;

				}
				else return false;
			}
			else return true;
			}
			return false;
		} catch (Exception e){
			try{
				ApplicationLogHelper.ERROR('MobilityLeadController', e.getmessage(), e.getStackTraceString());
			} catch (Exception ex){
				System.debug(System.LoggingLevel.ERROR, 'Exception: ' + ex.getmessage()+'\tStackTrace: ' + ex.getStackTraceString());
			}
			return false;
		}
	}
    public class LeadWrapper{
		@AuraEnabled
		public String colorCode;
		@AuraEnabled
		public Lead leadData;
		public LeadWrapper(String colorCode, Lead leadData){
			this.colorCode = colorCode;
			this.leadData = leadData;
		}
	}
    @AuraEnabled
	public static List<LeadWrapper> getColorsFromLead(List<Lead> leads){

		List<LeadWrapper> toRet = new List<LeadWrapper>();
		
		Map<String, String> mappaConfColore = new Map<String, String>();
		List<Color_chart_Mapping__mdt> mdtList = [select DeveloperName, Dettaglio_Fonte__c, Landing_Page__c, Fonte__c, Color__c // NOPMD  Fix CRUD violation
		                                          from Color_chart_Mapping__mdt ];
		Color_chart_Mapping__mdt defaultCM;
		for (Color_chart_Mapping__mdt ccm : mdtList){
			String key;
			if(ccm.developerName.equalsIgnoreCase('Default')){
				defaultCM = ccm;
			}else{
			if (String.isEmpty(ccm.Dettaglio_Fonte__c)){
				key = ccm.Fonte__c.toLowerCase();
			} else{
				key = ccm.Dettaglio_Fonte__c.toLowerCase()+ccm.Landing_Page__c.toLowerCase();
			}
			mappaConfColore.put(key, ccm.Color__c);
		}
			
			
		}
		for (Lead l : leads){
			String key1, key2;
			
			if (String.isNotBlank(l.Dettaglio__c) && String.isNotBlank(l.Landing_Page__c))
				key1 = l.Dettaglio__c.toLowerCase()+l.Landing_Page__c.toLowerCase();
			if (String.isNotBlank(l.LeadSource))
				key2 = l.LeadSource.toLowerCase();
			if (mappaConfColore.containsKey(key1)){
				system.debug(l.Id + ': ' + mappaConfColore.get(key1));
				toRet.add(new LeadWrapper(mappaConfColore.get(key1), l));
			} else if (mappaConfColore.containsKey(key2)){
				system.debug(l.Id + ': ' + mappaConfColore.get(key2));
				toRet.add(new LeadWrapper(mappaConfColore.get(key2), l));
			}
			else{
				toRet.add(new LeadWrapper(defaultCM.Color__c, l));
			}
		}
		return toRet;
	}


}