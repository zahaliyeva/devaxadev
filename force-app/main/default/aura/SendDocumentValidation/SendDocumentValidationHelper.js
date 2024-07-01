({
	sendDocumentValidation : function(component, helper, event) {
		console.log('sendDocumentValidation start method');
		let caseId = component.get("v.caseId");
	    var action = component.get("c.sendDocumentValidationCTRL");
        action.setParams({ "caseId" : caseId });
        action.setCallback(this, function(response) {
            component.set("v.isPopupAssociatePolicyOpen", false);
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("From server: ",response.getReturnValue());
                var msg = response.getReturnValue().message;
                if (response.getReturnValue().isSuccess==true) {
                    this.showToast(component, event, helper, 'success', msg);
                    component.getEvent("closeModal").fire();
                }
                else {
                    this.showToast(component, event, helper, 'error', msg);
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
                                 //component.set("v.errorMessage",errors[0].message);
                                 //component.set("v.isSuccess", false);
                                 helper.showToast(component,event,helper,'error','La funzionalità non è al momento disponibile. Contatta l\'Amministratore di sistema');
                                 
                    }
                } else {
                    console.log("Unknown error");
                    //component.set("v.errorMessage","Unknown error");
                    //component.set("v.isSuccess", false);
                    helper.showToast(component,event,helper,'error','La funzionalità non è al momento disponibile. Contatta l\'Amministratore di sistema');
                }
                
            }
        });
        $A.enqueueAction(action);
    },
    showToast : function(component, event, helper, type, message) 
    {
        console.log('showToast method');
        component.set("v.messageToast", message);
        component.set("v.typeToast", type);
        component.set("v.showToast",true);
        var self = this;
    },
    handleHasAssociatePolicy: function(component, event, helper){
        let caseId = component.get("v.caseId");
        return helper.server(component, "c.hasAssociatePolicy", { 
            "caseId" : caseId 
        });
    },
    polizzaAndCompany: function(component, event, helper){
        let caseId = component.get("v.caseId");
        helper.server(component, "c.polizzaAndCompany", { 
            "caseId" : caseId 
        }).then(
            result => { 
                  component.set("v.techCompany", result[0]);
                  component.set("v.policyNumber", result[1]); 
            }).catch(
                errors => { 
                    component.set('v.isLoading', false);
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            helper.showToast(component,event,helper,'error','Si è verificato un errore: ' + errors[0].message);                  
                        }
                    }
            });
    },
    handleAssociatePolicy: function(component, event, helper){
        component.set('v.isLoading', true);
        let caseId = component.get("v.caseId");
        let policyNumber = component.get("v.policyNumber");
        let techCompany = component.get("v.techCompany");
        return helper.server(component, "c.associatePolicy", { 
            "caseId" : caseId,
            "policyNumber": policyNumber,
            "techCompany": techCompany
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