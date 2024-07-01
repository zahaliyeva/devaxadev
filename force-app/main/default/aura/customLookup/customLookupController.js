({
    onfocus : function(component,event,helper){
        console.log('@onfocus');
        $A.util.addClass(component.find("mySpinner"), "slds-show");
        var forOpen = component.find("searchRes");
        $A.util.addClass(forOpen, 'slds-is-open');
        $A.util.removeClass(forOpen, 'slds-is-close');
        // Get Default 5 Records order by createdDate DESC 
        component.set("v.listOfSearchRecords",[]);//test 
        var getInputkeyWord = '';
        
        /* ORLANDO PICKLIST ENHANCEMENT */
        // if(getInputkeyWord.length>0)
        if(getInputkeyWord.length>0 || component.get("v.immediateQuery"))
        /* ORLANDO PICKLIST ENHANCEMENT */
        {
        	console.log('immediateQuery');
            helper.searchHelper(component,event,getInputkeyWord);
        }
    },
    onblur : function(component,event,helper){ 
        
        console.log('@onblur');
        /* ORLANDO PICKLIST ENHANCEMENT */
        console.log('component.get("v.listOfSearchRecords")',component.get("v.listOfSearchRecords"));
        if(component.get("v.listOfSearchRecords"))
        {
            if(component.get("v.Message")=="" && component.get("v.listOfSearchRecords").length == 0 )
                helper.clear(component,event,helper);
        }
        /* ORLANDO PICKLIST ENHANCEMENT */
        //OAVERSANO 24/01/2019 : NMA Fix Mobile -- START
	    /*var params = event.getParam('arguments');
	    console.log('Param 1: '+ params.param1);*/
        //OAVERSANO 24/01/2019 : NMA Fix Mobile -- END
        
        component.set("v.listOfSearchRecords", null );
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
    },
    keyPressController : function(component, event, helper) {
        console.log('@onkeypress');
        // get the search Input keyword   
        var getInputkeyWord = component.get("v.SearchKeyWord");
        // check if getInputKeyWord size id more then 0 then open the lookup result List and 
        // call the helper 
        // else close the lookup result List part.   
        console.log('getInputkeyWord: '+getInputkeyWord);
        /* ORLANDO PICKLIST ENHANCEMENT */
        //if( getInputkeyWord.length >= 3 ){
        if( getInputkeyWord.length >= 3 || component.get("v.immediateQuery")){
        /* ORLANDO PICKLIST ENHANCEMENT */
            var forOpen = component.find("searchRes");
            component.set("v.listOfSearchRecords",[]);//test
            $A.util.addClass(forOpen, 'slds-is-open');
            $A.util.removeClass(forOpen, 'slds-is-close');
            helper.searchHelper(component,event,getInputkeyWord);
        }
        else{  
            component.set("v.listOfSearchRecords", null ); 
            var forclose = component.find("searchRes");
            $A.util.addClass(forclose, 'slds-is-close');
            $A.util.removeClass(forclose, 'slds-is-open');
        }
    },
    
    // function for clear the Record Selaction 
    clear :function(component,event,helper){
        console.log('clear');
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
        
       
        if(component.get("v.objectAPIName")=="account")
        {
            compEvent.setParams({"ObjectType" : "Account" });
            //compEvent.fire();
        }
        else if(component.get("v.objectAPIName")=="insurancepolicy__c")
        {
            compEvent.setParams({"ObjectType" : "Policy" });
        }
            
        compEvent.fire();
    },
    
    // This function call when the end User Select any record from the result list.   
    handleComponentEvent : function(component, event, helper) {
        // get the selected Account record from the COMPONETN event 	 
        var selectedAccountGetFromEvent = event.getParam("recordByEvent");
        component.set("v.selectedRecord" , selectedAccountGetFromEvent); 
        /*Orlando*/
        console.log('selectedAccountGetFromEvent.Obj.Name: ',selectedAccountGetFromEvent.Obj.Id);
        var compEvent = component.getEvent("oSelectedRecordEventToCreateCaseCmp");
        compEvent.setParams({"recordByEvent" : selectedAccountGetFromEvent });  
      
        /*
         *DECOMMENTA
         
        if(component.get("v.objectAPIName")=="account")
        {
            compEvent.fire();
        } 
        */
        
        if(component.get("v.objectAPIName")=="account")
        {
            compEvent.setParams({"ObjectType" : "Account" });  
        }
        else if(component.get("v.objectAPIName")=="insurancepolicy__c")
        {
            compEvent.setParams({"ObjectType" : "Policy" });
        }
        
        compEvent.fire();
        
        //compEvent.fire();
        console.log('compEvent: ',compEvent);
        var forclose = component.find("lookup-pill");
        $A.util.addClass(forclose, 'slds-show');
        $A.util.removeClass(forclose, 'slds-hide');
        component.set("v.ShowSearchIcon","false");
        
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
        
        var lookUpTarget = component.find("lookupField");
        $A.util.addClass(lookUpTarget, 'slds-hide');
        $A.util.removeClass(lookUpTarget, 'slds-show');  
        
    }
})