({
	init : function(cmp, evt, helper) {
        const action = cmp.get("c.getMonitoraggioPath");
        const staticLabel = $A.get("$Label.c.NFE_MonitoraggioPath_Fallback");
        action.setCallback(this, $A.getCallback(function (response){
			const state = response.getState();
            if(state == 'SUCCESS'){
				const res = response.getReturnValue();
                cmp.set("v.monitoraggioPath", res);
                console.log(res);
            } else if(state == 'ERROR'){
                cmp.set("v.monitoraggioPath", staticLabel);
            }
		}));
        $A.enqueueAction(action);
    },
})