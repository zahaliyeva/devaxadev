({
    onGetRecords : function(component) {
        var action = component.get("c.getRecords");
        let accountId = component.get('v.accountId');
        action.setParams({
            "id" : accountId,
            "limits": component.get("v.limits"),
        });
        action.setCallback(this, function(response) {     
           var state = response.getState();
            if (state === "SUCCESS" ) {
                component.set("v.data",response.getReturnValue());
                component.set("v.limits", component.get("v.limits") + 10);
                console.log('Limits on Get Records', component.get("v.limits") );
            }
        });
        $A.enqueueAction(action);
    },
    onSetColumnsAndQuickactions: function(component){
        component.set('v.columns',[
            {label:'Id', fieldName:'Id', type:'url', shortable: true, hideDefaultActions: true, typeAttributes: {
                    label: { fieldName: 'Id' }
                }
            },
            {label: 'Area', fieldName:'LOB', type:'text', shortable: true, hideDefaultActions: true},
            {label: 'Data Apertura', fieldName:'createdDate', type:'date', shortable: true, hideDefaultActions: true, typeAttributes: {
                day: '2-digit',
                month: '2-digit',
                year: 'numeric',
                hour: '2-digit',
                minute: '2-digit'
        }},
            {label: 'Mittente', fieldName:'mittente', type:'text', shortable: true, hideDefaultActions: true},
            {label: 'Titolare', fieldName:'owner', type:'text', shortable: true, hideDefaultActions: true},
            {label: 'Stato', fieldName:'stato', type:'text', shortable: true, hideDefaultActions: true},
            {label: 'IVR', fieldName:'IVR', type:'text', shortable: true, hideDefaultActions: true}
        ] 
          );
    },
   onGetCount : function(component) {
        var action = component.get("c.getCount");
        let accountId = component.get('v.accountId');
        action.setParams({
            "id" : accountId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS" ) {
                var resultData = response.getReturnValue();
                component.set("v.count", resultData);
            }
        });
        $A.enqueueAction(action);
    },
    setFocusedTabLabel : function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.setTabLabel({
                tabId: focusedTabId,
                label: component.get('v.title')
            });
            workspaceAPI.setTabIcon({
                tabId: focusedTabId,
                icon: component.get('v.iconName')
            });
        })
        .catch(function(error) {
            console.log(error);
        });
    }
})