({
    handleCancel : function(component, event, helper) {
    	//OAVERSANO 18/12/2018 : Enhancement NMA Biz III -- START
    	var myEvent = $A.get("e.c:ModalConfirmFunctionEvent");
    	myEvent.setParams({"buttonValue": "cancel"});
        myEvent.fire();
        //component.find("overlayLib").notifyClose(); //performed in parent Component
    	//OAVERSANO 18/12/2018 : Enhancement NMA Biz III -- END
    },
    handleOK : function(component, event, helper) {
        var myEvent = $A.get("e.c:ModalConfirmFunctionEvent");
        myEvent.fire();
    }
})