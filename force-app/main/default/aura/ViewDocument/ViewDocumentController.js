({	doInit : function(component, event, helper) {
	
		
    var action = component.get("c.fetchUser");
    
    
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                component.set("v.userInfo", storeResponse);
               
            }
        });
        $A.enqueueAction(action);
        
    },


    navigate : function(component, event, helper)
{	
    console.log(component.get("v.userInfo.Profile.Name"));
     
    var profileName = component.get("v.userInfo.Profile.Name");
    var recordId = component.get("v.recordId");
    var action = component.get("c.checkDocumentId");


                action.setParams({"recordId" : recordId });
                action.setCallback(this,function(response){
                    var state = response.getState();
                    
                    var Case = response.getReturnValue();
                    component.set("v.DocumentId",Case[0].Document_Unique_ID__c);
                    var documentId = component.get("v.DocumentId");
                    component.set("v.RecordType", Case[0].RecordType.DeveloperName);

                    if (state === "SUCCESS") {

                        if  ((profileName != null && profileName.indexOf('SmartCenter') != -1) ||
                            (profileName=='System Administrator') || 
                            (profileName=='Amministratore del sistema') || 
                            (profileName=='AXA MPS Business Admin') || 
                            (profileName=='Technical Office')||
                            (profileName != null && profileName.indexOf('HD2 BIZ')!= -1)||
                            ((profileName.indexOf('Caring Angel - Supporto HD2')!= -1) && component.get("v.RecordType") == 'CAI')){

                             
                        if(documentId == null){
                        helper.checkDocument(component, event, helper);
                        }
                        else if(documentId != null)  {
                        var urlEvent = $A.get("e.force:navigateToURL");
                        urlEvent.setParams({ "url": 'https://axabpows.xerox.it/OBSF-MyRiam/OBSF/'+documentId});
                        
                            urlEvent.fire();
                        }
                    }
                    else {
                        console.log("RecordID: ",  component.get("v.recordId"));
                        helper.checkProfile(component, event, helper);
                        } 
                }
                        else if (state === "ERROR") {
                        var errors = response.getError();
                            if (errors) {
                                if (errors[0] && errors[0].message) {
                                        console.log("Error message: " +errors[0].message);                                
                                }
                            } 
                        }
                        
                });
                $A.enqueueAction(action);
        
            
    
}

})