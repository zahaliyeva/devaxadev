({
    startFilters : function (component, event, helper){
		helper.populateYearFilter(component);
		helper.populateMonthFilter(component);
		helper.populateWeekFilter(component);
		helper.populateLobFilter(component);
		helper.populateCategoryFilter(component);
		helper.populateSubCategoryFilter(component);
		helper.populateOwnershipFilter(component);
    },
    changedYear : function (component, event, helper){
    	helper.populateMonthFilter(component);
        helper.populateWeekFilter(component);
    },
    changedMonth : function (component, event, helper){
    	helper.populateWeekFilter(component);
    },
    changedLob : function (component, event, helper){
    	helper.populateCategoryFilter(component);
        helper.populateSubCategoryFilter(component);
    },
    changedCategory : function (component, event, helper){
    	helper.populateSubCategoryFilter(component);

    }
})