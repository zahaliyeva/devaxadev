({
 createCaseNoAnagrafica : function(component,event,helper)
    {
    var action = component.get("c.generateNewCase");    
        action.setCallback(this, function(response) 
                        {
                            var state = response.getState();
                            
                            if (state === "SUCCESS")
                            {
                                var result = response.getReturnValue();
                                
                                if(result!=null)
                                {
                                    console.log('##Result: ',result);
                                    
                                    if(result.isSuccess)
                                    {    
                                         component.set("v.NewCaseId",result.CsId);
                                        var self = this;
                                        self.showToast(component,event,helper,'success','Il Case '+ result.CsNumber + ' è stato creato con successo', result.CsNumber);
                                    }
                                    else
                                    {
                                        var self = this;
                                        self.showToast(component,event,helper,'error',result.Msg);
                                    }
                                }
                            }
                            else if (state === "INCOMPLETE")
                            {
                                var self = this;
                                self.showToast(component,event,helper,'error','La funzionalità non è al momento disponibile. Contatta l\'Amministratore di sistema','');
                                
                            }
                                else if (state === "ERROR")
                                {
                                    var errors = response.getError();
                                    if (errors) {
                                        if (errors[0] && errors[0].message) 
                                        {
                                            console.log("Error message: " +errors[0].message);                                
                                        }
                                    } 
                                    else
                                    {
                                        console.log("Unknown error");
                                    }
                                    var self = this;
                                    self.showToast(component,event,helper,'error','La funzionalità non è al momento disponibile. Contatta l\'Amministratore di sistema','');
                                }
                        });
    $A.enqueueAction(action);
    },
    
    showToast : function(component, event, helper,type, message,CaseNumber){
        console.log('showToast method');
        component.set("v.ShowToast",true);
        component.set("v.messageToast", message);
        component.set("v.typeToast", type);
        
        var self = this;
        
         if(type!='error')
        {
            window.setTimeout(
                $A.getCallback(function() {
                   
                    component.set("v.ShowToast",false);
                    
                    
                    var myEvent = $A.get("e.c:tabclosing");
             
                    
                    	console.log("NewCaseNumber: "+component.get("v.NewCaseNumber"));
                    	myEvent.setParams({"data":"openCaseTab",
                                       "recordid":component.get("v.NewCaseId"),
                                       "Url":CaseNumber});
          
                    myEvent.fire(); 
                  
                }), 3000
            );
        }
    },

      
})