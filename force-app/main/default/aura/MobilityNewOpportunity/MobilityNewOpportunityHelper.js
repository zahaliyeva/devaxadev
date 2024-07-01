({
    initializeASAdescription : function(component) {
        var action = component.get("c.getASAList");
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {                
                component.set("v.ASA_Description__c",response.getReturnValue());        
                
            }
            
        });
        $A.enqueueAction(action);        
        
    },
    
    createOpportunity : function(component) {
 
        if(component.get("v.SelectedAccount.Obj.Id")!= null && component.get("v.Opportunity.ASA_Description__c")!= null && component.get("v.SelectedAccount.Obj.Id")!== "" && component.get("v.Opportunity.ASA_Description__c")!== ""){
        var action = component.get("c.createOpportunity"); 
        // setting the parameter to apex class method
        action.setParams({ 
            "accId" : component.get("v.SelectedAccount.Obj.Id")  ,
            "description": component.get("v.Opportunity.ASA_Description__c")
            
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS" && response.getReturnValue()!=null) {            
                console.log('opp id '+  response.getReturnValue() );  
                debugger;
            var oppId = response.getReturnValue();
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": oppId
            });
            navEvt.fire();  
            }else{
                console.log('opp id '+  response.getError());  
                this.showToast(component,'Error!',' ','error');
            }              
        });                      
                              
        $A.enqueueAction(action);
       }else
          this.showToast(component,'Error!','Compilare i campi obbligatori.','error');
    },
    
    showToast : function (component, title, message, type){
    var toastEvent = $A.get("e.force:showToast");
				toastEvent.setParams({
					title: title,
					message: message,
					duration:' 3000',
					type: type,
				});
				toastEvent.fire();
   }


   })