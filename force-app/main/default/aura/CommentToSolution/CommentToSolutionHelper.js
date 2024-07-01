({    
    startSpinner: function (cmp) {
        var spinner = cmp.find("mySpinner");
        $A.util.removeClass(spinner, 'slds-hide');
        console.log("SPINNER START");
    },
    stopSpinner: function (cmp) {
        var spinner = cmp.find("mySpinner");
        $A.util.addClass(spinner, 'slds-hide');
        console.log("SPINNER STOP");
    },
	checkError : function(component,event,helper) {
        this.startSpinner(component);
		var caseId = component.get("v.caseId");
        var action = component.get("c.checkError");
        action.setParams({"cCase" : caseId});
        console.log(caseId);
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
                if (component.get("v.jsDebug")) {
                    console.log('Success state');
                    console.log('Data:' + JSON.stringify(response.getReturnValue()));
                }
                component.set("v.showError", response.getReturnValue());
            }
            else if (state === "INCOMPLETE") {
                if (component.get("v.jsDebug"))
                    console.log('Incomplete state');
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        if (component.get("v.jsDebug"))
                            console.log("Error message: " + errors[0].message);
                    }
                } else {
                    if (component.get("v.jsDebug"))
                        console.log("Unknown error");
                }
            }
            this.stopSpinner(component);
            component.set("v.showWhite", false);
        });  
        $A.enqueueAction(action);
	},
	getOrgURL : function(component,event,helper) {
        this.startSpinner(component);
		var action = component.get("c.getOrgURL");         
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
               if (component.get("v.jsDebug")) {
                   console.log('Success state');
                   console.log('Data:' + JSON.stringify(response.getReturnValue()));
               }
               component.set("v.OrgLink", response.getReturnValue());
            }
            else if (state === "INCOMPLETE") {
                if (component.get("v.jsDebug"))
                    console.log('Incomplete state');
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        if (component.get("v.jsDebug"))
                            console.log("Error message: " + errors[0].message);
                    }
                } else {
                    if (component.get("v.jsDebug"))
                        console.log("Unknown error");
                }
            }
            this.stopSpinner(component);
        });
        $A.enqueueAction(action);
	},
	clickCreate : function(component, event, helper) {
        this.startSpinner(component);
        var comm = component.get("v.comment");
        if (comm.length != 0)
        {
            var cCase  = component.get("v.caseId");
            var action = component.get("c.saveComment");
            action.setParams({"cmt" : comm, "cCase" : cCase});
            action.setCallback(this, function(response) {
                
                var state = response.getState();
                if (state === "SUCCESS") {
                    if (component.get("v.jsDebug")) {
                        console.log('Success state');
                        console.log('Data:' + JSON.stringify(response.getReturnValue()));
                    }
                    component.set("v.isCommentToBeInsert", false);
                }
                else if (state === "INCOMPLETE") {
                    if (component.get("v.jsDebug"))
                        console.log('Incomplete state');
                }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            if (component.get("v.jsDebug"))
                                console.log("Error message: " + errors[0].message);
                        }
                    } else {
                        if (component.get("v.jsDebug"))
                            console.log("Unknown error");
                    }
                }
                this.stopSpinner(component);
            });
            $A.enqueueAction(action);
        }
        else
        {
           component.set("v.error", "Attenzione! Per l'annullamento di una richiesta è obbligatorio l'inserimento di un commento");  
           component.set("v.MandatoryInputsMissing", true); 
           this.stopSpinner(component); 
        }   
    },
    closeComment : function(component,event,helper){
        //OAVERSANO 24/01/2019 : NMA Fix Mobile -- START
        //window.open(component.get("v.OrgLink") + component.get("v.caseId"), "_self");
        
        var mobility = component.get("v.isMobility");
        var myURL = "https://"+window.location.hostname;
        var caseId = component.get("v.caseId");
        if(mobility){
            myURL = myURL+"/crm/s/case/"+caseId+"/detail";
            window.location.href = myURL; 
        } else {
        
        var myEvent = $A.get("e.c:tabclosing");
        myEvent.setParams({"data":"cancel",
                           "recordid":component.get("v.caseId"),
                           "Url":component.get("v.OrgLink")});
        myEvent.fire();
        //OAVERSANO 24/01/2019 : NMA Fix Mobile -- END
    	}     
    },
    cancelBtn : function(component){    	
        //OAVERSANO 24/01/2019 : NMA Fix Mobile -- START
        //window.open(component.get("v.OrgLink") + component.get("v.caseId"), "_self");   
        
        var mobility = component.get("v.isMobility");
        var myURL = "https://"+window.location.hostname;
        var caseId = component.get("v.caseId");
        if(mobility){
            myURL = myURL+"/crm/s/case/"+caseId+"/detail";
            window.location.href = myURL; 
        } else {
        
        var myEvent = $A.get("e.c:tabclosing");
        myEvent.setParams({"data":"cancel",
                           "recordid":component.get("v.caseId"),
                           "Url":component.get("v.OrgLink")});
        myEvent.fire();
        //OAVERSANO 24/01/2019 : NMA Fix Mobile -- END
    	} 
    },
    closeMissingInputsModal: function(component,event,helper){
        component.set("v.MandatoryInputsMissing", false);
    }
})