({
    initializeCA : function(component, event, helper) {
        
        console.log('initializeCA method');
        let accountId = component.get("v.accountId");
        let questionario = component.get("v.questionario");
        let pickFields = component.get("v.pickFields");
        let questionarioCAid = component.get("v.questionarioCaID");
        if(questionarioCAid == null && component.get("v.recordId")!=null)
            questionarioCAid = component.get("v.recordId");
        let method = component.get("v.method");
        let lob = component.get("v.lob");
        let category = component.get("v.category");
        let subcategory = component.get("v.subcategory");
        var parameterMap = {};
        parameterMap['lob'] = lob;
        parameterMap['category'] = category;
        parameterMap['subcategory'] = subcategory;
        console.log('method: ',method);
        var action = component.get("c.initializeCaCTRL");
        action.setParams({	"accountId" : accountId,
                          "pickObj" : questionario,
                          "pickFields" : pickFields,
                          "method" : method,
                          "parameterMap" : parameterMap,
                          "questionarioCAid" : questionarioCAid
                          });
        component.set('v.isLoading', true);	
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("From server CA: ",response.getReturnValue());
                var result = response.getReturnValue();
                if(result!=null)
                {                   
                    if(result.pickValues!=null)
                    {
                        let pickResults = result.pickValues;
                        var picklistMap = component.get("v.picklistMap");
                        for(var key in pickResults){
                            console.log('key : '+ key+ ' - Map value: ', pickResults[key]);
                            picklistMap[key] = pickResults[key];
                        }
                        component.set("v.picklistMap",picklistMap);
                        console.log('picklistMap: ',picklistMap);
                        var picklistFields = component.get("v.pickFields");
                        for(var i = 0; i<picklistFields.length; i++)
                        {
                            if(picklistMap[picklistFields[i]]!=null)
                                component.set("v."+picklistFields[i], picklistMap[picklistFields[i]]);
                        }
                    }
                    if(result.cliente!=null && result.persona!=null)
                    {
                        this.populateClientInfo(component, event, helper, result.cliente, result.persona);
                    }
                    
                    if(result.idCase!=null)
                    {
                        component.set("v.caseId", result.idCase);
                        component.set("v.questionarioCA.Case__c", result.idCase);
                        
                    }
                    
                    if(result.questionario!=null)
                    {
                        component.set("v.questionarioCA", result.questionario);
                        console.log("Questionario completo: ", result.questionario);
                        component.set("v.CodiceFiscaleControparteContr",result.questionario.Codice_Fiscale_Controparte_Contr__c);
                        component.set("v.CodiceFiscaleControparte",result.questionario.Codice_fiscale_controparte__c);
                        component.set("v.CodiceFiscaleCondContr",result.questionario.Codice_fiscale_conducente__c);
                        component.set("v.AlreadyOpened",result.questionario.Sinistro_aperto_su_SOL__c);
                        if(result.questionario.Survey_Status__c!=null ){  
                            console.log('status bar '+ result.questionario.Survey_Status__c); 
                           
                          let respStep= result.questionario.Survey_Status__c;
                          let setSteps =  this.setCurrentPath(component,helper, respStep);
                            this.setCurrentPage(component,helper,setSteps, result.questionario.Feriti__c, result.questionario.Presenza_Testimoni__c);

                        }
                            
                        if(result.questionario.Ora_Evento__c!=null )
                        {
                        	console.log('result.questionario.Ora_Evento__c: ',result.questionario.Ora_Evento__c);
                            var oraEvento = this.convertToString(component, event, helper, result.questionario.Ora_Evento__c, ':');
                            console.log('oraEvento: ',oraEvento);
                            if(oraEvento.indexOf(':')>-1)
                            {
                                let resEvento = oraEvento.split(':')
                                component.set("v.oraEvento",resEvento[0]);
                                component.set("v.minutiEvento",resEvento[1]);
                            }
                        }
                        if(result.questionario.Ora_recall__c!=null )
                        {
                            var oraRecall = this.convertToString(component, event, helper, result.questionario.Ora_recall__c, ':');
                            if(oraRecall.indexOf(':')>-1)
                            {
                                let resRecall = oraRecall.split(':')
                                component.set("v.oraRecall",resRecall[0]);
                                component.set("v.minutiRecall",resRecall[1]);
                            }
                        }
                        //OAVERSANO 08/01/2019 : FIX Spring'19 -- START
                        /*component.set("v.questionarioCA.Ora_Evento__c",null);
                        component.set("v.questionarioCA.Ora_recall__c",null);*/
                        //OAVERSANO 08/01/2019 : FIX Spring'19 -- END
                        if(result.questionario.Ambulanza__c!=null)
                        {
                            if(result.questionario.Ambulanza__c=='No')
                                component.set("v.isVisibleNoteAmbulanza",true);
                        }
                        if(result.questionario.Autorit__c!=null)
                        {
                            if(result.questionario.Autorit__c=='No')
                                component.set("v.isVisibleNoteAutorita",true);
                        }
                        if(result.questionario.Carro__c!=null)
                        {
                            if(result.questionario.Carro__c=='Sì')
                                component.set("v.isVisibleNoteCarroattrezzi",true);
                        }
                         console.log("booleano: "+result.questionario.Conducente_contraente__c);
                        if(result.questionario.Conducente_contraente__c!=null)
                        {
                            component.set("v.condUgualeContr",result.questionario.Conducente_contraente__c);
                        }
                          console.log("booleano: "+result.questionario.Conducente_Controparte_contraente__c);
                         if(result.questionario.Conducente_Controparte_contraente__c!=null)
                        {
                            component.set("v.condControparteUgualeContr",result.questionario.Conducente_Controparte_contraente__c);
                        }
                        if(result.questionario.Targa__c !=null)
                        {
                            component.set("v.NonEditTarga",true);
                        }
                    }
                }
                
                component.set('v.isLoading', false);
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                            component.set("v.errorMessage",errors[0].message);
                            component.set("v.isSuccess", false);
                            
                        }
                    } else {
                        console.log("Unknown error");
                        component.set("v.errorMessage","Unknown error");
                        component.set("v.isSuccess", false);
                    }
                    component.set('v.isLoading', false);
                }
        });
        $A.enqueueAction(action);
    },
    
    upsertQuestionarioCA: function(component, event, helper) {
        console.log('upsertQuestionarioCA method');
        component.set("v.questionarioCA.Conducente_contraente__c",component.get("v.condUgualeContr"));
        component.set("v.questionarioCA.Conducente_Controparte_contraente__c",component.get("v.condControparteUgualeContr"));
        component.set("v.questionarioCA.Codice_fiscale_conducente__c", component.get("v.CodiceFiscaleCondContr"));
        component.set("v.questionarioCA.Codice_Fiscale_Controparte_Contr__c", component.get("v.CodiceFiscaleControparteContr"));
        let accountIdToUpdate = component.get("v.accountIdToUpdate");
        var action = component.get("c.upsertQuestionarioCACTRL");
        action.setParams({ "questionario" : component.get("v.questionarioCA"),
                            "nodeCode" : component.get('v.policyNodeCode'),
                          "oraEvento" : component.get("v.oraEvento"),
                          "minutiEvento" : component.get("v.minutiEvento"),
                          "oraRecall" : component.get("v.oraRecall"),
                          "minutiRecall" : component.get("v.minutiRecall"),
                          "accountIdToUpdate" : accountIdToUpdate,
                          "QuestionarioToUpdate" :component.get("v.questionarioCaID"),
                          "NoteHD2" : component.get("v.Note_HD2__c"), // Giorgio Bonifazi - Caring Angel fase 2
                          "Description" : component.get("v.Description__c"), // Giorgio Bonifazi - Caring Angel fase 2
                          "Testimoni" : component.get("v.testimoniList"), //Giorgio Bonifazi CAI DIGITALE
                          "Feriti" :component.get("v.feritiList"), //Giorgio Bonifazi CAI DIGITALE
                          "surveyStatus": JSON.stringify(component.get("v.steps"))
                         });
        component.set('v.isLoading', true);	
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('##State_update: '+state+' #response: '+response.getReturnValue());
            if (state === "SUCCESS") {
                console.log("From server: ",response.getReturnValue());
                let result = response.getReturnValue();
                if(result!=null)
                {
                    //if(result == 'OK')
                    if(result.indexOf('OK')>-1)
                    {
                        this.showToast(component, event, helper, 'success', 'Questionario salvato correttamente');
                        //ZA prima salva per prendere l'id del questionario start
                        if(component.get("v.sinistro")==true){
                        //fix BUG dupplicated questionary order first create then update 20-04-2023
                        this.nuovoSinistro(component,event,helper);
                            component.set("v.sinistro" , false);
                            }
                         //ZA prima salva per prendere l'id del questionario fine
                        component.set("v.successSaveSurvey" , "true");
                                                
                        component.set("v.method","update");
                        
                        if(!component.get("v.questionarioCaID"))
                        //OAVERSANO 04/02/2019 : Caring Angel FIX -- START
                        {
                            component.set("v.questionarioCaID",result.substring('OK|'.length,result.length));
                           // component.set("v.questionarioCA.id",result.substring('OK|'.length,result.length));
                        }
                        //OAVERSANO 04/02/2019 : Caring Angel FIX -- END
                        
                        console.log("questionario id: "+component.get("v.questionarioCaID"));
                        console.log(component.get("v.SaveButtonPressed"));
                    }
                    else if(result.indexOf('KO|Fallito')>-1)
                    {
                        console.log(result.substring('KO|Fallito'.length,result.lenght));
                        this.showToast(component, event, helper, 'error', 'Attenzione ! Si è verificato il seguente errore: ', result.substring('KO|Fallito'.length,result.lenght));                    
                    }
                }
                component.set('v.isLoading', false);
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                            this.showToast(component, event, helper, 'error', 'Attenzione ! Si è verificato il seguente errore: ', errors[0].message); 
                            
                            component.set("v.isSuccess", false);
                            
                        }
                    } else {
                        console.log("Unknown error");
                        component.set("v.errorMessage","Unknown error");
                        component.set("v.isSuccess", false);
                    }
                    component.set('v.isLoading', false);
                }
        });
        $A.enqueueAction(action);
    },
    copiaDatiControparteContraenteInConducente : function(component, event, helper){
        console.log('copiaDatiControparteContraenteInConducente method');
        component.set("v.questionarioCA.Conducente_Controparte_contraente__c",true);
    

    if(component.get("v.questionarioCA.Telefono_controparte__c")!=null){
        component.set("v.questionarioCA.Numero_Cell_Controparte_Contraente__c",component.get("v.questionarioCA.Telefono_controparte__c"));
    }
    else
    {
        component.set("v.questionarioCA.Numero_Cell_Controparte_Contraente__c","");
    }
    
    if(component.get("v.questionarioCA.Nome_controparte__c")!=null){
        component.set("v.questionarioCA.Nome_Controparte_Contr__c",component.get("v.questionarioCA.Nome_controparte__c"));
    }
    else
    {
        component.set("v.questionarioCA.Nome_Controparte_Contr__c","");
    }
    if(component.get("v.questionarioCA.Cognome_Controparte__c")!=null)
    {
        component.set("v.questionarioCA.Cognome_Controparte_Contr__c",component.get("v.questionarioCA.Cognome_Controparte__c"));
    }
    else
    {
        component.set("v.questionarioCA.Cognome_Controparte_Contr__c","");
    }
    if(component.get("v.questionarioCA.Data_di_nascita_controparte__c")!=null)
    {
        component.set("v.questionarioCA.Data_Nascita_Controparte_Contr__c",component.get("v.questionarioCA.Data_di_nascita_controparte__c"));
    }
    else
    {
        component.set("v.questionarioCA.Data_Nascita_Controparte_Contr__c","");
    }
    //Giorgio Bonifazi CAI DIGITALE START
    if(component.get("v.questionarioCA.Provincia_Nascita_Controparte__c")!=null)
    {
        component.set("v.questionarioCA.Provincia_Nascita_Conducente_Contr__c",component.get("v.questionarioCA.Provincia_Nascita_Controparte__c"));
    }
    else
    {
        component.set("v.questionarioCA.Provincia_Nascita_Conducente_Contr__c","");
    }
    if(component.get("v.questionarioCA.Sesso_Controparte__c")!=null)
    {
        component.set("v.questionarioCA.Sesso_Controparte_Contr__c",component.get("v.questionarioCA.Sesso_Controparte__c"));
    }
    else
    {
        component.set("v.questionarioCA.Comune_di_Nascita_Controparte__c","");
    }
    if(component.get("v.questionarioCA.Comune_di_Nascita_Controparte__c")!=null)
    {
        component.set("v.questionarioCA.Luogo_Nascita_Controparte_Contr__c",component.get("v.questionarioCA.Comune_di_Nascita_Controparte__c"));
    }
    else
    {
        component.set("v.questionarioCA.Luogo_Nascita_Controparte_Contr__c","");
    }
    
    if(component.get("v.CodiceFiscaleControparte")!=null)
    {
        component.set("v.questionarioCA.Codice_Fiscale_Controparte_Contr__c",component.get("v.CodiceFiscaleControparte"));
        component.set("v.CodiceFiscaleControparteContr",component.get("v.CodiceFiscaleControparte"));
    }
    //Giorgio Bonifazi CAI DIGITALE END
    else
    {
        component.set("v.questionarioCA.Codice_Fiscale_Controparte_Contr__c","");
    }
    if(component.get("v.questionarioCA.Email_Controparte__c")!=null)
    {
        component.set("v.questionarioCA.Email_Controparte_Contr__c",component.get("v.questionarioCA.Email_Controparte__c"));
    }
    else
    {
        component.set("v.questionarioCA.Email_Controparte_Contr__c","");
    }
    if(component.get("v.questionarioCA.Indirizzo_Controparte__c")!=null)
    {
        component.set("v.questionarioCA.Indirizzo_Res_Controparte_Contr__c",component.get("v.questionarioCA.Indirizzo_Controparte__c"));
    }
    else
    {
        component.set("v.questionarioCA.Indirizzo_Res_Controparte_Contr__c","");
    }
    if(component.get("v.questionarioCA.Citt_Controparte__c")!=null)
    {
        component.set("v.questionarioCA.Citt_Res_Controparte_Contr__c",component.get("v.questionarioCA.Citt_Controparte__c"));
    }
    else
    {
        component.set("v.questionarioCA.Citt_Res_Controparte_Contr__c","");
    }
    if(component.get("v.questionarioCA.Provincia_Controparte__c")!=null)
    {
        component.set("v.questionarioCA.Provincia_Res_Controparte_Contr__c",component.get("v.questionarioCA.Provincia_Controparte__c"));
    }
    else
    {
        component.set("v.questionarioCA.Provincia_Res_Controparte_Contr__c","");
    }
    if(component.get("v.questionarioCA.CAP_Controparte__c")!=null)
    {
        component.set("v.questionarioCA.CAP_Res_Controparte_Contr__c",component.get("v.questionarioCA.CAP_Controparte__c"));
    }
    else
    {
        component.set("v.questionarioCA.CAP_Res_Controparte_Contr__c","");
    }
    if(component.get("v.questionarioCA.Stato_Controparte__c")!=null)
    {
        component.set("v.questionarioCA.Stato_Res_Controparte_Contr__c",component.get("v.questionarioCA.Stato_Controparte__c"));
    }
    else
    {
        component.set("v.questionarioCA.Stato_Res_Controparte_Contr__c","");
    }
    if(component.get("v.questionarioCA.Indirizzo_Domicilio_Controparte__c")!=null)
    {
        component.set("v.questionarioCA.Indirizzo_Dom_Controparte_Contr__c",component.get("v.questionarioCA.Indirizzo_Domicilio_Controparte__c"));
    }
    else
    {
        component.set("v.questionarioCA.Indirizzo_Dom_Controparte_Contr__c","");
    }
    if(component.get("v.questionarioCA.Citt_Domicilio_Controparte__c")!=null)
    {
        component.set("v.questionarioCA.Citt_Dom_Controparte_Contr__c",component.get("v.questionarioCA.Citt_Domicilio_Controparte__c"));
    }
    else
    {
        component.set("v.questionarioCA.Citt_Dom_Controparte_Contr__c","");
    }
    if(component.get("v.questionarioCA.Provincia_Domicilio_Controparte__c")!=null)
    {
        component.set("v.questionarioCA.Provincia_Dom_Controparte_Contr__c",component.get("v.questionarioCA.Provincia_Domicilio_Controparte__c"));
    }
    else
    {
        component.set("v.questionarioCA.Provincia_Dom_Controparte_Contr__c","");
    }	
    if(component.get("v.questionarioCA.CAP_Domicilio_Controparte__c")!=null)
    {
        component.set("v.questionarioCA.CAP_Dom_Controparte_Contr__c",component.get("v.questionarioCA.CAP_Domicilio_Controparte__c"));
    }
    else
    {
        component.set("v.questionarioCA.CAP_Dom_Controparte_Contr__c","");
    }
    if(component.get("v.questionarioCA.Stato_Domicilio_Controparte__c")!=null)
    {
        component.set("v.questionarioCA.Stato_Dom_Controparte_Contr__c",component.get("v.questionarioCA.Stato_Domicilio_Controparte__c"));
    }	
    else
    {
        component.set("v.questionarioCA.Stato_Dom_Controparte_Contr__c","");
    }
    
  

    },
    copiaDatiContraenteInConducente : function(component, event, helper)
    {
        console.log('copiaDatiContraenteInConducente method');
        component.set("v.questionarioCA.Conducente_contraente__c",true);
         /* d.pirelli CAI DIGITALE start*/
        if(component.get("v.questionarioCA.Numero_Cellulare_Contraente__c")!=null){
            component.set("v.questionarioCA.Telefono_conducente__c",component.get("v.questionarioCA.Numero_Cellulare_Contraente__c"));
        }
        else
        {
            component.set("v.questionarioCA.Telefono_conducente__c","");
        }
         /* d.pirelli end*/
        if(component.get("v.questionarioCA.Nome_contraente__c")!=null){
            component.set("v.questionarioCA.Nome_conducente__c",component.get("v.questionarioCA.Nome_contraente__c"));
        }
        else
        {
            component.set("v.questionarioCA.Nome_conducente__c","");
        }
        if(component.get("v.questionarioCA.Cognome_Contraente__c")!=null)
        {
            component.set("v.questionarioCA.Cognome_Conducente__c",component.get("v.questionarioCA.Cognome_Contraente__c"));
        }
        else
        {
            component.set("v.questionarioCA.Cognome_Conducente__c","");
        }
        if(component.get("v.questionarioCA.Data_di_nascita_contraente__c")!=null)
        {
            component.set("v.questionarioCA.Data_di_nascita_conducente__c",component.get("v.questionarioCA.Data_di_nascita_contraente__c"));
        }
        else
        {
            component.set("v.questionarioCA.Data_di_nascita_conducente__c","");
        }
        if(component.get("v.questionarioCA.Codice_fiscale_contraente__c")!=null)
        {
            component.set("v.CodiceFiscaleCondContr",component.get("v.questionarioCA.Codice_fiscale_contraente__c"));
            component.set("v.questionarioCA.Codice_fiscale_conducente__c",component.get("v.questionarioCA.Codice_fiscale_contraente__c"));
        }
        else
        {
            component.set("v.questionarioCA.Codice_fiscale_conducente__c","");
        }
        if(component.get("v.questionarioCA.Email_Contraente__c")!=null)
        {
            component.set("v.questionarioCA.Email_conducente__c",component.get("v.questionarioCA.Email_Contraente__c"));
        }
        else
        {
            component.set("v.questionarioCA.Email_conducente__c","");
        }
        if(component.get("v.questionarioCA.Indirizzo_Contraente__c")!=null)
        {
            component.set("v.questionarioCA.Indirizzo_Conducente__c",component.get("v.questionarioCA.Indirizzo_Contraente__c"));
        }
        else
        {
            component.set("v.questionarioCA.Indirizzo_Conducente__c","");
        }
        if(component.get("v.questionarioCA.Citt_Contraente__c")!=null)
        {
            component.set("v.questionarioCA.Citt_Conducente__c",component.get("v.questionarioCA.Citt_Contraente__c"));
        }
        else
        {
            component.set("v.questionarioCA.Citt_Conducente__c","");
        }
        if(component.get("v.questionarioCA.Provincia_Contraente__c")!=null)
        {
            component.set("v.questionarioCA.Provincia_Conducente__c",component.get("v.questionarioCA.Provincia_Contraente__c"));
        }
        else
        {
            component.set("v.questionarioCA.Provincia_Conducente__c","");
        }
        if(component.get("v.questionarioCA.CAP_Contraente__c")!=null)
        {
            component.set("v.questionarioCA.CAP_Conducente__c",component.get("v.questionarioCA.CAP_Contraente__c"));
        }
        else
        {
            component.set("v.questionarioCA.CAP_Conducente__c","");
        }
        if(component.get("v.questionarioCA.Stato_Contraente__c")!=null)
        {
            component.set("v.questionarioCA.Stato_Conducente__c",component.get("v.questionarioCA.Stato_Contraente__c"));
        }
        else
        {
            component.set("v.questionarioCA.Stato_Conducente__c","");
        }
        if(component.get("v.questionarioCA.Indirizzo_Domicilio_Contraente__c")!=null)
        {
            component.set("v.questionarioCA.Indirizzo_Domicilio_Conducente__c",component.get("v.questionarioCA.Indirizzo_Domicilio_Contraente__c"));
        }
        else
        {
            component.set("v.questionarioCA.Indirizzo_Domicilio_Conducente__c","");
        }
        if(component.get("v.questionarioCA.Citt_Domicilio_Contraente__c")!=null)
        {
            component.set("v.questionarioCA.Citt_Domicilio_Conducente__c",component.get("v.questionarioCA.Citt_Domicilio_Contraente__c"));
        }
        else
        {
            component.set("v.questionarioCA.Citt_Domicilio_Conducente__c","");
        }
        if(component.get("v.questionarioCA.Provincia_Domicilio_Contraente__c")!=null)
        {
            component.set("v.questionarioCA.Provincia_Domicilio_Conducente__c",component.get("v.questionarioCA.Provincia_Domicilio_Contraente__c"));
        }
        else
        {
            component.set("v.questionarioCA.Provincia_Domicilio_Conducente__c","");
        }	
        if(component.get("v.questionarioCA.CAP_Domicilio_Contraente__c")!=null)
        {
            component.set("v.questionarioCA.CAP_Domicilio_Conducente__c",component.get("v.questionarioCA.CAP_Domicilio_Contraente__c"));
        }
        else
        {
            component.set("v.questionarioCA.CAP_Domicilio_Conducente__c","");
        }
        if(component.get("v.questionarioCA.Stato_Domicilio_Contraente__c")!=null)
        {
            component.set("v.questionarioCA.Stato_Domicilio_Conducente__c",component.get("v.questionarioCA.Stato_Domicilio_Contraente__c"));
        }	
        else
        {
            component.set("v.questionarioCA.Stato_Domicilio_Conducente__c","");
        }
        
    },
    populateClientInfo : function(component, event, helper, cliente, persona)
    {
        console.log('populateClientInfo method');
		
        if(!component.get("v.accountId"))
        	component.set("v.accountId",cliente.Id);
        
        component.set("v.personaContr",persona);     
        
        if(cliente.Codice_fiscale_ListView__c!=null)
        {
            component.set("v.questionarioCA.Codice_fiscale_contraente__c",cliente.Codice_fiscale_ListView__c);
        }
        else
        {
            component.set("v.questionarioCA.Codice_fiscale_contraente__c","");
        }
        if(persona == "fisica")
        {
            //Giorgio Bonifazi CAI DIGITALE - START
            if(cliente.Telefono_cellulare_ListView__c!=null)
            {
                component.set("v.questionarioCA.Numero_Cellulare_Contraente__c",cliente.Telefono_cellulare_ListView__c);
            }
            else
            {
                component.set("v.questionarioCA.Numero_Cellulare_Contraente__c","");
            }
            //Giorgio Bonifazi CAI DIGITALE - END
            if(cliente.FirstName!=null)
            {
                component.set("v.questionarioCA.Nome_contraente__c",cliente.FirstName);
            }
            else
            {
                component.set("v.questionarioCA.Nome_contraente__c","");
            }
            if(cliente.LastName!=null)
            {
                component.set("v.questionarioCA.Cognome_Contraente__c",cliente.LastName);
            }
            else
            {
                component.set("v.questionarioCA.Cognome_Contraente__c","");
            }	
            if(cliente.PersonBirthdate!=null)
            {
                component.set("v.questionarioCA.Data_di_nascita_contraente__c",cliente.PersonBirthdate);
            }
            else
            {
                component.set("v.questionarioCA.Data_di_nascita_contraente__c","");
            }
            if(cliente.CIF_PersonEmail__c!=null)
            {
                component.set("v.questionarioCA.Email_Contraente__c",cliente.CIF_PersonEmail__c);
            }
            else
            {
                component.set("v.questionarioCA.Email_Contraente__c","");
            }
            if(cliente.PersonMailingStreet!=null)
            {
                component.set("v.questionarioCA.Indirizzo_Contraente__c",cliente.PersonMailingStreet);  
                component.set("v.questionarioCA.Indirizzo_Domicilio_Contraente__c",cliente.PersonMailingStreet);
            }
            else
            {
                component.set("v.questionarioCA.Indirizzo_Contraente__c","");  
                component.set("v.questionarioCA.Indirizzo_Domicilio_Contraente__c","");
            }
            if(cliente.PersonMailingCity!=null)
            {
                component.set("v.questionarioCA.Citt_Contraente__c",cliente.PersonMailingCity);
                component.set("v.questionarioCA.Citt_Domicilio_Contraente__c",cliente.PersonMailingCity);
            }
            else
            {
                component.set("v.questionarioCA.Citt_Contraente__c","");
                component.set("v.questionarioCA.Citt_Domicilio_Contraente__c","");
            }
            if(cliente.PersonMailingState!=null)
            {
                component.set("v.questionarioCA.Provincia_Contraente__c",cliente.PersonMailingState);
                component.set("v.questionarioCA.Provincia_Domicilio_Contraente__c",cliente.PersonMailingState);
            }
            else
            {
                component.set("v.questionarioCA.Provincia_Contraente__c","");
                component.set("v.questionarioCA.Provincia_Domicilio_Contraente__c","");
            }
            if(cliente.PersonMailingPostalCode!=null)
            {
                component.set("v.questionarioCA.CAP_Contraente__c",cliente.PersonMailingPostalCode);
                component.set("v.questionarioCA.CAP_Domicilio_Contraente__c",cliente.PersonMailingPostalCode);
            }
            else
            {
                component.set("v.questionarioCA.CAP_Contraente__c","");
                component.set("v.questionarioCA.CAP_Domicilio_Contraente__c","");
            }
            if(cliente.PersonMailingCountry!=null)
            {
                component.set("v.questionarioCA.Stato_Contraente__c",cliente.PersonMailingCountry);
                component.set("v.questionarioCA.Stato_Domicilio_Contraente__c",cliente.PersonMailingCountry);
            }
            else
            {
                component.set("v.questionarioCA.Stato_Contraente__c","");
                component.set("v.questionarioCA.Stato_Domicilio_Contraente__c","");
            }
        }
        else if(persona == "giuridica")
        {
             //Giorgio Bonifazi CAI DIGITALE - START
             if(cliente.Telefono_cellulare_ListView__c!=null)
             {
                 component.set("v.questionarioCA.Numero_Cellulare_Contraente__c",cliente.Telefono_cellulare_ListView__c);
             }
             else
             {
                 component.set("v.questionarioCA.Numero_Cellulare_Contraente__c","");
             }
             //Giorgio Bonifazi CAI DIGITALE - END
            if(cliente.Name!=null)
            {	
                component.set("v.questionarioCA.Nome_contraente__c",cliente.Name);
            }
            else
            {
                component.set("v.questionarioCA.Nome_contraente__c","");
            }
            if(cliente.CIF_Personalemail__c!=null)
            {
                component.set("v.questionarioCA.Email_Contraente__c",cliente.CIF_Personalemail__c);
            }
            else
            {
                component.set("v.questionarioCA.Email_Contraente__c","");
            }
            if(cliente.BillingStreet!=null)
            {
                component.set("v.questionarioCA.Indirizzo_Contraente__c",cliente.BillingStreet);
                component.set("v.questionarioCA.Indirizzo_Domicilio_Contraente__c",cliente.BillingStreet);
            }	
            else
            {
                component.set("v.questionarioCA.Indirizzo_Contraente__c","");
                component.set("v.questionarioCA.Indirizzo_Domicilio_Contraente__c","");
            }
            if(cliente.BillingCity!=null)
            {
                component.set("v.questionarioCA.Citt_Contraente__c",cliente.BillingCity);
                component.set("v.questionarioCA.Citt_Domicilio_Contraente__c",cliente.BillingCity);
            }
            else
            {
                component.set("v.questionarioCA.Citt_Contraente__c","");
                component.set("v.questionarioCA.Citt_Domicilio_Contraente__c","");
            }
            if(cliente.BillingState!=null)
            {
                component.set("v.questionarioCA.Provincia_Contraente__c",cliente.BillingState);
                component.set("v.questionarioCA.Provincia_Domicilio_Contraente__c",cliente.BillingState);
            }
            else
            {
                component.set("v.questionarioCA.Provincia_Contraente__c","");
                component.set("v.questionarioCA.Provincia_Domicilio_Contraente__c","");
            }
            if(cliente.BillingPostalCode!=null)
            {
                component.set("v.questionarioCA.CAP_Contraente__c",cliente.BillingPostalCode);
                component.set("v.questionarioCA.CAP_Domicilio_Contraente__c",cliente.BillingPostalCode);
            }
            else
            {
                component.set("v.questionarioCA.CAP_Contraente__c","");
                component.set("v.questionarioCA.CAP_Domicilio_Contraente__c","");
            }
            if(cliente.BillingCountry!=null)
            {
                component.set("v.questionarioCA.Stato_Contraente__c",cliente.BillingCountry);
                component.set("v.questionarioCA.Stato_Domicilio_Contraente__c",cliente.BillingCountry);
            }
            else
            {
                component.set("v.questionarioCA.Stato_Contraente__c","");
                component.set("v.questionarioCA.Stato_Domicilio_Contraente__c","");
            }
        }
        if(cliente.RecordType!=null)
        {
            if(cliente.RecordType.Name!=null)
            {
                if(cliente.RecordType.Name == 'B2C Client' || cliente.RecordType.Name == 'B2B Client')
                {
                    if(cliente.CIF_Phone__c!=null)
                    {
                        component.set("v.questionarioCA.Telefono__c",cliente.CIF_Phone__c);
                    }
                    else
                    {
                        component.set("v.questionarioCA.Telefono__c","");
                    }
                }
                else if(cliente.RecordType.Name == 'Individual')
                {
                    if(cliente.PersonHomePhone!=null)
                    {
                        component.set("v.questionarioCA.Telefono__c",cliente.PersonHomePhone);
                    }
                    else
                    {
                        component.set("v.questionarioCA.Telefono__c","");
                    }
                }
                    else if(cliente.RecordType.Name == 'Corporate')
                    {
                        if(cliente.Phone!=null)
                        {
                            component.set("v.questionarioCA.Telefono__c",cliente.Phone);
                        }
                        else
                        {
                            component.set("v.questionarioCA.Telefono__c","");
                        }
                    }
                 }
        }
    },
    populateCondClientInfo : function(component, event, helper, cliente, persona)
    {
        console.log('populateCondClientInfo method');
        if(cliente.Codice_fiscale_ListView__c!=null)
        {
            component.set("v.questionarioCA.Codice_fiscale_conducente__c",cliente.Codice_fiscale_ListView__c);
        }
        else
        {
            component.set("v.questionarioCA.Codice_fiscale_conducente__c","");
        }
        if(persona == "fisica")
        {
             //Giorgio Bonifazi CAI DIGITALE - START
             if(cliente.Telefono_cellulare_ListView__c!=null)
             {
                 component.set("v.questionarioCA.Numero_Cellulare_Contraente__c",cliente.Telefono_cellulare_ListView__c);
             }
             else
             {
                 component.set("v.questionarioCA.Numero_Cellulare_Contraente__c","");
             }
             //Giorgio Bonifazi CAI DIGITALE - END
            if(cliente.FirstName!=null)
            {
                component.set("v.questionarioCA.Nome_conducente__c",cliente.FirstName);
            }
            else
            {
                component.set("v.questionarioCA.Nome_conducente__c","");
            }
            if(cliente.LastName!=null)
            {
                component.set("v.questionarioCA.Cognome_Conducente__c",cliente.LastName);
            }
            else
            {
                component.set("v.questionarioCA.Cognome_Conducente__c","");
            }
            if(cliente.PersonBirthdate!=null)
            {
                component.set("v.questionarioCA.Data_di_nascita_conducente__c",cliente.PersonBirthdate);
            }
            else
            {
                component.set("v.questionarioCA.Data_di_nascita_conducente__c","");
            }
            if(cliente.CIF_PersonEmail__c!=null)
            {
                component.set("v.questionarioCA.Email_conducente__c",cliente.CIF_PersonEmail__c);
            }
            else
            {
                component.set("v.questionarioCA.Email_conducente__c","");
            }
            if(cliente.PersonMailingStreet!=null)
            {
                component.set("v.questionarioCA.Indirizzo_Conducente__c",cliente.PersonMailingStreet);  
                component.set("v.questionarioCA.Indirizzo_Domicilio_Conducente__c",cliente.PersonMailingStreet);
            }
            else
            {
                component.set("v.questionarioCA.Indirizzo_Conducente__c","");  
                component.set("v.questionarioCA.Indirizzo_Domicilio_Conducente__c","");
            }
            if(cliente.PersonMailingCity!=null)
            {
                component.set("v.questionarioCA.Citt_Conducente__c",cliente.PersonMailingCity);
                component.set("v.questionarioCA.Citt_Domicilio_Conducente__c",cliente.PersonMailingCity);
            }
            else
            {
                component.set("v.questionarioCA.Citt_Conducente__c","");
                component.set("v.questionarioCA.Citt_Domicilio_Conducente__c","");
            }
            if(cliente.PersonMailingState!=null)
            {
                component.set("v.questionarioCA.Provincia_Conducente__c",cliente.PersonMailingState);
                component.set("v.questionarioCA.Provincia_Domicilio_Conducente__c",cliente.PersonMailingState);
            }
            else
            {
                component.set("v.questionarioCA.Provincia_Conducente__c","");
                component.set("v.questionarioCA.Provincia_Domicilio_Conducente__c","");
            }
            if(cliente.PersonMailingPostalCode!=null)
            {
                component.set("v.questionarioCA.CAP_Conducente__c",cliente.PersonMailingPostalCode);
                component.set("v.questionarioCA.CAP_Domicilio_Conducente__c",cliente.PersonMailingPostalCode);
            }
            else
            {
                component.set("v.questionarioCA.CAP_Conducente__c","");
                component.set("v.questionarioCA.CAP_Domicilio_Conducente__c","");
            }
            if(cliente.PersonMailingCountry!=null)
            {
                component.set("v.questionarioCA.Stato_Conducente__c",cliente.PersonMailingCountry);
                component.set("v.questionarioCA.Stato_Domicilio_Conducente__c",cliente.PersonMailingCountry);
            }
            else
            {
                component.set("v.questionarioCA.Stato_Conducente__c","");
                component.set("v.questionarioCA.Stato_Domicilio_Conducente__c","");
            }
        }
        else if(persona == "giuridica")
        {
             //Giorgio Bonifazi CAI DIGITALE - START
             if(cliente.Telefono_cellulare_ListView__c!=null)
             {
                 component.set("v.questionarioCA.Numero_Cellulare_Contraente__c",cliente.Telefono_cellulare_ListView__c);
             }
             else
             {
                 component.set("v.questionarioCA.Numero_Cellulare_Contraente__c","");
             }
             //Giorgio Bonifazi CAI DIGITALE - END
            if(cliente.Name!=null)
            {
                component.set("v.questionarioCA.Nome_conducente__c",cliente.Name);
            }
            else
            {
                component.set("v.questionarioCA.Nome_conducente__c","");
            }
            if(cliente.CIF_Personalemail__c!=null)
            {
                component.set("v.questionarioCA.Email_conducente__c",cliente.CIF_Personalemail__c);
            }
            else
            {
                component.set("v.questionarioCA.Email_conducente__c","");
            }
            if(cliente.BillingStreet!=null)
            {
                component.set("v.questionarioCA.Indirizzo_Conducente__c",cliente.BillingStreet);
                component.set("v.questionarioCA.Indirizzo_Domicilio_Conducente__c",cliente.BillingStreet);
            }
            else
            {
                component.set("v.questionarioCA.Indirizzo_Conducente__c","");
                component.set("v.questionarioCA.Indirizzo_Domicilio_Conducente__c","");
            }	
            if(cliente.BillingCity!=null)
            {
                component.set("v.questionarioCA.Citt_Conducente__c",cliente.BillingCity);
                component.set("v.questionarioCA.Citt_Domicilio_Conducente__c",cliente.BillingCity);
            }
            else
            {
                component.set("v.questionarioCA.Citt_Conducente__c","");
                component.set("v.questionarioCA.Citt_Domicilio_Conducente__c","");
            }
            if(cliente.BillingState!=null)
            {
                component.set("v.questionarioCA.Provincia_Conducente__c",cliente.BillingState);
                component.set("v.questionarioCA.Provincia_Domicilio_Conducente__c",cliente.BillingState);
            }
            else
            {
                component.set("v.questionarioCA.Provincia_Conducente__c","");
                component.set("v.questionarioCA.Provincia_Domicilio_Conducente__c","");
            }	
            if(cliente.BillingPostalCode!=null)
            {
                component.set("v.questionarioCA.CAP_Conducente__c",cliente.BillingPostalCode);
                component.set("v.questionarioCA.CAP_Domicilio_Conducente__c",cliente.BillingPostalCode);
            }
            else
            {
                component.set("v.questionarioCA.CAP_Conducente__c","");
                component.set("v.questionarioCA.CAP_Domicilio_Conducente__c","");
            }
            if(cliente.BillingCountry!=null)
            {
                component.set("v.questionarioCA.Stato_Conducente__c",cliente.BillingCountry);
                component.set("v.questionarioCA.Stato_Domicilio_Conducente__c",cliente.BillingCountry);
            }
            else
            {
                component.set("v.questionarioCA.Stato_Conducente__c","");
                component.set("v.questionarioCA.Stato_Domicilio_Conducente__c","");
            }
        }
    },   
    showToast : function(component, event, helper, type, message, detailsMessage) 
    {
        console.log('showToast method');
        component.set("v.messageToast", message);
        component.set("v.DetailsMessageToast", detailsMessage)
        component.set("v.typeToast", type);
        component.set("v.showToast",true);
        var self = this;
        
        if(type!='error' && type!='warning')
        {
            window.setTimeout(
                $A.getCallback(function() {
                    component.set("v.messageToast", "");
                    component.set("v.typeToast", "");
                    component.set("v.showToast",false);
                    
                    if(component.get("v.SaveButtonPressed")=="Fine")
                    {
                        console.log('Close');
                        
                        self.closeQuestionario(component,event,helper);
                        component.set("v.SaveButtonPressed","");
                    }
                    //MMOSCATELLI 23/11/2018 : Caring Angel Enhancement -- START
                    else if(component.get("v.RecordsDeleted"))
                    {                    
                        var myEvent = $A.get("e.c:tabclosing");
                        myEvent.setParams({"data":"cancel",
                                           "recordid":'',
                                           "Url":''});
                        myEvent.fire();
                    }
                    //MMOSCATELLI 23/11/2018 : Caring Angel Enhancement -- START   
                }), 1000
            );
        }
    },
    convertToString : function(component, event, helper, ms, delim ) {
       	/*const showWith0 = value => (value < 10 ? `0${value}` : value);
        const hours = showWith0(Math.floor((ms / (1000 * 60 * 60)) % 60));
        const minutes = showWith0(Math.floor((ms / (1000 * 60)) % 60));
        const seconds = showWith0(Math.floor((ms / 1000) % 60));
        return `${parseInt(hours) ? `${hours}${delim}` : ""}${minutes}${delim}${seconds}`;*/
		var hours = Math.floor((ms / (1000 * 60 * 60)) % 60);
		var minutes = Math.floor((ms / (1000 * 60)) % 60);
		if(hours<10)
			hours = '0'+hours;
		if(minutes<10)
			minutes = '0'+minutes;
		return hours+delim+minutes;
    },
    nuovoSinistro : function(component,event,helper){
        console.log("nuovoSinistro_helper");
        console.log("caseId: "+component.get("v.caseId"));
        
        let caseId = component.get("v.caseId");
        if(caseId== null || caseId=='')
            caseId  = component.get("v.questionarioCA.Case__c");
        console.log('caseId: ',caseId);
        
        var action = component.get("c.OpenNewClaim");
        var dataEvento = component.get("v.questionarioCA.Data_Evento__c");
        var NumeroPolizza = component.get("v.questionarioCA.Numero_Polizza__c"); 
        
        if(!dataEvento || !NumeroPolizza)
        {
            this.showToast(component, event, helper, 'error', 'Attenzione, per procedere con l\'operazione richiesta è necessario indicare la data dell\'evento e selezionare la polizza del contraente');                    
        }
        else
        {
        	let questionnaireID;
        	if(component.get("v.questionarioCaID")!=null)
        	{
        		console.log('Classic openNewClaim');
        		questionnaireID = component.get("v.questionarioCaID");
        	}
        	else if(component.get("v.recordId")!=null)
        	{
        		console.log('Lightning openNewClaim');
        		questionnaireID = component.get("v.recordId");
        	}
            console.log('questionarioCA: ',component.get("v.questionarioCA"));
            console.log('caseId: ',component.get("v.caseId"));
            console.log('questionnaireID: ',questionnaireID);
            action.setParams({"theQuestionnaire" : component.get("v.questionarioCA"),
                              "theCase": component.get("v.caseId"),
                              "theQuestionnaireID": questionnaireID});
            component.set("v.AlreadyOpened",true);
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    console.log("From server: ",response.getReturnValue());
                    var result = response.getReturnValue();
                    
                    if(result!=null)
                    {
                        if(result.isSuccess)
                        {
                            console.log('url sol: '+result.Url);
                            //OAVERSANO 05/12/2018 : FIX -- START
                            console.log('questId',result.QuestId);
                            component.set("v.questionarioCaID", result.QuestId);
                            component.set("v.questionarioCA.Id", result.QuestId);
                            component.set("v.AlreadyOpened",false);
                            //OAVERSANO 05/12/2018 : FIX -- END
                            //component.set("v.AlreadyOpened",result.isSuccess);
                            //this.showToast(component, event, helper, 'success', 'Questionario salvato correttamente');
                            //component.set("v.method","update");
                            
                            var idCaseLightning = component.get("v.recordId");
                            
                            if(idCaseLightning!='' && idCaseLightning!=null)
                            {
                                /*var workspaceAPI = component.find("workspace");
                                workspaceAPI.getEnclosingTabId().then(function(tabId) {
                                    workspaceAPI.openSubtab({
                                        parentTabId: tabId,
                                        url: result.Url,
                                        focus: true
                                    });
                                })
                                .catch(function(error) {
                                    console.log(error);
                                });*/
                                window.open(result.Url, '_blank');
                            }
                            else
                            {
                                var myEvent = $A.get("e.c:tabclosing");
                                myEvent.setParams({"data":"openInSOL",
                                                   "recordid":'',
                                                   "Url":result.Url});
                                myEvent.fire();
                            }
                        }
                        else
                        {
                            console.log('Errore SOL: '+result.Error);
                            this.showToast(component, event, helper, 'error', 'Il sistema SOL non è al momento raggiungibile, ti chiediamo di riprovare più tardi. Se il problema persiste contatta il tuo referente AXA');                    
                        }
                    }
                    component.set('v.isLoading', false);
                }
                else if (state === "INCOMPLETE") {
                    // do something
                }
                    else if (state === "ERROR") {
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                console.log("Error message: " + 
                                            errors[0].message);
                                this.showToast(component, event, helper, 'error', 'Il sistema SOL non è al momento raggiungibile, ti chiediamo di riprovare più tardi. Se il problema persiste contatta il tuo referente AXA'); 
                                
                                component.set("v.isSuccess", false);
                                
                            }
                        } else {
                            console.log("Unknown error");
                            component.set("v.errorMessage","Unknown error");
                            component.set("v.isSuccess", false);
                        }
                        component.set('v.isLoading', false);
                    }
            });
            $A.enqueueAction(action);
        }       
    },
    chiudiTab : function(component,event,helper){
        var myEvent = $A.get("e.c:tabclosing");
        myEvent.setParams({"data":"cancel",
                           "recordid":'',
                           "Url":''});
        myEvent.fire();
    },
    chiudiModalfindAssociateClient : function(component, event, helper)
    {
        component.set("v.findClientModal" , false);
    },
    closeQuestionario : function(component,event,helper){
        var idquestionario = component.get("v.recordId");
        console.log('closeQuestionario_START');
        
        if(idquestionario!='' && idquestionario!=null)
        {
            var workspaceAPI = component.find("workspace");
            workspaceAPI.getFocusedTabInfo().then(function(response) {
                var focusedTabId = response.tabId;
                console.log('response:'+response);
                workspaceAPI.closeTab({tabId: focusedTabId});
                workspaceAPI.openSubtab({
                    parentTabId: focusedTabId,
                    url: '/lightning/r/Questionario_CA__c/'+idquestionario+'/view',
                    focus: true
                });
            })
            .catch(function(error) {
                console.log(error);
            });
        }
        else
        {
            var myEvent = $A.get("e.c:tabclosing");
            myEvent.setParams({"data":"close_questionario",
                               "recordid":component.get("v.questionarioCaID"),
                               "Url":''});
            myEvent.fire();
        }
    },
    //MOSCATELLI_M 16/11/2018: Caring Angel CR -- START
    generaLuogoEvento : function(component,event,helper)
    {
        console.log("generaLuogoEvento START");
        var cittaEvento = component.get("v.questionarioCA.Citt_Evento__c"); 
        var IndirizzoEvento = component.get("v.questionarioCA.Indirizzo_Evento__c"); 
        var CAPEvento = component.get("v.questionarioCA.CAP_Evento__c"); 
        var ProvinciaEvento = component.get("v.questionarioCA.Provincia_Evento__c"); 
        var StatoEvento = component.get("v.questionarioCA.Stato_Evento__c");
        var Luogo ='';
        
        if(StatoEvento)
            Luogo = StatoEvento;
        
        if(ProvinciaEvento)
        {
            if(Luogo)
                Luogo = Luogo+','+ProvinciaEvento;
            else
                Luogo = ProvinciaEvento;
        }
        
        if(cittaEvento)
        {
            if(Luogo)
                Luogo = Luogo+','+cittaEvento;
            else
                Luogo = cittaEvento;
        }
        
        if(CAPEvento)
        {
            if(Luogo)
                Luogo = Luogo+','+CAPEvento;
            else
                Luogo = CAPEvento;
        }        
        
        if(Luogo)
            component.set("v.questionarioCA.Luogo_Evento__c",Luogo); 
        
        console.log('##Luogo: '+component.get("v.questionarioCA.Luogo_Evento__c"));
    },

    deleteRecords: function(component,event,helper,idCaseLightning,idQuestionario){
        var action = component.get("c.eraseRecords");

        action.setParams({ "CaseId": idCaseLightning,
                            "QuestionarioId": idQuestionario
                         });

        action.setCallback(this, function(response) 
        {
            var state = response.getState();

            if (state === "SUCCESS")
            {
                var result = response.getReturnValue();

                if(result!=null)
                {
                    console.log('##Result: ',result);

                    if(result.isSuccess)
                    {
                        component.set("v.RecordsDeleted",true);
                        var self = this;
                        self.showToast(component,event,helper,'success',result.Msg);
                    }
                    else
                    {
                        var self = this;
                        self.showToast(component,event,helper,'error',result.Msg);
                    }
                }
            }
            else if (state === "INCOMPLETE")
            {
                var self = this;
                self.showToast(component,event,helper,'error','La funzionalità non è al momento disponibile. Contatta l\'Amministratore di sistema');

            }
            else if (state === "ERROR")
            {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) 
                    {
                        console.log("Error message: " +errors[0].message);                                
                    }
                } 
                else
                {
                    console.log("Unknown error");
                }
                var self = this;
                self.showToast(component,event,helper,'error','La funzionalità non è al momento disponibile. Contatta l\'Amministratore di sistema');
            }
        });
       $A.enqueueAction(action);
    },
    //MOSCATELLI_M 16/11/2018: Caring Angel CR -- END

    // Giorgio Bonifazi 23/07/2019 : Caring Angel fase 2 - START -->
    
    startSpinner: function (cmp) {
        var spinner = cmp.find("mySpinner");
        $A.util.removeClass(spinner, 'slds-hide');
        //console.log("SPINNER START");
    },
    stopSpinner: function (cmp) {
        var spinner = cmp.find("mySpinner");
        $A.util.addClass(spinner, 'slds-hide'); 
    },
    // Giorgio Bonifazi 23/07/2019 : Caring Angel fase 2 - END -->  
    initializeTestimoni : function(component, event, helper){

        var questionarioCAid = component.get("v.questionarioCaID");
        var action = component.get("c.initializeTestimoniCTRL");
        action.setParams({"questionarioCAid" : questionarioCAid});

                          action.setCallback(this,function(response){
                            var state = response.getState();
                            if (state === "SUCCESS") {
                            
                            var testimoni = response.getReturnValue();
                            component.set("v.testimoniList",testimoni);

                                            

                            }
                            else if (state === "ERROR") {
                                var errors = response.getError();
                                    if (errors) {
                                        if (errors[0] && errors[0].message) {
                                                console.log("Error message: " +errors[0].message);                                
                                        }
                                    } 
                                }
                                
                        });
                        $A.enqueueAction(action);

    },    

    initializeFeriti : function(component, event, helper){

        var questionarioCAid = component.get("v.questionarioCaID");
        var action = component.get("c.initializeFeritiCTRL");
        action.setParams({"questionarioCAid" : questionarioCAid});

                          action.setCallback(this,function(response){
                            var state = response.getState();
                            if (state === "SUCCESS") {
                            
                            var testimoni = response.getReturnValue();
                            component.set("v.feritiList",testimoni);

                            

                            }
                            else if (state === "ERROR") {
                                var errors = response.getError();
                                    if (errors) {
                                        if (errors[0] && errors[0].message) {
                                                console.log("Error message: " +errors[0].message);                                
                                        }
                                    } 
                                }
                                
                        });
                        $A.enqueueAction(action);
    },
    setProgressBar: function(component, event, helper,action,pagePrev, pageNext){
     var progressBar = component.get("v.steps");   
       
      var  toBeCurr;   
         switch (pageNext) {           
                  case "v.isVisibleSTEP1":
                      toBeCurr = "STEP2";
                      break;
                  case "v.isVisibleSTEP2":
                      toBeCurr = "STEP1";
                      break;
                  case "v.isVisibleSTEP3":
                      toBeCurr = "STEP2";
                      break;
                  case "v.isVisibleSTEP4":
                      toBeCurr = "STEP3";
                      break;
                  case "v.isVisibleSTEP5":
                      toBeCurr = "STEP3";
                      break;
                  case "v.isVisibleSTEP6":
                      toBeCurr = "STEP4";
                      break;
                  case "v.isVisibleSTEP7":
                      toBeCurr = "STEP4";
                      break;
                  case "v.isVisibleSTEP8":
                      toBeCurr = "STEP5";
                      break;
                  case "v.isVisibleSTEP9":
                      toBeCurr = "STEP6";
                     break;
                 }
        
            var  toBeCompleted ='' ; 
           
            //calculate curr step to be completed
           switch (pagePrev) {           
              case "v.isVisibleSTEP2":
                toBeCompleted = "STEP1";
                break;
              case "v.isVisibleSTEP3":
                 toBeCompleted = "STEP2";
                break;
              case "v.isVisibleSTEP5":
                toBeCompleted = "STEP3";
                break;
              case "v.isVisibleSTEP7":
              toBeCompleted = "STEP4"; 
              break;            
               case "v.isVisibleSTEP8":
                toBeCompleted = "STEP5";
                break; 
              case "v.isVisibleSTEP9":
                toBeCompleted = "STEP6";
                break; 
           }

           toBeCompleted =  (pagePrev == 'v.isVisibleSTEP6' && component.get("v.questionarioCA.Presenza_Testimoni__c") != 'Sì' ) ? "STEP4" : toBeCompleted;
        
          var  prevStepActionPrev =''; 
           
            //calculate curr step to be completed
           switch (pagePrev) {           
              case "v.isVisibleSTEP2":
                prevStepActionPrev = "STEP1";
                break;
              case "v.isVisibleSTEP1":
                 prevStepActionPrev = "STEP2";
                break;
              case "v.isVisibleSTEP4":
                prevStepActionPrev = "STEP3";
                break;            
              case "v.isVisibleSTEP6":
                prevStepActionPrev = "STEP4";
                break; 
              case "v.isVisibleSTEP8":
                prevStepActionPrev = "STEP5";
                break; 
              case "v.isVisibleSTEP9":
                prevStepActionPrev = "STEP6";
                break; 
           }
           
           prevStepActionPrev =  (pagePrev == 'v.isVisibleSTEP7' && component.get("v.questionarioCA.Feriti__c") != 'Sì' ) ? "STEP4" : prevStepActionPrev;
        
     
        if(action=="next"){ 
            
            progressBar.forEach(function(item) {
                if(item.value==toBeCompleted){
                    item.isCurr='N';
                    item.completed='Y';
                }
                
            }); 
            
            progressBar.forEach(function(item) {            
                if(item.value==toBeCurr){
                    item.isCurr='Y';                   
                }
                
            });
            
            
        }  else if(action=="previous"){ 
            console.log("previous");
            progressBar.forEach(function(item) {            
                if(item.value==toBeCurr){
                    item.isCurr='Y';                   
                }
                
                if(item.value==prevStepActionPrev){
                    item.isCurr='N';  
                    item.completed='Y';                
                }
                
            });
            
        }
        
      
            
           console.log("progress bar" , progressBar);
           component.set("v.steps",progressBar);
            
    },
     validateFiscalCode : function (component, cf){      
         console.log("*** validate CF: " + cf);
         var reg_ex = new RegExp ( component.get("v.patternFiscalCode"));         
         
         if (typeof  cf == "undefined" || cf == "") {
             return true;
         }else{  
             return reg_ex.test(cf);
         }     
    },
      validateMail : function(component, regEx, email) {  
        console.log("*** validateMail email: " + email);
        var reg_ex = component.get("v.regEx");
        console.log("*** validateMail - reg_ex[" + regEx + "]: " + reg_ex[regEx]);	
        var emailFilter = new RegExp(reg_ex[regEx]);
        if (typeof  email == "undefined" || email == "") {
            return true;
        }else{  
            return emailFilter.test(email);
        } 
    },
    validatePhone : function(component, regEx, phone_number) { 
        console.log("*** validatePhone phone_number: " + phone_number);
        var reg_ex = component.get("v.regEx");
        console.log("*** validatePhone - reg_ex[" + regEx + "]: " + reg_ex[regEx]);	
        var phoneFilter = new RegExp(reg_ex[regEx]);
        if (typeof  phone_number == "undefined" || phone_number == "") {
            return true;
        } else {  
            return phoneFilter.test(phone_number);
        }
    },
    validatePhoneFiscalCodeEmail : function (component, phone, cf, email){
        
      var check_email= this.validateMail(component, 'Email_RegEx', email);
      var check_phone = this.validatePhone(component, 'Generic_Phone_RegEx', phone) || this.validatePhone(component, 'National_Mobile_Phone_RegEx', phone); 
      var check_cf = this.validateFiscalCode(component, cf); 
        console.log('check_email '+check_email); 
        console.log('check_phone '+check_phone); 
         console.log('check_phone '+check_cf); 
        return check_email  && check_phone && check_cf;
   
    },
   
         
    
 
    
    checkValidate: function(component, event, helper,page){
  
        if(page =="v.isVisibleSTEP1"){          
            let phone = component.get('v.questionarioCA.Numero_Cellulare_Contraente__c') ;
            let email = component.get('v.questionarioCA.Email_Contraente__c');
            let cf=  component.get("v.personaContr")=='fisica' ? component.get('v.questionarioCA.Codice_fiscale_contraente__c') : '';
              
            
            return this.validatePhoneFiscalCodeEmail(component,phone,cf,email);
            
        }
        
        if(page =="v.isVisibleSTEP2"){           
            
            let phone = component.get("v.questionarioCA.Telefono__c") ; 
            let email = component.get("v.questionarioCA.Email__c") ; 
            
            return this.validatePhoneFiscalCodeEmail(component,phone,'',email);
        }
        if(page =="v.isVisibleSTEP3"){
            let phone = component.get('v.questionarioCA.Telefono_conducente__c') 
            let cf  = component.get('v.CodiceFiscaleCondContr');
            let email  = component.get('v.questionarioCA.Email_conducente__c');
            
            return this.validatePhoneFiscalCodeEmail(component,phone,cf,email);            
        }
        
        if(page =="v.isVisibleSTEP4"){
            let phone = component.get('v.questionarioCA.Telefono_controparte__c') ;
            let cf  = component.get('v.CodiceFiscaleControparte');
            let email  = component.get('v.questionarioCA.Email_Controparte__c');           
            
            return this.validatePhoneFiscalCodeEmail(component,phone,cf,email);   
            
        }   
        
        if(page =="v.isVisibleSTEP5"){
            let phone = component.get('v.questionarioCA.Numero_Cell_Controparte_Contraente__c') ;
            let cf    = component.get('v.CodiceFiscaleControparteContr') ;
            let email = component.get('v.questionarioCA.Email_Controparte_Contr__c');
            
            return this.validatePhoneFiscalCodeEmail(component,phone,cf,email);               
        }   
        
        if(page =="v.isVisibleSTEP6"){
            let feritiList= component.get("v.feritiList");
            console.log('** feriti precheck ',feritiList );
            var isValid = true;
            
            for (var indexVar = 0; indexVar < feritiList.length; indexVar++) {
                let email = feritiList[indexVar].Email__c ;
                let phone = feritiList[indexVar].Telefono__c ;
                isValid = this.validatePhoneFiscalCodeEmail(component,phone,'',email);   
                
                if (!isValid) break;
            }
            return isValid;
        }  
        
        if(page =="v.isVisibleSTEP7"){
            let testimoniList= component.get("v.testimoniList");
            console.log('** testimoniList precheck ',testimoniList );
            var isValid = true;
            
            for (var indexVar = 0; indexVar < testimoniList.length; indexVar++) {
                
                let phone = testimoniList[indexVar].Telefono__c ;
                isValid = this.validatePhoneFiscalCodeEmail(component,phone,'','');   
                
                if (!isValid) break;                  
                
            }
            return isValid;
        }     
        
        
        
        return true;  
    },

    setCurrentPath:function(component,helper,surveyStatus){
        
        var steps  = JSON.parse(surveyStatus);
       
        var profiloCorrente = component.get("v.UsrProfile");
             if(profiloCorrente =="Caring Angel - Supervisor" || profiloCorrente == "Caring Angel - Supporto HD2" || profiloCorrente =="Caring Angel - Supporto HD2 Supervisor" )       
             {  
                 steps.forEach(function(item) {
                     if(item.value== 'STEP6')
                         item.hide='Y';              
                 }); 
             }     
                    

        let foundIncompleted=  steps.filter(function(item) {return (item.completed=== 'N'  && item.hide=='N'); });
     
         if(foundIncompleted.length>0){                 
             let foundCurr=  steps.filter(function(item) { return item.isCurr=== 'Y'; });                   
                if(foundCurr.length>0){                     

                 steps.forEach(function(item) {            
                     if(item.value==foundCurr[0].value){
                         item.isCurr='N';                   
                     }  
                 });       

                }
                steps.forEach(function(item) {            
                 if(item.value==foundIncompleted[0].value){
                     item.isCurr='Y';                   
                 }  });
         }else{
             let foundCurr=  steps.filter(function(item) { return item.isCurr=== 'Y'; });
             if(foundCurr.length>0){
              steps.forEach(function(item) {            
                  if(item.value==foundCurr[0].value){
                      item.isCurr='N';                   
                  }  
              });
              
            
                 if(profiloCorrente =="Caring Angel - Supervisor" || profiloCorrente == "Caring Angel - Supporto HD2" || profiloCorrente =="Caring Angel - Supporto HD2 Supervisor" )       
                 { steps[(steps.length)-1].isCurr='Y';
                   steps[(steps.length)-1].hide='N';
                 }
                 else {
                     steps[(steps.length)-2].isCurr='Y';
                     steps[(steps.length)-1].hide='Y';                       
                 }
                 
         }          
         
          
    }
      
        
         component.set("v.steps",steps);
         return steps;
},
    
