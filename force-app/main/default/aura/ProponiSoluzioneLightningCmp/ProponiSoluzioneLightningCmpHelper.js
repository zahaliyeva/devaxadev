({
    //OAVERSANO 18/12/2018 : Enhancement NMA Biz III -- START
    deleteAttachments: function (component,attachmentList) 
    {
    	console.log("deleteAttachments method");
        var action = component.get("c.deleteAttachments");             
        var params = {"attachmentIds": attachmentList};
        action.setParams(params);
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if (component.get("v.jsDebug"))
                    console.log('Success state');
            }
            else if (state === "INCOMPLETE") {
                if (component.get("v.jsDebug"))
                    console.log('Incomplete state');
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            if (component.get("v.jsDebug"))
                                console.log("Error message: " + errors[0].message);
                        }
                    } else {
                        if (component.get("v.jsDebug"))
                            console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);  
        component.find("overlayLib").notifyClose();
    },
    //OAVERSANO 18/12/2018 : Enhancement NMA Biz III -- END
})