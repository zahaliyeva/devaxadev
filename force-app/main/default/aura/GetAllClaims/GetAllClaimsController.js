({
	doInit : function(component, event, helper) {
		console.log('doinit start method');
		
        console.log("href"+window.location.href);
        helper.initCmp(component, event, helper);
        helper.getAllClaimsSOL(component, event, helper);
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
	
	//OAVERSANO 14/03/2019 : AXA Assistance -- START
	Cancel : function(component, event, helper) {
		console.log('Cancel method');
		console.log('@@FIRE!!!');
		let originalCase = component.get("v.originalCase");
        var myEvent = $A.get("e.c:tabclosing");
    	myEvent.setParams({	"data":"cancel",
							"recordid": originalCase,
							"Url": ""});
		myEvent.fire();
	},
	creaCaseMonitoraggio : function(component, event, helper) {
		let caseId = event.target.name;
		let linkToSol = event.target.id;
        let claimNumber = event.target.getAttribute("data-claimId");
        if(component.get("v.lghtMode")){
            component.set('v.isLoading', true);
            let accountId = component.get("v.accountId");
            helper.handleCreaCaseDiMonitoraggioLightning(component, event, helper, caseId, linkToSol, claimNumber, false, accountId, event.target.getAttribute('data-isAssocia')).then(
                result => { 
                    component.set('v.isLoading', false);
                    helper.navigateToObject(component, result);
                }).catch(
                    errors => { 
                        component.set('v.isLoading', false);
                        component.set("v.isSuccess", false);
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                component.set("v.errorMessage", 'Si è verificato un errore: ' + errors[0].message);                  
                            }
                        }
                });
        } else {
            helper.creaCaseDiMonitoraggio(component, event, helper, caseId, linkToSol, claimNumber, false);
        }
    },
    
    handleRTEvent : function(component, event, helper)
    {
        console.log("handleRTEvent");
        var RTID = event.getParam("RTid");
        console.log("SelectedCaseType: "+RTID);
        let url = component.get("v.urlToOpen");
        url += '&RecordType='+RTID;
        helper.callEvent(component, event, helper, "openNewCasePage", "", url);
    }
	//OAVERSANO 14/03/2019 : AXA Assistance -- END
    //MDANTONIO 20/05/2019 : AXA Assistance enh. US-1018 - start
    ,
    getRelatedCases : function(component, event, helper) {
        let claimNumber = event.target.getAttribute("data-claimNumber");
        let caseId = event.target.getAttribute("data-caseId");
        helper.getRelatedCases(component, event, helper, claimNumber, caseId);
    },
    //MDANTONIO 20/05/2019 : AXA Assistance enh. US-1018 - end

    // FOZDEN 26/06/2019: AXA Assistance Enhancement Fase II -- START
    apriCaseSenzaSinistro: function(component, event, helper) {
        if(component.get("v.caseRT") == "AXA_Caring_Salute" && component.get("v.source")=="Phone"){
            if(component.get("v.lghtMode")){
                helper.handleCreateCaseLightning(component, helper).then(
                    result => { 
                        component.set('v.isLoading', false);
                        helper.navigateToObject(component, result);
                    }).catch(
                        errors => { 
                            component.set('v.isLoading', false);
                            component.set("v.isSuccess", false);
                            if (errors) {
                                if (errors[0] && errors[0].message) {
                                    component.set("v.errorMessage", 'Si è verificato un errore: ' + errors[0].message);                  
                                }
                            }
                    });;
            } else {
                helper.createCase(component, helper);
            }
        } else if(component.get("v.lghtMode")){
            component.set('v.isLoading', true);
            let accountId = component.get("v.accountId");
            helper.handleCreaCaseDiMonitoraggioLightning(component, event, helper, null, null, null, true, accountId, false).then(
                result => { 
                    component.set('v.isLoading', false);
                    helper.navigateToObject(component, result);
                }).catch(
                    errors => { 
                        component.set('v.isLoading', false);
                        component.set("v.isSuccess", false);
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                component.set("v.errorMessage", 'Si è verificato un errore: ' + errors[0].message);                  
                            }
                        }
                });
        } else {
            helper.creaCaseDiMonitoraggio(component, event, helper, null, null, null, true);
        }
    },

    closeCaseWithRTClaims: function(component, event, helper) {
            component.set("v.CaseWithRTClaims", false);
    }
    // FOZDEN 26/06/2019: AXA Assistance Enhancement Fase II -- END
})