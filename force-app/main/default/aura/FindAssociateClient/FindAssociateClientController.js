({
	doInit : function(component, event, helper) {
		console.log('doInit method');
		console.log('tipoCliente: ', component.get("v.tipoCliente"));
        console.log('tipoAccount: ',component.get("v.tipoAccount"));
	},
	findPersonaFisica : function(component, event, helper) {
		console.log('findPersonaFisica method');
		helper.findPersonaFisicaList(component, event, helper);
	},
	findPersonaGiuridica : function(component, event, helper) {
		console.log('findPersonaGiuridica method');
		helper.findPersonaGiuridicaList(component, event, helper);
	},
	associaCliente : function(component, event, helper) {
		console.log('associaCliente method');
		var clientId = event.target.id;
		var persona = event.target.name;
		var clientiMap = component.get("v.clientiMap");
		var type = component.get("v.tipoCliente");
		console.log('client clicked: ',clientiMap[clientId]);
		console.log('type: ',type);
		console.log('persona: ',persona);
		var myEvent = component.getEvent("associateClientToQuestionarioCA");
		console.log('myEvent: ',myEvent);
		if(!myEvent)
		{
			helper.showToast(component, event, helper, 'error', 'Attenzione ! Si è verificato un errore. Si prega di riprovare più tardi.'); 
		}
		else
		{
			myEvent.setParams({"client": clientiMap[clientId],
        					"type": type,
        					"persona": persona});
			myEvent.fire();
		}
        
	},
	/*SORT ROWS*/
	updateColumnSorting: function (component, event, helper) {
        component.set('v.isLoading', true);
        setTimeout(function() {
            var fieldName = event.target.id;
            console.log('fieldName: '+fieldName);
            if(component.get("v.sortDirection")=="asc"){
            	component.set("v.sortIconName","utility:chevronup");
            	component.set("v.sortDirection","desc");
            }
            else{
            	component.set("v.sortIconName","utility:chevrondown");
            	component.set("v.sortDirection","asc");
            }
            var sortDirection = component.get("v.sortDirection");
            console.log('sortDirection: '+sortDirection);
            component.set("v.sortedBy", fieldName);
            component.set("v.sortedDirection", sortDirection);
            helper.sortData(component, fieldName, sortDirection);
            component.set('v.isLoading', false);
        }, 0);
    },
    /*SORT ROWS*/
    handleSelect : function(component, event, helper)
    {
    	console.log('handleSelect');
    	component.set("v.clienti", {});
    },
    chiudiToast : function(component, event, helper) {
    	component.set("v.messageToast", "");
    	component.set("v.typeToast", "");
    	component.set("v.showToast",false);
	}
})