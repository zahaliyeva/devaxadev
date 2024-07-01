@isTest
global class getStatiMock_Test implements HttpCalloutMock{



    global HTTPResponse respond(HTTPRequest req) {

   
      // Create a fake response

      HttpResponse res = new HttpResponse();
            
            string myXML='';                                                                                                                                     
            myXML='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">   '+
            '<soapenv:Body>                                                                                                                                                                    '+
            '<RispostaStato xmlns="http://bean.services.jdna6hs.app.directw.it">                                                                                                               '+
            '<TabStato>                                                                                                                                                                        '+
            '   <NumOccorrenza>1</NumOccorrenza>                                                                                                                                               '+
            '    <CodStato>4</CodStato>                                                                                                                                                        '+
            '    <DesStato>AFGHANISTAN</DesStato>'+
            '    <SiglaStato2>AF</SiglaStato2>'+
            '    <SiglaStato3>AFG</SiglaStato3>'+
            '</TabStato>'+
            '<TabStato>'+
            '    <NumOccorrenza>2</NumOccorrenza>'+
            '    <CodStato>8</CodStato>'+
            '    <DesStato>ALBANIA</DesStato>'+
            '    <SiglaStato2>AL</SiglaStato2>'+
            '    <SiglaStato3>ALB</SiglaStato3>'+
            '</TabStato>'+
            '<TabStato>'+
            '    <NumOccorrenza>3</NumOccorrenza>'+
            '    <CodStato>12</CodStato>'+
            '    <DesStato>ALGERIA</DesStato>'+
            '    <SiglaStato2>DZ</SiglaStato2>'+
            '    <SiglaStato3>DZA</SiglaStato3>'+
            '</TabStato>'+
            '<TabStato>'+
            '    <NumOccorrenza>4</NumOccorrenza>'+
            '    <CodStato>16</CodStato>'+
            '    <DesStato>AMERICAN SAMOA</DesStato>'+
            '    <SiglaStato2>AS</SiglaStato2>'+
            '    <SiglaStato3>ASM</SiglaStato3>'+
            '</TabStato>'+
            '<TabStato>'+
            '    <NumOccorrenza>5</NumOccorrenza>'+
            '    <CodStato>20</CodStato>'+
            '    <DesStato>ANDORRA</DesStato>'+
            '    <SiglaStato2>AD</SiglaStato2>'+
            '    <SiglaStato3>AND</SiglaStato3>'+
            '</TabStato>'+
            '<TabStato>'+
            '    <NumOccorrenza>6</NumOccorrenza>'+
            '    <CodStato>24</CodStato>'+
            '    <DesStato>ANGOLA</DesStato>'+
            '    <SiglaStato2>AO</SiglaStato2>'+
            '    <SiglaStato3>AGO</SiglaStato3>'+
            '</TabStato>                         '+
            '   <Esito>'+
            '    <CodiceEsito>0</CodiceEsito>'+
            '</Esito>'+
            '    </RispostaStato>'+
    '               </soapenv:Body>'+
    '               </soapenv:Envelope>';   
    
    myXML=myXML.normalizespace();

      res.setBody(myXML);

      //res.setStatusCode(200);

      return res;


}

}