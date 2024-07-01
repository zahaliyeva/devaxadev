@isTest(seeAllData=false)
public class IE_SOLClaimOpening_TEST {
    
    //MDANTONIO 09/04/2019 popolamento custom settings per classi di test - start
    @testSetup static void setup(){
        ServiceUtilsClass.populateCustomSettingsForTests();
    }
    //MDANTONIO 09/04/2019 popolamento custom settings per classi di test - end

    //FAILURE MOCK T720
    public class Test_MockIE_SOLClaimOpeningsErrorResponseT720 implements HttpCalloutMock 
    {
        
        public HTTPResponse respond(HTTPRequest req) 
        {  
            
            HttpResponse res = new HttpResponse();
            res.setHeader('Accept-Encoding', 'gzip,deflate');
            res.setHeader('Content-Type', 'application/json');
            res.setHeader('Content-Length', '207');
            res.setHeader('Host', 'esg-pp.axa-medla.com');
			res.setHeader('Connection', 'Keep-Alive');
            res.setHeader('User-Agent', 'Apache-HttpClient/4.1.1 (java 1.5)');
            res.setBody('{"code" : "T720", "developerMessage" : "test"}');
            res.setStatusCode(500);
            return res;
        }
    } 
    
    //FAILURE MOCK UNHANDLED
    public class Test_MockIE_SOLClaimOpeningErrorResponseUnhandled implements HttpCalloutMock 
    {
        
        public HTTPResponse respond(HTTPRequest req) 
        {  
            
            HttpResponse res = new HttpResponse();
            res.setHeader('Accept-Encoding', 'gzip,deflate');
            res.setHeader('Content-Type', 'application/json');
            res.setHeader('Content-Length', '207');
            res.setHeader('Host', 'esg-pp.axa-medla.com');
			res.setHeader('Connection', 'Keep-Alive');
            res.setHeader('User-Agent', 'Apache-HttpClient/4.1.1 (java 1.5)');
            res.setBody('{"code" : "T222222", "developerMessage" : "test"}');
            res.setStatusCode(500);
            return res;
        }
    } 
    
    //POSITIVE MOCK
    public class Test_MockIE_SOLClaimOpeningPositiveResponse implements HttpCalloutMock 
    {
        
