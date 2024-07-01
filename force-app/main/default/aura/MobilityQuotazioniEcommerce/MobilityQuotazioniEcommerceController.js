({
    doInit: function(component, event, helper) {
     
        
        var action = component.get("c.getRTDevName"); 
        // setting the parameter to apex class method
        action.setParams({ 
            "qId" : component.get('v.recordId')                   
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS" && response.getReturnValue()!=null) {            
                
                let rt = response.getReturnValue();
                if (rt=="eCommerce")
                    component.set('v.showForEcommerce', true ); 
            }             
        });                      
        
        $A.enqueueAction(action);
    },
    
})