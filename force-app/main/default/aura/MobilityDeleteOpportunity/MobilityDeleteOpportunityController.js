({
    doInit : function(component, event, helper) {
       helper.init(component, event, helper);
    },
     
    conferma : function(component, event, helper) 
    {
      helper.deleteOpportunity(component, event, helper);
    },
    
    annulla : function(component, event, helper) 
    {
      helper.goToOpp(component, event, helper);   
    }  
})