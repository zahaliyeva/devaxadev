public with sharing class MobilityCampaignDataEnrichment extends MobilityAbstract{

	public class MobilityCampaignDataEnrichmentException extends Exception {}
	public class MobilityCampaignDataEnrichmentResponse extends MobilityResponse {
		@AuraEnabled public Account account;
		@AuraEnabled public CampaignMember campaignMember;
		@AuraEnabled public Boolean hasOpenTask;
		@AuraEnabled public Map<String, MobilityCustomLayoutWrapper.FieldDefinition> fieldsDefinition;
        @AuraEnabled public Map<Object, Object> additionalData;
	}


	@AuraEnabled
	public static MobilityCampaignDataEnrichmentResponse initData(String campaignMemberId){
		DebugStart('MobilityCampaignProcessing', 'dataEnrichment');
		MobilityCampaignDataEnrichmentResponse response = new MobilityCampaignDataEnrichmentResponse();

		try {
			response.campaignMember = MobilityCampaignMemberController.getMember(campaignMemberId);

			List<String> fields = new List<String>{
                'NDG__c',
				'CIF_Privacy_1__c', 'CIF_Privacy_2__c', 'CIF_Privacy_3__c', 'CIF_Privacy_4__c', 'CIF_Privacy_5__c', 'CIF_Privacy_7__c', 
				'CIF_Mail_contact__c', 'CIF_Privacy_8__c', 'CIF_OTP_Phone_contact__c', 
				'CIF_MobilePhone_IntPrefix__c', 'CIF_PersonMobilePhone_IntPrefix__c', 'CIF_Phone_IntPrefix__c', 'CIF_Work_phone_IntPrefix__c', 
				'Fax_IntPrefix__c', 'Fax', 'CIF_Job_code__c', 'CIF_Marital_Status_code__c', 'CIF_Work_phone__c', 'CIF_Work_email__c', 
				'CIF_PersonalEmail__c', 'CIF_Job__c', 'CIF_Phone__c', 'CIF_PersonMobilePhone__c', 'CIF_MobilePhone__c', 'CIF_PersonEmail__c', 
				'CIF_Marital_Status__c', 'CIF_Document_type__c', 'CIF_Number__c', 'CIF_Expiry_date__c', 'CIF_Propaga_OMNIA_Work_Email__c', 
				'CIF_Propaga_OMNIA_Fax__c', 'CIF_Propaga_OMNIA_Personal_Email__c', 'CIF_Propaga_OMNIA_PersonEmail__c', 
				'CIF_Propaga_OMNIA_PersonMobilePhone__c', 'CIF_Propaga_OMNIA_Mobile_Phone__c', 'CIF_Propaga_OMNIA_Phone__c', 
				'CIF_Propaga_OMNIA_Work_Phone__c', 'CIF_Id_Contatto_Fax__c', 'CIF_Id_Contatto_MobilePhone__c', 'CIF_Id_Contatto_PersonalEmail__c', 
				'CIF_Id_Contatto_PersonEmail__c', 'CIF_Id_Contatto_PersonMobilePhone__c', 'CIF_Id_Contatto_Phone__c', 'CIF_Id_Contatto_WorkEmail__c', 
				'CIF_Id_Contatto_WorkPhone__c', 'Flag_Opposizione_Tel_Princ__c', 'Motivo_opposizione_Tel_Princ__c', 'Flag_Opposizione_Tel_Cell_B2C__c', 
				'Motivo_opposizione_Tel_Cell_B2C__c', 'Flag_Opposizione_Tel_Cell_B2B__c', 'Motivo_opposizione_Tel_Cell_B2B__c', 
				'Flag_Opposizione_Fax__c', 'Motivo_opposizione_Fax__c', 'Flag_Opposizione_Tel_Uff__c', 'Motivo_opposizione_Tel_Uff__c', 
				'Flag_Opposizione_Email_Pers_B2C__c', 'Motivo_opposizione_Email_Pers_B2C__c', 'Flag_Opposizione_Email_Pers_B2B__c', 
				'Motivo_opposizione_Email_Pers_B2B__c', 'Flag_Opposizione_Email_Uff__c', 'Motivo_opposizione_Email_Uff__c', 
				'RecordTypeId','Motivo_opposizione_Email_Uff__c'
			};

			String accountId = response.campaignMember.contact.Account.Id;

			accountEditLightningCTRL.ResponseDto openTastResult = accountEditLightningCTRL.getTaskDAOL(accountId);

			response.hasOpenTask = (Boolean)openTastResult.values.get('check');
			response.account = (Account)SObjectTable.getById('Account', fields, accountId);
			response.fieldsDefinition = MobilityCustomLayout.getFieldsDefinition('Account', fields);
			response.isSuccess = true;
		} catch (MobilityCampaignDataEnrichmentException ex) {
			response.errorMessage = ex.getMessage();
		}

		Debug('response', response);
		DebugEnd();
		return response;
	}

	@AuraEnabled
	public static MobilityCampaignDataEnrichmentResponse proccessDataEnrichment(String campaignId, String campaignMemberId, Account accountToSave) {
	    DebugStart('MobilityCampaignDataEnrichment', 'proccessDataEnrichment');

	    MobilityCampaignDataEnrichmentResponse response = new MobilityCampaignDataEnrichmentResponse();

	    try {
	    	accountEditLightningCTRL.ResponseDto evaluate = accountEditLightningCTRL.updateAccount(
	    		accountToSave, 
	    		campaignMemberId,
	    		campaignId,
	    		false,
	    		null,
	    		false,
	    		null
    		);
    		
	    	DebugJson('evaluate', evaluate);
			response.additionalData = evaluate.values;
			
	    	if(!evaluate.isSuccess){
	    		throw new MobilityCampaignDataEnrichmentException(evaluate.message);
	    	}

	        response.isSuccess = true;
	    } catch (MobilityCampaignDataEnrichmentException ex) {
	        response.errorMessage = ex.getMessage();
        } catch (Exception ex) {
            Debug('Exception', ex.getStackTraceString());
            response.errorMessage = ex.getMessage();
        }

	    Debug('response', response);
	    DebugEnd();
	    return response;
	}

	@AuraEnabled
	public static SObjectTable.TablePagination getDataEnrichment(Integer page, Integer perPage, Map < String, List < Object >> filters, String orderField, String orderName, String search) {
		DebugStart('MobilityCampaignProcessingDataGrid', 'getDataEnrichment');
		Debug('page', page);
		Debug('perPage', perPage);
		Debug('filters', filters);
		Debug('orderField', orderField);
		Debug('orderName', orderName);
		Debug('search', search);
		Debug('campaignId', filters.get('CampaignId'));

		String campaignId = (String)(filters.get('CampaignId'))[0];

		List<Campaign> campaignData = [Select Id, name, Type from Campaign where id =: campaignId];

		SObjectTable.SObjectStrategy strategy = MobilityCampaignProcessing.getCampaignMember(campaignId);

		strategy.searchColumns = new Set < String > {
			'TECH_Account_Name__c',
			'Status',
			'Sottostato__c',
			'Nodes__c',
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
		if(campaignData.get(0).Type == 'Core/Industriale'){
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
		}else if(campaignData.get(0).Type == 'Data Enrichment Campaign'){
			tableElement.columns = new List < String > {
				'TECH_Account_Name__c',
				'TECH_Account_Active_Insurance_Contracts__c',
				'TECH_Account_Active_Campaigns__c',
				'TECH_Client_Index__c',
				'Propensione_Acquisto__c',
				'TECH_First_expiration_date__c',
				'Status',
				'Sottostato__c',
				'Nodes__c',
				'Owner__r',
				'Data_Enrichment_Target_Phone__c',
				'Data_Enrichment_Target_Email__c',
				'Data_Enrichment_Target_Consensus__c',
				'Data_Enrichment_Target_Other__c',
				'LastModifiedDate'
			};
	
			tableElement.labels = new Map < String, String > {
				'TECH_Account_Name__c' => 'Nome e Cognome',
				'TECH_Account_Active_Insurance_Contracts__c' => 'Polizze attive',
				'TECH_Account_Active_Campaigns__c' => 'Campagne attive',
				'TECH_Client_Index__c' => 'Indice Cliente',
				'Propensione_Acquisto__c' => 'Propensione acquisto',
				'TECH_First_expiration_date__c' => 'Prima Scadenza',
				'Status' => 'Stato',
				'Sottostato__c' => 'Tracking contatto',
				'Nodes__c' => 'Nodo',
				'Owner__r' => 'Titolare',
				'Data_Enrichment_Target_Phone__c' => 'Cellulare',
				'Data_Enrichment_Target_Email__c' => 'E-mail',
				'Data_Enrichment_Target_Consensus__c' => 'Consensi',
				'Data_Enrichment_Target_Other__c' => 'Altri dati',
				'LastModifiedDate' => 'Ultima modifica' //formato dd-MM-yyyy HH:mm:ss
			};
		}else{
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
		

		Debug('tableElement', tableElement);
		DebugEnd();
		return tableElement;
	}

}