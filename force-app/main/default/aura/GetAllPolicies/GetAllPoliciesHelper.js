({
	getPolicies : function(component, event, helper) {

	let fiscalCode = component.get("v.fiscalCode");
	let startDate = component.get("v.startDate");
	let targa = component.get("v.targa");
	var action = component.get("c.getPoliciesCTRL");        
	console.log("getPolicies - Fiscal Code: ", fiscalCode);
	console.log("getPolicies - Start Date: ", startDate);
	action.setParams({ "fiscalCode" : fiscalCode,
						"startDate" : startDate,
						"targa" : targa		
					 });
	component.set('v.isLoading', true);	
	action.setCallback(this, function(response) {
		var state = response.getState();
		if (state === "SUCCESS") {
			console.log("From server: ",response.getReturnValue());
			if(response.getReturnValue().isSuccess==true)
			{
				component.set("v.isSuccess", true);
				console.log("nodo policy", response.getReturnValue().deserializedResults);
				let tipoPolizza = component.get("v.tipoPolizza");
                let portfolio = component.get("v.portfolio");
                let isSchedaCliente = component.get("v.isSchedaCliente");
				if(!tipoPolizza.length){
					component.set("v.policies", response.getReturnValue().deserializedResults);
				} else {
					let filteredResults = response.getReturnValue().deserializedResults.filter(function(policy){
						return  tipoPolizza.includes(policy.commonData.type);
					});
                   
					if(isSchedaCliente && portfolio)
					{
						filteredResults = filteredResults.filter(function(policy){
						return  policy.portfolio == portfolio;
					    }); 
                    }
					if(!filteredResults.length){
						component.set("v.isSuccess", false);
						component.set("v.errorMessage", 'Nessuna Polizza presente per questa tipologia');
					}
					component.set("v.policies", filteredResults);
				}
				var policiesMap = component.get("v.policiesMap");
				console.log('policiesMap: ',policiesMap);
				var policies = component.get("v.policies");
				for(var i = 0; i < policies.length; i++)
				{
					policiesMap[policies[i].policyId] = policies[i];                      
				}
				component.set("v.policiesMap",policiesMap);
				console.log('policiesMap: ',policiesMap);
				component.set('v.isLoading', false);
			}
			else if(response.getReturnValue().isSuccess==false){
				component.set("v.errorMessage", response.getReturnValue().message);
				component.set("v.isSuccess", false);
				component.set('v.isLoading', false);
			}
			
		}
		else if (state === "INCOMPLETE") {
			// do something
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
getAllPolicies : function(component, event, helper) {

	let fiscalCode = component.get("v.fiscalCode");
	let accountId = component.get("v.accountId");
	var action = component.get("c.getAllPoliciesCTRL");
	console.log("getAllPolicies"+fiscalCode+' '+accountId+' '+component.get("v.CaseId"));
	action.setParams({ "fiscalCode" : fiscalCode ,
					   "accountId" : accountId,
					   "CaseId" : component.get("v.CaseId")//MOSCATELLI_M 18/03/2019: AXA Assistance
					 });
	component.set('v.isLoading', true);	
	action.setCallback(this, function(response) {
		var state = response.getState();
		if (state === "SUCCESS") {
			console.log("From server: ",response.getReturnValue());
			if(response.getReturnValue().isSuccess==true)
			{
				console.log("nodo policy", response.getReturnValue().deserializedResults);
				component.set("v.policies", response.getReturnValue().deserializedResults);
				component.set("v.isSuccess", true);
				var policiesMap = component.get("v.policiesMap");
				console.log('policiesMap: ',policiesMap);
				var policies = component.get("v.policies");
				for(var i = 0; i < policies.length; i++)
				{
					policiesMap[policies[i].policyId] = policies[i];                      
				}
				component.set("v.policiesMap",policiesMap);
				console.log('policiesMap: ',policiesMap);
				component.set('v.isLoading', false);
			}
			else if(response.getReturnValue().isSuccess==false){
				component.set("v.errorMessage", response.getReturnValue().message);
				component.set("v.isSuccess", false);
				component.set('v.isLoading', false);
			}
			
		}
		else if (state === "INCOMPLETE") {
			// do something
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
getAllGaranzie : function(component, event, helper, policyId) {
	//var GaranzieClienteGOLD = ['GASLG6','000336'];
	let fiscalCode = component.get("v.fiscalCode");
	var action = component.get("c.getAllGaranzieCTRL");
	action.setParams({ "fiscalCode" : fiscalCode ,
						"policyId" : policyId });
	component.set('v.isLoading', true);	
	action.setCallback(this, function(response) {
		var state = response.getState();
		if (state === "SUCCESS") {
			var result = response.getReturnValue();
			console.log('From Server: ',result);
			if(result!=null)
			{
				console.log('check code');
				console.log('nodo garanzie : '+response.getReturnValue());
				if(result.JSONToReturn!=null)
				{
					var garanzie = JSON.parse(result.JSONToReturn);
					var GaranzieClienteGOLD; 
					if(result.garanzieGOLD!=null)
					{
						GaranzieClienteGOLD = result.garanzieGOLD;
						console.log('GaranzieClienteGOLD: ',GaranzieClienteGOLD);
					}
					/*if(garanzie.coverages!=null)
					{
						console.log('garanzie: ',garanzie.coverages);
						console.log('garanzie.length: ',garanzie.coverages.length);
						for(var i = 0; i<garanzie.coverages.length; i++)
						{
							let garanzia = garanzie.coverages[i];
							if(garanzia.id!=null)
							{
								if(GaranzieClienteGOLD.includes(garanzia.id))
								{
									component.set("v.clienteGOLD",true);
									console.log('CLIENTE GOLD');
									break;
								}
							}
							
						}
						component.set("v.garanzie",garanzie);
						component.set("v.isErrorGaranzie", false);
					}*/
					
						console.log('garanzie: ',garanzie);
						console.log('garanzie.length: ',garanzie.length);
						component.set("v.clienteGOLD",false);
						for(var i = 0; i<garanzie.length; i++)
						{
							let garanzia = garanzie[i];
							if(garanzia.id!=null)
							{
								
								if(GaranzieClienteGOLD.includes(garanzia.id))
								{
									component.set("v.clienteGOLD",true);
									console.log('CLIENTE GOLD');
									break;
								}
							}
							
						}
						component.set("v.garanzie",garanzie);
						component.set("v.isErrorGaranzie", false);
					
				}
				else
				{
					component.set("v.isErrorGaranzie", true);
					component.set("v.errorMessageGaranzie", 'Attenzione ! Si è verificato il seguente errore:\n'+garanzie.code+' - '+garanzie.developerMessage+'\nContattare l\'Amministratore del sistema');
				}
			}
			
			component.set('v.isLoading', false);
			
		}
		else if (state === "INCOMPLETE") {
			// do something
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
	var data = component.get("v.policies");
	var reverse = sortDirection !== 'asc';

	data = Object.assign([],
		data.sort(this.sortBy(fieldName, reverse ? -1 : 1))
	);
	component.set("v.policies", data);
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
highlightRow: function(component, event, helper, row)
{
	console.log('highlightRow');
	var tBody = document.getElementById('tBodyPolicies');
	var allTr = tBody.childNodes;
	console.log('allTr.length: ',allTr.length);
	for (var i=0; i<allTr.length; i++) 
	{
		allTr[i].setAttribute("style", "background-color:#ffffff;");
	}
	console.log('row.id: ',row.id);
	row.setAttribute("style", "background-color:rgb(232, 232, 232);");
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