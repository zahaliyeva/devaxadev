@isTest
global class accountSearchMock_Test implements HttpCalloutMock{

 public String TestCase;


    global HTTPResponse respond(HTTPRequest req) {

   
      // Create a fake response

      HttpResponse res = new HttpResponse();

      //res.setHeader('Content-Type', 'application/json');
      string myXml='';
        if (TestCase == 'B2C') {
            myXml='<?xml version="1.0" encoding="UTF-8"?><S:Envelope xmlns:S="http://schemas.xmlsoap.org/soap/envelope/"><S:Body><ns2:ricercaSoggettoResponse xmlns:ns4="http://rgi.it/anag" xmlns:ns3="http://rgi.it/soa" xmlns:ns2="http://cif.service.rgi.it/"><return><codiceEsito>OK</codiceEsito><occorrenzeTrovate>1</occorrenzeTrovate><aSoggetto><tipoSoggetto>1</tipoSoggetto><denominazione></denominazione><cognome>PETRUZZI</cognome><nome>FABIO</nome><soggettoEstero>false</soggettoEstero><codiceFiscale>PTRFBA65D15H501S</codiceFiscale><partitaIva></partitaIva><localitaNascita>ROMA</localitaNascita><provinciaNascita>RM</provinciaNascita><sesso>1</sesso><dataNascita>1965-04-15T00:00:00+01:00</dataNascita><paese>ITA</paese><provincia>RM</provincia><localita>ROMA</localita><indirizzo>VIA PALMOLI 3</indirizzo><cap>00132</cap><codiceProfessione>42470</codiceProfessione><Ndg>0001270000135585</Ndg><cittadinanza></cittadinanza><cittadinanzaSeconda></cittadinanzaSeconda><Pep></Pep><tipologiaPEP></tipologiaPEP><caricaPEP></caricaPEP><ramoAttivita></ramoAttivita><codiceAttivita></codiceAttivita><codiceAteco></codiceAteco><tipoDocumento>1</tipoDocumento><numeroDocumento>AA1234567</numeroDocumento><dataInizioValidita>2010-06-08T00:00:00+02:00</dataInizioValidita><dataFineValidita>2020-06-08T00:00:00+02:00</dataFineValidita><autoritaRilascioDocumento>1</autoritaRilascioDocumento><localitaRilascioDocumento>ROMA</localitaRilascioDocumento><provinciaRilascioDocumento>RM</provinciaRilascioDocumento><codiceAgenzia>000127</codiceAgenzia><agenziaLight>false</agenziaLight><presenzaAlert>false</presenzaAlert><privacy1>true</privacy1><privacy2>false</privacy2><privacy3>false</privacy3><privacy4>false</privacy4><privacy5>false</privacy5><gestFin>false</gestFin><timestampCif>2017-06-01T17:53:09+02:00</timestampCif></aSoggetto></return></ns2:ricercaSoggettoResponse></S:Body></S:Envelope>';
        }
        if (TestCase == 'B2B') {    
            myXml='<?xml version="1.0" encoding="UTF-8"?><S:Envelope xmlns:S="http://schemas.xmlsoap.org/soap/envelope/"><S:Body><ns2:ricercaSoggettoResponse xmlns:ns4="http://rgi.it/anag" xmlns:ns3="http://rgi.it/soa" xmlns:ns2="http://cif.service.rgi.it/"><return><codiceEsito>OK</codiceEsito><occorrenzeTrovate>1</occorrenzeTrovate><aSoggetto><tipoSoggetto>2</tipoSoggetto><denominazione>ROSSI SRL</denominazione><cognome></cognome><nome></nome><soggettoEstero>false</soggettoEstero><codiceFiscale>08253490968</codiceFiscale><partitaIva>08253490968</partitaIva><localitaNascita></localitaNascita><provinciaNascita></provinciaNascita><sesso></sesso><paese>ITA</paese><provincia>MI</provincia><localita>MILANO</localita><indirizzo>CORSO BUENOS AIRES 15</indirizzo><cap>20124</cap><codiceProfessione></codiceProfessione><Ndg>0001270000135604</Ndg><fasciaFatturato></fasciaFatturato><sedeLegale></sedeLegale><sedeLegaleDirittoEstero></sedeLegaleDirittoEstero><ramoAttivita></ramoAttivita><codiceAttivita></codiceAttivita><tipoDocumento></tipoDocumento><numeroDocumento></numeroDocumento><autoritaRilascioDocumento></autoritaRilascioDocumento><localitaRilascioDocumento></localitaRilascioDocumento><provinciaRilascioDocumento></provinciaRilascioDocumento><codiceAgenzia>000127</codiceAgenzia><agenziaLight>false</agenziaLight><presenzaAlert>false</presenzaAlert><gestFin>false</gestFin><timestampCif>2017-06-05T18:07:52+02:00</timestampCif></aSoggetto></return></ns2:ricercaSoggettoResponse></S:Body></S:Envelope>';
        }
        if (TestCase == 'nonesiste'){
            
            myXml='<?xml version="1.0" encoding="UTF-8"?><S:Envelope xmlns:S="http://schemas.xmlsoap.org/soap/envelope/"><S:Body><ns2:ricercaSoggettoResponse xmlns:ns4="http://rgi.it/anag" xmlns:ns3="http://rgi.it/soa" xmlns:ns2="http://cif.service.rgi.it/"><return><codiceEsito>-206</codiceEsito><msgRisposta>Nessun dato trovato</msgRisposta><occorrenzeTrovate>0</occorrenzeTrovate></return></ns2:ricercaSoggettoResponse></S:Body></S:Envelope>';
        }   
           myXml=myXml.normalizespace();

      res.setBody(myXml);

      //res.setStatusCode(200);

      return res;

    }

}