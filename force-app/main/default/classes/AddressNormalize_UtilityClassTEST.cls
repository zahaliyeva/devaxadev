/**
 * @description PURE IT 23/05 - commentata la classe
 */
@istest
global without sharing class AddressNormalize_UtilityClassTEST{ 
/** PURE IT
	@TestSetup
    static void setup(){
        List<IE_Configuration__c> ieToIns = new List<IE_Configuration__c>{
            new IE_Configuration__c (
    Name= 'Integration_getComuni',
    Direction__c= 'OUTBOUND',
    EndPoint__c= 'Comuni',
    Request_compiler__c= 'IE_Request_CIF_EditAccount',
    Response_parser__c= 'IE_CIFparser_GetComuni',
    Type__c= 'WebService',
    NameSpacePrefix1__c= 'soapenv',
    NameSpacePrefix2__c= 'bean',
    NameSpaceUri1__c= 'http=//schemas.xmlsoap.org/soap/envelope/',
    NameSpaceUri2__c= 'http=//bean.services.jdna6hs.app.directw.it',
    HTTPMethod__c= null,
    NameSpacePrefix3__c= null,
    NameSpaceUri3__c= null,
    Named_Credential_Name__c= null,
    Named_Credential_Path__c= null,
    log_records_flag__c= false,
    Timeout__c= null,
    Insert_IR_WS__c= false,
    ClientId__c= null,
    SignedCertificatedSFDC__c= null,
    Client_Secret__c= null
  ),
  new IE_Configuration__c (
    Name= 'Integration_getProvince',
    Direction__c= 'OUTBOUND',
    EndPoint__c= 'Province',
    Request_compiler__c= 'IE_Request_CIF_EditAccount',
    Response_parser__c= 'IE_CIFparser_GetProvince',
    Type__c= 'WebService',
    NameSpacePrefix1__c= 'soapenv',
    NameSpacePrefix2__c= 'bean',
    NameSpaceUri1__c= 'http=//schemas.xmlsoap.org/soap/envelope/',
    NameSpaceUri2__c= 'http=//bean.services.jdna6hs.app.directw.it',
    HTTPMethod__c= null,
    NameSpacePrefix3__c= null,
    NameSpaceUri3__c= null,
    Named_Credential_Name__c= null,
    Named_Credential_Path__c= null,
    log_records_flag__c= false,
    Timeout__c= 30000,
    Insert_IR_WS__c= false,
    ClientId__c= null,
    SignedCertificatedSFDC__c= null,
    Client_Secret__c= null
  ),
  new IE_Configuration__c (
    Name= 'Integration_getStati',
    Direction__c= 'OUTBOUND',
    EndPoint__c= 'Stati',
    Request_compiler__c= 'IE_Request_CIF_EditAccount',
    Response_parser__c= 'IE_CIFparser_GetStati',
    Type__c= 'WebService',
    NameSpacePrefix1__c= 'soapenv',
    NameSpacePrefix2__c= 'bean',
    NameSpaceUri1__c= 'http=//schemas.xmlsoap.org/soap/envelope/',
    NameSpaceUri2__c= 'http=//bean.services.jdna6hs.app.directw.it',
    HTTPMethod__c= null,
    NameSpacePrefix3__c= null,
    NameSpaceUri3__c= null,
    Named_Credential_Name__c= null,
    Named_Credential_Path__c= null,
    log_records_flag__c= false,
    Timeout__c= null,
    Insert_IR_WS__c= false,
    ClientId__c= null,
    SignedCertificatedSFDC__c= null,
    Client_Secret__c= null
  )
        };
            insert ieToIns;
        System.assertEquals('Integration_getComuni', ieToIns[0].Name);
    }
    
    static testMethod void TestCorrect(){
		Test.setMock(HttpCalloutMock.class, new MockClass());
        Test.startTest();
        AddressNormalize_UtilityClass.ResponseDto res1 = AddressNormalize_UtilityClass.getProvinceList();
        AddressNormalize_UtilityClass.ResponseDto res2 = AddressNormalize_UtilityClass.getComuniList('MI'); 
        AddressNormalize_UtilityClass.ResponseDto res3 = AddressNormalize_UtilityClass.getStatiList();
        Test.stopTest();
    }
    
    static testMethod void TestKO(){
        Test.startTest();
        
        AddressNormalize_UtilityClass.ResponseDto res1 = AddressNormalize_UtilityClass.getProvinceList();
        AddressNormalize_UtilityClass.ResponseDto res2 = AddressNormalize_UtilityClass.getComuniList('MI'); 
        AddressNormalize_UtilityClass.ResponseDto res3 = AddressNormalize_UtilityClass.getStatiList();
        Test.stopTest();
    }

    global class MockClass implements System.HttpCalloutMock {
        
        global System.HttpResponse respond(System.HttpRequest req) {
            String reqType = req.getEndpoint();
            System.HttpResponse res = new System.HttpResponse();
            if(reqType == 'Stati'){
                res.setBody('<?xml version="1.0" encoding="utf-8"?><S:Envelope xmlns:S="http://schemas.xmlsoap.org/soap/envelope/"><S:Body><RispostaStato xmlns="http://bean.services.jdna6hs.app.directw.it"><TabStato><NumOccorrenza>1</NumOccorrenza><CodStato>4</CodStato><DesStato>AFGHANISTAN</DesStato><SiglaStato2>AF</SiglaStato2><SiglaStato3>AFG</SiglaStato3></TabStato><Esito><CodiceEsito>0</CodiceEsito></Esito></RispostaStato></S:Body></S:Envelope>');
            System.assertEquals('Stati', reqType);
            }
            else if(reqType == 'Comuni'){
                res.setBody('<?xml version="1.0" encoding="utf-8"?><S:Envelope xmlns:S="http://schemas.xmlsoap.org/soap/envelope/"><S:Body><RispostaLocalita xmlns="http://bean.services.jdna6hs.app.directw.it"><TabLocalita><NumOccorrenza>1</NumOccorrenza><TipoLocalitaUfficiale>1</TipoLocalitaUfficiale><DesTipoLocalitaUfficiale>COMUNE AMMINISTRATIVO</DesTipoLocalitaUfficiale><SigProvin>MI</SigProvin><CodLingua>ITA</CodLingua><CAP>20081</CAP><FlViarioNaz>S</FlViarioNaz><FlViarioZon>N</FlViarioZon><CodStatistico>003015002</CodStatistico><SigProvAmm>MI</SigProvAmm><DesLocalitaAmm>ABBIATEGRASSO</DesLocalitaAmm><CodStatisticoAmm>003015002</CodStatisticoAmm><DesLocalitaRicerca>ABBIATEGRASSO</DesLocalitaRicerca><CAPRicerca>20081</CAPRicerca><SigProRicerca>MI</SigProRicerca><TipoElemento>1</TipoElemento><FlSinonimo>N</FlSinonimo><DesTipoCertificazione>DNA</DesTipoCertificazione><TipoCertificazione>1</TipoCertificazione><DesRegione>LOMBARDIA</DesRegione><CodRegione>3</CodRegione><DesProvin>MILANO</DesProvin><DesLingua>Italia</DesLingua><DesLocalitaUff>ABBIATEGRASSO</DesLocalitaUff><DesLocalitaOut>ABBIATEGRASSO</DesLocalitaOut><DesLocalitaAbb>ABBIATEGRASSO</DesLocalitaAbb><FlViarioSpe>N</FlViarioSpe><CAPLocalitaAmm>20081</CAPLocalitaAmm><TpDato>0</TpDato></TabLocalita><Esito><CodiceEsito>0</CodiceEsito></Esito></RispostaLocalita></S:Body></S:Envelope>');
            System.assertEquals('Comuni', reqType);
            }
            else if(reqType == 'Province'){
                res.setBody('<?xml version="1.0" encoding="utf-8"?><S:Envelope xmlns:S="http://schemas.xmlsoap.org/soap/envelope/"><S:Body><RispostaProvincia xmlns="http://bean.services.jdna6hs.app.directw.it"><TabProvin><NumOccorrenza>1</NumOccorrenza><SigProvin>AG</SigProvin><DesProvin>AGRIGENTO</DesProvin><CAP>92100</CAP><CodStatistico1>019</CodStatistico1><CodStatistico2>084</CodStatistico2><CodStatistico3>001</CodStatistico3></TabProvin><Esito><CodiceEsito>0</CodiceEsito></Esito></RispostaProvincia></S:Body></S:Envelope>');
            System.assertEquals('Province', reqType);
            }
        	return res;
    	}
        
    } 
    PURE IT */
}