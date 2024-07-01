({

  
    
    handleAccountReceived: function(component, event, helper) {
        
        var receivedAccount = event.getParam("containedAccount");
        
        helper.storeInitialInfo(component,receivedAccount); 
        
        var OpenTask = component.get("v.OpenTask");
        
        var EmailConsenso = receivedAccount.CIF_Mail_contact__c;
       
        component.set("v.EmailConsenso",EmailConsenso);
        helper.WorkableContact(component);
        console.log('OPEN TASK RECAPITI'+OpenTask);
        
    }, 

    PersEmailChange : function(component, event, helper) {
        var new_Email = component.find("CIF_Person_email").get("v.value");
        //console.log("New personal Email" + new_Email);
        component.set("v.Recapiti_RO_SmartCenter.CIF_PersonEmail__c", new_Email);
        helper.sendEmailInfo(component,"Personal Email", new_Email);   

    },

    WorkEmailChange: function (component, event, helper){
        var new_WorkEmail = component.find("CIF_Work_email").get("v.value");
        //console.log("New work Email" + new_WorkEmail);
        component.set("v.Recapiti_RO_SmartCenter.CIF_Work_email__c", new_WorkEmail);
        helper.sendEmailInfo(component,"Work Email", new_WorkEmail); 


    },


       
 
})