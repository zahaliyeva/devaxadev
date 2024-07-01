({
   setOptionsValue : function(component, event, helper)  {
		
        var action = component.get("c.getOptionsValuesInvioASecondoLivello");
                  
        var caseId = component.get("v.caseId");  
        var params = {"caseId": caseId};
        action.setParams(params);
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
            let options=response.getReturnValue();
                component.set("v.availableValues" ,options);
            }         

        });  
        $A.enqueueAction(action); 
        
    
    },
    skipMappingAutomaticOwnerNMAConfiguration : function(component, event, helper)  {
        var action = component.get("c.skipMappingAutomaticOwnerNMAConfiguration");
        var params = {"caseId": component.get("v.caseId")};
        action.setParams(params);
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.skipMappingAutomaticOwnerNMAConfiguration" ,response.getReturnValue());
            }         
        });  
        $A.enqueueAction(action); 
	},
    getOwnerIdForSendAutomaticHD1IT : function(component, event, helper)  {
        var action;
        var motivo = component.get("v.motivoTrasferimento");
        action = component.get("c.getOwnerIdForSendAutomatic");
      	var motivoTrasferimento = (motivo === '' || typeof motivo === "undefined" || motivo === null )? '':motivo;
        var caseId = component.get("v.caseId");  
        var params = {caseId: caseId,
                      MotivoTrasferimento: motivoTrasferimento};
        action.setParams(params);
        
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
               if(response.getReturnValue() == null){
                    this.showToast(component, event, helper, 'error', 'Attenzione ! Categorizzazione non presente.');
                }
                else
               component.set("v.sendToOwenerId" ,response.getReturnValue());
                console.log(response.getReturnValue());
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
        var action;
        var motivo = component.get("v.motivoTrasferimento");
        action = component.get("c.getOwnerIdForSendAutomatic");
      	var motivoTrasferimento = (motivo === '' || typeof motivo === "undefined" || motivo === null )? '':motivo;
        var caseId = component.get("v.caseId");  
        var params = {caseId: caseId,
                      MotivoTrasferimento: motivoTrasferimento};
        action.setParams(params);
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if(response.getReturnValue() == null){
                    this.showToast(component, event, helper, 'error', 'Attenzione ! Categorizzazione non presente.');
                }
                else
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