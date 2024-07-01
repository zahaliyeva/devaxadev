({
    doInit : function(component, event, helper) {
        helper.setOptionsValue(component, event, helper);
        helper.isProfileHD2(component, event, helper);
        
        
    },
    
    closeModal : function(component, event, helper) {
        let visibilities = component.get('v.visibilities');
        if(visibilities){
            visibilities('NewCommentAndAttachmentLightning', false);
        }
        // when a component is dynamically created in lightning, we use destroy() method to destroy it.
        component.destroy();
    },
    
    // action to execute when save button is clicked
    handleSave : function(component, event, helper) {
        // We are showing an alert box here, you can perform any stuff here.
        console.log("VALORI",component.get("v.selectedValue"));
        
        if(component.get("v.selectedValue")!="" && component.get("v.selectedValue")!= null){
            
            helper.startSpinner(component); 
            helper.getOwnerIdForSend(component, event, helper);             
            
            
            //component.destroy(); 
        }
        
    },
    
    toggle : function (component, event, helper) {
        component.set("v.choiseSelectSend",component.find("mySelect").get("v.value"));
        var lista = component.get("v.availableValues");
        var valore = component.get("v.selectedValue");
        console.log("LISTA" , lista);
        console.log("VALORE", valore);
        for(var i = 0; i<lista.length; i++){
            if(lista[i].value == valore )
            component.set("v.selectedLabel",lista[i].label );
            
        }
        
      

        
    },
    
    saveQueue : function(component, event, helper){
        
        console.log("Save Owner: ", component.get("v.sendToOwenerId"));
        console.log("Save Label:", component.get("v.Label"));
        console.log("Save Selected Value:", component.get("v.selectedValue"));
        console.log("Save Selected Label:", component.get("v.selectedLabel"));
        console.log("Save RT:", component.get("v.rT"));
        
        console.log("Commento ", component.get("v.cmt"));
        if(component.get("v.cmt")==null || component.get("v.cmt")==undefined || component.get("v.cmt")==""){
        helper.showToast(component, event, helper, 'error', 'Attenzione ! Inserire un commento prima di inoltrare il case.');
        return
        }
 
            helper.startSpinner(component);           
            var attachmentList = component.get("v.attachmentList");
            var isHD2 = component.get("v.isHD2");
                  
            var action = component.get('c.NewsaveCommentAttachment');
            var params = {'cCase' : component.get("v.caseId"),
            "cmt" : component.get("v.cmt"), 
            "rT" : "Supporto", 
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
                console.log("ISHD2?", isHD2)
                if (state === "SUCCESS") {
            

                if(component.get("v.isHD2")==true){
                     
                        
                        location.reload();
                        
                    
                        }
                    else{
                        console.log('Success state');
                        //console.log('Data:' + JSON.stringify(response.getReturnValue()));
                        var result = response.getReturnValue();
                        console.log(' server Response: '+result);
                        if(result != "OK")
                        {
                            
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
                                if(component)
                                	component.destroy();
                                
                            }
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