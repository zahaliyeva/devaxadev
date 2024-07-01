@isTest
global class getcomuniMock_Test implements HttpCalloutMock{



    global HTTPResponse respond(HTTPRequest req) {

   
      // Create a fake response

      HttpResponse res = new HttpResponse();

      //res.setHeader('Content-Type', 'application/json');
      string myXml='';
            myXml='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'+
'   <soapenv:Body>                                                                                                 '+
'       <RispostaLocalita xmlns="http://bean.services.jdna6hs.app.directw.it">                                     '+
'           <TabLocalita>                                                                                          '+
'               <NumOccorrenza>1</NumOccorrenza>                                                                   '+
'               <TipoLocalitaUfficiale>1</TipoLocalitaUfficiale>                                                   '+
'               <DesTipoLocalitaUfficiale>COMUNE AMMINISTRATIVO</DesTipoLocalitaUfficiale>                         '+
'               <SigProvin>LE</SigProvin>                                                                          '+
'               <CodLingua>ITA</CodLingua>                                                                         '+
'               <CAP>73040</CAP>                                                                                   '+
'               <FlViarioNaz>S</FlViarioNaz>                                                                       '+
'               <FlViarioZon>N</FlViarioZon>                                                                       '+
'               <CodStatistico>016075001</CodStatistico>                                                           '+
'               <SigProvAmm>LE</SigProvAmm>                                                                        '+
'               <DesLocalitaAmm>ACQUARICA DEL CAPO</DesLocalitaAmm>                                                '+
'               <CodStatisticoAmm>016075001</CodStatisticoAmm>                                                     '+
'               <DesLocalitaRicerca>ACQUARICA DEL CAPO</DesLocalitaRicerca>                                        '+
'               <CAPRicerca>73040</CAPRicerca>                                                                     '+
'               <SigProRicerca>LE</SigProRicerca>                                                                  '+
'               <TipoElemento>1</TipoElemento>                                                                     '+
'               <FlSinonimo>N</FlSinonimo>                                                                         '+
'               <DesTipoCertificazione>DNA</DesTipoCertificazione>                                                 '+
'               <TipoCertificazione>1</TipoCertificazione>                                                         '+
'               <DesRegione>PUGLIA</DesRegione>                                                                    '+
'               <CodRegione>16</CodRegione>                                                                        '+
'               <DesProvin>LECCE</DesProvin>                                                                       '+
'               <DesLingua>Italia</DesLingua>                                                                      '+
'               <DesLocalitaUff>ACQUARICA DEL CAPO</DesLocalitaUff>                                                '+
'               <DesLocalitaOut>ACQUARICA DEL CAPO</DesLocalitaOut>                                                '+
'               <DesLocalitaAbb>ACQUARICA DEL CAPO</DesLocalitaAbb>                                                '+
'               <FlViarioSpe>N</FlViarioSpe>                                                                       '+
'               <CAPLocalitaAmm>73040</CAPLocalitaAmm>                                                             '+
'               <TpDato>0</TpDato>                                                                                 '+
'           </TabLocalita>                                                                                         '+
'           <TabLocalita>                                                                                          '+
'               <NumOccorrenza>2</NumOccorrenza>                                                                   '+
'               <TipoLocalitaUfficiale>1</TipoLocalitaUfficiale>                                                   '+
'               <DesTipoLocalitaUfficiale>COMUNE AMMINISTRATIVO</DesTipoLocalitaUfficiale>                         '+
'               <SigProvin>LE</SigProvin>                                                                          '+
'               <CodLingua>ITA</CodLingua>                                                                         '+
'               <CAP>73031</CAP>                                                                                   '+
'               <FlViarioNaz>S</FlViarioNaz>                                                                       '+
'               <FlViarioZon>N</FlViarioZon>                                                                       '+
'               <CodStatistico>016075002</CodStatistico>                                                           '+
'               <SigProvAmm>LE</SigProvAmm>                                                                        '+
'               <DesLocalitaAmm>ALESSANO</DesLocalitaAmm>                                                          '+
'               <CodStatisticoAmm>016075002</CodStatisticoAmm>                                                     '+
'               <DesLocalitaRicerca>ALESSANO</DesLocalitaRicerca>                                                  '+
'               <CAPRicerca>73031</CAPRicerca>                                                                     '+
'               <SigProRicerca>LE</SigProRicerca>                                                                  '+
'               <TipoElemento>1</TipoElemento>                                                                     '+
'               <FlSinonimo>N</FlSinonimo>                                                                         '+
'               <DesTipoCertificazione>DNA</DesTipoCertificazione>                                                 '+
'               <TipoCertificazione>1</TipoCertificazione>                                                         '+
'               <DesRegione>PUGLIA</DesRegione>                                                                    '+
'               <CodRegione>16</CodRegione>                                                                        '+
'               <DesProvin>LECCE</DesProvin>                                                                       '+
'               <DesLingua>Italia</DesLingua>                                                                      '+
'               <DesLocalitaUff>ALESSANO</DesLocalitaUff>                                                          '+
'               <DesLocalitaOut>ALESSANO</DesLocalitaOut>                                                          '+
'               <DesLocalitaAbb>ALESSANO</DesLocalitaAbb>                                                          '+
'               <FlViarioSpe>N</FlViarioSpe>                                                                       '+
'               <CAPLocalitaAmm>73031</CAPLocalitaAmm>                                                             '+
'               <TpDato>0</TpDato>                                                                                 '+
'           </TabLocalita>                                                                                         '+
'           <TabLocalita>                                                                                          '+
'               <NumOccorrenza>3</NumOccorrenza>                                                                   '+
'               <TipoLocalitaUfficiale>1</TipoLocalitaUfficiale>                                                   '+
'               <DesTipoLocalitaUfficiale>COMUNE AMMINISTRATIVO</DesTipoLocalitaUfficiale>                         '+
'               <SigProvin>LE</SigProvin>                                                                          '+
'               <CodLingua>ITA</CodLingua>                                                                         '+
'               <CAP>73011</CAP>                                                                                   '+
'               <FlViarioNaz>S</FlViarioNaz>                                                                       '+
'               <FlViarioZon>N</FlViarioZon>                                                                       '+
'               <CodStatistico>016075003</CodStatistico>                                                           '+
'               <SigProvAmm>LE</SigProvAmm>                                                                        '+
'               <DesLocalitaAmm>ALEZIO</DesLocalitaAmm>                                                            '+
'               <CodStatisticoAmm>016075003</CodStatisticoAmm>                                                     '+
'               <DesLocalitaRicerca>ALEZIO</DesLocalitaRicerca>                                                    '+
'               <CAPRicerca>73011</CAPRicerca>                                                                     '+
'               <SigProRicerca>LE</SigProRicerca>                                                                  '+
'               <TipoElemento>1</TipoElemento>                                                                     '+
'               <FlSinonimo>N</FlSinonimo>                                                                         '+
'               <DesTipoCertificazione>DNA</DesTipoCertificazione>                                                 '+
'               <TipoCertificazione>1</TipoCertificazione>                                                         '+
'               <DesRegione>PUGLIA</DesRegione>                                                                    '+
'               <CodRegione>16</CodRegione>                                                                        '+
'               <DesProvin>LECCE</DesProvin>                                                                       '+
'               <DesLingua>Italia</DesLingua>                                                                      '+
'               <DesLocalitaUff>ALEZIO</DesLocalitaUff>                                                            '+
'               <DesLocalitaOut>ALEZIO</DesLocalitaOut>                                                            '+
'               <DesLocalitaAbb>ALEZIO</DesLocalitaAbb>                                                            '+
'               <FlViarioSpe>N</FlViarioSpe>                                                                       '+
'               <CAPLocalitaAmm>73011</CAPLocalitaAmm>                                                             '+
'               <TpDato>0</TpDato>                                                                                 '+
'           </TabLocalita>                                                                                         '+
'           <TabLocalita>                                                                                          '+
'               <NumOccorrenza>4</NumOccorrenza>                                                                   '+
'               <TipoLocalitaUfficiale>1</TipoLocalitaUfficiale>                                                   '+
'               <DesTipoLocalitaUfficiale>COMUNE AMMINISTRATIVO</DesTipoLocalitaUfficiale>                         '+
'               <SigProvin>LE</SigProvin>                                                                          '+
'               <CodLingua>ITA</CodLingua>                                                                         '+
'               <CAP>73040</CAP>                                                                                   '+
'               <FlViarioNaz>S</FlViarioNaz>                                                                       '+
'               <FlViarioZon>N</FlViarioZon>                                                                       '+
'               <CodStatistico>016075004</CodStatistico>                                                           '+
'               <SigProvAmm>LE</SigProvAmm>                                                                        '+
'               <DesLocalitaAmm>ALLISTE</DesLocalitaAmm>                                                           '+
'               <CodStatisticoAmm>016075004</CodStatisticoAmm>                                                     '+
'               <DesLocalitaRicerca>ALLISTE</DesLocalitaRicerca>                                                   '+
'               <CAPRicerca>73040</CAPRicerca>                                                                     '+
'               <SigProRicerca>LE</SigProRicerca>                                                                  '+
'               <TipoElemento>1</TipoElemento>                                                                     '+
'               <FlSinonimo>N</FlSinonimo>                                                                         '+
'               <DesTipoCertificazione>DNA</DesTipoCertificazione>                                                 '+
'               <TipoCertificazione>1</TipoCertificazione>                                                         '+
'               <DesRegione>PUGLIA</DesRegione>                                                                    '+
'               <CodRegione>16</CodRegione>                                                                        '+
'               <DesProvin>LECCE</DesProvin>                                                                       '+
'               <DesLingua>Italia</DesLingua>                                                                      '+
'               <DesLocalitaUff>ALLISTE</DesLocalitaUff>                                                           '+
'               <DesLocalitaOut>ALLISTE</DesLocalitaOut>                                                           '+
'               <DesLocalitaAbb>ALLISTE</DesLocalitaAbb>                                                           '+
'               <FlViarioSpe>N</FlViarioSpe>                                                                       '+
'               <CAPLocalitaAmm>73040</CAPLocalitaAmm>                                                             '+
'               <TpDato>0</TpDato>                                                                                 '+
'           </TabLocalita>                                                                                         '+
'           <TabLocalita>                                                                                          '+
'               <NumOccorrenza>5</NumOccorrenza>                                                                   '+
'               <TipoLocalitaUfficiale>1</TipoLocalitaUfficiale>                                                   '+
'               <DesTipoLocalitaUfficiale>COMUNE AMMINISTRATIVO</DesTipoLocalitaUfficiale>                         '+
'               <SigProvin>LE</SigProvin>                                                                          '+
'               <CodLingua>ITA</CodLingua>                                                                         '+
'               <CAP>73032</CAP>                                                                                   '+
'               <FlViarioNaz>S</FlViarioNaz>                                                                       '+
'               <FlViarioZon>N</FlViarioZon>                                                                       '+
'               <CodStatistico>016075005</CodStatistico>                                                           '+
'               <SigProvAmm>LE</SigProvAmm>                                                                        '+
'               <DesLocalitaAmm>ANDRANO</DesLocalitaAmm>                                                           '+
'               <CodStatisticoAmm>016075005</CodStatisticoAmm>                                                     '+
'               <DesLocalitaRicerca>ANDRANO</DesLocalitaRicerca>                                                   '+
'               <CAPRicerca>73032</CAPRicerca>                                                                     '+
'               <SigProRicerca>LE</SigProRicerca>                                                                  '+
'               <TipoElemento>1</TipoElemento>                                                                     '+
'               <FlSinonimo>N</FlSinonimo>                                                                         '+
'               <DesTipoCertificazione>DNA</DesTipoCertificazione>                                                 '+
'               <TipoCertificazione>1</TipoCertificazione>                                                         '+
'               <DesRegione>PUGLIA</DesRegione>                                                                    '+
'               <CodRegione>16</CodRegione>                                                                        '+
'               <DesProvin>LECCE</DesProvin>                                                                       '+
'               <DesLingua>Italia</DesLingua>                                                                      '+
'               <DesLocalitaUff>ANDRANO</DesLocalitaUff>                                                           '+
'               <DesLocalitaOut>ANDRANO</DesLocalitaOut>                                                           '+
'               <DesLocalitaAbb>ANDRANO</DesLocalitaAbb>                                                           '+
'               <FlViarioSpe>N</FlViarioSpe>                                                                       '+
'               <CAPLocalitaAmm>73032</CAPLocalitaAmm>                                                             '+
'               <TpDato>0</TpDato>                                                                                 '+
'           </TabLocalita>                                                                                         '+
'           <TabLocalita>                                                                                          '+
'               <NumOccorrenza>6</NumOccorrenza>                                                                   '+
'               <TipoLocalitaUfficiale>1</TipoLocalitaUfficiale>                                                   '+
'               <DesTipoLocalitaUfficiale>COMUNE AMMINISTRATIVO</DesTipoLocalitaUfficiale>                         '+
'               <SigProvin>LE</SigProvin>                                                                          '+
'               <CodLingua>ITA</CodLingua>                                                                         '+
'               <CAP>73040</CAP>                                                                                   '+
'               <FlViarioNaz>S</FlViarioNaz>                                                                       '+
'               <FlViarioZon>N</FlViarioZon>                                                                       '+
'               <CodStatistico>016075006</CodStatistico>                                                           '+
'               <SigProvAmm>LE</SigProvAmm>                                                                        '+
'               <DesLocalitaAmm>ARADEO</DesLocalitaAmm>                                                            '+
'               <CodStatisticoAmm>016075006</CodStatisticoAmm>                                                     '+
'               <DesLocalitaRicerca>ARADEO</DesLocalitaRicerca>                                                    '+
'               <CAPRicerca>73040</CAPRicerca>                                                                     '+
'               <SigProRicerca>LE</SigProRicerca>                                                                  '+
'               <TipoElemento>1</TipoElemento>                                                                     '+
'               <FlSinonimo>N</FlSinonimo>                                                                         '+
'               <DesTipoCertificazione>DNA</DesTipoCertificazione>                                                 '+
'               <TipoCertificazione>1</TipoCertificazione>                                                         '+
'               <DesRegione>PUGLIA</DesRegione>                                                                    '+
'               <CodRegione>16</CodRegione>                                                                        '+
'               <DesProvin>LECCE</DesProvin>                                                                       '+
'               <DesLingua>Italia</DesLingua>                                                                      '+
'               <DesLocalitaUff>ARADEO</DesLocalitaUff>                                                            '+
'               <DesLocalitaOut>ARADEO</DesLocalitaOut>                                                            '+
'               <DesLocalitaAbb>ARADEO</DesLocalitaAbb>                                                            '+
'               <FlViarioSpe>N</FlViarioSpe>                                                                       '+
'               <CAPLocalitaAmm>73040</CAPLocalitaAmm>                                                             '+
'               <TpDato>0</TpDato>                                                                                 '+
'           </TabLocalita>                                                                                         '+
'           <TabLocalita>                                                                                          '+
'               <NumOccorrenza>7</NumOccorrenza>                                                                   '+
'               <TipoLocalitaUfficiale>1</TipoLocalitaUfficiale>                                                   '+
'               <DesTipoLocalitaUfficiale>COMUNE AMMINISTRATIVO</DesTipoLocalitaUfficiale>                         '+
'               <SigProvin>LE</SigProvin>                                                                          '+
'               <CodLingua>ITA</CodLingua>                                                                         '+
'               <CAP>73010</CAP>                                                                                   '+
'               <FlViarioNaz>S</FlViarioNaz>                                                                       '+
'               <FlViarioZon>N</FlViarioZon>                                                                       '+
'               <CodStatistico>016075007</CodStatistico>                                                           '+
'               <SigProvAmm>LE</SigProvAmm>                                                                        '+
'               <DesLocalitaAmm>ARNESANO</DesLocalitaAmm>                                                          '+
'               <CodStatisticoAmm>016075007</CodStatisticoAmm>                                                     '+
'               <DesLocalitaRicerca>ARNESANO</DesLocalitaRicerca>                                                  '+
'               <CAPRicerca>73010</CAPRicerca>                                                                     '+
'               <SigProRicerca>LE</SigProRicerca>                                                                  '+
'               <TipoElemento>1</TipoElemento>                                                                     '+
'               <FlSinonimo>N</FlSinonimo>                                                                         '+
'               <DesTipoCertificazione>DNA</DesTipoCertificazione>                                                 '+
'               <TipoCertificazione>1</TipoCertificazione>                                                         '+
'               <DesRegione>PUGLIA</DesRegione>                                                                    '+
'               <CodRegione>16</CodRegione>                                                                        '+
'               <DesProvin>LECCE</DesProvin>                                                                       '+
'               <DesLingua>Italia</DesLingua>                                                                      '+
'               <DesLocalitaUff>ARNESANO</DesLocalitaUff>                                                          '+
'               <DesLocalitaOut>ARNESANO</DesLocalitaOut>                                                          '+
'               <DesLocalitaAbb>ARNESANO</DesLocalitaAbb>                                                          '+
'               <FlViarioSpe>N</FlViarioSpe>                                                                       '+
'               <CAPLocalitaAmm>73010</CAPLocalitaAmm>                                                             '+
'               <TpDato>0</TpDato>                                                                                 '+
'           </TabLocalita>                                                                                         '+
'           <TabLocalita>                                                                                          '+
'               <NumOccorrenza>8</NumOccorrenza>                                                                   '+
'               <TipoLocalitaUfficiale>1</TipoLocalitaUfficiale>                                                   '+
'               <DesTipoLocalitaUfficiale>COMUNE AMMINISTRATIVO</DesTipoLocalitaUfficiale>                         '+
'               <SigProvin>LE</SigProvin>                                                                          '+
'               <CodLingua>ITA</CodLingua>                                                                         '+
'               <CAP>73020</CAP>                                                                                   '+
'               <FlViarioNaz>S</FlViarioNaz>                                                                       '+
'               <FlViarioZon>N</FlViarioZon>                                                                       '+
'               <CodStatistico>016075008</CodStatistico>                                                           '+
'               <SigProvAmm>LE</SigProvAmm>                                                                        '+
'               <DesLocalitaAmm>BAGNOLO DEL SALENTO</DesLocalitaAmm>                                               '+
'               <CodStatisticoAmm>016075008</CodStatisticoAmm>                                                     '+
'               <DesLocalitaRicerca>BAGNOLO DEL SALENTO</DesLocalitaRicerca>                                       '+
'               <CAPRicerca>73020</CAPRicerca>                                                                     '+
'               <SigProRicerca>LE</SigProRicerca>                                                                  '+
'               <TipoElemento>1</TipoElemento>                                                                     '+
'               <FlSinonimo>N</FlSinonimo>                                                                         '+
'               <DesTipoCertificazione>DNA</DesTipoCertificazione>                                                 '+
'               <TipoCertificazione>1</TipoCertificazione>                                                         '+
'               <DesRegione>PUGLIA</DesRegione>                                                                    '+
'               <CodRegione>16</CodRegione>                                                                        '+
'               <DesProvin>LECCE</DesProvin>                                                                       '+
'               <DesLingua>Italia</DesLingua>                                                                      '+
'               <DesLocalitaUff>BAGNOLO DEL SALENTO</DesLocalitaUff>                                               '+
'               <DesLocalitaOut>BAGNOLO DEL SALENTO</DesLocalitaOut>                                               '+
'               <DesLocalitaAbb>BAGNOLO DEL SALENTO</DesLocalitaAbb>                                               '+
'               <FlViarioSpe>N</FlViarioSpe>                                                                       '+
'               <CAPLocalitaAmm>73020</CAPLocalitaAmm>                                                             '+
'               <TpDato>0</TpDato>                                                                                 '+
'           </TabLocalita>                                                                                         '+
'           <TabLocalita>                                                                                          '+
'               <NumOccorrenza>9</NumOccorrenza>                                                                   '+
'               <TipoLocalitaUfficiale>1</TipoLocalitaUfficiale>                                                   '+
'               <DesTipoLocalitaUfficiale>COMUNE AMMINISTRATIVO</DesTipoLocalitaUfficiale>                         '+
'               <SigProvin>LE</SigProvin>                                                                          '+
'               <CodLingua>ITA</CodLingua>                                                                         '+
'               <CAP>73020</CAP>                                                                                   '+
'               <FlViarioNaz>S</FlViarioNaz>                                                                       '+
'               <FlViarioZon>N</FlViarioZon>                                                                       '+
'               <CodStatistico>016075009</CodStatistico>                                                           '+
'               <SigProvAmm>LE</SigProvAmm>                                                                        '+
'               <DesLocalitaAmm>BOTRUGNO</DesLocalitaAmm>                                                          '+
'               <CodStatisticoAmm>016075009</CodStatisticoAmm>                                                     '+
'               <DesLocalitaRicerca>BOTRUGNO</DesLocalitaRicerca>                                                  '+
'               <CAPRicerca>73020</CAPRicerca>                                                                     '+
'               <SigProRicerca>LE</SigProRicerca>                                                                  '+
'               <TipoElemento>1</TipoElemento>                                                                     '+
'               <FlSinonimo>N</FlSinonimo>                                                                         '+
'               <DesTipoCertificazione>DNA</DesTipoCertificazione>                                                 '+
'               <TipoCertificazione>1</TipoCertificazione>                                                         '+
'               <DesRegione>PUGLIA</DesRegione>                                                                    '+
'               <CodRegione>16</CodRegione>                                                                        '+
'               <DesProvin>LECCE</DesProvin>                                                                       '+
'               <DesLingua>Italia</DesLingua>                                                                      '+
'               <DesLocalitaUff>BOTRUGNO</DesLocalitaUff>                                                          '+
'               <DesLocalitaOut>BOTRUGNO</DesLocalitaOut>                                                          '+
'               <DesLocalitaAbb>BOTRUGNO</DesLocalitaAbb>                                                          '+
'               <FlViarioSpe>N</FlViarioSpe>                                                                       '+
'               <CAPLocalitaAmm>73020</CAPLocalitaAmm>                                                             '+
'               <TpDato>0</TpDato>                                                                                 '+
'           </TabLocalita>                                                                                         '+
'           <TabLocalita>                                                                                          '+
'               <NumOccorrenza>10</NumOccorrenza>                                                                  '+
'               <TipoLocalitaUfficiale>1</TipoLocalitaUfficiale>                                                   '+
'               <DesTipoLocalitaUfficiale>COMUNE AMMINISTRATIVO</DesTipoLocalitaUfficiale>                         '+
'               <SigProvin>LE</SigProvin>                                                                          '+
'               <CodLingua>ITA</CodLingua>                                                                         '+
'               <CAP>73021</CAP>                                                                                   '+
'               <FlViarioNaz>S</FlViarioNaz>                                                                       '+
'               <FlViarioZon>N</FlViarioZon>                                                                       '+
'               <CodStatistico>016075010</CodStatistico>                                                           '+
'               <SigProvAmm>LE</SigProvAmm>                                                                        '+
'               <DesLocalitaAmm>CALIMERA</DesLocalitaAmm>                                                          '+
'               <CodStatisticoAmm>016075010</CodStatisticoAmm>                                                     '+
'               <DesLocalitaRicerca>CALIMERA</DesLocalitaRicerca>                                                  '+
'               <CAPRicerca>73021</CAPRicerca>                                                                     '+
'               <SigProRicerca>LE</SigProRicerca>                                                                  '+
'               <TipoElemento>1</TipoElemento>                                                                     '+
'               <FlSinonimo>N</FlSinonimo>                                                                         '+
'               <DesTipoCertificazione>DNA</DesTipoCertificazione>                                                 '+
'               <TipoCertificazione>1</TipoCertificazione>                                                         '+
'               <DesRegione>PUGLIA</DesRegione>                                                                    '+
'               <CodRegione>16</CodRegione>                                                                        '+
'               <DesProvin>LECCE</DesProvin>                                                                       '+
'               <DesLingua>Italia</DesLingua>                                                                      '+
'               <DesLocalitaUff>CALIMERA</DesLocalitaUff>                                                          '+
'               <DesLocalitaOut>CALIMERA</DesLocalitaOut>                                                          '+
'               <DesLocalitaAbb>CALIMERA DI LECCE</DesLocalitaAbb>                                                 '+
'               <FlViarioSpe>N</FlViarioSpe>                                                                       '+
'               <CAPLocalitaAmm>73021</CAPLocalitaAmm>                                                             '+
'               <TpDato>0</TpDato>                                                                                 '+
'           </TabLocalita>                                                                                         '+
'           <TabLocalita>                                                                                          '+
'               <NumOccorrenza>11</NumOccorrenza>                                                                  '+
'               <TipoLocalitaUfficiale>1</TipoLocalitaUfficiale>                                                   '+
'               <DesTipoLocalitaUfficiale>COMUNE AMMINISTRATIVO</DesTipoLocalitaUfficiale>                         '+
'               <SigProvin>LE</SigProvin>                                                                          '+
'               <CodLingua>ITA</CodLingua>                                                                         '+
'               <CAP>73012</CAP>                                                                                   '+
'               <FlViarioNaz>S</FlViarioNaz>                                                                       '+
'               <FlViarioZon>N</FlViarioZon>                                                                       '+
'               <CodStatistico>016075011</CodStatistico>                                                           '+
'               <SigProvAmm>LE</SigProvAmm>                                                                        '+
'               <DesLocalitaAmm>CAMPI SALENTINA</DesLocalitaAmm>                                                   '+
'               <CodStatisticoAmm>016075011</CodStatisticoAmm>                                                     '+
'               <DesLocalitaRicerca>CAMPI SALENTINA</DesLocalitaRicerca>                                           '+
'               <CAPRicerca>73012</CAPRicerca>                                                                     '+
'               <SigProRicerca>LE</SigProRicerca>                                                                  '+
'               <TipoElemento>1</TipoElemento>                                                                     '+
'               <FlSinonimo>N</FlSinonimo>                                                                         '+
'               <DesTipoCertificazione>DNA</DesTipoCertificazione>                                                 '+
'               <TipoCertificazione>1</TipoCertificazione>                                                         '+
'               <DesRegione>PUGLIA</DesRegione>                                                                    '+
'               <CodRegione>16</CodRegione>                                                                        '+
'               <DesProvin>LECCE</DesProvin>                                                                       '+
'               <DesLingua>Italia</DesLingua>                                                                      '+
'               <DesLocalitaUff>CAMPI SALENTINA</DesLocalitaUff>                                                   '+
'               <DesLocalitaOut>CAMPI SALENTINA</DesLocalitaOut>                                                   '+
'               <DesLocalitaAbb>CAMPI SALENTINA</DesLocalitaAbb>                                                   '+
'               <FlViarioSpe>N</FlViarioSpe>                                                                       '+
'               <CAPLocalitaAmm>73012</CAPLocalitaAmm>                                                             '+
'               <TpDato>0</TpDato>                                                                                 '+
'           </TabLocalita>                                                                                         '+
'           <TabLocalita>                                                                                          '+
'               <NumOccorrenza>12</NumOccorrenza>                                                                  '+
'               <TipoLocalitaUfficiale>1</TipoLocalitaUfficiale>                                                   '+
'               <DesTipoLocalitaUfficiale>COMUNE AMMINISTRATIVO</DesTipoLocalitaUfficiale>                         '+
'               <SigProvin>LE</SigProvin>                                                                          '+
'               <CodLingua>ITA</CodLingua>                                                                         '+
'               <CAP>73020</CAP>                                                                                   '+
'               <FlViarioNaz>S</FlViarioNaz>                                                                       '+
'               <FlViarioZon>N</FlViarioZon>                                                                       '+
'               <CodStatistico>016075012</CodStatistico>                                                           '+
'               <SigProvAmm>LE</SigProvAmm>                                                                        '+
'               <DesLocalitaAmm>CANNOLE</DesLocalitaAmm>                                                           '+
'               <CodStatisticoAmm>016075012</CodStatisticoAmm>                                                     '+
'               <DesLocalitaRicerca>CANNOLE</DesLocalitaRicerca>                                                   '+
'               <CAPRicerca>73020</CAPRicerca>                                                                     '+
'               <SigProRicerca>LE</SigProRicerca>                                                                  '+
'               <TipoElemento>1</TipoElemento>                                                                     '+
'               <FlSinonimo>N</FlSinonimo>                                                                         '+
'               <DesTipoCertificazione>DNA</DesTipoCertificazione>                                                 '+
'               <TipoCertificazione>1</TipoCertificazione>                                                         '+
'               <DesRegione>PUGLIA</DesRegione>                                                                    '+
'               <CodRegione>16</CodRegione>                                                                        '+
'               <DesProvin>LECCE</DesProvin>                                                                       '+
'               <DesLingua>Italia</DesLingua>                                                                      '+
'               <DesLocalitaUff>CANNOLE</DesLocalitaUff>                                                           '+
'               <DesLocalitaOut>CANNOLE</DesLocalitaOut>                                                           '+
'               <DesLocalitaAbb>CANNOLE</DesLocalitaAbb>                                                           '+
'               <FlViarioSpe>N</FlViarioSpe>                                                                       '+
'               <CAPLocalitaAmm>73020</CAPLocalitaAmm>                                                             '+
'               <TpDato>0</TpDato>                                                                                 '+
'           </TabLocalita>                                                                                         '+
'           <TabLocalita>                                                                                          '+
'               <NumOccorrenza>13</NumOccorrenza>                                                                  '+
'               <TipoLocalitaUfficiale>1</TipoLocalitaUfficiale>                                                   '+
'               <DesTipoLocalitaUfficiale>COMUNE AMMINISTRATIVO</DesTipoLocalitaUfficiale>                         '+
'               <SigProvin>LE</SigProvin>                                                                          '+
'               <CodLingua>ITA</CodLingua>                                                                         '+
'               <CAP>73010</CAP>                                                                                   '+
'               <FlViarioNaz>S</FlViarioNaz>                                                                       '+
'               <FlViarioZon>N</FlViarioZon>                                                                       '+
'               <CodStatistico>016075013</CodStatistico>                                                           '+
'               <SigProvAmm>LE</SigProvAmm>                                                                        '+
'               <DesLocalitaAmm>CAPRARICA DI LECCE</DesLocalitaAmm>                                                '+
'               <CodStatisticoAmm>016075013</CodStatisticoAmm>                                                     '+
'               <DesLocalitaRicerca>CAPRARICA DI LECCE</DesLocalitaRicerca>                                        '+
'               <CAPRicerca>73010</CAPRicerca>                                                                     '+
'               <SigProRicerca>LE</SigProRicerca>                                                                  '+
'               <TipoElemento>1</TipoElemento>                                                                     '+
'               <FlSinonimo>N</FlSinonimo>                                                                         '+
'               <DesTipoCertificazione>DNA</DesTipoCertificazione>                                                 '+
'               <TipoCertificazione>1</TipoCertificazione>                                                         '+
'               <DesRegione>PUGLIA</DesRegione>                                                                    '+
'               <CodRegione>16</CodRegione>                                                                        '+
'               <DesProvin>LECCE</DesProvin>                                                                       '+
'               <DesLingua>Italia</DesLingua>                                                                      '+
'               <DesLocalitaUff>CAPRARICA DI LECCE</DesLocalitaUff>                                                '+
'               <DesLocalitaOut>CAPRARICA DI LECCE</DesLocalitaOut>                                                '+
'               <DesLocalitaAbb>CAPRARICA DI LECCE</DesLocalitaAbb>                                                '+
'               <FlViarioSpe>N</FlViarioSpe>                                                                       '+
'               <CAPLocalitaAmm>73010</CAPLocalitaAmm>                                                             '+
'               <TpDato>0</TpDato>                                                                                 '+
'           </TabLocalita>                                                                                         '+
'           <TabLocalita>                                                                                          '+
'               <NumOccorrenza>14</NumOccorrenza>                                                                  '+
'               <TipoLocalitaUfficiale>1</TipoLocalitaUfficiale>                                                   '+
'               <DesTipoLocalitaUfficiale>COMUNE AMMINISTRATIVO</DesTipoLocalitaUfficiale>                         '+
'               <SigProvin>LE</SigProvin>                                                                          '+
'               <CodLingua>ITA</CodLingua>                                                                         '+
'               <CAP>73041</CAP>                                                                                   '+
'               <FlViarioNaz>S</FlViarioNaz>                                                                       '+
'               <FlViarioZon>N</FlViarioZon>                                                                       '+
'               <CodStatistico>016075014</CodStatistico>                                                           '+
'               <SigProvAmm>LE</SigProvAmm>                                                                        '+
'               <DesLocalitaAmm>CARMIANO</DesLocalitaAmm>                                                          '+
'               <CodStatisticoAmm>016075014</CodStatisticoAmm>                                                     '+
'               <DesLocalitaRicerca>CARMIANO</DesLocalitaRicerca>                                                  '+
'               <CAPRicerca>73041</CAPRicerca>                                                                     '+
'               <SigProRicerca>LE</SigProRicerca>                                                                  '+
'               <TipoElemento>1</TipoElemento>                                                                     '+
'               <FlSinonimo>N</FlSinonimo>                                                                         '+
'               <DesTipoCertificazione>DNA</DesTipoCertificazione>                                                 '+
'               <TipoCertificazione>1</TipoCertificazione>                                                         '+
'               <DesRegione>PUGLIA</DesRegione>                                                                    '+
'               <CodRegione>16</CodRegione>                                                                        '+
'               <DesProvin>LECCE</DesProvin>                                                                       '+
'               <DesLingua>Italia</DesLingua>                                                                      '+
'               <DesLocalitaUff>CARMIANO</DesLocalitaUff>                                                          '+
'               <DesLocalitaOut>CARMIANO</DesLocalitaOut>                                                          '+
'               <DesLocalitaAbb>CARMIANO</DesLocalitaAbb>                                                          '+
'               <FlViarioSpe>N</FlViarioSpe>                                                                       '+
'               <CAPLocalitaAmm>73041</CAPLocalitaAmm>                                                             '+
'               <TpDato>0</TpDato>                                                                                 '+
'           </TabLocalita>                                                                                         '+
'           <TabLocalita>                                                                                          '+
'               <NumOccorrenza>15</NumOccorrenza>                                                                  '+
'               <TipoLocalitaUfficiale>1</TipoLocalitaUfficiale>                                                   '+
'               <DesTipoLocalitaUfficiale>COMUNE AMMINISTRATIVO</DesTipoLocalitaUfficiale>                         '+
'               <SigProvin>LE</SigProvin>                                                                          '+
'               <CodLingua>ITA</CodLingua>                                                                         '+
'               <CAP>73020</CAP>                                                                                   '+
'               <FlViarioNaz>S</FlViarioNaz>                                                                       '+
'               <FlViarioZon>N</FlViarioZon>                                                                       '+
'               <CodStatistico>016075015</CodStatistico>                                                           '+
'               <SigProvAmm>LE</SigProvAmm>                                                                        '+
'               <DesLocalitaAmm>CARPIGNANO SALENTINO</DesLocalitaAmm>                                              '+
'               <CodStatisticoAmm>016075015</CodStatisticoAmm>                                                     '+
'               <DesLocalitaRicerca>CARPIGNANO SALENTINO</DesLocalitaRicerca>                                      '+
'               <CAPRicerca>73020</CAPRicerca>                                                                     '+
'               <SigProRicerca>LE</SigProRicerca>                                                                  '+
'               <TipoElemento>1</TipoElemento>                                                                     '+
'               <FlSinonimo>N</FlSinonimo>                                                                         '+
'               <DesTipoCertificazione>DNA</DesTipoCertificazione>                                                 '+
'               <TipoCertificazione>1</TipoCertificazione>                                                         '+
'               <DesRegione>PUGLIA</DesRegione>                                                                    '+
'               <CodRegione>16</CodRegione>                                                                        '+
'               <DesProvin>LECCE</DesProvin>                                                                       '+
'               <DesLingua>Italia</DesLingua>                                                                      '+
'               <DesLocalitaUff>CARPIGNANO SALENTINO</DesLocalitaUff>                                              '+
'               <DesLocalitaOut>CARPIGNANO SALENTINO</DesLocalitaOut>                                              '+
'               <DesLocalitaAbb>CARPIGNANO SALENTINO</DesLocalitaAbb>                                              '+
'               <FlViarioSpe>N</FlViarioSpe>                                                                       '+
'               <CAPLocalitaAmm>73020</CAPLocalitaAmm>                                                             '+
'               <TpDato>0</TpDato>                                                                                 '+
'           </TabLocalita>                                                                                         '+
'           <TabLocalita>                                                                                          '+
'               <NumOccorrenza>16</NumOccorrenza>                                                                  '+
'               <TipoLocalitaUfficiale>1</TipoLocalitaUfficiale>                                                   '+
'               <DesTipoLocalitaUfficiale>COMUNE AMMINISTRATIVO</DesTipoLocalitaUfficiale>                         '+
'               <SigProvin>LE</SigProvin>                                                                          '+
'               <CodLingua>ITA</CodLingua>                                                                         '+
'               <CAP>73042</CAP>                                                                                   '+
'               <FlViarioNaz>S</FlViarioNaz>                                                                       '+
'               <FlViarioZon>N</FlViarioZon>                                                                       '+
'               <CodStatistico>016075016</CodStatistico>                                                           '+
'               <SigProvAmm>LE</SigProvAmm>                                                                        '+
'               <DesLocalitaAmm>CASARANO</DesLocalitaAmm>                                                          '+
'               <CodStatisticoAmm>016075016</CodStatisticoAmm>                                                     '+
'               <DesLocalitaRicerca>CASARANO</DesLocalitaRicerca>                                                  '+
'               <CAPRicerca>73042</CAPRicerca>                                                                     '+
'               <SigProRicerca>LE</SigProRicerca>                                                                  '+
'               <TipoElemento>1</TipoElemento>                                                                     '+
'               <FlSinonimo>N</FlSinonimo>                                                                         '+
'               <DesTipoCertificazione>DNA</DesTipoCertificazione>                                                 '+
'               <TipoCertificazione>1</TipoCertificazione>                                                         '+
'               <DesRegione>PUGLIA</DesRegione>                                                                    '+
'               <CodRegione>16</CodRegione>                                                                        '+
'               <DesProvin>LECCE</DesProvin>                                                                       '+
'               <DesLingua>Italia</DesLingua>                                                                      '+
'               <DesLocalitaUff>CASARANO</DesLocalitaUff>                                                          '+
'               <DesLocalitaOut>CASARANO</DesLocalitaOut>                                                          '+
'               <DesLocalitaAbb>CASARANO</DesLocalitaAbb>                                                          '+
'               <FlViarioSpe>N</FlViarioSpe>                                                                       '+
'               <CAPLocalitaAmm>73042</CAPLocalitaAmm>                                                             '+
'               <TpDato>0</TpDato>                                                                                 '+
'           </TabLocalita>                                                                                         '+
'           <TabLocalita>                                                                                          '+
'               <NumOccorrenza>17</NumOccorrenza>                                                                  '+
'               <TipoLocalitaUfficiale>1</TipoLocalitaUfficiale>                                                   '+
'               <DesTipoLocalitaUfficiale>COMUNE AMMINISTRATIVO</DesTipoLocalitaUfficiale>                         '+
'               <SigProvin>LE</SigProvin>                                                                          '+
'               <CodLingua>ITA</CodLingua>                                                                         '+
'               <CAP>73020</CAP>                                                                                   '+
'               <FlViarioNaz>S</FlViarioNaz>                                                                       '+
'               <FlViarioZon>N</FlViarioZon>                                                                       '+
'               <CodStatistico>016075017</CodStatistico>                                                           '+
'               <SigProvAmm>LE</SigProvAmm>                                                                        '+
'               <DesLocalitaAmm>CASTRI DI LECCE</DesLocalitaAmm>                                                   '+
'               <CodStatisticoAmm>016075017</CodStatisticoAmm>                                                     '+
'               <DesLocalitaRicerca>CASTRI DI LECCE</DesLocalitaRicerca>                                           '+
'               <CAPRicerca>73020</CAPRicerca>                                                                     '+
'               <SigProRicerca>LE</SigProRicerca>                                                                  '+
'               <TipoElemento>1</TipoElemento>                                                                     '+
'               <FlSinonimo>N</FlSinonimo>                                                                         '+
'               <DesTipoCertificazione>DNA</DesTipoCertificazione>                                                 '+
'               <TipoCertificazione>1</TipoCertificazione>                                                         '+
'               <DesRegione>PUGLIA</DesRegione>                                                                    '+
'               <CodRegione>16</CodRegione>                                                                        '+
'               <DesProvin>LECCE</DesProvin>                                                                       '+
'               <DesLingua>Italia</DesLingua>                                                                      '+
'               <DesLocalitaUff>CASTRI DI LECCE</DesLocalitaUff>                                                   '+
'               <DesLocalitaOut>CASTRI DI LECCE</DesLocalitaOut>                                                   '+
'               <DesLocalitaAbb>CASTRI DI LECCE</DesLocalitaAbb>                                                   '+
'               <FlViarioSpe>N</FlViarioSpe>                                                                       '+
'               <CAPLocalitaAmm>73020</CAPLocalitaAmm>                                                             '+
'               <TpDato>0</TpDato>                                                                                 '+
'           </TabLocalita>                                                                                         '+
'           <TabLocalita>                                                                                          '+
'               <NumOccorrenza>18</NumOccorrenza>                                                                  '+
'               <TipoLocalitaUfficiale>1</TipoLocalitaUfficiale>                                                   '+
'               <DesTipoLocalitaUfficiale>COMUNE AMMINISTRATIVO</DesTipoLocalitaUfficiale>                         '+
'               <SigProvin>LE</SigProvin>                                                                          '+
'               <CodLingua>ITA</CodLingua>                                                                         '+
'               <CAP>73020</CAP>                                                                                   '+
'               <FlViarioNaz>S</FlViarioNaz>                                                                       '+
'               <FlViarioZon>N</FlViarioZon>                                                                       '+
'               <CodStatistico>016075018</CodStatistico>                                                           '+
'               <SigProvAmm>LE</SigProvAmm>                                                                        '+
'               <DesLocalitaAmm>CASTRIGNANO DE GRECI</DesLocalitaAmm>                                             '+
'               <CodStatisticoAmm>016075018</CodStatisticoAmm>                                                     '+
'               <DesLocalitaRicerca>CASTRIGNANO DE GRECI</DesLocalitaRicerca>                                     '+
'               <CAPRicerca>73020</CAPRicerca>                                                                     '+
'               <SigProRicerca>LE</SigProRicerca>                                                                  '+
'               <TipoElemento>1</TipoElemento>                                                                     '+
'               <FlSinonimo>N</FlSinonimo>                                                                         '+
'               <DesTipoCertificazione>DNA</DesTipoCertificazione>                                                 '+
'               <TipoCertificazione>1</TipoCertificazione>                                                         '+
'               <DesRegione>PUGLIA</DesRegione>                                                                    '+
'               <CodRegione>16</CodRegione>                                                                        '+
'               <DesProvin>LECCE</DesProvin>                                                                       '+
'               <DesLingua>Italia</DesLingua>                                                                      '+
'               <DesLocalitaUff>CASTRIGNANO DE GRECI</DesLocalitaUff>                                             '+
'               <DesLocalitaOut>CASTRIGNANO DE GRECI</DesLocalitaOut>                                             '+
'               <DesLocalitaAbb>CASTRIGNANO DE GRECI</DesLocalitaAbb>                                              '+
'               <FlViarioSpe>N</FlViarioSpe>                                                                       '+
'               <CAPLocalitaAmm>73020</CAPLocalitaAmm>                                                             '+
'               <TpDato>0</TpDato>                                                                                 '+
'           </TabLocalita>                                                                                         '+
'           <TabLocalita>                                                                                          '+
'               <NumOccorrenza>19</NumOccorrenza>                                                                  '+
'               <TipoLocalitaUfficiale>1</TipoLocalitaUfficiale>                                                   '+
'               <DesTipoLocalitaUfficiale>COMUNE AMMINISTRATIVO</DesTipoLocalitaUfficiale>                         '+
'               <SigProvin>LE</SigProvin>                                                                          '+
'               <CodLingua>ITA</CodLingua>                                                                         '+
'               <CAP>73040</CAP>                                                                                   '+
'               <FlViarioNaz>S</FlViarioNaz>                                                                       '+
'               <FlViarioZon>N</FlViarioZon>                                                                       '+
'               <CodStatistico>016075019</CodStatistico>                                                           '+
'               <SigProvAmm>LE</SigProvAmm>                                                                        '+
'               <DesLocalitaAmm>CASTRIGNANO DEL CAPO</DesLocalitaAmm>                                              '+
'               <CodStatisticoAmm>016075019</CodStatisticoAmm>                                                     '+
'               <DesLocalitaRicerca>CASTRIGNANO DEL CAPO</DesLocalitaRicerca>                                      '+
'               <CAPRicerca>73040</CAPRicerca>                                                                     '+
'               <SigProRicerca>LE</SigProRicerca>                                                                  '+
'               <TipoElemento>1</TipoElemento>                                                                     '+
'               <FlSinonimo>N</FlSinonimo>                                                                         '+
'               <DesTipoCertificazione>DNA</DesTipoCertificazione>                                                 '+
'               <TipoCertificazione>1</TipoCertificazione>                                                         '+
'               <DesRegione>PUGLIA</DesRegione>                                                                    '+
'               <CodRegione>16</CodRegione>                                                                        '+
'               <DesProvin>LECCE</DesProvin>                                                                       '+
'               <DesLingua>Italia</DesLingua>                                                                      '+
'               <DesLocalitaUff>CASTRIGNANO DEL CAPO</DesLocalitaUff>                                              '+
'               <DesLocalitaOut>CASTRIGNANO DEL CAPO</DesLocalitaOut>                                              '+
'               <DesLocalitaAbb>CASTRIGNANO DEL CAPO</DesLocalitaAbb>                                              '+
'               <FlViarioSpe>N</FlViarioSpe>                                                                       '+
'               <CAPLocalitaAmm>73040</CAPLocalitaAmm>                                                             '+
'               <TpDato>0</TpDato>                                                                                 '+
'           </TabLocalita>                                                                                         '+
'           <TabLocalita>                                                                                          '+
'               <NumOccorrenza>20</NumOccorrenza>                                                                  '+
'               <TipoLocalitaUfficiale>1</TipoLocalitaUfficiale>                                                   '+
'               <DesTipoLocalitaUfficiale>COMUNE AMMINISTRATIVO</DesTipoLocalitaUfficiale>                         '+
'               <SigProvin>LE</SigProvin>                                                                          '+
'               <CodLingua>ITA</CodLingua>                                                                         '+
'               <CAP>73030</CAP>                                                                                   '+
'               <FlViarioNaz>S</FlViarioNaz>                                                                       '+
'               <FlViarioZon>N</FlViarioZon>                                                                       '+
'               <CodStatistico>016075096</CodStatistico>                                                           '+
'               <SigProvAmm>LE</SigProvAmm>                                                                        '+
'               <DesLocalitaAmm>CASTRO</DesLocalitaAmm>                                                            '+
'               <CodStatisticoAmm>016075096</CodStatisticoAmm>                                                     '+
'               <DesLocalitaRicerca>CASTRO</DesLocalitaRicerca>                                                    '+
'               <CAPRicerca>73030</CAPRicerca>                                                                     '+
'               <SigProRicerca>LE</SigProRicerca>                                                                  '+
'               <TipoElemento>1</TipoElemento>                                                                     '+
'               <FlSinonimo>N</FlSinonimo>                                                                         '+
'               <DesTipoCertificazione>DNA</DesTipoCertificazione>                                                 '+
'               <TipoCertificazione>1</TipoCertificazione>                                                         '+
'               <DesRegione>PUGLIA</DesRegione>                                                                    '+
'               <CodRegione>16</CodRegione>                                                                        '+
'               <DesProvin>LECCE</DesProvin>                                                                       '+
'               <DesLingua>Italia</DesLingua>                                                                      '+
'               <DesLocalitaUff>CASTRO</DesLocalitaUff>                                                            '+
'               <DesLocalitaOut>CASTRO</DesLocalitaOut>                                                            '+
'               <DesLocalitaAbb>CASTRO</DesLocalitaAbb>                                                            '+
'               <FlViarioSpe>N</FlViarioSpe>                                                                       '+
'               <CAPLocalitaAmm>73030</CAPLocalitaAmm>                                                             '+
'               <TpDato>0</TpDato>                                                                                 '+
'           </TabLocalita>                                                                                         '+
'                                                                                                                  '+
'           <Esito>                                                                                                '+
'               <CodiceEsito>0</CodiceEsito>                                                                       '+
'           </Esito>                                                                                               '+
'       </RispostaLocalita>                                                                                        '+
'   </soapenv:Body>                                                                                                '+
'</soapenv:Envelope>';
           myXml=myXml.normalizespace();

      res.setBody(myXml);

      //res.setStatusCode(200);

      return res;

    }

}