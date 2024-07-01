({
    parseResponse: function(component, returnValue){
        component.set("v.vCall", returnValue);
    },
    onVisualizzaTutto: function(component) {
        var navService = component.find("navService");
        var pageReference = {
            "type": "standard__component",
            "attributes": {  
                "componentName": "c__schedaClienteVoiceCallLazy"
            }, 
            "state": {
                'c__accountId': component.get('v.accountId'),
                'c__title': 'Voice Call',
                'c__iconName': 'standard:call'
            }
        };
        navService.navigate(pageReference);
    },

})