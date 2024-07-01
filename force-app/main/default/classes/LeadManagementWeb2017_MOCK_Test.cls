global class LeadManagementWeb2017_MOCK_Test implements HttpCalloutMock{
/*------------------------------------------------------------------------
Author:        Andrea Capobianco
Company:       Deloitte
Class:         LeadManagementWeb2017_MOCK_Test
Description:   Test
            
History
27/06/2017 - Created
---------------------------------------------------------------------------*/
      public String TestCase;

      global HTTPResponse respond(HTTPRequest req) {

            // Create a fake response.
            HttpResponse res = new HttpResponse();
            // Set response values, and 
            string myJSON = '';
            
            if(testCase=='testCase_1') { 
                  myJSON ='{ "resultsNumber": "1", "results": [ { "metadata": { "distance": "2311.5637", "agency": { "agencyId": "4610", "holder": "VALANDRO GROUP S.A.S. DI VALANDRO QUIRINO E C.", "institutionalEmail": "AG1404@AXA-AGENZIE.IT", "CAP": "20144", "city": "MILANO", "address": "VIA ELBA 10", "province": "MI", "institutionalWebSite": "HTTP://AGENZIE.AXA.IT/VIGEVANO1404", "venueType": "S", "venueId": "461000988" }, "ranking": [ { "vitaQuotation": "1452", "ratailQuotation": "7775", "autoQuotation": "16357", "clQuotation": "2656" }] }, "location": { "latitude": 9.156359007895452E15, "longitude": 4.546512680103348E15 } } ] }';
                  
                  res.setHeader('Content-Type', 'application/json');
                  res.setBody(myJSON); 
                  res.setStatusCode(200);
            }

            if(testCase=='testCase_2') {
                  myJSON ='{ "resultsNumber": "2", "results": [ { "metadata": { "distance": "28878.56", "agency": { "agencyId": "0828", "holder": "VALANDRO GROUP S.A.S. DI VALANDRO QUIRINO E C.", "institutionalEmail": "AG1404@AXA-AGENZIE.IT", "region": "LOMBARDIA", "CAP": "27029", "city": "VIGEVANO", "address": "VIA BERTOLINI 49/51", "telephones": [ { "prefered": true, "telephoneNumber": "0381-34071", "type": "OTHER" }, { "prefered": false, "telephoneNumber": "0381-42744", "type": "FAX" } ], "province": "PV", "institutionalWebSite": "HTTP://AGENZIE.AXA.IT/VIGEVANO1404", "venueType": "P" }, "ranking": [ { "vitaQuotation": "1452", "ratailQuotation": "7775", "autoQuotation": "16357", "clQuotation": "2656" }] }, "location": { "latitude": 4.5320140501066696E16, "longitude": 8.879996807987856E15 } }, { "metadata": { "distance": "2311.5637", "agency": { "agencyId": "4610", "holder": "VALANDRO GROUP S.A.S. DI VALANDRO QUIRINO E C.", "institutionalEmail": "AG1404@AXA-AGENZIE.IT", "CAP": "20144", "city": "MILANO", "address": "VIA ELBA 10", "province": "MI", "institutionalWebSite": "HTTP://AGENZIE.AXA.IT/VIGEVANO1404", "venueType": "S", "venueId": "25" }, "ranking": [ { "vitaQuotation": "1452", "ratailQuotation": "7775", "autoQuotation": "16357", "clQuotation": "2656" }] }, "location": { "latitude": 9.156359007895452E15, "longitude": 4.546512680103348E15 } } ] }';
            
                  res.setHeader('Content-Type', 'application/json');
                  res.setBody(myJSON); 
                  res.setStatusCode(200);
            }

            if(testCase=='testCase_3'){
                  myJSON = '{ "code": "1", "userMessage": "An internal system error occurred", "developerMessage": "System error", "maintenanceEndDate": "2015-09-14T10:00:00", "errors": [ { "location": "string", "message": "string" } ], "links": { "rel": "string", "uri": "string", "method": "string" } }';
            
                  res.setHeader('Content-Type', 'application/json');
                  res.setBody(myJSON); 
                  res.setStatusCode(400);
            }

            if(testCase=='testCase_4') {
                  myJSON ='{"resultsNumber":"3","results":[{"metadata":{"agency":{"agencyId":"828","holder":"APOLLONI S.R.L.","institutionalEmail":"AG5931@AXA-AGENZIE.IT","region":"LAZIO","CAP":"00135","city":"ROMA","address":"VIA TORBOLE 56","telephones":[{"prefered":true,"telephoneNumber":"06-3242104","type":"OTHER"},{"prefered":false,"telephoneNumber":"06-3611857","type":"FAX"}],"province":"RM","institutionalWebSite":"HTTP://AGENZIE.AXA.IT/ROMA5931","venueType":"S",             "venueId": "82800025"},"ranking":[{"vitaQuotation":"581","ratailQuotation":"1934","autoQuotation":"3344","clQuotation":"1021"}]},"location":{"latitude":41.95225000101051,"longitude":12.4501616062337}},{"metadata":{"agency":{"agencyId":"0127","holder":"DACOTA S.R.L.","institutionalEmail":"AG5959@AXA-AGENZIE.IT","region":"LAZIO","CAP":"00161","city":"ROMA","address":"VIA NOMENTANA 257","telephones":[{"prefered":true,"telephoneNumber":"06-8549401","type":"OTHER"},{"prefered":false,"telephoneNumber":"06-8845201","type":"OTHER"},{"prefered":false,"telephoneNumber":"06-8845201","type":"FAX"}],"province":"RM","institutionalWebSite":"HTTP://AGENZIE.AXA.IT/ROMA5959","venueType":"P"},"ranking":[{"vitaQuotation":"806","ratailQuotation":"2235","autoQuotation":"1267","clQuotation":"1018"}]},"location":{"latitude":41.91492300099744,"longitude":12.508992006213225}},{"metadata":{"agency":{"agencyId":"4610","holder":"ASSICURAZIONI QUIRINALE S.R.L.","institutionalEmail":"AG5838@AXA-AGENZIE.IT","region":"LAZIO","CAP":"00187","city":"ROMA","address":"VIA XX SETTEMBRE 3","telephones":[{"prefered":true,"telephoneNumber":"06-42903601","type":"OTHER"},{"prefered":false,"telephoneNumber":"06-42904157","type":"FAX"}],"province":"RM","institutionalWebSite":"HTTP://AGENZIE.AXA.IT/ROMA5838","venueType":"S","venueId": "461000988"},"ranking":[{"vitaQuotation":"389","ratailQuotation":"1550","autoQuotation":"2293","clQuotation":"847"}]},"location":{"latitude":41.902482101003585,"longitude":12.491300506216968}}]}';
            
                  res.setHeader('Content-Type', 'application/json');
                  res.setBody(myJSON); 
                  res.setStatusCode(200);
            }


            return res;
      }
}