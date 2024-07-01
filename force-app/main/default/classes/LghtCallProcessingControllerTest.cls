@isTest
class LghtCallProcessingControllerTest {
    
    @TestSetup
    static void makeData(){
        ServiceUtilsClass.populateCustomSettingsForTests();
        Id recordtypeId = [Select Id from Recordtype Where Name = 'Intermediary' and sObjecttype='Account'].Id;
        Id caseRecordtypeId = [Select Id from Recordtype Where Name = 'Motor' and sObjecttype='Case'].Id;
        Account account = new Account(FirstName = 'Test',
            LastName = 'Test',
            Matricola__c = '123',
            Phone = '999',
            RecordtypeId = recordtypeId);
        insert account;
        Case aCase = new Case(
            AccountId = account.Id,
            RecordtypeId = caseRecordtypeId);
        insert aCase;
    }

    @isTest
    public static void testInitGestori(){
        Test.startTest();
        Map<String, String> params = new Map<String, String>();
        Account account = [SELECT Id, FirstName, LastName, Matricola__c, Phone from Account LIMIT 1];
        params.put('AgentId', account.Id);
        params.put('RecordType', 'Motor');
        LghtCallProcessingController.initGestori(params);
        params = new Map<String, String>();
        params.put('Agentcode', account.Matricola__c);
        params.put('RecordType', 'Motor');
        LghtCallProcessingController.initGestori(params);
        Test.stopTest();
    }

    @isTest
    public static void testInitGestoriKO(){
        Test.startTest();
        try{
            LghtCallProcessingController.initGestori(null);
        } catch(Exception ex){
            System.debug(ex.getStackTraceString());
        }
        Test.stopTest();
    }

    @isTest 
    public static void testSearchGestori(){
        Test.startTest();
        Map<String, String> params = new Map<String, String>();
        Account account = [SELECT Id, FirstName, LastName, Matricola__c, Phone from Account LIMIT 1];
        params.put('firstNameSearch', account.FirstName);
        params.put('lastNameSearch', account.LastName);
        params.put('matricolaSearch', account.Matricola__c);
        params.put('RecordType', 'Motor');
        LghtCallProcessingController.searchGestori(params);
        params = new Map<String, String>();
        params.put('Phone', account.Phone);
        LghtCallProcessingController.initGestori(params);
        //davide pagano
        LghtCallProcessingController.initAgency(params);
        LghtCallProcessingController.init(params);
        LghtCallProcessingController.initDealer(params);
        LghtCallProcessingController.createCase(params,String.valueOf(account.id));
        LghtCallProcessingController.searchAgent(params,params);
        LghtCallProcessingController.search(params,params);
        
        Test.stopTest();
    }

    @isTest
    public static void testSearchGestoriKO(){
        Test.startTest();
        try{
            LghtCallProcessingController.searchGestori(null);
        } catch(Exception ex){
            System.debug(ex.getStackTraceString());
        }
        Test.stopTest();
    }

    @isTest
    public static void Coverage(){

        Id recordtypeId = [Select Id, DeveloperName from Recordtype Where Name = 'Intermediary' and sObjecttype='Account'].Id;
        RecordType caseRecordtype = [Select Id, DeveloperName from Recordtype Where Name = 'Motor' and sObjecttype='Case' limit 1];
        Account account = new Account(FirstName = 'TestCov',
            LastName = 'TestCov',
            Matricola__c = '456',
            Phone = '333',
            RecordtypeId = recordtypeId);
        insert account;
        Case aCase = new Case(
            AccountId = account.Id,
            Partner_Code__c='0909',
            AgentName__c=account.id,
            RecordtypeId = caseRecordtype.Id);
        insert aCase;
        List<Case> cs= new List<Case>();
        cs.add(aCase);
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('key','value'));

        Map<String,String> params= new Map<String,String>();
        params.put('AgentId','');
        params.put('Agentcode','456');
        params.put('RecordType',caseRecordtype.DeveloperName);

        Map<String,String> sc= new Map<String,String>();
        params.put('searchAgencyName','456');
        params.put('searchAgencyLastname','456');
        params.put('searchAgencyCode','456');
        params.put('searchAgentCommunityId','456');


        Test.startTest();
        LghtCallProcessingController.getIstanceCaseCreation(new Map<String,String>());
        LghtCallProcessingController.getCaseOptions(options);
        LghtCallProcessingController.getAccountCases(account.id,cs);
        LghtCallProcessingController.searchCaseByPartnerCode('0909',caseRecordtype);
        LghtCallProcessingController.initGestori(params);
        LghtCallProcessingController.initDealer(params);
        LghtCallProcessingController.init(params);
        LghtCallProcessingController.initAgency(params);
        LghtCallProcessingController.createCase(params,account.id);
        LghtCallProcessingController.searchAgent(params,sc);
        LghtCallProcessingController.CaseOption co= new LghtCallProcessingController.CaseOption();
        Test.stopTest();
    }
    
    
 
}