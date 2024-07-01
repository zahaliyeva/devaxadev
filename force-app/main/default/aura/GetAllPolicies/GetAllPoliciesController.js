({
	doInit : function(component, event, helper) {
        
        console.log('doinit start method');
        helper.getPolicies(component, event, helper);
        if(component.get("v.mode") == 'CaringSalute' || component.get("v.mode") == 'CaringProperty' || component.get("v.UsrProfile").includes("Assistance") || component.get("v.UsrProfile").includes("SmartCenter")){
            component.set("v.isSinistri",true);
        }
	},
	vediGaranzie: function(component, event, helper) {
		console.log('vediGaranzie start method');
		var policyId = event.target.id;
        component.set("v.selectedPolicy", event.target);
        
		var row = event.target.parentElement.parentElement.parentElement;
		helper.highlightRow(component, event, helper, row);
		console.log('test : ',document.getElementById(policyId));
        if(component.get('v.mode') != "CaringProperty")
        helper.getAllGaranzie(component, event, helper, policyId);
        else{
            var policies = component.get("v.policies");
            var policy;
            for(var i = 0; i<policies.length; i++){
                if(policies[i].policyId === policyId){
                    policy = policies[i];
                    break;
                }
            }
            var garanzie = [];
            
            console.log("policy :"+policy);
            for(var i = 0; i < policy.assets.length; i++){
                var asset = policy.assets[i];
                console.log('Asset: ');
                console.log(asset);
                for(var j = 0; j<asset.coverages.length;j++){
            var temp = {};
                    var coverage = asset.coverages[j];
                    temp.GarBase = coverage.baseCoverage;
                    temp.GarSpec = coverage.specificCoverage;
                    temp.Description = coverage.descAssurance;
                    temp.TipoBene = asset.assetDescription;
                    if(!asset.address){
                        temp.UbicazioneRischio = '';
                    } else {
                        temp.UbicazioneRischio = (asset.address || '')+', '+ (asset.town || '') +', '+ (asset.zipCode || '') +', ' + (asset.province || '');
                    }
                    console.log("temp: " + temp);
                    garanzie.push(temp);
                    
                }
            }
            console.log(garanzie);
            component.set("v.garanzie",garanzie);
            component.set("v.isErrorGaranzie", false);
        }
	},
	associaPolizza: function(component, event, helper) {
		console.log('associaPolizza start method');
		var policyId = event.target.id;
		var row = event.target.parentElement.parentElement.parentElement;
		helper.highlightRow(component, event, helper, row);
		var policiesMap = component.get("v.policiesMap");
		console.log('policy clicked: ',policiesMap[policyId]);
		var myEvent = component.getEvent("associatePolicyToQuestionarioCA");
		if(!myEvent)
		{
			helper.showToast(component, event, helper, 'error', 'Attenzione ! Si è verificato un errore. Si prega di riprovare più tardi.'); 
		}
		else
		{
            if(policiesMap[policyId].commonData.nodeCode.startsWith("000729")){
                
                helper.showToast(component, event, helper, 'warning', 'Attenzione: La targa selezionata è relativa al dealing RCI. Ricordati le peculiarità di gestione.');
            }
	        myEvent.setParams({"policy": policiesMap[policyId],
                               "isGoldCustomer": component.get("v.clienteGOLD")});
	        myEvent.fire();
        }
	},
    chiudiToast : function(component, event, helper) {
    	component.set("v.messageToast", "");
    	component.set("v.typeToast", "");
    	component.set("v.showToast",false);
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
	
	/*RESIZE COLUMN*/	
	calculateWidth : function(component, event, helper) {
            var childObj = event.target
            var parObj = childObj.parentNode;
            var count = 1;
            while(parObj.tagName != 'TH') {
                parObj = parObj.parentNode;
                count++;
            }
            console.log('final tag Name'+parObj.tagName);
            var mouseStart=event.clientX;
            console.log('mouseStart: ',mouseStart);
            console.log('parObj.offsetWidth: ',parObj.offsetWidth);
            component.set("v.mouseStart",mouseStart);
            component.set("v.oldWidth",parObj.offsetWidth);
    },
    setNewWidth : function(component, event, helper) {
    		console.log('setNewWidth method');
            var childObj = event.target
            var parObj = childObj.parentNode;
            var count = 1;
            while(parObj.tagName != 'TH') {
                parObj = parObj.parentNode;
                count++;
            }
            var mouseStart = component.get("v.mouseStart");
            var oldWidth = component.get("v.oldWidth");
            var newWidth = event.clientX- parseFloat(mouseStart)+parseFloat(oldWidth);
            parObj.style.width = newWidth+'px';
    },
	/*RESIZE COLUMN*/
	
	Cancel: function(component, event, helper) {
		console.log('Cancel method');
	}
})