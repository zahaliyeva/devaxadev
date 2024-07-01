({
    onClick : function(component, event, helper) {
    	const recordId = component.get('v.recordId');
    	const request = {
    		recordId
    	};

    	component.set('v.spinner', true);

    	helper.invokeAura(component, 'deleteRecord', request).then((response)=>{
    		const result = response.getReturnValue();

    		if(!result.isSuccess) throw new Error(result.errorMessage);

    		window.location.href = '/crm/s/calendar';
    	}).catch((err)=>{
    		console.log('err', err);

 			const toastEvent = $A.get("e.force:showToast");
 			toastEvent.setParams({
 			    "title": "Error!",
 			    "message": err.message,
 			    "type": 'error'
 			});
 			toastEvent.fire();
    	}).finally(()=>{
    		component.set('v.spinner', false);
    	})
    }
})