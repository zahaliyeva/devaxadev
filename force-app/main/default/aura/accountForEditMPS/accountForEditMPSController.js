({
    doInit : function(component, event, helper) {
	    console.debug('Sono dentro INit');

        helper.getData(component);

    },
    handleSubmit: function(component, event, helper) {
        
        helper.startSpinner(component);
        
    },

    handleSuccess: function(component, event, helper) {
        
        helper.stopSpinner(component);
        helper.showToast('Il record è stato aggiornato correttamente')
    },
    gotoURL : function (component, event, helper) {
        helper.redirectpage(component, event);   
        }
})