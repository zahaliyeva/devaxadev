/*------------------------------------------------------------------------
Author:        Anna Riccardi
Company:       Deloitte
Class:         HTTP_Rest_Request_Mock_Test
Description:   Response Test
               
History

2/05/2016     Anna Riccardi
----------------------------------------------------------------------------*/
@isTest
global class HTTP_Rest_Request_Mock_Test implements HttpCalloutMock {

    public String TestCase;

    global HTTPResponse respond(HTTPRequest req) {
    	
    	
    	system.debug('AAAAAAAAAAAAAAAAAAAAAAAAAAAAA sono nella classe HTTP_Rest_Request_Mock_Test');
    	system.debug('AAAAAAAAAAAAAAAAAAAAAAAAAAAAA value of TestCase' + TestCase);
    	
        // Create a fake response.
        HttpResponse res = new HttpResponse();
        //req.setClientCertificateName('AXA_PRE_CA04'); -- CAPOBIANCO_A 17/01/2018 COMMENTED

        // Set response values, and 
        string myJSON = '';
        if (TestCase == 'Response1') {
        	
       		//myJSON = '{"coverages":[{"name": "ASSISTENZA","id": "COAS","categoryName": "TUR\'ANI ROBERTO","categoryId":"118134595.000000000000000","Beneficiaries": [{"BeneficiaryName": "Beneficiario1"},{"BeneficiaryName": "Beneficiario1"}],"restrictions": [{"type": "MAXLIMIT","value": 260000,"unitCode": "€","applicationCase": "PROVA","description": "260,000 € SOMMA ASSICURATA xxxxxxxxxxxxxxxxxxxxx     xxxx     aaaaaaaaa  xxxxxx"},{"type": "MAXLIMIT","value": 260000,"unitCode": "€", "description": "260,000 € SOMMA ASSICURATA"}]},{"name": "INVALIDITÀ PERMANENTE DA MALATTIA","id": "COIPM", "categoryName": "TURA ROBERTO"  ,"categoryId": "118134595.000000000000000","restrictions": [{"type": "MAXLIMIT","value": 260000,"unitCode": "€","description": "260,000 € SOMMA ASSICURATA"}]},{"name": "GARANZIA GENERICA (CRITERI PER PRODOTTO)","id": "CONTTT","categoryName": "TURANI ROBERTO","categoryId": "118134595.000000000000000"}]}' ;   
        
        	myJSON = '[{"name": "ASSISTENZA","id": "COAS","categoryName": "TUR\'ANI ROBERTO","categoryId":"118134595.000000000000000","Beneficiaries": [{"BeneficiaryName": "Beneficiario1"},{"BeneficiaryName": "Beneficiario1"}],"restrictions": [{"type": "MAXLIMIT","value": 260000,"unitCode": "€","applicationCase": "PROVA","description": "260,000 € SOMMA ASSICURATA xxxxxxxxxxxxxxxxxxxxx     xxxx     aaaaaaaaa  xxxxxx"},{"type": "MAXLIMIT","value": 260000,"unitCode": "€", "description": "260,000 € SOMMA ASSICURATA"}]},{"name": "INVALIDITÀ PERMANENTE DA MALATTIA","id": "COIPM", "categoryName": "TURA ROBERTO"  ,"categoryId": "118134595.000000000000000","restrictions": [{"type": "MAXLIMIT","value": 260000,"unitCode": "€","description": "260,000 € SOMMA ASSICURATA"}]},{"name": "GARANZIA GENERICA (CRITERI PER PRODOTTO)","id": "CONTTT","categoryName": "TURANI ROBERTO","categoryId": "118134595.000000000000000"}]' ;   
        }
          
       if (TestCase=='ERRORT300') {
       	
         	myJSON =  '{"code": "T710","developerMessage": "An error occurred when calling a service from the entity", "userMessage": "test"}';
       }
       
       if (TestCase=='Response2'){
       	
           	myJson='{"coverages":[{"name":"ASSISTENZA","id":"COAS","other":"text","shortDescriptionLines":["string"],"categoryName":"TURANI ROBERTO","categoryId":"118134595.000000000000000","riderName":"prova","effectiveDate":"2016-01-15","clauses":["test"],"expirationDate":"2016-01-15","beneficiaries":[{"BeneficiaryName":"Beneficiario1"},{"BeneficiaryName":"Beneficiario1"}],"restrictions":[{"type":"MAXLIMIT","value":260000,"unitCode":"€","applicationCase":"PROVA","description":"260,000 € SOMMA ASSICURATA xxxxxxxxxxxxxxxxxxxxx     xxxx     aaaaaaaaa  xxxxxx"},{"type":"MAXLIMIT","value":260000,"unitCode":"€","description":"260,000 € SOMMA ASSICURATA"}],"benefit":{"descriptionLines":["string"],"lumpSumBenefit":{"value":2323,"currencyCode":"EUR"},"scheduledBenefit":{"periodicity":{"code":"EVERY_YEAR","name":"Annually"},"endDate":"2020-01-01","yearlyRenewalDate":"2016-01-01"}}},{"name":"INVALIDITÀ PERMANENTE DA MALATTIA","id":"COIPM","categoryName":"TURA ROBERTO","categoryId":"118134595.000000000000000","restrictions":[{"type":"MAXLIMIT","value":260000,"unitCode":"€","description":"260,000 € SOMMA ASSICURATA"}]},{"name":"GARANZIA GENERICA (CRITERI PER PRODOTTO)","id":"CONTTT","categoryName":"TURANI ROBERTO","categoryId":"118134595.000000000000000"}]}' ;
       }
       
       if (TestCase == 'garanzieTableErrorT300'){
       		
          /* CAPOBIANCO_A 17/01/2018 -- START
       		String json = '{' + 
   							'"code":"T300",' +
   							'"developerMessage":"The requested policy does not exist for this digital account",' +
   							'"userMessage":"The requested policy does not exist for this digital account"' +
						'}' ;      	
       	
       		myJson= json;
          */

          myJSON =  '{"code": "T300","developerMessage": "The requested policy does not exist for this digital account", "userMessage": "The requested policy does not exist for this digital account"}';
          system.debug('#@#@ myJSON '+myJSON);

          //CAPOBIANCO_A 17/01/2018 -- END
       }
                 
        // return response.
           
        res.setHeader('Content-Type', 'application/json');
        res.setBody(myJSON); 
        //CAPOBIANCO_A 17/01/2018 -- START
        if (TestCase == 'garanzieTableErrorT300' || TestCase == 'ERRORT300')
        {
          res.setStatusCode(300);
        }
        else{
          res.setStatusCode(200);
        }
        //CAPOBIANCO_A 17/01/2018 -- END
  
      	return res;
    }
}