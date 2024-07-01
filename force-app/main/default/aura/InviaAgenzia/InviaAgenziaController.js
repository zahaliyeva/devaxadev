({  doInit : function(component, event, helper) {
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
    
    closeModal : function(component, event, helper) {
    // when a component is dynamically created in lightning, we use destroy() method to destroy it.
    component.destroy();
    },

    saveQueue : function(component, event, helper){
        
        console.log("Commento ", component.get("v.cmt"));

        if(component.get("v.cmt")==null || component.get("v.cmt")==undefined || component.get("v.cmt")==""){
        helper.showToast(component, event, helper, 'error', 'Attenzione ! Inserire un commento prima di inoltrare il case.');
        return
        }
 
        component.set("v.rT", "Agente");
        console.log("RT ",component.get("v.rT"));
        
            helper.startSpinner(component);           
            var attachmentList = component.get("v.attachmentList");
            
                  
            var action = component.get('c.NewsaveCommentAttachment');
            var params = {'cCase' : component.get("v.caseId"),
            "cmt" : component.get("v.cmt"), 
            "rT" : 'Agente', 
            "numberOfAttachment" : attachmentList.length, 
            "attachmentList" : component.get("v.attachmentList"), 
            "OrgUrl" :component.get("v.OrgUrl"), 
            "Label": component.get("v.Label"), 
            "profileName": component.get("v.profileName"), 
            "userRole": component.get("v.userRole"),
            "defectCheckbox" : "false",
            "motivoTrasferimento" : component.get("v.motivoTrasferimento"),
            "selectedValue" : component.get("v.selectedValue"),
            "selectedLabel" : component.get("v.selectedLabel"),
            "OwnerId" : component.get("v.sendToOwenerId")}
            
            action.setParams(params);
            action.setCallback(this, function(response) {
                
                var state = response.getState();
                console.log("state --> "+state);
                
                if (state === "SUCCESS") {
                    
                        console.log('Success state');
                        //console.log('Data:' + JSON.stringify(response.getReturnValue()));
                        var result = response.getReturnValue();
                        console.log(' server Response: '+result);
                        if(result != "OK")
                        {
                            if(result === "KO"){
                                helper.showToast(component, event, helper, 'error', 'È necessario associare un agente a cui chiedere informazioni');
                            }
                            else if(result === "KOCliente"){
                                helper.showToast(component, event, helper, 'error', 'Attenzione, per inviare un case all\'agenzia inserire prima la scheda cliente');
                            }
                            component.set("v.MandatoryInputsMissing",true);
                            component.set("v.error","Attenzione, non è stato possibile procedere con l'operazione richiesta. Riprova più tardi, se il problema persiste contattaci telefonicamente.");
                        }
                        console.log(" +++++ ====> è console: " + sforce.console.isInConsole());
                        if(sforce.console.isInConsole() && result == "OK"){
                            console.log(' ===> is in console');
                            sforce.console.getEnclosingPrimaryTabId(function(primarytab)
                            {
                                console.log('primary: '+primarytab.id );
                                sforce.console.refreshPrimaryTabById(primarytab.id, 
                                    true, 
                                    function refreshSuccess(result) {
                                        //Report whether refreshing the primary tab was successful
                                        if (result.success == true) {
                                            console.log('Primary tab refreshed successfully');
                                        } else {
                                            console.log('Primary did not refresh');
                                        }
                                    }, true);
                                }); 
                                var myEvent = $A.get("e.c:tabclosing");
                                myEvent.setParams({"data":"cancel",
                                "recordid":component.get("v.caseId"),
                                "Url":component.get("v.OrgLink")});
                                myEvent.fire();
                            } else if(!sforce.console.isInConsole() && result == "OK") {
                                console.log(' ===> is in not console');
                                var myEvent = $A.get("e.c:tabclosing");
                                myEvent.setParams({"data":"cancel",
                                "recordid":component.get("v.caseId"),
                                "Url":component.get("v.OrgLink")});
                                myEvent.fire();                           
                                
                            }
                        
                    }
                    else if (state === "INCOMPLETE") {
                        if (component.get("v.jsDebug")) 
                        console.log('Incomplete state');
                    }
                    else if (state === "ERROR") {
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                if (component.get("v.jsDebug"))
                                console.log("Error message: " + errors[0].message);
                            }
                        } else {
                            if (component.get("v.jsDebug"))
                            console.log("Unknown error");
                        }
                    }
                    helper.stopSpinner(component);
                    
                });  
                $A.enqueueAction(action); 
              
        }
    
})