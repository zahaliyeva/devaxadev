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