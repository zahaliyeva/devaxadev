({
    parseResponse: function(component, returnValue){
        component.set("v.cases", returnValue);
    },
    onVisualizzaTutto: function(component) {
        var navService = component.find("navService");
        var pageReference = {
            "type": "standard__component",
            "attributes": {  
                "componentName": "c__schedaClienteCaseLazy"
            }, 
            "state": {
                'c__accountId': component.get('v.accountId'),
                'c__title': 'Case',
                'c__iconName': 'standard:case'
            }
        };
        navService.navigate(pageReference);
    },
    onNuovo: function(component, event){
            let recordId = component.get("v.accountId");
            var navService = component.find("navService");
            var pageReference = {
                type: 'standard__objectPage',
                attributes: {
                    objectApiName: 'Case',
                    actionName: 'new'
                },
                state: {
                    defaultFieldValues: {
                        AccountId: recordId
                    }
                }
            };
            navService.navigate(pageReference);
    }

})