        public HTTPResponse respond(HTTPRequest req) 
        {  
            HttpResponse res = new HttpResponse();
            res.setHeader('Accept-Encoding', 'gzip,deflate');
            res.setHeader('Content-Type', 'application/json');
            res.setHeader('Content-Length', '207');
            res.setHeader('Host', 'esg-pp.axa-medla.com');
			res.setHeader('Connection', 'Keep-Alive');
            res.setHeader('User-Agent', 'Apache-HttpClient/4.1.1 (java 1.5)');
            res.setBody('{ "MessageBody": { "Url": "https://precol.axa-italia.it/AXA_DENUNCE/Digital/CaringAngel/AperturaSinistroCaringAngel.aspx?IdCase=98765422&NumPol=1.1315.5.403126157&DtEvento=18/06/2018&Targa=XN874PP&IdAdesione=&NumApplicazione=00013", "Errori": null }, "MessageHeader": { "ResultMessage": 1, "Resultexception": null }}');            
            res.setStatusCode(200);            
            return res;
        }
    }  
    
    
    static testMethod void IE_GetAllPolicies_method1(){
        IE_Configuration__c IE_conf = new IE_Configuration__c(Name = 'SOL_Claim_Insert', HTTPMethod__c='GET', Type__c = 'WebService_rest', 
                                                              Request_compiler__c='IE_SOLClaimOpening_Request_Compiler', Response_parser__c = 'IE_SOLClaimOpening_Response_parser',
                                                              Endpoint__c = 'https://esg-pp.axa-medla.com/it-nb-sol-claimreport-vs_INT/AperturaDenuncia');
        insert IE_conf;
        User uteTec = [SELECT Id FROM User WHERE Profile.Name IN ('System Administrator','Amministratore del sistema') AND Alias ='utte' LIMIT 1];
        String userId = uteTec.Id;
        Account acct = new Account(FirstName = 'Account', LastName = 'SFDC', AAI_Codice_fiscale__c = 'MCCGNN88P14F839W', Fiscal_ID__c = 'MCCGNN88P14F839W', RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2C Client').getRecordTypeId());
        insert acct;
        Case cs = new Case(Status = 'Open', RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Caring Angel').getRecordTypeId());
        insert cs;
        Questionario_CA__c quest = new Questionario_CA__c(Case__c = cs.Id,
															Contraente__c = acct.Id, 
															Data_Evento__c = System.now().date(), 
															Numero_Polizza__c = '1.008480000020.5.408228998', 
															Targa__c = 'tr456tr', 
															Luogo_Evento__c = 'Roma',
															Nome_contraente__c = 'Account',
															Cognome_Contraente__c = 'SFDC',
															Data_di_nascita_contraente__c = system.now().date(),
															Codice_fiscale_contraente__c = 'MCCGNN88P14F839W',
															Indirizzo_Contraente__c = 'qua',
															Citt_Contraente__c = 'qua',
															Provincia_Contraente__c = 'la',
															CAP_Contraente__c = '90909',
															Indirizzo_Domicilio_Contraente__c = 'Indirizzo_Domicilio_Contraente__c',
															Citt_Domicilio_Contraente__c = 'Citt_Domicilio_Contraente__c',
															Provincia_Domicilio_Contraente__c = 'Provincia_Domicilio_Contraente__c',
															CAP_Domicilio_Contraente__c = 'CAP_Domicilio_Contraente__c',
															Stato_Contraente__c = 'Stato_Contraente__c',
															Email_Contraente__c = 'sdfsd@sdfsdf.com',
															Nome_conducente__c = 'Nome_conducente__c',
															Cognome_Conducente__c = 'Cognome_Conducente__c',
															Data_di_nascita_conducente__c = system.now().date(),
															Codice_fiscale_conducente__c = 'MCCGNN88P14F839W',
															Indirizzo_Conducente__c = 'Indirizzo_Conducente__c',
															Citt_Conducente__c = 'Citt_Conducente__c',
															CAP_Conducente__c = '90909',
															Indirizzo_Domicilio_Conducente__c = 'Indirizzo_Domicilio_Conducente__c',
															Citt_Domicilio_Conducente__c = 'Citt_Domicilio_Conducente__c',
															Provincia_Domicilio_Conducente__c = 'Provincia_Domicilio_Conducente__c',
															CAP_Domicilio_Conducente__c = 'CAP_Domicilio_Conducente__c',
															Stato_Conducente__c = 'Stato_Conducente__c',
															Descrizione_dinamica__c = 'Descrizione_dinamica__c',
															Ambulanza__c = 'No',
															Autorit__c = 'No',
															Carro__c = 'No',
															Note__c = 'Note__c',
															Targa_controparte__c = 'Targa_controparte__c',
															Nome_controparte__c = 'Nome_controparte__c',
															Cognome_Controparte__c = 'Cognome_Controparte__c',
															Data_di_nascita_controparte__c = system.now().date());
        insert quest;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Test_MockIE_SOLClaimOpeningPositiveResponse());
        IE_SOLClaimOpening.ResponseDto response = new IE_SOLClaimOpening.ResponseDto();
        response = IE_SOLClaimOpening.SOLCreateNewClaim(quest,quest.Case__c);
        Test.stopTest();
    }
    
    static testMethod void IE_GetAllPolicies_method2(){
        IE_Configuration__c IE_conf = new IE_Configuration__c(Name = 'SOL_Claim_Insert', HTTPMethod__c='GET', Type__c = 'WebService_rest', 
                                                              Request_compiler__c='IE_SOLClaimOpening_Request_Compiler', Response_parser__c = 'IE_SOLClaimOpening_Response_parser',
                                                              Endpoint__c = 'https://esg-pp.axa-medla.com/it-nb-sol-claimreport-vs_INT/AperturaDenuncia');
        insert IE_conf;
        User uteTec = [SELECT Id FROM User WHERE Profile.Name IN ('System Administrator','Amministratore del sistema') AND Alias ='utte' LIMIT 1];
        String userId = uteTec.Id;
        Account acct = new Account(FirstName = 'Account', LastName = 'SFDC', AAI_Codice_fiscale__c = 'MCCGNN88P14F839W', Fiscal_ID__c = 'MCCGNN88P14F839W', RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2C Client').getRecordTypeId());
        insert acct;
        Case cs = new Case(Status = 'Open', RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Caring Angel').getRecordTypeId());
        insert cs;
        Questionario_CA__c quest = new Questionario_CA__c(Case__c = cs.Id,
															Contraente__c = acct.Id, 
															Data_Evento__c = System.now().date(), 
															Numero_Polizza__c = '1.008480000020.5.123654408228998', 
															Targa__c = 'tr456tr', 
															Luogo_Evento__c = 'Roma',
															Nome_contraente__c = 'Account',
															Cognome_Contraente__c = 'SFDC',
															Data_di_nascita_contraente__c = system.now().date(),
															Codice_fiscale_contraente__c = 'MCCGNN88P14F839W',
															Indirizzo_Contraente__c = 'qua',
															Citt_Contraente__c = 'qua');
        insert quest;
        Test.startTest();
        IE_SOLClaimOpening.ResponseDto response = new IE_SOLClaimOpening.ResponseDto();
        response = IE_SOLClaimOpening.SOLCreateNewClaim(quest,quest.Case__c);
        Test.stopTest();
    }
    
   
}