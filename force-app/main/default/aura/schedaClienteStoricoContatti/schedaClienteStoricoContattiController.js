({
    onVisualizzaTutto: function(component, event, helper) {
        helper.onVisualizzaTutto(component);
    },
    handleStoricoContattiError: function(component){
        component.set('v.disableVisualizzaTutto', true);
    }
})