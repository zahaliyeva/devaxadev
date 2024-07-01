/*------------------------------------------------------------------------
Author:        Dario Bovolenta
Company:       Deloitte
Class:         AccountInsert_Mock_TEST
Description:   Test response for the decode fiscal code routine
            
History
14/02/2017 - Created
---------------------------------------------------------------------------*/
/**
 * @description PURE IT 22/05 - commentata la classe
 */

 public class decodeFiscalCode_Mock_TEST{}
/** PURE IT
global class decodeFiscalCode_Mock_TEST implements HttpCalloutMock{

    public String TestCase;


    global HTTPResponse respond(HTTPRequest req) {



        // Create a fake response based on the attribute TestCase
        HttpResponse res = new HttpResponse();

        string myXml='';
        
        if (TestCase == 'Valid'){
            myXML=''+'<?xml version=\'1.0\' encoding=\'utf-8\'?>';
            myXML+='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">';
            myXML+='    <soapenv:Body>';
            myXML+='        <RispostaCodicePersonale xmlns="http://bean.services.jdna6ws.app.directw.it">';
            myXML+='            <CodConf>0</CodConf>';
            myXML+='            <SigConf />';
            myXML+='            <DesConf />';
            myXML+='            <CodStato>0</CodStato>';
            myXML+='            <SigStato2 />';
            myXML+='            <SigStato3 />';
            myXML+='            <DesStato />';
            myXML+='            <CodRegione>0</CodRegione>';
            myXML+='            <DesRegione />';
            myXML+='            <SigProvincia>TO</SigProvincia>';
            myXML+='            <DesProvincia />';
            myXML+='            <DesLoc1>TORINO</DesLoc1>';
            myXML+='            <DesLoc2 />';
            myXML+='            <TipoLocalita />';
            myXML+='            <CxTerr />';
            myXML+='            <NumPesoLoc>0.0</NumPesoLoc>';
            myXML+='            <Cognome />';
            myXML+='            <Nome />';
            myXML+='            <Sesso>2</Sesso>';
            myXML+='            <DataNascita>19800101</DataNascita>';
            myXML+='            <CodiceFiscale1>ZCCFMN80A41L219Y</CodiceFiscale1>';
            myXML+='            <CodiceFiscale2 />';
            myXML+='            <Esito>';
            myXML+='                <Codice>0</Codice>';
            myXML+='                <Descrizione>DATI VALIDATI</Descrizione>';
            myXML+='            </Esito>';
            myXML+='        </RispostaCodicePersonale>';
            myXML+='    </soapenv:Body>';
            myXML+='</soapenv:Envelope>                                                                                                                                                               ';
        }
        else if (TestCase == 'Error')
        {
            myXML=+'<?xml version=\'1.0\' encoding=\'utf-8\'?>';
            myXML+='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">';
            myXML+='    <soapenv:Body>';
            myXML+='        <RispostaCodicePersonale xmlns="http://bean.services.jdna6ws.app.directw.it">';
            myXML+='            <CodConf>0</CodConf>';
            myXML+='            <SigConf />';
            myXML+='            <DesConf />';
            myXML+='            <CodStato>0</CodStato>';
            myXML+='            <SigStato2 />';
            myXML+='            <SigStato3 />';
            myXML+='            <DesStato />';
            myXML+='            <CodRegione>0</CodRegione>';
            myXML+='            <DesRegione />';
            myXML+='            <SigProvincia />';
            myXML+='            <DesProvincia />';
            myXML+='            <DesLoc1 />';
            myXML+='            <DesLoc2 />';
            myXML+='            <TipoLocalita />';
            myXML+='            <CxTerr />';
            myXML+='            <NumPesoLoc>0.0</NumPesoLoc>';
            myXML+='            <Cognome />';
            myXML+='            <Nome />';
            myXML+='            <Sesso />';
            myXML+='            <DataNascita />';
            myXML+='            <CodiceFiscale1>123456789012345A</CodiceFiscale1>';
            myXML+='            <CodiceFiscale2 />';
            myXML+='            <Esito>';
            myXML+='                <Codice>8</Codice>';
            myXML+='                <Descrizione>DATI NON VALIDATI</Descrizione>';
            myXML+='            </Esito>';
            myXML+='            <Errori>';
            myXML+='                <Codice>8096</Codice>';
            myXML+='                <Tipo>8</Tipo>';
            myXML+='                <Descrizione>CHECK CF NON VALIDO</Descrizione>';
            myXML+='            </Errori>';
            myXML+='            <Errori>';
            myXML+='                <Codice>7896</Codice>';
            myXML+='                <Tipo>8</Tipo>';
            myXML+='                <Descrizione>MMNAS NON VALIDO/A</Descrizione>';
            myXML+='            </Errori>';
            myXML+='            <Errori>';
            myXML+='                <Codice>5196</Codice>';
            myXML+='                <Tipo>8</Tipo>';
            myXML+='                <Descrizione>NOME PROPRIO NON VALIDO </Descrizione>';
            myXML+='            </Errori>';
            myXML+='            <Errori>';
            myXML+='                <Codice>5096</Codice>';
            myXML+='                <Tipo>8</Tipo>';
            myXML+='                <Descrizione>COGNOME NON VALIDO</Descrizione>';
            myXML+='            </Errori>';
            myXML+='            <Errori>';
            myXML+='                <Codice>5005</Codice>';
            myXML+='                <Tipo>8</Tipo>';
            myXML+='                <Descrizione>DSCOG DATI NON SIGNIFICATIVI</Descrizione>';
            myXML+='            </Errori>';
            myXML+='        </RispostaCodicePersonale>';
            myXML+='    </soapenv:Body>';
            myXML+='</soapenv:Envelope>';
        }
        

        myXml=myXml.normalizespace();
        res.setBody(myXml);
        return res;


}  
  } PURE IT */