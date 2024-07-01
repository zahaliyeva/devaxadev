({
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
    getDefectMdC : function(component){
        
        var caseId = component.get("v.CaseId");
        var action = component.get("c.getDefectMdC");
        action.setParams({"idCase" : caseId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var isdefect_MdC = response.getReturnValue();
                component.set("v.defect_MdC", isdefect_MdC);
            }
        });  
        $A.enqueueAction(action); 
        
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
		
	}
})