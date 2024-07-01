({
	doInit: function(component, event, helper) {
        const action = component.get('c.getCase');
        const recordId = component.get('v.recordId');
        action.setParams({
            recordId: recordId
        });
        
		action.setCallback(this, function(response){
            const result = response.getReturnValue();
        	const state = response.getState();
        	
            if(state === 'SUCCESS'){
            	component.set('v.caseStatus', result.Status);    
				let isOwnerAdvisor;
				console.log(result);
				
				if(result.OwnerId.startsWith('005')){
					isOwnerAdvisor = !result.ProfileNameOwner__c.includes('AAI - Vendite');
					component.set('v.isOwnerAdvisor',isOwnerAdvisor);
					
				}
				else if(result.OwnerId.startsWith('00G')){
					if(result.Owner.Name.startsWith('Coda Agenzia Case')){
						component.set('v.OwnerIsQueue', true);
					}
					else{
						component.set('v.isOwnerAdvisor',true);
					}
				}  
				console.log("Ciao Sono quiiiiii!");
                const action2 = component.get('c.isRightCTL');
                action2.setParams({
                    recordId: recordId,
					isClose: false
                });
                action2.setCallback(this, function(response){
                    const result2 = response.getReturnValue();
        	        const state2 = response.getState();
					console.log(result2);
                    if(state2 === 'SUCCESS'){
                        console.log(result2);
                        component.set("v.isRightCTL", result2);
                    }
                });
                $A.enqueueAction(action2);
            }
        });
		$A.enqueueAction(action);
    },
    Cancel: function(component, event, helper) {
    	const pathName = window.location.pathname;
        const myURL = "https://" + window.location.hostname + "/crm/s/case/" + component.get("v.caseId") + "/detail";
        window.location.href = myURL;
    },
    UpdateCase: function(component, event, helper) {
    	let value = component.get('v.commentoCTL');
        let caseId = component.get('v.caseId');
        console.log('caseId: ', caseId);
        const pathName = window.location.pathname;
        const myURL = "https://" + window.location.hostname + "/crm/s/case/" + component.get("v.caseId") + "/detail";
		if(value==null || value =="") {
        	component.set("v.emptySolution",true);
        } else {
        	component.set("v.isLoading",true);
        	component.set("v.emptySolution",false);
	        var action = component.get("c.UpdateCaseCTL");
	        action.setParams({
                "caseId" : caseId,
	            "value" : value 
            });
	
	        action.setCallback(this, function(response) {
	            const state = response.getState();
                
                console.log(response.getReturnValue());
	            if (state === "SUCCESS") {
                    let result = response.getReturnValue();
	                console.log('result: ',result);
	                if (result == 'OK') {
	                    window.location.href = myURL;
	                } else if (result.indexOf('KO|Fallito')>-1) {
	                	component.set("v.isLoading",false);
                        console.log(result);
	                    console.log(result.substring('KO|Fallito'.length,result.lenght));
	                    component.set("v.errorFromServer",true);
	                    component.set("v.errorDetails",result.substring('KO|Fallito'.length,result.lenght));
	                } else {
	                	console.log('errore');
                        console.log(result);
	                	component.set("v.isLoading",false);
	                	component.set("v.errorFromServer",true);
	                	component.set("v.errorDetails",result.substring('KO|Fallito'.length,result.lenght));
	                }
	            } else if (state === "ERROR") {
	            	component.set("v.isLoading",false);
	                const errors = response.getError();
	                if (errors) {
	                    if (errors[0] && errors[0].message) {
	                    	component.set("v.errorFromServer",true);
	                        console.log("Error message: " + 
	                                 errors[0].message);
	                                 component.set("v.errorDetails",errors[0].message)
	                    }
	                } else {
	                    console.log("Unknown error");
	                    component.set("v.WrongSolution","Unknown error");
	                }
	            }
	        });
	        $A.enqueueAction(action);
	    }
    }
})