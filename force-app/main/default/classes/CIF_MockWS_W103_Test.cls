/*------------------------------------------------------------------------
Author:        Veronica Chianura
Company:       Deloitte
Class:         CIF_MockWS_W103_Test
Description:   Test
               VF Page: 
History

 04/02/2016 
 ---------------------------------------------------------------------------*/

@isTest
global class CIF_MockWS_W103_Test implements HttpCalloutMock{



    global HTTPResponse respond(HTTPRequest req) {

   
      // Create a fake response

      HttpResponse res = new HttpResponse();

      //res.setHeader('Content-Type', 'application/json');
      string myXml='';
            myXml='<S:Envelope xmlns:S="http://schemas.xmlsoap.org/soap/envelope/"><S:Body><ns2:salvaSoggettoCrmResponse xmlns:ns2="http://crm.service.rgi.it/">'+
                                    '<return>'+
                                        '<esitoElaborazione>W103</esitoElaborazione>'+
                                        '<totaleOccorrenze>0</totaleOccorrenze>'+                                
                                        '<messaggioErrore>Codice fiscale non congruente con dati soggetto</messaggioErrore>'+
                                    '</return>'+
                                '</ns2:salvaSoggettoCrmResponse>   </S:Body></S:Envelope>';
           myXml=myXml.normalizespace();

      res.setBody(myXml);

      //res.setStatusCode(200);

      return res;

    }

}