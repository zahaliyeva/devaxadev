({
	init : function(cmp, evt, helper) {
        const action = cmp.get("c.getKnowledgePath");
        const staticLabel = $A.get("$Label.c.NFE_KnowledgePath_Fallback");
        action.setCallback(this, $A.getCallback(function (response){
			const state = response.getState();
            if(state == 'SUCCESS'){
				const res = response.getReturnValue();
                cmp.set("v.knowledgePath", res);
            } else if(state == 'ERROR'){
                cmp.set("v.knowledgePath", staticLabel);
            }
		}));
        $A.enqueueAction(action);
    },
})