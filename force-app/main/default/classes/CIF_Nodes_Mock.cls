/*------------------------------------------------------------------------
Author:        Davide Fabris
Company:       Deloitte
Class:         CIF_Nodes_Mock 
Description:   Test
            
History
15/06/2016 - Created
---------------------------------------------------------------------------*/

global class CIF_Nodes_Mock implements HttpCalloutMock{

    public String TestCase;


    global HTTPResponse respond(HTTPRequest req) {



        // Create a fake response based on the attribute TestCase
        HttpResponse res = new HttpResponse();

        string myXml='';
        
        if (String.Isempty(TestCase)) {
            myXML='<return>'+
            '<listaNdgOutput_anotherTag>'+
            '<listaNdgOutput>'+
            '<ndg>1111111111</ndg>'+
            '<esito>OK</esito>'+
            '<descrizioneEsito>Visibilità estesa correttamente</descrizioneEsito>'+
            '</listaNdgOutput>'+
            '<listaNdgOutput>'+
            '<ndg>2222222222</ndg>'+
            '<esito>OK</esito>'+
            '<descrizioneEsito>Visibilità estesa correttamente</descrizioneEsito>'+
            '</listaNdgOutput>'+
            '<listaNdgOutput>'+
            '        <ndg>0046100000000604</ndg>'+
            '               <esito>KO</esito>'+
            '             <descrizioneEsito>Ndg non presente in anagrafica soggetti</descrizioneEsito>'+
            '</listaNdgOutput>'+
            '</listaNdgOutput_anotherTag>'+
            '</return>';
        }
        
        if (TestCase == 'ERROR') {
            myXML =  '        <return>'+
            '<listaNdgOutput_anotherTag>'+
            '<listaNdgOutput>'+
            '        <ndg/>'+
            '               <esito>KO</esito>'+
            '             <descrizioneEsito>Sottonodo non presente in anagrafica di agenzia</descrizioneEsito>'+
            '</listaNdgOutput>'+
            '</listaNdgOutput_anotherTag>'+
            '</return>';

        }
        if (TestCase=='ON_Acc_Add_OK_Single') {
            myXml =+'              <listaNdgOutput_anotherTag>'
            +  '            <return>  '     
            +'<ndg>0010010000001422</ndg>                                                        '
            +'  <listaNodiOutput>                                                                '
            +'      <nodo>004610000010</nodo>                                                    '
            +'      <esito>OK</esito>                                                            '
            +'      <descrizioneEsito>Visibilità già presente</descrizioneEsito>                 '
            +'  </listaNodiOutput>                                                               '                                                       
            +'  <listaNodiAggiornata>                                                            '
            +'         <nodo>004610</nodo>                                                       '
            +'         <nodo>004610000010</nodo>                                                 '
            +'         <nodo>004610000020</nodo>                                                 '
            +'  </listaNodiAggiornata>                                                           '
            
            +'</return>                                                                          '
            +         '</listaNdgOutput_anotherTag>                                           ';




        }
                if (TestCase=='ON_Acc_Add_OK') {
            myXml =+'              <listaNdgOutput_anotherTag>'
            +  '            <return>  '     
            +'<ndg>0010010000001422</ndg>                                                        '
            +'  <listaNodiOutput>                                                                '
            +'      <nodo>004610000010</nodo>                                                    '
            +'      <esito>OK</esito>                                                            '
            +'      <descrizioneEsito>Visibilità già presente</descrizioneEsito>                 '
            +'  </listaNodiOutput>                                                               '
            +'  <listaNodiOutput>                                                                '
            +'      <nodo>004610000020</nodo>                                                    '
            +'      <esito>OK</esito>                                                            '
            +'      <descrizioneEsito>Visibilità già presente</descrizioneEsito>                 '
            +'  </listaNodiOutput>                                                               '
            +'  <listaNodiOutput>                                                                '
            +'         <nodo>004610000030</nodo>                                                 '
            +'         <esito>OK</esito>                                                         '
            +'         <descrizioneEsito>Visibilità estesa correttamente</descrizioneEsito>      '
            +'  </listaNodiOutput>                                                               '
            +'  <listaNodiAggiornata>                                                            '
            +'         <nodo>004610</nodo>                                                       '
            +'         <nodo>004610000020</nodo>                                                 '
            +'         <nodo>004610000010</nodo>                                                 '
            +'         <nodo>004610000030</nodo>                                                 '
            +'  </listaNodiAggiornata>                                                           '
            +'</return>                                                                          '
            +         '</listaNdgOutput_anotherTag>                                           ';




        }
        
        if (TestCase == 'ON_Acc_error') {
            myXml=+' '
            +'<return>                                                                                                                                                       '
            +'  <ndg/>                                                                                                                                                       '
            +'  <listaNodiOutput>                                                                                                                                            '
            +'<nodo/>                                                                                                                                                        '
            +'      <esito>KO</esito>                                                                                                                                        '
            +'      <descrizioneEsito>cvc-length-valid: Value \'\' with length = \'0\' is not facet-valid with respect to length \'12\' for type \'nodo\'.</descrizioneEsito>'
            +'  </listaNodiOutput>                                                                                                                                           '
            +'</return>'
            +         '                                          ';


            
        }
        
        if (TestCase=='ON_Acc_Remove_OK') {
            myXml =+'              <listaNdgOutput_anotherTag>'
            +'<return>                                                                              '
            +'<ndg>0010010000001422</ndg>                                                           '
            +'  <listaNodiOutput>                                                                   '
            +'         <nodo>004610000030</nodo>                                                    '
            +'         <esito>OK</esito>                                                            '
            +'         <descrizioneEsito>Visibilità eliminata correttamente</descrizioneEsito>      '
            +'  </listaNodiOutput>                                                                  '
            +'  <listaNodiOutput>                                                                   '
            +'         <nodo>004610000020</nodo>                                                    '
            +'         <esito>OK</esito>                                                            '
            +'         <descrizioneEsito>Visibilità eliminata correttamente</descrizioneEsito>      '
            +'  </listaNodiOutput>                                                                  '
            +'  <listaNodiAggiornata>                                                               '
            +'         <nodo>004610</nodo>                                                          '
            +'         <nodo>004610000010</nodo>                                                    '
            +'         <nodo>004610000021</nodo>                                                    '
            +'  </listaNodiAggiornata>                                                              '
            +'</return>                                                                             '
            +         '</listaNdgOutput_anotherTag>                                           ';

        }
        
        //Add more cases with more IF statements
        
        

        myXml=myXml.normalizespace();
        res.setBody(myXml);
        return res;

    }
}