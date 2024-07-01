@isTest
global class campaignKPITest_Mock implements HttpCalloutMock {

    public String TestCase;

    global HTTPResponse respond(HTTPRequest req) {

   
      // Create a fake response

      HttpResponse res = new HttpResponse();

      //res.setHeader('Content-Type', 'application/json');
      
        string myResp='';
        
           if (TestCase == 'ClientiInTarget') {
            myResp='{ "totalSize" : 1, "done" : true, "records" : [ { "attributes" : { "type" : "AggregateResult" }, "expr0" : 1285 } ] }';
            }
            
             if (TestCase == 'ClientiPrioritari') {

              myResp='{ "totalSize" : 1, "done" : true, "records" : [ { "attributes" : { "type" : "AggregateResult" }, "expr0" : 1285 } ] }';
             }
        
            if (TestCase == 'ClientiLavorati') {
                
                myResp='{ "totalSize" : 1, "done" : true, "records" : [ { "attributes" : { "type" : "AggregateResult" }, "expr0" : 1285 } ] }';
            }
        
        if (TestCase == 'ClientiPrioritariLavorati') {

                myResp='{ "totalSize" : 1, "done" : true, "records" : [ { "attributes" : { "type" : "AggregateResult" }, "expr0" : 1285 } ] }';
        }
        
        if (TestCase == 'OpportunitaCreate'){
            
                myResp='{ "totalSize" : 1, "done" : true, "records" : [ { "attributes" : { "type" : "AggregateResult" }, "expr0" : 1285 } ] }';
        }
        
         if (TestCase == 'OpportunitaVinte'){
            
                myResp='{ "totalSize" : 1, "done" : true, "records" : [ { "attributes" : { "type" : "AggregateResult" }, "expr0" : 1285 } ] }';
    }
        
             
              if (TestCase == 'OpportunitaVinteClientiPrioritari'){
            
            myResp='{ "totalSize" : 1, "done" : true, "records" : [ { "attributes" : { "type" : "AggregateResult" }, "expr0" : 1285 } ] }';
        }
        
             if (TestCase == 'RevenueOpportunitaVinte'){
            
            myResp='{ "totalSize" : 1, "done" : true, "records" : [ { "attributes" : { "type" : "AggregateResult" }, "expr0" : 1285 } ] }';
        }
        if (TestCase == 'OpportunitaIncorso'){
            
            myResp='{ "totalSize" : 1, "done" : true, "records" : [ { "attributes" : { "type" : "AggregateResult" }, "expr0" : 1285 } ] }';
        }
        
        if (TestCase == 'RevenueOpportunitaInCorso'){
            
            myResp='{ "totalSize" : 1, "done" : true, "records" : [ { "attributes" : { "type" : "AggregateResult" }, "expr0" : 1285 } ] }';
        }
        if (TestCase == 'EmailSMSrecapitati'){
            
            myResp='{ "totalSize" : 1, "done" : true, "records" : [ { "attributes" : { "type" : "AggregateResult" }, "expr0" : 1285 } ] }';
        }
        
        if (TestCase == 'ClientiConEmailSMSInTarget'){
            
            myResp='{ "totalSize" : 1, "done" : true, "records" : [ { "attributes" : { "type" : "AggregateResult" }, "expr0" : 1285 } ] }';
        }
        if (TestCase == 'EmailSMSNonRecapitabili'){
            
            myResp='{ "totalSize" : 1, "done" : true, "records" : [ { "attributes" : { "type" : "AggregateResult" }, "expr0" : 1285 } ] }';
        }
        if (TestCase == 'ClientiConEmailInTarget'){
            
            myResp='{ "totalSize" : 1, "done" : true, "records" : [ { "attributes" : { "type" : "AggregateResult" }, "expr0" : 1285 } ] }';
        }
        if (TestCase == 'ClientiEmailApertaRichiestaContatto'){
            
            myResp= '{ "totalSize" : 1, "done" : true, "records" : [ { "attributes" : { "type" : "AggregateResult" }, "expr0" : 1285 } ] }';
        }
        if (TestCase == 'ClientiConSMSInTarget'){
            
            myResp='{ "totalSize" : 1, "done" : true, "records" : [ { "attributes" : { "type" : "AggregateResult" }, "expr0" : 1285 } ] }';
        }
        if (TestCase == 'ClientiSMSApertoRichiestaContatto'){
            
            myResp='{ "totalSize" : 1, "done" : true, "records" : [ { "attributes" : { "type" : "AggregateResult" }, "expr0" : 1285 } ] }';
        }
        if (TestCase == 'ClientiConEmailSMSAperti'){
            
            myResp='{ "totalSize" : 1, "done" : true, "records" : [ { "attributes" : { "type" : "AggregateResult" }, "expr0" : 1285 } ] }';
        }
        if (TestCase == 'ClientiPrioritariEmail'){
            
            myResp='{ "totalSize" : 1, "done" : true, "records" : [ { "attributes" : { "type" : "AggregateResult" }, "expr0" : 1285 } ] }';
        }
        if (TestCase == 'ClientiPrioritariSMS'){
            
            myResp='{ "totalSize" : 1, "done" : true, "records" : [ { "attributes" : { "type" : "AggregateResult" }, "expr0" : 1285 } ] }';
        }
        
        


            //myXml=myXml.normalizespace();

            res.setBody(myResp);
            
      //res.setStatusCode(200);

      return res;

    }

    
}