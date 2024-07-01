({
    doInit : function(component, event, helper) {
        let url = '/crm/' + component.get('v.recordId') + '/p';
        component.set('v.url', url);
    }
})