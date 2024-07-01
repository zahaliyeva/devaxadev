@isTest
public class UnsubMainCTLR_Test {

	public class testMock implements HttpCalloutMock {
        
        public testMock(Boolean login, Boolean getDet, Boolean accSearchB2B, Boolean accSearchB2C, Boolean PartyService){
            this.login = login;
            this.getDet = getDet;
            this.accSearchB2B = accSearchB2B;
            this.accSearchB2C = accSearchB2C;
            this.PartyService = PartyService;
        }
        
        private boolean login;
        private boolean getDet;
        private boolean accSearchB2B;
        private boolean accSearchB2C;
        private boolean PartyService;
        
    	public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
        	String s = req.getEndpoint();
            switch on s {
                when 'MC_Unsub_Login' {
                    if(login){
                        Map<String, Object> respMap = new Map<String, Object>();
                        respMap.put('access_token', '000');
                        res.setBody(JSON.serialize(respMap));
                    }
                    
                }
                when 'MC_Unsub_GetDetail' {
                    if(getDet){
                        MKT_Unsuscribed_Wrapper resp = new MKT_Unsuscribed_Wrapper();
                        List<MKT_Unsuscribed_Wrapper.itemsWrapper> items = new List<MKT_Unsuscribed_Wrapper.itemsWrapper>();
                        MKT_Unsuscribed_Wrapper.ValueWrapper values = new MKT_Unsuscribed_Wrapper.ValueWrapper();
                        resp.count = 1;
                        values.ndg = '000000000';
                        
                        values.emailaddress = '';
                        dateTime n = dateTime.now()+1;
                        values.expirationdate = n.format('MM/dd/yyyy hh:mm:ss a');
                       
                        values.accountid = '';
                       
                        values.firstname = 'TEST';
                        
                       	values.mobilephone = '';
                        
                        values.insertdate = '';
                        
                        values.channel = 'Email';
                        
                        MKT_Unsuscribed_Wrapper.itemsWrapper i = new MKT_Unsuscribed_Wrapper.itemsWrapper();
                        i.values = values;
                        items.add(i);
                        resp.items = items;
                        
                        res.setBody(JSON.serialize(resp));
                    }
                     
                }
                when 'CIF_Integration_AccountFullSearch' {
                    if(accSearchB2B){
                        String myXml='<?xml version="1.0"'+
                  'encoding="UTF-8"?><S:Envelope xmlns:S="http://schemas.xmlsoap.org/soap/envelope/">'+
                  '<S:Body><ns2:ricercaSoggettoFullResponse xmlns:ns4="http://rgi.it/anag" xmlns:ns3="http://rgi.it/soa"'+
                  ' xmlns:ns2="http://cif.service.rgi.it/"><return><codiceEsito>OK</codiceEsito><occorrenzeTrovate>1</occorrenzeTrovate><aSoggetto><soggetto><tipoSoggetto>2'+
                  '</tipoSoggetto><denominazione>ROSSI SRL</denominazione><soggettoEstero>false</soggettoEstero><codiceFiscale>08253490968</codiceFiscale><partitaIva>08253490968</partitaIva><collegatoPA>'+
                  'false</collegatoPA><paese>ITA</paese><provincia>MI</provincia><localita>MILANO</localita><indirizzo>CORSO BUENOS AIRES 15</indirizzo><cap>20124</cap><Ndg>000000000</Ndg>'+
                  '<idSoggetto>1290527954</idSoggetto><ramoAttivita></ramoAttivita><codiceAttivita></codiceAttivita><codiceAteco></codiceAteco><codiceAgenzia>000127</codiceAgenzia><agenziaLight>false</agenziaLight>'+
                  '<presenzaAlert>false</presenzaAlert><privacy1>true</privacy1><privacy2>false</privacy2><privacy3>false</privacy3><privacy4>false</privacy4><privacy5>false</privacy5><privacyEmail>false</privacyEmail>'+
                  '<privacyFirma>false</privacyFirma><aggPrivacy1>true</aggPrivacy1><aggPrivacy2>true</aggPrivacy2><aggPrivacy3>true</aggPrivacy3><aggPrivacy4>true</aggPrivacy4><aggPrivacyEmail>true</aggPrivacyEmail>'+
                  '<aggPrivacyFirma>true</aggPrivacyFirma><gestFin>false</gestFin><firsDAC>true</firsDAC><timestampCif>2017-06-05T18:07:52+02:00</timestampCif></soggetto></aSoggetto></return></ns2:ricercaSoggettoFullResponse></S:Body></S:Envelope>';
                           myXml=myXml.normalizespace();

            			res.setBody(myXml);
                    }
                    else if (accSearchB2C){
                        String myXml = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:cif="http://cif.service.rgi.it/" xmlns:soa="http://rgi.it/soa">'+
                                        '<soapenv:Header/>'+
                                        '<soapenv:Body>'+
                                        '<cif:ricercaSoggettoFullResponse>'+
                                        '<return>'+
                                        '<codiceEsito>OK</codiceEsito>'+
                                        '<msgRisposta></msgRisposta>'+
                                        '<occorrenzeTrovate>1</occorrenzeTrovate>'+
                                        '<aSoggetto>'+
                                        '<soggetto>'+
                                        '<codiceTitoloOnorifico>1</codiceTitoloOnorifico>'+
                                        '<tipoSoggetto>1</tipoSoggetto>'+
                                        '<cognome>BARBUTO</cognome>'+
                                        '<nome>ALESSIO</nome>'+
                                        '<soggettoEstero>false</soggettoEstero>'+
                                        '<codiceFiscale>BRBLSS54G78D654G</codiceFiscale>'+
                                        '<localitaNascita>Milano</localitaNascita>'+
                                        '<sesso>M</sesso>'+
                                        '<dataNascita>1989-12-09T11:04:59.674+01:00</dataNascita>'+
                                        '<paese>ITA</paese>'+
                                        '<provincia>MI</provincia>'+
                                        '<localita>Milano</localita>'+
                                        '<indirizzo>Via Arguzia 54</indirizzo>'+
                                        '<cap>20100</cap>'+
                                        '<codiceProfessione>23V0041</codiceProfessione>'+
                                        '<codiceStatoCivile>1</codiceStatoCivile>'+
                                        '<Ndg>ABC112233</Ndg>'+
                                        '<codiceAgenzia>000828</codiceAgenzia>'+
                                        '<agenziaLight>true</agenziaLight>'+
                                        '<presenzaAlert>false</presenzaAlert>  <privacy1>true</privacy1>'+
                                        '<privacy2>false</privacy2>'+
                                        '<privacy3>false</privacy3>'+
                                        '<privacy4>false</privacy4>'+
                                        '<privacy5>false</privacy5>'+
                                        '<privacyEmail>false</privacyEmail>'+
                                        '<privacyFirma>false</privacyFirma>'+
                                        '<aggPrivacy1>true</aggPrivacy1>'+
                                        '<aggPrivacy2>true</aggPrivacy2>'+
                                        '<aggPrivacy3>true</aggPrivacy3>'+
                                        '<aggPrivacy4>true</aggPrivacy4>'+
                                        '<aggPrivacy5>true</aggPrivacy5>'+
                                        '<aggPrivacyEmail>true</aggPrivacyEmail>'+
                                        '<aggPrivacyFirma>true</aggPrivacyFirma>'+
                                        '<aggByEmailPrivacyEmail>true</aggByEmailPrivacyEmail>'+
                                        '<aggIndEmail>true</aggIndEmail>'+
                                        '<aggDocumentoPrivacyFirma>true</aggDocumentoPrivacyFirma>'+
                                        '<gestFin>false</gestFin>'+
                                        '<firsDAC>true</firsDAC>'+
                                        '<timestampCif>2017-03-02T10:11:34+01:00</timestampCif>'+
                                        '</soggetto>'+
                                        '<lstTelefoni>'+
                                        '<numero>3294521432</numero>'+
                                        '<objectId>'+
                                        '<soa:long>123</soa:long>'+
                                        '</objectId>'+
                                        '<prefissoInternazionale>+39</prefissoInternazionale>'+
                                        '<tipoTelefono>1</tipoTelefono>'+
                                        '<timeStamp>2016-12-09T11:04:59.674+01:00</timeStamp>'+
                                        '</lstTelefoni>'+
                                        '<lstTelefoni>'+
                                        '<numero>3294521111</numero>'+
                                        '<prefissoInternazionale>+39</prefissoInternazionale>'+
                                        '<tipoTelefono>1</tipoTelefono>'+
                                        '<timeStamp>2016-12-14T11:04:59.674+01:00</timeStamp>'+
                                        '</lstTelefoni>'+
                                        '<lstTelefoni>'+
                                        '<numero>3294521433</numero>'+
                                        '<prefissoInternazionale>+39</prefissoInternazionale>'+
                                        '<tipoTelefono>2</tipoTelefono>'+
                                        '<timeStamp>2016-12-09T11:04:59.674+01:00</timeStamp>'+
                                        '</lstTelefoni>'+
                                        '<lstDocumenti>'+
                                        '<tipoDoc>1</tipoDoc>'+
                                        '<siglaNazione>ITA</siglaNazione>'+
                                        '<provincia>RM</provincia>'+
                                        '<localita>ROMA</localita>'+
                                        '<numeroDoc>AO2458942</numeroDoc>'+
                                        '<autoritaRilascio>1</autoritaRilascio>'+
                                        '<dataRilascio>2027-10-16T00:00:00+01:00</dataRilascio>'+
                                        '<dataScadenza>2027-02-02T00:00:00+01:00</dataScadenza>'+
                                        '<idDocumento>3473747374995845</idDocumento>'+
                                        '</lstDocumenti>'+
                                        '<lstContTelem>'+
                                        '<tipoContatto>1</tipoContatto>'+
                                        '<testo>AXA@AXA.IT</testo>'+
                                        '<idContatto>1293284323</idContatto>'+
                                        '<timeStamp>2017-07-06T14:41:35.852+02:00</timeStamp>'+
                                        '<propagaOmnia>true</propagaOmnia>'+
                                        '</lstContTelem>'+
                                        '<lstVisibilita>'+
                                        '<subagenzia>000828000001</subagenzia>'+
                                        '</lstVisibilita>'+
                                        '<lstVisibilita>'+
                                        '<subagenzia>000828000002</subagenzia>'+
                                        '</lstVisibilita>'+
                                        '<lstVisibilita>'+
                                        '<subagenzia>000828</subagenzia>'+
                                        '</lstVisibilita>'+
                                        '</aSoggetto>'+
                                        '</return>'+
                                        '</cif:ricercaSoggettoFullResponse>'+
                                        '</soapenv:Body>'+
                                        '</soapenv:Envelope>';
                        myXml=myXml.normalizespace();

            			res.setBody(myXml);
                    }
                    
                }
                when 'CIF_Integration_PartyService_Edit'{
                    if(PartyService)
                    	res.setBody('[{"ndg":"0001270000138297","occurrencyNumber":"1","dacOperationResult":{"operationResult":"OK","operationDetail":"Sono stati aperti dei fascicoli dalla chiamata DAC oppure ci sono dei documenti da consegnare"},"parties":[{"party":{"sourceExternal":"SFDC","userExternal":"AG2901A2","externalUpdateDateTime":"2018-10-08T16:23:17.470Z","ndg":["0001270000138297"],"agencyCode":"000127","operativePrivacy":true,"promotionalPrivacy":false,"marketResearchPrivacy":false,"thirdPartiesPrivacy":false,"mailDigitalPrivacy":false,"emailDac":"","graphometricSignaturePrivacy":true,"otpPrivacy":true,"telephoneOtp":"3332221111","marketResearchPrivacyUser":"AG2901A2","mailDigitalPrivacyUser":"AG2901A2","graphometricSignaturePrivacyUser":"AG2901A2","otpPrivacyUser":"AG2901A2","operativePrivacyDate":"2018-10-08T18:21:40.000+02:00","promotionalPrivacyDate":"2018-10-08T16:21:39.000+02:00","marketResearchPrivacyDate":"2018-10-08T16:21:39.000+02:00","thirdPartiesPrivacyDate":"2018-10-08T16:21:39.000+02:00","mailDigitalPrivacyDate":"2018-10-08T16:23:17.472Z","graphometricSignaturePrivacyDate":"2018-10-08T16:23:17.472Z","aggPrivacyOTP":"2018-10-08T16:23:17.472Z","eTypeAggPrivacy1":"SFDC","eTypeAggPrivacy2":"SFDC","eTypeAggPrivacy3":"SFDC","eTypeAggPrivacy4":"SFDC","eTypeAggPrivacyEmail":"SFDC","eTypeAggPrivacyFirma":"SFDC","eTypeAggPrivacyOTP":"SFDC","timestampCif":"2018-10-08T18:23:18.644+02:00"},"documents":[{"documentType":"1","nationCode":"AFG","documentNumber":"xx12312312","releaseAuthority":"1","releaseDate":"2018-10-01T00:00:00.000Z","expirationDate":"2028-01-01T00:00:00.000Z","dacDocument":true,"documentId":"1519027840"}],"telephone":[{"number":"3332221111","internationalPrefix":"+39","telephoneType":"2","contactId":"1519027838","propagaOmnia":true,"opposition":false}],"companyId":"2"}]}]'.normalizeSpace());
                }
            }
            return res;
        }
    }
    
    
    @TestSetup
    static void init(){
        ID BusinessHoursDefault = [Select id from businesshours where isDefault = true limit 1].id;
        list<MPS_Code_Variables__c> settList = new List<MPS_Code_Variables__c>();
        settList.add(new MPS_Code_Variables__c(name = 'BusinessHours_Default', Value__c = BusinessHoursDefault));
        settList.add(new MPS_Code_Variables__c(name = 'Ivass41Solleciti', Value__c = '0;0;0;0;0'));
        
        insert settList;
        Profile AdminProfile = [SELECT Id FROM Profile WHERE Name  IN ('Amministratore del Sistema', 'System Administrator') ]; 
        UserRole role = [SELECT Id FROM UserRole where name = 'AXA Assicurazioni'];
            Id pRol = role.Id;
        insert new SMSCaringKeyword__c(Keyword__c='INFORMATIVE',Name='SMSKeyword');
        insert new SMSCaringKeyword__c(Keyword__c='INFORMATIVE',Name='SMSKeywordSTT');
        Account ac = new Account (
                FirstName = 'test',
                LastName = 'LeadTest',
                PersonEmail = 'account@mail.test',
                Phone = '0333333333',
                PersonMobilePhone = '3333333333',
                NDG__c = '000000000',
                Nodes__c = '000828',
                AAI_Agency_Reference_Code__c='000828',
                AAI_Codice_fiscale__c='DRFNLI65H54F654G'
                
            );
        insert ac;
        insert new AAI_Code_Variables__c(name = 'AccountEdit_Folderlink', value__c = 'test');
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

            SalutationMapping__c sm = new SalutationMapping__c(
                Codice_CIF__c='1',
                Descrizione_CIF__c='Sig.',
                name='1'
            );
            insert sm;
        List<IE_Configuration__c> confToInsert = new List<IE_Configuration__c>();
        IE_Configuration__c MCLogin = new IE_Configuration__c(Name = 'MC_Unsub_Login', Direction__c = 'OUTBOUND', EndPoint__c = 'MC_Unsub_Login', HTTPMethod__c = 'POST', clientId__c = '0000', Client_Secret__c = '0000');
        IE_configuration__c MCGetDeatail = new IE_Configuration__c(Name = 'MC_Unsub_GetDetail', Direction__c = 'OUTBOUND', EndPoint__c = 'MC_Unsub_GetDetail', HTTPMethod__c = 'GET');
        IE_Configuration__c CIF_Search = new IE_Configuration__c(Request_compiler__c = 'IE_Request_CIF_EditAccount',
                Response_parser__c = 'IE_CIFparser_FullSearchAccount',
                Type__c = 'WebService',
                Certificate__c = '',
                EndPoint__c = 'CIF_Integration_AccountFullSearch',
                Name = 'CIF_Integration_AccountFullSearch',
                log_records_flag__c=false,
                Direction__c='OUTBOUND',
                NameSpacePrefix1__c = 'soapenv',
                NameSpacePrefix2__c = 'cif',
                NameSpaceUri1__c = 'http://schemas.xmlsoap.org/soap/envelope/',
                NameSpaceUri2__c = 'http://cif.service.rgi.it/');
        
        IE_Configuration__c integration = new IE_Configuration__c(Name = 'CIF_Integration_PartyService_Edit',
                                                                 	Type__c = 'WebService_rest',
                                                                	Direction__c = 'OUTBOUND',
                                                                  	HTTPMethod__c = 'PUT',
                                                                  	EndPoint__c = 'CIF_Integration_PartyService_Edit',
                                                                  	Request_compiler__c = 'IE_Request_CIF_EditAccount',
                                                                  	Response_parser__c = 'IE_CIFparser_EditAccount',
                                                                  	NameSpacePrefix1__c = 'soapenv',
                                                                  	NameSpacePrefix2__c = 'crm',
                                                                  	NameSpaceUri1__c = 'http://schemas.xmlsoap.org/soap/envelope/',
                                                                  	NameSpaceUri2__c = 'http://crm.service.rgi.it/'
                                                                 );
        
        confToInsert.add(MCLogin);
        confToInsert.add(MCGetDeatail);
        confToInsert.add(CIF_Search);
        confToInsert.add(integration);
        insert confToInsert;
        user u = new User(FirstName='Utente',
                               LastName = 'Tecnico', 
                               Alias = 'utte', 
                               Email = 'test.test@test.test', 
                               Username = 'technical_user@italy.axa.comTestClass', 
                               LanguageLocaleKey = 'en_US',
                               TimeZoneSidKey='Europe/Rome',
                               Profileid = AdminProfile.Id,
                               LocaleSidKey='en_US',
                               EmailEncodingKey='ISO-8859-1',
                               UserRoleId=pRol);
        System.runAs(new User(Id=UserInfo.getUserId()))
        {            

            insert u;
        } 
        
    }
    
    @isTest
    public static void TestUnsubAllCorrectB2B(){
        testMock mock = new testMock(true, true, true,false, true);
        Test.setMock(HttpCalloutMock.class, mock);
        UnsubscribeInitWrapper u = UnsubMainCTRL.Init('0000', true);
        u.editedFieldsMap.put('Comunicazioni informative',true);
        Test.startTest();
        
        UnsubMainCTRL.save(JSON.serialize(u));
        Test.stopTest();
        
        
        
    }
    
    @isTest
    public static void TestUnsubAllCorrectB2C(){
        testMock mock = new testMock(true, true, false, true, true);
        Test.setMock(HttpCalloutMock.class, mock);
        UnsubscribeInitWrapper u = UnsubMainCTRL.Init('0000', true);
        u.editedFieldsMap.put('Comunicazioni informative',true);
        Test.startTest();
        
        UnsubMainCTRL.save(JSON.serialize(u));
        Test.stopTest();
        
        
        
    }
    
    @isTest
    public static void TestUnsubException(){
        testMock mock = new testMock(true, false, true,false, true);
        Test.setMock(HttpCalloutMock.class, mock);
        UnsubscribeInitWrapper u = UnsubMainCTRL.Init('0000', true);
        u.editedFieldsMap.put('Comunicazioni informative',true);
        Test.startTest();
        
        UnsubMainCTRL.save(JSON.serialize(u));
        Test.stopTest();
        
    }
    
    @isTest
    public static void TestDestErratoAllCorrect(){
    	testMock mock = new testMock(true, true, true,false, true);
        Test.setMock(HttpCalloutMock.class, mock);
        UnsubscribeInitWrapper u = UnsubMainCTRL.Init('0000', false);
        Test.startTest();
        UnsubMainCTRL.createCase(JSON.serialize(u));
        Test.stopTest();
    }
    
    @isTest
    public static void TestDestErratoException(){
    	testMock mock = new testMock(true, true, true, false, true);
        Test.setMock(HttpCalloutMock.class, mock);
        UnsubscribeInitWrapper u = UnsubMainCTRL.Init('0000', false);
        Test.startTest();
        UnsubMainCTRL.createCase('');
        Test.stopTest();
    }
}