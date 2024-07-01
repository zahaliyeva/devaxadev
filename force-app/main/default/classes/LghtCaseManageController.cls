public with sharing class LghtCaseManageController extends RLY_Behaviour {

	public static final String RECORD_TYPE_ALL = 'All';
   
	public class LghtCaseManageException extends Exception {}
	public class CaseManageContext extends LghtResponse{
		@AuraEnabled public String portalRole;
		@AuraEnabled public String profileName;
		@AuraEnabled public Boolean hasCaseNewStandard;
		@AuraEnabled public Boolean hasCaseNewCustom;
		@AuraEnabled public Boolean hasCaseNewSurvey;
		@AuraEnabled public Map<String,List<String>> availableActions;
		@AuraEnabled public String newType;
		
	}

	@AuraEnabled
	public static CaseManageContext caseCreateContext(){
		DebugStart('LghtCaseActionsController', 'getCase');

		CaseManageContext response = new CaseManageContext();

		try {
			/**
			* Retrieve Current User
			*/
			User currentUser = LghtCaseManageController.currentUser();

			Debug('currentUser', currentUser);

			/**
			* User Role
			*/
			response.portalRole = currentUser.UserRole.PortalRole;

			/**
			* Profile Name
			*/
			response.profileName = currentUser.Profile.Name;

			/**
			 * Retrive New Type
			 */
			List<MPS_Code_Utils__mdt> codeUtilsMetadata = [
				SELECT Key__c, Value__c 
				FROM MPS_Code_Utils__mdt 
				WHERE DeveloperName 
				LIKE 'OffQuestionario%'
			];

			Debug('codeUtilsMetadata', codeUtilsMetadata);
			for(MPS_Code_Utils__mdt codeUtils : codeUtilsMetadata){
				if(codeUtils.Key__c.contains(response.profileName)){
					response.newType = codeUtils.Value__c;
				}
			}

			response.hasCaseNewStandard 	= LghtCaseManageController.hasAvailableAction(currentUser.Profile.Name, 'CASE_NEW_STANDARD');
			response.hasCaseNewCustom		= LghtCaseManageController.hasAvailableAction(currentUser.Profile.Name, 'CASE_NEW_CUSTOM');
			response.hasCaseNewSurvey		= LghtCaseManageController.hasAvailableAction(currentUser.Profile.Name, 'CASE_NEW_SURVEY');

			response.availableActions		= LghtCaseManageController.availableAction(currentUser.Profile.Name);

			response.isSuccess = true;
		} catch (LghtCaseManageException ex) {
			response.errorMessage = ex.getMessage();
		}

		Debug('response', response);
		DebugEnd();

		return response;
	}

	/**
	 * Retrieve Case Data
	 * @param  recordId Case Id
	 * @return          Return Case
	 */
	public static Case getCase(String recordId){
		return [
			SELECT Id, Status, SuppliedEmail, RecordType.Id, RecordType.Name, RecordType.DeveloperName, Pratica_Documentale__c,
				 CaseNumber, Details_of_Solution__c, IsClosed, OwnerId, StatusReopened_Date__c, NumberOfReopens__c,
				 LinkToPolicy__r.Id, Insurance_Policy_AAF__r.Id,Insurance_Policy_AAF__c,LinkToPolicy__c,
				 AccountId, Account.FirstName, Account.LastName, Account.Fiscal_ID__c, Account.Matricola__c, 
				 Account.AAI_Codice_fiscale__c, Account.Codice_Fiscale_AAF__c, Account.PersonEmail, 
				 Account.Additional_Email__c, Account.Name, Account.Partita_IVA__c, Account.AAI_Partita_IVA__c, 
				 Account.Account_email__c, Account.TECH_Company__c, Account.RecordType.DeveloperName, Agency_Code__c, Codice_Fiscale__c,
				 Document_Unique_ID__c, RequiredDocumentList__c, SubCategory__c, Origin, MessagingUser__c, Current_Owner_Queue__c
			FROM Case
			WHERE Id = :recordId
		];

	}

	/**
	* Retrieve Current User
	*/
	public static User currentUser(){
		User user = [
			SELECT CommunityNickname, Email, Profile.Name, UserRole.Name, UserRole.PortalRole
			FROM User
			WHERE Id = :Userinfo.getUserId()
		];

		if(user.Profile.Name == 'Amministratore del sistema') user.Profile.Name = 'System Administrator';

		return user;
	}

	public static Boolean hasAvailableAction(String profileName, String actionName){
		return LghtCaseManageController.hasAvailableAction(profileName, null, actionName);
	}

	public static Boolean hasAvailableAction(String profileName, String recordTypeDeveloperName, String actionName){
		Map<String,List<String>> availableActions = LghtCaseManageController.availableAction(profileName, recordTypeDeveloperName);

		String recordTypeCheck = recordTypeDeveloperName;
		if(recordTypeCheck == null) recordTypeCheck = RECORD_TYPE_ALL;

		for(String key : availableActions.keySet()){
			List<String> actions = availableActions.get(key);

			if(actions.contains(actionName)){
				return true;
			}
		}

		return false;
	}

	/**
	 * Get available actions
	 * @param  profileName             Profile to Check
	 * @return                         List availables Acations
	 */
	public static Map<String,List<String>> availableAction(String profileName){
		return LghtCaseManageController.availableAction(profileName, null);
	}

	/**
	 * Get available actions
	 * @param  profileName             Profile to Check
	 * @param  recordTypeDeveloperName Record Type to check
	 * @return                         List availables Acations
	 */
	public static Map<String,List<String>> availableAction(String profileName, String recordTypeDeveloperName){
		DebugStart('LghtCaseActionsController', 'availableAction');
		List<CaseVisibilities__mdt> visibities = LghtCaseManageController.getVisibilities(profileName, recordTypeDeveloperName);

		Map<String,List<String>> mapVisibilies = new Map<String,List<String>>();

		for(CaseVisibilities__mdt visibility : visibities){
			String keyName = visibility.RecordType__c;
			if(keyName == '*') keyName = RECORD_TYPE_ALL;

			if(keyName != RECORD_TYPE_ALL){
				Map<String,String> mapRecordTypes = RLY_RecordType.recordTypeByDeveloperName('Case');
				keyName = mapRecordTypes.get(keyName);

				Debug('keyName', keyName);
			}

			List<String> currentActions = visibility.ActionsName__c.split(';');

			if(mapVisibilies.get(keyName) == null){
				Set<String> cleanActions = new Set<String>();
				cleanActions.addAll(currentActions);

				mapVisibilies.put(keyName, new List<String>(cleanActions));
			}else{
				List<String> actions = mapVisibilies.get(keyName);
				
				Set<String> cleanActions = new Set<String>();
				cleanActions.addAll(currentActions);
				cleanActions.addAll(actions);

				mapVisibilies.put(keyName,  new List<String>(cleanActions));
			}

		}

		Debug('mapVisibilies', mapVisibilies);
		DebugEnd();
		return mapVisibilies;
	}

	/**
	* Retrieve Visibilities
	*/
	public static List<CaseVisibilities__mdt> getVisibilities(String profileName, String recordTypeDeveloperName){
		DebugStart('LghtCaseActionsController', 'getVisibilities');

		Set<String> fields = new Set<String>{
			'Id',
			'DeveloperName',
			'RecordType__c',
			'ProfileName__c',
			'ActionsName__c'
		};

		String objectName = 'CaseVisibilities__mdt';

		Set<String> andCondition = new Set<String>();

		if(String.IsNotBlank(profileName)){
			andCondition.add(SObjectTable.whereField('ProfileName__c', profileName));
		}

		if(String.IsNotBlank(recordTypeDeveloperName)){
			andCondition.add(SObjectTable.whereField('RecordType__c', recordTypeDeveloperName));
		}

		String query = SObjectTable.getTableQuery(fields, objectName, andCondition, null, null, null, null);

		DebugEnd();
		return Database.query(query);
	}

}