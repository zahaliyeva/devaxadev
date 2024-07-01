public with sharing class DataGridGenerateController extends RLY_Behaviour{

	public class DataGridException extends Exception {}
	public class DataGridResponse extends LghtResponse{
		@AuraEnabled public List<DataGridConfig__mdt> configs;
		@AuraEnabled public SObjectTable.TablePagination tableData;
	}

	@AuraEnabled
	public static DataGridResponse getDataGrid(String dataGridName, String sObjectName, Integer page, Integer perPage, Map<String,List<Object>> filters, String orderField, String orderName, String search, Boolean noDataRequired){
		DebugStart('DataGridGenerateController', 'getDataGrid');

		DataGridResponse response = new DataGridResponse();

		try {
			/**
			 * Retrieve Configurations
			 */
			List<DataGridConfig__mdt> configs = DataGridGenerateController.getConfig(dataGridName, sObjectName);
			response.configs = configs;

			/**
			 * Retrieve data
			 */
			response.tableData = DataGridGenerateController.getData(configs, sObjectName, page, perPage, filters, orderField, orderName, search, noDataRequired);

			response.isSuccess = true;
		} catch (DataGridException ex) {
			response.errorMessage = ex.getMessage();
			Debug('Exception', response.errorMessage);
		} catch (Exception ex){
			response.errorMessage = ex.getMessage();
			Debug('Exception', response.errorMessage);
			Debug('Exception', ex.getStackTraceString());
		}

		Debug('response', response);
		DebugEnd();

		return response;
	}

	/**
	 * Retrive List Data
	 * @param  configs     Current Configs
	 * @param  sObjectName SObject to Retrieve
	 * @param  limitData   Limit Records
	 * @return             List SObjects
	 */
	public static SObjectTable.TablePagination getData(List<DataGridConfig__mdt> configs, String sObjectName, Integer page, Integer perPage, Map<String,List<Object>> filters, String orderField, String orderName, String search, Boolean noDataRequired){
		/**
		 * Get fields to configs 
		 */
		List<String> fieldsList = DataGridGenerateController.getFields(configs);
		fieldsList.add('Id');

		/**
		 * Generare query
		 */
		Set<String> fields = new Set<String>(fieldsList);
		String objectName = sObjectName;

		SObjectTable.SObjectStrategy strategy = new SObjectTable.SObjectStrategy();
		strategy.fieldsSet = fields;
		strategy.sobjectName = objectName;
		//strategy.addFilters(filters, true);

		//INPUT DATA
		strategy.perPage = perPage;
		strategy.page = page;
		strategy.searchString = search;
		strategy.setOrder(orderField, orderName, true);
		
		strategy.addFilters(filters, true);

		//RESPONSE
		SObjectTable.TablePagination tableElement = new SObjectTable.TablePagination();
		if(!noDataRequired) tableElement = SObjectTable.paginationData(strategy);

		tableElement.columns = DataGridGenerateController.getFieldsVisible(configs);
		tableElement.labels = DataGridGenerateController.getLabels(configs);

		return tableElement;
	}

	/**
	 * Retrieve Configurations
	 * @param  dataGridName DataGrid Name
	 * @param  sObjectName  SObject Name
	 * @return              List Configurations
	 */
	public static List<DataGridConfig__mdt> getConfig(String dataGridName, String sObjectName){
		return [
			SELECT DataGrid__c, Sobject__c, Label__c, Field__c, Type__c, Index__c
			FROM DataGridConfig__mdt
			WHERE DataGrid__c = :dataGridName
			AND Sobject__c = :sObjectName
		];
	}

	/**
	 * Get List Fields to Configs
	 * @param  configs List Configs
	 * @return         List Fields
	 */
	public static List<String> getFields(List<DataGridConfig__mdt> configs){
		List<String> listFields = new List<String>();

		for(DataGridConfig__mdt config : configs){
			listFields.add(config.Field__c);
		}

		return listFields;
	}

	/**
	 * Get List Fields to Configs
	 * @param  configs List Configs
	 * @return         List Fields
	 */
	public static List<String> getFieldsVisible(List<DataGridConfig__mdt> configs){
		List<String> listFields = new List<String>();

		for(DataGridConfig__mdt config : configs){
			//TODO: Add Field Visible
			listFields.add(config.Field__c);
		}

		return listFields;
	}

	/**
	 * Get List Fields to Configs
	 * @param  configs List Configs
	 * @return         List Fields
	 */
	public static Map<String, String> getLabels(List<DataGridConfig__mdt> configs){
		Map<String, String> listLabels = new Map<String, String>();

		for(DataGridConfig__mdt config : configs){
			listLabels.put(config.Field__c, config.Label__c);
		}

		return listLabels;
	}


}