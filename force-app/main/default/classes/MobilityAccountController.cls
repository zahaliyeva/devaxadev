public with sharing class MobilityAccountController extends MobilityAbstract {

	public class MobilityAccountResponse extends MobilityResponse{}

	public class WrapperSobject{
		@AuraEnabled public String fieldName;
		@AuraEnabled public Object definition;
	}

	@AuraEnabled
	public static Account getAccountByNdg(String ndgId) {
		List<Account> listAccount = [
			SELECT
				Id, BlackList_Abitazione__c, BlackList_Auto__c, BlackList_Aziende__c,
				BlackList_Commerciale__c, BlackList_Infortuni__c,
				BlackList_Malattia__c, BlackList_Protection__c, BlackList_Rinnovo__c,
				BlackList_Saving__c, BlackList_Servizio__c, Ultima_modifica_blacklist__c,
				Blacklist_Processi__c
			FROM Account
			WHERE NDG__c =: ndgId
		];

		if (listAccount.size() == 0) return null;
		return listAccount[0];
	}

	@AuraEnabled
	public static List<MobilityAccountController.WrapperSobject> getSobjectFields(String sObjectName){
		try {
			SObjectType sobjectDefinition = Schema.getGlobalDescribe().get(sObjectName);

			Map<String, Schema.SObjectField> result = sobjectDefinition.getDescribe().fields.getMap();
			List<MobilityAccountController.WrapperSobject> resultList = new List<MobilityAccountController.WrapperSobject>();

			for(String fieldKey : result.keySet()){
				Schema.SObjectField field = result.get(fieldKey);
				Schema.DescribeFieldResult definition = field.getDescribe();

				MobilityAccountController.WrapperSobject fieldWrapper = new MobilityAccountController.WrapperSobject();
				fieldWrapper.fieldName = '' + field;
				fieldWrapper.definition = JSON.deserializeUntyped(JSON.serialize(definition));

				resultList.add(fieldWrapper);
			}

			return resultList;
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	@AuraEnabled
	public static Account getAccountById(String accountId) {
		List<Account> listAccount = [
			SELECT
				Id, BlackList_Abitazione__c, BlackList_Auto__c, BlackList_Aziende__c,
				BlackList_Commerciale__c, BlackList_Infortuni__c,
				BlackList_Malattia__c, BlackList_Protection__c, BlackList_Rinnovo__c,
				BlackList_Saving__c, BlackList_Servizio__c, Ultima_modifica_blacklist__c
			FROM Account
			WHERE Id = :accountId
		];

		if (listAccount.size() == 0) return null;
		return listAccount[0];
	}

	@AuraEnabled
	public static ContactHistoryCTRL.ResponseDto getContactHistory(Integer limitRows, String ndgId) {
		Account account = MobilityAccountController.getAccountByNdg(ndgId);
		
		if (account == null) return new ContactHistoryCTRL.ResponseDto();

		List < Id > ids = new List < Id > {
			account.Id
		};
		Integer limitResult = limitRows;

		ContactHistoryCTRL.ResponseDto response = ContactHistoryCTRL.getHistoryItemWrappers(ids, limitResult);

		return response;
	}

	@AuraEnabled
	public static ContactHistoryCTRL.ResponseDto getFilteredContactHistory(Integer limitRows, String ndgId, String Filter) {
		Account account = MobilityAccountController.getAccountByNdg(ndgId);
		
		if (account == null) return new ContactHistoryCTRL.ResponseDto();

		List < Id > ids = new List < Id > {
			account.Id
		};
		Integer limitResult = limitRows;

		ContactHistoryCTRL.ResponseDto response = ContactHistoryCTRL.getHistoryItemWrappers(ids, limitResult, Filter);

		return response;
	}

	@AuraEnabled
	public static MobilityAccountResponse updateAccountBlackList(Account account) {
		DebugStart('MobilityAccountController', 'updateAccountBlackList');

		MobilityAccountResponse response = new MobilityAccountResponse();

		try {
			account.Ultima_modifica_blacklist__c = Datetime.now();
			return MobilityAccountController.updateAccount(account);
		} catch (MobilityException ex) {
			response.errorMessage = ex.getMessage();
		} catch (Exception ex) {
			response.errorMessage = ex.getMessage();
		}

		DebugEnd();
		return response;
	}

	@AuraEnabled
	public static MobilityAccountResponse updateAccount(Account account) {
		DebugStart('MobilityAccountController', 'updateAccount');

		MobilityAccountResponse response = new MobilityAccountResponse();
		Debug('account', account);

		try {
			update account;
			response.isSuccess = true;
		} catch (MobilityException ex) {
			response.errorMessage = ex.getMessage();
		} catch (Exception ex) {
			response.errorMessage = ex.getMessage();
		}

		DebugEnd();
		return response;
	}

	@AuraEnabled
	public static SObjectTable.TablePagination getContactHistoryPage(String ndgId, Integer page, Integer perPage, Integer maxPerPage, Integer lengthList) {
		ContactHistoryCTRL.ResponseDto response = MobilityAccountController.getContactHistory(99, ndgId);

		List < ContactHistoryCTRL.HistoryItemWrapper > datalist = (List < ContactHistoryCTRL.HistoryItemWrapper > ) response.values.get('ContactHistoryList');

		System.debug(datalist);

		SObjectTable.TablePagination pagination = new SObjectTable.TablePagination(
			datalist, //elements
			datalist.size(), //total
			page, //page
			perPage, //perPage
			maxPerPage, //maxPerPage
			lengthList, //lengthList
			true //hasFullData
		);
		pagination.baseUrl = response.CRMUrl;
		System.debug(JSON.serialize(pagination));
		return pagination;
	}

	@AuraEnabled
	public static SObjectTable.TablePagination getFilteredContactHistoryPage(String ndgId, Integer page, Integer perPage, Integer maxPerPage, Integer lengthList, String Filter) {
		ContactHistoryCTRL.ResponseDto response = MobilityAccountController.getFilteredContactHistory(99, ndgId, Filter);

		List < ContactHistoryCTRL.HistoryItemWrapper > datalist = (List < ContactHistoryCTRL.HistoryItemWrapper > ) response.values.get('ContactHistoryList');

		System.debug(datalist);

		SObjectTable.TablePagination pagination = new SObjectTable.TablePagination(
			datalist, //elements
			datalist.size(), //total
			page, //page
			perPage, //perPage
			maxPerPage, //maxPerPage
			lengthList, //lengthList
			true //hasFullData
		);

		pagination.baseUrl = response.CRMUrl;
		System.debug(JSON.serialize(pagination));
		return pagination;
	}
}