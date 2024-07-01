public with sharing class LghtCaseFindAssociate extends RLY_Behaviour {

	public class LghtCaseFindAssociateException extends Exception {}

	public class CaseResult extends LghtResponse{
		@AuraEnabled public Boolean isAgent;
		@AuraEnabled public Boolean isCorporate;
        @AuraEnabled public Boolean isFromCIF;
		@AuraEnabled public Case caseData;
		@AuraEnabled public List<Account> listCustomerResult;
		@AuraEnabled public String customerRecordType;
		@AuraEnabled public String corporateRecordType;
	}
    
    public class CasePoliciesResult extends LghtResponse{
        @AuraEnabled public List<InsurancePolicy__c> listPolicyResult;
        @AuraEnabled public List<InsurancePolicyAAF__c> listPolicyResultAAF;
        @AuraEnabled public Boolean isFamilyProtect = false;
        @AuraEnabled public Boolean noAccount = false;
        @AuraEnabled public Boolean NoPolicy = false;
	}
    
    public static VFC08_CaseFindAssociatedAccount getIstance(Case currentCase){
        return LghtCaseFindAssociate.getIstance(currentCase, new Map<String,String>());
    }

    public static VFC08_CaseFindAssociatedAccount getIstance(Case currentCase, Map<String, String> params){
        DebugStart('LghtCaseFindAssociate', 'getIstance');
        Debug('currentCase', currentCase);
        Debug('params', params);

        VFC08_CaseFindAssociatedAccount istance = new VFC08_CaseFindAssociatedAccount(currentCase);

        //istance.cas                           = currentCase;
        istance.isAgent                         = false;
        istance.isCorporate                     = false;
        istance.isNew                           = false;

        istance.transactionStatus               = false;
        istance.overwriteEmail                  = false;
        istance.transactionError                = 'firstLoad';
        istance.customer                        = new Account();
        istance.selectedCustomer                = new Account(); 
        istance.selectedCorporateCustomer       = new Account(Recordtypeid = istance.rtAccCorporateId);

        Set<String> doNotCopyEmail = new Set<String>(); 
        
        if(MPS_Code_Variables__c.getValues('DoNotCopyEmail')!=null){
            if(String.isNotBlank(MPS_Code_Variables__c.getValues('DoNotCopyEmail').value__c)){
                for(String value : (MPS_Code_Variables__c.getValues('DoNotCopyEmail').value__c).split(';')){
                    doNotCopyEmail.add(value);                
                }
            }
        }

        if(string.isNotBlank(currentCase.SuppliedEmail) && !doNotCopyEmail.contains(currentCase.SuppliedEmail)){
            istance.selectedCustomer.PersonEmail                        = currentCase.SuppliedEmail;
            istance.selectedCorporateCustomer.Account_email__c          =  currentCase.SuppliedEmail;
        }

        istance.listCustomerResult = new list<Account>();
        istance.UrlParameterMap = params;

        if(istance.UrlParameterMap.containsKey('CaseRecordType')){
            istance.FamilyProtectUser = (istance.UrlParameterMap.get('CaseRecordType') == AP_Constants.getDeveloperIdMap(AP_Constants.sobjectCas).get(AP_Constants.rtCaseAAI));
        }

        if(!istance.UrlParameterMap.containsKey('type')){
            istance.isAgent = true;
            istance.selectedCustomer.recordtypeid = istance.rtAccIntemediaryId;
        }else if(istance.UrlParameterMap.get('type') == 'customer'){
            istance.isAgent = false;
            istance.selectedCustomer.recordtypeid = istance.rtAccIndividualId;
        }

        DebugJson('istance', istance);
        DebugEnd();
        return istance;
    }

    @AuraEnabled
    public static CaseResult initContext(String recordId, Map<String,String> params){
        DebugStart('LghtCaseFindAssociate', 'initContext');
        Debug('recordId', recordId);
        Debug('params', params);

        CaseResult response = new CaseResult();

        try{
            Case currentCase = LghtCaseManageController.getCase(recordId);
            Debug('currentCase', currentCase);

            VFC08_CaseFindAssociatedAccount istance = LghtCaseFindAssociate.getIstance(currentCase, params);

            response.isAgent = istance.isAgent;
            response.isCorporate = istance.isCorporate;
            response.customerRecordType = istance.selectedCustomer.recordtypeid;
            response.corporateRecordType = istance.selectedCorporateCustomer.recordtypeid;

            response.isSuccess = true;
        }catch(LghtCaseFindAssociateException ex){
            response.errorMessage = ex.getMessage();
        }catch(Exception ex){
            response.errorMessage = ex.getMessage();
        }

        Debug('response', response);
        DebugEnd();
        return response;
    }

    @AuraEnabled
    public static CaseResult searchCustomer(String recordId, Map<String,String> params, Account searchCustomer){
    	DebugStart('LghtCaseFindAssociate', 'searchCustomer');
    	Debug('recordId', recordId);
    	Debug('params', params);

    	CaseResult response = new CaseResult();

    	try{
    		Case currentCase = LghtCaseManageController.getCase(recordId);
    		Debug('currentCase', currentCase);

    		VFC08_CaseFindAssociatedAccount istance = LghtCaseFindAssociate.getIstance(currentCase, params);
    		istance.customer = searchCustomer;
    		Debug('searchCustomer', searchCustomer);
    		istance.searchCustomer();

    		response.isAgent = istance.isAgent;
    		response.isCorporate = istance.isCorporate; 
    		response.listCustomerResult = istance.listCustomerResult;
            response.isFromCIF=false;
    		Debug('listCustomerResult', response.listCustomerResult);
                        
            if (!response.isAgent && response.listCustomerResult.size()<=0 )
            {
               Debug('Do fullsearch');      
              	response.listCustomerResult = doSearchAccounOnCIF(!response.isCorporate,  searchCustomer, currentCase.Agency_Code__c );
                response.isFromCIF=true;          
            }
    		response.isSuccess = true;
		}catch(LghtCaseFindAssociateException ex){
			response.errorMessage = ex.getMessage();
		}catch(Exception ex){
			response.errorMessage = ex.getMessage();
		}

		Debug('response', response);
		DebugEnd();
		return response;
    }
   
    @AuraEnabled
    public static CaseResult asociateCustomerToCase(String recordId, Map<String,String> params, Account selectedCustomer){
    	DebugStart('LghtCaseFindAssociate', 'asociateCustomerToCase');
    	Debug('recordId', recordId);
    	Debug('params', params);

        CaseResult response = new CaseResult();

        try{
            Case currentCase = LghtCaseManageController.getCase(recordId);
            
            VFC08_CaseFindAssociatedAccount istance = LghtCaseFindAssociate.getIstance(currentCase, params);
            istance.selectedCustomer = selectedCustomer;

            istance.asociateCustomerToCase();

            if(!istance.transactionStatus) throw new LghtCaseFindAssociateException(istance.transactionError);

            response.isSuccess = true;
        }catch(LghtCaseFindAssociateException ex){
            response.errorMessage = ex.getMessage();
        }catch(Exception ex){
            response.errorMessage = ex.getMessage();
        }

        Debug('response', response);
        DebugEnd();
        return response;
    }

    @AuraEnabled
    public static CaseResult saveCustomer(String recordId, Map<String,String> params, Account selectedCustomer){
        DebugStart('LghtCaseFindAssociate', 'searchCustomer');
        Debug('recordId', recordId);
        Debug('params', params);

        CaseResult response = new CaseResult();

        try{
            Case currentCase = LghtCaseManageController.getCase(recordId);
            
            VFC08_CaseFindAssociatedAccount istance = LghtCaseFindAssociate.getIstance(currentCase, params);
            if(!istance.isCorporate){
                istance.selectedCustomer = selectedCustomer;
            }else{
                istance.selectedCorporateCustomer = selectedCustomer;
            }

            istance.saveCustomer();
            if(!istance.transactionStatus) throw new LghtCaseFindAssociateException(istance.transactionError);
            
            response.isSuccess = true;
        }catch(LghtCaseFindAssociateException ex){
            response.errorMessage = ex.getMessage();
        }catch(Exception ex){
            response.errorMessage = ex.getMessage();
        }

        Debug('response', response);
        DebugEnd();
        return response;
    }
    
    public static List<Account> doSearchAccounOnCIF(Boolean isB2C,  Account searchCustomer, String agencyCode){
        DebugStart('LghtCaseFindAssociate', 'doSearchAccounOnCIF');
        List<Account> accountList = new List<Account>();   
        AccountSearchCtrl.RequestObj req = new  AccountSearchCtrl.RequestObj();
        AccountSearchCtrl.ResponseDto requestOutcome = new AccountSearchCtrl.ResponseDto(true, '');
        req.nome = req.cognome = req.cf = req.ragSoc = req.piva  = req.codAg = '';
        
		req.codAg=  String.isNotBlank(agencyCode) ?  agencyCode : '1' ;
        
        if(isB2C){
            req.nome = searchCustomer.FirstName;
            req.cognome = searchCustomer.Lastname;
            req.cf = searchCustomer.Fiscal_ID__c;
        }
        else{
            req.ragSoc =searchCustomer.Name;
            req.piva=searchCustomer.Partita_IVA__c;
        }
        Debug('request', req);
        requestOutcome = AccountSearchCtrl.sendRequest(req,isB2C);
        Debug('requestOutcome', requestOutcome);  
        
        if (requestOutcome.isSuccess){ 
            
            for (Object resItem : requestOutcome.values.keyset()){
                accountList.add((Account) requestOutcome.values.get(resItem));                       
            }
        }
   
        return accountList;
    }
    
     @AuraEnabled
    public static CaseResult importAssociateCustomerToCase(String recordId, Map<String,String> params){
        DebugStart('LghtCaseFindAssociate', 'importAssociateCustomerToCase');
    	Debug('recordId', recordId);
    	Debug('params', params);
        CaseResult response = new CaseResult();
        Boolean isB2C = params.get('isCorporate') == 'false' ? true : false;
        
        AccountSearchCtrl.ResponseDto requestOutcome = new AccountSearchCtrl.ResponseDto(true, '');
        requestOutcome = AccountSearchCtrl.sendRequest_fullsearch( params.get('NDG'));
        Debug('requestOutcome', requestOutcome);  
        Account fullAccount = new Account();
        
        if (requestOutcome.isSuccess){ 
                 
        id RecordTypeidforAccount;
        if(isB2C)
            RecordTypeidforAccount = [select Id,name from RecordType where DeveloperName = 'B2C_Client' and SobjectType = 'Account'].Id;
        else
            RecordTypeidforAccount = [select Id,name from RecordType where DeveloperName = 'B2B_Client' and SobjectType = 'Account'].Id;
        
            fullAccount = (Account) requestOutcome.values.get('returnedCIFAccount');
            fullAccount.RecordTypeid= RecordTypeidforAccount;
            fullAccount.TECH_Company__c='AAI';
            
            try{
                Database.SaveResult SaveResult = database.insert (fullAccount);
                response = LghtCaseFindAssociate.asociateCustomerToCase(recordId, params, fullAccount);
            }
            catch(LghtCaseFindAssociateException ex){
                response.errorMessage = ex.getMessage();
            }catch(Exception ex){
                response.errorMessage = ex.getMessage();
            }
        }
        
        return response;

    }

    @AuraEnabled
    public static CasePoliciesResult searchPolicies(Map<String,String> params){
    	DebugStart('LghtCaseFindAssociate', 'searchPolicies');
    	Debug('params', params);
        Id AccountId;
        Id PolicyId;
        String FamilyProtectid;
        Id PolicyFamProtectId;

     
        CasePoliciesResult response = new CasePoliciesResult();
        response.listPolicyResult = new  List<InsurancePolicy__c>();
        response.listPolicyResultAAF = new  List<InsurancePolicyAAF__c>();
        
        try{
            FamilyProtectid = AP_Constants.getDeveloperIdMap(AP_Constants.sobjectAcc).get(AP_Constants.rtAccAAFB2C);
            
            if(String.isNotBlank(params.get('Account'))){
                AccountId = params.get('Account');
                List<Account>AccRecTypId = ([Select RecordTypeId from Account where Id=:AccountId]);

                if(AccRecTypId[0].RecordTypeId ==FamilyProtectid )
                response.isFamilyProtect = true;          
            }
            else
             response.noAccount = true;

            if(String.isNotBlank(params.get('Policy')))
             {
                PolicyId = params.get('Policy');                 
             }
             else if(String.isNotBlank(params.get('PolicyAAF')))
             {
                 response.isFamilyProtect = true;
                 PolicyFamProtectId = params.get('PolicyAAF'); 
             }             
             else             
                 response.NoPolicy = true;  
                 
                 
                 if(!response.NoAccount)
                 {
                  
                     if(!response.isFamilyProtect)
                     {
                         String soql = 'SELECT id, Name, TECH_Company__c,CUID__r.Name , Policy_Holder_Fiscal_Id__c,CCDATE__c,EXPIRY_DATE__c,Product__c FROM   InsurancePolicy__c where CUID__c =: AccountId '; 
                         
                         for(InsurancePolicy__c inpol:Database.query(soql))
                         {
                             response.listPolicyResult.add(inpol);
                         }
                     }
                     else
                     {
                         String soql1 = 'Select Id,Name,Subscriber_national_identifier__r.Name, Subscriber_national_identifier__r.Codice_Fiscale_AAF__c,Contract_Effective_date__c,Contract_Termination_Date__c,Product_code_ADP__c From InsurancePolicyAAF__c where Subscriber_national_identifier__c =: AccountId';
                         
                         for(InsurancePolicyAAF__c inpolAAF:Database.query(soql1))
                         {
                             response.listPolicyResultAAF.add(inpolAAF);
                         }
                     }
                 }
                 else if(response.NoAccount && !response.NoPolicy)
                 {
                   
                     if(!response.isFamilyProtect)
                     {
                         String soql = 'SELECT id, Name, TECH_Company__c,CUID__r.Name,CUID__r.Id  , Policy_Holder_Fiscal_Id__c,CCDATE__c,EXPIRY_DATE__c,Product__c FROM InsurancePolicy__c where Id =: PolicyId '; 
                         
                         for(InsurancePolicy__c inpol:Database.query(soql))
                         {
                             response.listPolicyResult.add(inpol);
                         }
                     }
                     else
                     {
                         String soql1 = 'Select Id,Name,Subscriber_national_identifier__r.id,Subscriber_national_identifier__r.Name, Subscriber_national_identifier__r.Codice_Fiscale_AAF__c,Contract_Effective_date__c,Contract_Termination_Date__c,Product_code_ADP__c From InsurancePolicyAAF__c where Id =: PolicyFamProtectId'; 
                         
                         for(InsurancePolicyAAF__c inpolAAF:Database.query(soql1))
                         {
                             response.listPolicyResultAAF.add(inpolAAF);
                         }                
                     }          
                 }
                     
            Debug('listPolicyResult: '   +response.listPolicyResult);
            Debug('listPolicyResultAAF: '+response.listPolicyResultAAF);   
            response.isSuccess = true;
        }catch(LghtCaseFindAssociateException ex){
            response.errorMessage = ex.getMessage();
        }catch(Exception ex){
            response.errorMessage = ex.getMessage();
        }

        Debug('response', response);
        DebugEnd();
        return response;
    }

     @AuraEnabled
    public static CaseResult asociatePolicyToCase(String recordId, Integer index, Object params ){
    	DebugStart('LghtCaseFindAssociate', 'asociatePolicyToCase');
        Debug('recordId', recordId);
        Debug('index', index);
        Debug('params', params);   
        
        CasePoliciesResult data = new CasePoliciesResult();
        data= (CasePoliciesResult) System.JSON.deserialize( System.JSON.serialize(params), CasePoliciesResult.class);

        CaseResult response = new CaseResult();

        try{

            if(!data.NoAccount)          
            {
                if(!data.isFamilyProtect)                   
                    update new Case (id=recordId , LinkToPolicy__c = data.listPolicyResult[index].Id  );	
                else
                    update new Case (id=recordId , Insurance_Policy_AAF__c = data.listPolicyResultAAF[index].Id  );
            }
			  
            else if(data.NoAccount && !data.NoPolicy)
            {
                if(!data.isFamilyProtect)
                	update new Case (id=recordId , AccountId = data.listPolicyResult[index].CUID__r.Id);
                else
                    update new Case (id=recordId , AccountId = data.listPolicyResultAAF[index].Subscriber_national_identifier__r.id);
            }    
            response.isSuccess = true;
        }catch(LghtCaseFindAssociateException ex){
            response.errorMessage = ex.getMessage();
        }catch(Exception ex){
            response.errorMessage = ex.getMessage();
        }

        Debug('response', response);
        DebugEnd();
        return response;
        
    }
    
    
}