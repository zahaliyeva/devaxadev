({
    showToastStandard : function(component, event, helper,title,type, msg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": type,
            "title": title,
            "message": msg
        });
        toastEvent.fire();
    },
    
    STORMSavePhoneRecording: function(component, event, helper){
        
        var action = component.get("c.call_SAP17_STORMSavePhoneRecording_WS");
        var params = {"ChiamataID":component.get("v.recordId"), "TOSave": true};
        action.setParams(params);        
        
         action.setCallback(this, function(response) { 
               var state = response.getState();
                if (component.isValid() && state === "SUCCESS") 
                {   console.log(response.getReturnValue());
                    if(response.getReturnValue())
                    {
                    component.set("v.loading", false);
                    this.showToastStandard(component, event, helper,'Success','success', 'Il salvataggio della registrazione è avvenuto correttamente');                     
                    $A.get("e.force:closeQuickAction").fire(); 
                    }
                    else
                    {
                    component.set("v.loading", false);
                    this.showToastStandard(component, event, helper,'Errore','error', 'Si è verificato un errore. Non è stato possibile eseguire il salvataggio');                     
                    $A.get("e.force:closeQuickAction").fire();
                    }                  

                }
                else {
                    component.set("v.loading", false);
                    this.showToastStandard(component, event, helper,'Errore','error', 'Si è verificato un errore. Non è stato possibile eseguire il salvataggio');                     
                    $A.get("e.force:closeQuickAction").fire();
                    console.log("Failed with state: " + state);
                }
            });
             // Send action off to be executed
            $A.enqueueAction(action);
        
    }
})