public with sharing class MobilityCaseListWidgetController extends MobilityAbstract{

	@AuraEnabled(cacheable=true)
	public static List<Case> getCase() {
		return MobilityCaseListWidgetController.getCase(100);
	}

	@AuraEnabled(cacheable=true)
	public static List<Case> getCase(Integer limitRows) {
		Modello_di_Assistenza__mdt conf = [
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

		System.debug(statusFilter);

		List<Case> listCases = [
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
			AND Status IN :statusFilter
			AND IsClosed = False
			ORDER BY LastModifiedDate desc
			LIMIT: limitRows
		];

		System.debug(listCases);
		
		return listCases;
	}
}