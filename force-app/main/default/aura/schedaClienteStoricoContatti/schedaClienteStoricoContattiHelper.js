({
    onVisualizzaTutto: function(component) {
        var navService = component.find("navService");
        var pageReference = {
                            "type": "standard__component",
                            "attributes": {  
                                            "componentName": "c__storicoContatti"
                                          }, 
                            "state": {
                                'c__numberOfRows': "0",
                                'c__recordId': component.get('v.accountId'),
                                'c__hasIconSVG': true
                            }
                           };
        navService.navigate(pageReference);
    }
})