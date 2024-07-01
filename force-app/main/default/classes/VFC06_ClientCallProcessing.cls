//MOSCATELLI_M 13062016:EVO 62 -- START
//public with sharing class VFC06_ClientCallProcessing {
public without sharing class VFC06_ClientCallProcessing {
    public class LghtClientCallProcessingException extends Exception {}
    
    //MOSCATELLI_M 13062016:EVO 62 -- END
    public boolean showButtonCreateCase {set;get;}
    public boolean activeViewClientNewCase {set;get;}
    public boolean activeViewClientExistingCase {set;get;}
    public boolean activeViewAgentExistingCase {set;get;}
    public boolean successClientUpdate {set;get;}
    public boolean successClientCreation {set;get;}
    public boolean isPerson {set;get;}
    public id rtAccountIndividual = AP_Constants.getDeveloperIdMap( AP_Constants.sobjectAcc ).get( AP_Constants.rtAccIndividualClient );
    public id rtAccountIntermediary = AP_Constants.getDeveloperIdMap( AP_Constants.sobjectAcc ).get( 'Intermediary');
    public id rtAccountAgency = AP_Constants.getDeveloperIdMap( AP_Constants.sobjectAcc ).get( AP_Constants.rtAccCorporateClient);//MOSCATELLI_M 22/07/2015: Implementations for CR10
    public string paramPhone{get;set;}
    //MOSCATELLI_M 09112015: EVO-23-----START
    public string ONEService{get;set;}
    public string FiscalCode{get;set;}
    public string PartitaIVA{get;set;}
    public string CustomerName{get;set;}
    public string CustomerSurname{get;set;}
    public string CustomerEmail{get;set;}
    public string Distribution{set;get;}
    public string CaseType{set;get;}
    public boolean isONE{set;get;}
    public string AgencyName{get;set;}
    //MOSCATELLI_M 09112015: EVO-23-----END
    public string paramCategory{get;set;}
    public string selectedPolicyId{get;set;}
    public string selectedPolicyName{get;set;}
    public string searchStatus{get;set;}
    //MOSCATELLI_M 22072015: CR10-----START
    public string searchPartitaIVA{get;set;}
    public string searchName{get;set;}
    public String searchClaim {get;set;} // FOZDEN 26/06/2019: AXA Assistance Enhancement Fase II
    public boolean isAgency{set;get;}
    //MOSCATELLI_M 22072015: CR10-----END
    public string searchCaseStatus{get;set;}
    public string paramSubCategory{get;set;}
    public string paramAgentCode{get;set;}
    public string policyNumber{set;get;}
    public string searchFirstName{set;get;}
    public string searchLastName{set;get;}
    public string searchFiscalId{set;get;}
    //public Date searchDateOfBirth{set;get;}
    public String searchDateOfBirth {set;get;}//MOSCATELLI_M 27/11/2018: Caring Angel Enhancement
    public string clientPolicyNumber{set;get;}
    public string selectedAgentId{set;get;}
    public string selectedAgentName{set;get;}
    public string selectedAgentPhone{set;get;}
    public string selectedClientId{set;get;}
    public string selectedPolicyClientId{set;get;}
    public string errorMgs{set;get;}
    public string newCaseUrl{set;get;}
    public Account client {set;get;}
    public Account customer {set;get;}
    public Account searchClient {set;get;}
    public Contact searchContact {set;get;}
    public Account CustAgency {set;get;}//MOSCATELLI_M 22072015: CR10
    public Account Cliente {set;get;}//MOSCATELLI_M 22072015: CR10
    public list<WrapperClientCases> policyClients{set;get;}
    public list<Case> listAgentCases{set;get;}
    public list<Case> listCases{set;get;}
    public list<Case> listPolicyClientCases{set;get;}
    //MOSCATELLI_M 07072016:EVO 62 -- START
    //public list<Account> listAgents =  new list<Account>();
    public list<Account> listAgents {set;get;}
    //MOSCATELLI_M 07072016:EVO 62 -- END
    public map<id,Account> mapClients {set;get;}
    public map<id,list<Case>> mapClientToCases = new map<id,list<Case>>();
    public map<id,list<Case>> mapPolicyClientToCases = new map<id,list<Case>>();
    Map<String, String> UrlParameterMap;
    //Added by Yra: 02/03/15
    public boolean recTypeAuto {set;get;}
    public String recId {set;get;}
    public String recTypeName {set;get;}
    //MOSCATELLI_M 02022016: EVO-18-----START
    public boolean isAAI {set;get;}
    public boolean AIISelected {set;get;}
    //MOSCATELLI_M 02022016: EVO-18-----END
    //MOSCATELLI_M 13062016:EVO 62 -- START
    public String ProvidedCase {get;set;}
    public Id ExistingCaseId {set;get;}
    public Case CaseToUpdate;
    public Boolean Updatecase = false;
    public Boolean LoggedUserIsCaseOwner = true;
    public String LogACallRecType;
    public Id LoggedUser = system.UserInfo.getuserId();
    public String CaseOwner;
    public String CaseContact;
    public String CaseAccount;
    public String CaseAgent;
    public Boolean CallerAgentFound = false;
    public Id FoundAccount;
    public Boolean CaseAccountIsPerson = false;
    public Boolean CallerIsCustomer =true;
    public Boolean isQuadra{set;get;}
    public String  CallIdentifier{get;set;}
    public String  CasePhoneCallId;
    public Boolean UpdatePhoneCallId = false;
    public string selectedCaseId{get;set;}
    public String URLBASE2 {get;set;}
    public Boolean FoundCase = false;
    public map<id,Account> mapAgents {set;get;}
    public map<id,list<Case>> mapAgentToCases = new map<id,list<Case>>();
    public integer AgentCasesNum{set;get;}
    public map<string,Id> mapTaskRT = AP_Constants.getDeveloperIdMap('Task');
    public Id CaseContactId;
    public map<id,Account> mapPolicyClients = new map <id,Account>();
    public Boolean ExistingPhoneCallId = false;
    //MOSCATELLI_M 13062016:EVO 62 -- END

    //MOSCATELLI_M 15/07/2016: EVO 65 -- START
    public Boolean CreateCaseLight {set;get;}
    public String  CreateCaseLightAccounts {set;get;}
    //MOSCATELLI_M 15/07/2016: EVO 65 -- END

    //MOSCATELLI_M 02/11/2016: EVO 69 -- START
    public String ProvidedFoundCaseID{set;get;}
    public String ProvidedFoundCustomerID{set;get;}
    public String ProvidedFoundPolicyID{set;get;}
    public String ProvidedFoundAgentID {set;get;}
    //MOSCATELLI_M 02/11/2016: EVO 69 -- END

    public String AccountIdForSCV{set;get;}
    //MOSCATELLI_M 29/11/2017: Data enrichment SmartCenter Fase 1 -- START
    public boolean enabCustChng{set;get;}
    public boolean displayPopup {get; set;}
    public list<String>MissingContactStr;
    public list<String>MissingPhoneLst{set;get;}
    public list<String>MissingEmailLst{set;get;}
    public list<String>MissingAddressLst{set;get;}
    //MOSCATELLI_M 29/11/2017: Data enrichment SmartCenter Fase 1 -- END

    //MOSCATELLI_M 02/07/2018: Easy Azienda -- START
    public string searchAgencyCode{set;get;}
    public string searchAgencyName{set;get;}
    public string searchAgencyLastname{set;get;}
    public List<User> AgentList{set;get;}
    public Boolean activeViewAAIAgent{set;get;}
    public String selectedAAIAgentId{set;get;}
    public List<Case> listAAIAgentCases{set;get;}
    public string selectedAAIAgentName{set;get;}
    public map<String,Account> AgentToAgencyMap{set;get;}
    public string searchAgentCommunityId{set;get;}
    public Map<String,String> MapAgentIdToName;
    //MOSCATELLI_M 02/07/2018: Easy Azienda -- END

    //MOSCATELLI_M 13/02/2018: Aggiornamento anagrafica gestori -- START
    public Boolean InactiveBankAgent{set;get;}
    public Boolean AgentSearchedNotFound{Set;Get;}
    //MOSCATELLI_M 13/02/2018: Aggiornamento anagrafica gestori -- END

    public String Lob{set;get;}//MOSCATELLI_M 02/08/2018: Nuovo Modello di assistenza

    public Boolean isAMF {set;get;} //CAPOBIANCO_A 29/08/2017 : EVO 87

    //OAVERSANO 05/10/2018 : Caring Angel -- START
    public Boolean isCaringAngel            { get; set; }
    public String selectedClientFiscalCode  { get; set; }
    public String searchTarga               { get; set; }
    public String CaringAngelCaseId         { get; set; }
    //OAVERSANO 05/10/2018 : Caring Angel -- START

    //OAVERSANO 16/05/2019 : AXA Assistance Enhancement Fase I -- START
    public String currentCaseNumber      { get; set; }
    //OAVERSANO 16/05/2019 : AXA Assistance Enhancement Fase I -- END

    //MOSCATELLI_M 01/03/2018: Accesso a registrazioni audio -- START
    public String CallDateTime{set;get;}
    public String PhoneCallIDB{set;get;}
    //MOSCATELLI_M 01/03/2018: Accesso a registrazioni audio -- END

    //OAVERSANO 09/01/2019 : Agenzia diretta -- START
    public String Complainant        { get; set; }
    //OAVERSANO 09/01/2019 : Agenzia diretta -- END
    private Boolean isFromSCV = false;
    //MOSCATELLI_M 13/03/2019: Axa Assistance -- START
    public Boolean isSinistri {set;get;}
    public String CallerType {set;get;}
    //MOSCATELLI_M 13/03/2019: Axa Assistance -- END

    //START - LIGHTING MIGRATION
    public String UrlParameterJSON {set; get;}
    public Boolean isCaringSalute            { get; set; }
    public Boolean isLght            { get; set; }
    public String  recordTypeDevName            { get; set; }
    
    public VFC06_ClientCallProcessing(){
        this(ApexPages.currentPage().getParameters());
        UrlParameterJSON = JSON.serialize(UrlParameterMap);
    }
    //END - LIGHTING MIGRATION

    public VFC06_ClientCallProcessing(Map<String, String> params)
    {
        
        isONE = false;//MOSCATELLI_M 09112015: EVO-23
        CaseType = null;//MOSCATELLI_M 16112015: EVO-32
        isAAI = false;//MOSCATELLI_M 02022016: EVO-18

        isCaringAngel = false;//OAVERSANO 05/10/2018 : Caring Angel
        isSinistri = false;//MOSCATELLI_M 13/03/2019: Axa Assistance
		isCaringSalute = false; //#1093 - Case 03629185 test Storm. - SFDC AXA Assistance

        //MOSCATELLI_M 13062016:EVO 62--START
        //MOSCATELLI_M 29/11/2017: Data enrichment SmartCenter Fase 1 -- START
        enabCustChng = false;
        displayPopup=false;
        MissingContactStr = new list<String>();
        MissingPhoneLst = new list<String>();
        MissingEmailLst = new list<String>();
        MissingAddressLst = new list<String>();
        //MOSCATELLI_M 29/11/2017: Data enrichment SmartCenter Fase 1 -- END

        //MOSCATELLI_M 13/02/2018: Aggiornamento anagrafica gestori -- START
        InactiveBankAgent=false;
        AgentSearchedNotFound = false;
        //MOSCATELLI_M 13/02/2018: Aggiornamento anagrafica gestori -- END

        isQuadra=false;
        isAMF=false; //CAPOBIANCO_A 29/08/2017 : EVO 87
        String URLBASE = System.URL.getCurrentRequestUrl().toExternalForm();
        URLBASE2 = URLBASE.SPLIT('/apex/',-1).get(0);
        AgentCasesNum = 0;
        //MOSCATELLI_M 13062016:EVO 62--END
        activeViewClientNewCase = false;
        activeViewClientExistingCase = false;
        activeViewAgentExistingCase  = false;
        recTypeAuto =false;
        recId =null;
        successClientUpdate = false;
        successClientCreation = false; 
        //MOSCATELLI_M 22072015: CR10-----START
        searchPartitaIVA ='';
        isAgency = false;
        //MOSCATELLI_M 22072015: CR10-----END
        CreateCaseLight = true;//MOSCATELLI_M 15/07/2016: EVO 65
        searchStatus = System.label.MakeAsearch+ '.';
        searchCaseStatus = System.label.ChooseACase;
        selectedPolicyId = '';
        selectedPolicyName ='';
        searchFiscalId='';
        listCases = new list<Case>();
        listAgentCases = new list<Case>();
        listPolicyClientCases = new list<Case>();
        searchClient = new Account();
        searchContact = new contact();
        policyClients = new list<WrapperClientCases>();
        
        //START - LIGHTING MIGRATION
        //UrlParameterMap = ApexPages.currentPage().getParameters();
        UrlParameterMap = params;
        //END - LIGHTING MIGRATION

        CallerType = (UrlParameterMap.get('caller') == 'cliente')?'Customer':((UrlParameterMap.get('caller') == 'gestore')?'Bank Agent':((UrlParameterMap.get('caller') == 'agente')?'Agente':'Dipendente'));
        CallerIsCustomer= (UrlParameterMap.get('caller') == 'cliente')?true:false;//MOSCATELLI_M 13062016:EVO 62
        //MOSCATELLI_M 01/03/2018: Accesso a registrazioni audio -- START
        CallDateTime = (String.isNotBlank(UrlParameterMap.get('CallDateTime')))?UrlParameterMap.get('CallDateTime'):'';
        PhoneCallIDB = (String.isNotBlank(UrlParameterMap.get('PhoneCallIDB')))?UrlParameterMap.get('PhoneCallIDB'):'';
        //MOSCATELLI_M 01/03/2018: Accesso a registrazioni audio -- END


        //MOSCATELLI_M 02/07/2018: Easy Azienda -- START
        searchAgencyCode ='';
        searchAgencyName ='';
        searchAgencyLastname ='';
        AgentList = new List<User>();
        activeViewAAIAgent = false;
        selectedAAIAgentId='';
        listAAIAgentCases = new List<Case>();
        AgentToAgencyMap = new map<String,Account>();
        searchAgentCommunityId='';
        MapAgentIdToName = new Map<String,String>();
        //MOSCATELLI_M 02/07/2018: Easy Azienda -- END
        if(params.containsKey('isFromSCV')){
            this.isFromSCV = Boolean.valueOf(params.get('isFromSCV'));
        }
        //MOSCATELLI_M 22/01/2018: Bugfix--START
        if(String.isBlank(UrlParameterMap.get('category')) && (UrlParameterMap.get('subcategory')=='0'))
            UrlParameterMap.put('subcategory','');

        if(String.isNotBlank(UrlParameterMap.get('phone')))
        {
            Map<String,AAI_Code_Variables__c> VariablesMap = AAI_Code_Variables__c.getAll();

            system.debug('#phoneSTART'+UrlParameterMap.get('phone'));

            for(String Vmap : VariablesMap.keyset())
            {
                if(Vmap.contains('VFC06_ContactCenterNumbers') && String.isNotBlank(VariablesMap.get(Vmap).Value__c))
                {
                    for(String s :VariablesMap.get(Vmap).Value__c.split(';'))
                    {
                        if(String.isNotBlank(s))
                        {
                            if((UrlParameterMap.get('phone')).contains(s))
                                UrlParameterMap.put('phone','');
                        }
                    }
                }
            }
        }

        system.debug('#phoneend'+UrlParameterMap.get('phone'));
        //MOSCATELLI_M 22/01/2018: Bugfix--END

        if (   UrlParameterMap.containsKey('caller')
                &&  UrlParameterMap.get('caller')  == 'gestore'
                &&  UrlParameterMap.containsKey('phone')
                && UrlParameterMap.containsKey('category')
                && UrlParameterMap.containsKey('subcategory')
                && UrlParameterMap.containsKey('agentcode')){
            activeViewAgentExistingCase = true;

            Complainant = 'Bank+Agent'; //OAVERSANO 09/01/2019 : Agenzia diretta

            paramPhone = UrlParameterMap.get('phone');
            paramCategory = EncodingUtil.urlEncode(UrlParameterMap.get('category'), 'UTF-8');
            //paramCategory = UrlParameterMap.get('category');
            paramSubCategory = EncodingUtil.urlEncode(UrlParameterMap.get('subcategory'), 'UTF-8');
            paramAgentCode = UrlParameterMap.get('agentcode');
            string agentlastname = '',agentfirstname = '',agentbranch = '', agentemail='';
            if(UrlParameterMap.containsKey('Agentfirstn'))
                agentfirstname = UrlParameterMap.get('Agentfirstn');
            if(UrlParameterMap.containsKey('Agentlastn'))
                agentlastname = UrlParameterMap.get('Agentlastn');
            if(UrlParameterMap.containsKey('agentbranch'))
                agentbranch = UrlParameterMap.get('agentbranch');
            if(UrlParameterMap.containsKey('agentemail'))
                agentemail = UrlParameterMap.get('agentemail');
            //purify parameter

            //MOSCATELLI_M 13062016:EVO 62 -- START
            if(UrlParameterMap.containsKey('Casenumber'))
                ProvidedCase = UrlParameterMap.get('Casenumber');

            if(UrlParameterMap.containsKey('Distribution') && String.isNotBlank(UrlParameterMap.get('Distribution')) && UrlParameterMap.get('Distribution')!='0')
                Distribution = UrlParameterMap.get('Distribution');

            if(UrlParameterMap.containsKey('RecordType') && String.isNotBlank(UrlParameterMap.get('RecordType')) && UrlParameterMap.get('RecordType')!='0')
                CaseType = [Select Id From RecordType Where SobjectType = 'Case' and DeveloperName =: UrlParameterMap.get('RecordType')].Id;

            if(UrlParameterMap.containsKey('PhonecallID'))
                CallIdentifier = UrlParameterMap.get('PhonecallID');
            //MOSCATELLI_M 13062016:EVO 62 -- END

            //MOSCATELLI_M 02/11/2016: EVO 69 -- START
            if(UrlParameterMap.containsKey('CaseId'))
                ProvidedFoundCaseID = UrlParameterMap.get('CaseId');

            if(UrlParameterMap.containsKey('AgentId'))
                ProvidedFoundAgentID = UrlParameterMap.get('AgentId');

            if(UrlParameterMap.containsKey('CustomerId'))
                ProvidedFoundCustomerID = UrlParameterMap.get('CustomerId');

            if(UrlParameterMap.containsKey('PolicyId'))
                ProvidedFoundPolicyID = UrlParameterMap.get('PolicyId');
            //MOSCATELLI_M 02/11/2016: EVO 69 -- END

            if(UrlParameterMap.containsKey('Lob'))
                Lob = UrlParameterMap.get('Lob');

            loadAgentCases();

            //MOSCATELLI_M 13062016:EVO 62 -- START
            //MOSCATELLI_M 02/11/2016: EVO 69 -- START
            //if(ProvidedCase!=null && ProvidedCase!='')
            if(String.isNotBlank(ProvidedCase) || String.isNotBlank(ProvidedFoundCaseID))
                //MOSCATELLI_M 02/11/2016: EVO 69 -- END
                searchExistingCase();
            //MOSCATELLI_M 13062016:EVO 62 -- END

            client = new Account(RecordtypeId = rtAccountIntermediary, lastname =agentlastname,firstname =agentfirstname,PersonEmail= agentemail );
            client.Phone = paramPhone;
            //client.RecordtypeId = rtAccountIntermediary;
            client.Matricola__c = paramAgentCode;
            customer = new Account(RecordtypeId = rtAccountIndividual);
            //MOSCATELLI_M 22072015: CR10-----START
            CustAgency = new Account(RecordtypeId = rtAccountAgency);
            CustAgency.Phone =   paramPhone;
            //MOSCATELLI_M 22072015: CR10-----END
        }else if( UrlParameterMap.containsKey('caller')
                //OAVERSANO 10/01/2019 : Agenzia diretta -- START
                //&&  UrlParameterMap.get('caller')  == 'cliente'
                &&  ( UrlParameterMap.get('caller')  == 'cliente' || UrlParameterMap.get('caller')  == 'Dipendente' )
                //OAVERSANO 10/01/2019 : Agenzia diretta -- END
                &&  UrlParameterMap.containsKey('phone')
                && UrlParameterMap.containsKey('category')
                && UrlParameterMap.containsKey('subcategory')
                && String.IsNotBlank(UrlParameterMap.get('category'))
                && String.IsNotBlank(UrlParameterMap.get('subcategory'))
                /*&& UrlParameterMap.get('subcategory') != '0'*/
                && UrlParameterMap.get('category') != '0'  ){
            system.debug('cliente con categoria e sottocategoria');
            //MOSCATELLI_M 09112015: EVO-23-----START
            if (UrlParameterMap.containsKey('Custservice'))
            {
                ONEService = UrlParameterMap.get('Custservice');

                if(ONEService == 'MPS One')
                    isONE = true;
            }
            if(UrlParameterMap.containsKey('Custfirstn') && String.isNotBlank(UrlParameterMap.get('Custfirstn')) && UrlParameterMap.get('Custfirstn')!='0')
                CustomerName = UrlParameterMap.get('Custfirstn');
            if(UrlParameterMap.containsKey('Custlastn') && String.isNotBlank(UrlParameterMap.get('Custlastn')) && UrlParameterMap.get('Custlastn')!='0')
                CustomerSurname = UrlParameterMap.get('Custlastn');
            if(UrlParameterMap.containsKey('Custemail') && String.isNotBlank(UrlParameterMap.get('Custemail')) && UrlParameterMap.get('Custemail')!='0')
                CustomerEmail = UrlParameterMap.get('Custemail');
            if(UrlParameterMap.containsKey('Fiscalcode') && String.isNotBlank(UrlParameterMap.get('Fiscalcode')) && UrlParameterMap.get('Fiscalcode')!='0')
                FiscalCode = UrlParameterMap.get('Fiscalcode');
            if(UrlParameterMap.containsKey('Partitaiva') && String.isNotBlank(UrlParameterMap.get('Partitaiva')) && UrlParameterMap.get('Partitaiva')!='0')
                PartitaIVA = UrlParameterMap.get('Partitaiva');
            //MOSCATELLI_M 16112015: EVO-32-----START

            //MOSCATELLI_M 02022016: EVO-18-----START
            /*
if(UrlParameterMap.containsKey('RecordType') && String.isNotBlank(UrlParameterMap.get('RecordType')) && UrlParameterMap.get('RecordType')!='0')
CaseType = [Select Id From RecordType Where SobjectType = 'Case' and DeveloperName =: UrlParameterMap.get('RecordType')].Id;
*/
            if(UrlParameterMap.containsKey('RecordType') && String.isNotBlank(UrlParameterMap.get('RecordType')) && UrlParameterMap.get('RecordType')!='0')
            {
                CaseType = [Select Id From RecordType Where SobjectType = 'Case' and DeveloperName =: UrlParameterMap.get('RecordType')].Id;

                if(UrlParameterMap.get('RecordType')==AP_Constants.rtCaseAAI)
                    isAAI=true;
                //MOSCATELLI_M 13062016:EVO 62 -- START
                else if(UrlParameterMap.get('RecordType')==AP_Constants.rtCaseQuadra)
                    isQuadra=true;
                //MOSCATELLI_M 13062016:EVO 62 -- END
                //CAPOBIANCO_A 29/08/2017 : EVO 87 -- START
                else if(UrlParameterMap.get('RecordType')==AP_Constants.rtCaseAMF)
                    isAMF=true;
                //CAPOBIANCO_A 29/08/2017 : EVO 87 -- END

                //OAVERSANO 05/10/2018 : Caring Angel -- START
                else if(UrlParameterMap.get('RecordType')==AP_Constants.rtCaseCaringAngel)
                    isCaringAngel=true;
                //OAVERSANO 05/10/2018 : Caring Angel -- END
                else if(UrlParameterMap.get('RecordType')=='AXA_Caring_Salute')
                    isCaringSalute=true;
                //MOSCATELLI_M 13/03/2019: Axa Assistance -- START
                else if(UrlParameterMap.get('RecordType')==AP_Constants.rtCaseSinistro || UrlParameterMap.get('RecordType')=='Sinistri_AAI')
                    isSinistri=true;
                //MOSCATELLI_M 13/03/2019: Axa Assistance -- END
            }
            //MOSCATELLI_M 02022016: EVO-18----END

            if(UrlParameterMap.containsKey('Distribution') && String.isNotBlank(UrlParameterMap.get('Distribution')) && UrlParameterMap.get('Distribution')!='0')
                Distribution = UrlParameterMap.get('Distribution');
            //MOSCATELLI_M 16112015: EVO-32-----END
            if(UrlParameterMap.containsKey('Nomeazienda') && String.isNotBlank(UrlParameterMap.get('Nomeazienda')) && UrlParameterMap.get('Nomeazienda')!='0')
                AgencyName = UrlParameterMap.get('Nomeazienda');
            //MOSCATELLI_M 09112015: EVO-23-----END

            //MOSCATELLI_M 13062016:EVO 62 -- START
            if(UrlParameterMap.containsKey('Casenumber'))
                ProvidedCase = UrlParameterMap.get('Casenumber');

            if(UrlParameterMap.containsKey('PhonecallID'))
                CallIdentifier = UrlParameterMap.get('PhonecallID');
            //MOSCATELLI_M 13062016:EVO 62 -- END

            paramPhone = UrlParameterMap.get('phone');

            system.debug('tel: '+paramPhone);

            paramCategory = EncodingUtil.urlEncode(UrlParameterMap.get('category'), 'UTF-8');
            //paramCategory = UrlParameterMap.get('category');
            paramSubCategory = EncodingUtil.urlEncode(UrlParameterMap.get('subcategory'), 'UTF-8');

            activeViewClientNewCase = true;

            //OAVERSANO 09/01/2019 : Agenzia diretta -- START
            if(UrlParameterMap.get('caller')  == 'Dipendente')
                Complainant = 'Dipendente';
            else
                    Complainant = 'Customer';
            //OAVERSANO 09/01/2019 : Agenzia diretta -- END

            client = new Account(RecordtypeId = rtAccountIndividual);
            client.PersonHomePhone = paramPhone;

            //MOSCATELLI_M 09112015: EVO-23-----START
            client.Fiscal_ID__c    = FiscalCode;
            client.FirstName       = CustomerName;
            client.LastName        = CustomerSurname;
            client.PersonEmail     = CustomerEmail;
            client.Servizio__c     = ONEService;
            client.Additional_Phone__c = paramPhone;
            //MOSCATELLI_M 09112015: EVO-23-----END

            //MOSCATELLI_M 22072015: CR10-----START
            CustAgency         = new Account(RecordtypeId = rtAccountAgency);
            CustAgency.Phone   =   paramPhone;
            CustAgency.Additional_Phone__c = paramPhone;
            //MOSCATELLI_M 22072015: CR10------END

            //MOSCATELLI_M 09112015: EVO-23-----START
            CustAgency.Account_email__c = CustomerEmail;
            CustAgency.Partita_IVA__c      = PartitaIVA;
            CustAgency.Servizio__c         = ONEService;
            CustAgency.Name                = AgencyName;
            //MOSCATELLI_M 09112015: EVO-23-----END

            //MOSCATELLI_M 02/11/2016: EVO 69 -- START
            if(UrlParameterMap.containsKey('CaseId'))
                ProvidedFoundCaseID = UrlParameterMap.get('CaseId');

            if(UrlParameterMap.containsKey('AgentId'))
                ProvidedFoundAgentID = UrlParameterMap.get('AgentId');

            if(UrlParameterMap.containsKey('CustomerId'))
                ProvidedFoundCustomerID = UrlParameterMap.get('CustomerId');

            if(UrlParameterMap.containsKey('PolicyId'))
                ProvidedFoundPolicyID = UrlParameterMap.get('PolicyId');
            //MOSCATELLI_M 02/11/2016: EVO 69 -- END

            loadClients();

            //MOSCATELLI_M 13062016:EVO 62 -- START
            //MOSCATELLI_M 02/11/2016: EVO 69 -- START
            //if(ProvidedCase!=null && ProvidedCase!='')
            if(String.isNotBlank(ProvidedCase) || String.isNotBlank(ProvidedFoundCaseID))
                //MOSCATELLI_M 02/11/2016: EVO 69 -- END
                searchExistingCase();

            if(UrlParameterMap.containsKey('PhonecallID'))
                CallIdentifier = UrlParameterMap.get('PhonecallID');
            //MOSCATELLI_M 13062016:EVO 62 -- END

            if(UrlParameterMap.containsKey('Lob'))
                Lob = UrlParameterMap.get('Lob');

        }else if(  UrlParameterMap.containsKey('caller')
                //OAVERSANO 10/01/2019 : Agenzia diretta -- START
                //&&  UrlParameterMap.get('caller')  == 'cliente'
                &&  ( UrlParameterMap.get('caller')  == 'cliente' || UrlParameterMap.get('caller')  == 'Dipendente' )
                //OAVERSANO 10/01/2019 : Agenzia diretta -- END
                &&  UrlParameterMap.containsKey('phone')
                && UrlParameterMap.containsKey('category')
                && UrlParameterMap.containsKey('subcategory')
                && ((
                String.IsBlank(UrlParameterMap.get('category'))
                        && String.IsBlank(UrlParameterMap.get('subcategory'))
        )||(
                UrlParameterMap.get('category') == '0' &&
                        UrlParameterMap.get('subcategory') == '0'
        )) ){
            system.debug('cliente senza categoria e sottocategoria');
            //MOSCATELLI_M 09112015: EVO-23-----START
            if (UrlParameterMap.containsKey('Custservice'))
            {
                ONEService = UrlParameterMap.get('Custservice');

                if(ONEService == 'MPS One')
                    isONE = true;
            }
            if(UrlParameterMap.containsKey('Custfirstn') && String.isNotBlank(UrlParameterMap.get('Custfirstn')) && UrlParameterMap.get('Custfirstn')!='0')
                CustomerName = UrlParameterMap.get('Custfirstn');
            if(UrlParameterMap.containsKey('Custlastn') && String.isNotBlank(UrlParameterMap.get('Custlastn')) && UrlParameterMap.get('Custlastn')!='0')
                CustomerSurname = UrlParameterMap.get('Custlastn');
            if(UrlParameterMap.containsKey('Custemail') && String.isNotBlank(UrlParameterMap.get('Custemail')) && UrlParameterMap.get('Custemail')!='0')
                CustomerEmail = UrlParameterMap.get('Custemail');
            if(UrlParameterMap.containsKey('Fiscalcode') && String.isNotBlank(UrlParameterMap.get('Fiscalcode')) && UrlParameterMap.get('Fiscalcode')!='0')
                FiscalCode = UrlParameterMap.get('Fiscalcode');
            if(UrlParameterMap.containsKey('Partitaiva') && String.isNotBlank(UrlParameterMap.get('Partitaiva')) && UrlParameterMap.get('Partitaiva')!='0')
                PartitaIVA = UrlParameterMap.get('Partitaiva');
            //MOSCATELLI_M 16112015: EVO-32-----START

            //MOSCATELLI_M 02022016: EVO-18-----START
            /*
if(UrlParameterMap.containsKey('RecordType') && String.isNotBlank(UrlParameterMap.get('RecordType')) && UrlParameterMap.get('RecordType')!='0')
CaseType = [Select Id From RecordType Where SobjectType = 'Case' and DeveloperName =: UrlParameterMap.get('RecordType')].Id;
*/
            if(UrlParameterMap.containsKey('RecordType') && String.isNotBlank(UrlParameterMap.get('RecordType')) && UrlParameterMap.get('RecordType')!='0')
            {
                CaseType = [Select Id From RecordType Where SobjectType = 'Case' and DeveloperName =: UrlParameterMap.get('RecordType')].Id;

                if(UrlParameterMap.get('RecordType')==AP_Constants.rtCaseAAI)
                    isAAI=true;
                //MOSCATELLI_M 13062016:EVO 62 -- START
                else if(UrlParameterMap.get('RecordType')==AP_Constants.rtCaseQuadra)
                    isQuadra=true;
                //MOSCATELLI_M 13062016:EVO 62 -- END
                //CAPOBIANCO_A 29/08/2017 : EVO 87 -- START
                else if(UrlParameterMap.get('RecordType')==AP_Constants.rtCaseAMF)
                    isAMF=true;
                //CAPOBIANCO_A 29/08/2017 : EVO 87 -- END

                //OAVERSANO 05/10/2018 : Caring Angel -- START
                else if(UrlParameterMap.get('RecordType')==AP_Constants.rtCaseCaringAngel)
                    isCaringAngel=true;
                //OAVERSANO 05/10/2018 : Caring Angel -- END
                else if(UrlParameterMap.get('RecordType')=='AXA_Caring_Salute')
                    isCaringSalute=true;
                //MOSCATELLI_M 13/03/2019: Axa Assistance -- START
                else if(UrlParameterMap.get('RecordType')==AP_Constants.rtCaseSinistro || UrlParameterMap.get('RecordType')=='Sinistri_AAI')
                    isSinistri=true;
                //MOSCATELLI_M 13/03/2019: Axa Assistance -- END
            }
            //MOSCATELLI_M 02022016: EVO-18-----END

            if(UrlParameterMap.containsKey('Distribution') && String.isNotBlank(UrlParameterMap.get('Distribution')) && UrlParameterMap.get('Distribution')!='0')
                Distribution = UrlParameterMap.get('Distribution');
            //MOSCATELLI_M 16112015: EVO-32-----END
            if(UrlParameterMap.containsKey('Nomeazienda') && String.isNotBlank(UrlParameterMap.get('Nomeazienda')) && UrlParameterMap.get('Nomeazienda')!='0')
                AgencyName = UrlParameterMap.get('Nomeazienda');

            system.debug('fiscal: '+FiscalCode+' iva: '+PartitaIVA);
            //MOSCATELLI_M 09112015: EVO-23-----END

            //MOSCATELLI_M 13062016:EVO 62 -- START
            if(UrlParameterMap.containsKey('Casenumber'))
                ProvidedCase = UrlParameterMap.get('Casenumber');

            if(UrlParameterMap.containsKey('PhonecallID'))
                CallIdentifier = UrlParameterMap.get('PhonecallID');
            //MOSCATELLI_M 13062016:EVO 62 -- END

            paramPhone = UrlParameterMap.get('phone');

            client = new Account(RecordtypeId = rtAccountIndividual);
            client.PersonHomePhone = paramPhone;

            //MOSCATELLI_M 09112015: EVO-23-----START
            client.Fiscal_ID__c   = FiscalCode;
            client.FirstName      = CustomerName;
            client.LastName       = CustomerSurname;
            client.PersonEmail    = CustomerEmail;
            client.Servizio__c    = ONEService;
            client.Additional_Phone__c = paramPhone;
            //MOSCATELLI_M 09112015: EVO-23-----END

            //MOSCATELLI_M 22072015: CR10-----START
            CustAgency = new Account(RecordtypeId = rtAccountAgency);
            CustAgency.Phone =   paramPhone;
            CustAgency.Additional_Phone__c = paramPhone;
            //MOSCATELLI_M 22072015: CR10-----END

            //MOSCATELLI_M 09112015: EVO-23----START
            CustAgency.Account_email__c = CustomerEmail;
            CustAgency.Partita_IVA__c = PartitaIVA;
            CustAgency.Servizio__c = ONEService;
            CustAgency.Name = AgencyName;
            //MOSCATELLI_M 09112015: EVO-23-----END
            activeViewClientExistingCase=true;

            //OAVERSANO 09/01/2019 : Agenzia diretta -- START
            if(UrlParameterMap.get('caller')  == 'Dipendente')
                Complainant = 'Dipendente';
            else
                    Complainant = 'Customer';
            //OAVERSANO 09/01/2019 : Agenzia diretta -- END

            //MOSCATELLI_M 02/11/2016: EVO 69 -- START
            if(UrlParameterMap.containsKey('CaseId'))
                ProvidedFoundCaseID = UrlParameterMap.get('CaseId');

            if(UrlParameterMap.containsKey('AgentId'))
                ProvidedFoundAgentID = UrlParameterMap.get('AgentId');

            if(UrlParameterMap.containsKey('CustomerId'))
                ProvidedFoundCustomerID = UrlParameterMap.get('CustomerId');

            if(UrlParameterMap.containsKey('PolicyId'))
                ProvidedFoundPolicyID = UrlParameterMap.get('PolicyId');
            //MOSCATELLI_M 02/11/2016: EVO 69 -- END

            if(UrlParameterMap.containsKey('Lob'))
                Lob = UrlParameterMap.get('Lob');

            loadClients();

            //MOSCATELLI_M 13062016:EVO 62 -- START
            //MOSCATELLI_M 02/11/2016: EVO 69 -- START
            //if(ProvidedCase!=null && ProvidedCase!='')
            if(String.isNotBlank(ProvidedCase) || String.isNotBlank(ProvidedFoundCaseID))
                //MOSCATELLI_M 02/11/2016: EVO 69 -- END
                searchExistingCase();
            //MOSCATELLI_M 13062016:EVO 62 -- END

            system.debug('isAAI: '+isAAI+' RecType: '+UrlParameterMap.get('RecordType'));
        }



        //MOSCATELLI_M 02/07/2018: Easy Azienda -- START
        else if( UrlParameterMap.containsKey('caller')
                &&  UrlParameterMap.get('caller')  == 'agente'
                &&  UrlParameterMap.containsKey('phone')
                && UrlParameterMap.containsKey('category')
                && UrlParameterMap.containsKey('subcategory'))
        {
            if(UrlParameterMap.containsKey('RecordType') && String.isNotBlank(UrlParameterMap.get('RecordType')) && UrlParameterMap.get('RecordType')!='0')
            {
                CaseType = [Select Id From RecordType Where SobjectType = 'Case' and DeveloperName =: UrlParameterMap.get('RecordType')].Id;
            }

            if(UrlParameterMap.containsKey('Distribution') && String.isNotBlank(UrlParameterMap.get('Distribution')) && UrlParameterMap.get('Distribution')!='0')
                Distribution = UrlParameterMap.get('Distribution');

            if(UrlParameterMap.containsKey('Casenumber'))
                ProvidedCase = UrlParameterMap.get('Casenumber');

            if(UrlParameterMap.containsKey('PhonecallID'))
                CallIdentifier = UrlParameterMap.get('PhonecallID');

            //MOSCATELLI_M 02/08/2018: Nuovo Modello di assistenza -- START
            if(UrlParameterMap.containsKey('agentcode'))
            {
                paramAgentCode = UrlParameterMap.get('agentcode');

                if(paramAgentCode.isNumeric())
                {
                    if(paramAgentCode.length()>4)
                        searchAgentCommunityId = 'AG'+paramAgentCode.substring(0,4)+'A'+paramAgentCode.substring(4);
                    else
                            searchAgentCommunityId = 'AG'+paramAgentCode;
                }

                system.debug('@@paramAgentCode: '+paramAgentCode);
            }


            if(UrlParameterMap.containsKey('category'))
                paramCategory = UrlParameterMap.get('category');
            if(UrlParameterMap.containsKey('subcategory'))
                paramSubCategory = UrlParameterMap.get('subcategory');
            //MOSCATELLI_M 02/08/2018: Nuovo Modello di assistenza -- END

            paramPhone = UrlParameterMap.get('phone');

            activeViewAAIAgent=true;

            Complainant = 'Agente'; //OAVERSANO 09/01/2019 : Agenzia diretta

            if(UrlParameterMap.containsKey('CaseId'))
                ProvidedFoundCaseID = UrlParameterMap.get('CaseId');

            if(UrlParameterMap.containsKey('AgentId'))
                ProvidedFoundAgentID = UrlParameterMap.get('AgentId');


            //MOSCATELLI_M 02/08/2018: Nuovo Modello di assistenza -- START
            if(UrlParameterMap.containsKey('Lob'))
                Lob = UrlParameterMap.get('Lob');

            if(String.isNotBlank(paramAgentCode))
                SearchAAIAgents();
            else if(String.isNotBlank(paramPhone))
                SearchAAIAgentsbyPhone();
            //MOSCATELLI_M 02/08/2018: Nuovo Modello di assistenza -- END

            if(String.isNotBlank(ProvidedCase) || String.isNotBlank(ProvidedFoundCaseID))
                searchExistingCase();
        }
        //MOSCATELLI_M 02/07/2018: Easy Azienda -- END

        //added by YRA: 2/03/15
        retriveRecordType();
        /* commented by HDU on 06 Feb 2015
if (   UrlParameterMap.containsKey('phone')
&& UrlParameterMap.containsKey('category')
&& UrlParameterMap.containsKey('subcategory')
&& UrlParameterMap.containsKey('agentcode') ){
activeViewAgentExistingCase = true;

paramPhone = UrlParameterMap.get('phone');
paramCategory = UrlParameterMap.get('category');
paramSubCategory = UrlParameterMap.get('subcategory');
paramAgentCode = UrlParameterMap.get('agentcode');

loadAgentCases();
client = new Account(RecordtypeId = rtAccountIntermediary);
client.PersonHomePhone = paramPhone;
//client.RecordtypeId = rtAccountIntermediary;
client.Matricola__c = paramAgentCode;
}else if(   UrlParameterMap.containsKey('phone')
&& UrlParameterMap.containsKey('category')
&& UrlParameterMap.containsKey('subcategory') ){

paramPhone = UrlParameterMap.get('phone');
paramCategory = UrlParameterMap.get('category');
paramSubCategory = UrlParameterMap.get('subcategory');

activeViewClientNewCase = true;

client = new Account(RecordtypeId = rtAccountIndividual);
client.PersonHomePhone = paramPhone;


loadClients();
}else if( UrlParameterMap.containsKey('phone') ){

paramPhone = UrlParameterMap.get('phone');

client = new Account(RecordtypeId = rtAccountIndividual);
client.PersonHomePhone = paramPhone;
activeViewClientExistingCase=true;

loadClients();
}       */
    }//end of construtor

    public void retriveRecordType(){
        system.debug('Category:'+UrlParameterMap.get('category'));

        recTypeAuto = false;
        /*
// commented by NAP 17/03/15
map<String,Id> case_developerIdMap = AP_Constants.getDeveloperIdMap(AP_Constants.sobjectCas);
map<Id,String> case_developerNameMap = AP_Constants.getIdDeveloperMap(AP_Constants.sobjectCas);

if(UrlParameterMap.containsKey('category') && String.IsNotBlank(UrlParameterMap.get('category')) && UrlParameterMap.get('category') != '0' ){
if(UrlParameterMap.get('category').tolowercase().Contains('auto')){
recId = case_developerIdMap.get(AP_Constants.rtCaseMotor);
recTypeName = case_developerNameMap.get(recId);
recTypeAuto = true;
}
else{
recId = case_developerIdMap.get(AP_Constants.rtCaseNonMotor);
recTypeAuto = true;
}
}else
{
recTypeAuto = false;
}
*/
        system.debug('xxxxxx:'+recId);
    }

    public void setAgentPhone(){
        system.debug('##activeViewAgentExistingCase : '+activeViewAgentExistingCase);
        if(activeViewAgentExistingCase){
            system.debug('##selectedAgentPhone : '+selectedAgentPhone);
            system.debug('##paramPhone : '+paramPhone);
            system.debug('##selectedAgentId : '+selectedAgentId);
            if(selectedAgentPhone == null && String.IsNotBlank(paramPhone) &&String.IsNotBlank(selectedAgentId)){
                update new account (id = selectedAgentId , Phone  = paramPhone);
            }
        }
    }
    public void loadClients()
    {
        //MOSCATELLI_M 09112015: EVO-23-----START
        if(isONE)
        {
            system.debug('##############START QUERY FOR ONE CUSTOMERS#######################################');

            if(String.isNotBlank(FiscalCode))
            {
                //MOSCATELLI_M 02022016: EVO-18-----START
                system.debug('###Cliente ONE##');

                mapClients = new map<id,Account>([Select id, name ,Fiscal_ID__c,PersonEmail,Partita_IVA__c,AAI_Partita_IVA__c,AAI_Codice_fiscale__c,RecordType.Name,Phone,IsPersonAccount,AAI_Agency__r.Name
                from    Account
                where   ( (Fiscal_ID__c = :FiscalCode OR Partita_IVA__c = :FiscalCode) and RecordType.Name = 'Individual')
                or      ( (AAI_Codice_fiscale__c = :FiscalCode OR AAI_Partita_IVA__c = :FiscalCode) and RecordType.Name = 'B2C Client')
                ]) ;
                //MOSCATELLI_M 02022016: EVO-18-----END
            }
            else
            {
                system.debug('###Azienda ONE##');
                //MOSCATELLI_M 02022016: EVO-18-----START
                system.debug('###Case MPS##');
                isAgency = true;

                mapClients = new map<id,Account>([Select id, name ,Fiscal_ID__c,PersonEmail,Partita_IVA__c,AAI_Partita_IVA__c,AAI_Codice_fiscale__c,RecordType.Name,Phone,IsPersonAccount,AAI_Agency__r.Name
                from    Account
                where   (Partita_IVA__c = :PartitaIVA AND RecordType.Name = 'Corporate')
                or      (AAI_Partita_IVA__c = :PartitaIVA AND RecordType.Name = 'B2B Client')
                ]) ;
                //MOSCATELLI_M 02022016: EVO-18-----END
            }
            if(mapClients.size()>0)
            {
                for(Case caseRecord :[  select  subject ,accountId,Description,Complainant__c,Origin,CaseNumber, CreatedDate
                from    Case
                where   accountId IN :mapClients.keyset()
                AND isclosed = false//status = 'Open'
                order by CreatedDate DESC ]){
                    if(!mapClientToCases.containsKey(caseRecord.accountId))
                        mapClientToCases.put(caseRecord.accountId ,new list<Case>{caseRecord});
                    else
                            mapClientToCases.get(caseRecord.accountId).add(caseRecord);
                }//end of loop
            }
            else
            {
                apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Info,System.label.NoClientFound);
                apexpages.addmessage(msg);
            }//end of check size
        }
        else
        {
            //MOSCATELLI_M 02/11/2016: EVO 69 -- START
            if(String.isNotBlank(ProvidedFoundCustomerID))
            {
                mapClients = new map<Id,Account>([Select id, name ,Fiscal_ID__c,PersonEmail,Partita_IVA__c,AAI_Partita_IVA__c,AAI_Codice_fiscale__c,RecordType.name,Phone,IsPersonAccount,Codice_Fiscale_AAF__c,TECH_Company__c,AAI_Agency_Reference_Code__c,CIF_Phone__c,CIF_PersonMobilePhone__c,CIF_Work_phone__c,CIF_MobilePhone__c,CIF_PersonEmail__c,CIF_Personalemail__c,CIF_Work_email__c,PersonMailingStreet,BillingStreet,AAI_Agency__r.Name //CAPOBIANCO_A 30/08/2017 EVO 87: AMF - Added the extraction of TECH_Company__c
                from    Account
                where id =:ProvidedFoundCustomerID
                and RecordType.Name in ('B2B Client','B2C Client','Individual','Corporate','AAF_B2C')]);

                if(mapClients.size()>0)
                {
                    //MOSCATELLI_M 29/11/2017: Data enrichment SmartCenter Fase 1 -- START
                    if(mapClients.get(ProvidedFoundCustomerID).RecordType.name == 'B2B Client' || mapClients.get(ProvidedFoundCustomerID).RecordType.name == 'B2C Client')
                    {
                        //if(String.isNotBlank(mapClients.get(ProvidedFoundCustomerID).AAI_Agency_Reference_Code__c))
                        //{
                        enabCustChng=true;

                        if(mapClients.get(ProvidedFoundCustomerID).RecordType.name == 'B2C Client')
                        {
                            if(String.isBlank(mapClients.get(ProvidedFoundCustomerID).CIF_Phone__c))
                                MissingContactStr.add('Telefono principale');

                            if(String.isBlank(mapClients.get(ProvidedFoundCustomerID).CIF_PersonMobilePhone__c))
                                MissingContactStr.add('Telefono cellulare');

                            if(String.isBlank(mapClients.get(ProvidedFoundCustomerID).CIF_Work_phone__c))
                                MissingContactStr.add('Telefono ufficio');

                            if(String.isBlank(mapClients.get(ProvidedFoundCustomerID).CIF_PersonEmail__c))
                                MissingContactStr.add('Email');

                            if(String.isBlank(mapClients.get(ProvidedFoundCustomerID).CIF_Work_email__c))
                                MissingContactStr.add('Email ufficio');

                            if(String.isBlank(mapClients.get(ProvidedFoundCustomerID).PersonMailingStreet))
                                MissingContactStr.add('Indirizzo');
                        }
                        else
                        {
                            if(String.isBlank(mapClients.get(ProvidedFoundCustomerID).CIF_Phone__c))
                                MissingContactStr.add('Telefono principale');

                            if(String.isBlank(mapClients.get(ProvidedFoundCustomerID).CIF_MobilePhone__c))
                                MissingContactStr.add('Telefono cellulare');

                            if(String.isBlank(mapClients.get(ProvidedFoundCustomerID).CIF_Work_phone__c))
                                MissingContactStr.add('Telefono ufficio');

                            if(String.isBlank(mapClients.get(ProvidedFoundCustomerID).CIF_Personalemail__c))
                                MissingContactStr.add('Email');

                            if(String.isBlank(mapClients.get(ProvidedFoundCustomerID).CIF_Work_email__c))
                                MissingContactStr.add('Email ufficio');

                            if(String.isBlank(mapClients.get(ProvidedFoundCustomerID).BillingStreet))
                                MissingContactStr.add('Indirizzo');
                        }

                        if(MissingContactStr.size()>0)
                        {
                            displayPopup=true;

                            for(String s:MissingContactStr)
                            {
                                if(s.contains('Telefono'))
                                    MissingPhoneLst.add(s);
                                else if(s.contains('Email'))
                                    MissingEmailLst.add(s);
                                else if(s.contains('Indirizzo'))
                                    MissingAddressLst.add(s);
                            }
                        }
                        //}
                    }
                    //MOSCATELLI_M 29/11/2017: Data enrichment SmartCenter Fase 1 -- END

                    for(Case caseRecord :[  select  subject ,accountId,Description,Complainant__c,Origin,CaseNumber, CreatedDate
                    from    Case
                    where   accountId IN :mapClients.keyset()
                    AND isclosed = false
                    order by CreatedDate DESC ]){
                        if(!mapClientToCases.containsKey(caseRecord.accountId))
                            mapClientToCases.put(caseRecord.accountId ,new list<Case>{caseRecord});
                        else
                                mapClientToCases.get(caseRecord.accountId).add(caseRecord);
                    }
                }
            }
            //MOSCATELLI_M 02/11/2016: EVO 69 -- END
            else if (String.IsNotBlank(paramPhone))
            {
                system.debug('query:'+paramPhone);

                //MOSCATELLI_M 02022016: EVO-18-----START
                system.debug('##############START QUERY FOR STANDARD CUSTOMERS#######################################');
                //MOSCATELLI_M 22072015: CR10-----START

                //MOSCATELLI_M 01032016: EVO-18 Bugfixing -- START

                //MOSCATELLI_M 22062016:EVO 62--START
                String PhonePrefix = (String.valueOf(paramPhone)).left(4);
                String Queryphone;

                if(PhonePrefix=='0039')
                    Queryphone = '*39'+paramPhone.substring(4)+' OR '+paramPhone.substring(4)+' OR '+paramPhone+' OR '+'0'+paramPhone.substring(4);
                else
                        Queryphone = '*39'+paramPhone+' OR '+paramPhone+' OR 0039'+paramPhone+' OR '+'0'+paramPhone;
                //string Queryphone = '*39'+paramPhone+' OR '+paramPhone+' OR 0039'+paramPhone;
                //MOSCATELLI_M 22062016:EVO 62--END

                List<List<SObject>> ListAccounts=[FIND :Queryphone IN PHONE FIELDS RETURNING Account(ID)];
                system.debug('ListAccounts: '+ListAccounts);

                List<Account> ListAccountsQuery = new list<Account>();
                ListAccountsQuery = ((List<Account>)ListAccounts[0]);

                //OAVERSANO 08/10/2018 : Caring Angel -- START
                //mapClients = new map<Id,Account>([Select id, name ,Fiscal_ID__c,PersonEmail,Partita_IVA__c,AAI_Partita_IVA__c,AAI_Codice_fiscale__c,RecordType.name,Phone,IsPersonAccount,Codice_Fiscale_AAF__c,TECH_Company__c,AAI_Agency_Reference_Code__c,CIF_Phone__c,CIF_PersonMobilePhone__c,CIF_Work_phone__c,CIF_MobilePhone__c,CIF_PersonEmail__c,CIF_Personalemail__c,CIF_Work_email__c,PersonMailingStreet,BillingStreet //CAPOBIANCO_A 30/08/2017 EVO 87: AMF - Added the extraction of TECH_Company__c
                mapClients = new map<Id,Account>([SELECT id, name ,Fiscal_ID__c, Codice_fiscale_ListView__c,PersonEmail,Partita_IVA__c,AAI_Partita_IVA__c,AAI_Codice_fiscale__c,RecordType.name,Phone,IsPersonAccount,Codice_Fiscale_AAF__c,TECH_Company__c,AAI_Agency_Reference_Code__c,CIF_Phone__c,CIF_PersonMobilePhone__c,CIF_Work_phone__c,CIF_MobilePhone__c,CIF_PersonEmail__c,CIF_Personalemail__c,CIF_Work_email__c,PersonMailingStreet,BillingStreet,AAI_Agency__r.Name
                //OAVERSANO 08/10/2018 : Caring Angel -- END
                FROM    Account
                WHERE id in:ListAccountsQuery
                //MOSCATELLI_M 10102016: Family Protect -- START
                //and RecordType.Name in ('B2B Client','B2C Client','Individual','Corporate')]);
                AND RecordType.Name in ('B2B Client','B2C Client','Individual','Corporate','AAF_B2C')]);
                //MOSCATELLI_M 10102016: Family Protect -- END

                /*
mapClients = new map<id,Account>([Select id, name ,Fiscal_ID__c,PersonEmail,Partita_IVA__c,AAI_Partita_IVA__c,AAI_Codice_fiscale__c,RecordType.Name,Phone
from    Account
where   ((PersonMobilePhone like :'%'+paramPhone
or   PersonHomePhone like :'%'+paramPhone
or   PersonOtherPhone like :'%'+paramPhone
or   Phone  like :'%'+paramPhone
or   Additional_Phone__c  like :'%'+paramPhone)
AND RecordType.Name in ('B2B Client','B2C Client'))
or
((PersonMobilePhone = :paramPhone
or   PersonHomePhone = :paramPhone
or   PersonOtherPhone = :paramPhone
or   Phone  = :paramPhone
or   Additional_Phone__c  = :paramPhone)
AND RecordType.Name in ('Individual','Corporate'))
]) ;
*/
                //MOSCATELLI_M 01032016: EVO-18 Bugfixing -- END

                //MOSCATELLI_M 22072015: CR10-----END

                system.debug('##mapClients: '+mapClients);
                //MOSCATELLI_M 02022016: EVO-18-----END

                if(mapClients.size()>0)
                {
                    //MOSCATELLI_M 29/11/2017: Data enrichment SmartCenter Fase 1 -- START
                    List<Account> AccEnrichLst = new list<Account>();

                    for(String a: mapClients.keyset())
                    {
                        if((mapClients.get(a).RecordType.name == 'B2B Client' || mapClients.get(a).RecordType.name == 'B2C Client'))
                            AccEnrichLst.add(mapClients.get(a));
                    }

                    if(AccEnrichLst.size()==1)
                    {
                        enabCustChng=true;

                        if(AccEnrichLst[0].RecordType.name == 'B2C Client')
                        {
                            if(String.isBlank(AccEnrichLst[0].CIF_Phone__c))
                                MissingContactStr.add('Telefono principale');

                            if(String.isBlank(AccEnrichLst[0].CIF_PersonMobilePhone__c))
                                MissingContactStr.add('Telefono cellulare');

                            if(String.isBlank(AccEnrichLst[0].CIF_Work_phone__c))
                                MissingContactStr.add('Telefono ufficio');

                            if(String.isBlank(AccEnrichLst[0].CIF_PersonEmail__c))
                                MissingContactStr.add('Email');

                            if(String.isBlank(AccEnrichLst[0].CIF_Work_email__c))
                                MissingContactStr.add('Email ufficio');

                            if(String.isBlank(AccEnrichLst[0].PersonMailingStreet))
                                MissingContactStr.add('Indirizzo');
                        }
                        else
                        {
                            if(String.isBlank(AccEnrichLst[0].CIF_Phone__c))
                                MissingContactStr.add('Telefono principale');

                            if(String.isBlank(AccEnrichLst[0].CIF_MobilePhone__c))
                                MissingContactStr.add('Telefono cellulare');

                            if(String.isBlank(AccEnrichLst[0].CIF_Work_phone__c))
                                MissingContactStr.add('Telefono ufficio');

                            if(String.isBlank(AccEnrichLst[0].CIF_Personalemail__c))
                                MissingContactStr.add('Email');

                            if(String.isBlank(AccEnrichLst[0].CIF_Work_email__c))
                                MissingContactStr.add('Email ufficio');

                            if(String.isBlank(AccEnrichLst[0].BillingStreet))
                                MissingContactStr.add('Indirizzo');
                        }

                        if(MissingContactStr.size()>0)
                        {
                            displayPopup=true;

                            for(String s:MissingContactStr)
                            {
                                if(s.contains('Telefono'))
                                    MissingPhoneLst.add(s);
                                else if(s.contains('Email'))
                                    MissingEmailLst.add(s);
                                else if(s.contains('Indirizzo'))
                                    MissingAddressLst.add(s);
                            }
                        }
                    }
                    //MOSCATELLI_M 29/11/2017: Data enrichment SmartCenter Fase 1 -- END

                    //OAVERSANO 08/10/2018 : Caring Angel -- START

                    //MOSCATELLI_M 13/03/2019: Axa Assistance -- START
                    //if(isCaringAngel)
                    if(isCaringAngel == true || isSinistri == true || isCaringSalute == true)
                    //MOSCATELLI_M 13/03/2019: Axa Assistance -- END
                    {
                        list<WrapperClientCases> listWrapper3 =new list<WrapperClientCases>();
                        for (Account client : mapClients.values())
                        {
                            WrapperClientCases ClientWrapper = new WrapperClientCases();
                            ClientWrapper.Client =  client;
                            listWrapper3.add(ClientWrapper);
                            mapPolicyClients.put(client.id,ClientWrapper.Client);
                        }
                        system.debug('CaringAngel:listWrapper3: '+listWrapper3);
                        policyClients =  listWrapper3;

                        mapClientToCases = new Map<id,List<Case>>();
                        listCases = new List<Case>();
                        //MOSCATELLI_M 13/03/2019: Axa Assistance -- START

                        String Accountids ='';

                        for(String s: mapPolicyClients.keyset())
                        {
                          
                            if(String.isBlank(Accountids))
                                Accountids = '\''+s+'\'';
                            else
                                    Accountids+=',\''+s+'\'';
                        }
              
                        String CaseQuery = 'SELECT  subject ,accountId,RecordType.DeveloperName, Owner.Name, Status, Description,Complainant__c,Origin,CaseNumber,CreatedDate FROM Case WHERE accountId IN ('+Accountids+') AND isclosed = false ';

                        if(isCaringAngel)
                            CaseQuery+=' AND RecordTypeId=\''+Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(AP_Constants.rtCaseCaringAngel).getRecordTypeId()+'\'';
                        else if(isCaringSalute)
                            CaseQuery+=' AND RecordTypeId=\''+Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(AP_Constants.rtCaseCaringSalute).getRecordTypeId()+'\'';
                        else
                                CaseQuery+=' AND RecordTypeId in (\''+Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Sinistri_AAI').getRecordTypeId()+'\',\''+Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(AP_Constants.rtCaseCaringAngel).getRecordTypeId()+'\',\''+Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(AP_Constants.rtCaseSinistro).getRecordTypeId()+'\')';

                        CaseQuery+= ' ORDER BY CreatedDate DESC';

                        system.debug('##CaseQuery: '+CaseQuery);

                        for(Case caseRecord : Database.query(CaseQuery))
                        /*
                        for(Case caseRecord :[  SELECT  subject ,accountId,Description,Complainant__c,Origin,CaseNumber,CreatedDate
                                    FROM Case
                                    WHERE accountId IN :mapPolicyClients.keyset()
                                    AND isclosed = false
                                    AND RecordTypeId =: Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(AP_Constants.rtCaseCaringAngel).getRecordTypeId()
                                    ORDER BY CreatedDate DESC ])*/
                        //MOSCATELLI_M 13/03/2019: Axa Assistance -- END
                        {
                            if(!mapClientToCases.containsKey(caseRecord.accountId))
                                mapClientToCases.put(caseRecord.accountId ,new list<Case>{caseRecord});
                            else
                                    mapClientToCases.get(caseRecord.accountId).add(caseRecord);
                        }
                        if(mapPolicyClients.size()==1)
                        {
                            for(String IdmapPolicyClients: mapPolicyClients.keySet())
                            {
                                selectedClientId = mapPolicyClients.get(IdmapPolicyClients).Id;
                            }
                            loadCases();
                        }
                    }

                    else
                    {
                        for(Case caseRecord :[  select  subject ,accountId,Description,Complainant__c,Origin,CaseNumber, CreatedDate,RecordType.DeveloperName
                        from    Case
                        where   accountId IN :mapClients.keyset()
                        AND isclosed = false//status = 'Open'
                        order by CreatedDate DESC ]){
                            if(!mapClientToCases.containsKey(caseRecord.accountId))
                                mapClientToCases.put(caseRecord.accountId ,new list<Case>{caseRecord});
                            else
                                    mapClientToCases.get(caseRecord.accountId).add(caseRecord);
                        }//end of loop
                    }
                    //OAVERSANO 08/10/2018 : Caring Angel -- END
                }
                else
                {
                    if(ApexPages.currentPage() != null){
                        apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Info,System.label.NoClientFound);
                        apexpages.addmessage(msg);
                    }else{
                        throw new LghtClientCallProcessingException(System.label.NoClientFound);
                    }
                }//end of check size
            }
            //MOSCATELLI_M 04/01/2017: Bugfixing -- START
            else if(String.isBlank(paramPhone))
            {
                mapClients = new map<id,Account>();
                if(ApexPages.currentPage() != null){
                    apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Info,System.label.NoClientFound);
                    apexpages.addmessage(msg);
                }else{
                    throw new LghtClientCallProcessingException(System.label.NoClientFound);
                }
            }
            //MOSCATELLI_M 04/01/2017: Bugfixing -- END
        }
        //MOSCATELLI_M 09112015: EVO-23-----END

        if(String.isNotBlank(ProvidedFoundPolicyID))
        {
            selectedPolicyId =ProvidedFoundPolicyID;
            selectedPolicyName = [Select Name from Insurancepolicy__c where id=:ProvidedFoundPolicyID].Name;
        }

    }//end of method loadClients();

    public void loadAgentCases()
    {
        //MOSCATELLI_M 02/11/2016: EVO 69 -- START
        if(String.isNotBlank(ProvidedFoundAgentID))
        {
            listAgents = new list<Account>([Select id, name ,Fiscal_ID__c,PersonEmail,PersonHomePhone,Phone,State__c
            from    Account
            where   Id = :ProvidedFoundAgentID
            limit   1]) ;

            if(listAgents.size()>0)
            {
                selectedAgentId  = listAgents[0].id;
                selectedAgentName  = listAgents[0].name;
                InactiveBankAgent=(listAgents[0].State__c==AP_Constants.stAccInActiveBank)?true:false;//MOSCATELLI_M 13/02/2018: Aggiornamento gestori
                selectedAgentPhone  = listAgents[0].Phone;
                listAgentCases = new list<Case>([   select  subject ,accountId , account.Name ,Description,Complainant__c,Origin,CaseNumber,CreatedDate
                from    Case
                where   AgentName__c = :selectedAgentId
                AND isclosed = false
                order by CreatedDate DESC ]);
            }
        }
        else
        {
            //MOSCATELLI_M 13062016:EVO 62 -- START
            if(String.isNotBlank(Distribution) && Distribution =='MPS')
            {
                if (String.IsNotBlank(paramAgentCode))
                {
                    listAgents = new list<Account>([Select id, name ,Fiscal_ID__c,PersonEmail,PersonHomePhone,Phone,State__c
                    from    Account
                    where   Matricola__c = :paramAgentCode
                    limit   1]) ;
                    system.debug('listAgents size : '+listAgents.size());

                    if(listAgents.size()>0)
                    {
                        selectedAgentId  = listAgents[0].id;
                        selectedAgentName  = listAgents[0].name;
                        selectedAgentPhone  = listAgents[0].Phone;
                        InactiveBankAgent=(listAgents[0].State__c==AP_Constants.stAccInActiveBank)?true:false;//MOSCATELLI_M 13/02/2018: Aggiornamento gestori

                        listAgentCases = new list<Case>([   select  subject ,accountId , account.Name ,Description,Complainant__c,Origin,CaseNumber,CreatedDate
                        from    Case
                        where   AgentName__c = :selectedAgentId
                        AND isclosed = false//status = 'Open'
                        order by CreatedDate DESC ]);
                    }//end of checck listAgent size
                }//end of check paramAgentCode
                //MOSCATELLI_M 04/01/2017: Bugfixing -- START
                else if(String.IsBlank(paramAgentCode))
                {
                    listAgents = new list<Account>();
                }
                //MOSCATELLI_M 04/01/2017: Bugfixing -- END
            }
            else
            {
                if (String.IsNotBlank(paramPhone))
                {
                    String PhonePrefix = (String.valueOf(paramPhone)).left(4);
                    String Queryphone;

                    if(PhonePrefix=='0039')
                        Queryphone = '*39'+paramPhone.substring(4)+' OR '+paramPhone.substring(4)+' OR '+paramPhone+' OR '+'0'+paramPhone.substring(4);
                    else
                            Queryphone = '*39'+paramPhone+' OR '+paramPhone+' OR 0039'+paramPhone+' OR '+'0'+paramPhone;

                    List<List<SObject>> ListExternalAgents=[FIND :Queryphone IN PHONE FIELDS RETURNING Account(ID)];
                    system.debug('ListExternalAgents: '+ListExternalAgents);

                    List<Account> ListAgentQuery = new list<Account>();
                    ListAgentQuery = ((List<Account>)ListExternalAgents[0]);

                    listAgents = new list<Account>([Select id, name ,Fiscal_ID__c,PersonEmail,PersonHomePhone,Phone,Matricola__c,State__c
                    from    Account
                    where   id in:ListAgentQuery
                    and RecordType.Name = 'Intermediary'
                    ]) ;
                    system.debug('listAgents size : '+listAgents.size());

                    if(listAgents.size()==1)
                    {
                        selectedAgentId  = listAgents[0].id;
                        selectedAgentName  = listAgents[0].name;
                        selectedAgentPhone  = listAgents[0].Phone;
                        InactiveBankAgent=(listAgents[0].State__c==AP_Constants.stAccInActiveBank)?true:false;//MOSCATELLI_M 13/02/2018: Aggiornamento gestori

                        listAgentCases = new list<Case>([   select  subject ,accountId , account.Name ,Description,Complainant__c,Origin,CaseNumber,CreatedDate
                        from    Case
                        where   AgentName__c = :selectedAgentId
                        AND isclosed = false
                        order by CreatedDate DESC ]);
                    }
                    else
                    {
                        mapAgents = new map<Id,Account>(listAgents);

                        for(Case caseRecord :[  select  subject ,accountId , account.Name ,Description,Complainant__c,Origin,CaseNumber,CreatedDate,AgentName__r.id
                        from    Case
                        where   AgentName__c in:mapAgents.keyset()
                        AND isclosed = false
                        order by CreatedDate DESC ])
                        {
                            if(!mapAgentToCases.containsKey(caseRecord.AgentName__r.id))
                                mapAgentToCases.put(caseRecord.AgentName__r.id ,new list<Case>{caseRecord});
                            else
                                    mapAgentToCases.get(caseRecord.AgentName__r.id).add(caseRecord);
                        }
                    }
                }
                //MOSCATELLI_M 04/01/2017: Bugfixing -- START
                else if(String.IsBlank(paramPhone))
                {
                    listAgents = new list<Account>();
                }
                //MOSCATELLI_M 04/01/2017: Bugfixing -- END
            }
            //MOSCATELLI_M 13062016:EVO 62 -- END
        }
        //MOSCATELLI_M 02/11/2016: EVO 69 -- END
    }//end of loadAgentCases()

    public integer getNoOfClients(){
        return mapClients.size();
    }
    public integer getNoOfAgents(){
        return listAgents.size();
    }
    public integer getNoOfCases(){
        if(activeViewClientExistingCase)
            return listPolicyClientCases.size();
        if(activeViewAgentExistingCase)
            return listAgentCases.size();
        return listCases.size();
    }
    public integer getNoOfCasesFromList(){
        return listCases.size();
    }

    public void loadPolicyClients()
    {
        //MOSCATELLI_M 29/11/2017: Data enrichment SmartCenter Fase 1 -- START
        enabCustChng = false;
        displayPopup = false;
        MissingContactStr.clear();
        MissingPhoneLst.clear();
        MissingEmailLst.clear();
        MissingAddressLst.clear();
        //MOSCATELLI_M 29/11/2017: Data enrichment SmartCenter Fase 1 -- END

        isAgency = false;//MOSCATELLI_M 22072015: CR10
        selectedPolicyClientId = null;
        searchStatus = System.label.NoClientFound;
        searchCaseStatus = System.label.ChooseACase;
        policyClients =new list<WrapperClientCases>();
        listPolicyClientCases = new list<Case>();
        list<WrapperClientCases> listWrapper =new list<WrapperClientCases>();
        //MOSCATELLI_M 18/07/2016: EVO 62 -- START
        mapPolicyClients = new map <id,Account>();
        //MOSCATELLI_M 18/07/2016: EVO 62 -- END
        mapPolicyClientToCases  = new map<id,list<Case>>();

        System.debug('>>>>>>>>>>> policyNumber : ' + policyNumber);
        System.debug('>>>>>>>>>>> searchFirstName : ' + searchFirstName);
        System.debug('>>>>>>>>>>> policyNumber : ' + searchLastName);
        System.debug('>>>>>>>>>>> searchDateOfBirth : ' + searchDateOfBirth);
        System.debug('>>>>>>>>>>> searchPartitaIVA : ' + searchPartitaIVA); //MOSCATELLI_M 22072015: CR10
        System.debug('>>>>>>>>>>> searchTarga : ' + searchTarga); //OAVERSANO 15/10/2018 : Caring Angel
        System.debug('>>>>>>>>>>> searchClaim: ' + searchClaim); // FOZDEN 26/06/2019: AXA Assistance Enhancement Fase II


        //MOSCATELLI_M 23/02/2017: Bugfix Customer manual search -- START
        //string queryStatement = 'SELECT id,name,CUID__c,CUID__r.name , CUID__r.IsPersonAccount,  CUID__r.Fiscal_ID__c, CUID__r.Partita_IVA__c,CUID__r.AAI_Partita_IVA__c, CUID__r.AAI_Codice_fiscale__c,CUID__r.RecordType.Name FROM InsurancePolicy__c where ';
        String queryStatement = '';
        String toFind = '';

        // FOZDEN 26/06/2019: AXA Assistance Enhancement Fase II -- START
        if (String.isNotBlank(searchClaim)) {

            queryStatement += 'Id WHERE Account__r.RecordType.Name IN (\'Individual\',\'Corporate\',\'B2B Client\',\'B2C Client\') AND Name =' + '\'' + searchClaim + '\'';
            toFind = searchClaim;

            if (String.isNotBlank(searchPartitaIVA) || String.isNotBlank(searchName)) {

                isAgency = true;

                if (String.isNotBlank(searchPartitaIVA)) {
                    searchPartitaIVA = (searchPartitaIVA).escapeJava();
                    queryStatement += ' AND (Account__r.Partita_IVA__c =' + '\'' + searchPartitaIVA + '\' OR Account__r.AAI_Partita_IVA__c =' + '\'' + searchPartitaIVA + '\') ';
                }

                if (String.isNotBlank(searchName)) {
                    searchName = (searchName).escapeJava();
                    queryStatement += ' AND Account__r.Name LIKE ' + '\'%' + searchName + '%\'';
                }

            } else {

                if (String.isNotBlank(searchFirstName)) {
                    searchFirstName = (searchFirstName).escapeJava();
                    queryStatement += ' AND Account__r.FirstName =' + '\'' + searchFirstName + '\'';
                }
                if (String.isNotBlank(searchLastName)) {
                    searchLastName = (searchLastName).escapeJava();
                    queryStatement += ' AND Account__r.LastName =' + '\'' + searchLastName + '\'';
                }
                if (String.isNotBlank(searchFiscalId)) {
                    searchFiscalId = (searchFiscalId).escapeJava();
                    queryStatement += ' AND (Account__r.Fiscal_ID__c = :searchFiscalId  OR Account__r.AAI_Codice_fiscale__c = :searchFiscalId OR  Account__r.AAI_Partita_IVA__c = :searchFiscalId OR Account__r.Partita_IVA__c = :searchFiscalId OR Account__r.Codice_Fiscale_AAF__c = :searchFiscalId) ';
                }
                if (String.isNotBlank(searchDateOfBirth)) {
                    queryStatement += ' AND Account__r.PersonBirthDate = ' + searchDateOfBirth;
                }
            }

            if (String.isNotBlank(policyNumber)) {
                queryStatement += ' AND Polizza__r.Name =' + '\'' + policyNumber + '\'';
            }

            if (String.isNotBlank(searchTarga)) {
                queryStatement += ' AND Polizza__r.Targa_veicolo__c =' + '\'' + searchTarga + '\'';
            }

            String [] SpecialChar = new String[]{
                    '&#124;', '&', '|', '!', '{', '}', '[', ']', '(', ')', '^', '~', '*', ':', '"', '+', '-'
            };

            for (String s : SpecialChar) {
                if (toFind.contains(s)) {
                    toFind = toFind.replace(s, '\\' + s);
                }
            }
            toFind = String.escapeSingleQuotes(toFind);

            String searchs = 'FIND {' + toFind + '} IN ALL FIELDS RETURNING Claim__c(' + queryStatement + ')';
            System.debug('##searchs: ' + searchs);
            List<List<SObject>> ListClaims = Search.query(searchs);
            List<Claim__c> claims = (List<Claim__c>) ListClaims[0];

            for (Claim__c c : [
                    SELECT Id, Account__c, Account__r.Name, Account__r.IsPersonAccount, Account__r.Fiscal_ID__c,
                            Account__r.Codice_fiscale_ListView__c, Account__r.Partita_IVA__c,
                            Account__r.AAI_Partita_IVA__c, Account__r.AAI_Codice_fiscale__c, Account__r.RecordType.Name,
                            Account__r.Codice_Fiscale_AAF__c, Account__r.TECH_Company__c,
                            Account__r.AAI_Agency_Reference_Code__c, Account__r.CIF_Phone__c,
                            Account__r.CIF_PersonMobilePhone__c, Account__r.CIF_Work_phone__c,
                            Account__r.CIF_MobilePhone__c, Account__r.CIF_PersonEmail__c,
                            Account__r.CIF_Personalemail__c, Account__r.CIF_Work_email__c,
                            Account__r.PersonMailingStreet, Account__r.BillingStreet,
                            Account__r.AAI_Agency__r.Name
                    FROM Claim__c
                    WHERE Id IN:claims
            ]) {
                WrapperClientCases ClientWrapper = new WrapperClientCases();
                ClientWrapper.Client =  c.Account__r;
                listWrapper.add(ClientWrapper);
                mapPolicyClients.put(c.Account__c,ClientWrapper.Client);
            }

        }
        // FOZDEN 26/06/2019: AXA Assistance Enhancement Fase II -- END

        //OAVERSANO 15/10/2018 : Caring Angel -- START
        else if( String.isNotBlank(searchTarga) )
        {
            queryStatement += 'id WHERE CUID__r.RecordType.Name in (\'Individual\',\'Corporate\',\'B2B Client\',\'B2C Client\') AND Targa_veicolo__c ='+'\''+searchTarga+'\'';//MOSCATELLI_M 02022016: EVO-18
            toFind = searchTarga;
            if( String.IsNotBlank(policyNumber))
            {
                queryStatement += ' AND Name ='+'\''+policyNumber+'\'';
                if(String.isNotBlank(toFind))
                    toFind+= ' AND '+policyNumber;
                else
                        toFind= policyNumber;
            }
            if( String.IsNotBlank(searchFirstName)){
                searchFirstName = (searchFirstName).escapeJava();
                queryStatement += ' AND CUID__r.firstname ='+'\''+searchFirstName+'\'';
            }
            if( String.IsNotBlank(searchLastName)){
                searchLastName = (searchLastName).escapeJava();
                queryStatement += ' AND CUID__r.lastname ='+'\''+searchLastName+'\'';
            }
            if( String.IsNotBlank(searchFiscalId)){
                searchFiscalId = (searchFiscalId).escapeJava();
                queryStatement += ' AND (CUID__r.Fiscal_ID__c = :searchFiscalId  OR CUID__r.AAI_Codice_fiscale__c = :searchFiscalId OR  CUID__r.AAI_Partita_IVA__c = :searchFiscalId OR CUID__r.Partita_IVA__c = :searchFiscalId OR CUID__r.Codice_Fiscale_AAF__c = :searchFiscalId) ';

            }

            //MOSCATELLI_M 27/11/2018: Caring Angel Enhancement — START
            if(String.isNotBlank(searchDateOfBirth))
            {
                queryStatement += ' AND CUID__r.PersonBirthDate = '+searchDateOfBirth;
            }
            //MOSCATELLI_M 27/11/2018: Caring Angel Enhancement — END


            system.debug('>>>>>>>>>>> queryStatement : '+queryStatement);

            String searchs ='FIND {'+toFind+'} IN ALL FIELDS RETURNING InsurancePolicy__c('+queryStatement+')';
            system.debug('##searchs: '+searchs);
            List<List<SObject>> ListPolicies = search.query(searchs);

            List<InsurancePolicy__c> ListPoliciesQuery = new list<InsurancePolicy__c>();
            ListPoliciesQuery = ((List<InsurancePolicy__c>)ListPolicies[0]);

            for(InsurancePolicy__c policy : [Select id,name,CUID__c,CUID__r.name , CUID__r.Codice_fiscale_ListView__c, CUID__r.IsPersonAccount,  CUID__r.Fiscal_ID__c, CUID__r.Partita_IVA__c,CUID__r.AAI_Partita_IVA__c, CUID__r.AAI_Codice_fiscale__c,CUID__r.RecordType.Name,CUID__r.TECH_Company__c,CUID__r.AAI_Agency_Reference_Code__c,CUID__r.CIF_Phone__c,CUID__r.CIF_PersonMobilePhone__c,CUID__r.CIF_Work_phone__c,CUID__r.CIF_MobilePhone__c,CUID__r.CIF_PersonEmail__c,CUID__r.CIF_Personalemail__c,CUID__r.CIF_Work_email__c,CUID__r.PersonMailingStreet,CUID__r.BillingStreet,CUID__r.AAI_Agency__r.Name from InsurancePolicy__c where id in:ListPoliciesQuery]) //CAPOBIANCO_A 30/08/2017 EVO 87:AMF - Added the extraction of TECH_Company__c

            {
                selectedPolicyId = policy.Id;
                selectedPolicyName = policy.Name;
                if(policy.CUID__c != null){
                    WrapperClientCases ClientWrapper = new WrapperClientCases();
                    ClientWrapper.Client = policy.CUID__r; //new Account(id =policy.CUID__c , name = policy.CUID__r.Name, Fiscal_ID__c=  policy.CUID__r.Fiscal_ID__c  );
                    listWrapper.add(ClientWrapper);
                    mapPolicyClients.put(policy.CUID__c,ClientWrapper.Client);
                }
            }

        }
        else if( String.IsNotBlank(policyNumber))
        //if( String.IsNotBlank(policyNumber))
        //OAVERSANO 15/10/2018 : Caring Angel -- END
        {
            queryStatement += 'id WHERE CUID__r.RecordType.Name in (\'Individual\',\'Corporate\',\'B2B Client\',\'B2C Client\') AND Name ='+'\''+policyNumber+'\'';//MOSCATELLI_M 02022016: EVO-18
            toFind = policyNumber;

            if( String.IsNotBlank(searchFirstName)){
                //searchFirstName = '%'+(searchFirstName).escapeJava()+'%';  //MOSCATELLI_M 17082015: Query bugfixing
                searchFirstName = (searchFirstName).escapeJava();
                queryStatement += ' AND CUID__r.firstname ='+'\''+searchFirstName+'\'';
            }//end of check blank
            if( String.IsNotBlank(searchLastName)){
                //searchLastName = '%'+(searchLastName).escapeJava()+'%';//MOSCATELLI_M 17082015: Query bugfixing
                searchLastName = (searchLastName).escapeJava();
                //queryStatement += 'AND CUID__r.lastname like :searchLastName ';
                queryStatement += ' AND CUID__r.lastname ='+'\''+searchLastName+'\'';
            }//end of check blank
            if( String.IsNotBlank(searchFiscalId)){
                //searchFiscalId = '%'+(searchFiscalId).escapeJava()+'%';//MOSCATELLI_M 17082015: Query bugfixing
                //MOSCATELLI_M 02022016: EVO-18-----START
                //queryStatement += 'AND CUID__r.Fiscal_ID__c like :searchFiscalId ';
                //queryStatement += 'AND (CUID__r.Fiscal_ID__c like :searchFiscalId OR CUID__r.AAI_Codice_fiscale__c like :searchFiscalId) ';
                //MOSCATELLI_M 02022016: EVO-18-----END
                searchFiscalId = (searchFiscalId).escapeJava();
                queryStatement += ' AND (CUID__r.Fiscal_ID__c = :searchFiscalId  OR CUID__r.AAI_Codice_fiscale__c = :searchFiscalId OR  CUID__r.AAI_Partita_IVA__c = :searchFiscalId OR CUID__r.Partita_IVA__c = :searchFiscalId OR CUID__r.Codice_Fiscale_AAF__c = :searchFiscalId) ';

                
            }//end of check blank
            //}//end of check blank

            //MOSCATELLI_M 22072015: CR10-----START
            if( String.IsNotBlank(searchPartitaIVA)){
                //searchPartitaIVA =  '%'+(searchPartitaIVA).escapeJava()+'%'; //MMOSCATELLI 17082015: Query bugfixing
                //MOSCATELLI_M 02022016: EVO-18-----START
                //queryStatement += 'AND  CUID__r.Partita_IVA__c like :searchPartitaIVA ';
                //queryStatement += 'AND  (CUID__r.Partita_IVA__c like :searchPartitaIVA OR CUID__r.AAI_Partita_IVA__c like :searchPartitaIVA) ';
                //MOSCATELLI_M 02022016: EVO-18-----END
                searchPartitaIVA =  (searchPartitaIVA).escapeJava();
                queryStatement += ' AND  (CUID__r.Partita_IVA__c ='+'\''+searchPartitaIVA+'\' OR CUID__r.AAI_Partita_IVA__c ='+'\''+searchPartitaIVA+'\') ';
                isAgency  = true;
            }//end of check blank
            if( String.IsNotBlank(searchName)){
                /*
    searchName =  '%'+(searchName).escapeJava()+'%';//MMOSCATELLI 17082015: Query bugfixing
    queryStatement += 'AND CUID__r.name like :searchName ';
    */
                searchName =  (searchName).escapeJava();//MMOSCATELLI 17082015: Query bugfixing
                queryStatement += ' AND CUID__r.name like '+'\'%'+searchName+'%\'';
                isAgency  = true;
            }//end of check blank
            //MOSCATELLI_M 22072015: CR10-----END

            //MOSCATELLI_M 27/11/2018: Caring Angel Enhancement — START
            if(String.isNotBlank(searchDateOfBirth))
            {
                queryStatement += ' AND CUID__r.PersonBirthDate = '+searchDateOfBirth;
            }
            //MOSCATELLI_M 27/11/2018: Caring Angel Enhancement — END

            system.debug('>>>>>>>>>>> queryStatement : '+queryStatement);

            String searchs ='FIND {'+toFind+'} IN ALL FIELDS RETURNING InsurancePolicy__c('+queryStatement+')';
            system.debug('##searchs: '+searchs);
            List<List<SObject>> ListPolicies = search.query(searchs);

            List<InsurancePolicy__c> ListPoliciesQuery = new list<InsurancePolicy__c>();
            ListPoliciesQuery = ((List<InsurancePolicy__c>)ListPolicies[0]);

            //OAVERSANO 08/10/2018 : Caring Angel -- START
            for(InsurancePolicy__c policy : [Select id,name,CUID__c,CUID__r.name , CUID__r.Codice_fiscale_ListView__c, CUID__r.IsPersonAccount,  CUID__r.Fiscal_ID__c, CUID__r.Partita_IVA__c,CUID__r.AAI_Partita_IVA__c, CUID__r.AAI_Codice_fiscale__c,CUID__r.RecordType.Name,CUID__r.TECH_Company__c,CUID__r.AAI_Agency_Reference_Code__c,CUID__r.CIF_Phone__c,CUID__r.CIF_PersonMobilePhone__c,CUID__r.CIF_Work_phone__c,CUID__r.CIF_MobilePhone__c,CUID__r.CIF_PersonEmail__c,CUID__r.CIF_Personalemail__c,CUID__r.CIF_Work_email__c,CUID__r.PersonMailingStreet,CUID__r.BillingStreet,CUID__r.AAI_Agency__r.Name from InsurancePolicy__c where id in:ListPoliciesQuery]) //CAPOBIANCO_A 30/08/2017 EVO 87:AMF - Added the extraction of TECH_Company__c
            //for(InsurancePolicy__c policy : [Select id,name,CUID__c,CUID__r.name , CUID__r.IsPersonAccount,  CUID__r.Fiscal_ID__c, CUID__r.Partita_IVA__c,CUID__r.AAI_Partita_IVA__c, CUID__r.AAI_Codice_fiscale__c,CUID__r.RecordType.Name,CUID__r.TECH_Company__c,CUID__r.AAI_Agency_Reference_Code__c,CUID__r.CIF_Phone__c,CUID__r.CIF_PersonMobilePhone__c,CUID__r.CIF_Work_phone__c,CUID__r.CIF_MobilePhone__c,CUID__r.CIF_PersonEmail__c,CUID__r.CIF_Personalemail__c,CUID__r.CIF_Work_email__c,CUID__r.PersonMailingStreet,CUID__r.BillingStreet from InsurancePolicy__c where id in:ListPoliciesQuery]) //CAPOBIANCO_A 30/08/2017 EVO 87:AMF - Added the extraction of TECH_Company__c
            //OAVERSANO 08/10/2018 : Caring Angel -- END
            {
                selectedPolicyId = policy.Id;
                selectedPolicyName = policy.Name;
                if(policy.CUID__c != null){
                    WrapperClientCases ClientWrapper = new WrapperClientCases();
                    ClientWrapper.Client = policy.CUID__r; //new Account(id =policy.CUID__c , name = policy.CUID__r.Name, Fiscal_ID__c=  policy.CUID__r.Fiscal_ID__c  );
                    listWrapper.add(ClientWrapper);
                    mapPolicyClients.put(policy.CUID__c,ClientWrapper.Client);
                }
            }

            /*
    for (InsurancePolicy__c policy : Database.query(queryStatement) ){
    selectedPolicyId = policy.Id;
    selectedPolicyName = policy.Name;
    if(policy.CUID__c != null){
    WrapperClientCases ClientWrapper = new WrapperClientCases();
    ClientWrapper.Client = policy.CUID__r; //new Account(id =policy.CUID__c , name = policy.CUID__r.Name, Fiscal_ID__c=  policy.CUID__r.Fiscal_ID__c  );
    listWrapper.add(ClientWrapper);
    mapPolicyClients.put(policy.CUID__c,ClientWrapper.Client);
    }
    }//end of loop
    */
        }
        //MOSCATELLI_M 02022016: EVO-18-----END
        //MOSCATELLI_M 23/02/2017: Bugfix Customer manual search -- END

        else if ( String.IsBlank(policyNumber)
                &&  (String.IsNotBlank(searchFirstName)
                ||  String.IsNotBlank(searchLastName)
                ||  String.IsNotBlank(searchFiscalId)
                ||    String.IsNotBlank(searchPartitaIVA)//MOSCATELLI_M 22072015: CR10
                ||    String.IsNotBlank(searchName)//MOSCATELLI_M 22072015: CR10
        )
                )
        {
            /**
    *Added by HDU on 10 Feb 2015
    **/
            //MOSCATELLI_M 23/02/2017: Bugfix Customer manual search -- START

            //queryStatement = 'SELECT id,name,IsPersonAccount,Fiscal_ID__c, Partita_IVA__c,AAI_Partita_IVA__c,AAI_Codice_fiscale__c,RecordType.Name,Codice_Fiscale_AAF__c FROM Account where';//MOSCATELLI_M 22072015: CR10
            queryStatement = 'id where RecordType.name in (\'Individual\',\'Corporate\',\'B2B Client\',\'B2C Client\',\'AAF_B2C\')';
            //MOSCATELLI_M 10102016: Family Protect -- START
            //queryStatement +=' RecordType.name in (\'Individual\',\'Corporate\',\'B2B Client\',\'B2C Client\') AND';//MOSCATELLI_M 02022016: EVO-18
            //queryStatement +=' RecordType.name in (\'Individual\',\'Corporate\',\'B2B Client\',\'B2C Client\',\'AAF_B2C\') AND';
            //MOSCATELLI_M 10102016: Family Protect -- END
            if(String.isNotBlank(AccountIdForSCV)){
                queryStatement += ' and Id = ' + '\'' + AccountIdForSCV + '\''; 
            }
            if( String.IsNotBlank(searchFirstName)){
                /*
    searchFirstName = '%'+(searchFirstName).escapeJava()+'%';//MOSCATELLI_M 17082015: Query bugfixing
    queryStatement += ' firstname like :searchFirstName AND ';
    */
                searchFirstName = (searchFirstName).escapeJava();

                if(searchFirstName.contains('\''))
                    searchFirstName = searchFirstName.replace('\'','\\'+'\'');

                queryStatement += ' and firstname ='+'\''+searchFirstName+'\'';

                toFind = searchFirstName;
            }//end of check blank
            if( String.IsNotBlank(searchLastName)){
                /*
    searchLastName = '%'+(searchLastName).escapeJava()+'%';//MOSCATELLI_M 17082015: Query bugfixing
    queryStatement += ' lastname like :searchLastName AND ';
    */
                searchLastName = (searchLastName).escapeJava();

                if(searchLastName.contains('\''))
                    searchLastName = searchLastName.replace('\'','\\'+'\'');

                
                if(String.isNotBlank(searchFirstName)){
                queryStatement += ' AND lastname ='+'\''+searchLastName+'\'';
                }
                else{
                    queryStatement += ' AND (lastname ='+'\''+searchLastName+'\' OR name = \''+searchLastName+'\')';
                }
                if(String.isBlank(toFind))
                    toFind = searchLastName;
                else
                        toFind = toFind+' AND '+searchLastName;
            }//end of check blank
            if( String.IsNotBlank(searchFiscalId)){
                //searchFiscalId = '%'+(searchFiscalId).escapeJava()+'%'; //MOSCATELLI_M 17082015: Query bugfixing
                searchFiscalId = (searchFiscalId).escapeJava();
                //MOSCATELLI_M 02022016: EVO-18-----START
                //MOSCATELLI_M 10102016: Family Protect -- START
                //queryStatement += ' (Fiscal_ID__c like :searchFiscalId OR AAI_Codice_fiscale__c like :searchFiscalId) AND ';
                //queryStatement += ' (Fiscal_ID__c like :searchFiscalId OR AAI_Codice_fiscale__c like :searchFiscalId OR Codice_Fiscale_AAF__c like:searchFiscalId) AND ';
                queryStatement += ' AND (Fiscal_ID__c = :searchFiscalId  OR AAI_Codice_fiscale__c = :searchFiscalId OR  AAI_Partita_IVA__c = :searchFiscalId OR Partita_IVA__c = :searchFiscalId OR Codice_Fiscale_AAF__c = :searchFiscalId) ';

                if(String.isBlank(toFind))
                    toFind = (searchFiscalId).escapeJava();
                else
                        toFind = toFind+' AND '+(searchFiscalId).escapeJava();
                //MOSCATELLI_M 10102016: Family Protect -- END
                //MOSCATELLI_M 02022016: EVO-18-----END
            }//end of check blank

            //MOSCATELLI_M 22072015: Implementations for CR10: The search query has been modified-----START
            if( String.IsNotBlank(searchPartitaIVA)){
                //searchPartitaIVA =  '%'+(searchPartitaIVA).escapeJava()+'%'; //MMOSCATELLI 17082015: Query bugfixing
                searchPartitaIVA = (searchPartitaIVA).escapeJava();
                //MOSCATELLI_M 02022016: EVO-18-----START
                //queryStatement += ' (Partita_IVA__c like :searchPartitaIVA OR AAI_Partita_IVA__c like :searchPartitaIVA) AND ';
                queryStatement += ' AND (Partita_IVA__c ='+'\''+searchPartitaIVA+'\' OR AAI_Partita_IVA__c ='+'\''+searchPartitaIVA+'\')';
                if(String.isBlank(toFind))
                    toFind = (searchPartitaIVA).escapeJava();
                else
                        toFind = toFind+' AND '+(searchPartitaIVA).escapeJava();
                //MOSCATELLI_M 02022016: EVO-18-----END

                isAgency  = true;
            }//end of check blank
            if(String.IsNotBlank(searchName)){
                /*
    searchName =  '%'+(searchName).escapeJava()+'%';//MOSCATELLI_M 17082015: Query bugfixing
    queryStatement += ' name like :searchName AND ';
    */
                searchName =  (searchName).escapeJava();

                if(searchName.contains('\''))
                    searchName = searchName.replace('\'','\\'+'\'');

                queryStatement += ' AND name like '+'\'%'+searchName+'%\'';
                if(String.isBlank(toFind))
                    toFind = searchName;
                else
                        toFind = toFind+' AND '+searchName;
                isAgency  = true;
            }//end of check blank
            //MOSCATELLI_M 22072015: Implementations for CR10: The search query has been modified-----END

            //MOSCATELLI_M 27/11/2018: Caring Angel Enhancement — START
            if(String.isNotBlank(searchDateOfBirth))
            {
                queryStatement += ' AND PersonBirthDate = '+searchDateOfBirth;
            }
            //MOSCATELLI_M 27/11/2018: Caring Angel Enhancement — END

            queryStatement = queryStatement.removeEndIgnoreCase('AND ')+ ' limit 100';

            system.debug('>>>>>>>>>>> queryStatement1 : '+queryStatement);
            system.debug('isAgency: '+isAgency);//MOSCATELLI_M 22/07/2015: Implementations for CR10

            /*
    for (Account client : Database.query(queryStatement) ){
    WrapperClientCases ClientWrapper = new WrapperClientCases();
    ClientWrapper.Client =  client; //new Account(id =client.id , name = client.Name, Fiscal_ID__c= client.Fiscal_ID__c);
    listWrapper.add(ClientWrapper);
    mapPolicyClients.put(client.id,ClientWrapper.Client);
    }//end of loop
    */
            //List<List<SObject>> ListAccounts=[FIND :toFind IN ALL FIELDS RETURNING Account(id where RecordType.name in ('Individual','Corporate','B2B Client','B2C Client','AAF_B2C') and firstname =:searchFirstName and lastname =:searchLastName and (Fiscal_ID__c =:searchFiscalId OR AAI_Codice_fiscale__c =:searchFiscalId OR Codice_Fiscale_AAF__c =:searchFiscalId) and  (Partita_IVA__c =:searchPartitaIVA OR AAI_Partita_IVA__c =:searchPartitaIVA) AND name =:searchName)];
            String [] SpecialChar = new String[]{'&#124;', '&','|','!','{','}','[',']','(',')','^','~', '*', ':','"','+','-'};

            for(String s: SpecialChar)
            {
                if(toFind.contains(s))
                {
                    toFind= toFind.replace(s,'\\'+s);
                    system.debug('\\'+s);
                }
            }
            toFind = String.escapeSingleQuotes(toFind); //OAVERSANO 23/11/2018 : Caring Angel ENHANCEMENT

            String searchs ='FIND {'+toFind+'} IN ALL FIELDS RETURNING ACCOUNT('+queryStatement+')';
            system.debug('##searchs: '+searchs);
            List<List<SObject>> ListAccounts = search.query(searchs);
            system.debug('ListAccounts: '+ListAccounts);

            List<Account> ListAccountsQuery = new list<Account>();
            ListAccountsQuery = ((List<Account>)ListAccounts[0]);

            for (Account client : [Select id,name,IsPersonAccount,Fiscal_ID__c,Codice_fiscale_ListView__c,Partita_IVA__c,AAI_Partita_IVA__c,AAI_Codice_fiscale__c,RecordType.Name,Codice_Fiscale_AAF__c,TECH_Company__c,AAI_Agency_Reference_Code__c,CIF_Phone__c,CIF_PersonMobilePhone__c,CIF_Work_phone__c,CIF_MobilePhone__c,CIF_PersonEmail__c,CIF_Personalemail__c,CIF_Work_email__c,PersonMailingStreet,BillingStreet,AAI_Agency__r.Name from Account where id in:ListAccountsQuery]) //CAPOBIANCO_A 30/08/2017 EVO 87: AMF - Added the extraction of TECH_Company__c
            {
                WrapperClientCases ClientWrapper = new WrapperClientCases();
                ClientWrapper.Client =  client; //new Account(id =client.id , name = client.Name, Fiscal_ID__c= client.Fiscal_ID__c);
                listWrapper.add(ClientWrapper);
                mapPolicyClients.put(client.id,ClientWrapper.Client);
            }//end of loop

            //MOSCATELLI_M 23/02/2017: Bugfix Customer manual search -- END
        }
        system.debug('>>>>>>>>>>> mapPolicyClients : '+mapPolicyClients);
        if(mapPolicyClients.size()>0){

            //MOSCATELLI_M 29/11/2017: Data enrichment SmartCenter Fase 1 -- START
            List<Account> AccEnrichLst = new list<Account>();

            for(String a: mapPolicyClients.keyset())
            {
                if((mapPolicyClients.get(a).RecordType.Name == 'B2B Client' || mapPolicyClients.get(a).RecordType.Name == 'B2C Client'))
                    AccEnrichLst.add(mapPolicyClients.get(a));
            }

            if(AccEnrichLst.size()==1)
            {
                enabCustChng=true;

                if(AccEnrichLst[0].RecordType.name == 'B2C Client')
                {
                    if(String.isBlank(AccEnrichLst[0].CIF_Phone__c))
                        MissingContactStr.add('Telefono principale');

                    if(String.isBlank(AccEnrichLst[0].CIF_PersonMobilePhone__c))
                        MissingContactStr.add('Telefono cellulare');

                    if(String.isBlank(AccEnrichLst[0].CIF_Work_phone__c))
                        MissingContactStr.add('Telefono ufficio');

                    if(String.isBlank(AccEnrichLst[0].CIF_PersonEmail__c))
                        MissingContactStr.add('Email');

                    if(String.isBlank(AccEnrichLst[0].CIF_Work_email__c))
                        MissingContactStr.add('Email ufficio');

                    if(String.isBlank(AccEnrichLst[0].PersonMailingStreet))
                        MissingContactStr.add('Indirizzo');
                }
                else
                {
                    if(String.isBlank(AccEnrichLst[0].CIF_Phone__c))
                        MissingContactStr.add('Telefono principale');

                    if(String.isBlank(AccEnrichLst[0].CIF_MobilePhone__c))
                        MissingContactStr.add('Telefono cellulare');

                    if(String.isBlank(AccEnrichLst[0].CIF_Work_phone__c))
                        MissingContactStr.add('Telefono ufficio');

                    if(String.isBlank(AccEnrichLst[0].CIF_Personalemail__c))
                        MissingContactStr.add('Email');

                    if(String.isBlank(AccEnrichLst[0].CIF_Work_email__c))
                        MissingContactStr.add('Email ufficio');

                    if(String.isBlank(AccEnrichLst[0].BillingStreet))
                        MissingContactStr.add('Indirizzo');
                }

                if(MissingContactStr.size()>0)
                {
                    displayPopup=true;

                    for(String s:MissingContactStr)
                    {
                        if(s.contains('Telefono'))
                            MissingPhoneLst.add(s);
                        else if(s.contains('Email'))
                            MissingEmailLst.add(s);
                        else if(s.contains('Indirizzo'))
                            MissingAddressLst.add(s);
                    }
                }
            }

            //MOSCATELLI_M 29/11/2017: Data enrichment SmartCenter Fase 1 -- END



            //OAVERSANO 08/10/2018 : Caring Angel -- START

            //MOSCATELLI_M 13/03/2019: Axa Assistance -- START
            //if(isCaringAngel)
            if(isCaringAngel || isSinistri)
            //MOSCATELLI_M 13/03/2019: Axa Assistance -- END
            {
                mapClientToCases = new Map<id,List<Case>>();
                listCases = new List<Case>();
                //MOSCATELLI_M 13/03/2019: Axa Assistance -- START
                /*for(Case caseRecord :[  SELECT  subject ,accountId,Description,Complainant__c,Origin,CaseNumber,CreatedDate
                                        FROM Case
                                        WHERE accountId IN :mapPolicyClients.keyset()
                                        AND isclosed = false
                                        AND RecordTypeId =: Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(AP_Constants.rtCaseCaringAngel).getRecordTypeId()
                                        ORDER BY CreatedDate DESC ])*/
                String Accountids ='';

                for(String s: mapPolicyClients.keyset())
                {
                    if(String.isNotBlank(s))
                        Accountids = '\''+s+'\'';
                    else
                            Accountids+=',\''+s+'\'';
                }

                String CaseQuery_1 = 'SELECT  subject ,accountId,Description,Complainant__c,Origin,CaseNumber,CreatedDate, RecordType.DeveloperName FROM Case WHERE accountId IN ('+Accountids+') AND isclosed = false ';

                if(isCaringAngel)
                    CaseQuery_1+=' AND RecordTypeId=\''+Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(AP_Constants.rtCaseCaringAngel).getRecordTypeId()+'\'';
                else if(isCaringSalute)
                    CaseQuery_1+=' AND RecordTypeId=\''+Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('AXA_Caring_Salute').getRecordTypeId()+'\'';
                else
                        CaseQuery_1+=' AND RecordTypeId in (\''+Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Sinistri_AAI').getRecordTypeId()+'\',\''+Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(AP_Constants.rtCaseCaringAngel).getRecordTypeId()+'\',\''+Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(AP_Constants.rtCaseSinistro).getRecordTypeId()+'\')';

                CaseQuery_1+= ' ORDER BY CreatedDate DESC';

                system.debug('##CaseQuery_1: '+CaseQuery_1);

                for(Case caseRecord : Database.query(CaseQuery_1))
                //MOSCATELLI_M 13/03/2019: Axa Assistance -- END
                {
                    if(!mapClientToCases.containsKey(caseRecord.accountId))
                        mapClientToCases.put(caseRecord.accountId ,new list<Case>{caseRecord});
                    else
                            mapClientToCases.get(caseRecord.accountId).add(caseRecord);
                }
                if(mapPolicyClients.size()==1)
                {
                    for(String IdmapPolicyClients: mapPolicyClients.keySet())
                    {
                        selectedClientId = mapPolicyClients.get(IdmapPolicyClients).Id;
                    }
                    loadCases();
                }
            }
            else
            {
                for(Case caseRecord :[  select  subject , Status, RecordType.Name, RecordType.DeveloperName, Owner.Name, accountId,Description,Complainant__c,Origin,CaseNumber,CreatedDate
                from    Case
                where   accountId IN :mapPolicyClients.keyset()
                AND     isclosed = false //status = 'Open'
                order by CreatedDate DESC ]){
                    if(!mapPolicyClientToCases.containsKey(caseRecord.accountId))
                        mapPolicyClientToCases.put(caseRecord.accountId ,new list<Case>{caseRecord});
                    else
                            mapPolicyClientToCases.get(caseRecord.accountId).add(caseRecord);
                }//end of loop
            }
            //OAVERSANO 08/10/2018 : Caring Angel -- END
        }//end of check size
        //OAVERSANO 08/10/2018 : Caring Angel -- START
        else
        {
            //MOSCATELLI_M 13/03/2019: Axa Assistance -- START
            //if(isCaringAngel)
            if(isCaringAngel || isSinistri)
            //MOSCATELLI_M 13/03/2019: Axa Assistance -- END
            {
                mapClientToCases = new Map<id,List<Case>>();
                listCases = new List<Case>();
            }
        }
        //OAVERSANO 08/10/2018 : Caring Angel -- END

        if(activeViewClientExistingCase){
            list<WrapperClientCases> listWrapper2 =new list<WrapperClientCases>();
            for(WrapperClientCases  wrap : listWrapper){
                string clientId = wrap.Client.id;
                WrapperClientCases ClientWrapper = new WrapperClientCases();
                if(mapPolicyClients.get(clientId) != null ){
                    ClientWrapper.Client = mapPolicyClients.get(clientId);
                    listWrapper2.add(ClientWrapper);
                }
            }
            listWrapper =new list<WrapperClientCases>();
            listWrapper =listWrapper2;
            system.debug('CaringAngel:listWrapper: '+listWrapper);
        }
        if(activeViewAgentExistingCase){
            listWrapper =new list<WrapperClientCases>();
            /*for(string clientId : mapPolicyClientToCases.keySet()){
    WrapperClientCases ClientWrapper = new WrapperClientCases();
    if(mapPolicyClients.get(clientId) != null ){
    ClientWrapper.Client = mapPolicyClients.get(clientId);
    listWrapper.add(ClientWrapper);
    }
    }*/
            for(string clientId : mapPolicyClients.keySet()){
                WrapperClientCases ClientWrapper = new WrapperClientCases();
                ClientWrapper.Client = mapPolicyClients.get(clientId);
                listWrapper.add(ClientWrapper);
            }
        }

        policyClients =  listWrapper;
        if(policyClients.size() <= 0 )
            showButtonCreateCase = true; 
        system.debug('CaringAngel:policyClients: '+policyClients);
    }//end of method loadPolicyClients

    public void createClient(){
        try{
            //MOSCATELLI_M 22072015: CR10-----START
            system.debug('CreateClient -- START ');
      
            //ANASTASI_S 17072019: Email and Phone Validation -----START
            // Phone
            String phoneNumber = ''; 
            Boolean checkPhoneNumber = true;
            Boolean successPhoneValidation = true;
            // Email
            String emailAddress = ''; 
            Boolean checkEmailAddress = true;
            Boolean successEmailValidation = true;
            //ANASTASI_S 17072019: Email and Phone Validation -----END
            
            if(isAgency)
            {
              //ANASTASI_S 17072019: Email and Phone Validation -----START
                // Phone number validation
                phoneNumber = String.valueOf(CustAgency.Phone);
                if (String.isNotBlank(phoneNumber)) {
                  checkPhoneNumber = (FieldValidator.validateFieldValue('Generic_Phone_RegEx', phoneNumber.replaceAll( '\\s+', ''))) ? true : false;  
                    if (!checkPhoneNumber) {                    
               successPhoneValidation = false;
                        errorMgs = 'Telefono non valido. ';                      
                    } 
                } 
                // Email validation
                emailAddress = String.valueOf(CustAgency.Account_email__c);
                if (String.isNotBlank(emailAddress)) {
                  checkEmailAddress = (FieldValidator.validateFieldValue('Email_RegEx', emailAddress)) ? true : false;  
                    if (!checkEmailAddress) {                    
               successEmailValidation = false;
                        errorMgs = 'Email non valida. ';                       
                    } 
                } 
              //ANASTASI_S 17072019: Email and Phone Validation -----END
              
                Cliente =  CustAgency;
            }
            else
            {
                //ANASTASI_S 17072019: Email and Phone Validation -----START
                // Phone number validation
                phoneNumber = String.valueOf(Client.PersonHomePhone);
                if (String.isNotBlank(phoneNumber)) {
                  checkPhoneNumber = (FieldValidator.validateFieldValue('Generic_Phone_RegEx', phoneNumber.replaceAll( '\\s+', ''))) ? true : false;  
                    if (!checkPhoneNumber) {                    
               successPhoneValidation = false;
                        //errorMgs = 'Telefono non valido. ';                      
                    } 
                } 
                // Email validation
                emailAddress = String.valueOf(Client.PersonEmail);
                if (String.isNotBlank(emailAddress)) {
                  checkEmailAddress = (FieldValidator.validateFieldValue('Email_RegEx', emailAddress)) ? true : false;  
                    if (!checkEmailAddress) {                    
               successEmailValidation = false;
                        //errorMgs = 'Email non valida. ';                       
                    } 
                } 
              //ANASTASI_S 17072019: Email and Phone Validation -----END
              
                Cliente = client;
            }

            id recordId = client.RecordTypeId;
            system.debug('id cliente: '+recordId+' agency?: '+isAgency);
      
            //ANASTASI_S 17072019: Email and Phone Validation -----START
            if (!successPhoneValidation && !successEmailValidation) {
                successClientUpdate = false;
              errorMgs = 'Telefono non valido. Email non valida. ';  
            } else if (!successPhoneValidation && successEmailValidation) {
                successClientUpdate = false;
                errorMgs = 'Telefono non valido. ';
            } else if (successPhoneValidation && !successEmailValidation) {
                successClientUpdate = false;
                errorMgs = 'Email non valida. ';
            } else {
            //ANASTASI_S 17072019: Email and Phone Validation -----END    
            
                insert Cliente;
                //MOSCATELLI_M 22072015: CR10-----END
                /*
                 if(String.IsNotBlank(clientPolicyNumber)){
                     insert new InsurancePolicy__c(name=clientPolicyNumber , CUID__c =Cliente.id );//MOSCATELLI_M 22/07/2015: Implementations for CR10
                 }
                 */
                successClientUpdate = true;
                
            //ANASTASI_S 17072019: Email and Phone Validation -----START    
          }
            //ANASTASI_S 17072019: Email and Phone Validation -----END
        }catch(Exception e ){
            successClientUpdate = false;
            errorMgs = e.getMessage();
        }
        //return new Pagereference('/'+client.id);
    }//end of createClient
    public void CreateCustomer(){
        try{
            //ANASTASI_S 17072019: Email and Phone Validation -----START
            // Phone
            String phoneNumber = ''; 
            Boolean checkPhoneNumber = true;
            Boolean successPhoneValidation = true;
            // Email
            String emailAddress = ''; 
            Boolean checkEmailAddress = true;
            Boolean successEmailValidation = true;
            //ANASTASI_S 17072019: Email and Phone Validation -----END
            
            //MOSCATELLI_M 22072015: CR10-----START
            if(isAgency)
            {
                //ANASTASI_S 17072019: Email and Phone Validation -----START
                // Phone number validation
                phoneNumber = String.valueOf(CustAgency.Phone);
                if (String.isNotBlank(phoneNumber)) {
                  checkPhoneNumber = (FieldValidator.validateFieldValue('Generic_Phone_RegEx', phoneNumber.replaceAll( '\\s+', ''))) ? true : false;  
                    if (!checkPhoneNumber) {                    
               successPhoneValidation = false;
                        errorMgs = 'Telefono non valido. ';                      
                    } 
                } 
                // Email validation
                emailAddress = String.valueOf(CustAgency.Account_email__c);
                if (String.isNotBlank(emailAddress)) {
                  checkEmailAddress = (FieldValidator.validateFieldValue('Email_RegEx', emailAddress)) ? true : false;  
                    if (!checkEmailAddress) {                    
               successEmailValidation = false;
                        errorMgs = 'Email non valida. ';                       
                    } 
                } 
              //ANASTASI_S 17072019: Email and Phone Validation -----END
              
                CustAgency.Additional_Phone__c = CustAgency.Phone;
                Cliente = CustAgency;
            }
            else
            {
                //ANASTASI_S 17072019: Email and Phone Validation -----START
                // Phone number validation
                phoneNumber = String.valueOf(customer.PersonHomePhone);
                if (String.isNotBlank(phoneNumber)) {
                  checkPhoneNumber = (FieldValidator.validateFieldValue('Generic_Phone_RegEx', phoneNumber.replaceAll( '\\s+', ''))) ? true : false;  
                    if (!checkPhoneNumber) {                    
               successPhoneValidation = false;
                        //errorMgs = 'Telefono non valido. ';                      
                    } 
                } 
                // Email validation
                emailAddress = String.valueOf(customer.PersonEmail);
                if (String.isNotBlank(emailAddress)) {
                  checkEmailAddress = (FieldValidator.validateFieldValue('Email_RegEx', emailAddress)) ? true : false;  
                    if (!checkEmailAddress) {                    
               successEmailValidation = false;
                        //errorMgs = 'Email non valida. ';                       
                    } 
                } 
              //ANASTASI_S 17072019: Email and Phone Validation -----END
              
                if(!CallerIsCustomer)
                    customer.Additional_Phone__c = customer.PersonHomePhone;

                Cliente = customer;
            }
            
            //ANASTASI_S 17072019: Email and Phone Validation -----START
            if (!successPhoneValidation && !successEmailValidation) {
                successClientUpdate = false;
              errorMgs = 'Telefono non valido. Email non valida. ';  
            } else if (!successPhoneValidation && successEmailValidation) {
                successClientUpdate = false;
                errorMgs = 'Telefono non valido. ';
            } else if (successPhoneValidation && !successEmailValidation) {
                successClientUpdate = false;
                errorMgs = 'Email non valida. ';
            } else {
            //ANASTASI_S 17072019: Email and Phone Validation -----END 
            
                system.debug('Cliente: '+Cliente);
    
                insert Cliente;
                /*
                if(String.IsNotBlank(clientPolicyNumber)){
                    insert new InsurancePolicy__c(name=clientPolicyNumber , CUID__c =Cliente.id );
                }
                */
                //MOSCATELLI_M 22072015: CR10-----END
                successClientUpdate = true;
                
            //ANASTASI_S 17072019: Email and Phone Validation -----START    
          }
            //ANASTASI_S 17072019: Email and Phone Validation -----END    
        }catch(Exception e ){
            successClientUpdate = false;
            errorMgs = e.getMessage();
        }
        //return new Pagereference('/'+client.id);
    }//end of createClient

    public void createClientForNewCase(){
        try{
            createClient();
            successClientCreation = true;
        }catch(Exception e ){
            successClientCreation = false;
            errorMgs = e.getMessage();
        }
    }//end of createClient

    public void updateclient(){
        System.debug('######selectedClientId : '+selectedClientId);
        System.debug('######paramPhone : '+paramPhone);
        try{
            //set phone

            //MOSCATELLI_M 12042016: EVO 46 -- START
            /*
if(isPerson)
//MMOSCATELLI 02022016: EVO-18----START
{
if(!AIISelected)
update new account (id = selectedClientId, PersonHomePhone = paramPhone );
else
update new account (id = selectedClientId, Additional_Phone__c = paramPhone );
}
//MMOSCATELLI 02022016: EVO-18----END
else
//MMOSCATELLI 02022016: EVO-18----START
{
if(!AIISelected)
update new account (id = selectedClientId, Phone = paramPhone );
else
update new account (id = selectedClientId, Additional_Phone__c = paramPhone );
}
//MMOSCATELLI 02022016: EVO-18-----END
*/
            if(String.isNotBlank(paramPhone))
                update new account (id = selectedClientId, Additional_Phone__c = paramPhone );
            //MOSCATELLI_M 12042016: EVO 46 -- END
            successClientUpdate = true;
        }catch(Exception e ){
            System.debug('######error : '+e);
            successClientUpdate = false;
            errorMgs = e.getMessage();
        }
    }//end of method update client

    public void loadCases(){
        listCases = new list<Case>();
        system.debug('mapClientToCases: '+mapClientToCases);
        if(selectedClientId != null && mapClientToCases.containsKey(selectedClientId)){
            listCases =  mapClientToCases.get(selectedClientId);
        }
    }//end of method uploadCases
    public void loadPolicyClientCase(){
        searchCaseStatus = system.label.NoCaseFound+'.';
        listPolicyClientCases = new list<Case>();
        if(selectedPolicyClientId != null && mapPolicyClientToCases.containsKey(selectedPolicyClientId)){
            listPolicyClientCases = mapPolicyClientToCases.get(selectedPolicyClientId);
        }
    }//end of method loadPolicyClientCase

    public list<WrapperClientCases> getClients(){
        list<WrapperClientCases> listWrapper =new list<WrapperClientCases>();
        for (String clientId : mapClients.keySet()){
            WrapperClientCases ClientWrapper = new WrapperClientCases();
            ClientWrapper.Client = mapClients.get(clientId);
            if(mapClientToCases.get(clientId)!=null){
                ClientWrapper.Cases = mapClientToCases.get(clientId);
            }//end of if
            listWrapper.add(ClientWrapper);
        }//end of loop
        if(listWrapper.size() == 1){
            selectedClientId = listWrapper.get(0).Client.id;
            loadCases();
        }
        return listWrapper;
    }//end of method loadClientCases(String ClientId)

    public class WrapperClientCases{
        public Account Client{set;get;}
        public list<Case> Cases{set;get;}

        public WrapperClientCases(){
            Cases = new list<Case>();
        }

        public integer getNoOfCases(){
            return Cases.size();
        }
    }//end wrapper classs

    //MOSCATELLI_M 13062016:EVO 62 -- START
    public void spoolAgentCases()
    {
        if(String.isNotBlank(selectedAgentId))
        {
            listAgentCases = mapAgentToCases.get(selectedAgentId);

            if(listAgentCases != null)
            {
                if(listAgentCases.size()>0)
                    AgentCasesNum = listAgentCases.size();
            }

            system.debug('##selectedAgentId :'+selectedAgentId+' ##mapAgents: '+mapAgents);

            if(mapAgents.containsKey(selectedAgentId))
                selectedAgentName = mapAgents.get(selectedAgentId).name;
        }
        //MOSCATELLI_M 02/07/2018: Easy Azienda -- START
        else if(string.isnotblank(selectedAAIAgentId))
        {
            //listAAIAgentCases.clear();
            listAAIAgentCases = new List<Case>();
            selectedAAIAgentName='';

            if(MapAgentIdToName.containskey(selectedAAIAgentId))
                selectedAAIAgentName= MapAgentIdToName.get(selectedAAIAgentId);

            //MOSCATELLI_M 23/01/2019: NMA Enhancement V— start
            //for(Case c: [Select Id,Casenumber,subject, createddate,user__r.Name from Case where User__c=:selectedAAIAgentId AND isclosed = false order by CreatedDate DESC])
            String AgentAgency ='';

            if(AgentToAgencyMap.containskey(selectedAAIAgentId))
                AgentAgency = AgentToAgencyMap.get(selectedAAIAgentId).Agency_Code__c;

            //for(Case c: [Select Id,Casenumber,subject, createddate,user__r.Name,Lob__c,RecordType.DeveloperName, Category__c,Oggetto_apertura_case__c,Status,user__c,Agency_Code__c from Case where CreatedDate=THIS_YEAR and isclosed = false and RecordTypeId=:CaseType order by CreatedDate DESC])
			list<Case> Lc;
            if(String.isnotblank(AgentAgency) && !this.isFromSCV){
                Lc = [Select Id,Casenumber,subject, createddate,user__r.Name,Lob__c,Category__c,
                         Oggetto_apertura_case__c,Status,user__c,Agency_Code__c,
                         Owner.Name
                         from Case 
                         where isclosed = false and 
                         RecordTypeId=:CaseType and 
                         (User__c =: selectedAAIAgentId OR (Agency_Code__c =:AgentAgency AND (User__c != null AND User__c !=:selectedAAIAgentId))) order by CreatedDate DESC];
            }
            else{
                Lc = [Select Id,Casenumber,subject, createddate,user__r.Name,Lob__c,Category__c,
                         Oggetto_apertura_case__c,Status,user__c,Agency_Code__c,
                         Owner.Name
                         from Case 
                         where isclosed = false and 
                         RecordTypeId=:CaseType and 
                         User__c =: selectedAAIAgentId 
                         
                         order by CreatedDate DESC];
            }
            for(Case c : Lc)
            //MOSCATELLI_M 23/01/2019: NMA Enhancement V— end
            {
                //if((c.User__c==selectedAAIAgentId) || ((String.isnotblank(AgentAgency) && (c.Agency_Code__c==AgentAgency)) && ((String.isnotblank(c.User__c) && c.User__c != selectedAAIAgentId))))
                    listAAIAgentCases.add(c);
            }
        }
        //MOSCATELLI_M 02/07/2018: Easy Azienda -- END
    }

    public void searchExistingCase()
    {
        Integer CasenumberLength = 8;
        String Zeroes;

        //If the customer has not provided the entire number of the case, the following method makes sure that the number is composed by eigth digits

        //MOSCATELLI_M 02/11/2016: EVO 69 -- START
        List<Case> FoundCaseIdList = new List<Case>();

        if(String.isBlank(ProvidedFoundCaseID))
        {
            /*
            if(ProvidedCase.length()<8)
            {
                for(Integer i=0;i<(CasenumberLength-ProvidedCase.length());i++)
                {
                    if(Zeroes==null)
                        Zeroes='0';
                    else
                        Zeroes+='0';
                }
                ProvidedCase =Zeroes+ProvidedCase;
            }
            */
            FoundCaseIdList = [Select Id,AccountId,AgentName__r.Id,Recordtype.developername,OwnerId,ContactId,Account.IsPersonAccount,Phone_Call_Ids__c from Case where Casenumber =:ProvidedCase];
        }
        else
                FoundCaseIdList = [Select Id,AccountId,AgentName__r.Id,Recordtype.developername,OwnerId,ContactId,Account.IsPersonAccount,Phone_Call_Ids__c from Case where Id =:ProvidedFoundCaseID];
        //MOSCATELLI_M 02/11/2016: EVO 69 -- END

        //If a matching Case is found, the method verifies if it is necessary to update the information about its associated account or agent
        if(FoundCaseIdList.size()>0)
        {
            FoundCase = true;
            ExistingCaseId   = FoundCaseIdList[0].Id;
            //MOSCATELLI_M 16/02/2017: EVO-77 -- START
            //LogACallRecType = (FoundCaseIdList[0].Recordtype.developername==AP_Constants.rtCaseNonMotor)?mapTaskRT.get(AP_Constants.rtTaskNonMotor):((FoundCaseIdList[0].Recordtype.developername==AP_Constants.rtCaseMotor)?mapTaskRT.get(AP_Constants.rtTaskMotor):((FoundCaseIdList[0].Recordtype.developername==AP_Constants.rtCaseAAI)?mapTaskRT.get(AP_Constants.rtTaskAAI):mapTaskRT.get(AP_Constants.rtTaskQuadra)));
            //CAPOBIANCO_A 25/08/2017 EVO 87 -- START
            //LogACallRecType = (FoundCaseIdList[0].Recordtype.developername==AP_Constants.rtCaseNonMotor)?mapTaskRT.get(AP_Constants.rtTaskNonMotor):((FoundCaseIdList[0].Recordtype.developername==AP_Constants.rtCaseMotor)?mapTaskRT.get(AP_Constants.rtTaskMotor):((FoundCaseIdList[0].Recordtype.developername==AP_Constants.rtCaseAAI)?mapTaskRT.get(AP_Constants.rtTaskAAI):((FoundCaseIdList[0].Recordtype.developername==AP_Constants.rtCaseQuadra)?mapTaskRT.get(AP_Constants.rtTaskQuadra):mapTaskRT.get(AP_Constants.rtTaskCTL))));

            //OAVERSANO 09/01/2019 : Agenzia diretta -- START
            //LogACallRecType = (FoundCaseIdList[0].Recordtype.developername==AP_Constants.rtCaseNonMotor)?mapTaskRT.get(AP_Constants.rtTaskNonMotor):((FoundCaseIdList[0].Recordtype.developername==AP_Constants.rtCaseMotor)?mapTaskRT.get(AP_Constants.rtTaskMotor):((FoundCaseIdList[0].Recordtype.developername==AP_Constants.rtCaseAAI)?mapTaskRT.get(AP_Constants.rtTaskAAI):((FoundCaseIdList[0].Recordtype.developername==AP_Constants.rtCaseQuadra)?mapTaskRT.get(AP_Constants.rtTaskQuadra):((FoundCaseIdList[0].Recordtype.developername==AP_Constants.rtCaseAMF)?mapTaskRT.get(AP_Constants.rtTaskAMF):((FoundCaseIdList[0].Recordtype.developername==AP_Constants.rtCaseCaringAngel)?mapTaskRT.get(AP_Constants.rtTaskCaringAngel):mapTaskRT.get(AP_Constants.rtTaskCTL))))));
            LogACallRecType = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get(CaseRTtoTaskRT__c.getInstance(FoundCaseIdList[0].Recordtype.developername).Task_RT_developername__c).getRecordTypeId();
            //OAVERSANO 09/01/2019 : Agenzia diretta -- END

            //CAPOBIANCO_A 25/08/2017 EVO 87 -- END
            //MOSCATELLI_M 16/02/2017: EVO-77 -- END
            CaseOwner     = FoundCaseIdList[0].OwnerId;
            CaseContact   = FoundCaseIdList[0].ContactId;
            CaseAccount   = FoundCaseIdList[0].AccountId;
            CaseAgent     = FoundCaseIdList[0].AgentName__r.Id;
            CasePhoneCallId = FoundCaseIdList[0].Phone_Call_Ids__c;

            if(String.isNotBlank(CaseAccount))
                CaseAccountIsPerson = FoundCaseIdList[0].Account.IsPersonAccount;

            if(CaseOwner <> LoggedUser)
                LoggedUserIsCaseOwner = false;

            if(String.isNotBlank(CallIdentifier))
            {
                if(String.isNotBlank(CasePhoneCallId))
                {
                    if(!CasePhoneCallId.contains(CallIdentifier))
                    {
                        CasePhoneCallId=CasePhoneCallId+'|'+CallIdentifier;
                        UpdatePhoneCallId = true;
                    }
                }
                else
                {
                    CasePhoneCallId=CallIdentifier;
                    UpdatePhoneCallId = true;
                }
            }

            if(UpdatePhoneCallId)
                CaseToUpdate = new Case(Id=ExistingCaseId,Phone_Call_Ids__c=CasePhoneCallId);
            else
                    CaseToUpdate = new Case(Id=ExistingCaseId);

            if(CallerIsCustomer)
            {
                if(String.isBlank(CaseAccount) && mapClients.size()==1)
                {
                    for(String IdAccount: mapClients.keySet())
                    {
                        FoundAccount = mapClients.get(IdAccount).Id;
                        CaseAccountIsPerson = mapClients.get(IdAccount).IsPersonAccount;
                    }

                    CaseToUpdate.AccountId = FoundAccount;
                }
            }
            else
            {
                if(String.isBlank(CaseAgent) && listAgents.size()==1)
                {
                    CaseToUpdate.AgentName__c = listAgents[0].id;
                    CallerAgentFound = true;
                }
            }

            if(CallerAgentFound || String.isNotBlank(FoundAccount) || UpdatePhoneCallId)
                Updatecase = true;
        }
        else
        {
            //If a matching case is not found, an error is shown to the CRM user
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info, system.label.VFP06_SearchedCaseNotFound+' '+ProvidedCase);
            ApexPages.addMessage(myMsg);
        }
    }

    public pagereference AllowDMLforMethods()
    {
        setAgentPhone();

        if(FoundCase)
        {
            if(UpdatePhoneCallId)
                CreatePhoneHistoricization();

            TraceLogACall();
        }

        //If the Case provided by the customer is found, it is directly shown to the CRM user
        if(String.isNotBlank(ExistingCaseId))
        {
            String hostname = ApexPages.currentPage().getHeaders().get('Host');
            String redirectToURL = 'https://'+hostname+'/'+ExistingCaseId;
            pagereference pageref = new pagereference(redirectToURL);
            pageref.setredirect(true);
            return pageref;
        }
        else
                return null;
    }

    public pagereference AddPhoneCallId()
    {
        List<Case> SelectedCaseList = new list<Case>([Select id,Phone_Call_Ids__c,OwnerId,AccountId,AgentName__r.Id,Recordtype.developername,ContactId,Account.IsPersonAccount from Case where id=:selectedCaseId]);
        String FoundPhoneId = SelectedCaseList[0].Phone_Call_Ids__c;

        CaseOwner     = SelectedCaseList[0].OwnerId;
        CaseAccount   = SelectedCaseList[0].AccountId;
        CaseAgent     = SelectedCaseList[0].AgentName__r.Id;
        CaseContactId   = SelectedCaseList[0].ContactId;
        ExistingCaseId   = selectedCaseId;

        if(CaseOwner <> LoggedUser)
            LoggedUserIsCaseOwner = false;

        //MOSCATELLI_M 16/02/2017: EVO 77--START
        //LogACallRecType = (SelectedCaseList[0].Recordtype.developername==AP_Constants.rtCaseNonMotor)?mapTaskRT.get(AP_Constants.rtTaskNonMotor):((SelectedCaseList[0].Recordtype.developername==AP_Constants.rtCaseMotor)?mapTaskRT.get(AP_Constants.rtTaskMotor):((SelectedCaseList[0].Recordtype.developername==AP_Constants.rtCaseAAI)?mapTaskRT.get(AP_Constants.rtTaskAAI):mapTaskRT.get(AP_Constants.rtTaskQuadra)));
        //CAPOBIANCO_A 25/08/2017 EVO 87 -- START
        //LogACallRecType = (SelectedCaseList[0].Recordtype.developername==AP_Constants.rtCaseNonMotor)?mapTaskRT.get(AP_Constants.rtTaskNonMotor):((SelectedCaseList[0].Recordtype.developername==AP_Constants.rtCaseMotor)?mapTaskRT.get(AP_Constants.rtTaskMotor):((SelectedCaseList[0].Recordtype.developername==AP_Constants.rtCaseAAI)?mapTaskRT.get(AP_Constants.rtTaskAAI):((SelectedCaseList[0].Recordtype.developername==AP_Constants.rtCaseQuadra)?mapTaskRT.get(AP_Constants.rtTaskQuadra):mapTaskRT.get(AP_Constants.rtTaskCTL))));
        //LogACallRecType = (SelectedCaseList[0].Recordtype.developername==AP_Constants.rtCaseNonMotor)?mapTaskRT.get(AP_Constants.rtTaskNonMotor):((SelectedCaseList[0].Recordtype.developername==AP_Constants.rtCaseMotor)?mapTaskRT.get(AP_Constants.rtTaskMotor):((SelectedCaseList[0].Recordtype.developername==AP_Constants.rtCaseAAI)?mapTaskRT.get(AP_Constants.rtTaskAAI):((SelectedCaseList[0].Recordtype.developername==AP_Constants.rtCaseQuadra)?mapTaskRT.get(AP_Constants.rtTaskQuadra):((SelectedCaseList[0].Recordtype.developername==AP_Constants.rtCaseAMF)?mapTaskRT.get(AP_Constants.rtTaskAMF):mapTaskRT.get(AP_Constants.rtTaskCTL)))));
        LogACallRecType = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get(CaseRTtoTaskRT__c.getInstance(SelectedCaseList[0].Recordtype.developername).Task_RT_developername__c).getRecordTypeId();
        system.debug('@@LogACallRecType: '+LogACallRecType);
        //LogACallRecType = (SelectedCaseList[0].Recordtype.developername==AP_Constants.rtCaseNonMotor)?mapTaskRT.get(AP_Constants.rtTaskNonMotor):((SelectedCaseList[0].Recordtype.developername==AP_Constants.rtCaseMotor)?mapTaskRT.get(AP_Constants.rtTaskMotor):((SelectedCaseList[0].Recordtype.developername==AP_Constants.rtCaseAAI)?mapTaskRT.get(AP_Constants.rtTaskAAI):((SelectedCaseList[0].Recordtype.developername==AP_Constants.rtCaseQuadra)?mapTaskRT.get(AP_Constants.rtTaskQuadra):((SelectedCaseList[0].Recordtype.developername==AP_Constants.rtCaseAMF)?mapTaskRT.get(AP_Constants.rtTaskAMF):((SelectedCaseList[0].Recordtype.developername==AP_Constants.rtCaseBuonLavoro)?mapTaskRT.get(AP_Constants.rtTaskBuonLavoro):mapTaskRT.get(AP_Constants.rtTaskCTL))))));
        //CAPOBIANCO_A 25/08/2017 EVO 87 -- START
        //MOSCATELLI_M 16/02/2017: EVO 77--START


        if(SelectedCaseList[0].Account <> null)
            CaseAccountIsPerson = SelectedCaseList[0].Account.IsPersonAccount;

        Case UpdateCase = new case(id=selectedCaseId);

        if(String.isNotBlank(CallIdentifier))
        {
            if(String.isNotBlank(FoundPhoneId))
            {
                if(!FoundPhoneId.contains(CallIdentifier))
                {
                    UpdateCase.Phone_Call_Ids__c=FoundPhoneId+'|'+CallIdentifier;
                    UpdatePhoneCallId = true;
                }
            }
            else
            {
                UpdateCase.Phone_Call_Ids__c=CallIdentifier;
                UpdatePhoneCallId = true;
            }

            if(String.isNotBlank(UpdateCase.Phone_Call_Ids__c) && UpdatePhoneCallId)
                upsert UpdateCase;
        }

        if(UpdatePhoneCallId)
            CreatePhoneHistoricization();

        TraceLogACall();
        /*
         String hostname = ApexPages.currentPage().getHeaders().get('Host');
         String redirectToURL = 'https://'+hostname+'/'+selectedCaseId;
         pagereference pageref = new pagereference(redirectToURL);
         pageref.setredirect(true);
         return pageref;     */
        return null;
    }

    public void TraceLogACall()
    {
        //Boolean EmailtoOwner = (LoggedUserIsCaseOwner==true)?false:true;

        //OAVERSANO 10/02/2019 : Agenzia diretta -- START
        //Boolean EmailtoOwner = (LoggedUserIsCaseOwner==false && (LogACallRecType==mapTaskRT.get(AP_Constants.rtTaskMotor) || LogACallRecType==mapTaskRT.get(AP_Constants.rtTaskAAI) || LogACallRecType==mapTaskRT.get(AP_Constants.rtTaskAMF) ))?true:false; //CAPOBIANCO_A 04_09_2017 EVO 87: AMF - Added the sending of the email for the AMF Cases too
        Boolean EmailtoOwner = (LoggedUserIsCaseOwner==false && (LogACallRecType==mapTaskRT.get(AP_Constants.rtTaskMotor) || LogACallRecType==mapTaskRT.get(AP_Constants.rtTaskAAI) || LogACallRecType==mapTaskRT.get(AP_Constants.rtTaskAMF) || LogACallRecType==mapTaskRT.get(AP_Constants.rtTaskAgenziaDipendenti) ))?true:false;
        //OAVERSANO 10/02/2019 : Agenzia diretta -- END

        if(Updatecase)
            Upsert CaseToUpdate;

        String AssocTaskToAccnt;
        Task LogACall;
        Id AssocTascToContact;

        if(!CallerIsCustomer)
        {
            if(String.isNotBlank(selectedAgentId))
            {
                CaseAccountIsPerson = true;
                AssocTaskToAccnt = selectedAgentId;
            }
        }
        else
        {
            if(mapClients.size()==1)
            {
                for(String IdmapClients: mapClients.keySet())
                {
                    AssocTaskToAccnt = mapClients.get(IdmapClients).Id;
                    CaseAccountIsPerson = mapClients.get(IdmapClients).IsPersonAccount;
                }
            }
            else if(mapPolicyClients.size()==1)
            {
                for(String IdmapPolicyClients: mapPolicyClients.keySet())
                {
                    AssocTaskToAccnt = mapPolicyClients.get(IdmapPolicyClients).Id;
                    CaseAccountIsPerson = mapPolicyClients.get(IdmapPolicyClients).IsPersonAccount;
                }
            }
            else if(String.isNotBlank(selectedClientId))
            {
                AssocTaskToAccnt = selectedClientId;

                if(mapClients.containsKey(selectedClientId))
                    CaseAccountIsPerson = mapClients.get(selectedClientId).IsPersonAccount;
            }
            else if(String.isNotBlank(selectedPolicyClientId))
            {
                AssocTaskToAccnt = selectedPolicyClientId;

                if(mapPolicyClients.containsKey(selectedPolicyClientId))
                    CaseAccountIsPerson = mapPolicyClients.get(selectedPolicyClientId).IsPersonAccount;
            }
        }

        if(String.isNotBlank(AssocTaskToAccnt) && CaseAccountIsPerson)
            CaseContactId = [Select Id from Contact where AccountId=:AssocTaskToAccnt].Id;

        if(String.isNotBlank(CaseContactId))
            LogACall = new Task(RecordTypeId=LogACallRecType,Subject='Call',WhatId=ExistingCaseId,Status='Completed',Send_email_to_case_owner__c=EmailtoOwner,Call__c=true,whoid=CaseContactId);
        else
                LogACall = new Task(RecordTypeId=LogACallRecType,Subject='Call',WhatId=ExistingCaseId,Status='Completed',Send_email_to_case_owner__c=EmailtoOwner,Call__c=true);

        insert LogACall;
    }

    public void CreatePhoneHistoricization()
    {
        Id CallerId;
        Id AgentId;//MOSCATELLI_M 03/07/2018: Easy Azienda

        if(!CallerIsCustomer)
        {
            if(String.isNotBlank(selectedAgentId))
                CallerId = selectedAgentId;

            //MOSCATELLI_M 03/07/2018: Easy Azienda -- START
            else if(String.isnotblank(selectedAAIAgentId))
                AgentId = selectedAAIAgentId;
            //MOSCATELLI_M 03/07/2018: Easy Azienda -- END
        }
        else
        {
            if(mapClients.size()==1)
            {
                for(String IdmapClients: mapClients.keySet())
                {
                    CallerId = mapClients.get(IdmapClients).Id;
                }
            }
            else if(mapPolicyClients.size()==1)
            {
                for(String IdmapPolicyClients: mapPolicyClients.keySet())
                {
                    CallerId = mapPolicyClients.get(IdmapPolicyClients).Id;
                }
            }
            else if(String.isNotBlank(selectedClientId))
                CallerId = selectedClientId;
            else if(String.isNotBlank(selectedPolicyClientId))
                CallerId = selectedPolicyClientId;
        }

        Storico_Chiamate__c Storicocall;

        if(String.isNotBlank(CallerId))
            //Storicocall = new Storico_Chiamate__c(Case__c=ExistingCaseId,Call_ID__c=CallIdentifier,Phone_Call_Time__c=system.now(),Customer__c=CallerId);
            Storicocall = new Storico_Chiamate__c(Case__c=ExistingCaseId,Call_ID__c=CallIdentifier,Phone_Call_Time__c=system.now(),Customer__c=CallerId,CallDateTime__c=CallDateTime,PhoneCallIDB__c=PhoneCallIDB);//MOSCATELLI_M 01/03/2018: Accesso a registrazioni audio - Added calldatetime,PhoneCallIDB
        //MOSCATELLI_M 03/07/2018: Easy Azienda -- START
        else if(String.isNotBlank(AgentId))
            //Storicocall = new Storico_Chiamate__c(Case__c=ExistingCaseId,Call_ID__c=CallIdentifier,Phone_Call_Time__c=system.now(),Agente__c=AgentId);
            Storicocall = new Storico_Chiamate__c(Case__c=ExistingCaseId,Call_ID__c=CallIdentifier,Phone_Call_Time__c=system.now(),Agente__c=AgentId,CallDateTime__c=CallDateTime,PhoneCallIDB__c=PhoneCallIDB);//MOSCATELLI_M 01/03/2018: Accesso a registrazioni audio - Added calldatetime,PhoneCallIDB
        //MOSCATELLI_M 03/07/2018: Easy Azienda -- END
        else
                //Storicocall = new Storico_Chiamate__c(Case__c=ExistingCaseId,Call_ID__c=CallIdentifier,Phone_Call_Time__c=system.now());
                Storicocall = new Storico_Chiamate__c(Case__c=ExistingCaseId,Call_ID__c=CallIdentifier,Phone_Call_Time__c=system.now(),CallDateTime__c=CallDateTime,PhoneCallIDB__c=PhoneCallIDB);//MOSCATELLI_M 01/03/2018: Accesso a registrazioni audio - Added calldatetime,PhoneCallIDB

        insert Storicocall; // NOPMD  Fix CRUD violation
    }
    //MOSCATELLI_M 13062016:EVO 62 -- END

    //MOSCATELLI_M 15/07/2016: EVO 65 -- START
    public void CreateLightCase()
    {
        system.debug('##LightAccntId: '+selectedClientId+', '+selectedAgentId);
        try
        {
            String ComplainantType = (UrlParameterMap.get('caller') == 'gestore')?AP_Constants.rtCaseAgentComp:AP_Constants.rtCaseCustComp;

            //D.F. bugFix 11-08-2016. The Category should be unescaped, for example to replace '+' with actual spaces
            system.debug('+++input category-->'+paramCategory);
            string correctedCategory = '';

            if (String.isNotBlank(paramCategory)) {
                correctedCategory = EncodingUtil.urlDecode(paramCategory, 'UTF-8');
            }

            system.debug('+++decoded category-->'+correctedCategory);
            // Case CaseLight = new Case(RecordTypeId=CaseType, Status = AP_Constants.caseStatusOutOfTime, Origin=AP_Constants.caseOriginPhone, Complainant__c=ComplainantType ,Distribution_Network__c=Distribution,Category__c=paramCategory,Phone_Call_Ids__c=CallIdentifier,IsCaseLight__c=true);
            Case CaseLight = new Case(RecordTypeId=CaseType, Status = AP_Constants.caseStatusOutOfTime, Origin=AP_Constants.caseOriginPhone, Complainant__c=ComplainantType ,Distribution_Network__c=Distribution,Category__c=correctedCategory,Phone_Call_Ids__c=CallIdentifier,IsCaseLight__c=true);
            //D.F. 11-08-2016 End bugfix

            Id AssociatedAccnt;

            if(String.isNotBlank(selectedClientId))
            {
                CaseLight.AccountId = selectedClientId;

                if(String.isBlank(CreateCaseLightAccounts))
                    CreateCaseLightAccounts = selectedClientId;
                else
                        CreateCaseLightAccounts += ' ,'+selectedClientId;
            }

            if(String.isNotBlank(selectedAgentId))
            {
                CaseLight.AgentName__c = selectedAgentId;

                if(String.isBlank(CreateCaseLightAccounts))
                    CreateCaseLightAccounts = selectedAgentId;
                else
                        CreateCaseLightAccounts += ' ,'+selectedAgentId;
            }

            upsert CaseLight;
            CreateCaseLight = false;

            system.debug('CreateCaseLightAccounts: '+CreateCaseLightAccounts);

            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info, system.label.VFC06_CaseLightCreated);
            ApexPages.addMessage(myMsg);
        }
        catch(Exception e )
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, system.label.VFC06_CaseLightNotCreated);
            ApexPages.addMessage(myMsg);
        }
    }

    public void closePopup()
    {
        displayPopup = false;
    }
    //MOSCATELLI_M 15/07/2016: EVO 65 -- END

    //MOSCATELLI_M 02/07/2018: Easy Azienda -- START
    public void SearchAAIAgents()
    {
        system.debug('@@searchAgencyCode: '+searchAgencyCode);
        system.debug('@@searchAgencyName: '+searchAgencyName);
        system.debug('@@searchAgencyLastname: '+searchAgencyLastname);

        List<Account> AgenciesList = new List<Account>();
        Map<String,Account> AgencyDataMap = new Map<String,Account>();
        MapAgentIdToName.clear();

        AgenciesList = [SELECT Id, Agency_Code__c,Name,Active__c FROM Account WHERE RecordType.Developername = 'Agency' AND Active__c = true ]; // NOPMD  Fix CRUD violation

        for(Account a: AgenciesList)
        {
            AgencyDataMap.put(a.Agency_Code__c,a);
        }

        String query;
        if(this.isFromSCV) 
            query = 'SELECT Id, Name, FirstName, LastName, CommunityNickname, isActive, Contact.Account.Active__c,Contact.Account.Agency_Code__c,Email FROM User where profile.name like \'NFE - AAI - Vendite%\' ';
        else
            query = 'SELECT Id, Name, FirstName, LastName, CommunityNickname, isActive, Contact.Account.Active__c,Contact.Account.Agency_Code__c,Email FROM User where profile.name not in (\'System Administrator\')';
        Boolean firstArgument = true;

        AgentList.clear();

        if(String.isBlank(ProvidedFoundAgentID))
        {
            if(!(String.isblank(searchAgencyCode) && String.isblank(searchAgencyName) && String.isblank(searchAgencyLastname) && String.isblank(searchAgentCommunityId)))
            {
                if(searchAgencyCode != null && searchAgencyCode != '')
                {
                    query = query + ' and Contact.Account.Agency_Code__c ='+'\''+searchAgencyCode+'\' ';
                    firstArgument = false;
                }

                if(searchAgencyName != null && searchAgencyName != '')
                {
                    if(firstArgument)
                    {
                        query = query + ' and FirstName ='+'\''+searchAgencyName+'\' ';
                        firstArgument = false;
                    }
                    else
                    {
                        query = query + ' AND FirstName ='+'\''+searchAgencyName+'\' ';
                    }
                }
                if(searchAgencyLastname != null && searchAgencyLastname != '')
                {
                    if(firstArgument)
                    {
                        query = query + ' and LastName ='+'\''+searchAgencyLastname+'\' ';
                        firstArgument = false;
                    }
                    else
                    {
                        query = query + ' AND LastName ='+'\''+searchAgencyLastname+'\' ';
                    }
                }
                if(searchAgentCommunityId!= null && searchAgentCommunityId !='')
                {
                    if(searchAgentCommunityId.isNumeric())
                    {
                        if(searchAgentCommunityId.length()>4)
                            searchAgentCommunityId = 'AG'+searchAgentCommunityId.substring(0,4)+'A'+searchAgentCommunityId.substring(4);
                        else
                                searchAgentCommunityId = 'AG'+searchAgentCommunityId;
                    }


                    if(firstArgument)
                    {
                        query = query + ' and CommunityNickname ='+'\''+searchAgentCommunityId+'\' ';
                        firstArgument = false;
                    }
                    else
                    {
                        query = query + ' AND CommunityNickname ='+'\''+searchAgentCommunityId+'\' ';
                    }
                }
            }
            else
            {   if(ApexPages.currentPage()!= null){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, system.label.vfc06_NoAgentsInputs);
                ApexPages.addMessage(myMsg);}
                return;
            }
        }
        else
                query = query + 'AND Id ='+ProvidedFoundAgentID;

        System.debug(': ' + query);

        try
        {
            AgentList = Database.query(query);
        }
        catch(Exception ex)
        {
            System.debug('Error: ' + ex.getMessage());
        }

        if(AgentList.size()==0 && ApexPages.currentPage()!= null)
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info, system.label.vfc06_NoAgents);
            ApexPages.addMessage(myMsg);
            return;
        }
        else
        {
            for(User u:AgentList)
            {
                MapAgentIdToName.put(u.id,u.name);
                AgentToAgencyMap.put(u.id,AgencyDataMap.get(u.Contact.Account.Agency_Code__c));
            }

            if(AgentList.size()==1)
            {
                selectedAAIAgentId = AgentList[0].id;
                spoolAgentCases();
            }
        }

        System.debug('Size result: ' + AgentList.size());
    }

    public integer getNoOfAAIAgents()
    {
        system.debug('ds: '+AgentList.size());
        return AgentList.size();
    }

    public integer getNoOflistAAIAgentCases()
    {
        return listAAIAgentCases.size();
    }

    public void SearchAAIAgentsbyPhone()
    {
        String PhonePrefix = (String.valueOf(paramPhone.TRIM())).left(4);
        String Queryphone = 'Select Id, Name, FirstName, LastName, CommunityNickname, isActive, Contact.Account.Active__c,Contact.Account.Agency_Code__c from User where (MobilePhone!=\'\' or Phone!=\'\')';
        List<Account> AgenciesList = new List<Account>();
        Map<String,Account> AgencyDataMap = new Map<String,Account>();
        MapAgentIdToName.clear();

        if(PhonePrefix=='0039')
        {
            Queryphone = Queryphone+' and (MobilePhone like \'%39'+paramPhone.substring(4)+'\''+ 'or phone like \'%39'+paramPhone.substring(4)+'\''+' or Phone ='+'\''+paramPhone.substring(4)+'\''+' or MobilePhone='+'\''+paramPhone.substring(4)+'\''+' or Phone ='+'\''+paramPhone+'\''+' or MobilePhone='+'\''+paramPhone+'\''+' or Phone ='+'\''+'0'+paramPhone+'\''+' or MobilePhone='+'\''+'0'+paramPhone+'\''+')';
        }
        else
                Queryphone = Queryphone+' and (MobilePhone like \'%39'+paramPhone+'\''+' or phone like \'%39'+paramPhone+'\''+' or Phone ='+'\''+'0039'+paramPhone+'\''+' or MobilePhone='+'\''+'0039'+paramPhone+'\''+' or Phone ='+'\''+'0'+paramPhone+'\''+' or MobilePhone='+'\''+'0'+paramPhone+'\''+' or Phone ='+'\''+paramPhone+'\''+' or MobilePhone='+'\''+paramPhone+'\''+')';

        system.debug('@@Queryphone: '+Queryphone);
        try
        {
            AgentList = Database.query(Queryphone);
        }

        catch(Exception ex)
        {
            System.debug('Error: ' + ex.getMessage());
        }
        system.debug('@@AgentList: '+AgentList);

        AgenciesList = [SELECT Id, Agency_Code__c,Name,Active__c FROM Account WHERE RecordType.Developername = 'Agency' AND Active__c = true ]; // NOPMD  Fix CRUD violation

        for(Account a: AgenciesList)
        {
            AgencyDataMap.put(a.Agency_Code__c,a);
        }

        if(AgentList.size()>0)
        {
            for(User u:AgentList)
            {
                MapAgentIdToName.put(u.id,u.name);
                AgentToAgencyMap.put(u.id,AgencyDataMap.get(u.Contact.Account.Agency_Code__c));
            }

            if(AgentList.size()==1)
            {
                selectedAAIAgentId = AgentList[0].id;
                spoolAgentCases();
            }
        }
        else
        {
            if(ApexPages.currentPage()!= null){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info, system.label.vfc06_AgentNotRecognized);
                ApexPages.addMessage(myMsg);}
            return;
        }
    }
    //MOSCATELLI_M 02/07/2018: Easy Azienda -- END

    //MOSCATELLI_M 13/02/2018: Aggiornamento gestori -- START
    public Pagereference SearchAgent()
    {
        if(String.IsBlank(client.FirstName)
                && String.IsBlank(client.lastname)
                && String.IsBlank(client.Matricola__c))
        {
            Apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Info,system.label.VFP08_FillSearch);
            Apexpages.addmessage(msg);

            return null;
        }
        else
        {
            String query = 'id where ';
            String toFind = '';

            query+= ' recordtypeId = '+'\''+rtAccountIntermediary+'\'';

            if(String.IsNotBlank(client.FirstName))
            {
                String firstname = (client.FirstName).escapeJava();

                if(firstname.contains('\''))
                    firstname = firstname.replace('\'','\\'+'\'');

                query+= ' AND firstname like \'%'+firstname+'%\' ';
                toFind = firstname;
            }
            if(String.IsNotBlank(client.lastname) )
            {
                String lastname = (client.lastname).escapeJava();

                if(lastname.contains('\''))
                    lastname = lastname.replace('\'','\\'+'\'');

                query+= ' AND lastname like \'%'+lastname+'%\' ';

                if(String.isNotBlank(toFind))
                    toFind += ' AND '+lastname;
                else
                        toFind = lastname;
            }

            if(String.IsNotBlank(client.Matricola__c))
            {
                query+= ' AND Matricola__c = \''+(client.Matricola__c).escapeJava()+'\' ';

                if(String.isNotBlank(toFind))
                    toFind += ' AND '+(client.Matricola__c).escapeJava();
                else
                        toFind = (client.Matricola__c).escapeJava();
            }


            String [] SpecialChar = new String[]{'&#124;', '&','|','!','{','}','[',']','(',')','^','~', '*', ':','"','+','-'};

            for(String s: SpecialChar)
            {
                if(toFind.contains(s))
                {
                    toFind= toFind.replace(s,'\\'+s);
                    system.debug('\\'+s);
                }
            }

            String searchs ='FIND {'+toFind+'} IN ALL FIELDS RETURNING ACCOUNT('+query+')';
            system.debug('@@searchs: '+searchs);

            List<List<SObject>> ListAccounts = search.query(searchs);
            List<Account> ListAccountsQuery = new list<Account>();
            ListAccountsQuery = ((List<Account>)ListAccounts[0]);

            for(Account acc: [Select id, name, TECH_Flag__c, AAI_Codice_fiscale__c, AAI_Partita_IVA__c, RecordType.Name, RecordType.Developername, Additional_Email__c, personemail, Partita_IVA__c, Account_email__c, phone, lastname, IsPersonAccount,firstname,Fiscal_ID__c,Matricola__c,Codice_Fiscale_AAF__c,TECH_Company__c,State__c,AAI_Agency__r.Name from Account where id in:ListAccountsQuery and RecordType.Name = 'Intermediary'])
            {
                acc.Tech_Flag__c = false;
                listAgents.add(acc);
            }

            if(listAgents.size()==0)
                AgentSearchedNotFound = true;
            else
                    mapAgents = new map<Id,Account>(listAgents);

            if(listAgents.size()==1)
            {
                selectedAgentId=listAgents[0].id;

                for(Case caseRecord :[  select  subject ,accountId , account.Name ,Description,Complainant__c,Origin,CaseNumber,CreatedDate,AgentName__r.id
                from    Case
                where   AgentName__c =:selectedAgentId
                AND isclosed = false
                order by CreatedDate DESC ])
                {
                    if(!mapAgentToCases.containsKey(caseRecord.AgentName__r.id))
                        mapAgentToCases.put(caseRecord.AgentName__r.id ,new list<Case>{caseRecord});
                    else
                            mapAgentToCases.get(caseRecord.AgentName__r.id).add(caseRecord);
                }


                selectedAgentName  = listAgents[0].name;
                selectedAgentPhone  = listAgents[0].Phone;
                InactiveBankAgent=(listAgents[0].State__c==AP_Constants.stAccInActiveBank)?true:false;

                if(mapAgentToCases.size()>0)
                    spoolAgentCases();
            }

            system.debug('##listAgents: '+listAgents);
        }

        return null;
    }
    //MOSCATELLI_M 13/02/2018: Aggiornamento gestori -- END

    //OAVERSANO 15/10/2018 : Caring Angel -- START
    public void creaCaringAngelCase()
    {
        system.debug('creaCaringAngelCase method');
        Case caseToInsert = new Case();
        caseToInsert.Origin = AP_Constants.caseOriginPhone;
        //MOSCATELLI_M 13/03/2019: Axa Assistance -- START
        //caseToInsert.Complainant__c = 'Customer';
        caseToInsert.Complainant__c = CallerType;
        caseToInsert.RecordTypeId = CaseType;
        //caseToInsert.RecordTypeId =  Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(AP_Constants.rtCaseCaringAngel).getRecordTypeId();
        //MOSCATELLI_M 13/03/2019: Axa Assistance -- END
        caseToInsert.Status = AP_Constants.caseStatusAssigned;
        if(String.isNotBlank(selectedClientId))
        {
            caseToInsert.AccountId = selectedClientId;
            List<Account> accList = [SELECT Id, CIF_Personalemail__c, CIF_PersonEmail__c, RecordType.Name,Personemail, Account_Email__c,AAI_Agency__r.Name FROM Account WHERE id =:selectedClientId LIMIT 1];
            if(!accList.isEmpty())
            {
                Account acc = accList[0];

                if(acc.RecordType.Name == 'Individual' || acc.RecordType.Name == 'B2C Client')
                {
                    caseToInsert.Account_Email__c = (acc.RecordType.Name == 'Individual')?acc.Personemail:acc.CIF_PersonEmail__c;
                }
                else if(acc.RecordType.Name == 'Corporate' || acc.RecordType.Name == 'B2B Client')
                {
                    caseToInsert.Account_Email__c = (acc.RecordType.Name == 'Corporate')?acc.Account_Email__c:acc.CIF_Personalemail__c;
                }
            }
        }


        if(String.isNotBlank(lob))
        {
            caseToInsert.LOB__c = EncodingUtil.urlDecode(lob, 'UTF-8');
        }
        if(String.isNotBlank(paramCategory))
        {
            caseToInsert.Category__c = EncodingUtil.urlDecode(paramCategory, 'UTF-8');
        }
        if(String.isNotBlank(paramSubCategory))
        {
            caseToInsert.SubCategory__c = (paramSubCategory<>'0')?EncodingUtil.urlDecode(paramSubCategory, 'UTF-8'):'';
        }


        //OAVERSANO 17/05/2019 : AXA Assistance Enhancement Fase I -- START
        String LOBSinitri = '';
        String CategoryOpening = '';
        Boolean overwriteCategory = false;
        if(MPS_Code_Variables__c.getValues('prepopulatedLOBSinistri')!=null)
        {
            if(String.isNotBlank(MPS_Code_Variables__c.getValues('prepopulatedLOBSinistri').value__c))
            {
                LOBSinitri = MPS_Code_Variables__c.getValues('prepopulatedLOBSinistri').value__c;
            }
        }
        if(MPS_Code_Variables__c.getValues('populateCategoryAfterSTORM')!=null)
        {
            if(String.isNotBlank(MPS_Code_Variables__c.getValues('populateCategoryAfterSTORM').value__c) && MPS_Code_Variables__c.getValues('populateCategoryAfterSTORM').value__c == 'true')
            {
                overwriteCategory = true;
            }
        }
        if(MPS_Code_Variables__c.getValues('prepopulatedCategoryOpening')!=null)
        {
            if(String.isNotBlank(MPS_Code_Variables__c.getValues('prepopulatedCategoryOpening').value__c))
            {
                CategoryOpening = MPS_Code_Variables__c.getValues('prepopulatedCategoryOpening').value__c;
            }
        }
        List<String> recordTypeSinistri = new List<String>();
        if(MPS_Code_Variables__c.getValues('RecordTypeSinistriLabel')!=null)
        {
            if(String.isNotBlank(MPS_Code_Variables__c.getValues('RecordTypeSinistriLabel').value__c))
            {
                for(String s:(MPS_Code_Variables__c.getValues('RecordTypeSinistriLabel').value__c).split(';'))
                {
                    recordTypeSinistri.add(s);
                }
            }
        }
        if(overwriteCategory && recordTypeSinistri.contains(Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById().get(CaseType).getName()))
        {
            if(String.isNotBlank(LOBSinitri))
                caseToInsert.LOB__c= LOBSinitri;
            if(String.isNotBlank(CategoryOpening))
                caseToInsert.Category__c= CategoryOpening;
        }
        //OAVERSANO 17/05/2019 : AXA Assistance Enhancement Fase I -- END

        if(String.isNotBlank(CallIdentifier))
        {
            //MOSCATELLI_M 01/03/2018: Accesso a registrazioni audio -- START
            if(String.isblank(CallDateTime))
                caseToInsert.Phone_Call_Ids__c = CallIdentifier;
            else
            {
                if(String.isNotBlank(PhoneCallIDB))
                    caseToInsert.Phone_Call_Ids__c = CallIdentifier+'_'+CallDateTime+'_'+PhoneCallIDB;
                else
                        caseToInsert.Phone_Call_Ids__c = CallIdentifier+'_'+CallDateTime;
            }
            //MOSCATELLI_M 01/03/2018: Accesso a registrazioni audio -- END
        }

        try
        {
            //insert caseToInsert;
            List<Case> caseToInsertList = new List<Case>();
            caseToInsertList.add(caseToInsert);

            Database.SaveResult[] srList = Database.insert(caseToInsertList, false);

            for (Database.SaveResult sr : srList)
            {
                if (sr.isSuccess())
                {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully inserted case. Case ID: ' + sr.getId());
                    CaringAngelCaseId = sr.getId();
                    //OAVERSANO 16/05/2019 : AXA Assistance Enhancement Fase I -- START
                    Case currentCase = [SELECT Id, CaseNumber FROM Case WHERE Id =:sr.getId()];
                    currentCaseNumber = currentCase.CaseNumber;
                    //OAVERSANO 16/05/2019 : AXA Assistance Enhancement Fase I -- END
                }
            }

        }
        catch(exception ex)
        {
            system.debug(ex);
        }
    }
    //OAVERSANO 15/10/2018 : Caring Angel -- END
 
}//end of controller