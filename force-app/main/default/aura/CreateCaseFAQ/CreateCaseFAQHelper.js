({
	getKnowledge : function(component, event, helper, valueToSearch, orderBy, Category)
	{
		console.log("valueToSearch: "+valueToSearch);
        console.log("CategoryToSplit: "+Category);
		var action = component.get("c.getArticlesKnowledge");
        action.setParams({ 	"varToSearch" : valueToSearch,
        					"orderBy" : orderBy, 
        					"CategoryToSplit" : Category});
        component.set("v.showLoading",true);
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("From server: ", response.getReturnValue());
                var data = response.getReturnValue();
                component.set("v.articles", response.getReturnValue());
                /*if(data[0]!=null)
                	component.set("v.tags",data[0].categoryTags);*/
				console.log('articoli: ',data);
                component.set("v.showLoading",false);
                
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
      
        $A.enqueueAction(action);
	}
})