({
	startSpinner: function (component) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, 'slds-hide');
        //console.log("SPINNER START SU RITORNA PRIMO LIVELLO");
    },

    stopSpinner: function (component) {
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, 'slds-hide');
        //console.log("SPINNER STOP SU RITORNA PRIMO LIVELLO");
    },
	startSpinnerModal: function (component) {
        var spinner = component.find("mySpinnerModal");
        $A.util.removeClass(spinner, 'slds-hide');
        //console.log("SPINNER START SU RITORNA PRIMO LIVELLO");
    },

    stopSpinnerModal: function (component) {
        var spinner = component.find("mySpinnerModal");
        $A.util.addClass(spinner, 'slds-hide');
        //console.log("SPINNER STOP SU RITORNA PRIMO LIVELLO");
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
			}), 5000
		);
		
	},
    //DARIO
    getCaseValues : function(component, event, helper)  {
		
        var action = component.get("c.getCaseValues");
        
        let caseId = component.get("v.caseId")
        var params = {"CaseId": caseId};
        action.setParams(params);
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
            let TRValues = response.getReturnValue().TagRichiestaValues;
            let TR = response.getReturnValue().TagRichiesta;
            let blockButton = response.getReturnValue().BlockButton;
            let TicketTypeSilva = response.getReturnValue().TipologiaTicketSilva;
            let ApplicationNameSilva = response.getReturnValue().NomeApplicazioneSilva;
            let tagRSilva = response.getReturnValue().TagRichiestaNeedSilva;

                console.log(response.getReturnValue());
                component.set("v.tagRichiestaValues" , TRValues);
                component.set("v.tagRichiesta" , TR);
                component.set("v.block1LevelButton", blockButton);
                component.set("v.nomeApplicazioneSilva", ApplicationNameSilva);
                component.set("v.tipologiaTicketSilva", TicketTypeSilva);
                component.set("v.tagRNeedSilva", tagRSilva);
            }

        });  
        $A.enqueueAction(action); 
        //DARIO
    
	}
})