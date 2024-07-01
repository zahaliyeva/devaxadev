({
    doInit : function(component, event, helper) {
        const CaseId = component.get("v.caseId");
        const action = component.get("c.UpdateCase");
        
        action.setParams({ "CaseId" : CaseId });
        action.setCallback(this, function(response) {
            const state = response.getState();
            if (state === "SUCCESS") {
                const result = response.getReturnValue();
                component.set("v.currentCase", result);
                helper.redirect(component, event, helper);
            } else if (state === "ERROR") {
                const errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        helper.checkQueueNameOwner(component, event, helper,errors[0].message);
                     
                        window.setTimeout(
                            $A.getCallback(function() {
                                helper.redirect(component, event, helper)
                            }), 5000
                        );
                    }
                } 
            }
        });
        
        $A.enqueueAction(action);
    }

})