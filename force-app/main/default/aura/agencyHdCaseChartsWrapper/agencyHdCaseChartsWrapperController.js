({
	createChart : function(component, event, helper) {
        var selectedYear = 'None';
        var selectedMonth = 'None';
        var selectedWeek = 'None';
        var selectedLob = 'None';
        var selectedCategory = 'None';
        var selectedSubCategory = 'None';
        var selectedOwnership = 'None';

        component.set("v.selectedYear", selectedYear);
        component.set("v.selectedMonth", selectedMonth);
        component.set("v.selectedWeek", selectedWeek);
        component.set("v.selectedLob", selectedLob);
        component.set("v.selectedCategory", selectedCategory);
        component.set("v.selectedSubCategory", selectedSubCategory);
        component.set("v.selectedOwnership", selectedOwnership);   

        var filters = component.find("childFilters");
        filters.reInit();
        $A.createComponent(

            "c:agencyHdCaseCharts",
            {
                "selectedYear": selectedYear,
                "selectedMonth": selectedMonth,
                "selectedWeek": selectedWeek,
                "selectedLob": selectedLob,
                "selectedCategory": selectedCategory,
                "selectedSubCategory": selectedSubCategory,
                "selectedOwnership": selectedOwnership
            },

            function(newChartComp, status, errorMessage){

                if(status == "SUCCESS"){
                    var body = component.get("v.body");
                    body.pop();
                    body.push(newChartComp);
                    component.set("v.body", body);
                } 
                else{
                	console.log(errorMessage);
                }
            }
        );
    },
    applyFilters : function(component, event, helper) {
        var selectedYear = component.get("v.selectedYear");
        var selectedMonth = component.get("v.selectedMonth");
        var selectedWeek = component.get("v.selectedWeek");
        var selectedLob = component.get("v.selectedLob");
        var selectedCategory = component.get("v.selectedCategory");
        var selectedSubCategory = component.get("v.selectedSubCategory");
        var selectedOwnership = component.get("v.selectedOwnership");      

        $A.createComponent(

            "c:agencyHdCaseCharts",
            {
                "selectedYear": selectedYear,
                "selectedMonth": selectedMonth,
                "selectedWeek": selectedWeek,
                "selectedLob": selectedLob,
                "selectedCategory": selectedCategory,
                "selectedSubCategory": selectedSubCategory,
                "selectedOwnership": selectedOwnership
            },

            function(newChartComp, status, errorMessage){

                if(status == "SUCCESS"){
                    var body = component.get("v.body");
                    body.pop();
                    body.push(newChartComp);
                    component.set("v.body", body);

                    console.log('body: '+body);
                } 
            }
        );
    }
})