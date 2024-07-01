public with sharing class MobilityUserController extends MobilityAbstract {

	public class MobilityUserException extends Exception {}
	public class MobilityUserResponse extends MobilityResponse {}

	@AuraEnabled(cacheable = true)
	public static SObjectTable.TablePagination getUserPartners(Integer page, Integer perPage, Map < String, List < Object >> filters, String orderField, String orderName, String search) {
		DebugStart('MobilityUserController', 'getUserPartners');

		SObjectTable.SObjectStrategy strategy = new SObjectTable.SObjectStrategy();
		strategy.fieldsSet = new Set < String > {
			'Id',
			'Name',
			'IsPortalEnabled'
		};

		strategy.sobjectName = 'User';

		strategy.searchColumns = new Set < String > {
			'Name'
		};

		strategy.addFilter('isActive', new Set < Object > {
			true
		});

		strategy.addFilter('IsPortalEnabled', new Set < Object > {
			true
		});

		//setOrderAsc
		strategy.setOrderDesc('Name');

		//INPUT DATA 
		strategy.perPage = perPage;
		strategy.page = page;
		strategy.searchString = search;
		strategy.setOrder(orderField, orderName, true);
		strategy.addFilters(filters, true);

		//RESPONSE
		SObjectTable.TablePagination tableElement = SObjectTable.paginationData(strategy);
		tableElement.columns = new List < String > {
			'Name'
		};

		tableElement.labels = new Map < String, String > {
			'Name' => 'Nome'
		};

		Debug('Result', tableElement);
		DebugEnd();
		return tableElement;
	}

	@AuraEnabled(cacheable = true)
	public static SObjectTable.TablePagination getQueues(Integer page, Integer perPage, Map < String, List < Object >> filters, String orderField, String orderName, String search) {
		DebugStart('MobilityUserController', 'getQueues');

		SObjectTable.SObjectStrategy strategy = new SObjectTable.SObjectStrategy();
		strategy.fieldsSet = new Set < String > {
			'Id',
			'QueueId',
			'Queue.Name',
			'SobjectType'
		};

		strategy.sobjectName = 'QueueSobject';

		strategy.searchColumns = new Set < String > {
			'Queue.Name'
		};

		//setOrderAsc
		strategy.setOrderDesc('Queue.Name');

		//INPUT DATA 
		strategy.perPage = perPage;
		strategy.page = page;
		strategy.searchString = search;
		strategy.setOrder(orderField, orderName, true);
		strategy.addFilters(filters, true);

		//RESPONSE
		SObjectTable.TablePagination tableElement = SObjectTable.paginationData(strategy);
		tableElement.columns = new List < String > {
			'Queue'
		};

		tableElement.labels = new Map < String, String > {
			'Queue' => 'Nome'
		};

		Debug('Result', tableElement);
		DebugEnd();
		return tableElement;
	}

	public static List < SObject > changeOwnerData(String sobjectName, List < String > entityIds, String ownerId) {
		Set < String > fieldsSet = new Set < String > {
			'Id',
			'OwnerId'
		};

		Set < Object > valuesIn = new Set < Object > ();
		for (String recordId: entityIds) {
			valuesIn.add(recordId);
		}

		Set < String > andCondition = new Set < String > {
			SObjectTable.whereIn('Id', valuesIn)
		};

		String query = SObjectTable.getTableQuery(fieldsSet, sobjectName, andCondition, null, null, null, null);
		Debug('query', query);

		List < SObject > listData = Database.query(query);
		Debug('listData', listData);

		for (SObject data: listData) {
			data.put('OwnerId', ownerId);
		}

		return listData;
	}

	@AuraEnabled(cacheable = true)
	public static MobilityUserResponse changeOwner(String sobjectName, List < String > entityIds, String ownerId) {
		DebugStart('MobilityUserController', 'changeOwner');

		MobilityUserResponse response = new MobilityUserResponse();
		try {
			List < SObject > result = MobilityUserController.changeOwnerData(sobjectName, entityIds, ownerId);

			Database.SaveResult[] saveResult = Database.update(result, false);
		} catch (DmlException ex) {
			response.errorMessage = ex.getMessage();
		} catch (MobilityUserException ex) {
			response.errorMessage = ex.getMessage();
		}

		Debug('response', response);
		DebugEnd();
		return response;
	}

	@AuraEnabled
	public static User getCurrentUser() {
		return [
			SELECT Nodes__c, CommunityNickname, Email, Profile.Name, Agency_Code__c, Main_Node__c, UserRole.Name,FirstName
			FROM User
			WHERE Id =: Userinfo.getUserId()
		];
	}

	@AuraEnabled
	public static List < User > getUserAgency() {
		User currentUser = MobilityUserController.getCurrentUser();

		if (currentUser == null) return null;

		return [
			SELECT Id, Name
			FROM User
			WHERE Agency_Code__c =: currentUser.Agency_Code__c 
			AND isActive = true 
		];
	}

	@AuraEnabled
	public static User getUserById(String userId){
		return [
			SELECT Id, Name, FirstName, Nodes__c, Agency_Code__c, TECH_Email__c
			FROM User
			WHERE Id = :userId
		];
	}

	@AuraEnabled
	public static List<UserRecordAccess> getAccess(String userId, List<String> relatedRecordIds){
		return [
			SELECT RecordId, HasReadAccess 
			FROM UserRecordAccess 
			WHERE UserId = :userId 
			AND RecordId IN :relatedRecordIds
		];
	}
}