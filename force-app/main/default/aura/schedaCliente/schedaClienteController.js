({
    doInit: function(component, event, helper) {
        var action = component.get("c.getWrapper");
        action.setParams({ accountId : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") { 
				console.log('result',response.getReturnValue());
                helper.parseResponse(component, helper, response.getReturnValue());
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
    }
})