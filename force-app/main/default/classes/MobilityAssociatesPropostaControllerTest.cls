@isTest
public class MobilityAssociatesPropostaControllerTest {
    
    @TestSetup
    public static void setup(){
        
        IE_Configuration__c conf = new IE_Configuration__c(Name= 'REOL_getProposte',
                                                                                                Direction__c= 'OUTBOUND',
                                                                                                EndPoint__c= 'test',
                                                                                                Request_compiler__c= 'IE_Request_StaticCompiler',
                                                                                                Response_parser__c= 'IE_REOL_Parser',
                                                                                                Type__c= 'WebService',
                                                                                                NameSpacePrefix1__c= null,
                                                                                                NameSpacePrefix2__c= null,
                                                                                                NameSpaceUri1__c= null,
                                                                                                NameSpaceUri2__c= null,
                                                                                                HTTPMethod__c= null,
                                                                                                NameSpacePrefix3__c= null,
                                                                                                NameSpaceUri3__c= null,
                                                                                                Named_Credential_Name__c= null,
                                                                                                Named_Credential_Path__c= null,
                                                                                                log_records_flag__c= true,
                                                                                                Timeout__c= null,
                                                                                                Insert_IR_WS__c= false,
                                                                                                ClientId__c= null,
                                                                                                SignedCertificatedSFDC__c= null,
                                                                                                Client_Secret__c= null);
        
        List<IE_Configuration__c> confList = new List<IE_Configuration__c>{ new IE_Configuration__c(Name= 'REOL_AssociaProposta',
                                                                                                Direction__c= 'OUTBOUND',
                                                                                                EndPoint__c= 'test',
                                                                                                Request_compiler__c= 'IE_Request_REOL_AssociaProposta',
                                                                                                Response_parser__c= 'IE_REOL_Parser',
                                                                                                Type__c= 'WebService',
                                                                                                NameSpacePrefix1__c= 'soapenv',
                                                                                                NameSpacePrefix2__c= 'crm',
                                                                                                NameSpaceUri1__c= 'http://schemas.xmlsoap.org/soap/envelope/',
                                                                                                NameSpaceUri2__c= 'http://rgi.it/WS_REOL_Service',
                                                                                                HTTPMethod__c= null,
                                                                                                NameSpacePrefix3__c= null,
                                                                                                NameSpaceUri3__c= null,
                                                                                                Named_Credential_Name__c= null,
                                                                                                Named_Credential_Path__c= null,
                                                                                                log_records_flag__c= true,
                                                                                                Timeout__c= null,
                                                                                                Insert_IR_WS__c= false,
                                                                                                ClientId__c= null,
                                                                                                SignedCertificatedSFDC__c= null,
                                                                                                Client_Secret__c= null),
            
            																					conf
            															
            };
        insert confList;
        
        Attachment a = new Attachment(
        name = 'test',
        body = Blob.valueOf('<soapenv:Envelopexmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"xmlns:axa="http://rgi.it/WS_REOL_Service"xmlns:soa="http://rgi.it/soa"><soapenv:Header/><soapenv:Body><axa:getElencoProposteAssociabiliSalesForce><axa:input><axa:codeNDG>PH_codeNDG</axa:codeNDG><axa:codeNodo>PH_codiceAgenzia</axa:codeNodo><axa:codeUser>PH_UserName</axa:codeUser></axa:input></axa:getElencoProposteAssociabiliSalesForce></soapenv:Body></soapenv:Envelope>'),
        ParentId = conf.id
        );
            insert a;
        Map<string,Map<string,string>> rtypes = UtilityClass.fetchAllRTypes();
        id account_agency = UtilityClass.getRTid(rtypes, 'Account', 'Agency');
        Account TheClient = new Account();
        TheClient.NDG__c='0008280000002119';
        RecordType PF_RT = [SELECT id from RecordType where DeveloperName ='B2C_Client' Limit 1];
        TheClient.RecordTypeId = PF_RT.Id;
        TheClient.Salutation ='';
        TheClient.LastName = 'Rossi';
        TheClient.FirstName = 'Maria';
        TheClient.CIF_Marital_Status__c = 'Convivente';
        TheClient.CIF_Marital_Status_code__c = '7';
        TheClient.Nodes__c = '000828;000828000033';
        TheClient.AAI_Agency_Reference_Code__c ='000828';
        TheClient.State__c ='ATTIVO';
        TheClient.CIF_Job__c ='Agricoltore';
        TheClient.AAI_Codice_fiscale__c = 'MSSGNN64P24L929I';
        TheClient.CIF_Phone__c ='012345678';
        TheClient.CIF_PersonMobilePhone_IntPrefix__c   ='+39';
        TheClient.CIF_PersonMobilePhone__c ='023456678';
        TheClient.Fax = '345677891';
        TheClient.CIF_Work_phone__c= '012344444';
        TheClient.CIF_PersonEmail__c = 'mariarossi@email.com';
        TheClient.CIF_Work_email__c = 'test@libero6.it';
        TheClient.AnnualRevenue =  1112132;
        List<Account> agencyList = new List<Account>
            {
                new Account(Name = 'Agency Test Account 1',
                            RecordTypeId = account_agency,
                            Agency_Code__c = '004610',
                            Active__c = true,
                            Accordo_Digitale__c = true
                            ),

                new Account(Name = 'Agency Test Account 2',
                            RecordTypeId = account_agency,
                            Agency_Code__c = '000828',
                            Active__c = true,
                            Accordo_Digitale__c = true),
                theclient
            };

            insert agencyList;
    }
    
    @isTest static void testGetUserInfo() {  
        MobilityAssociatesPropostaController.getUserInfo();
    }
    
    @isTest static void testGetOpportunityInfo() {
        Account acc = new Account ();
        acc.Name='Test'; 
        acc.NDG__c='test test';  
        insert acc;

        Opportunity opp = new Opportunity();
        opp.Name='Myopp'; 
        opp.StageName='Open';
        opp.AccountId = acc.Id;
        opp.CloseDate= (date.today()).addDays(30); 
        insert opp;
        MobilityAssociatesPropostaController.getOpportunityInfo(opp.Id);
        
    }
    
    @isTest
    static void testMethod1(){
        List<account> a = [select id from account where ndg__c = '0008280000002119' limit 1];
        Opportunity o = new Opportunity(Name = 'OppTest', stageName = 'Closed Won', CloseDate = Date.today().addDays(1), AccountId = a.get(0).Id);
        insert o;
        
        REOL_associa_Mock mock = new REOL_associa_Mock();
        mock.TestCase = 'OK_ASSOCIA';
        mock.OppId = o.Id;
        test.setMock(HTTPCalloutMock.class, mock);
        test.startTest();
        MobilityAssociatesPropostaController.confirm(o.Id, 'test');
        test.stopTest();
    }
    
    @isTest
    static void testMethod2(){
        List<account> a = [select id from account where ndg__c = '0008280000002119' limit 1];
        Opportunity o = new Opportunity(Name = 'OppTest', stageName = 'Closed Won', CloseDate = Date.today().addDays(1), AccountId = a.get(0).Id);
        insert o;
        
        REOL_associa_Mock mock = new REOL_associa_Mock();
        mock.TestCase = 'OK_GET_2';
        mock.OppId = o.Id;
        test.setMock(HTTPCalloutMock.class, mock);
        test.startTest();
        MobilityAssociatesPropostaController.getListFromREOL(o);
        test.stopTest();
    }
}