public with sharing class MobilityCampaignMarketing extends MobilityAbstract{

	public class MobilityCampaignDataEnrichmentException extends Exception {}
	public class MobilityCampaignDataEnrichmentResponse extends MobilityResponse {}

	@AuraEnabled
	public static SObjectTable.TablePagination getMarketing(Integer page, Integer perPage, Map < String, List < Object >> filters, String orderField, String orderName, String search) {
		DebugStart(' MobilityCampaignMarketing', ' getMarketing ');
		Debug(' page', page);
		Debug(' perPage', perPage);
		Debug(' filters', filters);
		Debug(' orderField', orderField);
		Debug(' orderName', orderName);
		Debug('campaignId', filters.get('CampaignId'));

		String campaignId = (String)(filters.get('CampaignId'))[0];

		List<Campaign> campaignCrossSelling = [Select Id, name, Type from Campaign where id =: campaignId];

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
		if(campaignCrossSelling.get(0).Type == 'Cross Selling')
		{
			tableElement.columns = new List < String > {
				'TECH_Account_Name__c',
				'Tot_pol_a_scad__c',
				'Prox_data_scad__c',
				'Num_pol_prox_scad__c',
				'LoB_possedute__c',
				'Alta_Propensione_Acquisto__c',
				'Nodes__c',
				'Nodo_Omnia_produttore__c',
				'Status',
				'Sottostato__c',
				'Owner__r',
				'Stato_Opportunit_Custom__c',
				'TECH_task_date_created__c'
			};

			tableElement.labels = new Map < String, String > {
				'TECH_Account_Name__c' => 'Nome e Cognome',
				'Tot_pol_a_scad__c' => 'Tot pol a scad',
				'Prox_data_scad__c' => 'Prox data scad',
				'Num_pol_prox_scad__c' => 'Num pol prox scad',
				'LoB_possedute__c' => 'LoB Possedute',
				'Alta_Propensione_Acquisto__c' => 'Alta Propensione Acquisto',
				'Status' => 'Stato',
				'Sottostato__c' => 'Tracking contatto',
				'Nodes__c' => 'Nodo',
				'Nodo_Omnia_produttore__c' => 'Codice Omnia',
				'Owner__r' => 'Titolare',
				'Stato_Opportunit_Custom__c' => 'Stato Trattativa',
				'TECH_task_date_created__c'=> 'Ultimo contatto' //formato dd-MM-yyyy
			};
		}

		else
		{
		tableElement.columns = new List < String > {
			'TECH_Account_Name__c',
			'TECH_Account_Active_Insurance_Contracts__c',
			'TECH_Account_Active_Campaigns__c',
			'TECH_Client_Index__c',
			'Propensione_Acquisto__c',
			'TECH_First_expiration_date__c',
			'Nodes__c',
			'Nodo_Omnia_produttore__c',
			'Status',
			'Sottostato__c',
			'Owner__r',
			'Stato_Opportunit_Custom__c',
			'TECH_task_date_created__c'
		};
		tableElement.labels = new Map < String, String > {
			'TECH_Account_Name__c' => 'Nome e Cognome',
			'TECH_Account_Active_Insurance_Contracts__c' => 'Polizze attive',
			'TECH_Account_Active_Campaigns__c' => 'Campagne attive',
			'TECH_Client_Index__c' => 'Indice Cliente',
			'Propensione_Acquisto__c' => 'Propensione acquisto',
			'TECH_First_expiration_date__c' => 'Prima Scadenza',
			'Nodes__c' => 'Nodo',
			'Nodo_Omnia_produttore__c' => 'Codice Omnia',
			'Status' => 'Stato',
			'Sottostato__c' => 'Tracking contatto',
			'Owner__r' => 'Titolare',
			'Stato_Opportunit_Custom__c' => 'Stato Trattativa',
			'TECH_task_date_created__c'=> 'Ultimo contatto' //formato dd-MM-yyyy
		};
		}

		Debug(' tableElement', tableElement);
		DebugEnd();
		return tableElement;
	}
}