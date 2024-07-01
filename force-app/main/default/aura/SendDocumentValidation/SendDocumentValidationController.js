({
	doInit : function(component, event, helper) {
		component.set('v.isLoading', true);
		helper.handleHasAssociatePolicy(component, event, helper).then(
		result => { 
			if(result){
				helper.sendDocumentValidation(component, event, helper);
			} else {
				helper.polizzaAndCompany(component, event, helper);
				component.set('v.isLoading', false);
				component.set("v.isPopupAssociatePolicyOpen", true);
				//component.set('v.policyNumber', polizzaCompany[0]);
				//component.set('v.techCompany', polizzaCompany[1]);

			}
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
	onAssociatePolicy : function(component, event, helper) {
		helper.handleAssociatePolicy(component, event, helper).then(
			result => { 
					helper.sendDocumentValidation(component, event, helper);
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
	chiudiToast : function(component, event, helper) 
    {
        component.set("v.messageToast", "");
        component.set("v.typeToast", "");
        component.set("v.showToast",false);
	},
	closeModal: function(component){
		component.getEvent("closeModal").fire();
	}
})