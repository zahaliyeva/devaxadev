({
	prendiInCarico: function(component, event, helper) {
    	console.log('User ID: '+$A.get("$SObjectType.CurrentUser.Id"));
        console.log('Owner Id '+component.get("v.simpleRecord.OwnerId"));
        
        if(($A.get("$SObjectType.CurrentUser.Id")!=component.get("v.simpleRecord.OwnerId")) /*&& component.get("v.simpleRecord.OwnerId").startsWith('00G')*/)
        {
        	console.log('Owner Id!=USERId')
            component.set("v.showError",false);
            //component.set("v.simpleRecord.Status","Assigned");
            component.set("v.oldOwner", "v.simpleRecord.OwnerId");
            component.set("v.simpleRecord.OwnerId",$A.get("$SObjectType.CurrentUser.Id"));
            component.find("recordEditor").saveRecord($A.getCallback(function(saveResult) {
                if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                    console.log("Save completed successfully.");
                    window.location.reload(true);
                } else if (saveResult.state === "INCOMPLETE") {
                    console.log("User is offline, device doesn't support drafts.");
                } else if (saveResult.state === "ERROR") {
                    console.log('Problem saving record, error: ' + 
                               JSON.stringify(saveResult.error));
                    component.set("v.simpleRecord.OwnerId", "v.oldOwner");
                    component.set("v.Errorchecked",(saveResult.error[0].message));
                    component.set("v.showError",true);
                } else {
                    console.log('Unknown problem, state: ' + saveResult.state + ', error: ' + JSON.stringify(saveResult.error));
                }
            }));
        }
        //OAVERSANO 30/10/2018 : Nuovo Modello di Assistenza AXA MPS -- Sprint 84 | US-0911 -- START
        /*else if(($A.get("$SObjectType.CurrentUser.Id")!=component.get("v.simpleRecord.OwnerId")) && !component.get("v.simpleRecord.OwnerId").startsWith('00G'))
        {
            console.log('different user');
            component.set("v.showError",true);
            component.set("v.Errorchecked","Il case non può essere preso in gestione in quanto è già in carico ad un altro Advisor");   
        }*/
        //OAVERSANO 30/10/2018 : Nuovo Modello di Assistenza AXA MPS -- Sprint 84 | US-0911 -- END
    },
       closeModel: function(component, event, helper) {
       component.set("v.showError", false);
   },

})