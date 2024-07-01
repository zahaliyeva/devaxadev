({
	chiudiCase: function(component, event, helper) {
    	console.log('User ID: '+$A.get("$SObjectType.CurrentUser.Id"));
        console.log('Status '+component.get("v.simpleRecord.Status"));
        console.log('Details_of_Solution__c '+component.get("v.simpleRecord.Details_of_Solution__c"));
        if( component.get("v.simpleRecord.Status") != "Closed" && component.get("v.simpleRecord.Status") != "Chiuso")
        {
            component.set("v.showModalError",false);
            component.set("v.showError",false);
            component.set("v.Errorchecked","");   
            component.set("v.showModal",true);
        }
        else if( component.get("v.simpleRecord.Status") == "Closed" || component.get("v.simpleRecord.Status") == "Chiuso")
        {
            component.set("v.showModal",false);
            component.set("v.showModalError",true);
            component.set("v.showError",true);
            component.set("v.Errorchecked","Attenzione ! Non è possibile chiudere case già evasi.");   
        }
    },
       closeModal: function(component, event, helper) {
       component.set("v.showModal", false);
            let visibilities = component.get('v.visibilities');
       if(visibilities){
           visibilities('ChiudiCaseCmp', false);
       }
   },
       closeModalErorr: function(component, event, helper) {
       component.set("v.showModalError", false);
   },
    //Giorgio Bonifazi - Caring Angel - Fase 2 - START

   toggle : function(component, event, helper){
    
        var sel = (component.find("myselect")).get("v.value");

            console.log(sel);

    //Giorgio Bonifazi - Caring Angel - Fase 2 - END

   },



   saveToSFDC : function(component, event,helper)
   {

	   if(($A.get("$SObjectType.CurrentUser.Id")==component.get("v.simpleRecord.OwnerId"))  ) 
        {
            component.set("v.showError",false);
            component.set("v.simpleRecord.Status","Closed");
            console.log('component.get("v.soluzione"): ',component.get("v.soluzione"));
            component.set("v.simpleRecord.Details_of_Solution__c",component.get("v.soluzione"));
            component.set("v.isLoading", true);
            //Giorgio Bonifazi - Caring Angel - Fase 2 - START
            var sel = (component.find("myselect")).get("v.value");
            component.set("v.simpleRecord.Motivo_chiusura__c", sel);
            //Giorgio Bonifazi - Caring Angel - Fase 2 - END
            component.find("recordEditor").saveRecord($A.getCallback(function(saveResult) {
                if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                    console.log("Save completed successfully.");
                    window.location.reload(true);
                } else if (saveResult.state === "INCOMPLETE") {
                    console.log("User is offline, device doesn't support drafts.");
                } else if (saveResult.state === "ERROR") {
                    console.log('Problem saving record, error: ' + 
                               JSON.stringify(saveResult.error));
                    component.set("v.showError",true);
                    component.set("v.Errorchecked",JSON.stringify(saveResult.error));
                    component.set("v.isLoading", false);
                } else {
                    console.log('Unknown problem, state: ' + saveResult.state + ', error: ' + JSON.stringify(saveResult.error));
                }
            }));
        }
        else if(($A.get("$SObjectType.CurrentUser.Id")!=component.get("v.simpleRecord.OwnerId")) && !component.get("v.simpleRecord.OwnerId").startsWith('00G'))
        {
            console.log('different user');
            component.set("v.showError",true);
            component.set("v.Errorchecked","Attenzione ! Il case non può essere chiuso in quanto è in carico ad un altro Advisor");   
        }
        else if( component.get("v.simpleRecord.OwnerId").startsWith('00G'))
        {
            console.log('queue');
            component.set("v.showError",true);
            component.set("v.Errorchecked","Attenzione ! Il case non può essere chiuso in quanto è necessario prima prenderlo in carico.");   
        }
   },
    confimClose : function(component, event,helper){
        
     console.log('UpdateCase');   
     var value = (component.find("myselect")).get("v.value");
     var caseId = component.get("v.recordId");
 
     
        	component.set("v.isLoading",true);
        	
	        var action = component.get("c.updateCaseStatus");
	        action.setParams({ "caseId" : caseId,
	                           "value" :  value});
	
	        action.setCallback(this, function(response) {
	            var state = response.getState();
	            if (state === "SUCCESS") {
	               let result = response.getReturnValue();
	                console.log('result: ',result);
	                if( result == 'OK')
	                {
	                component.set("v.isLoading",false);                          
                    $A.enqueueAction(component.get('c.closeModal'));
                    $A.get('e.force:refreshView').fire();    
	                }
	                else if(result.indexOf('KO|Fallito')>-1)
	                {
	                	component.set("v.isLoading",false);
	                    console.log(result.substring('KO|Fallito'.length,result.lenght));
	                    helper.showToastStandard(component, event, helper, 'Error','error', result.substring('KO|Fallito'.length,result.lenght));	               
	                    
	                }
	               
	            }
	            
	            else if (state === "ERROR") {	            
	            	component.set("v.isLoading",false);
	                var errors = response.getError();
	                if (errors) {
	                    if (errors[0] && errors[0].message) {	                    	
	                        console.log("Error message: " + 
	                                 errors[0].message);
	                                 component.set("v.errorDetails",errors[0].message)
	                    }
	                } 
	            }
	        });
	        $A.enqueueAction(action);
	    
	
    }
})