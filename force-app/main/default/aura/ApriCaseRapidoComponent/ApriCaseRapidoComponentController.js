({
   showCaseRapidoModal: function(component, event, helper) {
        component.set("v.showCaseRapidoModal",true);
    },

    closeCaseRapidoModal: function(component, event, helper) {
        component.set("v.showCaseRapidoModal",false);
    },
     handleRTEvent: function(component,event,helper)
    {
        console.log("parent");
        var RTID = event.getParam("RTid");
        console.log("SelectedCaseType: "+RTID);
        component.set("v.SelectedCaseType",RTID);

        if(event.getParam("isCaseRapido")) { 
            component.set("v.showCaseRapidoModal", false);
            helper.createCaseRapido(component, event, helper);

        } else {
         
        }
    },
})