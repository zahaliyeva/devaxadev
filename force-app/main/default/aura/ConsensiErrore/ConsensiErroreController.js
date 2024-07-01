({
	  handleAccountReceived: function(component, event, helper) {
        var receivedAccount = event.getParam("containedAccount");
        console.log("EVENTO RICEVUTO");
        //component.find("CIF_Privacy_1").set("v.value", "Sì");
    }
})