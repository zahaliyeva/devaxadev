({
	doInit : function(component, event, helper) {
        var action = component.get("c.getStorico_ChiamateInfos");
        var params = {"Id":component.get("v.recordId")};
        action.setParams(params);
        
        action.setCallback(this, function(response) {              
                var state = response.getState();
                if (component.isValid() && state === "SUCCESS") {
                    if(response.getReturnValue().Call_Historicised__c)
                    {
                      helper.STORMSavePhoneRecording(component, event, helper);  
                    }else
                    {
                    component.set("v.loading", false);
                    helper.showToastStandard(component, event, helper,'Errore','error', 'Non è necessario effettuare l\'operazione. La registrazione non era infatti stata salvata in precedenza');                    
                    $A.get("e.force:closeQuickAction").fire();
                    }
                   

                }
                else {
                   console.log("Failed with state: " + state);
                }
            });
        
            // Send action off to be executed
            $A.enqueueAction(action);
	}
})