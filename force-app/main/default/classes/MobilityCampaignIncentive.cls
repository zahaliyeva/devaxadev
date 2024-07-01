public with sharing class MobilityCampaignIncentive extends MobilityAbstract{

    @AuraEnabled
	public static SObjectTable.TablePagination getIncentive(Integer page, Integer perPage, Map < String, List < Object >> filters, String orderField, String orderName, String search){
		DebugStart('MobilityCampaignInformative', 'getInformative');
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
			'Name',
			'Fiscal_Code__c',
			'Vat_Number__c',
			'codice_nodo_OMNIA__c'
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
			'Name',
			'Status',
			'codice_nodo_OMNIA__c',
			'ndg_certificato__c',
			'flg_attivo__c',
			'target_2018__c',
			'stop_carta_2018__c',
			'firma_digitale_2018__c',
			'LastModifiedDate'
		};

		tableElement.labels = new Map < String, String > {
			'Name' => 'Nome e Cognome',
			'Status' => 'Stato',
			'codice_nodo_OMNIA__c' => 'Nodo',
			'ndg_certificato__c' => 'Stato Certificazione',
			'flg_attivo__c' => 'Cliente Attivo',
			'target_2018__c' => 'Target',
			'stop_carta_2018__c' => 'Stop Carta',
			'firma_digitale_2018__c' => 'Firma Digitale',
			'LastModifiedDate' => 'Data ultimo aggiornamento'
		};

		Debug(' tableElement', tableElement);
		DebugEnd();
		return tableElement;
	}
}