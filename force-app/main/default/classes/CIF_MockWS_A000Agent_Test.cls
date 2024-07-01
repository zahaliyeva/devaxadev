/*------------------------------------------------------------------------
Author:        Veronica Chianura
Company:       Deloitte
Class:         CIF_MockWS_A000Agent_Test
Description:   Test
               VF Page: 
History

 04/02/2016 
 ---------------------------------------------------------------------------*/

@isTest
global class CIF_MockWS_A000Agent_Test implements HttpCalloutMock{



    global HTTPResponse respond(HTTPRequest req) {

   
      // Create a fake response

      HttpResponse res = new HttpResponse();

      //res.setHeader('Content-Type', 'application/json');
      string myXml='';
            myXml='<S:Envelope xmlns:S="http://schemas.xmlsoap.org/soap/envelope/"><S:Body><ns2:salvaSoggettoCrmResponse xmlns:ns2="http://crm.service.rgi.it/">'+
                                    '<return>'+
                                        '<esitoElaborazione>A000</esitoElaborazione>'+
                                        '<totaleOccorrenze>1</totaleOccorrenze>'+
                                        '<soggettoEsistente>'+
                                            '<tipoSoggetto>FISICO</tipoSoggetto>'+
                                            '<soggettoEstero>false</soggettoEstero>'+
                                            '<soggettoFisico>'+
                                                '<codiceFiscale>PNNMRI74C02I690F</codiceFiscale>'+
                                                '<cognome>PENNA US-0204</cognome>'+
                                                ' <nome>MARIO</nome> '+
                                                '<sesso>M</sesso>'+
                                                '<localitaNascita>SESTO SAN GIOVANNI</localitaNascita>'+
                                                '<provinciaNascita>MI</provinciaNascita> '+
                                                '<dataNascita>1974-03-02</dataNascita>'+
                                            '</soggettoFisico> '+
                                            '<datiDocumento> '+
                                                '<tipoDoc>PortoArmi</tipoDoc> '+
                                                '<numeroDoc>P88668</numeroDoc> '+
                                                '<dataRilascio>2007-02-07</dataRilascio>'+
                                                '<dataScadenza>2015-05-30</dataScadenza>'+
                                                '<autoritaRilascio>Questura</autoritaRilascio>'+
                                                '<siglaNazione/> '+
                                                '<provincia>MI</provincia>'+
                                                '<localita>MILANO</localita>'+
                                            '</datiDocumento> '+
                                            '<datiIndirizzo>'+
                                                '<indirizzo>VIA SARDEGNA 80</indirizzo>'+
                                                '<localita>SESTO SAN GIOVANNI</localita>'+
                                                ' <provincia>MI</provincia> '+
                                                '<siglaNazione/>'+
                                                '<frazione/>'+
                                            '</datiIndirizzo>'+
                                            '<codiceProfessione>P00018</codiceProfessione>'+
                                            '<codiceAgenzia>000828</codiceAgenzia>'+
 //                                           '<codiceAgenzia>004610</codiceAgenzia>'+
                                            ' <Ndg>0010010000115466</Ndg> '+
                                            ' <timestampCif>2015-11-23T15:39:44+01:00</timestampCif> '+
                                        ' </soggettoEsistente>'+
                                        '<messaggioErrore>Elaborazione terminata correttamente, soggetto inserito</messaggioErrore>'+
                                    '</return>'+
                                '</ns2:salvaSoggettoCrmResponse>   </S:Body></S:Envelope>';
           myXml=myXml.normalizespace();

      res.setBody(myXml);

      //res.setStatusCode(200);

      return res;

    }

}