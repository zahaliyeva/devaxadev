({
	doInit : function(component, event, helper) {
        var action = component.get("c.getStorico_ChiamateInfos");
        var params = {"Id":component.get("v.recordId")};
        action.setParams(params);
        
        action.setCallback(this, function(response) {              
                var state = response.getState();
                if (component.isValid() && state === "SUCCESS") 
                {
                    
                    var uniqueid = response.getReturnValue().PhoneCallIDB__c;
                    var datetimes = response.getReturnValue().CallDateTime__c;
    
                        if (!uniqueid || !datetimes) 
                        {
                            component.set("v.loading", false);
                            helper.showToastStandard(component, event, helper,'Errore','error', 'Non è stato possibile ascoltare la registrazione della telefonata selezionata');                    
                            $A.get("e.force:closeQuickAction").fire();      
                        }
                        else                  
                        {
                            var obj = new Object();
                            obj.action='dta_viewHistory';
                            obj.callID = uniqueid;
                            obj.callStartDateTime = datetimes;
                            obj.type = "call";
                            var jsonString = JSON.stringify(obj);
                            console.log('##jsonString: '+jsonString);
                            
                           // sforce.console.fireEvent('dta_viewHistory', jsonString, callback);
                           
                            //   var myEvent =  $A.get("e.force:dta_viewHistory");
                              //  myEvent.setParams(jsonString);
                                //myEvent.fire();
                                //
                             //   PostMessage.openCallback(this.params.id, data);
                            window.parent.postMessage(jsonString, '*');
                               // var retrievalEvent = $A.get("e.c:dta_viewHistory");
                                //retrievalEvent.setParams(jsonString);
                                //console.log ("event ready to be sent"+retrievalEvent);
                                //retrievalEvent.fire();
                            
                          /*  var callback = function(result)
                            {
                                if (result.success)
                                {
                                    console.log('##result',result);
                                }
                                else
                                {
                                    console.log('##result',result);                                    
                                    helper.showToastStandard(component, event, helper,'Errore','error', 'Non è stato possibile ascoltare la registrazione della telefonata selezionata');                    
                                    
                                }
                            }*/
                            
                           component.set("v.loading", false);
                            $A.get("e.force:closeQuickAction").fire(); 
                        }
                       

                }
                else {
                   console.log("Failed with state: " + state);
                }
            });
        
            // Send action off to be executed
            $A.enqueueAction(action);
	}
})