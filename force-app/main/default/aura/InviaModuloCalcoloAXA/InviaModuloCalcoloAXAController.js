({  doInit : function(component, event, helper) {

    
    
    var action = component.get("c.getOwnerQueueIdFromDevName");
        
    var params = {devName: "HD2_Modulo_di_Calcolo_AXA" };
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

    saveQueue : function(component, event, helper){
        
        
        if(component.get("v.cmt")==null || component.get("v.cmt")==undefined || component.get("v.cmt")==""){
        helper.showToast(component, event, helper, 'error', 'Attenzione ! Inserire un commento prima di inoltrare il case.');
        return
        }
 
        
        component.set("v.Label", "Supporto Modulo di Calcolo AXA");
        component.get("v.defect_MdC");
        
        
        
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
            "defectCheckbox" : component.get("v.defect_MdC"),
            "motivoTrasferimento" : component.get("v.motivoTrasferimento"),
            "selectedValue" : component.get("v.selectedValue"),
            "selectedLabel" : component.get("v.selectedLabel"),
            "OwnerId" : component.get("v.sendToOwenerId")}
            
            action.setParams(params);
            action.setCallback(this, function(response) {
                
                var state = response.getState();
                console.log("state --> "+state);
                
                var state = response.getState();
                if (state === "SUCCESS") {
                    console.log('Success state');
                    //console.log('Data:' + JSON.stringify(response.getReturnValue()));
                    var result = response.getReturnValue();
                    
                    if(result != "OK")
                    {
                    	console.log("output ==> " + result);
                        helper.stopSpinner(component);
                        component.set("v.isOpen", true);
                        component.set("v.isOpenModal", true);
                        component.set("v.MandatoryInputsMissing",true);
                        component.set("v.error","Attenzione, non è stato possibile procedere con l'operazione richiesta. Riprova più tardi, se il problema persiste contattaci telefonicamente");
                    }
                    else{
                        location.reload();
                        //window.location.href =  '/lightning/r/Case/'+component.get("v.CaseId")+'/view';
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