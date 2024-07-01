({
    doInit: function(component, event, helper) {
        helper.getOrgURL(component);          
    },
    cancelBtn : function(component, event, helper) { 
        helper.cancelBtn(component);
    }, 
    closeCaseBtn : function(component, event, helper) {
        helper.closeCaseBtn(component);
    },
    CloseMissingInputsModal: function(component,event,helper){
        helper.closeMissingInputsModal(component);
    },    
    closePage : function(component,event,helper){
        helper.closePage(component);
    },
    
    // this function automatic call by aura:waiting event  
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true); 
    },
    
    // this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hide loading spinner    
        component.set("v.Spinner", false);
    },
    //OAVERSANO 30/10/2018 : Nuovo Modello di Assistenza ENHANCEMENT -- START
    countCharacters: function(component,event,helper){
        let value =  event.getSource().get("v.value");
        let charactersN = value.length;
        component.set("v.remainingCharacters",1000-charactersN);
    },
    //OAVERSANO 30/10/2018 : Nuovo Modello di Assistenza ENHANCEMENT -- END  
    
})