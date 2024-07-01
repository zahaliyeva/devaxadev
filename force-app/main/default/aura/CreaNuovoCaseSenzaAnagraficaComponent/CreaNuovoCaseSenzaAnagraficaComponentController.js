({
    createNewCaseNoAnagrafica : function(component,event,helper){        
        helper.createCaseNoAnagrafica(component,event,helper);        
    },
    showSpinner: function(component, event, helper) {
        component.set("v.Spinner", true); 
    },
    
    hideSpinner : function(component,event,helper){
        component.set("v.Spinner", false);
    },
    chiudiToast: function(component, event, helper){
    	component.set('v.ShowToast', false);
    }
})