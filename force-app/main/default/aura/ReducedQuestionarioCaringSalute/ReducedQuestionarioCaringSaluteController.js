({
    doInit : function(component, event, helper) 
    {
        
        console.log('doInit NewQuestionarioCA');
        console.log('questionarioCaID : ',component.get("v.questionarioCaID"));
        console.log('fiscalCode: '+component.get("v.fiscalCode"));
        console.log('accountId: '+component.get("v.accountId"));
        console.log('phone: '+component.get("v.phone"));
        console.log('caller: '+component.get("v.caller"));
        console.log('category: '+component.get("v.category"));
        console.log('subcategory: '+component.get("v.subcategory"));
        console.log('caseid: '+component.get("v.caseId"));
        console.log('Case from LIGHTNING: ',component.get("v.simpleRecord.Case__c"));
        console.log('questionario ID from LIGHTNING red: ',component.get("v.recordId"));
        
        var today = new Date(); 
        component.set('v.minDateEvent', $A.localizationService.formatDate(today.setDate(today.getDate() + 1), "YYYY-MM-DD"));

        let questionarioCAid = component.get("v.questionarioCaID");
        let caseId = component.get("v.caseId");
        let questionarioCAidLIGHTNING = component.get("v.recordId");
        if(questionarioCAid!= null && questionarioCAid !='')
        {
            console.log("edit From SF");
            component.set("v.method","update");
            component.set("v.questionarioCA.Id",questionarioCAid);
        }
        else if(caseId!= null && caseId !='')
        {
            console.log("new From SF");
            component.set("v.method","insert");
            component.set("v.questionarioCA.Case__c",caseId);
        }
            else if(questionarioCAidLIGHTNING!=null && questionarioCAidLIGHTNING!= '')
            {
                console.log("edit From SF Lightning");
                component.set("v.method","update");
                component.set("v.questionarioCA.Id",questionarioCAidLIGHTNING);
            }
                else
                {
                    console.log("new From VFP06")
                    component.set("v.method","insert");
                    let accountId = component.get("v.accountId");
                    if(accountId!=null)
                    {
                        component.set("v.questionario.Contraente__c",accountId);
                    }
                }
   
        helper.initializeCA(component, event, helper);
    },
    salvaQuestionario : function(component, event, helper)
    {
        console.log('salvaQuestionario method');
        component.set("v.SaveButtonPressed","Salva");
        helper.upsertQuestionarioCA(component, event, helper);
    },
    handleAssociatePolicyToQuestionarioCA : function(component, event, helper)
    { 
        console.log('handleAssociatePolicyToQuestionarioCA method');
        var policy = event.getParam("policy");

        if(!policy)
        {
            helper.showToast(component, event, helper, 'error', 'Attenzione ! Si è verificato un errore. Si prega di riprovare più tardi.');
        }
        else if(policy!=null)
        {
            
            component.set("v.questionarioCA.TECH_NDG__c",policy.commonData.ndg);
            component.set("v.questionarioCA.Tech_Policy_Node__c",policy.commonData.nodeCode);
            helper.showToast(component, event, helper, 'success', 'Polizza associata correttamente');
            component.set("v.questionarioCA.Id_Polizza_SOL__c",policy.policyIdSOl);
            component.set("v.questionarioCA.NumApplicazione__c",policy.numApplicazione);
            if(policy.publicId!=null){
                //component.set("v.questionarioCA.Numero_Polizza__c",policy.decodedPolicyId);
                component.set("v.questionarioCA.Numero_Polizza__c",policy.publicId);
                component.set("v.getPolizzeModal" , false);
            }
        }
    },
    getPolizze : function(component, event, helper)
    {
        var dataEvento = component.get("v.questionarioCA.Data_Evento__c");
        var codiceFiscale = component.get("v.CodiceFiscaleCaponucleo");      
        if(!dataEvento || !codiceFiscale)
        {
            helper.showToast(component, event, helper, 'error', 'Attenzione, per procedere con l\'operazione richiesta è necessario indicare il codice fiscale e la data dell\'evento');                    
        } else {
            component.set("v.getPolizzeModal" , true); 
        }
    },
    chiudiModalePolizze : function(component, event, helper)
    {
        component.set("v.getPolizzeModal" , false);
    },
    findAssociateClient : function(component, event, helper)
    {
        var isFindConducente = component.get('v.isVisibleSTEP3');
        
        if(isFindConducente)
            component.set("v.personaContr","fisica");
        
        let tipoCliente =  event.getSource().get("v.name");
        component.set("v.tipoCliente", tipoCliente);
        component.set("v.findClientModal" , true);
    },
    chiudiModalfindAssociateClient : function(component, event, helper)
    {
        component.set("v.findClientModal" , false);
    },
    handleAssociateClientToQuestionarioCA : function(component, event, helper)
    { 
        console.log('handleAssociateClientToQuestionarioCA method');
        var client = event.getParam("client");
        var clientType = event.getParam("type");
        var persona = event.getParam("persona");
        if(!client)
        {
            helper.showToast(component, event, helper, 'error', 'Attenzione ! Si è verificato un errore. Si prega di riprovare più tardi.');
        }
        else if(clientType == 'contraente' && client!=null)
        {
            helper.showToast(component, event, helper, 'success', 'Contraente associato correttamente');
            helper.populateClientInfo(component, event, helper,client, persona);
            if(client.Id!=null)
            {
                component.set("v.accountIdToUpdate", client.Id);
                component.set("v.questionario.Contraente__c",client.Id);
                component.set("v.accountId",client.Id);//MOSCATELLI_M 18/03/2019: AXA Assistance
            }
        }
            else if(clientType == 'conducente' && client!=null)
            {
                helper.showToast(component, event, helper, 'success', 'Conducente associato correttamente');
                helper.populateCondClientInfo(component, event, helper,client, persona);
            }
    },
    chiudiToast : function(component, event, helper) 
    {
        component.set("v.messageToast", "");
        component.set("v.typeToast", "");
        component.set("v.showToast",false);
    },
    returnToCase : function(component, event, helper)
    {
        var idCaseLightning = component.get("v.recordId");

        var source = component.get("v.source");
        var idQuestionario = component.get("v.questionarioCaID");
        var idCase = component.get("v.caseId");
        
        if(idCaseLightning!='' && idCaseLightning!=null)
        {
            var workspaceAPI = component.find("workspace");
            workspaceAPI.getFocusedTabInfo().then(function(response) {
                var focusedTabId = response.tabId;
                workspaceAPI.closeTab({tabId: focusedTabId});
            })
            .catch(function(error) {
                console.log(error);
            });
        }
        else
        {
            console.log('returnToCase method');

            if(source!='NewCaseCApage')  
            {            
                let prefix = $A.get("$Label.c.SiteDomain");
                let caseId = component.get("v.caseId");
                window.location.href = prefix+caseId;
                helper.chiudiTab(component,event,helper);
            }
            else
            {
                if(idCase)
                {
                    console.log('##START deleteRecords');
                    component.set("v.AnnullaModal",false);
                    helper.deleteRecords(component,event,helper,idCase,idQuestionario);
                }
            }
        }
    },
    showModalAnnulla : function(component, event, helper) 
    {
        component.set("v.AnnullaModal",true);
    },
    chiudiModalAnnulla :  function(component, event, helper) 
    {
        component.set("v.AnnullaModal",false);
    },
    
    creaSinistro : function(component,event,helper)
    {
        component.set("v.sinistro",true);//SC
        helper.upsertQuestionarioCA(component, event, helper);
        //helper.nuovoSinistro(component,event,helper);
    },
    endQuestionario : function(component,event,helper)
    {
        component.set("v.SaveButtonPressed","Fine");
        helper.upsertQuestionarioCA(component,event,helper);
    },
    calculateFiscalCode : function (component , event, helper){
        var surname = component.get("v.questionarioCA.Cognome_Caponucleo__c");
        var name = component.get("v.questionarioCA.Nome_Caponucleo__c");
        var city = component.get("v.questionarioCA.Luogo_di_Nascita_Caponucleo__c");
        var province = component.get("v.questionarioCA.Provincia_di_Nascita_Caponucleo__c");
        var birthDate = ''+component.get("v.questionarioCA.Data_di_Nascita_Caponucleo__c");
        var gender = component.get("v.questionarioCA.Sesso_Caponucleo__c");
         
         if ( surname && name && city && province && birthDate && gender ){
 
        var action = component.get("c.calculateFiscalCodeCtrl");
             action.setParams({"surname" : surname,
                               "firstName" : name,
                               "city" : city,
                               "province" : province,
                               "birthdate" : ''+birthDate,
                               "gender" : gender
                             });
 
                           action.setCallback(this,function(response){
                             var state = response.getState();
                             if (state === "SUCCESS") {
                                     var result = response.getReturnValue();
                                     console.log('### fiscalCode'+result);
                                     component.set("v.questionarioCA.Codice_Fiscale_Caponucleo__c",result);
                                     component.set("v.CodiceFiscaleCaponucleo",result);
                                 
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
         }
     
     },
     setCF : function(component, event, helper)
     {
        component.set("v.questionarioCA.Codice_Fiscale_Caponucleo__c",   component.get("v.CodiceFiscaleCaponucleo")); console.log( component.get("v.questionarioCA.Codice_Fiscale_Caponucleo__c"));
     
     }
})