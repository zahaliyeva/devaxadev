public with sharing class MobilityCampaignInformative extends MobilityAbstract{

	public class MobilityCampaignDataEnrichmentException extends Exception {}
	public class MobilityCampaignDataEnrichmentResponse extends MobilityResponse {}

	@AuraEnabled
	public static SObjectTable.TablePagination getInformative(Integer page, Integer perPage, Map < String, List < Object >> filters, String orderField, String orderName, String search) {
		DebugStart('MobilityCampaignInformative', 'getInformative');
		Debug('page', page);
		Debug('perPage', perPage);
		Debug('filters', filters);
		Debug('orderField', orderField);
		Debug('orderName', orderName);
		Debug('search', search);
		Debug('campaignId', filters.get('CampaignId'));

		String campaignId = (String)(filters.get('CampaignId'))[0];

		List<Campaign> campaignEmail = [Select Id, name, Type from Campaign where id =: campaignId];

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
		if(campaignEmail.get(0).Type == 'Email')
		{
			tableElement.columns = new List < String > {
			'TECH_Account_Name__c',
			'Status',
			'Informative_Contact_Outcome__c',
			'Nodes__c',
			'Email_errata__c',
			//'Nodo_Omnia_produttore__c',
			'Tipo_errore__c',
			'Owner__r',
			'LastModifiedDate'
			/*'TECH_Account_Active_Insurance_Contracts__c',
			'TECH_Account_Active_Campaigns__c',
			'TECH_Client_Index__c',
			'TECH_First_expiration_date__c',*/
			//'Codice_Agenzia_Subagente__c',
			};

		tableElement.labels = new Map < String, String > {
			'TECH_Account_Name__c' => 'Nome e Cognome',
			//'TECH_First_expiration_date__c' => 'Prima Scadenza',
			'Status' => 'Stato',
			'Informative_Contact_Outcome__c' => 'Esito di contatto informativo',
			'Nodes__c' => 'Nodo',
			'Email_errata__c'=> 'Email errata',
			'Tipo_errore__c' => 'Tipo errore',
			//'Nodo_Omnia_produttore__c' => 'Codice Omnia',
			'Owner__r' => 'Titolare',
			'LastModifiedDate' => 'Ultima modifica effettutata'
			/*'TECH_Account_Active_Insurance_Contracts__c' => 'Polizze attive',
			'TECH_Account_Active_Campaigns__c' => 'Campagne attive',
			'TECH_Client_Index__c' => 'Indice Cliente',*/
			//'Codice_Agenzia_Subagente__c' => 'Codice Agenzia/Subagente',
			 //formato dd-MM-yyyy HH:mm:ss
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