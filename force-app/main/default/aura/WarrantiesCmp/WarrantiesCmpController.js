({
	doInit: function(component, event, helper) {
        console.log("@@quotazioneId: " + component.get("v.recordId"));

        component.set('v.columns', [
            {label: 'Nome', fieldName: 'Name', type: 'text'},
            {label: 'Massimale', fieldName: 'Limits', type: 'text'},
            {label: 'Franchigia', fieldName: 'Exemption', type: 'text'},
            {label: 'Capitale Assicurato', fieldName: 'InsuredQuantity', type: 'text'},
            {label: 'Prezzo', fieldName: 'Price', type: 'text'},
            {label: 'Prezzo Originale', fieldName: 'OriginalPrice', type: 'text'}
        ]);

        helper.setDataTable(component);
    },
    navigateTo: function(component, event, helper) {
    	helper.navigateTo(component);
    }
})