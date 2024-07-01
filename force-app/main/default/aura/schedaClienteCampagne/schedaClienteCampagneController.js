({
    toggleAccordion : function(component, event, helper) {
        let elements = component.find('accordion');
        for(let component in elements) {
            $A.util.toggleClass(elements[component], 'slds-show');  
            $A.util.toggleClass(elements[component], 'slds-hide');  
        }
    },
    doInit: function(component, event, helper) {
            var action = component.get("c.getCampaignMembers");
            action.setParams({ 
                accountId : component.get("v.accountId")
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {  
                    helper.parseResponse(component, response.getReturnValue());
                }
                else if (state === "INCOMPLETE") {
                    console.log("incomplete state");
                }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                     errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
            });
            $A.enqueueAction(action);
        },
        onVisualizzaTutto: function(component, event, helper) {
            helper.onVisualizzaTutto(component);
        },
        onNuovo: function(component, event, helper){
            helper.onNuovo(component);
        },
        navigateToSObject: function (component, event, helper) {
            var recordId = event.target.id;
            var navService = component.find("navService");
            var pageReference = {
                type: 'standard__recordPage',
                attributes: {
                    recordId: recordId,
                    "actionName": "view"
                }
            };
            navService.navigate(pageReference);
        }

})