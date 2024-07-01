({
	checkProfile : function(component, event, helper) {

		component.find('notifLib').showToast({
            "title": "Privilegi insufficienti!",
			"message": "Non si dispone dei permessi necessari per eseguire l'operazione",
			"variant": "error",
			"mode": "pester"
        });
	},
	
	checkDocument : function(component, event, helper){

		component.find('notifLib').showToast({
            "title": "Errore!",
			"message": "Il Case non dispone di un documento da visualizzare",
			"variant": "error",
			"mode": "pester"
        });

	}
	
})