({
	  getListOfRegularExpressions : function(component) {
        console.log('*** getListOfRegularExpressions');
        var action = component.get("c.getListOfRegularExpressions");
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('*** getListOfRegularExpressions - state: ' + state);
            if (state === "SUCCESS") {
                var response = response.getReturnValue();
                console.log("*** getListOfRegularExpressions - From server: " + JSON.stringify(response));    
                var validations = {};
                for (var i = 0; i < response.length; i++) {
					validations[response[i].QualifiedApiName] = response[i].RegEx__c;
                }
                
                var checkPhone = validations['National_Mobile_Phone_RegEx'] +'|'+ validations['Generic_Phone_RegEx'] ;
                 component.set("v.patternPhone", checkPhone);
               
                
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("*** getListOfRegularExpressions - Error message: " + errors[0].message);
                        var validations = {};
                        component.set("v.regEx", validations);
                    }
                } else {
                    console.log("getListOfRegularExpressions - Unknown error");
                    var validations = {};
                    component.set("v.regEx", validations);
                }
            }
        });
        $A.enqueueAction(action);
    },
})