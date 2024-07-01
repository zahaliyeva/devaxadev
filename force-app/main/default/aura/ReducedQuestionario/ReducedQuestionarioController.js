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
        
        helper.getListOfRegularExpressions(component); //set validator Expr
        
        var HOURSList = component.get("v.HOURSList");
        
        for(var i = 0; i<24; i++)
        {
            if(i<10)
                HOURSList.push('0'+i);
            else
                HOURSList.push(i);
        }
        
        var HOURSListRecall = component.get("v.HOURSListRecall");
        for(var i = 9; i<19; i++)
        {
            if(i<10)
                HOURSListRecall.push('0'+i);
            else
                HOURSListRecall.push(i);
        }        
        
        var MINUTESList = component.get("v.MINUTESList");
        for(var i = 0; i<60; i++)
        {
            if(i<10)
                MINUTESList.push('0'+i);
            else
                MINUTESList.push(i);
        }
		/** */
        MINUTESList ? component.set("v.MINUTESList",MINUTESList) : MINUTESList;
        HOURSList ? component.set("v.HOURSList",HOURSList) : HOURSList;
        HOURSListRecall ? component.set("v.HOURSListRecall",HOURSListRecall) : HOURSListRecall;
        /** */
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
        var numChiamante = component.get("v.phone");
        if(numChiamante!=null) component.set("v.questionarioCA.Numero_chiamante__c",numChiamante);	
        var todayISODateTime = new Date();
        console.log('todayISODateTime.toISOString(): ',todayISODateTime.toISOString().substring(0, 10));
        component.set("v.todayISODateTime", todayISODateTime.toISOString().substring(0, 10));
        helper.initializeCA(component, event, helper);
    },
    salvaQuestionario : function(component, event, helper)
    {
        console.log('salvaQuestionario method');
        component.set("v.SaveButtonPressed","Salva");
        helper.upsertQuestionarioCA(component, event, helper);
    },
    handleAssociatePolicyToQuestionarioCA : function(component, event, helper) { 
        console.log('handleAssociatePolicyToQuestionarioCA method');
        var policy = event.getParam("policy");

        if(!policy)
        {
            helper.showToast(component, event, helper, 'error', 'Attenzione ! Si è verificato un errore. Si prega di riprovare più tardi.');
        }
        else if(policy!=null)
        {
            
            console.log("TestTest");
            helper.showToast(component, event, helper, 'success', 'Polizza associata correttamente');
            if(policy.publicId!=null){
                console.log('publicId Public public: '+policy.publicId);
                component.set("v.questionarioCA.Numero_Polizza__c",policy.publicId);
            }
            else
                component.set("v.questionarioCA.Numero_Polizza__c",'');
            
            if(policy.portfolio === 'DAOL'){
                component.set("v.questionarioCA.Compagnia__c",'AAI');
                component.set("v.questionarioCA.NumApplicazione__c",policy.numApplicazione);
            }
            else{
                component.set("v.questionarioCA.Compagnia__c",'MPS');
                component.set("v.questionarioCA.NumApplicazione__c",policy.idAdhesion);
            } 
            
            component.set("v.questionarioCA.TECH_NDG__c",policy.commonData.ndg);
            component.set("v.questionarioCA.Tech_Policy_Node__c",policy.commonData.nodeCode);
            component.set("v.questionarioCA.Id_Polizza_SOL__c",policy.policyIdSOl);
            console.log(component.get("v.questionarioCA.Id_Polizza_SOL__c"));
            console.log(component.get("v.questionarioCA.NumApplicazione__c"));
            component.set("v.getPolizzeModal" , false);
            console.log("isGoldCustomer: "+event.getParam("isGoldCustomer"));
            if(event.getParam("isGoldCustomer"))
                component.set("v.questionarioCA.Cliente_GOLD__c",true);
            else if(!event.getParam("isGoldCustomer"))
                component.set("v.questionarioCA.Cliente_GOLD__c",false);
            console.log("isGoldCustomer set: "+component.get("v.questionarioCA.Cliente_GOLD__c"));
            
            console.log('publicId: '+policy.publicId);
            if(policy.licensePlate!=null)
            component.set("v.questionarioCA.Targa__c",policy.licensePlate);
            else
                component.set("v.questionarioCA.Targa__c",'');
            if(policy.companyCode!=null)
                component.set("v.questionarioCA.Compagnia__c",policy.companyCode);
            else
                component.set("v.questionarioCA.Compagnia__c",'');
            helper.checkPolicyType(component,policy.publicId,helper);
        }
    },
    /*handleAssociatePolicyToQuestionarioCA : function(component, event, helper)
    { 
        console.log('handleAssociatePolicyToQuestionarioCA method');
        var policy = event.getParam("policy");

        if(!policy)
        {
            helper.showToast(component, event, helper, 'error', 'Attenzione ! Si è verificato un errore. Si prega di riprovare più tardi.');
        }
        else if(policy!=null)
        {
            helper.showToast(component, event, helper, 'success', 'Polizza associata correttamente');
            if(policy.publicId!=null)
                component.set("v.questionarioCA.Numero_Polizza__c",policy.decodedPolicyId);
            else
                component.set("v.questionarioCA.Numero_Polizza__c",'');
            if(policy.licensePlate!=null)
                component.set("v.questionarioCA.Targa__c",policy.licensePlate);
            else
                component.set("v.questionarioCA.Targa__c",'');
            if(policy.dataSource!=null)
                component.set("v.questionarioCA.Compagnia__c",policy.dataSource);
            else
                component.set("v.questionarioCA.Compagnia__c",'');
            
            console.log("isGoldCustomer: "+event.getParam("isGoldCustomer"));
            if(event.getParam("isGoldCustomer"))
                component.set("v.questionarioCA.Cliente_GOLD__c",true);
            else if(!event.getParam("isGoldCustomer"))
                component.set("v.questionarioCA.Cliente_GOLD__c",false);
            console.log("isGoldCustomer set: "+component.get("v.questionarioCA.Cliente_GOLD__c"));
            
            console.log('publicId: '+policy.publicId);
            helper.checkPolicyType(component,policy.publicId,helper);
        }
    },*/
    getPolizze : function(component, event, helper)
    {
        component.set("v.getPolizzeModal" , true);
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
        component.set("v.sinistro",true);//ZA
        helper.upsertQuestionarioCA(component, event, helper);
        //helper.nuovoSinistro(component,event,helper);
    },
    endQuestionario : function(component,event,helper)
    {
        component.set("v.SaveButtonPressed","Fine");
        helper.upsertQuestionarioCA(component,event,helper);
    }
})