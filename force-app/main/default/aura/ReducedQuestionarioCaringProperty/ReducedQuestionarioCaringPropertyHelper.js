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
                          "questionarioCAid" : questionarioCAid,
                          "caseId" : component.get("v.caseId")
                          });
        component.set('v.isLoading', true);	
        action.setCallback(this, function(response) {
            var state = response.getState();
            component.set("v.CATypeBoolean",true);
            if (state === "SUCCESS") {
                console.log("From server CA: ",response.getReturnValue());
                var result = response.getReturnValue();
                if(result!=null)
                {
                    component.set("v.ShowLess",result.showLess);
                    console.log("ShowLess: "+component.get("v.ShowLess"));
                    console.log("profilo corrente : "+result.profileName);
                    component.set("v.isHD2", result.profileName.includes('HD2') || result.profileName.includes('Admin'))
                    if(result.pickValues!=null)
                    {
                        let pickResults = result.pickValues;
                        var picklistMap = component.get("v.picklistMap");
                        for(var key in pickResults){
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
                        component.set("v.questionarioCA",result.questionario);
                        component.set("v.AlreadyOpened",result.questionario.Sinistro_aperto_su_SOL__c);
                        if(result.questionario.Ora_Evento__c!=null )
                        {
                        	console.log('result.questionario.Ora_Evento__: ',result.questionario.Ora_Evento__c);
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
        let accountIdToUpdate = component.get("v.accountIdToUpdate");
        console.log(component.get("v.accountIdToUpdate"));
        console.log(component.get("v.oraEvento"));
        console.log(component.get("v.minutiEvento"));
        console.log(component.get("v.oraRecall"));
        console.log(component.get("v.minutiRecall"));
        console.log(component.get("v.questionarioCaID"));
        
       var checkCf= false;
        if(component.get("v.personaContr") != 'fisica' ||  (typeof  component.get("v.questionarioCA.Codice_fiscale_contraente__c") == "undefined" || component.get("v.questionarioCA.Codice_fiscale_contraente__c") == "")  )
           checkCf = true;
        else {
              var patternCF= new RegExp(component.get("v.patternFiscalCode"));
              checkCf= patternCF.test(component.get("v.questionarioCA.Codice_fiscale_contraente__c"));
        }
        var email= component.get("v.questionarioCA.Email_Contraente__c");
        var patternEmail = new RegExp(component.get("v.patternEmail"));
        var checkEmail ;  
        if ((typeof  email == "undefined" || email == ""))
            checkEmail = true;
        else 
            checkEmail = patternEmail.test(email);
        
        if(checkCf && checkEmail){
        var action = component.get("c.upsertQuestionarioCACTRL");
        action.setParams({ "questionario" : component.get("v.questionarioCA"),
                          "oraEvento" : component.get("v.oraEvento"),
                          "minutiEvento" : component.get("v.minutiEvento"),
                          "oraRecall" : component.get("v.oraRecall"),
                          "minutiRecall" : component.get("v.minutiRecall"),
                          "accountIdToUpdate" : accountIdToUpdate,
	                      "QuestionarioToUpdate" :component.get("v.questionarioCaID")
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
                        component.set("v.method","update");
                        
                        if(!component.get("v.questionarioCaID"))
                            component.set("v.questionarioCaID",result.substring('OK|'.length,result.length));
                        
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
            $A.enqueueAction(action);}
        else
             this.showToast(component, event, helper, 'error', 'Attenzione, controllare gli errori in pagina.'); 
    },
    populateClientInfo : function(component, event, helper, cliente, persona)
    {
        console.log('populateClientInfo method',cliente);
        
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
        component.set("v.personaContr",persona);//MOSCATELLI_M 13/03/2019: Axa Assistance
        
        if(persona == "fisica")
        {
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
            //OAVERSANO 17/05/2019 : AXA Assistance Enhancement Fase I -- START
            if(cliente.Additional_Email__c!=null)
            {
            	component.set("v.questionarioCA.Email_Contraente__c",cliente.Additional_Email__c);
            }
            //MOSCATELLI_M 13/03/2019: Axa Assistance -- START
            //if(cliente.CIF_PersonEmail__c!=null)
            else if(cliente.Email_ListView__c!=null)
            //if(cliente.Email_ListView__c!=null)
            //OAVERSANO 17/05/2019 : AXA Assistance Enhancement Fase I -- END
            //MOSCATELLI_M 13/03/2019: Axa Assistance -- END
            {
                //MOSCATELLI_M 13/03/2019: Axa Assistance -- START
                //component.set("v.questionarioCA.Email_Contraente__c",cliente.CIF_PersonEmail__c);
                component.set("v.questionarioCA.Email_Contraente__c",cliente.Email_ListView__c);
                //MOSCATELLI_M 13/03/2019: Axa Assistance -- END
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
            if(cliente.Name!=null)
            {	
                component.set("v.questionarioCA.Nome_contraente__c",cliente.Name);
            }
            else
            {
                component.set("v.questionarioCA.Nome_contraente__c","");
            }
			//OAVERSANO 17/05/2019 : AXA Assistance Enhancement Fase I -- START
            if(cliente.Additional_Email__c!=null)
            {
            	component.set("v.questionarioCA.Email_Contraente__c",cliente.Additional_Email__c);
            }
            //MOSCATELLI_M 13/03/2019: Axa Assistance -- START
            //if(cliente.CIF_PersonEmail__c!=null)
            else if(cliente.Email_ListView__c!=null)
            //if(cliente.Email_ListView__c!=null)
            //OAVERSANO 17/05/2019 : AXA Assistance Enhancement Fase I -- END       
            //if(cliente.CIF_Personalemail__c!=null)
            //MOSCATELLI_M 13/03/2019: Axa Assistance -- END
            {
                //MOSCATELLI_M 13/03/2019: Axa Assistance -- START
                //component.set("v.questionarioCA.Email_Contraente__c",cliente.CIF_Personalemail__c);
                component.set("v.questionarioCA.Email_Contraente__c",cliente.Email_ListView__c);
                //MOSCATELLI_M 13/03/2019: Axa Assistance -- END
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
                    //MOSCATELLI_M 13/03/2019: Axa Assistance -- START
                    if(cliente.RecordType.Name == 'B2B Client')
                        component.set("v.questionarioCA.Codice_fiscale_contraente__c",cliente.AAI_Partita_IVA__c);               
                    //MOSCATELLI_M 13/03/2019: Axa Assistance -- END
                    
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
                        component.set("v.questionarioCA.Codice_fiscale_contraente__c",cliente.Partita_IVA__c);//MOSCATELLI_M 13/03/2019: Axa Assistance               

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
        console.log('EmailContraente: '+component.get("v.questionarioCA.Email_Contraente__c"));
    },
    showToast : function(component, event, helper, type, message, detailsMessage) 
    {
        console.log('showToast method');
        component.set("v.messageToast", message);
        component.set("v.DetailsMessageToast", detailsMessage)
        component.set("v.typeToast", type);
        component.set("v.showToast",true);
        var self = this;
        
        if(type!='error')
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
                    else if(component.get("v.RecordsDeleted"))
                    {                    
                        var myEvent = $A.get("e.c:tabclosing");
                        myEvent.setParams({"data":"cancel",
                                           "recordid":'',
                                           "Url":''});
                        myEvent.fire();
                    }
                }), 1000
            );
        }
    },
    convertToString : function(component, event, helper, ms, delim ) {
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
        var checkCf= false;
        if(component.get("v.personaContr") != 'fisica' ||  (typeof  component.get("v.questionarioCA.Codice_fiscale_contraente__c") == "undefined" || component.get("v.questionarioCA.Codice_fiscale_contraente__c") == "")  )
           checkCf = true;
        else {
              var patternCF= new RegExp(component.get("v.patternFiscalCode"));
              checkCf= patternCF.test(component.get("v.questionarioCA.Codice_fiscale_contraente__c"));
        }
        var email= component.get("v.questionarioCA.Email_Contraente__c");
        var patternEmail = new RegExp(component.get("v.patternEmail"));
        var checkEmail ;  
        if ((typeof  email == "undefined" || email == ""))
            checkEmail = true;
        else 
            checkEmail = patternEmail.test(email);
        
        if(checkCf && checkEmail){
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
                            console.log('questId',result.QuestId);
                            component.set("v.questionarioCaID", result.QuestId);
                            component.set("v.questionarioCA.Id", result.QuestId);
                            component.set("v.AlreadyOpened",false);
                            
                            var idCaseLightning = component.get("v.recordId");
                            
                            if(idCaseLightning!='' && idCaseLightning!=null)
                            {
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
        }
        else
             this.showToast(component, event, helper, 'error', 'Attenzione, controllare gli errori in pagina.');                    
   
    },
    chiudiTab : function(component,event,helper){
        var myEvent = $A.get("e.c:tabclosing");
        myEvent.setParams({"data":"cancel",
                           "recordid":'',
                           "Url":''});
        myEvent.fire();
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
})