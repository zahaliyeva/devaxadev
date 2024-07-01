public without sharing class CIF_Communication_Helper {

    /**  public static final Id AXA_TECHNICAL_USER_ID = (AAI_Code_Variables__c.getAll()).get('AXA_TECHNICAL_USER_ID') != null ? (AAI_Code_Variables__c.getAll()).get('AXA_TECHNICAL_USER_ID').Value__c : UserInfo.getUserId(); **/
      
    public static IE_Integration_Record__c PopulateIErecord_SearchAccount (AccountSearchCtrl.RequestObj req, Boolean isB2C){
          IE_Integration_Record__c theResult = new IE_Integration_Record__c();
          List<IE_Configuration__c> theConfig = [SELECT id,NameSpacePrefix1__c,NameSpacePrefix2__c,NameSpaceUri1__c,NameSpaceUri2__c FROM IE_Configuration__c WHERE Name='CIF_Integration_AccountSearch' LIMIT 1];
          if (!theConfig.isempty()) {
              theresult.IE_Configuration__c = theConfig[0].id;
          }
          //Compiling the DevField with the JSON 
          JSONGenerator myGen= JSON.createGenerator(true);
          
          String NameSpacePrefixToUse1 = theConfig[0].NameSpacePrefix1__c;
          String NameSpacePrefixToUse2 = theConfig[0].NameSpacePrefix2__c;
          String NameSpaceUriToUse1 = theConfig[0].NameSpaceUri1__c;
          String NameSpaceUriToUse2 = theConfig[0].NameSpaceUri2__c;
          
          //initialise writer
          XmlStreamWriter w = new XmlStreamWriter();
          
          //ENVELOPE
          w.writeStartElement(NameSpacePrefixToUse1, 'Envelope',NameSpaceUriToUse1+'');
          w.writeNamespace(NameSpacePrefixToUse1, NameSpaceUriToUse1+'');
          w.writeNamespace(NameSpacePrefixToUse2, NameSpaceUriToUse2+'');
          
          //HEADER OPEN-CLOSE
          w.writeEmptyElement(NameSpacePrefixToUse1, 'Header', NameSpacePrefixToUse1); 
          
          //BODY
          w.writeStartElement(NameSpacePrefixToUse1, 'Body', NameSpaceUriToUse1);
          w.writeStartElement(NameSpacePrefixToUse2, 'ricercaSoggetto', NameSpaceUriToUse2);
  
  
          myGen.writeStartObject();
          myGen.writeFieldName('arg0');
          w.writeStartElement('', 'arg0', '');
  
          myGen.writeStartObject();
          
          if(isB2C){
          
              myGen.writeStringField('sistemaFonte','CRM');
              w.writeStartElement('', 'sistemaFonte', '');
              w.writeCharacters('CRM');
              w.writeEndElement();
              
              
              myGen.writeStringField('tipoSoggetto','1');
              w.writeStartElement('', 'tipoSoggetto', '');
              w.writeCharacters('1');
              w.writeEndElement();
              
              myGen.writeStringField('cognome',req.cognome);
              w.writeStartElement('', 'cognome', '');
              w.writeCharacters(''+req.cognome);
              w.writeEndElement();
              
              myGen.writeStringField('nome',req.nome);
              w.writeStartElement('', 'nome', '');
              w.writeCharacters(''+req.nome);
              w.writeEndElement();
              
              myGen.writeStringField('soggettoEstero','false');
              w.writeStartElement('', 'soggettoEstero', '');
              w.writeCharacters('false');
              w.writeEndElement();
  
              myGen.writeStringField('codiceFiscale',req.cf);
              w.writeStartElement('', 'codiceFiscale', '');
              w.writeCharacters(''+req.cf);
              w.writeEndElement();
  
              
              myGen.writeStringField('codiceAgenzia',req.codAg); 
              w.writeStartElement('', 'codiceAgenzia', '');
              w.writeCharacters(''+req.codAg);
              w.writeEndElement();
              
              myGen.writeStringField('agenziaLight','false');
              w.writeStartElement('', 'agenziaLight', '');
              w.writeCharacters('false');
              w.writeEndElement();
              
              myGen.writeStringField('presenzaAlert','false');
              w.writeStartElement('', 'presenzaAlert', '');
              w.writeCharacters('false');
              w.writeEndElement();
              
          }else {
          
              myGen.writeStringField('sistemaFonte','CRM');
              w.writeStartElement('', 'sistemaFonte', '');
              w.writeCharacters('CRM');
              w.writeEndElement();
              
              myGen.writeStringField('tipoSoggetto','2');
              w.writeStartElement('', 'tipoSoggetto', '');
              w.writeCharacters('2');
              w.writeEndElement();
              
              myGen.writeStringField('denominazione',req.ragsoc);
              w.writeStartElement('', 'denominazione', '');
              w.writeCharacters(''+req.ragsoc);
              w.writeEndElement();
              
              myGen.writeStringField('soggettoEstero','false');
              w.writeStartElement('', 'soggettoEstero', '');
              w.writeCharacters('false');
              w.writeEndElement();
  
              myGen.writeStringField('partitaIva',req.piva);
              w.writeStartElement('', 'partitaIva', '');
              w.writeCharacters(''+req.piva);
              w.writeEndElement();
  
              myGen.writeStringField('codiceAgenzia',req.codAg); 
              w.writeStartElement('', 'codiceAgenzia', '');
              w.writeCharacters(''+req.codAg);
              w.writeEndElement();
              
              myGen.writeStringField('agenziaLight','false');
              w.writeStartElement('', 'agenziaLight', '');
              w.writeCharacters('false');
              w.writeEndElement();
              
              myGen.writeStringField('presenzaAlert','false');
              w.writeStartElement('', 'presenzaAlert', '');
              w.writeCharacters('false');
              w.writeEndElement();
          }
          
          myGen.writeEndObject();
          w.writeEndElement(); //end arg0
          string jsonString = myGen.getAsString();
  
          system.debug ('*****json string '+jsonString );
          theresult.DevField__c = jsonString;
  
          w.writeEndElement(); //end ricercaSoggetto
          w.writeEndElement(); //end body       
          w.writeEndElement(); //end envelope
          
          string compiledrequest = w.getXmlString();
          system.debug ('compiledrequest'+compiledrequest);   
          theresult.RequestBody__c = compiledrequest;
  
          return theResult;
  
      } 
      public static IE_Integration_Record__c PopulateIErecord_FullSearchAccount (String NDG){
          IE_Integration_Record__c theResult = new IE_Integration_Record__c();
          List<IE_Configuration__c> theConfig = [SELECT id,NameSpacePrefix1__c,NameSpacePrefix2__c,NameSpacePrefix3__c,NameSpaceUri1__c,NameSpaceUri2__c,NameSpaceUri3__c FROM IE_Configuration__c WHERE Name='CIF_Integration_AccountFullSearch' LIMIT 1];
          if (!theConfig.isempty()) {
              theresult.IE_Configuration__c = theConfig[0].id;
          }
          //Compiling the DevField with the JSON 
          JSONGenerator myGen= JSON.createGenerator(true);
          
          String NameSpacePrefixToUse1 = theConfig[0].NameSpacePrefix1__c;
          String NameSpacePrefixToUse2 = theConfig[0].NameSpacePrefix2__c;
          String NameSpacePrefixToUse3 = theConfig[0].NameSpacePrefix3__c;
          String NameSpaceUriToUse1 = theConfig[0].NameSpaceUri1__c;
          String NameSpaceUriToUse2 = theConfig[0].NameSpaceUri2__c;
          String NameSpaceUriToUse3 = theConfig[0].NameSpaceUri3__c;
          
          //initialise writer
          XmlStreamWriter w = new XmlStreamWriter();
          
          //ENVELOPE
          w.writeStartElement(NameSpacePrefixToUse1, 'Envelope',NameSpaceUriToUse1+'');
          w.writeNamespace(NameSpacePrefixToUse1, NameSpaceUriToUse1+'');
          w.writeNamespace(NameSpacePrefixToUse2, NameSpaceUriToUse2+'');
          
          //HEADER OPEN-CLOSE
          w.writeEmptyElement(NameSpacePrefixToUse1, 'Header', NameSpacePrefixToUse1); 
          
          //BODY
          w.writeStartElement(NameSpacePrefixToUse1, 'Body', NameSpaceUriToUse1);
          w.writeStartElement(NameSpacePrefixToUse2, 'ricercaSoggettoFull', NameSpaceUriToUse2);
  
  
          myGen.writeStartObject();
          myGen.writeFieldName('arg0');
          w.writeStartElement('', 'arg0', '');
  
          myGen.writeStartObject();
  
          myGen.writeStringField('sistemaFonte','CRM');
          w.writeStartElement('', 'sistemaFonte', '');
          w.writeCharacters('CRM');
          w.writeEndElement();
         
          myGen.writeStringField('soggettoEstero','false');
          w.writeStartElement('', 'soggettoEstero', '');
          w.writeCharacters('false');
          w.writeEndElement();
  
          myGen.writeStringField('Ndg',NDG);
          w.writeStartElement('', 'Ndg', '');
          w.writeCharacters(''+NDG);
          w.writeEndElement();
          
          myGen.writeStringField('agenziaLight','false');
          w.writeStartElement('', 'agenziaLight', '');
          w.writeCharacters('false');
          w.writeEndElement();
          
          myGen.writeStringField('presenzaAlert','false');
          w.writeStartElement('', 'presenzaAlert', '');
          w.writeCharacters('false');
          w.writeEndElement();
  
          
          myGen.writeEndObject();
          w.writeEndElement(); //end arg0
          string jsonString = myGen.getAsString();
  
          system.debug ('*****json string '+jsonString );
          theresult.DevField__c = jsonString;
  
          w.writeEndElement(); //end ricercaSoggetto
          w.writeEndElement(); //end body       
          w.writeEndElement(); //end envelope
          
          string compiledrequest = w.getXmlString();
          system.debug ('compiledrequest'+compiledrequest);   
          theresult.RequestBody__c = compiledrequest;
  
          return theResult;
  
      } 
      
      public static AccountSearchCtrl.ResponseDto manageEditResponse_SearchAccount (IE_Engine IEInstance,AccountSearchCtrl.RequestObj req){
          AccountSearchCtrl.ResponseDto results = new AccountSearchCtrl.ResponseDto();
  
          system.debug('****** IEInstance ='+IEInstance);
          SearchAccountResponse formattedResponse = mapSearchAccountResponse_SearchAccount (IEInstance.JSONResponse);        
          
          if (formattedResponse == null)
          {
              results.isSuccess = False;
              results.message = 'Errore risposta vuota'; 
              return results;
          }
          else if (formattedResponse.codiceEsito.startsWithIgnoreCase('-206'))
          {
              results.isSuccess = False;
              results.message = 'Nessuna occorrenza trovata'; 
              return results;
          }
          //successo chiamata
          else if (formattedResponse.codiceEsito.startsWithIgnoreCase('OK'))
          {
              system.debug ('******SUCCESS');
              
              map< AccountSearchCtrl.ResponseObj, account> Finalresponse = new map< AccountSearchCtrl.ResponseObj, account>();
              
              Finalresponse = searchAccount_setResponse (formattedResponse);
              results.isSuccess = True;
              for(AccountSearchCtrl.ResponseObj r: Finalresponse.keyset()){
                  results.values.put(r,Finalresponse.get(r));
              }
              
              system.debug ('******returnedCIFAccount'+results.values.get('returnedCIFAccount'));
          }
          //errore chiamata
          else{
              system.debug('****** ERROR');
              results.isSuccess = False;
              results.message = 'La chiamata verso CIF ha avuto esito negativo. Riprovare o contattare l\'amministratore di sistema'; 
          }
  
          return results;
      }
      
      public static AccountSearchCtrl.ResponseDto manageEditResponse_FullSearchAccount (IE_Engine IEInstance){
          AccountSearchCtrl.ResponseDto results = new AccountSearchCtrl.ResponseDto();
  
          system.debug('****** IEInstance ='+IEInstance);
          SearchAccountFullResponse formattedResponse = mapSearchAccountResponse_FullSearchAccount (IEInstance.JSONResponse);       
          system.debug('----------formattedResponse='+formattedResponse);
          if (formattedResponse == null)
          {
              results.isSuccess = False;
              results.message = 'Errore risposta vuota'; 
              return results;
          }
          else if(formattedResponse.codiceEsito.startsWithIgnoreCase('-206')){
              results.isSuccess = False;
              results.message = 'Nessuna occorrenza trovata';
              return results;
          }
          //successo chiamata
          else if (formattedResponse.codiceEsito.startsWithIgnoreCase('OK') && formattedResponse.occorrenzeTrovate== '1')
          {
              system.debug ('******SUCCESS');
              
              //map< AccountSearchCtrl.ResponseObj, account> Finalresponse = new map< AccountSearchCtrl.ResponseObj, account>();
              
              AccountSearchCtrl.ResponseDto FullResponse = fullSearchAccount_setResponse (formattedResponse);
              system.debug('WELLA'+FullResponse);
              
              results.isSuccess = True;
              
              results.values=FullResponse.values;
              system.debug('QUIII'+results);
              
              //results.values.put(FullResponse.values.get('returnedCIFAccount',selectedAccount));
              //results.values.put(FullResponse.values.get('RelatedDocsList',Documenti));
  
              //system.debug ('******returnedCIFAccount'+results.values.get('returnedCIFAccount'));
          }
          //errore chiamata
          else{
              system.debug('****** ERROR');
              results.isSuccess = False;
              results.message = 'La chiamata verso CIF ha avuto esito negativo. Riprovare o contattare l\'amministratore di sistema: '+formattedResponse.msgRisposta; 
          }
  
          return results;
      }
      
      
  /*
      public static IE_Integration_Record__c PopulateIErecord_InsertAccount(Account theNewAccount,string CodiceSottotipo,string SalutationString, AccountInsertCtrl.AddressResponseObj address, User CurrentUser, Map<String,String> LeadMPSFields){
          IE_Integration_Record__c theResult = new IE_Integration_Record__c();
          List<IE_Configuration__c> theConfig = [SELECT id,NameSpacePrefix1__c,NameSpacePrefix2__c,NameSpaceUri1__c,NameSpaceUri2__c FROM IE_Configuration__c WHERE Name='CIF_Integration_PartyService_Insert' LIMIT 1];
          
          if (!theConfig.isempty()) {
              theresult.IE_Configuration__c = theConfig[0].id;
          }
          
          String compiledrequest = CIF_Communication_Helper_Insert.createJson( theNewAccount, CodiceSottotipo, SalutationString,  address, CurrentUser, LeadMPSFields);
          System.debug('the new account: ' + theNewAccount);
          system.debug ('compiledrequest'+compiledrequest);
          theResult.DevField__c = compiledrequest;
          theresult.RequestBody__c = compiledrequest;
          //theresult.RequestBody__c = '';
  
          return theResult;
  
      } */
      
      public static IE_Integration_Record__c PopulateIErecord(Account theNewAccount, Map<String, BOOLEAN> editedFields, Map<String,String> userinfo, Map<String, TelephoneWithPrefix> changedTelephoneFields) {
          //Integration used on the Account edit page
          IE_Integration_Record__c theResult = new IE_Integration_Record__c();
          List<IE_Configuration__c> theConfig = [SELECT id,NameSpacePrefix1__c,NameSpacePrefix2__c,NameSpaceUri1__c,NameSpaceUri2__c FROM IE_Configuration__c WHERE Name='CIF_Integration_PartyService_Edit' LIMIT 1];
          if (!theConfig.isempty()) {
              theresult.IE_Configuration__c = theConfig[0].id;
          }
          
          string compiledrequest = CIF_Communication_Helper_Edit.createJson(theNewAccount, editedFields,userinfo, changedTelephoneFields);
          system.debug ('compiledrequest'+compiledrequest);   
          theResult.DevField__c = compiledrequest;
          theresult.RequestBody__c = compiledrequest;
  
          return theResult;
      }

      
     public static accountEditLightningCTRL.ResponseDto manageEditResponse(IE_Engine IEInstance, Account selectedAccount, Map<String,Boolean> editedFieldsMap) {
          accountEditLightningCTRL.ResponseDto results = new accountEditLightningCTRL.ResponseDto();
          //need to modify the JSONREPONSE to add the reisposta structure

 
          accountEditResponse formattedResponse = mapAccountEditResponse (IEInstance.JSONResponse);     
          
        
          if (formattedResponse == null)
          {
              //errore risposta vuota
              results.isSuccess = False;
              results.message = 'Risposta vuota';
              return results;
          }
          //errore dati    formattedResponse.esitoElaborazione.startsWithIgnoreCase('W')
          else if (formattedResponse.code != null)
          {
          //if (formattedResponse.code.startsWithIgnoreCase('1'))
          //{
              system.debug('******DATA ERROR');
              results.isSuccess = False;
              results.message = 'Errore di integrazione con CIF - '+formattedResponse.developerMessage; 
          //}
          }
          else if(formattedResponse.ndg!=null && formattedResponse.ndg!='')//if (formattedResponse.esitoElaborazione.startsWithIgnoreCase('A'))
          {
              system.debug ('******SUCCESS');
              Boolean isOneClick = editedFieldsMap.get('One Click');
              Boolean isUnsub = editedFieldsMap.get('isFromUnsub');
              if(isOneClick != true && isUnsub != true){
                system.debug('#####selectedAccount before accountUpdateFromResponse'+selectedAccount);
                selectedAccount = accountUpdateFromResponse(selectedAccount,formattedResponse);//here is where i change the variable for all methods
                system.debug('#####selectedAccount after accountUpdateFromResponse'+selectedAccount);
             }
             results.values.put('esitoChiamataDAC',formattedResponse.dacOperationResult.operationResult+' - '+formattedResponse.dacOperationResult.operationDetail);
             //results.values.put('dettaglioChiamataDAC',formattedResponse.dacOperationResult.operationDetail);
             system.debug ('******esitoChiamataDAC'+results.values.get('esitoChiamataDAC'));
              
  
  
              results.isSuccess = True;
              results.values.put ('returnedCIFAccount',selectedAccount);
              
              system.debug ('******returnedCIFAccount'+results.values.get('returnedCIFAccount'));
          }
         
         return results;
      }    
      
      /*public static AccountInsertCtrl.ResponseDto manageEditResponse_InsertAccount (IE_Engine IEInstance, Account selectedAccount)
      {
          AccountInsertCtrl.ResponseDto results = new AccountInsertCtrl.ResponseDto();
          accountInsertResponse formattedResponse = mapAccountInsertResponse (IEInstance.JSONResponse);    
          system.debug('formattedResponse:'+formattedResponse);
  
          system.debug('formattedResponsecheck'+formattedResponse.resultCode=='KO');
          system.debug('formattedResponsecheck'+formattedResponse.resultMessage == 'Soggetto gia\' presente in portafoglio');
          
          
          if (formattedResponse == null)
          {
              //errore risposta vuota
              results.isSuccess = False;
              results.message = 'Errore risposta vuota';
              return results;
          }else if (formattedResponse.code != null)
          {
          //if (formattedResponse.code.startsWithIgnoreCase('1'))
          //{
              system.debug('******DATA ERROR');
              results.isSuccess = False;
              results.message = 'Errore di integrazione con CIF - '+formattedResponse.developerMessage; 
          //}
          }else if(formattedResponse.resultCode == 'KO' && 
                   formattedResponse.resultMessage == 'Soggetto gia\' presente in portafoglio'){
              //errore soggetto già esistente
              system.debug('******SOGGETTO GIà INSERITO ERROR');
              results.isSuccess = False;
              results.message = 'Errore di integrazione con CIF - '+formattedResponse.resultMessage; 
          }*/
          /*
          //errore dati
          if (formattedResponse.esitoElaborazione.startsWithIgnoreCase('W'))
          {
              system.debug('******DATA ERROR');
              results.isSuccess = False;
              results.message = 'Errore di integrazione con CIF - '+formattedResponse.messaggioErrore; 
          }
          //errore chiamata
          else if (formattedResponse.esitoElaborazione.startsWithIgnoreCase('E'))
          {
              system.debug('******FATAL ERROR');
              results.isSuccess = False;
              results.message = 'Errore di integrazione con CIF - '+formattedResponse.messaggioErrore; 
          }
          //successo chiamata ma già presente
          else if (formattedResponse.esitoElaborazione.equalsIgnoreCase('A001'))
          {
              system.debug ('******SUCCESS BUT ALREADY PRESENT');
              results.isSuccess = False;
              results.message = 'Errore di integrazione con CIF - '+formattedResponse.messaggioErrore+' - Eseguire nuovamente la ricerca cliente';
          }*/
          //successo chiamata
         /* else if(formattedResponse.ndg!=null && 
                  formattedResponse.ndg!='')//if (formattedResponse.esitoElaborazione.startsWithIgnoreCase('A'))
          {
              system.debug ('******SUCCESS formattedResponse ='+formattedResponse);
              selectedAccount = accountInsertFromResponse(selectedAccount,formattedResponse);
   
              results.isSuccess = True;
              results.values.put ('returnedCIFAccount',selectedAccount);
              
              system.debug ('******returnedCIFAccount'+results.values.get('returnedCIFAccount'));
          }
          else{
              //errore risposta non gestita
              results.isSuccess = False;
              results.message = 'Errore nell\'interpretazione della risposta di integrazione con CIF: codice risposta non gestita';
              return results;
          }
  
          return results;
      } */
  
      public static accountEditResponse mapAccountEditResponse (String JSONResponse) {
          accountEditResponse emptyInstance = new accountEditResponse();
          Type typeInstance = Type.forName('accountEditResponse');
          try {
              List<accountEditResponse> AccountEditResponseList = new List<accountEditResponse>();
              AccountEditResponseList = (List<accountEditResponse>) JSON.deserialize(JSONResponse.replace('"number":', '"number_z":'),List<accountEditResponse>.class);
              accountEditResponse deserializeResults = AccountEditResponseList.get(0);
              return deserializeResults;
          }catch (exception e) {
              accountEditResponse deserializeResults = (accountEditResponse)JSON.deserialize(JSONResponse.replace('"number":', '"number_z":'), typeInstance);
              return deserializeResults;
  
          }
      }
      
      public static SearchAccountResponse mapSearchAccountResponse_SearchAccount (String JSONResponse) {
          SearchAccountResponse emptyInstance = new SearchAccountResponse();
          System.debug('***************pre deserialize() JSONResponse = ' + JSONResponse);
          Type typeInstance = Type.forName('SearchAccountResponse');
          SearchAccountResponse deserializeResults = (SearchAccountResponse)JSON.deserialize(JSONResponse, typeInstance);
          System.debug('***************deserialize() results = ' + deserializeResults);
          return deserializeResults;
      }
      
      public static SearchAccountFullResponse mapSearchAccountResponse_FullSearchAccount (String JSONResponse) {
          SearchAccountFullResponse emptyInstance = new SearchAccountFullResponse();
          System.debug('***************pre deserialize() JSONResponse = ' + JSONResponse);
          Type typeInstance = Type.forName('SearchAccountFullResponse');
          JSONResponse.replace('long','v_long');
          SearchAccountFullResponse deserializeResults = (SearchAccountFullResponse)JSON.deserialize(JSONResponse, typeInstance);
          System.debug('***************deserialize() results = ' + deserializeResults);
          return deserializeResults;
      }
      
      /** PURE IT Commento per rimuovere referenza di una classe commentata
      public static accountInsertResponse mapAccountInsertResponse (String JSONResponse) {
          accountInsertResponse emptyInstance = new accountInsertResponse();
          System.debug('***************pre deserialize() insert JSONResponse = ' + JSONResponse);
          Type typeInstance = Type.forName('accountInsertResponse');
  
          try {
              List<accountInsertResponse> AccountInsertResponseList = new List<accountInsertResponse>();
              AccountInsertResponseList = (List<accountInsertResponse>) JSON.deserialize(JSONResponse.replace('"number":', '"number_z":'),List<accountInsertResponse>.class);
              accountInsertResponse deserializeResults = AccountInsertResponseList.get(0);
              return deserializeResults;
          }catch (exception e) {
              accountInsertResponse deserializeResults = (accountInsertResponse)JSON.deserialize(JSONResponse.replace('"number":', '"number_z":'), typeInstance);
              return deserializeResults;
          }
  
      } 
      PURE IT Comment closure */
      
  
      public static Account accountUpdateFromResponse (Account theAccount, accountEditResponse theResponse )
      {
          map<string,string> MaritalStatusMap = new map<string,string>();
          MaritalStatusMap.put('1','Coniugato/a');
          MaritalStatusMap.put('2','Celibe/Nubile');
          MaritalStatusMap.put('3','Divorziato/a');
          MaritalStatusMap.put('4','Vedovo/a');
          MaritalStatusMap.put('5','Separato/a');
          MaritalStatusMap.put('6','Non noto/a');
          MaritalStatusMap.put('7','Convivente');
  
         if (theResponse.parties[0].party.honoraryTitleCode!= null && theResponse.parties[0].party.honoraryTitleCode!= '')
          {
              theAccount.CIF_Marital_Status__c = MaritalStatusMap.get(theResponse.parties[0].party.honoraryTitleCode);
              
          } 
        
          //phones   theResponse.soggettoEsistente.datiContattiTelefonici
          if(theResponse.parties[0].telephone != null)
              for (accountEditResponse.cls_telephone contact : theResponse.parties[0].telephone) {

                  String prefix = TelephoneWithPrefixService.getValidPrefix(contact.internationalPrefix);
                  System.debug('********Contatto telefonico'+contact);
                  //tel principale
                  if (contact.telephoneType == '1')
                  {
                      theAccount.CIF_Phone__c = prefix + contact.number_z;
                      theAccount.CIF_Id_Contatto_Phone__c = contact.contactId;
                      theAccount.Flag_Opposizione_Tel_Princ__c = contact.opposition;
                      theAccount.Motivo_opposizione_Tel_Princ__c = contact.oppositionReason;
                  }
                  //tel cellulare
                  if (contact.telephoneType == '2')
                  {
                      if (theAccount.isPersonAccount)
                      {
                          theAccount.CIF_PersonMobilePhone__c = prefix + contact.number_z;
                          theAccount.CIF_Id_Contatto_PersonMobilePhone__c = contact.contactId;
                          theAccount.Flag_Opposizione_Tel_Cell_B2C__c = contact.opposition;
                          theAccount.Motivo_opposizione_Tel_Cell_B2C__c = contact.oppositionReason;
                      }
                      else
                      {
                          theAccount.CIF_MobilePhone__c = prefix + contact.number_z;
                          theAccount.CIF_Id_Contatto_MobilePhone__c = contact.contactId;
                          theAccount.Flag_Opposizione_Tel_Cell_B2B__c = contact.opposition;
                          theAccount.Motivo_opposizione_Tel_Cell_B2B__c = contact.oppositionReason;
                      }
                  }
                  //fax
                  if (contact.telephoneType == '4')
                  {
                      theAccount.Fax = prefix + contact.number_z;
                      theAccount.CIF_Id_Contatto_Fax__c = contact.contactId;
                      theAccount.Flag_Opposizione_Fax__c = contact.opposition;
                      theAccount.Motivo_opposizione_Fax__c = contact.oppositionReason;
                  }
                  //tel uff
                  if (contact.telephoneType == '8')
                  {
                      theAccount.CIF_Work_phone__c = prefix + contact.number_z;
                      theAccount.CIF_Id_Contatto_WorkPhone__c = contact.contactId;
                      theAccount.FLag_Opposizione_Tel_Uff__c = contact.opposition;
                      theAccount.Motivo_opposizione_Tel_Uff__c = contact.oppositionReason;
                  }                       
              } 
          //emails theResponse.soggettoEsistente.datiEmail
          if(theResponse.parties[0].telemContact!= null)
              for (accountEditResponse.cls_telemContact contactMail : theResponse.parties[0].telemContact) {
                  System.debug('********Contatto telefonico'+contactMail);
                  //email uff
                  if (contactMail.contactType == '32')
                  {
                      theAccount.CIF_Work_email__c = contactMail.text;
                      theAccount.CIF_Id_Contatto_WorkEmail__c = contactMail.contactId;
                      theAccount.Flag_Opposizione_Email_Uff__c = contactMail.opposition;
                      theAccount.Motivo_opposizione_Email_Uff__c = contactMail.oppositionReason;
                  }
                  //email pers
                  if (contactMail.contactType == '1')
                  {
                      if (theAccount.isPersonAccount)
                      {
                          theAccount.CIF_PersonEmail__c = contactMail.text;
                          theAccount.CIF_Id_Contatto_PersonEmail__c = contactMail.contactId;
                          theAccount.Flag_Opposizione_Email_Pers_B2C__c = contactMail.opposition;
                          theAccount.Motivo_opposizione_Email_Pers_B2C__c = contactMail.oppositionReason;
                      }
                      else
                      {
                          theAccount.CIF_PersonalEmail__c = contactMail.text;
                          theAccount.CIF_Id_Contatto_PersonalEmail__c = contactMail.contactId;
                          theAccount.Flag_Opposizione_Email_Pers_B2B__c = contactMail.opposition;
                          theAccount.Motivo_opposizione_Email_Pers_B2B__c = contactMail.oppositionReason;
                      }
                  }
                              
              }
  
  
              
              //privacy theResponse.soggettoEsistente.datiPrivacyUpdate
              if(theResponse.parties[0].party!= null){
             // for (accountEditResponse.datiPrivacyUpdateClass theprivacyList : theResponse.soggettoEsistente.datiPrivacyUpdate) {
                if(theResponse.parties[0].party.sourceExternal!=null && theResponse.parties[0].party.sourceExternal!=''){
                theAccount.Sistema_fonte__c=theResponse.parties[0].party.sourceExternal;
                }
                if(theResponse.parties[0].party.externalUpdateDateTime!=null && theResponse.parties[0].party.externalUpdateDateTime!=''){
                String daggEst = theResponse.parties[0].party.externalUpdateDateTime;
                daggEst = daggEst.replace('Z','+02:00');
                DateTime dtdaggEst = DateTime.newInstance(Integer.valueof(daggEst.mid(0,4)), Integer.valueof(daggEst.mid(5,2)), Integer.valueof(daggEst.mid(8,2)), Integer.valueof(daggEst.mid(11,2))+2, Integer.valueof(daggEst.mid(14,2)), Integer.valueof(daggEst.mid(17,2)));
                theAccount.Data_ora_modifica__c = dtdaggEst;
                }
                if(theResponse.parties[0].party.operativePrivacy!=null){
                theAccount.CIF_Privacy_1__c=theResponse.parties[0].party.operativePrivacy == true ?'Sì': 'No';
                }
                if(theResponse.parties[0].party.promotionalPrivacy!=null){
                theAccount.CIF_Privacy_2__c=theResponse.parties[0].party.promotionalPrivacy == true ?'Sì': 'No';
                }
                if(theResponse.parties[0].party.marketResearchPrivacy!=null){
                theAccount.CIF_Privacy_3__c=theResponse.parties[0].party.marketResearchPrivacy == true ?'Sì': 'No';
                }
                if(theResponse.parties[0].party.thirdPartiesPrivacy!=null){
                theAccount.CIF_Privacy_4__c=theResponse.parties[0].party.thirdPartiesPrivacy == true  ?'Sì': 'No';
                }
                if(theResponse.parties[0].party.mailDigitalPrivacy!=null){
                theAccount.CIF_Privacy_5__c=theResponse.parties[0].party.mailDigitalPrivacy == true ?'Sì': 'No';
                }
                if(theResponse.parties[0].party.graphometricSignaturePrivacy!=null){
                theAccount.CIF_Privacy_7__c=theResponse.parties[0].party.graphometricSignaturePrivacy == true ?'Sì': 'No';
                }
                if(theResponse.parties[0].party.emailDac!=null && theResponse.parties[0].party.emailDac!=''){
                theAccount.CIF_Mail_contact__c=theResponse.parties[0].party.emailDac;
                }
                if(theResponse.parties[0].party.otpPrivacy!=null){
                theAccount.CIF_Privacy_8__c=theResponse.parties[0].party.otpPrivacy == true ?'Sì': 'No';
                }
                if(theResponse.parties[0].party.telephoneOtp!=null && theResponse.parties[0].party.telephoneOtp!=''){
                theAccount.CIF_OTP_Phone_contact__c=theResponse.parties[0].party.telephoneOtp;
                }
  
              //}
              }
  
              //DAC documents
          if(theResponse.parties[0].documents!=null) {
              List<AccountEditResponse.cls_documents> thedocList = (List<AccountEditResponse.cls_documents>) theResponse.parties[0].documents;
              //Must write on account the label of the doc type, not the number
              Map<String,String> MapNubertoLabel = new Map<String,String>();
  
              for (DICodeAssignment__c thisCode : DICodeAssignment__c.getall().values() ){
                  MapNubertoLabel.put(thisCode.CIF_DI_code__c, thisCode.Name);
              } 
              
              for (AccountEditResponse.cls_documents thisDoc : thedocList) {
                  if (Boolean.Valueof(thisDoc.dacDocument)) {
                      theAccount.CIF_Document_type__c=MapNubertoLabel.get(thisDoc.documentType);
                      theAccount.CIF_Number__c=thisDoc.documentNumber;
                      theAccount.CIF_Expiry_date__c=Date.ValueOf(thisDoc.expirationDate);
                  }
              } 
          }
  
  
          return theAccount;  
              
      }
  
  
  
      /*public static Account accountInsertFromResponse (Account theAccount, accountInsertResponse theResponse )
      {
          
          String recordTypename = [select name from RecordType where id = :theAccount.recordtypeid and SobjectType = 'Account'].name; //CAPOBIANCO_A 08/05/2017
  
          map<string,string> MaritalStatusMap = new map<string,string>();
          MaritalStatusMap.put('1','Coniugato/a');
          MaritalStatusMap.put('2','Celibe/Nubile');
          MaritalStatusMap.put('3','Divorziato/a');
          MaritalStatusMap.put('4','Vedovo/a');
          MaritalStatusMap.put('5','Separato/a');
          MaritalStatusMap.put('6','Non noto/a');
          MaritalStatusMap.put('7','Convivente');
  
  
          //Tracciamento Modifiche su Cliente

          if(theResponse.parties[0].party.sourceExternal!=null && theResponse.parties[0].party.sourceExternal!=''){
              theAccount.Sistema_fonte__c=theResponse.parties[0].party.sourceExternal;
          }
     
          if(theResponse.parties[0].party.externalUpdateDateTime!=null && theResponse.parties[0].party.externalUpdateDateTime!=''){
              String daggEst = theResponse.parties[0].party.externalUpdateDateTime;
              daggEst = daggEst.replace('Z','+02:00');
              DateTime dtdaggEst = DateTime.newInstance(Integer.valueof(daggEst.mid(0,4)), Integer.valueof(daggEst.mid(5,2)), Integer.valueof(daggEst.mid(8,2)), Integer.valueof(daggEst.mid(11,2))+2, Integer.valueof(daggEst.mid(14,2)), Integer.valueof(daggEst.mid(17,2)));
              theAccount.Data_ora_modifica__c = dtdaggEst;
          }
  
          
          String nodi = '';
          if(theResponse.parties[0].party.agencyCode!= null){
              theAccount.AAI_Agency_Reference_Code__c = theResponse.parties[0].party.agencyCode;
              nodi = theResponse.parties[0].party.agencyCode+';';
          }
  
          if(theResponse.parties[0].visibility!=null && theResponse.parties[0].visibility.size()>0){
              for (accountInsertResponse.cls_visibility vis : theResponse.parties[0].visibility){
                  if(vis.subNodeCode.length()>6){
                     nodi=nodi+vis.subNodeCode+';';
                  }
                  
              }
  
              nodi = nodi.removeEnd(';');
              system.debug ('§§§§§§§§§§§§§ nodi:'+nodi);
              
          }
          theAccount.Nodes__c = nodi;

          
         
          if(theResponse.parties[0].party.subjectType=='1' || theResponse.parties[0].party.subjectType=='FISICO'){
              //PERSONA FISICA
              //if(theResponse.parties[0].fiscalParty!= null)
              //{
                  if (theResponse.parties[0].party.nif!= null){
                      theAccount.AAI_Codice_fiscale__c=theResponse.parties[0].party.nif;
                  }
                  if (theResponse.parties[0].party.surname!= null){
                      theAccount.lastname=theResponse.parties[0].party.surname;
                  }
                  if (theResponse.parties[0].party.name!= null){
                      theAccount.firstname=theResponse.parties[0].party.name;
                  }
                  if (theResponse.parties[0].party.gender!= null){
                      theAccount.Gender__c=theResponse.parties[0].party.gender== '1' ? 'Male' : 'Female';
                  }
                  if (theResponse.parties[0].party.birthDate!= null){
                      string anno = theResponse.parties[0].party.birthDate.substring(0, 4);
                      string mese =theResponse.parties[0].party.birthDate.substring(5, 7);
                      String giorno = theResponse.parties[0].party.birthDate.substring(8, 10);
                      Date suppDate = date.newInstance(Integer.valueof(anno),Integer.valueof(mese),Integer.valueof(giorno) );
                      theAccount.PersonBirthdate=suppDate;
                  }
                  if (theResponse.parties[0].party.birthProvince!= null){
                      theAccount.Provincia_di_nascita__c = theResponse.parties[0].party.birthProvince;
                  }
                  if (theResponse.parties[0].party.birthPlace!= null){
                      theAccount.Place_of_birth__c = theResponse.parties[0].party.birthPlace;
                  }
                  if (theResponse.parties[0].party.honoraryTitleCode!= null){
                      if(theResponse.parties[0].party.honoraryTitleCode=='99'){
                          theAccount.Salutation='';
                      }
                      else{
                          String queryMc = 'select Codice_CIF__c, Descrizione_CIF__c from SalutationMapping__c where Codice_CIF__c =\''+theResponse.parties[0].party.honoraryTitleCode+'\'';
                          SalutationMapping__c mc = Database.query(queryMc);
                          String titOnorifico = mc.Descrizione_CIF__c;
                          
                          theAccount.Salutation=titOnorifico;
                      }
                  }
              //}
          }
          else if (theResponse.parties[0].party.subjectType=='2'){
              //PERSONA GIURIDICA
              if (theResponse.parties[0].party.vatNumber!= null){
                  theAccount.AAI_Partita_IVA__c=theResponse.parties[0].party.vatNumber;
              }
              if (theResponse.parties[0].party.companyName!= null){
                  theAccount.name=theResponse.parties[0].party.companyName;
              }
          }
          //CAPOBIANCO_A 27/04/2017 SPRINT 41 -- START 
          //Documents 
          if(theResponse.parties[0].documents!=null) {
              List<AccountInsertResponse.cls_documents> thedocList = (List<AccountInsertResponse.cls_documents>) theResponse.parties[0].documents;
              //Must write on account the label of the doc type, not the number
              Map<String,String> MapNubertoLabel = new Map<String,String>();
  
              for (DICodeAssignment__c thisCode : DICodeAssignment__c.getall().values() ){
                  MapNubertoLabel.put(thisCode.CIF_DI_code__c, thisCode.Name);
              } 
              
              for (AccountInsertResponse.cls_documents thisDoc : thedocList) {
                  if (thisDoc.dacDocument) {
                      theAccount.CIF_Document_type__c=MapNubertoLabel.get(thisDoc.documentType);
                      theAccount.CIF_Number__c=thisDoc.documentNumber;
                      theAccount.CIF_Expiry_date__c=Date.ValueOf(thisDoc.expirationDate);
                  }
              } 
          }
          //CAPOBIANCO_A 27/04/2017 SPRINT 41 -- END
  
          if(theResponse.parties[0].address != null){
              String queryMc = 'select CountryISOcode__c, CountrySFDC__c from MappingCountry__c where CountryISOcode__c =\''+theResponse.parties[0].address[0].country+'\'';
              MappingCountry__c mc = Database.query(queryMc);
              String nazione = mc.CountrySFDC__c;
              String nazioneCode = mc.CountryISOcode__c;
              queryMc = 'select    SFDCexpected__c, ProvinciaExternalKey__c from MappingProvince__c where ProvinciaExternalKey__c =\''+theResponse.parties[0].address[0].province+'\'';
              MappingProvince__c mc2 = Database.query(queryMc);
              String provincia = mc2.SFDCexpected__c;
              system.debug ('*******theResponse.parties[0].party.subjectType '+theResponse.parties[0].party.subjectType);
  
              String addressToInsert = ''+theResponse.parties[0].address[0].toponym+' '+theResponse.parties[0].address[0].extendedAddress+' '+theResponse.parties[0].address[0].streetNumber;
              if(theResponse.parties[0].party.subjectType=='1' || theResponse.parties[0].party.subjectType=='FISICO'){
                  //PERSONA FISICA
                 // theAccount.PersonMailingCountryCode = nazioneCode;
                  theAccount.PersonMailingCountry= nazione;   
                  theAccount.PersonMailingCity=theResponse.parties[0].address[0].place;
                  theAccount.PersonMailingState=provincia;
                  if (theResponse.parties[0].address[0].streetNumber != null && theResponse.parties[0].address[0].streetNumber!='')
                  {
  
                      theAccount.PersonMailingstreet=addressToInsert;
                  }
                  else
                  {
                      theAccount.PersonMailingstreet=theResponse.parties[0].address[0].extendedAddress;
                  }
                  theAccount.PersonMailingpostalcode=theResponse.parties[0].address[0].cap;  
              }
              else if (theResponse.parties[0].party.subjectType =='2' || theResponse.parties[0].party.subjectType=='GIURIDICO'){
                  //PERSONA GIURIDICA
                //  theAccount.BillingCountryCode = nazioneCode;
                  theAccount.BillingCountry= nazione; 
                  theAccount.BillingCity=theResponse.parties[0].address[0].place;
                  theAccount.BillingState=provincia;
                  if (theResponse.parties[0].address[0].streetNumber != null && theResponse.parties[0].address[0].streetNumber!='')
                  {
                      theAccount.Billingstreet=addressToInsert;
                  }
                  else
                  {
                      theAccount.Billingstreet=theResponse.parties[0].address[0].extendedAddress;                   
                  }
  
                  theAccount.BillingPostalCode=theResponse.parties[0].address[0].cap;  
  
              }
          }
          //if(theResponse.soggettoEsistente.datiPrivacy!=null){
              //@CAPOBIANCO_A 02/05/2017 SPRINT 41 -- START
              theAccount.CIF_Privacy_1__c=theResponse.parties[0].party.operativePrivacy ==true ?'Sì' : 'No';
              theAccount.CIF_Privacy_2__c=theResponse.parties[0].party.promotionalPrivacy==true ?'Sì' : 'No';
              theAccount.CIF_Privacy_3__c=theResponse.parties[0].party.marketResearchPrivacy==true ?'Sì' : 'No';
              theAccount.CIF_Privacy_4__c=theResponse.parties[0].party.thirdPartiesPrivacy==true ?'Sì' : 'No';
              theAccount.CIF_Privacy_5__c=theResponse.parties[0].party.mailDigitalPrivacy==true ?'Sì' : 'No';
              theAccount.CIF_Privacy_7__c=theResponse.parties[0].party.graphometricSignaturePrivacy==true ?'Sì' : 'No';
              if(theResponse.parties[0].party.otpPrivacy!=null){
              theAccount.CIF_Privacy_8__c=theResponse.parties[0].party.otpPrivacy==true ?'Sì' : 'No';
              }
              //@CAPOBIANCO_A 02/05/2017 SPRINT 41 -- END
  
              if(theResponse.parties[0].party.emailDac!=null && theResponse.parties[0].party.emailDac !=''){
                  theAccount.CIF_Mail_contact__c=theResponse.parties[0].party.emailDac;
              }
              if(theResponse.parties[0].party.telephoneOtp!=null && theResponse.parties[0].party.telephoneOtp !=''){
                  theAccount.CIF_OTP_Phone_contact__c=theResponse.parties[0].party.telephoneOtp;
              }
          //}
          if(theResponse.ndg!= null){
              theAccount.NDG__c = theResponse.ndg;
          }
  
          if (theResponse.parties[0].party.maritalStatus!= null && theResponse.parties[0].party.maritalStatus!= '')
          {
              theAccount.CIF_Marital_status_code__c = theResponse.parties[0].party.maritalStatus;
              theAccount.CIF_Marital_Status__c = MaritalStatusMap.get(theResponse.parties[0].party.maritalStatus);
              
          } 
          //phones
          if(theResponse.parties[0].telephone!= null && theResponse.parties[0].telephone.size()!=0)
              for (accountInsertResponse.cls_telephone contact : theResponse.parties[0].telephone) {
                  System.debug('********Contatto telefonico'+contact);

                  String prefix = TelephoneWithPrefixService.getValidPrefix(contact.internationalPrefix);
                  
                  if (contact.telephoneType == '1')
                  {
                      theAccount.CIF_Phone__c = prefix + contact.number_z;
                      theAccount.CIF_Id_Contatto_Phone__c = contact.contactId;
                      theAccount.Flag_Opposizione_Tel_Princ__c = contact.opposition == true ? true : false;
                      theAccount.Motivo_opposizione_Tel_Princ__c = contact.oppositionReason;
  
                  }
                  if (contact.telephoneType == '2')
                  {
                      if(recordTypename.contains('B2C'))
                      {
                          theAccount.CIF_PersonMobilePhone__c = prefix +contact.number_z;
                          theAccount.CIF_Id_Contatto_PersonMobilePhone__c = contact.contactId;
                          theAccount.Flag_Opposizione_Tel_Cell_B2C__c = contact.opposition == true ? true : false;
                          theAccount.Motivo_opposizione_Tel_Cell_B2C__c = contact.oppositionReason;
  
                      }
                      else
                      {
                          theAccount.CIF_MobilePhone__c = prefix + contact.number_z;
                          theAccount.CIF_Id_Contatto_MobilePhone__c = contact.contactId;
                          theAccount.Flag_Opposizione_Tel_Cell_B2B__c = contact.opposition == true ? true : false;
                          theAccount.Motivo_opposizione_Tel_Cell_B2B__c = contact.oppositionReason;
  
                      }
                  }
                  if (contact.telephoneType == '4')
                  {
                      theAccount.Fax = prefix + contact.number_z;
                      theAccount.CIF_Id_Contatto_Fax__c = contact.contactId;
                      theAccount.Flag_Opposizione_Fax__c = contact.opposition == true ? true : false;
                      theAccount.Motivo_opposizione_Fax__c = contact.oppositionReason;
                  }
                  if (contact.telephoneType == '8')
                  {
                      theAccount.CIF_Work_phone__c = prefix + contact.number_z;
                      theAccount.CIF_Id_Contatto_WorkPhone__c = contact.contactId;
                      theAccount.Flag_Opposizione_Tel_Uff__c = contact.opposition == true ? true : false;
                      theAccount.Motivo_opposizione_Tel_Uff__c = contact.oppositionReason;
  
  
                  }                       
              } 
          //emails
          if(theResponse.parties[0].telemContact!= null)
          {
              for (accountInsertResponse.cls_telemContact contactMail : theResponse.parties[0].telemContact) {
                  //if(contactMail.mailDac == 'true'){
                  //    theAccount.CIF_Mail_contact__c = contactMail.contattoMail;
                  //}
                  if (contactMail.contactType == '32')
                  {
                      theAccount.CIF_Work_email__c = contactMail.text;
                      theAccount.CIF_Id_Contatto_WorkEmail__c = contactMail.contactId;
                      theAccount.Flag_Opposizione_Email_Uff__c = contactMail.opposition == true ? true : false;
                      theAccount.Motivo_opposizione_Email_Uff__c = contactMail.oppositionReason;
  
  
                  }
                  if (contactMail.contactType == '1')
                  {
                      if(recordTypename.contains('B2C'))
                      {
                          theAccount.CIF_PersonEmail__c = contactMail.text;
                          theAccount.CIF_Id_Contatto_PersonEmail__c = contactMail.contactId;
                          theAccount.Flag_Opposizione_Email_Pers_B2C__c = contactMail.opposition == true ? true : false;
                          theAccount.Motivo_opposizione_Email_Pers_B2C__c = contactMail.oppositionReason;
  
                      }
                      else
                      {
                          theAccount.CIF_PersonalEmail__c = contactMail.text;
                          theAccount.CIF_Id_Contatto_PersonalEmail__c = contactMail.contactId;
                          theAccount.Flag_Opposizione_Email_Pers_B2B__c = contactMail.opposition == true ? true : false;
                          theAccount.Motivo_opposizione_Email_Pers_B2B__c = contactMail.oppositionReason;
  
                      }
                  }
    
              }
          }       
          return theAccount;  
      }*/
  
      
      
      public static map< AccountSearchCtrl.ResponseObj, account> searchAccount_setResponse (SearchAccountResponse theResponse)
      {
          map< AccountSearchCtrl.ResponseObj, account> res = new map< AccountSearchCtrl.ResponseObj, account>();
          
          Integer occorrenze = Integer.valueof (theResponse.occorrenzeTrovate);
          for(integer i = 0; i < occorrenze; i++){
              AccountSearchCtrl.ResponseObj resItem = new AccountSearchCtrl.ResponseObj();
              Account accItem = new Account();
              
              //NDG
              resItem.ndg = '' + theResponse.asoggetto.get(i).Ndg;
              accItem.NDG__c = '' + theResponse.asoggetto.get(i).Ndg;
              
              //CODICE AGENZIA
              if(theResponse.asoggetto.get(i).codiceAgenzia!=null){
                  accItem.AAI_Agency_Reference_Code__c = theResponse.asoggetto.get(i).codiceAgenzia;
                  accItem.Nodes__c = theResponse.asoggetto.get(i).codiceAgenzia;
              }
              if(theResponse.asoggetto.get(i).codiceSubAgenzia!=null){
                  accItem.Nodes__c = accItem.Nodes__c+';'+theResponse.asoggetto.get(i).codiceSubAgenzia;
              system.debug('cccccccccc '+accItem.Nodes__c);}
              //PRIVACY
              /*if(theResponse.asoggetto.get(i).privacy1!=null)
                  accItem.Industrial_privacy__c = theResponse.asoggetto.get(i).privacy1=='false'? false : true;
              if(theResponse.asoggetto.get(i).privacy2!=null)
                  accItem.Promotional_privacy__c = theResponse.asoggetto.get(i).privacy2=='false'? false : true;
              if(theResponse.asoggetto.get(i).privacy3!=null)
                  accItem.Market_research_privacy__c = theResponse.asoggetto.get(i).privacy3=='false'? false : true;
              if(theResponse.asoggetto.get(i).privacy4!=null)
                  accItem.Third_party_transfer_privacy__c = theResponse.asoggetto.get(i).privacy4=='false'? false : true;*/
              
              
              
              if (theResponse.asoggetto.get(i).tipoSoggetto == '1') {
                  //Account Persona fisica
                  accItem.RecordType = [select Id,name from RecordType where Name = 'B2C Client' and SobjectType = 'Account'];
                  system.debug('--------- accItem.RecordType = '+ accItem.RecordType.name );
                  
                  //NOME
                  resItem.name = '' + theResponse.asoggetto.get(i).nome + ' ' + theResponse.asoggetto.get(i).cognome;
                  resItem.PersonNome = '' + theResponse.asoggetto.get(i).nome;
                  resItem.PersonCognome = '' +theResponse.asoggetto.get(i).cognome;
                  accItem.firstname = '' + theResponse.asoggetto.get(i).nome;
                  accItem.lastname = '' +theResponse.asoggetto.get(i).cognome;
                  
                  //CODICE FISCALE
                  accItem.AAI_Codice_fiscale__c = '' + theResponse.asoggetto.get(i).codiceFiscale;
                  resItem.cfPiva = '' + theResponse.asoggetto.get(i).codiceFiscale;
                  
                  //NASCITA
                  accItem.Place_of_birth__c = '' +theResponse.asoggetto.get(i).localitaNascita;
                  accItem.PersonBirthdate = Date.valueof(theResponse.asoggetto.get(i).dataNascita);
                  
                  //GENDER
                  if(theResponse.asoggetto.get(i).sesso == '1')
                      accItem.Gender__c = 'Male';
                  else if (theResponse.asoggetto.get(i).sesso == '2')
                      accItem.Gender__c = 'Female';
                  
                  //INDIRIZZO PersonMailingAddress
                  if(theResponse.asoggetto.get(i).paese!=null){
                      String queryMc = 'select CountryISOcode__c, CountrySFDC__c from MappingCountry__c where CountryISOcode__c =\''+theResponse.asoggetto.get(i).paese+'\'';
                      MappingCountry__c mc = Database.query(queryMc);
                      accItem.PersonMailingCountry = mc.CountrySFDC__c;
                  }
                  if(theResponse.asoggetto.get(i).localita!=null)
                      accItem.PersonMailingCity = theResponse.asoggetto.get(i).localita;
                  if(theResponse.asoggetto.get(i).provincia!=null){
                      String queryMc = 'select    SFDCexpected__c, ProvinciaExternalKey__c from MappingProvince__c where ProvinciaExternalKey__c =\''+theResponse.asoggetto.get(i).provincia+'\'';
                      MappingProvince__c mc = Database.query(queryMc);
                      accItem.PersonMailingState = mc.SFDCexpected__c;
                  }
                  if(theResponse.asoggetto.get(i).indirizzo!=null)
                      accItem.PersonMailingstreet = theResponse.asoggetto.get(i).indirizzo;
                  if(theResponse.asoggetto.get(i).cap!=null)
                      accItem.PersonMailingpostalcode = theResponse.asoggetto.get(i).cap;
                  

              }
              else if (theResponse.asoggetto.get(i).tipoSoggetto == '2') {
                  //Account Persona giuridica
                  accItem.RecordType = [select Id from RecordType where Name = 'B2B Client' and SobjectType = 'Account'];
                  
                  //RAGIONE SOCIALE
                  resItem.name = '' + theResponse.asoggetto.get(i).denominazione; 
                  accItem.name = '' + theResponse.asoggetto.get(i).denominazione; 
                  
                  //PARTITA IVA
                  accItem.AAI_Partita_IVA__c = '' + theResponse.asoggetto.get(i).partitaIva;
                  resItem.cfPiva = '' + theResponse.asoggetto.get(i).partitaIva;
                  
                  //INDIRIZZO BillingAddress
                  if(theResponse.asoggetto.get(i).paese!=null){
                      String queryMc = 'select CountryISOcode__c, CountrySFDC__c from MappingCountry__c where CountryISOcode__c =\''+theResponse.asoggetto.get(i).paese+'\'';
                      MappingCountry__c mc = Database.query(queryMc);
                      accItem.BillingCountry = mc.CountrySFDC__c;
                  }
                  if(theResponse.asoggetto.get(i).localita!=null)
                      accItem.BillingCity = theResponse.asoggetto.get(i).localita;
                  if(theResponse.asoggetto.get(i).provincia!=null){
                      String queryMc = 'select    SFDCexpected__c, ProvinciaExternalKey__c from MappingProvince__c where ProvinciaExternalKey__c =\''+theResponse.asoggetto.get(i).provincia+'\'';
                      MappingProvince__c mc = Database.query(queryMc);
                      accItem.BillingState = mc.SFDCexpected__c;
                  }
                  if(theResponse.asoggetto.get(i).indirizzo!=null)
                      accItem.Billingstreet = theResponse.asoggetto.get(i).indirizzo;
                  if(theResponse.asoggetto.get(i).cap!=null)
                      accItem.Billingpostalcode = theResponse.asoggetto.get(i).cap;
                  
                  
              }
              
              res.put(resItem,accItem);
          }
          
          return res;  
  
      } 
      
      public static AccountSearchCtrl.ResponseDto fullSearchAccount_setResponse (SearchAccountFullResponse theResponse)
      {   
          map<string,string> MaritalStatusMap = new map<string,string>();
          MaritalStatusMap.put('1','Coniugato/a');
          MaritalStatusMap.put('2','Celibe/Nubile');
          MaritalStatusMap.put('3','Divorziato/a');
          MaritalStatusMap.put('4','Vedovo/a');
          MaritalStatusMap.put('5','Separato/a');
          MaritalStatusMap.put('6','Non noto/a');
          MaritalStatusMap.put('7','Convivente');
          
          Account theAccount = new Account ();

          AccountSearchCtrl.ResponseDto FullResponse = new AccountSearchCtrl.ResponseDto();
          
              List<DICodeAssignment__c> listDocCodes = DICodeAssignment__c.getall().values();
              system.debug('LISTA TIPO DOCUMENTI'+listDocCodes );
              //List<DICodeAssignment__c> listDocCodes= [Select name, CIF_DI_code__c FROM DICodeAssignment__c];
              map<string,string> mapDICode = new map<string,string>();
              for (DICodeAssignment__c dic: listDocCodes){
              mapDICode.put(dic.CIF_DI_code__c,dic.name);             
              }
              
              
              List<AutRilascio_Code_Assignment__c> listAutRilascioCodes = [Select name, AutRilascio_Code__c FROM AutRilascio_Code_Assignment__c];
              map<string,string> mapAutRilascioCode = new map<string,string>();
              for (AutRilascio_Code_Assignment__c aut :listAutRilascioCodes){
              mapAutRilascioCode.put(aut.AutRilascio_Code__c,aut.name);             
              }
              
          if(theResponse.aSoggetto.get(0).soggetto.tipoSoggetto=='1'){
              //PERSONA FISICA
              if (theResponse.aSoggetto.get(0).soggetto.cognome!= null){
                  theAccount.lastname=theResponse.aSoggetto.get(0).soggetto.cognome;
              }
              if (theResponse.aSoggetto.get(0).soggetto.nome!= null){
                  theAccount.firstname=theResponse.aSoggetto.get(0).soggetto.nome;
              }
              if (theResponse.aSoggetto.get(0).soggetto.codiceFiscale!= null){
                  theAccount.AAI_Codice_fiscale__c=theResponse.aSoggetto.get(0).soggetto.codiceFiscale;
              }
              if (theResponse.aSoggetto.get(0).soggetto.localitaNascita!= null){
                  theAccount.Place_of_birth__c=theResponse.aSoggetto.get(0).soggetto.localitaNascita;
              }
              if (theResponse.aSoggetto.get(0).soggetto.sesso!= null){
                  theAccount.Gender__c=theResponse.aSoggetto.get(0).soggetto.sesso == '1' ? 'Male' : 'Female';
              }
              if (theResponse.aSoggetto.get(0).soggetto.dataNascita!= null){
                  string anno = theResponse.aSoggetto.get(0).soggetto.dataNascita.substring(0, 4);
                  string mese =theResponse.aSoggetto.get(0).soggetto.dataNascita.substring(5, 7);
                  String giorno = theResponse.aSoggetto.get(0).soggetto.dataNascita.substring(8, 10);
                  Date suppDate = date.newInstance(Integer.valueof(anno),Integer.valueof(mese),Integer.valueof(giorno) );
                  theAccount.PersonBirthdate=suppDate;
              }

            if (theResponse.aSoggetto.get(0).soggetto.codiceStatoCivile!= null && theResponse.aSoggetto.get(0).soggetto.codiceStatoCivile!= ''){
                  theAccount.CIF_Marital_Status__c = MaritalStatusMap.get(theResponse.aSoggetto.get(0).soggetto.codiceStatoCivile);
              } 
              
          }
          else if (theResponse.aSoggetto.get(0).soggetto.tipoSoggetto=='2'){
              //PERSONA GIURIDICA
              if (theResponse.aSoggetto.get(0).soggetto.denominazione!= null){
                  theAccount.name=theResponse.aSoggetto.get(0).soggetto.denominazione;
              }
              if (theResponse.aSoggetto.get(0).soggetto.partitaIva!= null){
                  theAccount.AAI_Partita_IVA__c=theResponse.aSoggetto.get(0).soggetto.partitaIva;
              } 
              
          }
          
          // Modifica FMarchese 30/03 interventi Papaerless   
          
         if(theResponse.aSoggetto.get(0).soggetto.Ndg!= null){
              theAccount.NDG__c = theResponse.aSoggetto.get(0).soggetto.Ndg;
          }
          if(theResponse.aSoggetto.get(0).soggetto.codiceAgenzia!=null){
              theAccount.AAI_Agency_Reference_Code__c = theResponse.aSoggetto.get(0).soggetto.codiceAgenzia;
          }
          if(theResponse.aSoggetto.get(0).soggetto.privacy1!=null && theResponse.aSoggetto.get(0).soggetto.privacy1!=''){
              theAccount.CIF_Privacy_1__c=theResponse.aSoggetto.get(0).soggetto.privacy1 =='true' ?'Sì': 'No';
          }
          if(theResponse.aSoggetto.get(0).soggetto.privacy2!=null && theResponse.aSoggetto.get(0).soggetto.privacy2!=''){
              theAccount.CIF_Privacy_2__c=theResponse.aSoggetto.get(0).soggetto.privacy2 =='true' ?'Sì': 'No';
          }
          if(theResponse.aSoggetto.get(0).soggetto.privacy3!=null && theResponse.aSoggetto.get(0).soggetto.privacy3!=''){
              theAccount.CIF_Privacy_3__c=theResponse.aSoggetto.get(0).soggetto.privacy3 =='true' ?'Sì': 'No';
          }
          if(theResponse.aSoggetto.get(0).soggetto.privacy4!=null && theResponse.aSoggetto.get(0).soggetto.privacy4!=''){
              theAccount.CIF_Privacy_4__c=theResponse.aSoggetto.get(0).soggetto.privacy4 =='true' ?'Sì': 'No';
          }
         // if(theResponse.aSoggetto.get(0).soggetto.privacy5!=null){ //TODO check che il mapping sia corretto
         //     theAccount.CIF_Privacy_5__c=theResponse.aSoggetto.get(0).soggetto.privacy5 =='Sì' ?'Sì': 'No';
         //}  
          if(theResponse.aSoggetto.get(0).soggetto.privacyEmail!=null && theResponse.aSoggetto.get(0).soggetto.privacyEmail!=''){ //TODO check che il mapping sia corretto
              theAccount.CIF_Privacy_5__c=theResponse.aSoggetto.get(0).soggetto.privacyEmail =='true' ?'Sì': 'No';
          }
          if(theResponse.aSoggetto.get(0).soggetto.testoEmail!=null){ //TODO check che il mapping sia corretto
              theAccount.CIF_Mail_contact__c=theResponse.aSoggetto.get(0).soggetto.testoEmail; // =='Sì' ?'Sì': 'No';
          }
          if(theResponse.aSoggetto.get(0).soggetto.privacyFirma!=null && theResponse.aSoggetto.get(0).soggetto.privacyFirma!=''){ //TODO check che il mapping sia corretto
              theAccount.CIF_Privacy_7__c=theResponse.aSoggetto.get(0).soggetto.privacyFirma =='true' ?'Sì': 'No';
          }
          if(theResponse.aSoggetto.get(0).soggetto.privacyOTP!=null && theResponse.aSoggetto.get(0).soggetto.privacyOTP!=''){ //TODO check che il mapping sia corretto
              theAccount.CIF_Privacy_8__c=theResponse.aSoggetto.get(0).soggetto.privacyOTP =='true' ?'Sì': 'No';
          }
          if(theResponse.aSoggetto.get(0).soggetto.telefonoOTP!=null){ //TODO check che il mapping sia corretto
              theAccount.CIF_OTP_Phone_contact__c=theResponse.aSoggetto.get(0).soggetto.telefonoOTP; // =='Sì' ?'Sì': 'No';
          }

          if(theResponse.aSoggetto.get(0).soggetto.sorgenteEst!=null){
              theAccount.Sistema_fonte__c = theResponse.aSoggetto.get(0).soggetto.sorgenteEst;
          }
  
  
          if(theResponse.aSoggetto.get(0).soggetto.daggEst!=null){
              String daggEst = theResponse.aSoggetto.get(0).soggetto.daggEst;
              DateTime dtdaggEst = DateTime.newInstance(Integer.valueof(daggEst.mid(0,4)), Integer.valueof(daggEst.mid(5,2)), Integer.valueof(daggEst.mid(8,2)), Integer.valueof(daggEst.mid(11,2)), Integer.valueof(daggEst.mid(14,2)), Integer.valueof(daggEst.mid(17,2)));
              theAccount.Data_ora_modifica__c = dtdaggEst;
          }
  
          //read the list of nodes, put the agency code as first
          boolean addAgencyNode=true;
          if(theResponse.aSoggetto.get(0).lstVisibilita!=null && theResponse.aSoggetto.get(0).lstVisibilita.size()>0){
              String nodi = '';
              for (SearchAccountFullResponse.cls_lstVisibilita vis : theResponse.aSoggetto.get(0).lstVisibilita){
                  if(vis.subagenzia == theResponse.aSoggetto.get(0).soggetto.codiceAgenzia){
                      addAgencyNode=false;
                  }
                  nodi=nodi+vis.subagenzia+';';
              }
  
              nodi = nodi.removeEnd(';');
              system.debug ('§§§§§§§§§§§§§ nodi:'+nodi);
              if(addAgencyNode==true){
                  theAccount.Nodes__c=theResponse.aSoggetto.get(0).soggetto.codiceAgenzia+';';
                  system.debug ('§§§§§§§§§§§§§ theAccount.Nodes__c'+theAccount.Nodes__c);
              }
              theAccount.Nodes__c += nodi;
          }else{
          //if no visibility nodes are found, add just the agency code
          theAccount.Nodes__c=theResponse.aSoggetto.get(0).soggetto.codiceAgenzia+'';
          }
          
          //<timestampCif>2016-12-09T11:04:59.674+01:00</timestampCif>
          if(theResponse.aSoggetto.get(0).lstTelefoni!=null && theResponse.aSoggetto.get(0).lstTelefoni.size()>0){
              map<DateTime,String> telPrincipaleMap = new map<DateTime,String> ();
              map<DateTime,String> telMobileMap = new map<DateTime,String>();
              map<DateTime,String> telFaxMap= new map<DateTime,String>();
              map<DateTime,String> telUfficioMap = new map<DateTime,String>();
      
              map<String,String> telPrincipaleIdContattoList = new map<String,String>(); 
              map<String,String> telMobileIdContattoList = new map<String,String>();
              map<String,String> telFaxIdContattoList = new map<String,String>();
              map<String,String> telUfficioIdContattoList = new map<String,String>();
  
              map<String,String> telPrincipaleOppositionList = new map<String,String>(); 
              map<String,String> telMobileOppositionList = new map<String,String>();
              map<String,String> telFaxOppositionList = new map<String,String>();
              map<String,String> telUfficioOppositionList = new map<String,String>();
  
              map<String,String> telPrincipaleOppositionReasonList = new map<String,String>(); 
              map<String,String> telMobileOppositionReasonList = new map<String,String>();
              map<String,String> telFaxOppositionReasonList = new map<String,String>();
              map<String,String> telUfficioOppositionReasonList = new map<String,String>();
              
              for (SearchAccountFullResponse.cls_lstTelefoni contact : theResponse.aSoggetto.get(0).lstTelefoni) {
              
                  System.debug('********Contatto telefonico'+contact);
                  DateTime dt = DateTime.newInstance(Integer.valueof(contact.timeStamp.mid(0,4)), Integer.valueof(contact.timeStamp.mid(5,2)), Integer.valueof(contact.timeStamp.mid(8,2)), Integer.valueof(contact.timeStamp.mid(11,2)), Integer.valueof(contact.timeStamp.mid(14,2)), Integer.valueof(contact.timeStamp.mid(17,2)));
                
                  String prefix = TelephoneWithPrefixService.getValidPrefix(contact.prefissoInternazionale);

                  if (contact.tipoTelefono == '1'){ //tel principale  
                      telPrincipaleMap.put(dt,prefix + contact.numero);
                      telPrincipaleIdContattoList.put(contact.numero,contact.idContatto);
                      telPrincipaleOppositionList.put(contact.numero,contact.opposizione);
                      telPrincipaleOppositionReasonList.put(contact.numero,contact.motivoOpposizione);
                      
  
                  }
                  if (contact.tipoTelefono == '2'){ //tel mobile
                      telMobileMap.put(dt,prefix + contact.numero);
                      telMobileIdContattoList.put(contact.numero,contact.idContatto);
                      telMobileOppositionList.put(contact.numero,contact.opposizione);
                      telMobileOppositionReasonList.put(contact.numero,contact.motivoOpposizione);
                      
  
                  }
                  if (contact.tipoTelefono == '4'){ //fax
                      telFaxMap.put(dt,prefix + contact.numero);
                      telFaxIdContattoList.put(contact.numero, contact.idContatto);
                      telFaxOppositionList.put(contact.numero,contact.opposizione);                    
                      telFaxOppositionReasonList.put(contact.numero,contact.motivoOpposizione);
                      
                  }
                  if (contact.tipoTelefono == '8'){ //tel ufficio
                      telUfficioMap.put(dt,prefix + contact.numero);
                      telUfficioIdContattoList.put(contact.numero,contact.idContatto);
                      telUfficioOppositionList.put(contact.numero,contact.opposizione);
                      telUfficioOppositionReasonList.put(contact.numero,contact.motivoOpposizione);
                      
                  } 
              
              }
              
              system.debug('+++++++++ telPrincipaleMap='+telPrincipaleMap);
              
              list<DateTime> dtList = new List<DateTime>();
              dtList.addAll (telPrincipaleMap.keyset()); //creo una lista con i timestamp 
              dtList.sort(); //li ordino
              DateTime dtValueTelPrinc;
              if (dtList.size()>0)
                  dtValueTelPrinc = dtList.get(dtList.size()-1); // quello che mi interessa è l'ultimo
              
              dtList.clear();
              dtList.addAll (telMobileMap.keyset());
              dtList.sort();
              DateTime dtValueMobile;
              if (dtList.size()>0)
                  dtValueMobile = dtList.get(dtList.size()-1);
              
              dtList.clear();
              dtList.addAll (telFaxMap.keyset());
              dtList.sort();
              DateTime dtValueFax;
              if (dtList.size()>0)
                  dtValueFax = dtList.get(dtList.size()-1);
              
              dtList.clear();
              dtList.addAll (telUfficioMap.keyset());
              dtList.sort();
              DateTime dtValueUfficio;
              if (dtList.size()>0)
                  dtValueUfficio = dtList.get(dtList.size()-1);
              
              
              
              if(telPrincipaleMap.values().size()>0){
                  system.debug('+++++++++ telPrincipaleMap2 ='+telPrincipaleMap);
                  theAccount.CIF_Phone__c = telPrincipaleMap.get(dtValueTelPrinc); //il telefono è quello corrispondente al Dt più recente
                  theAccount.CIF_Id_Contatto_Phone__c = telPrincipaleIdContattoList.get(String.valueof(theAccount.CIF_Phone__c));
                  theAccount.Flag_Opposizione_Tel_Princ__c = telPrincipaleOppositionList.get(String.valueof(theAccount.CIF_Phone__c)) == 'true' ? true: false;
                  theAccount.Motivo_opposizione_Tel_Princ__c = telPrincipaleOppositionReasonList.get(String.valueof(theAccount.CIF_Phone__c));
              }
              if(telMobileMap.values().size()>0){
                  if (theResponse.aSoggetto.get(0).soggetto.tipoSoggetto=='1')
                  {
                      theAccount.CIF_PersonMobilePhone__c = telMobileMap.get(dtValueMobile);
                      theAccount.CIF_Id_Contatto_PersonMobilePhone__c = telMobileIdContattoList.get(String.valueof(theAccount.CIF_PersonMobilePhone__c));
                      theAccount.Flag_Opposizione_Tel_Cell_B2C__c = telMobileOppositionList.get(String.valueof(theAccount.CIF_PersonMobilePhone__c)) == 'true' ? true: false;
                      theAccount.Motivo_opposizione_Tel_Cell_B2C__c = telMobileOppositionReasonList.get(String.valueof(theAccount.CIF_PersonMobilePhone__c));
                  }
                  else if (theResponse.aSoggetto.get(0).soggetto.tipoSoggetto=='2')
                  {
                      theAccount.CIF_MobilePhone__c = telMobileMap.get(dtValueMobile);
                      theAccount.CIF_Id_Contatto_MobilePhone__c = telMobileIdContattoList.get(String.valueof(theAccount.CIF_MobilePhone__c));
                      theAccount.Flag_Opposizione_Tel_Cell_B2B__c = telMobileOppositionList.get(String.valueof(theAccount.CIF_MobilePhone__c)) == 'true' ? true: false;
                      theAccount.Motivo_opposizione_Tel_Cell_B2B__c = telMobileOppositionReasonList.get(String.valueof(theAccount.CIF_MobilePhone__c));
                  }
              }
              if(telFaxMap.values().size()!=0){
                  theAccount.Fax = telFaxMap.get(dtValueFax);
                  theAccount.CIF_Id_Contatto_Fax__c = telFaxIdContattoList.get(String.valueof(theAccount.Fax));
                  theAccount.Flag_Opposizione_Fax__c = telFaxOppositionList.get(String.valueof(theAccount.Fax)) == 'true' ? true: false;
                  theAccount.Motivo_opposizione_Fax__c = telFaxOppositionReasonList.get(String.valueof(theAccount.Fax));
              }
              if(telUfficioMap.values().size()!=0){
                  theAccount.CIF_Work_phone__c = telUfficioMap.get(dtValueUfficio);
                  theAccount.CIF_Id_Contatto_WorkPhone__c = telUfficioIdContattoList.get(String.valueof(theAccount.CIF_Work_phone__c));
                  theAccount.Flag_Opposizione_Tel_Uff__c = telUfficioOppositionList.get(String.valueof(theAccount.CIF_Work_phone__c)) == 'true' ? true: false;
                  theAccount.Motivo_opposizione_Tel_Uff__c = telUfficioOppositionReasonList.get(String.valueof(theAccount.CIF_Work_phone__c));
              }
          }
          
          
          if(theResponse.aSoggetto.get(0).lstContTelem!=null && theResponse.aSoggetto.get(0).lstContTelem.size()>0){
              map<DateTime,String> mailUfficioMap = new map<DateTime,String> ();
              map<DateTime,String> mailPersonaleMap = new map<DateTime,String>();
    
              map<String,String> mailUfficioIdContattoList = new map<String,String>(); 
              map<String,String> mailPersonaleIdContattoList = new map<String,String>();
  
              map<String,String> mailUfficioOppositionList = new map<String,String>(); 
              map<String,String> mailPersonaleOppositionList = new map<String,String>();
  
              map<String,String> mailUfficioOppositionReasonList = new map<String,String>(); 
              map<String,String> mailPersonaleOppositionReasonList = new map<String,String>();            
              
              for (SearchAccountFullResponse.cls_lstContTelem contact : theResponse.aSoggetto.get(0).lstContTelem) {
                  System.debug('********Contatto telematico'+contact);
                  DateTime dt = DateTime.newInstance(Integer.valueof(contact.timeStamp.mid(0,4)), Integer.valueof(contact.timeStamp.mid(5,2)), Integer.valueof(contact.timeStamp.mid(8,2)), Integer.valueof(contact.timeStamp.mid(11,2)), Integer.valueof(contact.timeStamp.mid(14,2)), Integer.valueof(contact.timeStamp.mid(17,2)));
                  
                  if (contact.tipoContatto == '1'){ //mail personale
                      mailPersonaleMap.put(dt,contact.testo);
                      mailPersonaleIdContattoList.put(contact.testo,contact.idContatto);
                      mailPersonaleOppositionList.put(contact.testo,contact.opposizione);
                      mailPersonaleOppositionReasonList.put(contact.testo,contact.motivoOpposizione);
                  }
                  if (contact.tipoContatto == '32'){ //mail ufficio
                      mailUfficioMap.put(dt,contact.testo);
                      mailUfficioIdContattoList.put(contact.testo,contact.idContatto);
                      mailUfficioOppositionList.put(contact.testo,contact.opposizione);
                      mailUfficioOppositionReasonList.put(contact.testo,contact.motivoOpposizione);
                      
                  }
              }
              
              list<DateTime> dtList = new List<DateTime>();
              dtList.addAll (mailPersonaleMap.keyset()); //creo una lista con i timestamp 
              dtList.sort(); //li ordino
              DateTime dtValueMailPers;
              if(dtList.size()>0)
                  dtValueMailPers= dtList.get(dtList.size()-1); // quello che mi interessa è l'ultimo
              
              dtList.clear();
              dtList.addAll (mailUfficioMap.keyset());
              dtList.sort();
              DateTime dtValueMailUff;
              if(dtList.size()>0)
                  dtValueMailUff = dtList.get(dtList.size()-1);
              
              if(mailPersonaleMap.values().size()>0){
                  if (theResponse.aSoggetto.get(0).soggetto.tipoSoggetto=='1')
                  {
                      theAccount.CIF_PersonEmail__c = mailPersonaleMap.get(dtValueMailPers);
                      theAccount.CIF_Id_Contatto_PersonEmail__c = mailPersonaleIdContattoList.get(String.valueof(theAccount.CIF_PersonEmail__c));
                      theAccount.Flag_Opposizione_Email_Pers_B2C__c = mailPersonaleOppositionList.get(String.valueof(theAccount.CIF_PersonEmail__c)) == 'true' ? true: false;
                      theAccount.Motivo_opposizione_Email_Pers_B2C__c = mailPersonaleOppositionReasonList.get(String.valueof(theAccount.CIF_PersonEmail__c));
                  }
                  if(theResponse.aSoggetto.get(0).soggetto.tipoSoggetto=='2')
                  {
                      theAccount.CIF_PersonalEmail__c = mailPersonaleMap.get(dtValueMailPers);
                      theAccount.CIF_Id_Contatto_PersonalEmail__c = mailPersonaleIdContattoList.get(String.valueof(theAccount.CIF_PersonalEmail__c));
                      theAccount.Flag_Opposizione_Email_Pers_B2B__c = mailPersonaleOppositionList.get(String.valueof(theAccount.CIF_PersonalEmail__c)) == 'true' ? true: false;
                      theAccount.Motivo_opposizione_Email_Pers_B2B__c = mailPersonaleOppositionReasonList.get(String.valueof(theAccount.CIF_PersonalEmail__c));
                  }
              }
              if(mailUfficioMap.values().size()!=0){
                  theAccount.CIF_Work_email__c = mailUfficioMap.get(dtValueMailUff);
                  theAccount.CIF_Id_Contatto_WorkEmail__c = mailUfficioIdContattoList.get(String.valueof(theAccount.CIF_Work_email__c));
                  theAccount.Flag_Opposizione_Email_Uff__c = mailUfficioOppositionList.get(String.valueof(theAccount.CIF_Work_email__c)) == 'true' ? true: false;
                  theAccount.Motivo_opposizione_Email_Uff__c = mailUfficioOppositionReasonList.get(String.valueof(theAccount.CIF_Work_email__c));
              }
  
              
  
              //theAccount.CIF_Privacy_8__c = theResponse.aSoggetto.get(0).soggetto.privacyOTP =='true' ? 'Sì' : 'No';
              //theAccount.CIF_OTP_Phone_contact__c = theResponse.aSoggetto.get(0).soggetto.telefonoOTP;
          }
  
              String daggPrivacy1 = theResponse.aSoggetto.get(0).soggetto.daggPrivacy1;
              String daggPrivacy2 = theResponse.aSoggetto.get(0).soggetto.daggPrivacy2;
              String daggPrivacy3 = theResponse.aSoggetto.get(0).soggetto.daggPrivacy3;
              String daggPrivacy4 = theResponse.aSoggetto.get(0).soggetto.daggPrivacy4;
              //String daggPrivacyEmail = theResponse.aSoggetto.get(0).soggetto.daggPrivacyEmail;
              //String daggPrivacyFirma = theResponse.aSoggetto.get(0).soggetto.daggPrivacyFirma;
              //if(theResponse.aSoggetto.get(0).soggetto.daggPrivacyOTP != null)
              //String daggPrivacyOTP = theResponse.aSoggetto.get(0).soggetto.daggPrivacyOTP;
  
              DateTime dtdaggPrivacy1;
              DateTime dtdaggPrivacy2;
              DateTime dtdaggPrivacy3;
              DateTime dtdaggPrivacy4;
  
              if(daggPrivacy1 != null){
                  dtdaggPrivacy1 = DateTime.newInstance(Integer.valueof(daggPrivacy1.mid(0,4)), Integer.valueof(daggPrivacy1.mid(5,2)), Integer.valueof(daggPrivacy1.mid(8,2)), Integer.valueof(daggPrivacy1.mid(11,2)), Integer.valueof(daggPrivacy1.mid(14,2)), Integer.valueof(daggPrivacy1.mid(17,2)));
              }
              if(daggPrivacy2 != null){
                  dtdaggPrivacy2 = DateTime.newInstance(Integer.valueof(daggPrivacy2.mid(0,4)), Integer.valueof(daggPrivacy2.mid(5,2)), Integer.valueof(daggPrivacy2.mid(8,2)), Integer.valueof(daggPrivacy2.mid(11,2)), Integer.valueof(daggPrivacy2.mid(14,2)), Integer.valueof(daggPrivacy2.mid(17,2)));
              }
              if(daggPrivacy3 != null){
                  dtdaggPrivacy3 = DateTime.newInstance(Integer.valueof(daggPrivacy3.mid(0,4)), Integer.valueof(daggPrivacy3.mid(5,2)), Integer.valueof(daggPrivacy3.mid(8,2)), Integer.valueof(daggPrivacy3.mid(11,2)), Integer.valueof(daggPrivacy3.mid(14,2)), Integer.valueof(daggPrivacy3.mid(17,2)));
              }
              if(daggPrivacy4 != null){
                  dtdaggPrivacy4 = DateTime.newInstance(Integer.valueof(daggPrivacy4.mid(0,4)), Integer.valueof(daggPrivacy4.mid(5,2)), Integer.valueof(daggPrivacy4.mid(8,2)), Integer.valueof(daggPrivacy4.mid(11,2)), Integer.valueof(daggPrivacy4.mid(14,2)), Integer.valueof(daggPrivacy4.mid(17,2)));
              }
          
          FullResponse.values.put('returnedCIFAccount',theAccount);
          
          return FullResponse;  
  
      }
  
      ////// SEZIONE PER NORMALIZZAZIONE INDIRIZZO //////
      
      //Get Stati
      public static IE_Integration_Record__c PopulateIErecord_stati (){
          IE_Integration_Record__c theResult = new IE_Integration_Record__c();
          List<IE_Configuration__c> theConfig = [SELECT id,NameSpacePrefix1__c,NameSpacePrefix2__c,NameSpaceUri1__c,NameSpaceUri2__c FROM IE_Configuration__c WHERE Name='Integration_getStati' LIMIT 1];
          if (!theConfig.isempty()) {
              theresult.IE_Configuration__c = theConfig[0].id;
          }
          //Compiling the DevField with the JSON 
          JSONGenerator myGen= JSON.createGenerator(true);
          
          String NameSpacePrefixToUse1 = theConfig[0].NameSpacePrefix1__c;
          String NameSpacePrefixToUse2 = theConfig[0].NameSpacePrefix2__c;
          String NameSpaceUriToUse1 = theConfig[0].NameSpaceUri1__c;
          String NameSpaceUriToUse2 = theConfig[0].NameSpaceUri2__c;
          
          //initialise writer
          XmlStreamWriter w = new XmlStreamWriter();
          
          //ENVELOPE
          w.writeStartElement(NameSpacePrefixToUse1, 'Envelope',NameSpaceUriToUse1+'');
          w.writeNamespace(NameSpacePrefixToUse1, NameSpaceUriToUse1+'');
          w.writeNamespace(NameSpacePrefixToUse2, NameSpaceUriToUse2+'');
          
          //HEADER OPEN-CLOSE
          w.writeEmptyElement(NameSpacePrefixToUse1, 'Header', NameSpacePrefixToUse1); 
          
          ///BODY
          w.writeStartElement(NameSpacePrefixToUse1, 'Body', NameSpaceUriToUse1);
          w.writeStartElement(NameSpacePrefixToUse2, 'RichiestaStato', NameSpaceUriToUse2);
  
  
          myGen.writeStartObject();
          myGen.writeFieldName('Generale');
          w.writeStartElement(NameSpacePrefixToUse2, 'Generale', NameSpacePrefixToUse2);
  
          myGen.writeStartObject();
  
          
          myGen.writeStringField('CodConfed','1');
          w.writeStartElement(NameSpacePrefixToUse2, 'CodConfed', NameSpacePrefixToUse2);
          w.writeCharacters('1');
          w.writeEndElement();
  
          myGen.writeStringField('CodStato','380');
          w.writeStartElement(NameSpacePrefixToUse2, 'CodStato', NameSpacePrefixToUse2);
          w.writeCharacters('380');
          w.writeEndElement();
          
          myGen.writeStringField('Config','70005');
          w.writeStartElement(NameSpacePrefixToUse2, 'Config', NameSpacePrefixToUse2);
          w.writeCharacters('70005');
          w.writeEndElement();
          
          myGen.writeStringField('ConfigDefault','0');
          w.writeStartElement(NameSpacePrefixToUse2, 'ConfigDefault', NameSpacePrefixToUse2);
          w.writeCharacters('0');
          w.writeEndElement();        
          
          myGen.writeStringField('Lingua','ITA');
          w.writeStartElement(NameSpacePrefixToUse2, 'Lingua', NameSpacePrefixToUse2);
          w.writeCharacters('ITA');
          w.writeEndElement();
  
          myGen.writeStringField('CodSocietaATC','0');
          w.writeStartElement(NameSpacePrefixToUse2, 'CodSocietaATC', NameSpacePrefixToUse2);
          w.writeCharacters('0');
          w.writeEndElement();        
          
          myGen.writeEndObject();
          w.writeEndElement(); //end Generale
          string jsonString = myGen.getAsString();
  
          system.debug ('*****json string '+jsonString );
          theresult.DevField__c = jsonString;
  
          w.writeEndElement(); //end RichiestaStato
          w.writeEndElement(); //end body       
          w.writeEndElement(); //end envelope
          
          string compiledrequest = w.getXmlString();
          system.debug ('compiledrequest'+compiledrequest);   
          theresult.RequestBody__c = compiledrequest;
  
          return theResult;
  
      } 
      /** PURE IT Commento per rimuovere referenza di una classe commentata
      public static AddressNormalize_UtilityClass.ResponseDto manageEditResponse_stati (IE_Engine IEInstance){
          AddressNormalize_UtilityClass.ResponseDto results = new AddressNormalize_UtilityClass.ResponseDto();
  
          system.debug('****** IEInstance ='+IEInstance);
          getStatiResponse formattedResponse = mapSearchAccountResponse_stati (IEInstance.JSONResponse);       
          
          if (formattedResponse == null)
          {
              results.isSuccess = False;
              results.message = 'Errore risposta vuota'; 
              return results;
          }
          if (formattedResponse.Esito.codiceEsito.startsWithIgnoreCase('0'))
          {
              system.debug ('******SUCCESS');
              
              map<string,string> Finalresponse = new map<string,string>();
              
              Finalresponse = setResponse_stati (formattedResponse); 
              results.isSuccess = True;
              for(string r: Finalresponse.keyset() ){
                  results.values.put(r,Finalresponse.get(r));
              }
              
          }
          //errore chiamata
          else{
              system.debug('****** ERROR');
              results.isSuccess = False;
              results.message = 'La chiamata ha avuto esito negativo. Riprovare o contattare l\'amministratore di sistema'; 
          }
  
          return results;
      }
      PURE IT */
      
      public static getStatiResponse mapSearchAccountResponse_stati (String JSONResponse) {
          getStatiResponse emptyInstance = new getStatiResponse();
          System.debug('***************pre deserialize() JSONResponse = ' + JSONResponse);
          Type typeInstance = Type.forName('getStatiResponse');
          getStatiResponse deserializeResults = (getStatiResponse)JSON.deserialize(JSONResponse, typeInstance);
          System.debug('***************deserialize() results = ' + deserializeResults);
          return deserializeResults;
      }
      
      public static map<string,string> setResponse_stati (getStatiResponse theResponse)
      {
          map<string,string> res = new map<string,string>();
          
          Integer occorrenze = Integer.valueof (theResponse.TabStato.size());
          
          for(integer i = 0; i < occorrenze; i++){
              res.put(String.valueof(theResponse.TabStato.get(i).DesStato),String.valueof(theResponse.TabStato.get(i).SiglaStato3));
              
          }
          return res;  
  
      } 
      
      
      
      
      //Get Province
      public static IE_Integration_Record__c PopulateIErecord_province (){
          IE_Integration_Record__c theResult = new IE_Integration_Record__c();
          List<IE_Configuration__c> theConfig = [SELECT id,NameSpacePrefix1__c,NameSpacePrefix2__c,NameSpaceUri1__c,NameSpaceUri2__c FROM IE_Configuration__c WHERE Name='Integration_getProvince' LIMIT 1];
          if (!theConfig.isempty()) {
              theresult.IE_Configuration__c = theConfig[0].id;
          }
          //Compiling the DevField with the JSON 
          JSONGenerator myGen= JSON.createGenerator(true);
          
          String NameSpacePrefixToUse1 = theConfig[0].NameSpacePrefix1__c;
          String NameSpacePrefixToUse2 = theConfig[0].NameSpacePrefix2__c;
          String NameSpaceUriToUse1 = theConfig[0].NameSpaceUri1__c;
          String NameSpaceUriToUse2 = theConfig[0].NameSpaceUri2__c;
          
          //initialise writer
          XmlStreamWriter w = new XmlStreamWriter();
          
          //ENVELOPE
          w.writeStartElement(NameSpacePrefixToUse1, 'Envelope',NameSpaceUriToUse1+'');
          w.writeNamespace(NameSpacePrefixToUse1, NameSpaceUriToUse1+'');
          w.writeNamespace(NameSpacePrefixToUse2, NameSpaceUriToUse2+'');
          
          //HEADER OPEN-CLOSE
          w.writeEmptyElement(NameSpacePrefixToUse1, 'Header', NameSpacePrefixToUse1); 
          
          ///BODY
          w.writeStartElement(NameSpacePrefixToUse1, 'Body', NameSpaceUriToUse1);
          w.writeStartElement(NameSpacePrefixToUse2, 'RichiestaProvincia', NameSpaceUriToUse2);
  
  
          myGen.writeStartObject();
          myGen.writeFieldName('Generale');
          w.writeStartElement(NameSpacePrefixToUse2, 'Generale', NameSpacePrefixToUse2);
  
          myGen.writeStartObject();
  
          
          myGen.writeStringField('CodConfed','1');
          w.writeStartElement(NameSpacePrefixToUse2, 'CodConfed', NameSpacePrefixToUse2);
          w.writeCharacters('1');
          w.writeEndElement();
  
          myGen.writeStringField('CodStato','380');
          w.writeStartElement(NameSpacePrefixToUse2, 'CodStato', NameSpacePrefixToUse2);
          w.writeCharacters('380');
          w.writeEndElement();
          
          myGen.writeStringField('Config','70005');
          w.writeStartElement(NameSpacePrefixToUse2, 'Config', NameSpacePrefixToUse2);
          w.writeCharacters('70005');
          w.writeEndElement();
          
          myGen.writeStringField('Lingua','ITA');
          w.writeStartElement(NameSpacePrefixToUse2, 'Lingua', NameSpacePrefixToUse2);
          w.writeCharacters('ITA');
          w.writeEndElement();
  
          
          myGen.writeEndObject();
          w.writeEndElement(); //end Generale
          string jsonString = myGen.getAsString();
  
          system.debug ('*****json string '+jsonString );
          theresult.DevField__c = jsonString;
  
          w.writeEndElement(); //end RichiestaProvincia
          w.writeEndElement(); //end body       
          w.writeEndElement(); //end envelope
          
          string compiledrequest = w.getXmlString();
          system.debug ('compiledrequest'+compiledrequest);   
          theresult.RequestBody__c = compiledrequest;
  
          return theResult;
  
      } 
      /** PURE IT Commento per rimuovere referenza di una classe commentata
      public static AddressNormalize_UtilityClass.ResponseDto manageEditResponse_province (IE_Engine IEInstance){
          AddressNormalize_UtilityClass.ResponseDto results = new AddressNormalize_UtilityClass.ResponseDto();
  
          system.debug('****** IEInstance ='+IEInstance);
          getProvinceResponse formattedResponse = mapSearchAccountResponse_province (IEInstance.JSONResponse);       
          
          if (formattedResponse == null)
          {
              results.isSuccess = False;
              results.message = 'Errore risposta vuota'; 
              return results;
          }
          if (formattedResponse.Esito.codiceEsito.startsWithIgnoreCase('0'))
          {
              system.debug ('******SUCCESS');
              
              map<string,string> Finalresponse = new map<string,string>();
              
              Finalresponse = setResponse_province (formattedResponse); 
              results.isSuccess = True;
              for(string r: Finalresponse.keyset() ){
                  results.values.put(r,Finalresponse.get(r));
              }
              
          }
          //errore chiamata
          else{
              system.debug('****** ERROR');
              results.isSuccess = False;
              results.message = 'La chiamata ha avuto esito negativo. Riprovare o contattare l\'amministratore di sistema'; 
          }
  
          return results;
      }
      PURE IT */
      
      public static getProvinceResponse mapSearchAccountResponse_province (String JSONResponse) {
          getProvinceResponse emptyInstance = new getProvinceResponse();
          System.debug('***************pre deserialize() JSONResponse = ' + JSONResponse);
          Type typeInstance = Type.forName('getProvinceResponse');
          getProvinceResponse deserializeResults = (getProvinceResponse)JSON.deserialize(JSONResponse, typeInstance);
          System.debug('***************deserialize() results = ' + deserializeResults);
          return deserializeResults;
      }
      
      public static map<string,string> setResponse_province (getProvinceResponse theResponse)
      {
          map<string,string> res = new map<string,string>();
          
          Integer occorrenze = Integer.valueof (theResponse.TabProvin.size());
          
          for(integer i = 0; i < occorrenze; i++){
              res.put(String.valueof(theResponse.TabProvin.get(i).NumOccorrenza),String.valueof(theResponse.TabProvin.get(i).SigProvin));
              
          }
          return res;  
  
      } 
      
      
      //Get Comuni
      public static IE_Integration_Record__c PopulateIErecord_comuni (String currentProvince){
          IE_Integration_Record__c theResult = new IE_Integration_Record__c();
          List<IE_Configuration__c> theConfig = [SELECT id,NameSpacePrefix1__c,NameSpacePrefix2__c,NameSpaceUri1__c,NameSpaceUri2__c FROM IE_Configuration__c WHERE Name='Integration_getComuni' LIMIT 1];
          if (!theConfig.isempty()) {
              theresult.IE_Configuration__c = theConfig[0].id;
          }
          //Compiling the DevField with the JSON 
          JSONGenerator myGen= JSON.createGenerator(true);
          
          String NameSpacePrefixToUse1 = theConfig[0].NameSpacePrefix1__c;
          String NameSpacePrefixToUse2 = theConfig[0].NameSpacePrefix2__c;
          String NameSpaceUriToUse1 = theConfig[0].NameSpaceUri1__c;
          String NameSpaceUriToUse2 = theConfig[0].NameSpaceUri2__c;
          
          //initialise writer
          XmlStreamWriter w = new XmlStreamWriter();
          
          //ENVELOPE
          w.writeStartElement(NameSpacePrefixToUse1, 'Envelope',NameSpaceUriToUse1+'');
          w.writeNamespace(NameSpacePrefixToUse1, NameSpaceUriToUse1+'');
          w.writeNamespace(NameSpacePrefixToUse2, NameSpaceUriToUse2+'');
          
          //HEADER OPEN-CLOSE
          w.writeEmptyElement(NameSpacePrefixToUse1, 'Header', NameSpacePrefixToUse1); 
          
          ///BODY
          w.writeStartElement(NameSpacePrefixToUse1, 'Body', NameSpaceUriToUse1);
          w.writeStartElement(NameSpacePrefixToUse2, 'RichiestaLocalita', NameSpaceUriToUse2);
  
  
          myGen.writeStartObject();
          myGen.writeFieldName('Generale');
          w.writeStartElement(NameSpacePrefixToUse2, 'Generale', NameSpacePrefixToUse2);
  
          myGen.writeStartObject();
  
          
          myGen.writeStringField('CodConfed','1');
          w.writeStartElement(NameSpacePrefixToUse2, 'CodConfed', NameSpacePrefixToUse2);
          w.writeCharacters('1');
          w.writeEndElement();
  
          myGen.writeStringField('CodStato','380');
          w.writeStartElement(NameSpacePrefixToUse2, 'CodStato', NameSpacePrefixToUse2);
          w.writeCharacters('380');
          w.writeEndElement();
          
          myGen.writeStringField('Config','70005');
          w.writeStartElement(NameSpacePrefixToUse2, 'Config', NameSpacePrefixToUse2);
          w.writeCharacters('70005');
          w.writeEndElement();
          
          myGen.writeStringField('Lingua','ITA');
          w.writeStartElement(NameSpacePrefixToUse2, 'Lingua', NameSpacePrefixToUse2);
          w.writeCharacters('ITA');
          w.writeEndElement();
  
          
          myGen.writeEndObject();
          w.writeEndElement(); //end Generale
          
          myGen.writeStringField('SigProvin',''+currentProvince);
          w.writeStartElement(NameSpacePrefixToUse2, 'SigProvin', NameSpacePrefixToUse2);
          w.writeCharacters(''+currentProvince);
          w.writeEndElement();
          
          
          string jsonString = myGen.getAsString();
  
          system.debug ('*****json string '+jsonString );
          theresult.DevField__c = jsonString;
  
          w.writeEndElement(); //end RichiestaLocalita
          w.writeEndElement(); //end body       
          w.writeEndElement(); //end envelope
          
          string compiledrequest = w.getXmlString();
          system.debug ('compiledrequest'+compiledrequest);   
          theresult.RequestBody__c = compiledrequest;
  
          return theResult;
  
      } 
      /** PURE IT Commento per rimuovere referenza di una classe commentata
      public static AddressNormalize_UtilityClass.ResponseDto manageEditResponse_Comuni (IE_Engine IEInstance){
          AddressNormalize_UtilityClass.ResponseDto results = new AddressNormalize_UtilityClass.ResponseDto();
  
          system.debug('****** IEInstance ='+IEInstance);
          PURE IT */
          /** PURE IT Commento per rimuovere referenza di una classe commentata
          getComuniResponse formattedResponse = mapSearchAccountResponse_Comuni (IEInstance.JSONResponse);       
          PURE IT comment closure */
          /** PURE IT Commento per rimuovere referenza di una classe commentata
          if (formattedResponse == null)
          {
              results.isSuccess = False;
              results.message = 'Errore risposta vuota'; 
              return results;
          }
          if (formattedResponse.Esito.codiceEsito.startsWithIgnoreCase('0'))
          {
              system.debug ('******SUCCESS');
              
              map<string,string> Finalresponse = new map<string,string>();
              
              Finalresponse = setResponse_comuni (formattedResponse); 
              results.isSuccess = True;
              for(string r: Finalresponse.keyset() ){
                  results.values.put(r,Finalresponse.get(r));
              }
              
          }
          //errore chiamata
          else{
              system.debug('****** ERROR');
              results.isSuccess = False;
              results.message = 'La chiamata ha avuto esito negativo. Riprovare o contattare l\'amministratore di sistema'; 
          }
  
          return results;
      }
      PURE IT */
      /** PURE IT Commento per rimuovere referenza di una classe commentata
      public static getComuniResponse mapSearchAccountResponse_comuni (String JSONResponse) {
          getComuniResponse emptyInstance = new getComuniResponse();
          System.debug('***************pre deserialize() JSONResponse = ' + JSONResponse);
          Type typeInstance = Type.forName('getComuniResponse');
          getComuniResponse deserializeResults = (getComuniResponse)JSON.deserialize(JSONResponse, typeInstance);
          System.debug('***************deserialize() results = ' + deserializeResults);
          return deserializeResults;
      }
      
      
      public static map<string,string> setResponse_comuni (getComuniResponse theResponse)
      {
          map<string,string> res = new map<string,string>();
          
          Integer occorrenze = Integer.valueof (theResponse.TabLocalita.size());
          
          for(integer i = 0; i < occorrenze; i++){
              res.put(String.valueof(theResponse.TabLocalita.get(i).NumOccorrenza),String.valueof(theResponse.TabLocalita.get(i).DesLocalitaAmm));
              
          }
          return res;  
  
      } 
      PURE IT Comment closure */
      
      
      /*public static IE_Integration_Record__c PopulateIErecord_NormalizeAddress (AccountInsertCtrl.AddressResponseObj req){
          IE_Integration_Record__c theResult = new IE_Integration_Record__c();
          List<IE_Configuration__c> theConfig = [SELECT id,NameSpacePrefix1__c,NameSpacePrefix2__c,NameSpaceUri1__c,NameSpaceUri2__c FROM IE_Configuration__c WHERE Name='AddressNormalization' LIMIT 1];
          if (!theConfig.isempty()) {
              theresult.IE_Configuration__c = theConfig[0].id;
          }
          
          //string queryMc = 'select SFDCexpected__c, ProvinciaExternalKey__c from MappingProvince__c where SFDCexpected__c =\''+req.provincia+'\'';
          //MappingProvince__c mc2 = Database.query(queryMc);
          //String SiglaProvincia = mc2.ProvinciaExternalKey__c;
          //system.debug('sigla provincia = '+SiglaProvincia);
          
          string ViaString = req.via.replace(',',' ');
              
          //Compiling the DevField with the JSON 
          JSONGenerator myGen= JSON.createGenerator(true);
          
          String NameSpacePrefixToUse1 = theConfig[0].NameSpacePrefix1__c;
          String NameSpacePrefixToUse2 = theConfig[0].NameSpacePrefix2__c;
          String NameSpaceUriToUse1 = theConfig[0].NameSpaceUri1__c;
          String NameSpaceUriToUse2 = theConfig[0].NameSpaceUri2__c;
          
          //initialise writer
          XmlStreamWriter w = new XmlStreamWriter();
          
          //ENVELOPE
          w.writeStartElement(NameSpacePrefixToUse1, 'Envelope',NameSpaceUriToUse1+'');
          w.writeNamespace(NameSpacePrefixToUse1, NameSpaceUriToUse1+'');
          w.writeNamespace(NameSpacePrefixToUse2, NameSpaceUriToUse2+'');
          
          //HEADER OPEN-CLOSE
          w.writeEmptyElement(NameSpacePrefixToUse1, 'Header', NameSpacePrefixToUse1); 
          
          //BODY
          w.writeStartElement(NameSpacePrefixToUse1, 'Body', NameSpaceUriToUse1);
          w.writeStartElement(NameSpacePrefixToUse2, 'RichiestaAddressMatchCode', NameSpaceUriToUse2);
  
  
          myGen.writeStartObject();
          myGen.writeFieldName('Generale');
          w.writeStartElement(NameSpacePrefixToUse2, 'Generale', NameSpacePrefixToUse2);
  
          myGen.writeStartObject();
          
          myGen.writeStringField('CodConfed','1');
          w.writeStartElement(NameSpacePrefixToUse2, 'CodConfed',NameSpacePrefixToUse2);
          w.writeCharacters('1');
          w.writeEndElement();
          
          myGen.writeStringField('CodStato','380');
          w.writeStartElement(NameSpacePrefixToUse2, 'CodStato', NameSpacePrefixToUse2);
          w.writeCharacters('380');
          w.writeEndElement();
          
          myGen.writeStringField('Config','70005');
          w.writeStartElement(NameSpacePrefixToUse2, 'Config', NameSpacePrefixToUse2);
          w.writeCharacters('70005');
          w.writeEndElement();
          
  
          myGen.writeStringField('Lingua','ITA');
          w.writeStartElement(NameSpacePrefixToUse2, 'Lingua', NameSpacePrefixToUse2);
          w.writeCharacters('ITA');
          w.writeEndElement();
  
          myGen.writeEndObject();
          w.writeEndElement(); //end Generale
          
          myGen.writeStringField('SigStato','ITA');
          w.writeStartElement(NameSpacePrefixToUse2, 'SigStato', NameSpacePrefixToUse2);
          w.writeCharacters('ITA');
          w.writeEndElement();
          
          myGen.writeStringField('DesStato','ITALIA');
          w.writeStartElement(NameSpacePrefixToUse2, 'DesStato', NameSpacePrefixToUse2);
          w.writeCharacters('ITALIA');
          w.writeEndElement();
          
          myGen.writeStringField('TipoCodice','');
          w.writeStartElement(NameSpacePrefixToUse2, 'TipoCodice', NameSpacePrefixToUse2);
          w.writeCharacters('');
          w.writeEndElement();
          
          myGen.writeStringField('CxCodice','');
          w.writeStartElement(NameSpacePrefixToUse2, 'CxCodice', NameSpacePrefixToUse2);
          w.writeCharacters('');
          w.writeEndElement();
          
          myGen.writeStringField('SigArea','');
          w.writeStartElement(NameSpacePrefixToUse2, 'SigArea', NameSpacePrefixToUse2);
          w.writeCharacters('');
          w.writeEndElement();
          
          myGen.writeStringField('DesArea','');
          w.writeStartElement(NameSpacePrefixToUse2, 'DesArea', NameSpacePrefixToUse2);
          w.writeCharacters('');
          w.writeEndElement();
          
          myGen.writeStringField('SigProvincia',''+req.provincia);
          w.writeStartElement(NameSpacePrefixToUse2, 'SigProvincia', NameSpacePrefixToUse2);
          w.writeCharacters(''+req.provincia);
          w.writeEndElement();
          
          myGen.writeStringField('DesProvincia','');
          w.writeStartElement(NameSpacePrefixToUse2, 'DesProvincia', NameSpacePrefixToUse2);
          w.writeCharacters('');
          w.writeEndElement();
          
          myGen.writeStringField('DesLocalita1',''+req.comune);
          w.writeStartElement(NameSpacePrefixToUse2, 'DesLocalita1', NameSpacePrefixToUse2);
          w.writeCharacters(''+req.comune);
          w.writeEndElement();
          
          myGen.writeStringField('DesLocalita2','');
          w.writeStartElement(NameSpacePrefixToUse2, 'DesLocalita2', NameSpacePrefixToUse2);
          w.writeCharacters('');
          w.writeEndElement();
          
          myGen.writeStringField('DesLocalita3','');
          w.writeStartElement(NameSpacePrefixToUse2, 'DesLocalita3', NameSpacePrefixToUse2);
          w.writeCharacters('');
          w.writeEndElement();
          
          myGen.writeStringField('CxTerr','');
          w.writeStartElement(NameSpacePrefixToUse2, 'CxTerr', NameSpacePrefixToUse2);
          w.writeCharacters('');
          w.writeEndElement();
          
          myGen.writeStringField('DesDUG','');
          w.writeStartElement(NameSpacePrefixToUse2, 'DesDUG', NameSpacePrefixToUse2);
          w.writeCharacters('');
          w.writeEndElement();
          
          myGen.writeStringField('DesVia',''+ViaString);
          w.writeStartElement(NameSpacePrefixToUse2, 'DesVia', NameSpacePrefixToUse2);
          w.writeCharacters(''+ViaString);
          w.writeEndElement();
          
          myGen.writeStringField('DesInfDX','');
          w.writeStartElement(NameSpacePrefixToUse2, 'DesInfDX', NameSpacePrefixToUse2);
          w.writeCharacters('');
          w.writeEndElement();
          
          myGen.writeStringField('TipoCivico','');
          w.writeStartElement(NameSpacePrefixToUse2, 'TipoCivico', NameSpacePrefixToUse2);
          w.writeCharacters('');
          w.writeEndElement();
          
          myGen.writeStringField('DesCivico','');
          w.writeStartElement(NameSpacePrefixToUse2, 'DesCivico', NameSpacePrefixToUse2);
          w.writeCharacters('');
          w.writeEndElement();
          
          myGen.writeStringField('ComplCivico1','');
          w.writeStartElement(NameSpacePrefixToUse2, 'ComplCivico1', NameSpacePrefixToUse2);
          w.writeCharacters('');
          w.writeEndElement();
          
          myGen.writeStringField('ComplCivico2','');
          w.writeStartElement(NameSpacePrefixToUse2, 'ComplCivico2', NameSpacePrefixToUse2);
          w.writeCharacters('');
          w.writeEndElement();
          
          string jsonString = myGen.getAsString();
  
          system.debug ('*****json string '+jsonString );
          theresult.DevField__c = jsonString;
  
          w.writeEndElement(); //end RichiestaAddressMatchCode
          w.writeEndElement(); //end body       
          w.writeEndElement(); //end envelope
          
          string compiledrequest = w.getXmlString();
          system.debug ('compiledrequest'+compiledrequest);   
          theresult.RequestBody__c = compiledrequest;
  
          return theResult;
  
      } */
      
      /*public static AccountInsertCtrl.ResponseDto manageEditResponse_NormalizeAddress (IE_Engine IEInstance){
          AccountInsertCtrl.ResponseDto results = new AccountInsertCtrl.ResponseDto();
  
          system.debug('****** IEInstance ='+IEInstance);
          NormalizeAddressResponse formattedResponse = mapSearchAccountResponse_NormalizeAddress (IEInstance.JSONResponse);       
          
          if (formattedResponse == null)
          {
              results.isSuccess = False;
              results.message = 'Errore risposta vuota'; 
              return results;
          }
          if (formattedResponse.Esito.Codice.startsWithIgnoreCase('0'))
          {
              system.debug ('******SUCCESS');
              
              AccountInsertCtrl.AddressResponseObj Finalresponse = new AccountInsertCtrl.AddressResponseObj();
              
              Finalresponse = setResponse_NormalizeAddress (formattedResponse); 
              results.isSuccess = True;
              
              results.values.put('ValidatedAddress',Finalresponse);
          }
          else if (formattedResponse.Esito.Codice.startsWithIgnoreCase('6')){
              system.debug ('******WARNING');
              List<AccountInsertCtrl.AddressResponseObj> Finalresponse = new List<AccountInsertCtrl.AddressResponseObj>();
              
              Finalresponse = setResponse_NormalizeAddressWarning (formattedResponse); //TODO
              results.isSuccess = True;
              
              for (AccountInsertCtrl.AddressResponseObj add : Finalresponse){
                  results.values.put(add.identif,add);
              }
              system.debug('-------results='+results);
              
          }
          else if (formattedResponse.Esito.Codice.startsWithIgnoreCase('8')){
              system.debug ('******ERRORS IN ADDRESS VALIDATION');
              String Finalresponse = setResponse_NormalizeAddressError (formattedResponse); 
              results.isSuccess = false;
              results.message = Finalresponse;            
          }
          //errore chiamata
          else{
              system.debug('****** ERROR');
              results.isSuccess = False;
              results.message = 'La chiamata ha avuto esito negativo. Riprovare o contattare l\'amministratore di sistema'; 
          }
  
          return results;
      }*/
      /*
      public static NormalizeAddressResponse mapSearchAccountResponse_NormalizeAddress (String JSONResponse) {
          NormalizeAddressResponse emptyInstance = new NormalizeAddressResponse();
          System.debug('***************pre deserialize() JSONResponse = ' + JSONResponse);
          Type typeInstance = Type.forName('NormalizeAddressResponse');
          NormalizeAddressResponse deserializeResults = (NormalizeAddressResponse)JSON.deserialize(JSONResponse, typeInstance);
          System.debug('***************deserialize() results = ' + deserializeResults);
          return deserializeResults;
      }*/
      
      /*public static AccountInsertCtrl.AddressResponseObj setResponse_NormalizeAddress (NormalizeAddressResponse theResponse) {
          AccountInsertCtrl.AddressResponseObj res = new AccountInsertCtrl.AddressResponseObj();
          
          res.viaSoloDescr = theResponse.DesViaAbb;
          res.ViaNoCiv = theResponse.DesDugUff+' '+ theResponse.DesViaAbb;
          res.via = theResponse.DesViaCompleta;
          res.cap = theResponse.CxTerr;
          res.comune = theResponse.DesLocAmmUff;
          res.provincia = theResponse.SigProvincia;
          res.ncivico = theResponse.DesCivico;
          res.adxCivico = theResponse.DesInfDx;
          res.MatchCode = theResponse.McConfederazione+theResponse.McStato+theResponse.McLocalita +theResponse.McVia +theResponse.McDugr +theResponse.McCivico +theResponse.McComplCivico1+ theResponse.McComplCivico2;
          res.MatchCode = res.MatchCode.trim();
          System.debug('*************res.MatchCode'+res.MatchCode);
          res.toponimo = theResponse.DesDugUff;
  
          return res;  
      } */
      /*
      public class CifCommunicationException extends Exception {}
      
      public static List<AccountInsertCtrl.AddressResponseObj> setResponse_NormalizeAddressWarning (NormalizeAddressResponse theResponse) {
          List<AccountInsertCtrl.AddressResponseObj> res = new List<AccountInsertCtrl.AddressResponseObj>();
          
          system.debug('---------- sono in setResponse_NormalizeAddressWarning');
          
          //il primo indirizzo che restituisco è quello della response (utile soprattutto nel caso non ci siano altri candidati)
          AccountInsertCtrl.AddressResponseObj addResponse = new AccountInsertCtrl.AddressResponseObj();
          addResponse.identif ='ResponseAddress0';
          
          addResponse.viaSoloDescr = theResponse.DesViaAbb;
          addResponse.ViaNoCiv = theResponse.DesDugUff+' '+ theResponse.DesViaAbb;
          addResponse.via = theResponse.DesViaCompleta;
          addResponse.cap = theResponse.CxTerr;
          addResponse.comune = theResponse.DesLocAmmUff;
          addResponse.provincia = theResponse.SigProvincia;
          addResponse.ncivico = theResponse.DesCivico;
          addResponse.adxCivico = theResponse.DesInfDx;
          //addResponse.MatchCode = theResponse.CxStatistico;
          addResponse.MatchCode = ''+theResponse.McConfederazione+theResponse.McStato+theResponse.McLocalita +theResponse.McVia +theResponse.McDugr +theResponse.McCivico +theResponse.McComplCivico1+ theResponse.McComplCivico2;
          addResponse.MatchCode = addResponse.MatchCode.trim();
          addResponse.toponimo = theResponse.DesDugUff;
  
          res.add(addResponse);
          
          
          if(theResponse.Candidati!=null ) {
              //se è stata restituita una lista di candidati, restituisco gli indirizzi
              if(theResponse.Candidati.TabCandVia!=null && theResponse.Candidati.TabCandLoc ==null){
                  //la località è fissa ma cambia la via (con cap)
                  for(integer i=0; i<theResponse.Candidati.TabCandVia.size();i++){
                      String prog = String.valueof(i+1);
                      AccountInsertCtrl.AddressResponseObj tempAdd = new AccountInsertCtrl.AddressResponseObj();
                      tempAdd.identif ='ResponseAddress'+prog;
  
                      tempAdd.viaSoloDescr = theResponse.Candidati.TabCandVia.get(i).DesVia;                    
                      tempAdd.ViaNoCiv = theResponse.Candidati.TabCandVia.get(i).DesDUG+' '+theResponse.Candidati.TabCandVia.get(i).DesVia;
                      tempAdd.via = theResponse.Candidati.TabCandVia.get(i).DesDUG+' '+theResponse.Candidati.TabCandVia.get(i).DesVia + ' '+theResponse.Candidati.TabCandVia.get(i).Civico;
                      tempAdd.cap = theResponse.Candidati.TabCandVia.get(i).CAP;
                      tempAdd.comune = theResponse.DesLocAmmUff;
                      tempAdd.provincia = theResponse.SigProvincia;
                      //tempAdd.ncivico = theResponse.DesCivico;
                      tempAdd.adxCivico = theResponse.DesInfDx;
                      tempAdd.MatchCode = ''+theResponse.McConfederazione+theResponse.McStato+theResponse.McLocalita +theResponse.McVia +theResponse.McDugr +theResponse.McCivico +theResponse.McComplCivico1+ theResponse.McComplCivico2;
                      tempAdd.MatchCode = tempAdd.MatchCode.trim();
                      tempAdd.toponimo = theResponse.DesDugUff;
                      
                      res.add(tempAdd);
                  }
              }
              else if (theResponse.Candidati.TabCandVia==null && theResponse.Candidati.TabCandLoc !=null){
                  //la via è fissa ma cambia la località (con cap)
                  for(integer i=0; i<theResponse.Candidati.TabCandLoc.size();i++){
                      String prog = String.valueof(i+1);
                      AccountInsertCtrl.AddressResponseObj tempAdd = new AccountInsertCtrl.AddressResponseObj();
                      tempAdd.identif ='ResponseAddress'+prog;
                      
                      tempAdd.viaSoloDescr = theResponse.DesViaAbb;
                      tempAdd.ViaNoCiv = theResponse.DesDugUff+' '+ theResponse.DesViaAbb;
                      tempAdd.via = theResponse.DesViaCompleta;
                      tempAdd.cap = theResponse.Candidati.TabCandLoc.get(i).CAP;
                      tempAdd.comune = theResponse.Candidati.TabCandLoc.get(i).Localita;
                      tempAdd.provincia = theResponse.Candidati.TabCandLoc.get(i).SigProvin;
                      tempAdd.ncivico = theResponse.DesCivico;
                      tempAdd.adxCivico = theResponse.DesInfDx;
                      tempAdd.MatchCode = ''+theResponse.McConfederazione+theResponse.McStato+theResponse.McLocalita +theResponse.McVia +theResponse.McDugr +theResponse.McCivico +theResponse.McComplCivico1+ theResponse.McComplCivico2;
                      tempAdd.MatchCode = tempAdd.MatchCode.trim();
                      tempAdd.toponimo = theResponse.DesDugUff;
                      
                      res.add(tempAdd);
                  }
              }
              else if (theResponse.Candidati.TabCandVia==null && theResponse.Candidati.TabCandLoc ==null)
              {
                  
              }
              else{
                  throw new CifCommunicationException('Si sono riscontrati i seguenti errori nella normalizzazione dell\'indirizzo: - Via e località / CAP non validi');
              }
          }
          system.debug('---------- res ='+res);
          return res;
      }
      
      public static String setResponse_NormalizeAddressError (NormalizeAddressResponse theResponse) {
          String res='Si sono riscontrati i seguenti errori nella normalizzazione dell\'indirizzo: ';
          
          integer nErrori = theResponse.Errori.size();
          
          for (integer i=0;i<nErrori;i++){
              res = res+' - '+theResponse.Errori.get(i).Descrizione;
          }
          
          return res;
      }*/
          
      
  }