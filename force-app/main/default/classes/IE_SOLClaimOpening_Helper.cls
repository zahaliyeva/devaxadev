/*------------------------------------------------------------------------------------------
Author:        Marco Moscatelli
Company:       Deloitte
Class:         IE_SOLClaimOpening_Helper
Description:   Apex class used to execute all the logics internal to the 
rest Callout related to Caring Angel

History

4/10/2018     Created 
-------------------------------------------------------------------------------------------*/
public without sharing class IE_SOLClaimOpening_Helper
{
    public static IE_Integration_Record__c PopulateIErecord_CreateClaim(Questionario_CA__c theQuestionnaire, String caseId)
  {
    IE_Integration_Record__c theResult = new IE_Integration_Record__c();

    List<IE_Configuration__c> theConfig = [SELECT id,NameSpacePrefix1__c,NameSpacePrefix2__c,NameSpaceUri1__c,NameSpaceUri2__c FROM IE_Configuration__c WHERE Name='SOL_Claim_Insert' LIMIT 1];
        
        if (!theConfig.isempty())
        {
            theresult.IE_Configuration__c = theConfig[0].id;
        }

    //System.debug('the theQuestionnaire: ' + theQuestionnaire);

        String compiledrequest = IE_SOLClaimOpening_Helper.createJson(theQuestionnaire, caseId);

        //system.debug ('compiledrequest'+compiledrequest);
        theResult.DevField__c = compiledrequest;
        theresult.RequestBody__c = compiledrequest;
        theResult.ScopeID__c = theQuestionnaire.id;

        return theResult;
  }
    private static String dateFormat(Date dateToFormat){
        String DayString;
        String MonthString;
        if(dateToFormat.day()<10)
            DayString='0'+dateToFormat.day()+'/';
        else
            DayString=dateToFormat.day()+'/';     
        if(dateToFormat.month()<10)
            MonthString='0'+dateToFormat.month()+'/';
        else
            MonthString=dateToFormat.month()+'/';          
        return DayString+MonthString+dateToFormat.year();
    }
    public static IE_SOLClaimOpening.ResponseDto manageResponse(IE_Engine IEInstance)
   {
        IE_SOLClaimOpening.ResponseDto results = new IE_SOLClaimOpening.ResponseDto();
        
        //system.debug('****** IEInstance =' + IEInstance);
        GetSOLDetailResponse formattedResponse = mapResponse_GetClaimDetail(IEInstance.JSONResponse);
    
    if (formattedResponse == null)
        {
            results.isSuccess = False;
            results.message = 'Errore nell\'interpretazione della risposta di integrazione con SOL: Errore risposta vuota'; 
        }
        else if (formattedResponse.MessageHeader.ResultMessage <> 1 )
    {
      results.isSuccess = False;
            if(!formattedResponse.MessageBody.Errori.isempty())
              results.message = formattedResponse.MessageBody.Errori[0]; 
            else
              results.message = formattedResponse.MessageHeader.Resultexception; 

            results.values.put('code',formattedResponse.MessageHeader.ResultMessage);
    }
    else
    {
      system.debug ('******SUCCESS');                       
            GetClaimDetail_setResponse (formattedResponse);          
            results.isSuccess = True;
            results.values.put('url',formattedResponse.MessageBody.Url);         
    }
    system.debug('results --> '+results);
        return results;

    }

    public static void GetClaimDetail_setResponse(GetSOLDetailResponse theResponse)
    {
       system.debug('theResponse -->  '+theResponse);
    }

    public static GetSOLDetailResponse  mapResponse_GetClaimDetail (String JSONResponse)
    {
      
        /*GetClaimDetailResponse emptyInstance = new GetClaimDetailResponse();
        Type typeInstance = Type.forName('GetAllClaimsResponse');*/
        GetSOLDetailResponse deserializedResponse = new GetSOLDetailResponse();
        //system.debug('JSONResponse : '+JSONResponse);
        //JSONResponse = JSONResponse.replaceAll('date','dateSFDC');     //replace 'date' field cause the Identifier name 'date' is reserved.
        //JSONResponse = JSONResponse.replaceAll('url','urlSFDC');    //replace 'url' field cause the Identifier name 'url' is reserved.
        //system.debug('JSONResponse after replace: '+JSONResponse);
        //deserializedResponse = (GetClaimDetailResponse)JSON.deserialize(JSONResponse, GetClaimDetailResponse.class);
        deserializedResponse = parseResponse(JSONResponse);
    System.debug('***************deserialize(OBJECT) result = ' + deserializedResponse);
        
        return deserializedResponse;
    }

    public static GetSOLDetailResponse parseResponse(String json)
    {
        return (GetSOLDetailResponse) System.JSON.deserialize(json, GetSOLDetailResponse.class);
    }

    public static String codiceAppDaNumeroPolizza(String Numero_Polizza){
    String response = '';
    try {     
        if( String.isNotBlank(Numero_Polizza)){
            List<String> partsOfNumber = Numero_Polizza.split('\\.');
            if(partsOfNumber.size()!=0)
                if(partsOfNumber.get(partsOfNumber.size()-1)!=null){
                    String polizza = partsOfNumber.get(partsOfNumber.size()-1);
                    if(polizza.length()==9)
                        return '';
                    else{
                    if(polizza.length()>9)
                        return polizza.substring(9, polizza.length()) ;
                    return '';
                    }
                }
        }
    }catch (Exception error) {
        return '';
    } 
    return response;
    }

    public static String createJson(Questionario_CA__c theQuestionnaire, String caseId)
    {
        JSONGenerator generator = JSON.createGenerator(true);

        generator.writeStartObject();
        //Case
        generator.writeStringField('idcase', caseId);

        //Start parameter
        generator.writeFieldName('parameter');
        generator.writeStartArray();

        generator.writeStartObject();
        
        //NC 28/11/2023
        generator.writeStringField('idQuestionario', theQuestionnaire.id);

        //MOSCATELLI_M 13/03/2019: Axa Assistance -- START
        String CurrentUsrProfile = [Select Name from Profile where id=: UserInfo.getProfileId() limit 1].Name;

        Set<String> CaringSaluteProfile = new Set<String>{'AXA Caring Salute HD1', 'AXA Caring Salute HD2', 'AXA Caring Salute Supervisor', 'HD1 Outsourcer Salute', 'HD1 Outsourcer Supervisor'};
        Set<String> CaringPropertyProfile = new Set<String>{'Caring Angel Property - HD1', 'Caring Angel Property - HD2', 'Caring Angel Property - Supervisor'};
        if(theQuestionnaire.Caring_Angel_Type__c=='Caring Angel Light')
            generator.writeStringField('Caller', '05');
        else{
            for(Assistenza_sinistri__mdt AssSin: [Select  TipoGestioneHealth__c,  Value__c,Key__c from Assistenza_sinistri__mdt where DeveloperName like 'CallerType%']){
                if(AssSin.Key__c == CurrentUsrProfile){   
                    generator.writeStringField('Caller', ''+AssSin.Value__c);
                    if (CaringSaluteProfile.contains(CurrentUsrProfile) ){
                        generator.writeStringField('TipoGestioneHealth', ''+ AssSin.TipoGestioneHealth__c);                      
                    }   
                }        
            }
        }
        //MOSCATELLI_M 13/03/2019: Axa Assistance -- END
        String numApplicazione='';
        if(!String.isBlank(theQuestionnaire.NumApplicazione__c))
            numApplicazione=theQuestionnaire.NumApplicazione__c;
        if (CaringSaluteProfile.contains(CurrentUsrProfile) || theQuestionnaire.Compagnia__c == 'AAI')
            generator.writeStringField('NumApplicazione', numApplicazione);
        else if(theQuestionnaire.Compagnia__c == 'MPS'){
            generator.writeStringField('IdAdesione', numApplicazione);
        }
        if(theQuestionnaire.Data_Evento__c!=null)
        {
            generator.writeStringField('DataEvento', ''+dateFormat(theQuestionnaire.Data_Evento__c));          
        }

        if(String.isNotBlank(theQuestionnaire.Id_Polizza_SOL__c)) {
            generator.writeStringField('NumeroPolizza', ''+theQuestionnaire.Id_Polizza_SOL__c); 

            if(String.isNotBlank(theQuestionnaire.Numero_Polizza__c))
                if(String.isNotBlank(codiceAppDaNumeroPolizza(theQuestionnaire.Numero_Polizza__c))){ 
                    // *-+ 28-12-2022 è valorizzato con più di 9 cifre aggiunge altro parametro
                    generator.writeStringField('NumApplicazione', ''+ codiceAppDaNumeroPolizza(theQuestionnaire.Numero_Polizza__c));
                }         
        } else 
        if(String.isNotBlank(theQuestionnaire.Numero_Polizza__c)){
            system.debug('****NUmeropoliza-'+theQuestionnaire.Numero_Polizza__c);
            generator.writeStringField('NumeroPolizza', ''+theQuestionnaire.Numero_Polizza__c); 

            if(String.isNotBlank(codiceAppDaNumeroPolizza(theQuestionnaire.Numero_Polizza__c))){ 
                // *-+ 28-12-2022 è valorizzato con più di 9 cifre aggiunge altro parametro
                generator.writeStringField('NumApplicazione', ''+ codiceAppDaNumeroPolizza(theQuestionnaire.Numero_Polizza__c));
            }
        }
        if(String.isNotBlank(theQuestionnaire.Targa__c))
        {
            generator.writeStringField('Targa', ''+theQuestionnaire.Targa__c);         
        } 

        if(String.isNotBlank(theQuestionnaire.Luogo_Evento__c))
        {
            generator.writeStringField('LuogoEvento', ''+theQuestionnaire.Luogo_Evento__c);         
        }
        
        if(String.isNotBlank(theQuestionnaire.Indirizzo_Evento__c))
        {
            generator.writeStringField('IndirizzoEvento', ''+theQuestionnaire.Indirizzo_Evento__c);          
        }
        
        if(String.isNotBlank(theQuestionnaire.CAP_Evento__c))
        {
            generator.writeStringField('CapEvento', ''+theQuestionnaire.CAP_Evento__c);          
        }
        
        if(String.isNotBlank(theQuestionnaire.Citt_Evento__c))
        {
            generator.writeStringField('ComuneEvento', ''+theQuestionnaire.Citt_Evento__c);          
        }
        
        if(String.isNotBlank(theQuestionnaire.Provincia_Evento__c))
        {
            generator.writeStringField('ProvinciaEvento', ''+theQuestionnaire.Provincia_Evento__c);          
        }
        
        if(String.isNotBlank(theQuestionnaire.Stato_Evento__c))
        {
            generator.writeStringField('NazioneEvento', ''+theQuestionnaire.Stato_Evento__c);          
        }
        /*     generator.writeEndObject();

        //Start Contraente
        generator.writeFieldName('Contraente');
        generator.writeStartObject();*/

        if(String.isNotBlank(theQuestionnaire.Nome_contraente__c))
        {
            generator.writeStringField('Nome_contraente', ''+theQuestionnaire.Nome_contraente__c);          
        }

        if(String.isNotBlank(theQuestionnaire.Cognome_Contraente__c))
        {
            generator.writeStringField('Cognome_contraente', ''+theQuestionnaire.Cognome_Contraente__c);          
        }

        if(theQuestionnaire.Data_di_nascita_contraente__c!=null)
        {
          //OAVERSANO 04/12/2018 : Enhancement Date -- START
          String DayStringDatacontraente;
          if(theQuestionnaire.Data_di_nascita_contraente__c.day()<10)
            DayStringDatacontraente = '0'+theQuestionnaire.Data_di_nascita_contraente__c.day()+'/';
          else
            DayStringDatacontraente = theQuestionnaire.Data_di_nascita_contraente__c.day()+'/';
            //OAVERSANO 08/01/2019 : Enhancement Month -- START
            String MonthStringDatacontraente;

            if(theQuestionnaire.Data_di_nascita_contraente__c.month()<10)
                MonthStringDatacontraente = '0'+theQuestionnaire.Data_di_nascita_contraente__c.month()+'/';
            else
                MonthStringDatacontraente = theQuestionnaire.Data_di_nascita_contraente__c.month()+'/';          

          //String DateString = DayStringDatacontraente+theQuestionnaire.Data_di_nascita_contraente__c.month()+'/'+theQuestionnaire.Data_di_nascita_contraente__c.year();
          String DateString = DayStringDatacontraente+MonthStringDatacontraente+theQuestionnaire.Data_di_nascita_contraente__c.year();
            //OAVERSANO 08/01/2019 : Enhancement Month -- END
            //OAVERSANO 04/12/2018 : Enhancement Date -- END
            generator.writeStringField('Data_nascita_contraente', ''+DateString);          
        }

        if(String.isNotBlank(theQuestionnaire.Codice_fiscale_contraente__c))
        {
            generator.writeStringField('CF_contraente', ''+theQuestionnaire.Codice_fiscale_contraente__c);          
        }

        if(String.isNotBlank(theQuestionnaire.Indirizzo_Contraente__c))
        {
            generator.writeStringField('Indirizzo_residenza_contraente', ''+theQuestionnaire.Indirizzo_Contraente__c);          
        }
        
        if(String.isNotBlank(theQuestionnaire.Citt_Contraente__c))
        {
            generator.writeStringField('Citta_residenza_contraente', ''+theQuestionnaire.Citt_Contraente__c);          
        }

        if(String.isNotBlank(theQuestionnaire.Provincia_Contraente__c))
        {
            generator.writeStringField('Provincia_residenza_contraente', ''+theQuestionnaire.Provincia_Contraente__c);          
        }

        if(String.isNotBlank(theQuestionnaire.CAP_Contraente__c))
        {
            generator.writeStringField('Cap_residenza_contraente', ''+theQuestionnaire.CAP_Contraente__c);          
        }

        if(String.isNotBlank(theQuestionnaire.Stato_Contraente__c))
        {
            generator.writeStringField('Stato_residenza_contraente', ''+theQuestionnaire.Stato_Contraente__c);          
        }

        if(String.isNotBlank(theQuestionnaire.Indirizzo_Domicilio_Contraente__c))
        {
            generator.writeStringField('Indirizzo_domicilio_contraente', ''+theQuestionnaire.Indirizzo_Domicilio_Contraente__c);          
        }
        
        if(String.isNotBlank(theQuestionnaire.Citt_Domicilio_Contraente__c))
        {
            generator.writeStringField('Citta_domicilio_contraente', ''+theQuestionnaire.Citt_Domicilio_Contraente__c);          
        }

        if(String.isNotBlank(theQuestionnaire.Provincia_Domicilio_Contraente__c))
        {
            generator.writeStringField('Provincia_domicilio_contraente', ''+theQuestionnaire.Provincia_Domicilio_Contraente__c);          
        }

        if(String.isNotBlank(theQuestionnaire.CAP_Domicilio_Contraente__c))
        {    
            generator.writeStringField('Cap_domicilio_contraente', ''+theQuestionnaire.CAP_Domicilio_Contraente__c);          
        }

        if(String.isNotBlank(theQuestionnaire.Stato_Domicilio_Contraente__c))
        {    
            generator.writeStringField('Stato_domicilio_contraente', ''+theQuestionnaire.Stato_Domicilio_Contraente__c);          
        }

        if(String.isNotBlank(theQuestionnaire.Telefono__c))
        {    
            generator.writeStringField('telefono_contraente', ''+theQuestionnaire.Telefono__c);          
        }

        if(String.isNotBlank(theQuestionnaire.Email_Contraente__c))
        {    
            generator.writeStringField('email_contraente', ''+theQuestionnaire.Email_Contraente__c);          
        }
        if (!CaringSaluteProfile.contains(CurrentUsrProfile) )
           generator.writeBooleanField('conducente_is_contraente', theQuestionnaire.Conducente_contraente__c);
                
        /*        generator.writeEndObject();

        //Start Conducente
        generator.writeFieldName('Conducente');
        generator.writeStartObject();*/

        if(String.isNotBlank(theQuestionnaire.Nome_conducente__c))
        {
            generator.writeStringField('Nome_conducente', ''+theQuestionnaire.Nome_conducente__c);          
        }

        if(String.isNotBlank(theQuestionnaire.Cognome_Conducente__c))
        {
            generator.writeStringField('Cognome_conducente', ''+theQuestionnaire.Cognome_Conducente__c);          
        }

        if(theQuestionnaire.Data_di_nascita_conducente__c!=null)
        {
          //OAVERSANO 04/12/2018 : Enhancement Date -- START
          String DayStringDataconducente;
          if(theQuestionnaire.Data_di_nascita_conducente__c.day()<10)
            DayStringDataconducente = '0'+theQuestionnaire.Data_di_nascita_conducente__c.day()+'/';
          else
            DayStringDataconducente = theQuestionnaire.Data_di_nascita_conducente__c.day()+'/';
            //OAVERSANO 08/01/2019 : Enhancement Month -- START
            String MonthStringDataconducente;

            if(theQuestionnaire.Data_di_nascita_conducente__c.month()<10)
                MonthStringDataconducente = '0'+theQuestionnaire.Data_di_nascita_conducente__c.month()+'/';
            else
                MonthStringDataconducente = theQuestionnaire.Data_di_nascita_conducente__c.month()+'/';      
            
          //String DateString = DayStringDataconducente+theQuestionnaire.Data_di_nascita_conducente__c.month()+'/'+theQuestionnaire.Data_di_nascita_conducente__c.year();
          String DateString = DayStringDataconducente+MonthStringDataconducente+theQuestionnaire.Data_di_nascita_conducente__c.year();
            //OAVERSANO 08/01/2019 : Enhancement Month -- END
            //OAVERSANO 04/12/2018 : Enhancement Date -- END
            generator.writeStringField('Data_nascita_conducente', ''+DateString);          
        }

        if(String.isNotBlank(theQuestionnaire.Codice_fiscale_conducente__c))
        {
            generator.writeStringField('CF_conducente', ''+theQuestionnaire.Codice_fiscale_conducente__c);          
        }

        if(String.isNotBlank(theQuestionnaire.Indirizzo_Conducente__c))
        {
            generator.writeStringField('Indirizzo_residenza_conducente', ''+theQuestionnaire.Indirizzo_Conducente__c);          
        }
        
        if(String.isNotBlank(theQuestionnaire.Citt_Conducente__c))
        {
            generator.writeStringField('Citta_residenza_conducente', ''+theQuestionnaire.Citt_Conducente__c);          
        }

        if(String.isNotBlank(theQuestionnaire.Provincia_Conducente__c))
        {
            generator.writeStringField('Provincia_residenza_conducente', ''+theQuestionnaire.Provincia_Conducente__c);          
        }

        if(String.isNotBlank(theQuestionnaire.CAP_Conducente__c))
        {
            generator.writeStringField('Cap_residenza_conducente', ''+theQuestionnaire.CAP_Conducente__c);          
        }

        if(String.isNotBlank(theQuestionnaire.Stato_Conducente__c))
        {
            generator.writeStringField('Stato_residenza_conducente', ''+theQuestionnaire.Stato_Conducente__c);          
        }

        if(String.isNotBlank(theQuestionnaire.Indirizzo_Domicilio_Conducente__c))
        {
            generator.writeStringField('Indirizzo_domicilio_conducente', ''+theQuestionnaire.Indirizzo_Domicilio_Conducente__c);          
        }
        
        if(String.isNotBlank(theQuestionnaire.Citt_Domicilio_Conducente__c))
        {
            generator.writeStringField('Citta_domicilio_conducente', ''+theQuestionnaire.Citt_Domicilio_Conducente__c);          
        }

        if(String.isNotBlank(theQuestionnaire.Provincia_Domicilio_Conducente__c))
        {
            generator.writeStringField('Provincia_domicilio_conducente', ''+theQuestionnaire.Provincia_Domicilio_Conducente__c);          
        }

        if(String.isNotBlank(theQuestionnaire.CAP_Domicilio_Conducente__c))
        {
            generator.writeStringField('Cap_domicilio_conducente', ''+theQuestionnaire.CAP_Domicilio_Conducente__c);          
        }

        if(String.isNotBlank(theQuestionnaire.Stato_Domicilio_Conducente__c))
        {
            generator.writeStringField('Stato_domicilio_conducente', ''+theQuestionnaire.Stato_Domicilio_Conducente__c);          
        }

        if(String.isNotBlank(theQuestionnaire.Telefono_conducente__c))
        {
            generator.writeStringField('telefono_conducente', ''+theQuestionnaire.Telefono_conducente__c);          
        }

        if(String.isNotBlank(theQuestionnaire.Email_conducente__c))
        {
            generator.writeStringField('email_conducente', ''+theQuestionnaire.Email_conducente__c);          
        }

        generator.writeStringField('DataDenuncia',dateFormat(System.Today()));          


        /*      generator.writeEndObject();

        //Start Sinistro
        generator.writeFieldName('Sinistro');
        generator.writeStartObject();*/

        if(theQuestionnaire.Ora_Evento__c!=null)
        {
          String EventTime = theQuestionnaire.Ora_Evento__c.hour()+':'+(theQuestionnaire.Ora_Evento__c.minute() < 10 ? '0':'')+theQuestionnaire.Ora_Evento__c.minute();
            generator.writeStringField('ora_evento', ''+EventTime);          
        } 

        if(String.isNotBlank(theQuestionnaire.Luogo_Evento__c))
        {
            generator.writeStringField('luogo_evento', ''+theQuestionnaire.Luogo_Evento__c);          
        }  

        if(String.isNotBlank(theQuestionnaire.Descrizione_dinamica__c))
        {
            generator.writeStringField('descrizione_dinamica', ''+theQuestionnaire.Descrizione_dinamica__c);          
        }   

        if(String.isNotBlank(theQuestionnaire.Ambulanza__c))
        {
            generator.writeBooleanField('ambulanza_richiesta', (theQuestionnaire.Ambulanza__c=='Sì')?true:false);

            if(theQuestionnaire.Ambulanza__c=='No' && String.isNotBlank(theQuestionnaire.Note_ambulanza__c))
            {
              generator.writeStringField('ambulanza_note', ''+theQuestionnaire.Note_ambulanza__c.tolowercase());
            }          
        }   

        if(String.isNotBlank(theQuestionnaire.Autorit__c))
        {
            generator.writeBooleanField('autorita_richiesta', (theQuestionnaire.Autorit__c=='Sì')?true:false);

            if(theQuestionnaire.Autorit__c=='No' && String.isNotBlank(theQuestionnaire.Note_autorit__c))
            {
              generator.writeStringField('autorita_note', ''+theQuestionnaire.Note_autorit__c.tolowercase());
            }          
        }  

        if(String.isNotBlank(theQuestionnaire.Carro__c))
        {
            generator.writeBooleanField('carroattrezzi_richiesta', (theQuestionnaire.Carro__c=='Sì')?true:false);

            if(theQuestionnaire.Autorit__c=='No' && String.isNotBlank(theQuestionnaire.Note_carroattrezzi__c))
            {
              generator.writeStringField('carroattrezzi_note', ''+theQuestionnaire.Note_carroattrezzi__c.tolowercase());
            }          
        }   
        
        if(String.isNotBlank(theQuestionnaire.Note__c))
        {
            generator.writeStringField('note', ''+theQuestionnaire.Note__c);                     
        }                  

        /*       generator.writeEndObject();

        //Start Controparte
        generator.writeFieldName('Controparte');
        generator.writeStartObject();*/

        if(String.isNotBlank(theQuestionnaire.Targa_controparte__c))
        {
            generator.writeStringField('Targa_controparte', ''+theQuestionnaire.Targa_controparte__c);          
        }

        if(String.isNotBlank(theQuestionnaire.Tipologia_Targa__c))
        {
            generator.writeStringField('Tipo_targa_controparte', ''+theQuestionnaire.Tipologia_Targa__c);          
        }      

        if(String.isNotBlank(theQuestionnaire.Nome_controparte__c))
        {
            generator.writeStringField('Nome_controparte', ''+theQuestionnaire.Nome_controparte__c);          
        }

        if(String.isNotBlank(theQuestionnaire.Cognome_Controparte__c))
        {
            generator.writeStringField('Cognome_controparte', ''+theQuestionnaire.Cognome_Controparte__c);          
        }

        if(theQuestionnaire.Data_di_nascita_controparte__c!=null)
        {
          //OAVERSANO 04/12/2018 : Enhancement Date -- START
          String DayStringDatacontroparte;
          if(theQuestionnaire.Data_di_nascita_controparte__c.day()<10)
            DayStringDatacontroparte = '0'+theQuestionnaire.Data_di_nascita_controparte__c.day()+'/';
          else
            DayStringDatacontroparte = theQuestionnaire.Data_di_nascita_controparte__c.day()+'/';
            //OAVERSANO 08/01/2019 : Enhancement Month -- START
            String MonthStringDatacontroparte;

            if(theQuestionnaire.Data_di_nascita_controparte__c.month()<10)
                MonthStringDatacontroparte = '0'+theQuestionnaire.Data_di_nascita_controparte__c.month()+'/';
            else
                MonthStringDatacontroparte = theQuestionnaire.Data_di_nascita_controparte__c.month()+'/';              
            
          //String DateString = DayStringDatacontroparte+theQuestionnaire.Data_di_nascita_controparte__c.month()+'/'+theQuestionnaire.Data_di_nascita_controparte__c.year();
          String DateString = DayStringDatacontroparte+MonthStringDatacontroparte+theQuestionnaire.Data_di_nascita_controparte__c.year();
            //OAVERSANO 08/01/2019 : Enhancement Month -- END
            //OAVERSANO 04/12/2018 : Enhancement Date -- END
            generator.writeStringField('Data_nascita_controparte', ''+DateString);          
        }

        if(String.isNotBlank(theQuestionnaire.Codice_fiscale_controparte__c))
        {
            generator.writeStringField('CF_controparte', ''+theQuestionnaire.Codice_fiscale_controparte__c);          
        }

        if(String.isNotBlank(theQuestionnaire.Indirizzo_Controparte__c))
        {
            generator.writeStringField('Indirizzo_residenza_controparte', ''+theQuestionnaire.Indirizzo_Controparte__c);          
        }
        
        if(String.isNotBlank(theQuestionnaire.Citt_Controparte__c))
        {
            generator.writeStringField('Citta_residenza_controparte', ''+theQuestionnaire.Citt_Controparte__c);          
        }

        if(String.isNotBlank(theQuestionnaire.Provincia_Controparte__c))
        {
            generator.writeStringField('Provincia_residenza_controparte', ''+theQuestionnaire.Provincia_Controparte__c);          
        }

        if(String.isNotBlank(theQuestionnaire.CAP_Controparte__c))
        {
            generator.writeStringField('Cap_residenza_controparte', ''+theQuestionnaire.CAP_Controparte__c);          
        }

        if(String.isNotBlank(theQuestionnaire.Stato_Controparte__c))
        {
            generator.writeStringField('Stato_residenza_controparte', ''+theQuestionnaire.Stato_Controparte__c);          
        }

        if(String.isNotBlank(theQuestionnaire.Indirizzo_Domicilio_Controparte__c))
        {
            generator.writeStringField('Indirizzo_domicilio_controparte', ''+theQuestionnaire.Indirizzo_Domicilio_Controparte__c);          
        }
        
        if(String.isNotBlank(theQuestionnaire.Citt_Domicilio_Controparte__c))
        {
            generator.writeStringField('Citta_domicilio_controparte', ''+theQuestionnaire.Citt_Domicilio_Controparte__c);          
        }

        if(String.isNotBlank(theQuestionnaire.Provincia_Domicilio_Controparte__c))
        {
            generator.writeStringField('Provincia_domicilio_controparte', ''+theQuestionnaire.Provincia_Domicilio_Controparte__c);          
        }

        if(String.isNotBlank(theQuestionnaire.CAP_Domicilio_Controparte__c))
        {
            generator.writeStringField('Cap_domicilio_controparte', ''+theQuestionnaire.CAP_Domicilio_Controparte__c);          
        }

        if(String.isNotBlank(theQuestionnaire.Stato_Domicilio_Controparte__c))
        {
            generator.writeStringField('Stato_domicilio_controparte', ''+theQuestionnaire.Stato_Domicilio_Controparte__c);          
        }

        if(String.isNotBlank(theQuestionnaire.Telefono_controparte__c))
        {
            generator.writeStringField('telefono_controparte', ''+theQuestionnaire.Telefono_controparte__c);          
        }

        if(String.isNotBlank(theQuestionnaire.Email_Controparte__c))
        {
            generator.writeStringField('email_controparte', ''+theQuestionnaire.Email_Controparte__c);          
        }

        if(String.isNotBlank(theQuestionnaire.Tipo_controparte__c))
        {
            generator.writeStringField('descrizione_dati_controparte', ''+theQuestionnaire.Tipo_controparte__c);          
        }

        if(String.isNotBlank(theQuestionnaire.Tipo_controparte__c))
        {
            generator.writeStringField('Tipo_veicolo_controparte', ''+theQuestionnaire.Tipo_controparte__c);          
        }

        //Giorgio Bonifazi - Caring Angel Fase 2 - START
        if(String.isNotBlank(theQuestionnaire.assistenza_cai_richiesta__c))
        {
            generator.writeBooleanField('assistenza_cai_richiesta', (theQuestionnaire.assistenza_cai_richiesta__c=='Sì')?true:false);          
        }

        

        //Giorgio Bonifazi - Caring Angel Fase 2 - END

        generator.writeEndObject();

        generator.writeEndArray();
        generator.writeEndObject();

        String result = generator.getAsString();
        return result;
    }
}