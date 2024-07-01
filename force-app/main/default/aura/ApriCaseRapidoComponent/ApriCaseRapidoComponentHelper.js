({
	 
    createCaseRapido: function(component, event, helper) {
        var action = component.get("c.getCaseRapidoPrepopulatedFields");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {

                let values = response.getReturnValue();

                let lobField = $A.get("$Label.c.LOB_ID");
                let lobValue = values["LOB__c"];
                if(lobValue == 'undefined' || lobValue == undefined) {
                    lobValue = '';
                }

                let categoryField = $A.get("$Label.c.Categoria_ID");
                let categoryValue = values["Category__c"];
                if(categoryValue == 'undefined' || categoryValue == undefined) {
                    categoryValue = '';
                }

                let RTID = component.get("v.SelectedCaseType");

                let url = '?cas11=Phone&cas7=Closed&' + lobField + '=' + lobValue + '&' +
                            categoryField + '=' + categoryValue + '&RecordType=' + RTID + '&classicEdit=true';

                console.log('** DBG | New Case Rapido URL: ' + url);

                this.callEvent(component, event, helper, "openNewCasePage", "", url);

            } else {
                var errors = response.getError();
                var toastEvent = $A.get("e.force:showToast");
                var msg = 'Unknown error';

                if (errors) {
                    if (errors[0] && errors[0].message) {
                        msg = errors[0].message;
                        console.log("Error message: " + msg);
                    }
                } else {
                    console.log(msg);
                }

                toastEvent.setParams({
                    "title": "Error",
                    "type": 'error',
                    "message": msg
                });
                toastEvent.fire();
            }
        });

        $A.enqueueAction(action);
    }, 

    callEvent : function(component, event, helper, data, recordId, Url) {
        var myEvent = $A.get("e.c:tabclosing");
        myEvent.setParams({ "data": data,
                            "recordid": recordId,
                            "Url": Url});
        myEvent.fire();
    }
})