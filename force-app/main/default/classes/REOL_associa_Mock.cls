/*------------------------------------------------------------------------
Author:        Davide Fabris
Company:       Deloitte
Class:         CIF_Nodes_Mock 
Description:   Test
            
History
15/06/2016 - Created
---------------------------------------------------------------------------*/

global class REOL_associa_Mock implements HttpCalloutMock{

    public String TestCase;
	public String OppId = '0068E000004lZtdQAE';

    global HTTPResponse respond(HTTPRequest req) {



        // Create a fake response based on the attribute TestCase
        HttpResponse res = new HttpResponse();

        string myXml='';
        
        if (TestCase=='OK_GET') {
            myXML='<S:Envelope xmlns:S="http://schemas.xmlsoap.org/soap/envelope/">'
            +' <S:Body>'
            +'    <ns3:getElencoProposteAssociabiliSalesForceResponse xmlns:ns2="http://rgi.it/soa" xmlns:ns3="http://rgi.it/axa" xmlns:ns4="http://rgi.it/WSPassPro">'
            +'       <return>'
            +'          <codeResult>OK</codeResult>'
            +'          <descResult>Elenco delle proposte estratto correttamente</descResult>'
            +'          <elencoProposteAssociabiliSalesForce>                '
            +'             <numeroProposta>45258</numeroProposta>            '
            +'          </elencoProposteAssociabiliSalesForce>               '
            +'          <elencoProposteAssociabiliSalesForce>                '
            +'             <numeroProposta>45533</numeroProposta>            '
            +'          </elencoProposteAssociabiliSalesForce>               '
            +'          <elencoProposteAssociabiliSalesForce>                '
            +'             <numeroProposta>45475</numeroProposta>            '
            +'          </elencoProposteAssociabiliSalesForce>               '
            +'          <elencoProposteAssociabiliSalesForce>                '
            +'             <numeroProposta>45476</numeroProposta>            '
            +'          </elencoProposteAssociabiliSalesForce>               '
            +'          <elencoProposteAssociabiliSalesForce>                '
            +'             <numeroProposta>45477</numeroProposta>            '
            +'          </elencoProposteAssociabiliSalesForce>               '
            +'          <elencoProposteAssociabiliSalesForce>                '
            +'             <numeroProposta>45672</numeroProposta>            '
            +'          </elencoProposteAssociabiliSalesForce>               '
            +'          <elencoProposteAssociabiliSalesForce>                '
            +'             <numeroProposta>45490</numeroProposta>            '
            +'          </elencoProposteAssociabiliSalesForce>               '
            +'          <elencoProposteAssociabiliSalesForce>                '
            +'             <numeroProposta>45492</numeroProposta>            '
            +'          </elencoProposteAssociabiliSalesForce>               '
            +'          <elencoProposteAssociabiliSalesForce>                '
            +'             <numeroProposta>45285</numeroProposta>            '
            +'          </elencoProposteAssociabiliSalesForce>               '
            +'          <elencoProposteAssociabiliSalesForce>                '
            +'             <numeroProposta>45745</numeroProposta>            '
            +'          </elencoProposteAssociabiliSalesForce>               '
            +'          <elencoProposteAssociabiliSalesForce>                '
            +'             <numeroProposta>45454</numeroProposta>            '
            +'          </elencoProposteAssociabiliSalesForce>               '
            +'          <elencoProposteAssociabiliSalesForce>                '
            +'             <numeroProposta>45265</numeroProposta>            '
            +'          </elencoProposteAssociabiliSalesForce>               '
            +'          <elencoProposteAssociabiliSalesForce>                '
            +'             <numeroProposta>45700</numeroProposta>            '
            +'          </elencoProposteAssociabiliSalesForce>               '
            +'          <elencoProposteAssociabiliSalesForce>                '
            +'             <numeroProposta>45474</numeroProposta>            '
            +'          </elencoProposteAssociabiliSalesForce>               '
            +'          <elencoProposteAssociabiliSalesForce>                '
            +'             <numeroProposta>45465</numeroProposta>            '
            +'          </elencoProposteAssociabiliSalesForce>               '
            +'          <elencoProposteAssociabiliSalesForce>                '
            +'             <numeroProposta>45282</numeroProposta>            '
            +'          </elencoProposteAssociabiliSalesForce>               '
            +'       </return>                                               '
            +'    </ns3:getElencoProposteAssociabiliSalesForceResponse>      '
            +' </S:Body>'
            +'</S:Envelope>';
        }
        
        if (TestCase=='OK_GET_2') {
            myXML = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">'
 +'  <soapenv:Body>'
 +'     <tns:getElencoProposteAssociabiliSalesForceResponse xmlns:tns="http://rgi.it/WS_REOL_Service"> '
 +'        <tns:result>                                                                                '
 +'           <tns:message>Operazione andata a buon fine</tns:message>                                 '
 +'           <tns:result>OK</tns:result>                                                              '
 +'           <tns:elencoProposteAssociabiliSalesForce>                                                '
 +'              <tns:numeroProposta>45258</tns:numeroProposta>                                        '
 +'              <tns:dataEffetto>2016-05-16T00:00:00+02:00</tns:dataEffetto>                          '
 +'              <tns:dataScadenza>2016-05-16T00:00:00+02:00</tns:dataScadenza>                        '
 +'              <tns:dataFineValidita>2016-05-16T00:00:00+02:00</tns:dataFineValidita>                '
 +'              <tns:productCode>1E16</tns:productCode>                                               '
 +'              <tns:productName>All Risks Aziende</tns:productName>                                  '
 +'              <tns:subAsaDesc>desc ASA</tns:subAsaDesc>                                             '
 +'              <tns:propostaStatusDesc/>                                                             '
 +'              <tns:dataUltimaModifica>2016-05-16T00:00:00+02:00</tns:dataUltimaModifica>            '
 +'              <tns:lastModifiedBy>author</tns:lastModifiedBy>                                       '
 +'           </tns:elencoProposteAssociabiliSalesForce>                                               '
 +'           <tns:elencoProposteAssociabiliSalesForce>                                                '
 +'              <tns:numeroProposta>45259</tns:numeroProposta>                                        '
 +'              <tns:dataEffetto>2016-05-16T00:00:00+02:00</tns:dataEffetto>                          '
 +'              <tns:dataScadenza>2016-05-16T00:00:00+02:00</tns:dataScadenza>                        '
 +'              <tns:dataFineValidita>2016-05-16T00:00:00+02:00</tns:dataFineValidita>                '
 +'              <tns:productCode>1E16</tns:productCode>                                               '
 +'              <tns:productName>All Risks Aziende</tns:productName>                                  '
 +'              <tns:subAsaDesc>desc ASA</tns:subAsaDesc>                                             '
 +'              <tns:propostaStatusDesc>Prop.da Autor.</tns:propostaStatusDesc>                       '
 +'              <tns:dataUltimaModifica>2016-05-16T00:00:00+02:00</tns:dataUltimaModifica>            '
 +'              <tns:lastModifiedBy>author1</tns:lastModifiedBy>                                      '
 +'           </tns:elencoProposteAssociabiliSalesForce>                                               '
 +'        </tns:result>                                                                               '
 +'     </tns:getElencoProposteAssociabiliSalesForceResponse>                                          '
 +'  </soapenv:Body>'
+'</soapenv:Envelope>';
            
        }

        if (TestCase=='ERROR_GET') {
            myXml='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">'
            + ' <soapenv:Body>'
            +    '<soapenv:Fault>'
            +     '  <faultcode>soapenv:Server</faultcode>'
            +     '  <faultstring>[ISS.0088.9256] Fault returned by invoked service</faultstring>'
            +      ' <faultactor>http://dvamreip01.ppmail.ppservices.axa-tech.intraxa:5540/ws</faultactor>'
            +       '<detail>'
            +        '  <tns:getElencoProposteAssociabiliSalesForceFault xmlns:tns="http://rgi.it/WS_REOL_Service">'
            +         '    <tns:getElencoProposteAssociabiliSalesForceFault>'
            +          '      <exc:errorType xmlns:exc="http://aems.corp.intraxa/eip/2013/07/schemas/fault">BusinessError</exc:errorType>'
            +           '     <exc:errorDescription xmlns:exc="http://aems.corp.intraxa/eip/2013/07/schemas/fault">Elenco proposte non trovate secondo il criterio di ricerca in input</exc:errorDescription>'
            +            '    <exc:errorValue xmlns:exc="http://aems.corp.intraxa/eip/2013/07/schemas/fault">ER_REOL_00</exc:errorValue>'
            +             '</tns:getElencoProposteAssociabiliSalesForceFault>'
            +          '</tns:getElencoProposteAssociabiliSalesForceFault>'
            +       '</detail>'
            +    '</soapenv:Fault>'
            + '</soapenv:Body>'
            +'</soapenv:Envelope>';
        }
        
        
        if (TestCase=='ERROR_ASSOCIA') {
            myXml = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">'+
            '<soapenv:Body>'+
            '  <soapenv:Fault>'+
            '    <faultcode>soapenv:Server</faultcode>'+
            '   <faultstring>[ISS.0088.9256] Fault returned by invoked service</faultstring>'+
            '  <faultactor>http://dvamreip01.ppmail.ppservices.axa-tech.intraxa:5540/ws</faultactor>'+
            ' <detail>'+
            '   <tns:associazioneProposteSalesForceFault xmlns:tns="http://rgi.it/WS_REOL_Service">'+
            '     <tns:associazioneProposteSalesForceFault>'+
            '       <exc:errorType xmlns:exc="http://aems.corp.intraxa/eip/2013/07/schemas/fault">BusinessError</exc:errorType>'+
            '      <exc:errorDescription xmlns:exc="http://aems.corp.intraxa/eip/2013/07/schemas/fault">La chiave idOpp xxxxx risulta già associata ad una altra proposta in Reol</exc:errorDescription>'+
            '     <exc:errorValue xmlns:exc="http://aems.corp.intraxa/eip/2013/07/schemas/fault">ER_REOL_01</exc:errorValue>'+
            ' </tns:associazioneProposteSalesForceFault>'+
            ' </tns:associazioneProposteSalesForceFault>'+
            ' </detail>'+
            ' </soapenv:Fault>'+
            ' </soapenv:Body>'+
            '</soapenv:Envelope>';
        }
        
        
        if (TestCase=='OK_ASSOCIA'){
            myXml='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ws="http://rgi.it/WS_REOL_Service">'+
            '<soapenv:Header/>'+
            '<soapenv:Body>'+
            '  <ws:associazioneProposteSalesForceResponse>'+
            '    <ws:result>'+
            '      <ws:message>Operazione andata a buon fine</ws:message>'+
            '     <ws:result>OK</ws:result>'+
            '    <ws:input>'+
            '      <ws:AgencyCode>000828</ws:AgencyCode>'+
            '     <ws:Branch>1</ws:Branch>'+
            '    <ws:DataEffetto>2016-05-16T00:00:00+02:00</ws:DataEffetto>'+
            '   <ws:DataFineValidita>2016-12-16T00:00:00+01:00</ws:DataFineValidita>'+
            '  <ws:DataScadenza>2017-05-16T00:00:00+02:00</ws:DataScadenza>'+
            ' <ws:FrazionamentoCode>000001</ws:FrazionamentoCode>'+
            '               <ws:FrazionamentoDesc>Annuale</ws:FrazionamentoDesc>'+
            '              <ws:Holder>BIANCHI ADELE</ws:Holder>'+
            '             <ws:IdOpp>'+OppId+'</ws:IdOpp>'+
            '            <ws:IdProposta>1002000125812</ws:IdProposta>'+
            '           <ws:LastModifiedBy>AG0828A3</ws:LastModifiedBy>'+
            '          <ws:NDG>0008280000002119</ws:NDG>'+
            '         <ws:Node>000314</ws:Node>'+
            '        <ws:PropostaNum>452582</ws:PropostaNum>'+
            '       <ws:Premium>'+
            '         <ws:currencyCode>EUR</ws:currencyCode>'+
            '        <ws:amount>0.0</ws:amount>'+
            '    </ws:Premium>'+
            '   <ws:ProductCode>1E16</ws:ProductCode>'+
            '  <ws:ProductName>All Risks Aziende</ws:ProductName>'+
            ' <ws:PropostaStatusCode>300000</ws:PropostaStatusCode>'+
            '               <ws:PropostaStatusDesc>Prop.da Autor.</ws:PropostaStatusDesc>'+
            '              <ws:SubAsaCode>0</ws:SubAsaCode>'+
            '             <ws:ObjectType>'+
            '               <ws:codice>PRO</ws:codice>'+
            '              <ws:descrizione>PROPOSTA</ws:descrizione>'+
            '          </ws:ObjectType>'+
            '      </ws:input>'+
            '  </ws:result>'+
            '</ws:associazioneProposteSalesForceResponse>'+
            '</soapenv:Body>'+
            '</soapenv:Envelope>';

        }
        //Add more cases with more IF statements
        
        

        myXml=myXml.normalizespace();
        res.setBody(myXml);
        system.debug('++++'+res.getbody());
        return res;

    }
}