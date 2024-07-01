({
    parseResponse: function(component, returnValue){
        component.set("v.campaignMembers", returnValue);
    },
    onVisualizzaTutto: function(component) {
        var navService = component.find("navService");
        var pageReference = {
            "type": "standard__component",
            "attributes": {  
                "componentName": "c__schedaClienteCampagneLazy"
            }, 
            "state": {
                'c__accountId': component.get('v.accountId'),
                'c__title': 'Storico Campagne',
                'c__iconName': 'standard:campaign'
            }
        };
        navService.navigate(pageReference);
    }
})