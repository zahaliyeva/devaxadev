({
	doInit : function(component, event, helper) 
    {
		document.body.setAttribute('style', 'overflow-x: hidden;');
	},
    
    handleCategoryToFAQCmpEvent : function(component, event, helper)
    {
        console.log('handleCategoryToFAQCmpEvent');
        if($A.get("$Browser.formFactor") == "DESKTOP")
        {
	        var Category = event.getParam("Category");
	        var SubCategory = event.getParam("SubCategory");
	        var Lob = event.getParam("Lob");
	    	component.set('v.Category',Category);
	        component.set('v.SubCategory',SubCategory);
	        component.set('v.Lob',Lob);
	        if(Category!= null && Category!= '' ){
	            component.set("v.sizeFirstLayout",8);
	            component.set("v.sizeSecondLayout",4);
                component.set("v.loadKnowledge", true);
	        }
	        else{
	            component.set("v.sizeFirstLayout",12);
	            component.set("v.sizeSecondLayout",0);
	        }
	        var createCaseFAQComponent = component.find("createCaseFAQ");
	        createCaseFAQComponent.ReceiveCategoryFromCmp(Category, SubCategory, Lob);
	    }
	}
})