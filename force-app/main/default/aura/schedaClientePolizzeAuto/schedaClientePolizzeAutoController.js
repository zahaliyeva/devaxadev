({
    doInit: function(component, event, helper) {
        var action = component.get("c.getPolizze");
        action.setParams({ 
            accountId : component.get("v.accountId"),
            asa : component.get("v.asa"),
            schedaClientePolizzaType : component.get('v.wrapper.schedaClientePolizzaType')
        });
        action.setCallback(this, function(response) {
            component.set('v.loading', true);
            var state = response.getState();
            if (state === "SUCCESS") {  
                helper.parseResponse(component, response.getReturnValue());
                component.set('v.loading', false);
            }
            else if (state === "INCOMPLETE") {
                console.log("incomplete state");
                component.set('v.loading', false);
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
                component.set('v.loading', false);
            }
        });
        $A.enqueueAction(action);

        var techCompany = component.get("v.techCompany");
        
        if(techCompany=='AAI')
            component.set("v.portfolio", 'DAOL');
        else
            component.set("v.portfolio", 'NAIS'); 
            
          
        let today = new Date().toISOString().slice(0, 10);
            component.set("v.startDate", today); 
    },
    onVisualizzaTutto: function(component, event, helper) {
        helper.onVisualizzaTutto(component, component.get("v.visualizzaTuttoListViewName"));
    },
    getPolizzeDaPortafoglio : function(component, event, helper) {
        component.set("v.isOpen", true);
    },
    onClose : function(component, event, helper) {
        component.set("v.isOpen", false);
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