({
	init : function(component, event, helper) {
		this.getOpportunityInfo(component, event, helper);
	},
    
    goToOpp : function(component, event, helper) {
        var url_string = window.location.href;
        var url = new URL(url_string);
        var oppId = url.searchParams.get("recordId");
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": oppId
        });
        navEvt.fire();  
    },
    

     getOpportunityInfo : function(component, event, helper) {
        var url_string = window.location.href;
        var url = new URL(url_string);
        var recordId = url.searchParams.get("recordId");
        
        var action = component.get("c.getOpportunityInfo");
        action.setParams({ oppId : recordId });

                     
        action.setCallback(this, function(response){
        var state = response.getState();
        if (state === "SUCCESS") {
         if(  response.getReturnValue().Numero_proposte__c >= 1){
              component.set("v.showError",true);
              component.set("v.ErrorMsg",'Non è possibile effettuare l\'eliminazione perché la trattativa ha una proposta collegata.');
         } else{ 
           component.set("v.opportunityInfo", response.getReturnValue());  
           component.set("v.showConfirm",true);
           component.set("v.WarningMsg",'Procedere con l\'eliminazione della trattativa?');
         }
         
         }
       });
       $A.enqueueAction(action);  
	},
    
    deleteOpportunity : function(component, event, helper){
        var action = component.get("c.getDeleteOpportunity");
        action.setParams({ opp : component.get("v.opportunityInfo") });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS")              
           	this.goToOpportunityList(component, event, helper);      
                
            
            
        });
        $A.enqueueAction(action);        
        
    },
    
       
    goToOpportunityList : function(component, event, helper) {
        let urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({ "url" : '/opportunity/Opportunity/Default' });
        urlEvent.fire();    
    },
    
  
})