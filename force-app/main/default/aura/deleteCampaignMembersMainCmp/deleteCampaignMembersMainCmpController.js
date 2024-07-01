({
    Initialize : function(component, event, helper) {
        var action = component.get("c.checkEligibility");  
        var campaignId = component.get("v.recordId");  
        var params = {"campaignId":campaignId};
        action.setParams(params);
        
        // Add callback behavior for when response is received
        action.setCallback(this, function(response) {
            helper.stopSpinner(component);
            
            if (component.get("v.jsDebug")) console.log("stopping spinner..");
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                
                if (component.get("v.jsDebug")) console.log("Response " + JSON.stringify(response.getReturnValue(), null, 4));
                var isCallSuccess = response.getReturnValue()["isSuccess"];
                if (component.get("v.jsDebug")) console.log("isCallSuccess " + isCallSuccess);                
                if (isCallSuccess)
                {                    
                   // var usrList = response.getReturnValue().values.userList;
                   // console.log("usrList " + JSON.stringify(usrList, null, 4));                    
                   // component.set('v.userList', usrList);
                }else
                {
                    helper.setError(component,"Impossibile procedere",response.getReturnValue()["message"]);
                }
            }
            else {
                if (component.get("v.jsDebug")) console.log("Failed with state: " + state);
            }
        });
        
        // Send action off to be executed
        $A.enqueueAction(action);
        
    },
    saveUpdates : function(component, event, helper) {

        var campaignId = component.get("v.recordId");

        //SEND THIS VARIABLE TO THE SERVER
        var action = component.get("c.startDeletion");              
        var params = {"campaignId":campaignId};
        action.setParams(params);
        
        // Add callback behavior for when response is received
        action.setCallback(this, function(response) {
            helper.startSpinner(component);
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                helper.stopSpinner(component);
                if (component.get("v.jsDebug")) console.log("Response " + JSON.stringify(response.getReturnValue(), null, 4));
                var isCallSuccess = response.getReturnValue()["isSuccess"];
                if (isCallSuccess)
                {                       
                    component.set('v.isFinish', true);
                }
                else
                {
                    helper.setError(component,"Errore di salvataggio",response.getReturnValue()["message"]);        
                }
                
                if (component.get("v.jsDebug")) console.log("isCallSuccess " + isCallSuccess);
            }
            else {
                if (component.get("v.jsDebug")) console.log("Failed with state: " + state);
                helper.setError(component,"Errore","Si è verificato un errore nella comunicazione con il server, riprovare più tardi");
    
            }
        });
        
        // Send action off to be executed
        $A.enqueueAction(action);            
            
        
        
        
    },
    closeError : function(component, event, helper) {
        //component.set("v.isError",false);
        helper.redirectpage(component);
    },  
    finish : function(component, event, helper) {
        helper.redirectpage(component);
    },
    gotoURL : function (component, event, helper) {
    	helper.redirectpage(component, event);   
    }
    
})