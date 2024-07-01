({
	init : function(cmp, evt, helper) {
        const action = cmp.get("c.getBlackListPath");
        const staticLabel = $A.get("$Label.c.NFE_BlackListPath_Fallback");
        action.setCallback(this, $A.getCallback(function (response){
			const state = response.getState();
            if(state == 'SUCCESS'){
				const res = response.getReturnValue();
                cmp.set("v.blackListPath", res);
            } else if(state == 'ERROR'){
                cmp.set("v.blackListPath", staticLabel);
            }
		}));
        $A.enqueueAction(action);
    },
})