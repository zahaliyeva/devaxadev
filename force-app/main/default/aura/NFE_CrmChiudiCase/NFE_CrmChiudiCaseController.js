({
    doInit: function(component, event, helper) {
        var action = component.get("c.getCase");
        action.setParams({ 
            id : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            const result = response.getReturnValue();
            var state = response.getState();
            if (state === "SUCCESS") {

                if(result.OwnerId.startsWith('005'))
					{
						component.set('v.OwnerIsUser', true);
                       
					} else  
                      document.getElementById("divError").style.display="block";
                component.set("v.caseData", response.getReturnValue());
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
    close: function(component, event, helper) {
        const myURL = "https://" + window.location.hostname + "/crm/s/case/" + component.get("v.recordId") + "/detail";
        window.location.href = myURL;
    }
})