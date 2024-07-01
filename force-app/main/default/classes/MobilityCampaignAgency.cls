public with sharing class MobilityCampaignAgency extends MobilityAbstract{

	public class MobilityCampaignDataEnrichmentException extends Exception {}
	public class MobilityCampaignDataEnrichmentResponse extends MobilityResponse {}

	@AuraEnabled
	public static SObjectTable.TablePagination getAgency(Integer page, Integer perPage, Map < String, List < Object >> filters, String orderField, String orderName, String search) {
		DebugStart(' MobilityCampaignAgency', ' getAgency ');
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
			'Nodes__c',
			'Nodo_Omnia_produttore__c',
			'Status',
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
			'Nodes__c' => 'Nodo',
			'Nodo_Omnia_produttore__c' => 'Codice Omnia',
			'Status' => 'Stato',
			'Owner__r' => 'Titolare',
			'Stato_Opportunit_Custom__c' => 'Stato Trattativa',
			'TECH_task_date_created__c'=> 'Ultimo contatto' //formato dd-MM-yyyy
		};

		Debug(' tableElement', tableElement);
		DebugEnd();
		return tableElement;
	}
}