({
    getCaseInfo : function(component,event,helper){
        var action = component.get("c.getCaseFields");
        action.setParams({ 
            "caseId" : component.get("v.caseId")
        });
        action.setCallback(this, function(response){
            component.set("v.case", response.getReturnValue());
        });
        $A.enqueueAction(action);
    },
    
    setOptionsValue : function(component, event, helper)  {
        var action = component.get("c.getOptionsValuesInviaAdAltraArea");
        var caseId = component.get("v.caseId");  
        var params = {"caseId": caseId};
        action.setParams(params);
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                let options=response.getReturnValue();
                console.log("RESPONSE DEI VALORI", options);
                component.set("v.availableValues" ,options);    
            }
        });  
        $A.enqueueAction(action);  
    },
    
    getOwnerIdForSend : function(component, event, helper){
        var action = component.get("c.getOwnerQueueIdFromDevName");
        var Queue;
        var caseInfo = component.get("v.case");
        if(component.get("v.selectedValue")=='HD1_ContabilitaVita' || component.get("v.selectedValue")=='HD1_ContabilitaDanni'){
            Queue='HD1_Contabilita';
            component.set("v.selectedValue",'HD1_Contabilita');
        }else if(component.get("v.selectedValue")=='HD1_IT_AAI_VITA_LOL') {
            //vita lol
            console.log("vita lol");
            Queue ='HD1_Biz_Vita';
            component.set("v.selectedValue",'HD1_Biz_Vita');
        }        
            else{
                console.log("else");
                Queue = component.get("v.selectedValue");
            }
        console.log("queue: "+Queue);
        var params = {devName: Queue };
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
    
    showToast : function(component, event, helper, type, message){
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
    
    isProfileHD2 : function (component, event, helper){
        var action = component.get("c.checkProfileHD2");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                let results=response.getReturnValue();
                if(results)
                    component.set("v.isHD2",true);
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
        });
        $A.enqueueAction(action);
    }   
})