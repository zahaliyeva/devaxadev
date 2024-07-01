({
	findPersonaFisicaList : function(component, event, helper) {
		console.log('findClientList method');
		let nomeCliente = component.get("v.nomeCliente");
		let cognomeCliente = component.get("v.cognomeCliente");
		let polizzaCliente = component.get("v.polizzaCliente");
		let codiceFiscaleCliente = component.get("v.codiceFiscaleCliente");
		let targaCliente = component.get("v.targaCliente");
        var action = component.get("c.findPersonaFisicaListCTRL");
        action.setParams({ "nomeCliente" : nomeCliente,
        					"cognomeCliente" : cognomeCliente,
        					"polizzaCliente" : polizzaCliente,
        					"codiceFiscaleCliente" : codiceFiscaleCliente,
        					"targaCliente" : targaCliente,
                            "datanascita" : component.get("v.nascitaCliente")//MOSCATELLI_M 27/11/2018: CR Caring Angel
        					});
        component.set('v.isLoading', true);	
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("From server: ",response.getReturnValue());
                var result = response.getReturnValue();
                if(result!=null)
                {
                	component.set("v.clienti",result);
                	component.set("v.errorMessage","");
                	var clientiMap = component.get("v.clientiMap");
                	var clienti = component.get("v.clienti");
	                for(var i = 0; i < clienti.length; i++)
	                {
	                	clientiMap[clienti[i].Id] = clienti[i];
	                }
	                if(clienti.length==0)
	                {
	                	component.set("v.errorMessage","Nessun risultato trovato.");
	                }
                }
                component.set('v.isLoading', false);
            }
            else if (state === "INCOMPLETE") {
            	component.set("v.errorMessage",'Server could not be reached. Check your internet connection.');
                component.set("v.isSuccess", false);
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                                 component.set("v.errorMessage",errors[0].message);
                                 component.set("v.isSuccess", false);
                                 
                    }
                } else {
                    console.log("Unknown error");
                    component.set("v.errorMessage","Unknown error");
                    component.set("v.isSuccess", false);
                }
                component.set('v.isLoading', false);
            }
        });
        $A.enqueueAction(action);
	},
	findPersonaGiuridicaList : function(component, event, helper) {
		console.log('findClientList method');
		let ragioneSociale = component.get("v.ragioneSociale");
		let polizzaB2BClient = component.get("v.polizzaB2BClient");
		let partitaIVA = component.get("v.partitaIVA");
        var action = component.get("c.findPersonaGiuridicaListCTRL");
        action.setParams({ "ragioneSociale" : ragioneSociale,
        					"polizzaB2BClient" : polizzaB2BClient,
        					"partitaIVA" : partitaIVA
        					});
        component.set('v.isLoading', true);	
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("From server: ",response.getReturnValue());
                var result = response.getReturnValue();
                if(result!=null)
                {
                	component.set("v.clienti",result);
                	var clientiMap = component.get("v.clientiMap");
                	var clienti = component.get("v.clienti");
	                for(var i = 0; i < clienti.length; i++)
	                {
	                	clientiMap[clienti[i].Id] = clienti[i];
	                }
                    
	                if(clienti.length==0)
	                {
	                	component.set("v.errorMessage","Nessun risultato trovato.");
	                }
                }
                component.set('v.isLoading', false);
            }
            else if (state === "INCOMPLETE") {
                component.set("v.errorMessage",'Server could not be reached. Check your internet connection.');
                component.set("v.isSuccess", false);
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                                 component.set("v.errorMessage",errors[0].message);
                                 component.set("v.isSuccess", false);
                                 
                    }
                } else {
                    console.log("Unknown error");
                    component.set("v.errorMessage","Unknown error");
                    component.set("v.isSuccess", false);
                }
                component.set('v.isLoading', false);
            }
        });
        $A.enqueueAction(action);
	},
	sortData: function (component, fieldName, sortDirection) {
        var data = component.get("v.clienti");
        var reverse = sortDirection !== 'asc';

        data = Object.assign([],
            data.sort(this.sortBy(fieldName, reverse ? -1 : 1))
        );
        component.set("v.clienti", data);
    },
    sortBy: function (field, reverse, primer) {
        var key = primer
            ? function(x) { return primer(x[field]) }
            : function(x) { return x[field] };

        return function (a, b) {
            var A = key(a)?key(a):'';
            var B = key(b)?key(b):'';
            return reverse * ((A > B) - (B > A));
        };
    },
    showToast : function(component, event, helper, type, message) 
    {
    	component.set("v.messageToast", message);
    	component.set("v.typeToast", type);
    	component.set("v.showToast",true);
    	window.setTimeout(
			$A.getCallback(function() {
				component.set("v.messageToast", "");
		    	component.set("v.typeToast", "");
		    	component.set("v.showToast",false);
			}), 3000
    	);
	}
})