setCurrentPage:function(component,helper,surveyStatus,presenzaFeriti,presenzaTestimoni){
    let steps = surveyStatus;
    let foundCurr=  steps.filter(function(item) { return item.isCurr=== 'Y'; });
    if(foundCurr.length>0){
    component.set("v.isVisibleSTEP2",false);
    let toBeCurr;
    
       if(foundCurr[0].value=='STEP4'){
           if(component.get("v.questionarioCA.Feriti__c") == 'Sì')
                     toBeCurr = "v.isVisibleSTEP6";
                     else if(component.get("v.questionarioCA.Presenza_Testimoni__c")== 'Sì')
                          toBeCurr = "v.isVisibleSTEP7";

       }else{
        switch (foundCurr[0].value) {           
            case "STEP2":
                toBeCurr = "v.isVisibleSTEP1";
                break;
            case "STEP1":
                toBeCurr = "v.isVisibleSTEP2";
                break;       
            case "STEP3":
                toBeCurr = "v.isVisibleSTEP4";
                break;    
            case "STEP5":
                toBeCurr = "v.isVisibleSTEP8";
                break;
            case "STEP6":
                toBeCurr = "v.isVisibleSTEP9";
               break;
           }
       }

     component.set(toBeCurr, true);
     component.set("v.IndexPathCurr", toBeCurr);
     //setarre index e order page

     
     var listSortPage=component.get("v.sortOrderPage");
        
     if (presenzaFeriti=='Sì'){
         if(listSortPage.indexOf("v.isVisibleSTEP5")!=-1){           
             listSortPage.splice(listSortPage.indexOf("v.isVisibleSTEP5")+1, 0, "v.isVisibleSTEP6");//add page next v.isVisibleSTEP5
             
         }else{
             listSortPage.push("v.isVisibleSTEP6"); //add page at end
         }   
    }

    if (presenzaTestimoni=='Sì'){
        if(listSortPage.indexOf("v.isVisibleSTEP6")!=-1){           
            listSortPage.splice(listSortPage.indexOf("v.isVisibleSTEP6")+1, 0, "v.isVisibleSTEP7");//add page next v.isVisibleSTEP6
                       
        }else if(listSortPage.indexOf("v.isVisibleSTEP5")!=-1) {
            listSortPage.splice(listSortPage.indexOf("v.isVisibleSTEP5")+1, 0, "v.isVisibleSTEP7");//add page next v.isVisibleSTEP8            
        }else             
            listSortPage.push("v.isVisibleSTEP7"); //add page at end
    
   }
    component.set("v.sortOrderPage",listSortPage);
    let index = listSortPage.indexOf(toBeCurr);
    component.set("v.IndexCurrPage",index);
         
      }
    },
   
    setHideStepPath : function (component,step, visibility)
    {
        var steps=  component.get("v.steps");
        steps.forEach(function(item) {
            if(item.value== step)
                item.hide=visibility;              
        });             
        component.set("v.steps", steps); 
        
    },
    
    sortByProperty : function (property) {
    return function (x, y) {
        return ((x[property] === y[property]) ? 0 : ((x[property] > y[property]) ? 1 : -1));
    };
},
    getListOfRegularExpressions : function(component) {
        console.log('*** getListOfRegularExpressions');
        var action = component.get("c.getListOfRegularExpressions");
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('*** getListOfRegularExpressions - state: ' + state);
            if (state === "SUCCESS") {
                var response = response.getReturnValue();
                console.log("*** getListOfRegularExpressions - From server: " + JSON.stringify(response));    
                var validations = {};
                for (var i = 0; i < response.length; i++) {
					validations[response[i].QualifiedApiName] = response[i].RegEx__c;
                }
                component.set("v.regEx", validations);
                var checkPhone = validations['National_Mobile_Phone_RegEx'] +'|'+ validations['Generic_Phone_RegEx'] ;
                 component.set("v.patternPhone", checkPhone);
                 component.set("v.patternEmail", validations['Email_RegEx']);
                
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("*** getListOfRegularExpressions - Error message: " + errors[0].message);
                        var validations = {};
                        component.set("v.regEx", validations);
                    }
                } else {
                    console.log("getListOfRegularExpressions - Unknown error");
                    var validations = {};
                    component.set("v.regEx", validations);
                }
            }
        });
        $A.enqueueAction(action);
    },
    checkPolicyType : function(component,policynum,helper){
        console.log("policynum: "+policynum);
        var action = component.get("c.VerifyPolicy");
        
        action.setParams({ "PolicyNumber":  policynum});

        action.setCallback(this, function(response) 
        {
            var state = response.getState();

            if (state === "SUCCESS")
            {
                var result = response.getReturnValue();
                if(result)
                    component.set("v.AlreadyOpened",true);      
                else
                    component.set("v.AlreadyOpened",false);
                    
            }
            else if (state === "INCOMPLETE")
            {
                var self = this;
                self.showToast(component,event,helper,'error','La funzionalità non è al momento disponibile. Contatta l\'Amministratore di sistema');
            }
            else if (state === "ERROR")
            {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) 
                    {
                        console.log("Error message: " +errors[0].message);                                
                    }
                } 
                else
                {
                    console.log("Unknown error");
                }
                var self = this;
                self.showToast(component,event,helper,'error','La funzionalità non è al momento disponibile. Contatta l\'Amministratore di sistema');
            }
        });
       $A.enqueueAction(action);
    },
    //ZA prima salva per prendere l'id del questionario
    preControlloSalva : function (component, event, helper)
    {
        if(component.get("v.questionarioCA.Presenza_Testimoni__c") == "No" || component.get("v.questionarioCA.Presenza_Testimoni__c") == ""){  
   
        component.set("v.testimoniList",[]);
        
        }   

        if(component.get("v.questionarioCA.Feriti__c")=="No"||component.get("v.questionarioCA.Feriti__c")==""){

            component.set("v.feritiList",[]);
        
        }
        //Giorgio Bonifazi CAI DIGITALE START
        var arraytestimoni = component.get("v.testimoniList");
        var arrayferiti = component.get("v.feritiList");
        var newArrayTestimoni=arraytestimoni.filter(function(el) {
            
            if(!el.Nome__c || !el.Cognome__c ){
                
                return true;
            }
            
                return false;
        }).length;
        var newArrayFeriti = arrayferiti.filter(function(el) {
            
            if(!el.Nome__c || !el.Cognome__c ){
                
                return true;
            }
            
                return false;
        }).length;
        if(newArrayTestimoni>0){

            helper.showToast(component, event, helper, 'error', 'Attenzione ! Inserire il Nome e il Cognome per i Testimoni / Feriti');
            return;
        }else if(newArrayFeriti>0){
            helper.showToast(component, event, helper, 'error', 'Attenzione ! Inserire il Nome e il Cognome per i Testimoni / Feriti');
            return;
        }
        
        else{
            var newArrayTestimoniNoEmpty = arraytestimoni.filter(function(el){

                return Object.keys(el)
                    .filter(function(el){
                        return el !== 'sobjectType'
                    })
                    .reduce(function(previous,current){
    
                        return previous || el[current]
                },false)
    
            });
            component.set("v.testimoniList",newArrayTestimoniNoEmpty);
    
            
            var newArrayFeritiNoEmpty = arrayferiti.filter(function(el){
    
                return Object.keys(el)
                    .filter(function(el){
                        return el !== 'sobjectType'
                    })
                    .reduce(function(previous,current){
    
                        return previous || el[current]
                },false)
    
            });
            component.set("v.feritiList",newArrayFeritiNoEmpty);}
        console.log('salvaQuestionario method');
        component.set("v.SaveButtonPressed","Salva");
        component.set("v.questionarioCA.Codice_fiscale_controparte__c",component.get("v.CodiceFiscaleControparte"));
        console.log("Codice Fiscale Controparte: " + component.get("v.questionarioCA.codice_fiscale_controparte__c"));
        console.log("Flag:\n"+component.get("v.questionarioCA.Conducente_contraente__c")+'\n'+component.get("v.questionarioCA.Conducente_Controparte_contraente__c")); 
        
    }
    
})