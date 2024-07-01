public with sharing class lghtCreateCaseWithAttrCTRL {
    
    public enum CallerType {
        GESTORI,
        AGENTI,
        CLIENTI
    }
    
    public class initWrapper{

        @AuraEnabled
        public boolean needSearch {get;set;}
        @AuraEnabled
        public String FirstName {get;set;}
        @AuraEnabled
        public String Name {get;set;}
        @AuraEnabled
        public String LastName {get;set;}
        @AuraEnabled
        public String AgencyCode {get;set;}
        @AuraEnabled
        public String AgentCode {get;set;}
        @AuraEnabled
        public String FiscalId {get;set;}
        @AuraEnabled
        public String PIva {get;set;}
        @AuraEnabled
        public String AccountIdForSCV {get;set;}
        @AuraEnabled
        public String FiscalIdListView {get;set;}
        @AuraEnabled
        public String InsurancePolicy {get;set;}
    }

    public class completeWrapper{
        @AuraEnabled
        public boolean isSuccess {get;set;}
        @AuraEnabled
        public initWrapper InitWrapper {get;set;}
        @AuraEnabled
        public List<Case> CasesList {get;set;}
        @AuraEnabled
        public Map<String, String> cToCreate {get;set;}

        public completeWrapper(){
            this.isSuccess = true;
        }

    }

    public class InitManagementWrapper {
    @AuraEnabled
        public  String IVR_Name {get;set;}
        @AuraEnabled
        public  Boolean needError {get;set;}
    }

    @AuraEnabled
    public static InitManagementWrapper InitManagement(String VCId){
        InitManagementWrapper toRet = new InitManagementWrapper();
        VoiceCall vc = [Select IVR_Name__c, CaseRecordType__c from VoiceCall where Id =: VCId ]; // NOPMD  Fix CRUD violation
        if(String.isNotBlank(vc.IVR_Name__c) && String.isNotBlank(vc.CaseRecordType__c)){
            toRet.IVR_Name = vc.IVR_Name__c;
            toRet.needError = false;
        }
        else{
            toRet.needError = true;
        }

        return toRet;
    }
    
    @AuraEnabled
    public static completeWrapper InitClienti(String VCId){
        
        completeWrapper toRet = new completeWrapper();
        InitWrapper iW = new InitWrapper();
        toRet.InitWrapper = iW;
        iW.needSearch = true;
        try{
            List<VoiceCall> VCList = [SELECT Account__r.isPersonAccount, 
                                            Account__c, Account__r.Codice_fiscale_ListView__c,
                                            Account__r.FirstName, 
                                            Account__r.LastName,
                                            Account__r.Name, 
                                            Agent_Code__c,Caller__c, CaseRecordType__c, 
                                            Category__c,Distribution_Network__c, LOB__c,  
                                            SubCategory__c, FromPhoneNumber, CallStartDateTime 
                                    FROM VoiceCall 
                                    WHERE Id =: VCId];
            
            if(!VCList.isEmpty()){
                VoiceCall vc = VCList.get(0);
                iW.AgentCode = vc.Agent_Code__c;

                if(vc.Account__c != null){
                    iW.FiscalIdListView = vc.Account__r.Codice_fiscale_ListView__c;
                    iW.needSearch = false;
                    iW.AccountIdForSCV = vc.Account__c;
                    iW.Name = vc.Account__r.Name;
                    if(vc.Account__r.isPersonAccount){
                        iW.FirstName = vc.Account__r.FirstName;
                        iW.LastName = vc.Account__r.LastName;
                        
                    }
                    else{
                        iW.LastName = vc.Account__r.Name;
                    }
                    LghtCallProcessingController.LghtSearchResponse searchGestoriResult = searchClienteForInit(vc, iW);
                    if(searchGestoriResult.listResult!= null && !searchGestoriResult.listResult.isEmpty()){
                        toRet.CasesList = searchGestoriResult.listResult.get(0).cases;
                    }
                    
                }
                Map<String, String> cToCreate = new Map<String, String>{
                    'Complainant__c' => vc.Caller__c,
                    'Origin' => 'Phone',
                    'Status' => 'Assigned',
                    'OwnerId' => UserInfo.getUserId(),
                    'AccountId' => vc.Account__c,
                    'LOB__c' => vc.Lob__c,
                    'Category__c' => vc.Category__c,
                    'RecordTypeId' => Schema.SObjectType.Case.getRecordTypeInfosByName().get(vc.CaseRecordType__c).getRecordTypeId(),
                    'Distribution_Network__c' => vc.Distribution_Network__c,
                    'TECH_Voice_Call__c' => vc.Id,
                    'TECH_Agent_Code__c' => iW.AgentCode
                };
                toRet.cToCreate = cToCreate;
                
            }
        }catch(Exception e){
            toRet.isSuccess = false;
        }
        return toRet;
    }

    @AuraEnabled
    public static completeWrapper InitGestori(String VCId){
        
        completeWrapper toRet = new completeWrapper();
        InitWrapper iW = new InitWrapper();
        toRet.InitWrapper = iW;
        iW.needSearch = true;
        try{
            List<VoiceCall> VCList = [Select Account__c, Account__r.FirstName, Account__r.LastName, Agent_Code__c,Caller__c, CaseRecordType__c, Category__c,Distribution_Network__c, LOB__c,  SubCategory__c, FromPhoneNumber, CallStartDateTime from VoiceCall where Id =: VCId];
            
            if(!VCList.isEmpty()){
                VoiceCall vc = VCList.get(0);
                iW.AgentCode = vc.Agent_Code__c;

                if(vc.Account__c != null){
                    iW.needSearch = false;
                    iW.FirstName = vc.Account__r.FirstName;
                    iW.LastName = vc.Account__r.LastName;
                    LghtCallProcessingController.LghtCallProcessingResponse searchGestoriResult = searchGestoreForInit(vc, iW);
                    if(searchGestoriResult.listResult!= null && !searchGestoriResult.listResult.isEmpty()){
                        toRet.CasesList = searchGestoriResult.listResult.get(0).cases;
                    }
                    
                }
                Map<String, String> cToCreate = new Map<String, String>{
                    'Complainant__c' => vc.Caller__c,
                    'Origin' => 'Phone',
                    'Status' => 'Assigned',
                    'OwnerId' => UserInfo.getUserId(),
                    'AgentName__c' => vc.Account__c,
                    'LOB__c' => vc.Lob__c,
                    'Category__c' => vc.Category__c,
                    'RecordTypeId' => Schema.SObjectType.Case.getRecordTypeInfosByName().get(vc.CaseRecordType__c).getRecordTypeId(),
                    'Distribution_Network__c' => vc.Distribution_Network__c,
                    'TECH_Voice_Call__c' => vc.Id,
                    'TECH_Agent_Code__c' => iW.AgentCode
                };
                toRet.cToCreate = cToCreate;
                
            }
        }catch(Exception e){
            toRet.isSuccess = false;
        }
        return toRet;
    }

    @AuraEnabled
    public static completeWrapper Init(String VCId){
        

        
        completeWrapper toRet = new completeWrapper();
        InitWrapper iW = new InitWrapper();
        toRet.InitWrapper = iW;
        iW.needSearch = true;
        try{
            List<VoiceCall> VCList = [Select Agent__c, Agent__r.FirstName, Agent__r.LastName, Agent__r.Agency_Code__c,Agent_Code__c,Caller__c, CaseRecordType__c, Category__c,Distribution_Network__c, LOB__c,  SubCategory__c, FromPhoneNumber, CallStartDateTime from VoiceCall where Id =: VCId];
            
            if(!VCList.isEmpty()){
                VoiceCall vc = VCList.get(0);
                iW.AgentCode = vc.Agent_Code__c;

                if(vc.Agent__c != null){
                    iW.needSearch = false;
                    iW.FirstName = vc.Agent__r.FirstName;
                    iW.LastName = vc.Agent__r.LastName;
                    iW.AgencyCode = vc.Agent__r.Agency_Code__c;
                    LghtCallProcessingController.LghtSearchAgentResponse searchAgResult = searchAgentForInit(vc, iW);
                    if(searchAgResult.listResult!= null && !searchAgResult.listResult.isEmpty()){
                        toRet.CasesList = searchAgResult.listResult.get(0).cases;
                    }
                    
                }
                Map<String, String> cToCreate = new Map<String, String>{
                    'Complainant__c' => vc.Caller__c,
                    'Origin' => 'Phone',
                    'Status' => 'Assigned',
                    'OwnerId' => UserInfo.getUserId(),
                    'LOB__c' => vc.Lob__c,
                    'Category__c' => vc.Category__c,
                    'User__c' => vc.Agent__c,
                    'RecordTypeId' => Schema.SObjectType.Case.getRecordTypeInfosByName().get(vc.CaseRecordType__c).getRecordTypeId(),
                    'Distribution_Network__c' => vc.Distribution_Network__c,
                    'TECH_Voice_Call__c' => vc.Id,
                    'TECH_Agent_Code__c' => iW.AgentCode
                };
                toRet.cToCreate = cToCreate;
                
            }
        }catch(Exception e){
            toRet.isSuccess = false;
        }
        return toRet;
    }

    private static LghtCallProcessingController.LghtCallProcessingResponse searchGestoreForInit(VoiceCall vc, initWrapper request){
        Map<String, String> params = createParamsFromVC(vc);
        Map<String, String> searchContext = prepareSearchContext(request, CallerType.GESTORI);
        params.putall(searchContext);
        return LghtCallProcessingController.searchGestori(params);
    }

    private static LghtCallProcessingController.LghtSearchResponse searchClienteForInit(VoiceCall vc, initWrapper request){
        Map<String, String> params = createParamsFromVC(vc);
        Map<String, String> searchContext = prepareSearchContext(request, CallerType.CLIENTI);
        return LghtCallProcessingController.search(params, searchContext);
    }

    @AuraEnabled
    public static LghtCallProcessingController.LghtSearchResponse searchCliente(String VCId, initWrapper request){
        List<VoiceCall> VCList = [SELECT Agent_Code__c,Caller__c, CaseRecordType__c, Category__c,Distribution_Network__c, LOB__c,  SubCategory__c, FromPhoneNumber, CallStartDateTime  FROM VoiceCall WHERE Id =: VCId];
        Map<String, String> params = createParamsFromVC(VCList.get(0));
        Map<String, String> searchContext = prepareSearchContext(request, CallerType.CLIENTI);
        return LghtCallProcessingController.search(params, searchContext);
    }

    @AuraEnabled
    public static LghtCallProcessingController.LghtCallProcessingResponse searchGestore(String VCId, initWrapper request){
        List<VoiceCall> VCList = [SELECT Agent_Code__c,Caller__c, CaseRecordType__c, Category__c,Distribution_Network__c, LOB__c,  SubCategory__c, FromPhoneNumber, CallStartDateTime  FROM VoiceCall WHERE Id =: VCId];
        Map<String, String> params = createParamsFromVC(VCList.get(0));
        Map<String, String> searchContext = prepareSearchContext(request, CallerType.GESTORI);
        params.putall(searchContext);
        return LghtCallProcessingController.searchGestori(params);
    }

    private static LghtCallProcessingController.LghtSearchAgentResponse searchAgentForInit(VoiceCall vc, initWrapper request){
        Map<String, String> params = createParamsFromVC(vc);
        Map<String, String> searchContext = prepareSearchContext(request, CallerType.AGENTI);
        return LghtCallProcessingController.searchAgent(params, searchContext);
    }

    @AuraEnabled
    public static LghtCallProcessingController.LghtSearchAgentResponse searchAgent(String VCId, initWrapper request){
        List<VoiceCall> VCList = [SELECT Agent_Code__c,Caller__c, CaseRecordType__c, Category__c,Distribution_Network__c, LOB__c,  SubCategory__c, FromPhoneNumber, CallStartDateTime  FROM VoiceCall WHERE Id =: VCId];
        Map<String, String> params = createParamsFromVC(VCList.get(0));
        Map<String, String> searchContext = prepareSearchContext(request, CallerType.AGENTI);
        return LghtCallProcessingController.searchAgent(params, searchContext);
    }

    private static Map<String, String> prepareSearchContext(initWrapper request, CallerType type){
        Map<String, String> searchContext = new Map<String, String>();
        if(type == CallerType.AGENTI){
        searchContext.put('searchAgencyName', request.FirstName);
        searchContext.put('searchAgencyLastname', request.LastName);
        searchContext.put('searchAgencyCode', request.AgencyCode);
        searchContext.put('searchAgentCommunityId', request.AgentCode);
        }
        else if(type == CallerType.GESTORI){
            searchContext.put('firstNameSearch', request.FirstName);
            searchContext.put('lastNameSearch', request.LastName);
            searchContext.put('matricolaSearch', request.AgentCode);
        }
        else if(type == CallerType.CLIENTI){
            searchContext.put('AccountIdForSCV', request.AccountIdForSCV);
            searchContext.put('searchFirstName', request.FirstName);
            searchContext.put('searchLastName', request.LastName);
            searchContext.put('searchFiscalId', request.FiscalId);
            searchContext.put('searchPartitaIVA', request.PIva);
            searchContext.put('policyNumber', request.InsurancePolicy);
			
        }
        return searchContext;
    }

    private static Map<String, String> createParamsFromVC(VoiceCall vc){
        Map<String, String> toRet = new Map<String, String>();
        
        if(vc != null){
            String rtDevelopername;
            if(String.isNotBlank(vc.CaseRecordType__c)){
                List<recordType> rtList = [select developername from recordtype where SobjectType= 'Case' AND name =: vc.CaseRecordType__c ]; // NOPMD  Fix CRUD violation
                if(!rtList.isEmpty())
                    rtDevelopername = rtList.get(0).developername;
            }
            
            toRet.put('Caller', vc.Caller__c);
            toRet.put('Phone', vc.FromPhoneNumber);
            toRet.put('Category', vc.Category__c);
            toRet.put('Subcategory', vc.SubCategory__c);
            toRet.put('CallDateTime', String.valueOf(vc.CallStartDateTime));
            toRet.put('Distribution', vc.Distribution_Network__c);
            toRet.put('RecordType', rtDevelopername);
            toRet.put('CaseId', rtDevelopername);
            toRet.put('Agentcode', vc.Agent_Code__c);
            toRet.put('LOB', vc.Lob__c);
            toRet.put('isFromSCV', 'true');
        }
        return toRet;
    }

    @AuraEnabled
    public static boolean associateCase(String VCId, String CaseId, String Type){
        List<VoiceCall> VCList = [SELECT Id, RelatedRecordId FROM VoiceCall where Id =: VCId];
        List<Case> cList = [SELECT Id, User__c, User__r.FederationIdentifier, AccountId, AgentName__c FROM Case WHERE Id =:CaseId];
        if(!VCList.isEmpty()){
            VoiceCall vc = VCList.get(0);
            Case caseToLink = cList.isEmpty() ? null : cList.get(0);
            vc.RelatedRecordId = CaseId;
            if( caseToLink != null ){
                if(type == 'Agenti')
                vc.Agent__c = caseToLink.User__c;
                else if (type == 'Clienti')
                    vc.Account__c = caseToLink.AccountId;
                else if (type == 'Gestori')
                    vc.Account__c = caseToLink.AgentName__c;
                prepareVCAgentCode(vc, caseToLink.User__r.FederationIdentifier);
            }
            try{
                update vc;
                return true;
            }catch(DMLException ex){
                system.debug(ex);
                
            }
        }
        return false;
    }


    private static void prepareVCAgentCode(VoiceCall vc, String fedId){
        String newAgentCode = '';
        
        if(String.isNotBlank(fedId)){
            fedId = fedId.replace('AG', '').replace('A', '');
        }
        vc.Agent_Code__c = fedId;
    }

    

}