@isTest 
public class PassAnagrafeInvocableTest {
    
    @TestSetup
    static void makeData(){
        Id recordtypeId = [Select Id from Recordtype Where Name = 'B2B Client' and sObjecttype='Account'].Id;
        AAI_Code_Variables__c settinglink = new AAI_Code_Variables__c();
         settinglink.Name='AccountEdit_Folderlink';
         settinglink.Value__c='https://daol-pp.axa-italia.it/test';
        insert settinglink;
        IE_Configuration__c integration = new IE_Configuration__c();
        integration.Name = 'CIF_Integration_PartyService_Edit';
        integration.Type__c = 'WebService_rest';
        integration.Direction__c = 'OUTBOUND';
        integration.HTTPMethod__c = 'PUT';
        integration.EndPoint__c = 'https://testPassAnagrafe';
        integration.Request_compiler__c = 'IE_Request_CIF_EditAccount';
        integration.Response_parser__c = 'IE_CIFparser_EditAccount';
        integration.NameSpacePrefix1__c = 'soapenv';
        integration.NameSpacePrefix2__c = 'crm';
        integration.NameSpaceUri1__c = 'http://schemas.xmlsoap.org/soap/envelope/';
        integration.NameSpaceUri2__c = 'http://crm.service.rgi.it/';
        insert integration;
        IE_Configuration__c fullSearch_IEConf = new IE_Configuration__c (
                Request_compiler__c = 'IE_Request_CIF_EditAccount',
                Response_parser__c = 'IE_CIFparser_FullSearchAccount',
                Type__c = 'WebService',
                Certificate__c = '',
                EndPoint__c = 'https://testFullSearch',
                Name = 'CIF_Integration_AccountFullSearch',
                log_records_flag__c=false,
                Direction__c='OUTBOUND',
                NameSpacePrefix1__c = 'soapenv',
                NameSpacePrefix2__c = 'cif',
                NameSpaceUri1__c = 'http://schemas.xmlsoap.org/soap/envelope/',
                NameSpaceUri2__c = 'http://cif.service.rgi.it/'
            );
        insert fullSearch_IEConf;
        Account agency = new Account(
            Name = 'agency',
            RecordTypeId = RecordTypeUtility.getRecordTypeIdByDeveloperName('Account', 'Agency'),
            Agency_email__c = 'test@gmail.com'
        );
        insert agency;
        Account account = new Account(Name = 'Duplicated',
        RecordtypeId = recordtypeId,
        NDG__c = '13150000035966',
        AAI_Codice_fiscale__c = 'BB176176abcdefgh',
        AAI_Agency_Reference_Code__c = '004610',
        CIF_Commercial_Last_Modified_Date__c = Date.today()-1,
        CIF_OTP_Last_Modified_Date__c = Date.today()-1,
        State__c = 'ATTIVO');
        account.AAI_Agency__c = agency.Id;
         insert account;
        MappingCountry__c mc = new MappingCountry__c(
            name='1',
            CountryISOcode__c='ITA',
            CountrySFDC__c='Italy'
        );
        insert mc;
        MappingProvince__c mp = new MappingProvince__c(
            name='1',
            SFDCexpected__c='Milano',
            ProvinciaExternalKey__c='MI'
        );
        insert mp;
        Date myDaterilascio = Date.newInstance(2015, 2, 17); 
        Date myDatescadenza = Date.newInstance(2018, 3, 12);
        SalutationMapping__c sm = new SalutationMapping__c(
            Codice_CIF__c='1',
            Descrizione_CIF__c='Sig.',
            name='1'
        );
        insert sm;   

        Communications_to_customer__c communicationToCustomer = new Communications_to_customer__c(AccountId__c = account.Id, 
            Send_Date__c = Date.today(),
            CIF_Mail_contact__c = 'a.t@tiscali.it',
            CallPassAnagrafe__c = true,
            RecordTypeId = RecordTypeUtility.getRecordTypeIdByDeveloperName('Communications_to_customer__c', 'Marketing_Campaign'));
        insert communicationToCustomer;
                //fill custom setting Autorita rilascio
                AutRilascio_Code_Assignment__c setting3 = new AutRilascio_Code_Assignment__c();
                setting3.Name = 'Prefettura';
                setting3.AutRilascio_Code__c='8';
                AutRilascio_Code_Assignment__c setting4 = new AutRilascio_Code_Assignment__c();
                setting4.Name = 'Questura';
                setting4.AutRilascio_Code__c='2';
       
               //fill costum setting DI code Assignment
               DICodeAssignment__c setting5 = new DICodeAssignment__c();
               setting5.Name = 'Porto d\'armi';
               setting5.CIF_DI_code__c= '8';         
               DICodeAssignment__c setting6 = new DICodeAssignment__c();
               setting6.Name = 'Passaporto';
               setting6.CIF_DI_code__c= '4'; 
       
               List<AutRilascio_Code_Assignment__c> AutRilasciosetting = new List<AutRilascio_Code_Assignment__c>();
               AutRilasciosetting.add(setting3);
               AutRilasciosetting.add(setting4);
               List<Database.SaveResult> settingAutoritaSave = database.insert(AutRilasciosetting);
               system.debug ('+++++++settingSave2'+settingAutoritaSave );
       
               List<DICodeAssignment__c> DIcodesetting = new List<DICodeAssignment__c>();
               DIcodesetting.add(setting5);
               DIcodesetting.add(setting6);
               List<Database.SaveResult> DIsettingSave= database.insert(DIcodesetting);
               system.debug ('+++++++settingSave'+DIsettingSave);
    }

