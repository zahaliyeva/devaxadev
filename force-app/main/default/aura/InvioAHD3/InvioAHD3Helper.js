({
   setOptionsValue : function(component, event, helper)  {
		
        var action = component.get("c.getOptionsValuesInvioAHD3");
                  
        var caseId = component.get("v.caseId");  
       	var params = {caseId: caseId};
        action.setParams(params);
        //var params = {"caseId": caseId};
       // action.setParams(params);
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
            	let options=response.getReturnValue().options;
                console.log(response.getReturnValue());
                component.set("v.SilvaId", response.getReturnValue().SilvaId);
                component.set("v.availableValues" ,options);
                component.set("v.DettaglioInvio",response.getReturnValue().Dettaglio);
                component.set("v.selectedValue",response.getReturnValue().SelectedValue);
                component.set("v.DataInvio", response.getReturnValue().now);
                component.set("v.isHD2IT", response.getReturnValue().CurrentOwnerQueue.startsWith("HD2_IT"));
            }
            

        });  
        $A.enqueueAction(action); 
        
    
	},
    getOwnerIdForSendAutomaticHD1IT : function(component, event, helper)  {
        var action = component.get("c.getOwnerIdForSendAutomaticHD1IT");
        
        var caseId = component.get("v.caseId");  
        var params = {caseId: caseId };
        action.setParams(params);
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                
               component.set("v.sendToOwenerId" ,response.getReturnValue());
               // chiamare funzione salva passando l'ownerid  case 
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        this.showToast(component, event, helper, 'error', 'Attenzione ! Categorizzazione non presente. Utilizzare la selezione Manuale.');

                        console.log("Error message: " + errors[0].message);
                    }
                } 
            }
                
            var a = component.get('c.saveQueue');
            
            $A.enqueueAction(a);
            
            
        });  
        $A.enqueueAction(action);             
    },
    getOwnerIdForSendAutomaticHD1Contabilita : function(component, event, helper)  {
        var action = component.get("c.getOwnerIdForSendAutomaticHD1Contabilita");
        
        var caseId = component.get("v.caseId");  
        var params = {caseId: caseId };
        action.setParams(params);
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
               component.set("v.sendToOwenerId" ,response.getReturnValue());
               // chiamare funzione salva passando l'ownerid  case 
            }

                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            this.showToast(component, event, helper, 'error', 'Attenzione ! Categorizzazione non presente.');

                            console.log("Error message: " + errors[0].message);
                        }
                    } 
                }
                
            
            var a = component.get('c.saveQueue');
            
            $A.enqueueAction(a);
            
            
        });  
        $A.enqueueAction(action);
    },
    getOwnerIdForSendManualHD1IT : function(component, event, helper){
        var action = component.get("c.getOwnerIdForSendManualHD1IT");
        
        var caseId = component.get("v.caseId");  
        var params = {caseId: caseId };
        action.setParams(params);
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
               component.set("v.sendToOwenerId" ,response.getReturnValue());
               // chiamare funzione salva passando l'ownerid  case 
            }
            console.log("OWNER",response.getReturnValue() );
            var a = component.get('c.saveQueue');
            
            $A.enqueueAction(a);
            
            
        });  
        $A.enqueueAction(action);

    },
    
    getOwnerIdForSend : function(component, event, helper){
     var action = component.get("c.getOwnerQueueIdFromDevName");
        
    
        var params = {devName: component.get("v.selectedValue") };
        action.setParams(params);
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
               component.set("v.sendToOwenerId" ,response.getReturnValue());
            }
            console.log("OWNERID",component.get("v.sendToOwenerId"));
            var a = component.get('c.saveQueue');
            
            $A.enqueueAction(a);
          
        });
        
        $A.enqueueAction(action);
                    
    
     },
     startSpinner: function (component) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, 'slds-hide');
        //console.log("SPINNER START");
    },
    stopSpinner: function (component) {
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, 'slds-hide');
        //console.log("SPINNER STOP");
    },
    showToast : function(component, event, helper, type, message) 
    {
    	component.set("v.messageToast", message);
    	component.set("v.typeToast", type);
    	component.set("v.showToast",true);
    	window.setTimeout(
			$A.getCallback(function() {
				component.set("v.messageToast", "");
		    	component.set("v.typeToast", "");
		    	component.set("v.showToast",false);
			}), 5000
		);
		
	},
	showToastStandard : function(component, event, helper,title,type, msg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": type,
            "title": title,
            "message": msg
        });
        toastEvent.fire();
    }

     

})