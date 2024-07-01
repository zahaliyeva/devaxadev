({

    Initialize : function(component, event, helper) {
        helper.stopSpinner(component); 
        var defaultTemplateId = component.get("v.defaultTemplate");
        if (typeof defaultTemplateId != 'undefined' && defaultTemplateId!= null && defaultTemplateId != '')
        {
            console.log ("setting default template: "+defaultTemplateId);
            component.set("v.selectedTemplate",defaultTemplateId);
        }
        helper.getFromList(component,event,helper);
   
    },
    closeError : function(component, event, helper) {
        //component.set("v.isError",false);
        helper.redirectpage(component);
    },  
    finish : function(component, event, helper) {
        helper.redirectpage(component);
    },
    refresh : function(component,event,helper){
        window.location.reload();
    },
    cancel : function (component, event, helper) {
        helper.startSpinner(component);
        var attachmentList = component.get("v.attachmentList");
        if(typeof attachmentList != undefined &&  attachmentList!= null && attachmentList!="")
        {
            helper.deleteAttachments(component, event,helper,attachmentList);               
        }
        else
        {
            helper.redirectpage(component);
        }

    },

    sendMail: function(component, event, helper) {
        // when user click on Send button 
        // First we get all 3 fields values  
        var emailError = helper.checkAllEmailFields(component, event, helper);
        if (emailError) {
            component.set ("v.isError",emailError);
        }else{
            helper.startSpinner(component);
            var recordId = component.get("v.recordId");
            var toAddresses = helper.splitEmailString(component.get("v.toAddresses"));
            var CCAddresses = helper.splitEmailString(component.get("v.CCAddresses"));
            var BCCAddresses =  helper.splitEmailString(component.get("v.BCCAddresses"));
            var selectedFrom = component.get("v.selectedFrom");
            var subject = component.get("v.subject");
            var body = component.get("v.body");
            var attachmentList = component.get("v.attachmentList");

            //SEND THIS VARIABLE TO THE SERVER
            var action = component.get("c.sendMailMethod");              
            var params = {"recordId":recordId,
                            "toAddresses":toAddresses,
                            "CCAddresses": CCAddresses,
                            "BCCAddresses": BCCAddresses,
                            "selectedFrom": selectedFrom,
                            "mSubject":subject,
                            "mBody":body,
                            "attachmentIds": attachmentList};
            action.setParams(params);
            
            // Add callback behavior for when response is received
            action.setCallback(this, function(response) {
                helper.stopSpinner(component);
                var state = response.getState();
                if (component.isValid() && state === "SUCCESS") {
                    if (component.get("v.jsDebug")) console.log("Response " + JSON.stringify(response.getReturnValue(), null, 4));
                    var isCallSuccess = response.getReturnValue()["isSuccess"];
                    if (isCallSuccess)
                    {                       
                        component.set('v.isFinish', true);
                    }
                    else
                    {
                        helper.setError(component,"Errore di salvataggio",response.getReturnValue()["message"]);        
                    }
                    
                    if (component.get("v.jsDebug")) console.log("isCallSuccess " + isCallSuccess);
                }
                else {
                    if (component.get("v.jsDebug")) console.log("Failed with state: " + state);
                    helper.setError(component,"Errore","Si è verificato un errore nella comunicazione con il server, riprovare più tardi");
        
                }
            });
            
            // Send action off to be executed
            $A.enqueueAction(action);    
        }
    },
 
    // when user click on the close buttton on message popup ,
    // hide the Message box by set the mailStatus attribute to false
    // and clear all values of input fields.   
    closeMessage: function(component, event, helper) {
        component.set("v.mailStatus", false);
        component.set("v.email", null);
        component.set("v.subject", null);
        component.set("v.body", null);
    },
    handleChangeFolder: function(component,event,helper) {
        helper.getEmailTemplates(component, event, helper); 
    },
    handleChangeTemplate: function(component,event,helper) {
        helper.getTemplateHtml(component, event, helper); 
    },
    openSelectTemplate: function(component,event,helper){
        component.set("v.showTemplateBox", true);
        helper.getEmailFolders(component, event, helper);        
    },
    closeSelectTemplate: function(component,event,helper){
        component.set("v.showTemplateBox", false);  
    },
    openAddAttachment: function(component,event,helper){
        component.set("v.showAttachmentBox", true);
    },
    closeAddAttachment: function(component,event,helper){
        component.set("v.showAttachmentBox", false);       
    }
})