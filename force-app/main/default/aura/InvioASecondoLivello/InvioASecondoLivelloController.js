({
    doInit : function(component, event, helper) {
        helper.setOptionsValue(component, event, helper);
        //helper.skipMappingAutomaticOwnerNMAConfiguration(component, event, helper);
        
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
        debugger;
        // We are showing an alert box here, you can perform any stuff here.
        console.log("VALORI",component.get("v.selectedValue"));
        let skipMappingAutomaticOwnerNMAConfiguration = component.get("v.skipMappingAutomaticOwnerNMAConfiguration");
        console.log('skipMappingAutomaticOwnerNMAConfiguration', skipMappingAutomaticOwnerNMAConfiguration);

        if(component.get("v.selectedValue")!="" && component.get("v.selectedValue")!= null){
            
            if(component.get("v.selectedValue")=="Selezione Manuale")  {

            helper.getOwnerIdForSendManualHD1IT(component, event , helper);     
            } else if (component.get("v.selectedValue")=="Selezione Automatica"){
                if(skipMappingAutomaticOwnerNMAConfiguration){
                    $A.enqueueAction(component.get('c.saveQueue'));
                } else {
                    helper.getOwnerIdForSendAutomaticHD1IT(component, event, helper);
                }
            }  else if(component.get("v.selectedValue")=="Vita")
            helper.getOwnerIdForSendAutomaticHD1Contabilita(component, event, helper); 
            else
            helper.getOwnerIdForSend(component, event, helper);             
            
            
            //component.destroy(); 
        }
        
    },
    
    toggle : function (component, event, helper) {
        component.set("v.choiseSelectSend",component.find("mySelect").get("v.value"));      
        console.log("send to "+component.get("v.selectedValue"));    
    },
    
    saveQueue : function(component, event, helper){
        
        console.log("Commento ", component.get("v.cmt"));
        let motivoDiTrasferimento = component.get("v.motivoTrasferimento");
        let commento = component.get("v.cmt");
        if((!motivoDiTrasferimento || motivoDiTrasferimento == 'Altro') && (!commento || !commento.trim())){
            helper.showToast(component, event, helper, 'error', 'Attenzione ! Inserire un commento prima di inoltrare il case.');
            return;
        }
 
            helper.startSpinner(component);           
            var attachmentList = component.get("v.attachmentList");
                  
            var action = component.get('c.NewsaveCommentAttachment');
            var params = {'cCase' : component.get("v.caseId"),
            "cmt" : component.get("v.cmt"), 
            "rT" : 'Supporto', 
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
                            console.log("RESULTNOTOK");
                            component.set("v.MandatoryInputsMissing",true);
                            component.set("v.error","Attenzione, non è stato possibile procedere con l'operazione richiesta. Riprova più tardi, se il problema persiste contattaci telefonicamente.");
                            helper.showToastStandard(component, event, helper, 'Error','error', result);
                          
                        }
                   
                    if(window.location.pathname.indexOf('lightning')!=1){
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
                                
                            }}
                    else{
                        component.destroy()
                    $A.get('e.force:refreshView').fire();    
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
              
        },
          
    })