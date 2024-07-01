({
    afterScriptsLoaded : function(component, event, helper) {
        component.set("v.ready", true);
        helper.createChartCasesByStatus(component);
        helper.createChartCasesByTime(component);
    },
    applyFilters : function(component, event, helper) {
    	helper.createChartCasesByStatus(component);
    	helper.createChartCasesByTime(component);
    }    


})