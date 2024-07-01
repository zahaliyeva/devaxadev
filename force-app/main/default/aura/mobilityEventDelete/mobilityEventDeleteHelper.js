({
	invokeAura: function(component, methodName, params){
	    console.log('invokeAuraMethod', methodName);
	    
	    return new Promise($A.getCallback((resolve, reject)=>{
	        const action = component.get('c.' + methodName);
	        
	      	if(params) action.setParams(params);
	        
	        action.setCallback(this, (response)=>{
	            const state = response.getState();
	            if(state === 'SUCCESS'){
	                resolve(response);  
	            }else if(state === 'ERROR'){
	                throw new Error(response.getError());
	            }
	        });
	        
	        $A.enqueueAction(action);
	    }));
	}
})