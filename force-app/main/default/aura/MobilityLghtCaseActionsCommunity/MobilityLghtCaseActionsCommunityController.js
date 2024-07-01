({
    doInit : function(component, event, helper) {
        var action = component.get("c.getInfoCase");  
        
        var caseId = component.get("v.recordId");   
        var params = {"recordId":caseId};
        action.setParams(params);

          // Add callback behavior for when response is received
          action.setCallback(this, function(response) {
    
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                component.set('v.caseObj', response.getReturnValue());    
               
            }
        
        });
        
        // Send action off to be executed
        $A.enqueueAction(action);
        

    },
   
})