/*------------------------------------------------------------------------
Author:        Veronica Chianura
Company:       Deloitte
Class:         CIF_MockWS_A001_Test
Description:   Test
               VF Page: 
History

 04/02/2016 
 ---------------------------------------------------------------------------*/

@isTest
global class CIF_MockWS_A001_Test implements HttpCalloutMock{



    global HTTPResponse respond(HTTPRequest req) {

   
      // Create a fake response

      HttpResponse res = new HttpResponse();

      //res.setHeader('Content-Type', 'application/json');
      string myXml='';
            myXml='<S:Envelope xmlns:S="http://schemas.xmlsoap.org/soap/envelope/"><S:Body><ns2:salvaSoggettoCrmResponse xmlns:ns2="http://crm.service.rgi.it/">'+
                                    '<return>'+
                                        '<esitoElaborazione>A001</esitoElaborazione>'+
                                        '<totaleOccorrenze>4</totaleOccorrenze>'+
                                        '<soggettoEsistente>'+
                                            '<tipoSoggetto>FISICO</tipoSoggetto>'+
                                            '<soggettoEstero>false</soggettoEstero>'+
                                            '<soggettoFisico>'+
                                                '<codiceFiscale>A123456789012345</codiceFiscale>'+
                                                '<cognome>SODINI</cognome>'+
                                                '<nome>SANDRO</nome>'+
                                                '<sesso>M</sesso>'+
                                                '<localitaNascita>TORINO</localitaNascita>'+
                                                '<provinciaNascita>TO</provinciaNascita> '+
                                                '<dataNascita>1987-01-04T00:00:00+01:00</dataNascita>'+
                                            '</soggettoFisico> '+
                                            '<datiDocumento> '+
                                                '<tipoDoc>PortoArmi</tipoDoc> '+
                                                '<numeroDoc>P88668</numeroDoc> '+
                                                '<dataRilascio>2007-02-07</dataRilascio>'+
                                                '<dataScadenza>2015-05-30</dataScadenza>'+
                                                '<autoritaRilascio>Questura</autoritaRilascio>'+
                                                '<siglaNazione>ITA</siglaNazione>'+
                                                '<provincia>MI</provincia>'+
                                                '<localita>MILANO</localita>'+
                                            '</datiDocumento> '+
                                            '<datiIndirizzo>'+
                                                '<indirizzo>VIA GARIBALDI 80</indirizzo>'+
                                                '<localita>LAMBRATE</localita>'+
                                                ' <provincia>MI</provincia> '+
                                                '<siglaNazione>ITA</siglaNazione>'+
                                                '<frazione/>'+
                                            '</datiIndirizzo>'+
                                            '<codiceProfessione>41O0011</codiceProfessione>'+
                                            //'<codiceAgenzia>004610</codiceAgenzia>'+
                                            '<codiceAgenzia>000828</codiceAgenzia>'+
                                            '<codiceSubAgenzia>000828000028</codiceSubAgenzia>'+
                                            '<codiceSubAgenzia>000828000029</codiceSubAgenzia>'+
                                           // '<codiceSubAgenzia>004610000030</codiceSubAgenzia>'+
                                           // ' <Ndg>0046100000000137</Ndg> '+
                                            '<Ndg>0008280000000001</Ndg>'+
                                            ' <timestampCif>2015-11-23T15:39:44+01:00</timestampCif> '+
                                        ' </soggettoEsistente>'+
                                        '<soggettoEsistente>'+
                                            '<tipoSoggetto>FISICO</tipoSoggetto>'+
                                            '<soggettoEstero>false</soggettoEstero>'+
                                            '<soggettoFisico>'+
                                                '<codiceFiscale>B123456789012345</codiceFiscale>'+
                                                '<cognome>Bastoni</cognome>'+
                                                '<nome>Luca</nome>'+
                                                '<sesso>M</sesso>'+
                                                '<localitaNascita>Treviglio</localitaNascita>'+
                                                '<provinciaNascita>BG</provinciaNascita> '+
                                                '<dataNascita>1993-11-09T00:00:00+01:00</dataNascita>'+
                                            '</soggettoFisico> '+
                                            '<datiDocumento> '+
                                                '<tipoDoc>PortoArmi</tipoDoc> '+
                                                '<numeroDoc>P88668</numeroDoc> '+
                                                '<dataRilascio>2007-02-07</dataRilascio>'+
                                                '<dataScadenza>2015-05-30</dataScadenza>'+
                                                '<autoritaRilascio>Questura</autoritaRilascio>'+
                                                '<siglaNazione>ITA</siglaNazione>'+
                                                '<provincia>MI</provincia>'+
                                                '<localita>MILANO</localita>'+
                                            '</datiDocumento> '+
                                            '<datiIndirizzo>'+
                                                '<indirizzo>via Aldo Moro</indirizzo>'+
                                                '<localita>Linate</localita>'+
                                                ' <provincia>MI</provincia> '+
                                                '<siglaNazione>ITA</siglaNazione>'+
                                                '<frazione/>'+
                                            '</datiIndirizzo>'+
                                            '<codiceProfessione>12V0185</codiceProfessione>'+
                                            '<codiceAgenzia>000828</codiceAgenzia>'+
                                            //'<codiceAgenzia>004610</codiceAgenzia>'+
                                            '<codiceSubAgenzia>000828000028</codiceSubAgenzia>'+
                                            //'<codiceSubAgenzia>004610000030</codiceSubAgenzia>'+
                                            ' <Ndg>Esempio NDG2</Ndg> '+
                                            ' <timestampCif>2015-11-23T15:39:44+01:00</timestampCif> '+
                                        ' </soggettoEsistente>'+
                                        '<soggettoEsistente>'+
                                            '<tipoSoggetto>FISICO</tipoSoggetto>'+
                                            '<soggettoEstero>false</soggettoEstero>'+
                                            '<soggettoFisico>'+
                                                '<codiceFiscale>C123456789012345</codiceFiscale>'+
                                                '<cognome>Barbieri</cognome>'+
                                                '<nome>Antonino</nome>'+
                                                '<sesso>M</sesso>'+
                                                '<localitaNascita>Napoli</localitaNascita>'+
                                                '<provinciaNascita>NA</provinciaNascita> '+
                                                '<dataNascita>1970-03-04T00:00:00+01:00</dataNascita>'+
                                            '</soggettoFisico> '+
                                            '<datiDocumento> '+
                                                '<tipoDoc>PortoArmi</tipoDoc> '+
                                                '<numeroDoc>P88668</numeroDoc> '+
                                                '<dataRilascio>2007-02-07</dataRilascio>'+
                                                '<dataScadenza>2015-05-30</dataScadenza>'+
                                                '<autoritaRilascio>Questura</autoritaRilascio>'+
                                                '<siglaNazione>ITA</siglaNazione>'+
                                                '<provincia>MI</provincia>'+
                                                '<localita>MILANO</localita>'+
                                            '</datiDocumento> '+
                                            '<datiIndirizzo>'+
                                                '<indirizzo>via Mazzini</indirizzo>'+
                                                '<localita>Seriate</localita>'+
                                                ' <provincia>MI</provincia> '+
                                                '<siglaNazione>ITA</siglaNazione>'+
                                                '<frazione/>'+
                                            '</datiIndirizzo>'+
                                            '<codiceProfessione>21V0015</codiceProfessione>'+
                                           // '<codiceAgenzia>004610</codiceAgenzia>'+
                                            '<codiceAgenzia>000828</codiceAgenzia>'+
                                            //'<codiceSubAgenzia>004610000031</codiceSubAgenzia>'+
                                            '<codiceSubAgenzia>000828000029</codiceSubAgenzia>'+
                                            ' <Ndg>Esempio NDG3</Ndg> '+
                                            ' <timestampCif>2015-11-23T15:39:44+01:00</timestampCif> '+
                                        ' </soggettoEsistente>'+
                                        '<soggettoEsistente>'+
                                            '<tipoSoggetto>GIURIDICO</tipoSoggetto>'+
                                            '<soggettoEstero>false</soggettoEstero>'+
                                            '<soggettoGiuridico>'+
                                                '<partitaIva>ESPARTITAIVA</partitaIva>'+
                                                '<denominazione>es_denominazione</denominazione>'+
                                            '</soggettoGiuridico> '+
                                            '<datiDocumento> '+
                                                '<tipoDoc>PortoArmi</tipoDoc> '+
                                                '<numeroDoc>P88668</numeroDoc> '+
                                                '<dataRilascio>2007-02-07</dataRilascio>'+
                                                '<dataScadenza>2015-05-30</dataScadenza>'+
                                                '<autoritaRilascio>Questura</autoritaRilascio>'+
                                                '<siglaNazione>ITA</siglaNazione>'+
                                                '<provincia>MI</provincia>'+
                                                '<localita>MILANO</localita>'+
                                            '</datiDocumento> '+
                                            '<datiIndirizzo>'+
                                                '<indirizzo>via Mazzini</indirizzo>'+
                                                '<localita>Seriate</localita>'+
                                                ' <provincia>MI</provincia> '+
                                                '<siglaNazione>ITA</siglaNazione>'+
                                                '<frazione/>'+
                                            '</datiIndirizzo>'+
                                            '<codiceProfessione>21V0015</codiceProfessione>'+
                                          //  '<codiceAgenzia>004610</codiceAgenzia>'+
                                            '<codiceAgenzia>000828</codiceAgenzia>'+
                                           // '<codiceSubAgenzia>004610000031</codiceSubAgenzia>'+
                                            '<codiceSubAgenzia>000828000028</codiceSubAgenzia>'+
                                            ' <Ndg>0046100000999999</Ndg> '+
                                            ' <timestampCif>2015-11-23T15:39:44+01:00</timestampCif> '+
                                        ' </soggettoEsistente>'+                                        
                                        '<messaggioErrore>Elaborazione terminata correttamente, soggetto non inserito in quanto già presente</messaggioErrore>'+
                                    '</return>'+
                                '</ns2:salvaSoggettoCrmResponse>   </S:Body></S:Envelope>';
           myXml=myXml.normalizespace();

      res.setBody(myXml);

      //res.setStatusCode(200);

      return res;

    }

}