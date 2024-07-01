({
    onModifica : function(component, event, helper) {
        helper.onModifica(component);
    },

    doInit: function(component, event, helper) {       
        helper.manageCompanyNameClass(component);        
    },
    
    closeModal: function(component, event, helper){
        component.set('v.ShowModal', false );
    },
    openModal: function(component, event, helper){
        component.set('v.ShowModal', true);
    }
})