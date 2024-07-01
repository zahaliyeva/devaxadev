({
    doInitJS : function(component, event, helper) {

        if(component.get("v.pageReference")){
            var myPageRef = component.get("v.pageReference");
            var paramFlagVisualizza = myPageRef.state.c__visualizzaTutto;
            var paramLimit = myPageRef.state.c__limite;
            var paramStyleCss = myPageRef.state.c__styleIni;
            var paramAccount = myPageRef.state.c__account;
            component.set("v.visualizzaTutto", paramFlagVisualizza);
            component.set("v.limits", paramLimit);
            component.set("v.styleIni", paramStyleCss);
            component.set("v.account", paramAccount);       
        } 
        helper.helperMethod(component);
        helper.onSetColumnsAndQuickactions(component);

    },
    onVisualizzaTutto: function(component, event, helper) {
        helper.onVisualizzaTutto(component);
    },
    navigateToSObject: function (component, event, helper) {

        var row = event.getParam('row');
        var navService = component.find("navService");
        var pageReference = null;
            pageReference = {    
                "type": "standard__webPage",
                "attributes": {
                    "url": row.hyperlinkToSOL__c
                }
            };
        navService.navigate(pageReference);
    },
    handleSort: function(cmp, event, helper) {
        helper.handleSort(cmp, event);
    },
    doLoadMore:function (component, event, helper) {

        if(component.get('v.limits') >= component.get('v.count')){
            console.log('doLoadMore END'+component.get("v.count"));
            return;
        }else {
            component.set("v.limits", component.get("v.limits") + 10);
            helper.helperMethod(component);
            helper.onSetColumnsAndQuickactions(component);
        }
    }

})