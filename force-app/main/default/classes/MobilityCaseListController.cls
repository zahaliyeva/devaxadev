public with sharing class MobilityCaseListController extends MobilityAbstract {

	public class MobilityCaseException extends Exception {}
	public class MobilityCaseResponse extends MobilityResponse {
		@AuraEnabled public User currentUser;
	}
    public class MobilityCaseDetailResponse extends MobilityResponse {
        @AuraEnabled public Case currentCase;
    }

	@AuraEnabled(cacheable = true)
	public static List < Case > getCase() {
		return MobilityCaseListController.getCase(100);
	}

	@AuraEnabled(cacheable = true)
	public static List < Case > getCase(Integer limitRows) {
		/*Modello_di_Assistenza__mdt conf = [
			SELECT
				Id,
				DeveloperName,
				Status__c,
				StatusAgenti__c
			FROM Modello_di_Assistenza__mdt
			WHERE DeveloperName  = 'AssistenzaAgentiStatusPicklist'
			LIMIT 1
		];

		List<String> statusFilter = conf.StatusAgenti__c.split(';');

		System.debug(statusFilter);*/

		List < Case > listCases = [
			SELECT
			Id,
			Oggetto_Apertura_Case__c,
			CreatedDate,
			User__r.Name,
			Category__c,
			SubCategory__c,
			Status,
			LastModifiedDate
			FROM Case
			WHERE RecordType.DeveloperName = 'Assistenza_Agenti'
			//AND Status IN('Open', 'In gestione all\'HD3', 'Info Agente Ricevute', 'Attesa Info Agente')
			AND IsClosed = False
			ORDER BY LastModifiedDate desc
			LIMIT: limitRows
		];

		System.debug(listCases);

		return listCases;
	}

	@AuraEnabled
	public static Integer getCounterCloseTheLoop() {
		AggregateResult closeNumber = [
			SELECT Count(Id) countData
			FROM Case
			WHERE RecordType.DeveloperName = 'Close_the_loop'
			AND IsClosed = false
		];

		if (closeNumber.get('countData') != null) {
			return (Integer) closeNumber.get('countData');
		}

		return 0;
	}

	@AuraEnabled(cacheable=true)
	public static MobilityCaseResponse getAssistanceUser(){
		DebugStart('MobilityCaseResponse', 'getAssistanceUser');

		MobilityCaseResponse response = new MobilityCaseResponse();

		try {

			response.currentUser = MobilityUserController.getCurrentUser();

			response.isSuccess = true;
		} catch (MobilityCaseException ex) {
			response.errorMessage = ex.getMessage();
		}

		Debug('response', response);
		DebugEnd();
		return response;
	}
    
    @AuraEnabled(cacheable=true)
	public static Case getCaseById(String caseId) {
		return [
			SELECT CaseNumber, Status
			FROM Case
			WHERE Id =: caseId
		];
	}
    
    @AuraEnabled(cacheable=true)
	public static MobilityCaseDetailResponse getCaseDetail(String caseId){
		DebugStart('MobilityCaseResponse', 'getCaseDetail');
		
		MobilityCaseDetailResponse response = new MobilityCaseDetailResponse();

		try {

			response.currentCase = MobilityCaseListController.getCaseById(caseId);

			response.isSuccess = true;
		} catch (MobilityCaseException ex) {
			response.errorMessage = ex.getMessage();
		}

		Debug('response', response);
		DebugEnd();
		return response;
	}
    
}