({
    doInit : function(component, event, helper) {
        let pageReference = component.get("v.pageReference");
        if(pageReference && pageReference.state.c__accountId){
            component.set("v.accountId", pageReference.state.c__accountId);
        }
        if(pageReference && pageReference.state.c__title){
            component.set("v.title", pageReference.state.c__title);
        }
        if(pageReference && pageReference.state.c__iconName){
            component.set("v.iconName", pageReference.state.c__iconName);
        }
        helper.onSetColumnsAndQuickactions(component);
        helper.onGetRecords(component);
        helper.onGetCount(component);       
    },
    doLoadMore:function (component, event, helper) {
        if(component.get('v.countLazy') >= component.get('v.count')){
            return;
        }
        event.getSource().set("v.isLoading", true);
        var recordLimit = component.get("v.limits");
        let accountId = component.get('v.accountId');
        var action = component.get("c.getRecords");
        action.setParams({
            "id": accountId,
            "limits": recordLimit,
        });
        action.setCallback(this, function(response) {          
            var state = response.getState();     
            if (state === "SUCCESS" ) {
                component.set('v.data', response.getReturnValue());  
                component.set("v.limits", component.get("v.limits") + 10);
                event.getSource().set("v.isLoading", false);
                component.set("v.countLazy", component.get("v.data").length);
                console.log('Limits on Lad More', component.get("v.limits") );
            }
        });
        if(component.get('v.countLazy') == component.get('v.count')){
            event.getSource().set("v.isLoading", false);
         }
       else{
            $A.enqueueAction(action);
        }
    }
})