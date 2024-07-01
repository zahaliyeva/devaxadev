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
            "rT" : component.get("v.rT"), 
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

                    //ECLEMENTE - 27/02/2024 - START: ADDED AND SPLIT CONSTANT RESULT IN TWO STRING
                    const myArray = result.split(";");
                    console.log('myArray: '+myArray);

                    var resultCheck = myArray[0];
                    var errorMe = myArray[1];
                    //ECLEMENTE - 27/02/2024 - END
                    
                    if(resultCheck != "OK")
                    {
                    	console.log("output ==> " + resultCheck);
                        helper.stopSpinner(component);
                        component.set("v.isOpen", true);
                        component.set("v.isOpenModal", true);
                        component.set("v.MandatoryInputsMissing",true);
                        component.set("v.error","Attenzione, non è stato possibile procedere con l'operazione richiesta. Riprova più tardi, se il problema persiste contattaci telefonicamente");
                    	//ECLEMENTE - 27/02/2024 - START: ADDED "ELSE IF " 'COMMENT' TO CHECK IF THE LIMIT OF 1000 CHAR IS PASSED
                        if(resultCheck === "KOCliente"){
                            helper.showToast(component, event, helper, 'error', 'Attenzione, per inviare un case all\'agenzia inserire prima la scheda cliente');
                        }else if(resultCheck === "COMMENTO"){
                            console.log("ENTER IF COMM ==> " + resultCheck);
                            helper.showToast(component, event, helper, 'error', errorMe);
                        }
                        //ECLEMENTE - 27/02/2024 - END
                    }
                    else{
                         $A.get('e.force:refreshView').fire();
                    }
                }
                else if (state === "INCOMPLETE") {
                    helper.stopSpinner(component);
                    component.set("v.isOpen", true);
                    component.set("v.isOpenModal", true);
                    if (component.get("v.jsDebug")) 
                        console.log('Incomplete state');
                }
                else if (state === "ERROR") {   
                    helper.stopSpinner(component);                 
                    component.set("v.isOpen", true);
                    component.set("v.isOpenModal", true);
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