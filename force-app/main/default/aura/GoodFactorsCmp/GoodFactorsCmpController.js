({
	doInit: function(component, event, helper) {
        console.log("@@quotazioneId: " + component.get("v.recordId"));

        component.set('v.columns', [
            {label: 'Nome', fieldName: 'Name', type: 'text'},
            {label: 'Valore', fieldName: 'Value', type: 'text'}
        ]);

        helper.setDataTable(component);
    },
    navigateTo: function(component, event, helper) {
    	helper.navigateTo(component);
    }
})