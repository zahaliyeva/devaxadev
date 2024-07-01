({
	doInit : function(component, event, helper) {
		console.log('doInit');

		let action = component.get("c.getCaseDetail");
        let caseId = component.get("v.recordId");
        console.log('caseId = '+caseId);
        action.setParams({"caseId" : caseId});
		action.setCallback(this, function(response){
			console.log(response.getReturnValue());
            var state = response.getState();
            if (state === "SUCCESS") {
			let result = response.getReturnValue();
			component.set('v.caseStatus',result.currentCase.Status);
                console.log('Recupero lo stato del case = '+ result.currentCase.Status);
			component.set('v.show','true');
            } else {
                console.log('Errore nella chiamata al case');
            }
                
		});
		$A.enqueueAction(action);
	}
})