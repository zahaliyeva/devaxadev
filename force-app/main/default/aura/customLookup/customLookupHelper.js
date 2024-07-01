({
	searchHelper : function(component,event,getInputkeyWord) {
	  // call the apex class method 
     var action = component.get("c.fetchLookUpValues");
      // set param to method  
        action.setParams({
            'searchKeyWord': getInputkeyWord,
            'ObjectName' : component.get("v.objectAPIName"),
            'WhereCondition' : component.get("v.QueryWhereCondition"),
            'ResultNum' : component.get("v.QueryLimit"),
            'SelectString' : component.get("v.QueryOutputField")
          });
      // set a callBack    
        action.setCallback(this, function(response) {
          $A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('@@storeResponse: ',response.getReturnValue());
                component.set("v.listOfSearchRecords", []);
                var storeResponse = response.getReturnValue();
              // if storeResponse size is equal 0 ,display No Result Found... message on screen.                }
                if (storeResponse.length == 0) {
                    component.set("v.Message", component.get("v.NoResultsFoundMsg"));
                } else {
                    component.set("v.Message", '');
                }
                // set searchResult list with return value from server.
                component.set("v.listOfSearchRecords", storeResponse);
            }
 
        });
      // enqueue the Action  
        $A.enqueueAction(action);
    
	},
	/* ORLANDO PICKLIST ENHANCEMENT */
	clear :function(component,event,heplper){
        /*var ul = document.getElementById("resultsList");
        console.log(ul.className);
        //ul.className += " slds-hide";
        $A.util.addClass(ul, 'slds-hide');
        $A.util.removeClass(ul, 'slds-show');*/
        console.log('clear helper');
        var pillTarget = component.find("lookup-pill");
        var lookUpTarget = component.find("lookupField"); 
        component.set("v.Message",'');
        $A.util.addClass(pillTarget, 'slds-hide');
        $A.util.removeClass(pillTarget, 'slds-show');
        component.set("v.ShowSearchIcon","true");//test
        
        $A.util.addClass(lookUpTarget, 'slds-show');
        $A.util.removeClass(lookUpTarget, 'slds-hide');
        
        component.set("v.SearchKeyWord",null);
        component.set("v.listOfSearchRecords", null );
        component.set("v.selectedRecord", {} ); 
        var compEvent = component.getEvent("oSelectedRecordEventToCreateCaseCmp");
        compEvent.setParams({"recordByEvent" : null });  

        //test
        if(component.get("v.objectAPIName")=="account")
        {
            compEvent.setParams({"ObjectType" : "Account" });
            console.log('account');
            //compEvent.fire();
        }
        else if(component.get("v.objectAPIName")=="insurancepolicy__c")
        {
            compEvent.setParams({"ObjectType" : "Policy" });
            console.log('insurancepolicy__c');
        }
            
        compEvent.fire();
        
    },
    /* ORLANDO PICKLIST ENHANCEMENT */
    
})