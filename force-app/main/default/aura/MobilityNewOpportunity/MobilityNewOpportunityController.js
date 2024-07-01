({
    doInit: function(component,event,helper) 
    {        
      helper.initializeASAdescription(component);
    },
    
    salva : function(component, event, helper) 
    {
      helper.createOpportunity(component);
    },
    
    annulla : function(component, event, helper) 
    {
      window.history.back();        
    }  
})