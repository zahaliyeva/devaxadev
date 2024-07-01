({
    doInit: function(component, event, helper) {        
        helper.checkError(component,event,helper);
        helper.getOrgURL(component,event,helper);
    }, 

    cancelBtn : function(component, event, helper) { 
        helper.cancelBtn(component);
    }, 

    clickCreate : function(component, event, helper) {
        helper.clickCreate(component,event,helper);
    },
    CloseMissingInputsModal: function(component,event,helper){
        helper.closeMissingInputsModal(component);
    },    
    closeComment : function(component,event,helper){
        helper.closeComment(component,event,helper);
    },
    //OAVERSANO 30/10/2018 : Nuovo Modello di Assistenza ENHANCEMENT -- START
    countCharacters: function(component,event,helper){
        let value =  event.getSource().get("v.value");
        let charactersN = value.length;
        component.set("v.remainingCharacters",1000-charactersN);
    },
    //OAVERSANO 30/10/2018 : Nuovo Modello di Assistenza ENHANCEMENT -- END
})