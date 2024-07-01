public with sharing class LghtCallProcessingController extends RLY_Behaviour {

	public class LghtCallProcessingException extends Exception {}
	
	public class CaseOption{
		@AuraEnabled public String label;
		@AuraEnabled public String value;

		public CaseOption(){
			this.label = '';
			this.value = '';
		}
		

		public CaseOption(String label, String value){
			this.label = label;
			this.value = value;
		}
	}

	public class LghtCallProcessingResponse extends LghtResponse{
		@AuraEnabled public RecordType recordType;
		@AuraEnabled public RecordType recordTypeCase;
		@AuraEnabled public List<CaseOption> listCategory;
		@AuraEnabled public List<CaseOption> listSubCategory;
		@AuraEnabled public List<LghtSearchRow> listResult = new List<LghtSearchRow>();
		@AuraEnabled public List<Case> caseList;
	}
    
    public class LghtCallProcessingAgencyResponse extends LghtResponse{
		@AuraEnabled public RecordType recordType;
		@AuraEnabled public RecordType recordTypeCase;
		@AuraEnabled public List<CaseOption> listCategory;
		@AuraEnabled public List<CaseOption> listSubCategory;
        @AuraEnabled public Map<String,Account> AgentToAgencyMap = new Map<String,Account>();
		@AuraEnabled public List<LghtSearchAgentRow> listResult = new List<LghtSearchAgentRow>();
	}
	
	public class LghtSearchRow{
		@AuraEnabled public Account account;
		@AuraEnabled public List<Case> cases;

		public LghtSearchRow(){}

		public LghtSearchRow(Account setAccount, List<Case> setCases){
			this.account = setAccount;
			this.cases = setCases;
		}
	}
    
    public class LghtSearchAgentRow{
		@AuraEnabled public User user;
		@AuraEnabled public List<Case> cases;

		public LghtSearchAgentRow(){}

		public LghtSearchAgentRow(User setUser, List<Case> setCases){
			this.user = setUser;
			this.cases = setCases;
		}
	}

	public class LghtCaseNewResponse extends LghtResponse{
		@AuraEnabled public Case caseData;
	}

	public class LghtSearchResponse extends LghtResponse{
		@AuraEnabled public List<LghtSearchRow> listResult = new List<LghtSearchRow>();
	}
    
    public class LghtSearchAgentResponse extends LghtResponse{
        @AuraEnabled public Map<String,Account> AgentToAgencyMap = new Map<String,Account>();
		@AuraEnabled public List<LghtSearchAgentRow> listResult = new List<LghtSearchAgentRow>();
	}

	public static VFC06_ClientCallProcessing getIstanceCallProcess(Map<String,String> params){
		return new VFC06_ClientCallProcessing(params);
	}

	public static VFC16_CaseLightCreation getIstanceCaseCreation(Map<String,String> params){
		return new VFC16_CaseLightCreation(params);
	}

	public static List<CaseOption> getCaseOptions(List<SelectOption> listOptions){
		List<CaseOption> returnOptions = new List<CaseOption>();

		for(SelectOption option : listOptions){
			returnOptions.add(new CaseOption(option.getLabel(), option.getValue()));
		}

		return returnOptions;
	}

	

	@AuraEnabled
	public static LghtCallProcessingResponse initGestori(Map<String, String> params){
		String recordTypeGestori = 'Intermediary';
		String agentId = params.get('AgentId');
		String agentCode = params.get('Agentcode');
		String recordTypeCase = params.get('RecordType');
		List<Account> gestori = new List<Account>();
		List<Case> cases = new List<Case>();
		System.debug('LghtCallProcessingController.initGestori: START Params:' + JSON.serialize(params));
		LghtCallProcessingResponse response = new LghtCallProcessingResponse();
		try{
			response.recordType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = :recordTypeGestori LIMIT 1];
			response.recordTypeCase = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName =: recordTypeCase LIMIT 1];
			if(String.isNotBlank(agentId)){
				String query = LghtCallProcessingController.constructWhereClause('SELECT Id, Name, FirstName, LastName, Bank_Name__pc, CAB__pc, AXA_MPS_Descrizione_Filiale__c, Email_ListView__c from Account', 
					new Map<String, String>{
						'Id' => agentId,
						'RecordType.DeveloperName' => recordTypeGestori
					}
				);
				gestori = (List<Account>) Database.query(query);
			} else if(String.isNotBlank(agentCode)){
				String query = LghtCallProcessingController.constructWhereClause('SELECT Id, Name, FirstName, LastName, Bank_Name__pc, CAB__pc, AXA_MPS_Descrizione_Filiale__c, Email_ListView__c from Account', 
					new Map<String, String>{
						'Matricola__c' => agentCode,
						'RecordType.DeveloperName' => recordTypeGestori
					}
				);
				gestori = (List<Account>) Database.query(query);
			}
			if(!gestori.isEmpty()){
				cases = [SELECT Id, subject, RecordType.DeveloperName, accountId, account.Name, Description, Complainant__c, Origin, CaseNumber, CreatedDate, AgentName__c, AgentName__r.id FROM Case where AgentName__c =:gestori AND isclosed = false order by CreatedDate DESC];
			}
			for(Account account: gestori){
				response.listResult.add(new LghtSearchRow(account, getAccountCases(account.Id, cases)));
			}
		} catch(Exception ex){
			System.debug('LghtCallProcessingController.initGestori: Exception:' + ex.getStackTraceString());
			response.errorMessage = ex.getMessage();
		}
		System.debug('LghtCallProcessingController.initGestori: END');
		return response;
	}
	@TestVisible
	private static List<Case> getAccountCases(String accountId, List<Case> cases){
		List<Case> results = new List<Case>();
		for(Case c: cases){
			if(accountId.equalsIgnoreCase(c.AgentName__c)){
				results.add(c);
			}
		}
		return results;
	}

	@AuraEnabled
	public static List<Case> searchCaseByPartnerCode(String PartnerCode, Recordtype rt){
		//String recordTypeCase = 'Terze_Parti';
		List<Case> toRet = [select id, caseNumber, toLabel(status), CreatedDate, Partner_Address__c, Partner_Email__c, Partner_Name__c, Partner_Phone__c, Partner_Code__c, RecordTypeId from Case where recordtypeId =:rt.Id and Partner_Code__c = :PartnerCode order by createdDate desc limit 5 ];
		return toRet;
	}

	@AuraEnabled
	public static LghtCallProcessingResponse initDealer(Map<String, String> params){
		LghtCallProcessingResponse toRet = new LghtCallProcessingResponse();
		String recordTypeCase = params.get('RecordType');
		System.debug(recordTypeCase);
		String PartnerCode = params.get('Agentcode');
		try{
			List<RecordType> recType = [Select id, developername from Recordtype where developername =:recordTypeCase];
			if(recType.size() != 0){
				toRet.recordType = recType[0];
				toRet.caseList = LghtCallProcessingController.searchCaseByPartnerCode(PartnerCode, recType[0]);
				
			}
			else{
				toRet.errorMessage = 'Tipo di record non trovato!';
			}
		}
		catch(Exception ex){
			toRet.errorMessage = ex.getMessage();
		}
		return toRet;
	}

	@AuraEnabled
	public static LghtCallProcessingResponse searchGestori(Map<String, String> params){
		System.debug('LghtCallProcessingResponse.searchGestori: params ' + params);
		String recordTypeGestori = 'Intermediary';
		String firstName = params.get('firstNameSearch');
		String lastName = params.get('lastNameSearch');
		String matricola = params.get('matricolaSearch');
		String phone = params.get('phoneSearch');
		String recordTypeCase = params.get('RecordType');
		List<Account> gestori = new List<Account>();
		List<Case> cases = new List<Case>();
		System.debug('LghtCallProcessingController.initGestori: START Params:' + JSON.serialize(params));
		LghtCallProcessingResponse response = new LghtCallProcessingResponse();
		try{
			Map<String, String> queryParams = new Map<String, String>();
			if(String.isBlank(matricola) && String.isBlank(firstName) && String.isBlank(lastName) && String.isBlank(phone)){
				return response;
			}
			if(String.isNotBlank(firstName)){
				queryParams.put('FirstName', firstName);
			}
			if(String.isNotBlank(lastName)){
				queryParams.put('LastName', lastName);
			}
			if(String.isNotBlank(matricola)){
				queryParams.put('Matricola__c', matricola);
			}
			if(String.isBlank(matricola) && String.isBlank(firstName) && String.isBlank(lastName) && String.isNotBlank(phone)){
				queryParams.put('Phone', phone);
			}
			queryParams.put('RecordType.DeveloperName', recordTypeGestori);
			String query = LghtCallProcessingController.constructWhereClause('SELECT Id, Name, FirstName, LastName, Bank_Name__pc, CAB__pc, AXA_MPS_Descrizione_Filiale__c, Email_ListView__c, Matricola__c from Account', 
				queryParams
			);
			if(!queryParams.keySet().isEmpty()){
				gestori = (List<Account>) Database.query(query);
			}
			response.recordType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = :recordTypeGestori LIMIT 1];
			response.recordTypeCase = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = :recordTypeCase LIMIT 1];
			if(!gestori.isEmpty()){
				cases = [SELECT Id, RecordType.DeveloperName, subject, accountId, account.Name, Description, Complainant__c, Origin, CaseNumber, CreatedDate, AgentName__c, AgentName__r.id FROM Case where AgentName__c =:gestori AND isclosed = false order by CreatedDate DESC];
			}
			for(Account account: gestori){
				response.listResult.add(new LghtSearchRow(account, getAccountCases(account.Id, cases)));
			}
		} catch(Exception ex){
			System.debug('LghtCallProcessingController.searchGestori: Exception:' + ex.getStackTraceString());
			response.errorMessage = ex.getMessage();
		}
		System.debug('LghtCallProcessingController.searchGestori: END');
		return response;
	}

	@AuraEnabled
	public static LghtCallProcessingResponse init(Map<String, String> params){
		DebugStart('LghtCallProcessingController', 'init');
		LghtCallProcessingResponse response = new LghtCallProcessingResponse();

		try{
			response.recordType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Client' LIMIT 1];
			response.recordTypeCase = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName =: params.get('RecordType') LIMIT 1];

			//VFC16_CaseLightCreation instanceCaseCreaton = LghtCallProcessingController.getIstanceCaseCreation(params);

			//response.listCategory = LghtCallProcessingController.getCaseOptions(instanceCaseCreaton.ListCategory);
			//response.listSubCategory = LghtCallProcessingController.getCaseOptions(instanceCaseCreaton.ListSubCategory);


			VFC06_ClientCallProcessing instance = LghtCallProcessingController.getIstanceCallProcess(params);

			instance.paramPhone = params.get('Phone');
			instance.isCaringSalute = params.get('RecordType')=='AXA_Caring_Salute' ? true : false;			
			instance.isAAI = params.get('RecordType')=='Axa_Assicurazioni' ? true : false;
            
   
			instance.loadClients();

			List<VFC06_ClientCallProcessing.WrapperClientCases> responseData = new List<VFC06_ClientCallProcessing.WrapperClientCases>();
            responseData = params.get('RecordType')=='Axa_Assicurazioni' ? instance.getClients() : instance.policyClients;
            
			for(VFC06_ClientCallProcessing.WrapperClientCases data : responseData){
				response.listResult.add(new LghtSearchRow(data.Client, instance.mapClientToCases.get(data.Client.Id)));
			}
			Debug('paramPhone', instance.paramPhone);
			Debug('policyClients', instance.policyClients);
			
			response.isSuccess = true;
		}catch(LghtCallProcessingException ex){
			Debug('Exception', ex.getStackTraceString());
			response.errorMessage = ex.getMessage();
		}catch(Exception ex){
			Debug('Exception', ex.getStackTraceString());
			response.errorMessage = ex.getMessage();
		}

		Debug('response', response);
		DebugEnd();
		return response;
	}
    @AuraEnabled
	public static LghtCallProcessingAgencyResponse initAgency(Map<String, String> params){
		DebugStart('LghtCallProcessingController', 'init');
		LghtCallProcessingAgencyResponse response = new LghtCallProcessingAgencyResponse();

		try{
			response.recordType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Agency' LIMIT 1];
			response.recordTypeCase = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName =: params.get('RecordType') LIMIT 1];

			VFC06_ClientCallProcessing instance = LghtCallProcessingController.getIstanceCallProcess(params);
            instance.CaseType = [Select Id From RecordType Where SobjectType = 'Case' and DeveloperName =: params.get('RecordType')].Id;
			instance.paramPhone = params.get('Phone');
            instance.paramAgentCode = params.get('Agentcode');
            instance.searchAgentCommunityId = params.get('Agentcode');
			instance.isCaringSalute = params.get('RecordType')=='AXA_Caring_Salute' ? true : false;			
			instance.isAAI = params.get('RecordType')=='Axa_Assicurazioni' ? true : false;
            
            
            if(String.isNotBlank(instance.paramAgentCode))
               instance.SearchAAIAgents();
            else if(String.isNotBlank(instance.paramPhone))
                instance.SearchAAIAgentsbyPhone();
            
		   List <User>  responseData = instance.AgentList;
			for(User data : responseData){
				instance.selectedAAIAgentId = data.Id;
				instance.spoolAgentCases();
                response.AgentToAgencyMap = instance.AgentToAgencyMap;
				response.listResult.add(new LghtSearchAgentRow(data, instance.listAAIAgentCases));
			}
			
			response.isSuccess = true;
		}catch(LghtCallProcessingException ex){
			Debug('Exception', ex.getStackTraceString());
			response.errorMessage = ex.getMessage();
		}catch(Exception ex){
			Debug('Exception', ex.getStackTraceString());
			response.errorMessage = ex.getMessage();
		}

		Debug('response', response);
		DebugEnd();
		return response;
	}


	@AuraEnabled
	public static LghtCaseNewResponse createCase(Map<String, String> params, String accountId){
		DebugStart('LghtCallProcessingController', 'createCase');
		LghtCaseNewResponse response = new LghtCaseNewResponse();

		try{
			String lobToCase 			= params.get('LOB');
			String callerToCase 		= params.get('Caller');
			String category 			= params.get('Category');
			String subCategory 			= params.get('Subcategory');
			String PartnerCode			= params.get('Agentcode');
            String distrib				= params.get('Distribution');
			Case caseData 				= new Case();
			callerToCase = 'gestore'.equalsIgnoreCase(callerToCase) ? 'Bank Agent' : 'cliente'.equalsIgnoreCase(callerToCase) ? 'Customer' : callerToCase;
			caseData.Origin 			= AP_Constants.caseOriginPhone;
			caseData.RecordTypeId 		= Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(params.get('RecordType')).getRecordTypeId(); 
			caseData.Complainant__c 	= callerToCase;
			caseData.Lob__c				= lobToCase; 
			caseData.Category__c		= category;  
			caseData.SubCategory__c		= subCategory; 
            if(distrib!= null && String.isNotBlank(distrib)){
                caseData.Distribution_Network__c = distrib;
            }
			caseData.Phone_Call_Ids__c=params.get('PhonecallID')+'_'+params.get('CallDateTime')+'_'+params.get('PhoneCallIDB');
			if('Dealer'.equalsIgnoreCase(callerToCase)){
				caseData.Partner_Code__c = PartnerCode;
			}
			caseData.Status = AP_Constants.caseStatusAssigned;

			insert caseData;

			//if(String.isNotBlank(accountId)) caseData.AccountId = accountId;
			//if(String.isNotBlank(AccountEmail)) caseData.Account_Email__c = AccountEmail;
			//if(String.isNotBlank(PolicyId)) caseData.LinkToPolicy__c = PolicyId;
			//if(String.isNotBlank(Targa)) caseData.Targa__c = Targa;

			response.caseData = [
				SELECT Id, CaseNumber 
				FROM Case 
				WHERE id = :caseData.Id
				LIMIT 1
			];

			response.isSuccess = true;
		}catch(LghtCallProcessingException ex){
			response.errorMessage = ex.getMessage();
		}catch(Exception ex){
			response.errorMessage = ex.getMessage();
		}

		Debug('response', response);
		DebugEnd();
		return response;
	}
    @AuraEnabled
	public static LghtSearchAgentResponse searchAgent(Map<String, String> params, Map<String,String> searchContext){
		DebugStart('LghtCallProcessingController', 'search');
		Debug('params', params);
		DebugJson('searchContext', searchContext);

		LghtSearchAgentResponse response = new LghtSearchAgentResponse();

		try{
			VFC06_ClientCallProcessing instance = LghtCallProcessingController.getIstanceCallProcess(params);         
			 
            instance.CaseType = [Select Id From RecordType Where SobjectType = 'Case' and DeveloperName =: params.get('RecordType')].Id;
			instance.searchAgencyName 			= searchContext.get('searchAgencyName');
			instance.searchAgencyLastname 		= searchContext.get('searchAgencyLastname');
			instance.searchAgencyCode 			= searchContext.get('searchAgencyCode');
			instance.searchAgentCommunityId 	= searchContext.get('searchAgentCommunityId');

			instance.SearchAAIAgents();
            
            
            List <User>  responseData = instance.AgentList;
			for(User data : responseData){
				instance.selectedAAIAgentId = data.Id;
				instance.spoolAgentCases();
                response.AgentToAgencyMap = instance.AgentToAgencyMap;
				response.listResult.add(new LghtSearchAgentRow(data, instance.listAAIAgentCases));
			}
            
			
			response.isSuccess = true;
		}catch(LghtCallProcessingException ex){
			response.errorMessage = ex.getMessage();
			Debug('Exception', ex.getStackTraceString());
		}catch(Exception ex){
			response.errorMessage = ex.getMessage();
			Debug('Exception', ex.getStackTraceString());
		}

		Debug('response', response);
		DebugEnd();
		return response;
	}

	@AuraEnabled
	public static LghtSearchResponse search(Map<String, String> params, Map<String,String> searchContext){
		DebugStart('LghtCallProcessingController', 'search');
		Debug('params', params);
		DebugJson('searchContext', searchContext);

		LghtSearchResponse response = new LghtSearchResponse();

		try{ 
			VFC06_ClientCallProcessing instance = LghtCallProcessingController.getIstanceCallProcess(params);
			instance.AccountIdForSCV			= searchContext.get('AccountIdForSCV');
			instance.searchFirstName 			= searchContext.get('searchFirstName');
			instance.searchLastName 			= searchContext.get('searchLastName');
			instance.searchFiscalId 			= searchContext.get('searchFiscalId');
			instance.searchPartitaIVA 			= searchContext.get('searchPartitaIVA');
			instance.searchDateOfBirth 			= searchContext.get('searchDateOfBirth');
			instance.policyNumber 				= searchContext.get('policyNumber');

			instance.loadPolicyClients();

			List<VFC06_ClientCallProcessing.WrapperClientCases> responseData = instance.policyClients;
			for(VFC06_ClientCallProcessing.WrapperClientCases data : responseData){
				instance.selectedPolicyClientId = data.Client.Id;
				instance.loadPolicyClientCase();
				response.listResult.add(new LghtSearchRow(data.Client, instance.listPolicyClientCases));
			}

			response.isSuccess = true;
		}catch(LghtCallProcessingException ex){
			response.errorMessage = ex.getMessage();
			Debug('Exception', ex.getStackTraceString());
		}catch(Exception ex){
			response.errorMessage = ex.getMessage();
			Debug('Exception', ex.getStackTraceString());
		}

		Debug('response', response);
		DebugEnd();
		return response;
	}

	private static String constructWhereClause(String baseQuery, Map<String,String> whereMap){
		if(whereMap.size() > 0){
			baseQuery += ' WHERE ';
			Integer i = 0;
			for(String key: whereMap.keySet()){
				String value = whereMap.get(key);
				baseQuery += key + ' = \'' + value + '\'';
				if(i < whereMap.size() -1){
					baseQuery += ' AND ';
				} 
				++i;
			}
		}
		System.debug('LghtCallProcessingController.constructWhereClause: ' + baseQuery);
		return baseQuery;
	}

}