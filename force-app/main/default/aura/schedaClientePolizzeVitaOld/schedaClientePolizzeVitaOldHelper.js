({
    parseResponse: function(component, returnValue){
        component.set("v.polizze", returnValue.polizze);
        component.set("v.polizzeAttive", returnValue.polizzeAttive);
    },
    onVisualizzaTutto: function(component) {
        var navService = component.find("navService");
        var pageReference = {
            "type": "standard__component",
            "attributes": {  
                "componentName": "c__schedaClientePolizzeLazyOld"
            }, 
            "state": {
                'c__accountId': component.get('v.accountId'),
                'c__asaJson': JSON.stringify(component.get('v.asa')),
                'c__title': 'Polizze Vita',
                'c__iconName': 'custom:custom50'
            }
        };
        navService.navigate(pageReference);
    }

})