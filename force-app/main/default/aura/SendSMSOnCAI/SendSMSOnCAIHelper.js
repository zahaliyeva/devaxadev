({

       showToast : function(component, event, helper, type, message, detailsMessage) 
    {
 
        console.log('showToast method');
        component.set("v.messageToast", message);
        component.set("v.DetailsMessageToast", detailsMessage)
        component.set("v.typeToast", type);
        component.set("v.showToast",true);
    },
})