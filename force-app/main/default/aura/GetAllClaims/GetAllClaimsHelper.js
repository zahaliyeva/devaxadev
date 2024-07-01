({
    getAllClaimsSOL : function(component, event, helper) {

        let fiscalCode = component.get("v.fiscalCode");
        let policyNumber = component.get("v.policyNumber");
        let incompleteReports = component.get("v.showIncompleteReports");
        let accountId = component.get("v.accountId");
        let originalCase = component.get("v.originalCase");
        let identifiedId = originalCase ? originalCase : accountId;
        let rtId = component.get("v.rtCaseId");
        let rtDevName = component.get("v.caseRT");
        
        var action = component.get("c.getAllClaimsSOLCTRL");
        action.setParams({ "fiscalCode" : fiscalCode ,
                            "policyNumber" : policyNumber,
                            "identifiedId" : identifiedId,
                            "incompleteReports": incompleteReports, 
                            "accountId" : accountId,
                            "rtId": rtId,
                            "rtDevName": rtDevName
                         });
        component.set('v.isLoading', true); 
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("From server: ",response.getReturnValue());
                if(response.getReturnValue().isSuccess==true)
                {
                    console.log("Claims", response.getReturnValue().deserializedResult.Claims);
                    console.log("Incomplete Reports", response.getReturnValue().deserializedResult.IncompleteReports);
                    component.set("v.claims", response.getReturnValue().deserializedResult.Claims.concat(response.getReturnValue().deserializedResult.IncompleteReports));
                    component.set("v.isSuccess", true);
                    component.set('v.isLoading', false);
                }
                else if(response.getReturnValue().isSuccess==false){
                    component.set("v.errorMessage", response.getReturnValue().message);
                    component.set("v.isSuccess", false);
                    component.set('v.isLoading', false);
                }
                
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
    
    getAllClaims : function(component, event, helper) {
    
        let fiscalCode = component.get("v.fiscalCode");
        let policyNumber = component.get("v.policyNumber");
        let showPreDenunciations = component.get("v.showPreDenunciations");
        let accountId = component.get("v.accountId");
        let showIncompleteReports = component.get("v.showIncompleteReports");
        var action = component.get("c.getAllClaimsCTRL");
        action.setParams({ "fiscalCode" : fiscalCode ,
                            "policyNumber" : policyNumber,
                            "showPreDenunciations" : showPreDenunciations,
                            "accountId" : accountId,
                            "showIncompleteReports" : showIncompleteReports });
        component.set('v.isLoading', true); 
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("From server: ",response.getReturnValue());
                if(response.getReturnValue().isSuccess==true)
                {
                    console.log("nodo claim", response.getReturnValue().deserializedResults);
                    component.set("v.claims", response.getReturnValue().deserializedResults);
                    component.set("v.isSuccess", true)
                    component.set('v.isLoading', false);
                }
                else if(response.getReturnValue().isSuccess==false){
                    component.set("v.errorMessage", response.getReturnValue().message);
                    component.set("v.isSuccess", false);
                    component.set('v.isLoading', false);
                }
                
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
    sortData: function (component, fieldName, sortDirection) {
        var data = component.get("v.claims");
        var reverse = sortDirection !== 'asc';

        data = Object.assign([],
            data.sort(this.sortBy(fieldName, reverse ? -1 : 1))
        );
        component.set("v.claims", data);
    },
    sortBy: function (field, reverse, primer) {
        var key = primer
            ? function(x) { return primer(x[field]) }
            : function(x) { return x[field] };

        return function (a, b) {
            var A = key(a)?key(a):'';
            var B = key(b)?key(b):'';
            return reverse * ((A > B) - (B > A));
        };
    },
    creaCaseDiMonitoraggio : function (component, event, helper, selectedCase, linkToSol, claimNumber, noClaim) {
        console.log('crea case di monitoraggio start method');
        let source = component.get("v.source");
        let originalCase = component.get("v.originalCase");
        let CallerType = component.get("v.CallerType");
        let rtCaseId = component.get("v.rtCaseId");
        let phoneCallId = component.get("v.phoneCallId");
        let phoneCallIDB = component.get("v.phoneCallIDB");
        let CallDateTime = component.get("v.CallDateTime");
        var action = component.get("c.createCaseMonitoraggio");     
        action.setParams({  "originalCase" : originalCase,
                            "selectedCase" : selectedCase,
                            "source" : source,                  //vfp06
                            "linkToSol" : linkToSol,
                            "rtCaseId" : rtCaseId,              //vfp06
                            "CallerType" : CallerType,          //vfp06
                            "phoneCallId" : phoneCallId,        //vfp06
                            "phoneCallIDB" : phoneCallIDB,      //vfp06
                            "CallDateTime" : CallDateTime,          //vfp06
                            "claimNumber" : claimNumber,
                            "noClaim": noClaim // FOZDEN 26/06/2019: AXA Assistance Enhancement Fase II
                            });
        component.set('v.isLoading', true); 
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("From server: ",response.getReturnValue());
                if(response.getReturnValue().isSuccess==true)
                {
                    component.set("v.isSuccess", true)
                    component.set("v.isLoading", false);
                    let values = response.getReturnValue().values;
                    let caseIdUpserted = values["caseIdUpserted"];
                    console.log('caseIdUpserted: '+caseIdUpserted);
                    let redirectToNewCase = values["redirectToNewCase"];
                    if(redirectToNewCase == "true")
                    {
                        //url
                        let switchRecordTypeSelection = values["switchRecordTypeSelection"];
                        let caseType = values["caseType"];
                        let accountId = component.get("v.accountId");
                        if(accountId == 'undefined' || accountId == undefined)
                            accountId = '';
                        let linkToSOL = values["linkToSOL"];
                        let visualizzaSinistroField = $A.get("$Label.c.GetAllClaims_VisualizzaSinistro");
                        let CallerType = values["CallerType"];
                        console.log('CallerType: '+CallerType);
                        let recorTypeCaller = values["rtCaseId"];
                        let phoneCallIdField = $A.get("$Label.c.Phone_Call_Ids_ID");
                        let phone_callIds = values["phone_callIds"];
                        if(phone_callIds == 'undefined' || phone_callIds == undefined)
                            phone_callIds = '';
                        let numeroSinistroField = $A.get("$Label.c.GetAllClaims_NumeroSinistro");
                        let claimNumber = values["claimNumber"];
                        if(claimNumber == 'undefined' || claimNumber == undefined)
                            claimNumber = '';
                        //OAVERSANO 17/05/2019 : AXA Assistance Enhancement Fase I -- START
                        let lobField = $A.get("$Label.c.LOB_ID");
                        let lobValue = values["lobValue"];
                        if(lobValue == 'undefined' || lobValue == undefined)
                            lobValue = '';
                        let categoryField = $A.get("$Label.c.Categoria_ID");
                        let categoryValue = values["categoryValue"];
                        if(categoryValue == 'undefined' || categoryValue == undefined)
                            categoryValue = '';
                        //OAVERSANO 17/05/2019 : AXA Assistance Enhancement Fase I -- END
                        let url = '?cas11=Phone&def_account_id='+accountId+'&00N240000018Zoa='+CallerType+'&cas5='+caseType+'&'+lobField+'='+lobValue+'&'+categoryField+'='+categoryValue+'&'+visualizzaSinistroField+'='+linkToSOL+'&'+numeroSinistroField+'='+claimNumber+'&'+phoneCallIdField+'='+phone_callIds+'&classicEdit=true';

                        // FOZDEN 26/06/2019: AXA Assistance Enhancement Fase II -- START
                        if(noClaim) {
                            url = '?cas11=Phone&def_account_id='+accountId+'&cas5='+caseType+'&'+lobField+'='+lobValue+'&'+categoryField+'='+categoryValue+'&'+phoneCallIdField+'='+phone_callIds+'&classicEdit=true';
                        }
                        // FOZDEN 26/06/2019: AXA Assistance Enhancement Fase II -- END

                        component.set("v.urlToOpen", url);
                        /*if(switchRecordTypeSelection)
                        {
                            component.set("v.CaseWithRTClaims",true);
                        }
                        else
                        {
                            console.log('url: '+url);
                            let SinistriDanniBancaRecordTypeId = values["SinistriDanniBancaRecordTypeId"];
                            url += '&RecordType='+SinistriDanniBancaRecordTypeId;
                            this.callEvent(component, event, helper, "openNewCasePage", "", url);
                        }*/
                        component.set("v.CaseWithRTClaims",true);
                    }
                    else if(caseIdUpserted!=null)
                    {
                        
                        if(values['method'] == 'update')
                        {
                            console.log('original case updated');
                            this.callEvent(component, event, helper, "cancel", caseIdUpserted, "");
                        }
                        else if(values['method'] == 'insert')
                        {
                            console.log('inserted new case');
                            let casenumber = values["casenumber"];
                            console.log('casenumber: '+casenumber);
                            this.callEvent(component, event, helper, casenumber, caseIdUpserted, "");
                        }
                        
                    }
                    if(window.location.pathname.indexOf('lightning')==1){
                        const visibilities = component.get('v.visibilities');                    
                        if(visibilities) visibilities('GetAllClaims', false);
                        $A.get('e.force:refreshView').fire();
                         var navEvt = $A.get("e.force:navigateToSObject");
                         navEvt.setParams({
                           "recordId": response.getReturnValue().values["caseIdUpserted"],
                           "slideDevName": "detail"
                         });
                         navEvt.fire();                        
                     }
                }
                else if(response.getReturnValue().isSuccess==false){
                    component.set("v.errorMessage", response.getReturnValue().message);
                    component.set("v.isSuccess", false);
                    component.set('v.isLoading', false);
                }
                
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
    callEvent : function(component, event, helper, data, recordId, Url)
    {
        var myEvent = $A.get("e.c:tabclosing");
        myEvent.setParams({ "data": data,
                            "recordid": recordId,
                            "Url": Url});
        myEvent.fire();
    }
    //MDANTONIO 20/05/2019 : AXA Assistance enh. US-1018 - start
    ,
    getRelatedCases : function(component, event, helper, claimNumber, caseId){
        var action = component.get("c.getClaimRelatedCases");   
        console.log('claim number: ', claimNumber);
        console.log('case ID: ', caseId);
        action.setParams({"claimNumber" : claimNumber,
            "caseId" : caseId
    });
        component.set('v.isLoading', true);
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("From server: ",response.getReturnValue());
                if(response.getReturnValue().isSuccess==true)
                {
                    var caseList = response.getReturnValue().values.caseList;
                    component.set("v.caseRequestSuccess", true);
                    component.set("v.isLoading", false);
                    if(component.get("v.caseRT")=='AXA_Caring_Salute'){
                        caseList = caseList.filter(function(element) {
                            return element.RecordType.DeveloperName == 'AXA_Caring_Salute';
                        });
                    }
                    component.set("v.caseList", caseList);
                }
                else if(response.getReturnValue().isSuccess==false){
                    component.set("v.casesErrorMessage", response.getReturnValue().message);
                    component.set("v.caseRequestSuccess", false);
                    component.set('v.isLoading', false);
                    console.log('response is not success');
                }
                
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
                                 component.set("v.casesErrorMessage",errors[0].message);
                                 component.set("v.caseRequestSuccess", false);
                                 console.log('state error with message');
                    }
                } else {
                    console.log("Unknown error");
                    component.set("v.casesErrorMessage","Unknown error");
                    component.set("v.caseRequestSuccess", false);
                    console.log('state error without message');
                }
                component.set('v.isLoading', false);
            }
        });
        $A.enqueueAction(action);
    },
    //MDANTONIO 20/05/2019 : AXA Assistance enh. US-1018 - end
    initCmp : function(component, event, helper){
    
        var action = component.get("c.initComponent");
        action.setParams({ "caseId" : component.get("v.originalCase") ,
                           "CaseType" : component.get("v.rtCaseId") });
            
            
         action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    console.log("From server: ",response.getReturnValue());
                    component.set("v.showNewCreaCase",response.getReturnValue().showNewCreaCase);
                    component.set("v.showTraceMonitoringCase",response.getReturnValue().showTraceMonitoringCase);   
                  }     
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                     errors[0].message);
                                   
                                     
                        }
                    } 
                }
            });
            $A.enqueueAction(action);   
        
        },
        createCase: function(component, helper){
            component.set('v.spinner', true);
    
            const action = component.get('c.getNewCase');
            const params = {"LOB" : "Sinistri Salute", 
                            "Caller": component.get("v.CallerType"),
                            "RecordType": component.get("v.caseRT")};
    
            action.setParams({
                params,
                "accountId": component.get("v.accountId")
            });
            component.set('v.isLoading', true);
            action.setCallback(this, (response)=>{
                const state = response.getState();
                console.log('state', state);
    
                component.set('v.spinner', false);
                switch(state){
                    case 'SUCCESS':
                        const result = response.getReturnValue();    			
    
                        this.redirectToCase(component, result.values['CaseId']);
                         component.set('v.isLoading', false);
                        break;
                    case 'ERROR':
                        omponent.set("v.casesErrorMessage", response.getReturnValue().message);
                        component.set("v.caseRequestSuccess", false);
                        component.set('v.isLoading', false);
                        console.log('response is not success');
                        break;
                }
            })
    
            $A.enqueueAction(action);
        },
        redirectToCase: function(component, caseDataId){
            const myEvent = $A.get("e.c:lghtRedirectNew");
            
            console.log("caseData", caseDataId);
            
            myEvent.setParams({
                action: 'detail-case',
                recordId: caseDataId
            });
            
            myEvent.fire(); 
        },
        handleCreaCaseDiMonitoraggioLightning : function (component, event, helper, selectedCase, linkToSol, claimNumber, noClaim, accountId, isAssocia) {
            let source = component.get("v.source");
            let originalCase = component.get("v.originalCase");
            let CallerType = component.get("v.CallerType");
            let caseRT = component.get("v.caseRT");
            let phoneCallId = component.get("v.phoneCallId");
            let phoneCallIDB = component.get("v.phoneCallIDB");
            let CallDateTime = component.get("v.CallDateTime");
            return helper.server(component, "c.createCaseMonitoringLightning", {  
                    "originalCase" : originalCase,
                    "selectedCase" : selectedCase,
                    "source" : source,                 
                    "linkToSol" : linkToSol,
                    "caseRT" : caseRT,             
                    "CallerType" : CallerType,         
                    "phoneCallId" : phoneCallId,        
                    "phoneCallIDB" : phoneCallIDB,      
                    "CallDateTime" : CallDateTime,         
                    "claimNumber" : claimNumber,
                    "noClaim": noClaim,
                    "accountId": accountId,
                    "isAssocia": isAssocia
            });
        },
        handleCreateCaseLightning: function(component){
                const params = {"LOB" : "Sinistri Salute", 
                                "Caller": component.get("v.CallerType"),
                                "RecordType": component.get("v.caseRT")};
                return helper.server(component, "c.createCaseLightning", {
                    params,
                    "accountId": component.get("v.accountId")
                });
        },
        navigateToObject : function(component, recordId) {
            var workspaceAPI = component.find("workspace");
            return workspaceAPI.openTab({
                recordId: recordId,
                focus: true
            });
        },
        server: function(component, actionName, params) {
            return new Promise($A.getCallback((resolve, reject) => {
                var action = component.get(actionName);
                params && action.setParams(params);
                action.setCallback(this, result => {
                    switch (result.getState()) {
                        case "DRAFT":
                        case "SUCCESS":
                            resolve(result.getReturnValue());
                            break;
                        default:
                            reject(result.getError());
                    }
                });
                $A.enqueueAction(action);
            }));
        }
})