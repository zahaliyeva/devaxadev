public with sharing class FormGenerateController extends RLY_Behaviour{

	public class FormException extends Exception {}
	public class FormResponse extends LghtResponse{
		@AuraEnabled public List<FormConfig__mdt> configs;
		@AuraEnabled public String recordTypeId;
		@AuraEnabled public SObject data;
	}

	@AuraEnabled
	public static FormResponse getForm(String formName, String sObjectName, String recordId, String recordType){
		DebugStart('AccountActionsController', 'getAccount');

		FormResponse response = new FormResponse();

		try {
			/**
			 * Retrieve Configurations
			 */
			List<FormConfig__mdt> configs = FormGenerateController.getConfig(formName, sObjectName, recordType);
			response.configs = configs;

			/**
			 * Retrive RecordType Id
			 */
			Map<String,String> recordTypes = RLY_RecordType.recordTypeByDeveloperName(sObjectName);
			response.recordTypeId = recordTypes.get(recordType);

			/**
			 * If RecordId is not Blank, retrieve data
			 */
			if(String.isNotBlank(recordId)){
				response.data = FormGenerateController.getData(configs, sObjectName, recordId);
			}

			response.isSuccess = true;
		} catch (FormException ex) {
			response.errorMessage = ex.getMessage();
			Debug('Exception', response.errorMessage);
		} catch (Exception ex){
			response.errorMessage = ex.getMessage();
			Debug('Exception', response.errorMessage);
		}

		Debug('response', response);
		DebugEnd();

		return response;
	}

	public static SObject getData(List<FormConfig__mdt> configs, String sObjectName, String recordId){
		/**
		 * Get fields to configs 
		 */
		List<String> fieldsList = FormGenerateController.getFields(configs);

		/**
		 * Generare query
		 */
		Set<String> fields = new Set<String>(fieldsList);
		String objectName = sObjectName;

		Set<String> andCondition = new Set<String>();
		andCondition.add(SObjectTable.whereField('Id', recordId));

		String query = SObjectTable.getTableQuery(fields, objectName, andCondition, null, null, null, null);

		List<SObject> listResult = Database.query(query);

		if(listResult.size() == 1){
			return listResult[0];
		}

		return null;
	}

	public static List<FormConfig__mdt> getConfig(String formName, String sObjectName, String recordType){
        String profile = [Select name from profile where id = :UserInfo.getProfileId()].name;
		return [
			SELECT Form__c, Sobject__c, RecordType__c, Section__c, Label__c, 
				Field__c, ReadOnly__c, Required__c, Index__c, Default__c, Visible__c,
				Domain__c, Profile__c, Domain2__c
			FROM FormConfig__mdt
			WHERE Form__c = :formName
			AND Sobject__c = :sObjectName
			AND RecordType__c = :recordType
            AND (Profile__c =:profile OR Profile__c = null)
		];
	}

	public static List<String> getFields(List<FormConfig__mdt> configs){
		List<String> listFields = new List<String>();

		for(FormConfig__mdt config : configs){
			listFields.add(config.Field__c);
		}

		return listFields;
	}


}