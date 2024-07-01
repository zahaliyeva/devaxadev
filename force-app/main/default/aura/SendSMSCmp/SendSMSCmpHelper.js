({
	 showToast : function(component, event, helper, type, message, detailsMessage) 
    {
        console.log('showToast method');
        component.set("v.messageToast", message);
        component.set("v.DetailsMessageToast", detailsMessage)
        component.set("v.typeToast", type);
        component.set("v.showToast",true);
        var self = this;
        
        if(type!='error')
        {
            window.setTimeout(
                $A.getCallback(function() {
                    component.set("v.messageToast", "");
                    component.set("v.typeToast", "");
                    component.set("v.showToast",false);
                    
                    if(component.get("v.SaveButtonPressed")=="Fine")
                    {
                        console.log('Close');
                        
                        self.closeQuestionario(component,event,helper);
                        component.set("v.SaveButtonPressed","");
                    }
                    //MMOSCATELLI 23/11/2018 : Caring Angel Enhancement -- START
                    else if(component.get("v.RecordsDeleted"))
                    {                    
                        var myEvent = $A.get("e.c:tabclosing");
                        myEvent.setParams({"data":"cancel",
                                           "recordid":'',
                                           "Url":''});
                        myEvent.fire();
                    }
                    //MMOSCATELLI 23/11/2018 : Caring Angel Enhancement -- START   
                }), 1000
            );
        }
    },
    
    showStandardToast : function( type, message, detailsMessage){
         var toastEvent = $A.get("e.force:showToast");  
     				toastEvent.setParams({  
       					"title": message,  
       					"message": detailsMessage,  
       					"type": type  
     				});  
     					toastEvent.fire();  
    },
    
    redirectpage : function (component){
    if (component.get("v.jsDebug")) console.log("inside redirect");
      var pathName = window.location.pathname;
      var agencyIndex = pathName.indexOf("agenzie");
      var id = component.get("v.recordId");
      var myURL = "https://"+window.location.hostname;
      if (agencyIndex!= -1)
      {
        myURL = myURL+"/agenzie";
      }
      myURL = myURL+"/"+id;
      if (component.get("v.jsDebug")) console.log("********"+myURL);
      if (component.get("v.jsDebug")) console.log ("*****sforce.one "+sforce.one);
      if ( (typeof sforce.one != 'undefined') && (sforce.one != null) )
      {
        sforce.one.navigateToSObject(id);
      }
      else
      {
        window.location.href = myURL;
      }
     // window.location.href = myURL;
/*
      var sObjectEvent = $A.get("e.force:navigateToSObject");
      sObjectEvent.setParams({
          "recordId": component.get("v.currentAccount.Id"),
          "slideDevName": 'related'
      })
      sObjectEvent.fire();*/

   }
})