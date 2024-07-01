({
    checkQueueNameOwner : function(component, event, helper, message){
		component.find('notifLib').showToast({
            "title": "Errore!",
			"message": message,
			"variant": "error",
            "duration": "250000",
            "mode": "dismissible"
        });
    },

    redirect : function(component, event, helper){
		const pathName = window.location.pathname;
        const myURL = "https://" + window.location.hostname + "/crm/s/case/" + component.get("v.caseId") + "/detail";
        window.location.href = myURL;
    }
})