({
	init : function(cmp, evt, helper) {
        const action = cmp.get("c.getReportisticaPath");
        const staticLabel = $A.get("$Label.c.NFE_ReportisticaPath_Fallback");
        action.setCallback(this, $A.getCallback(function (response){
			const state = response.getState();
            if(state == 'SUCCESS'){
				const res = response.getReturnValue();
                cmp.set("v.reportisticaPath", res);
            } else if(state == 'ERROR'){
                cmp.set("v.reportisticaPath", staticLabel);
            }
            console.log(component.get("v.reportisticaPath"));
		}));
        $A.enqueueAction(action);
    },
})