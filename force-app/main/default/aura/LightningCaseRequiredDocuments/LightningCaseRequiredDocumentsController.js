({
    doInit : function(component, event, helper) {
		const action = component.get('c.initCmp');
		const recordId = component.get("v.recordId");

		action.setParams({
			'idCase': recordId
		});
		
		action.setCallback(this, (response)=>{
			const state = response.getState();
			console.log('state', state);

			switch(state){
				case 'SUCCESS':
					const result = response.getReturnValue();
					if(result.isSuccess){	
					component.set('v.data',result.docResults);
					component.set('v.showSendEmailButton',result.showSendEmailButton);
				    }

				
					break;
				case 'ERROR':
					break;
			}
		})

		$A.enqueueAction(action);
        
	},

    handleSendEmail: function(component, event, helper) {

        const action = component.get('c.sendEmail');
		const recordId = component.get("v.recordId");
		const docResults = component.get("v.data");
		component.set('v.spinner', true);

		action.setParams({
			'idCase': recordId,
			'params': docResults
		});
		
		action.setCallback(this, (response)=>{
			const state = response.getState();
			console.log('state', state);
			component.set('v.spinner', false);
			switch(state){
				case 'SUCCESS':
					const result = response.getReturnValue();
					if(result.isSuccess)	
						helper.showToastStandard('Success','success', '') ;
					else
					helper.showToastStandard('Error','error', response.errorMessage);
					break;
				case 'ERROR':
					helper.showToastStandard('Error','error', response.errorMessage);

					break;
			}
		})

		$A.enqueueAction(action);
	},

})