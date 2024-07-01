@isTest
global class SearchTaskDAOLMock_Test implements HttpCalloutMock{

  global HTTPResponse respond(HTTPRequest req) {

   
      // Create a fake response

      HttpResponse res = new HttpResponse();

      //res.setHeader('Content-Type', 'application/json');
        string myXml='';
           
            myXml='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">'
+'                        <soapenv:Body>'
+'                            <tns:isFascicoliAnagApertiOrNonConsegnatiResponse xmlns:tns="http://rgi.it/WS_REOL_Service">'
+'                                <tns:result>'
+'                                    <tns:check>true</tns:check>'
+'                                </tns:result>'
+'                            </tns:isFascicoliAnagApertiOrNonConsegnatiResponse>'
+'                        </soapenv:Body>'
+'                    </soapenv:Envelope>';
            myXml=myXml.normalizespace();

            res.setBody(myXml);
            
      res.setStatusCode(200);

      return res;

    }








}