    @isTest 
    public static void testCallPassAnagrafe(){
        Test.startTest();
        Mock mock = new Mock();
        Test.setMock(HttpCalloutMock.class, mock);
        Communications_to_customer__c communicationToCustomer = [SELECT id from Communications_to_customer__c LIMIT 1];
        PassAnagrafeInvocable.callPassAnagrafe(new List<Communications_to_customer__c>{communicationToCustomer});
        Test.stopTest();
        
    }


    private class Mock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            System.debug('EndPoint' + req.getEndpoint());
            if (req.getEndpoint().endsWith('testPassAnagrafe')) {
                    HTTPResponse res = new HTTPResponse();
                    res.setBody('[{"ndg":"0001270000138297","occurrencyNumber":"1","dacOperationResult":{"operationResult":"OK","operationDetail":"Sono stati aperti dei fascicoli dalla chiamata DAC oppure ci sono dei documenti da consegnare"},"parties":[{"party":{"sourceExternal":"SFDC","userExternal":"AG2901A2","externalUpdateDateTime":"2018-10-08T16:23:17.470Z","ndg":["0001270000138297"],"agencyCode":"000127","operativePrivacy":true,"promotionalPrivacy":false,"marketResearchPrivacy":false,"thirdPartiesPrivacy":false,"mailDigitalPrivacy":false,"emailDac":"","graphometricSignaturePrivacy":true,"otpPrivacy":true,"telephoneOtp":"3332221111","marketResearchPrivacyUser":"AG2901A2","mailDigitalPrivacyUser":"AG2901A2","graphometricSignaturePrivacyUser":"AG2901A2","otpPrivacyUser":"AG2901A2","operativePrivacyDate":"2018-10-08T18:21:40.000+02:00","promotionalPrivacyDate":"2018-10-08T16:21:39.000+02:00","marketResearchPrivacyDate":"2018-10-08T16:21:39.000+02:00","thirdPartiesPrivacyDate":"2018-10-08T16:21:39.000+02:00","mailDigitalPrivacyDate":"2018-10-08T16:23:17.472Z","graphometricSignaturePrivacyDate":"2018-10-08T16:23:17.472Z","aggPrivacyOTP":"2018-10-08T16:23:17.472Z","eTypeAggPrivacy1":"SFDC","eTypeAggPrivacy2":"SFDC","eTypeAggPrivacy3":"SFDC","eTypeAggPrivacy4":"SFDC","eTypeAggPrivacyEmail":"SFDC","eTypeAggPrivacyFirma":"SFDC","eTypeAggPrivacyOTP":"SFDC","timestampCif":"2018-10-08T18:23:18.644+02:00"},"documents":[{"documentType":"1","nationCode":"AFG","documentNumber":"xx12312312","releaseAuthority":"1","releaseDate":"2018-10-01T00:00:00.000Z","expirationDate":"2028-01-01T00:00:00.000Z","dacDocument":true,"documentId":"1519027840"}],"telephone":[{"number":"3332221111","internationalPrefix":"+39","telephoneType":"2","contactId":"1519027838","propagaOmnia":true,"opposition":false}],"companyId":"2"}]}]'.normalizeSpace());
                    res.setStatusCode(200);
                    return res;
                } else if (req.getEndpoint().endsWith('testFullSearch')) {
                    HTTPResponse res = new HTTPResponse();
                    res.setBody('<?xml version="1.0" encoding="UTF-8"?><S:Envelope xmlns:S="http://schemas.xmlsoap.org/soap/envelope/"><S:Body><ns2:ricercaSoggettoFullResponse xmlns:ns4="http://rgi.it/anag" xmlns:ns3="http://rgi.it/soa" xmlns:ns2="http://cif.service.rgi.it/"><return><codiceEsito>OK</codiceEsito><occorrenzeTrovate>1</occorrenzeTrovate><aSoggetto><soggetto><tipoSoggetto>2</tipoSoggetto><denominazione>ROSSI SRL</denominazione><soggettoEstero>false</soggettoEstero><codiceFiscale>08253490968</codiceFiscale><partitaIva>08253490968</partitaIva><collegatoPA>false</collegatoPA><paese>ITA</paese><provincia>MI</provincia><localita>MILANO</localita><indirizzo>CORSO BUENOS AIRES 15</indirizzo><cap>20124</cap><Ndg>0001270000135604</Ndg><idSoggetto>1290527954</idSoggetto><ramoAttivita></ramoAttivita><codiceAttivita></codiceAttivita><codiceAteco></codiceAteco><codiceAgenzia>000127</codiceAgenzia><agenziaLight>false</agenziaLight><presenzaAlert>false</presenzaAlert><privacy1>true</privacy1><privacy2>false</privacy2><privacy3>false</privacy3><privacy4>false</privacy4><privacy5>false</privacy5><privacyEmail>false</privacyEmail><privacyFirma>false</privacyFirma><aggPrivacy1>true</aggPrivacy1><aggPrivacy2>true</aggPrivacy2><aggPrivacy3>true</aggPrivacy3><aggPrivacy4>true</aggPrivacy4><aggPrivacyEmail>true</aggPrivacyEmail><aggPrivacyFirma>true</aggPrivacyFirma><gestFin>false</gestFin><firsDAC>true</firsDAC><timestampCif>2017-06-05T18:07:52+02:00</timestampCif></soggetto><lstDocumenti><tipoDoc>8</tipoDoc><siglaNazione>ITA</siglaNazione><provincia>MI</provincia><localita>MILANO</localita><numeroDoc>AA1234567</numeroDoc><autoritaRilascio>1</autoritaRilascio><dataRilascio>2017-06-05T00:00:00+02:00</dataRilascio><dataScadenza>2027-06-24T00:00:00+02:00</dataScadenza></lstDocumenti><lstIndirizzi><cap>20124</cap><indirizzo>CORSO BUENOS AIRES 15</indirizzo><localita>MILANO</localita><provincia>MI</provincia><tipoIndirizzo>1</tipoIndirizzo></lstIndirizzi><lstContTelem> <tipoContatto>1</tipoContatto> <testo>AXA@AXA.IT</testo> <idContatto>1293284323</idContatto> <timeStamp>2017-07-06T14:41:35.852+02:00</timeStamp> <propagaOmnia>true</propagaOmnia> </lstContTelem></aSoggetto></return></ns2:ricercaSoggettoFullResponse></S:Body></S:Envelope>'.normalizeSpace());
                    res.setStatusCode(200);
                    return res;
                } else {
                    System.assert(false, 'unexpected endpoint ' + req.getEndpoint());
                    return null;
                }
            }
        }
}