({    
    /*startSpinner: function (cmp) {
        var spinner = cmp.find("mySpinner");
        $A.util.removeClass(spinner, 'slds-hide');
        console.log("SPINNER START");
    },
    stopSpinner: function (cmp) {
        var spinner = cmp.find("mySpinner");
        $A.util.addClass(spinner, 'slds-hide');
        console.log("SPINNER STOP");
    },*/
	feedbackConfiguration : function(component, event, helper) {
        //this.startSpinner(component);
		var origin       = component.get("v.origin");
        var caseId       = component.get("v.caseId");
        var action      = component.get("c.getFeedbackConfiguration");
        console.log(' ===> origin: ' + origin);
        action.setParams({"caseOrigin" : origin, "caseId" : caseId});
        action.setCallback(this, function(response1) {
            
            var state1 = response1.getState();
            if (state1 === "SUCCESS") {
                if (component.get("v.jsDebug")) {
                    console.log('Success state');
                    console.log('Data:' + JSON.stringify(response1.getReturnValue()));
                }
                var resp = response1.getReturnValue();
                console.log('Resp= '+resp);
                component.set("v.welcomeMessage", resp.Welcome_Message__c);
                component.set("v.question1", resp.Question_1__c);
                //OAVERSANO 05/03/2019 : NMA Enhancement VII -- START
                //component.set("v.question2", resp.Question_2__c);
                //OAVERSANO 05/03/2019 : NMA Enhancement VII -- END
            }
            else if (state1 === "INCOMPLETE") {
                if (component.get("v.jsDebug"))
                    console.log('Incomplete state');
            }
            else if (state1 === "ERROR") {
                var errors = response1.getError();
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
            //this.stopSpinner(component);
        });  
        $A.enqueueAction(action);
	},
	checkError : function(component, event, helper) {
       // this.startSpinner(component);
		var caseId  = component.get("v.caseId");  
        var action = component.get("c.checkError");
        action.setParams({"cCase" : caseId,
                          "SurveyOrigin": component.get("v.origin")});
        action.setCallback(this, function(response2) {
            
            var state2 = response2.getState();
            if (state2 === "SUCCESS") {
                if (component.get("v.jsDebug")) {
                    console.log('Success state');
                    console.log('Data:' , response2.getReturnValue());
                }
                component.set("v.showError", response2.getReturnValue().showError);
                component.set("v.ErrorMsg",response2.getReturnValue().ErrorMsg);
                component.set("v.OrgLink", response2.getReturnValue().OrgUrl);
                
                if(!response2.getReturnValue().showError)
                {
                    var self = this;
                    self.feedbackConfiguration(component, event, helper);
                }
            }
            else if (state2 === "INCOMPLETE") {
                if (component.get("v.jsDebug"))
                    console.log('Incomplete state');
            }
            else if (state2 === "ERROR") {
                var errors = response2.getError();
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
            // this.stopSpinner(component);
            component.set("v.showWhite", false);
            component.set("v.Spinner", false);
        });  
        $A.enqueueAction(action);
	},
    checkEmailFeedback : function(component, event, helper) {
       // this.startSpinner(component);
		var caseId  = component.get("v.caseId");  
        var action = component.get("c.checkEmailFeedbackCTRL");
        action.setParams({"cCase" : caseId});
        action.setCallback(this, function(response2) {
            
            var state2 = response2.getState();
            if (state2 === "SUCCESS") {
                let result = response2.getReturnValue();
                if(result)
                {
                    component.set("v.showError", response2.getReturnValue().showError);
                    component.set("v.ErrorMsg",response2.getReturnValue().ErrorMsg);
                    component.set("v.OrgLink", response2.getReturnValue().OrgUrl);
                    if(!response2.getReturnValue().showError)
                    {
                        var self = this;
                        self.feedbackConfiguration(component, event, helper);
                    }
                }
            }
            else if (state2 === "INCOMPLETE") {
                if (component.get("v.jsDebug"))
                    console.log('Incomplete state');
            }
            else if (state2 === "ERROR") {
                var errors = response2.getError();
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
            // this.stopSpinner(component);
            component.set("v.showWhite", false);
            component.set("v.Spinner", false);
        });  
        $A.enqueueAction(action);
	},
	getOrgURL : function(component, event, helper) {
        //this.startSpinner(component);
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
            //this.stopSpinner(component);
         });
        $A.enqueueAction(action);
	},
	clickCreate : function(component,event,helper) {
		// this.startSpinner(component);
		//OAVERSANO 05/03/2019 : NMA Enhancement VII -- START
		//var sSpeed        = component.get("v.ratingSpeed");
        //var aCompleteness = component.get("v.ratingCompleteness");  
        var overallRating = component.get("v.overallRating");
        //OAVERSANO 05/03/2019 : NMA Enhancement VII -- END
        var comm          = component.get("v.comment");
        //OAVERSANO 05/03/2019 : NMA Enhancement VII -- START
        //if (parseInt(aCompleteness, 10) == 0 || parseInt(sSpeed, 10) == 0)
        if (parseInt(overallRating, 10) == 0)
        //OAVERSANO 05/03/2019 : NMA Enhancement VII -- END
        {
           // if (parseInt(sSpeed, 10) == 0 || parseInt(aCompleteness, 10) == 0)
            //{
                component.set("v.error", 'Attenzione! È obbligatorio fornire una valutazione sul supporto ricevuto cliccando sul numero di stelle che si desidera assegnare');        
                component.set("v.MandatoryInputsMissing", true);
                //this.stopSpinner(component);
            //}
        }
        //OAVERSANO 05/03/2019 : NMA Enhancement VII -- START
        //else if ((parseInt(aCompleteness, 10) <= 5 || parseInt(sSpeed, 10) <= 5) && comm.length == 0)
        else if ( parseInt(overallRating, 10) <= 6 && comm.length == 0)
        //OAVERSANO 05/03/2019 : NMA Enhancement VII -- END
        {
            console.log('minor');
            component.set("v.error", 'Attenzione! Per una valutazione inferiore o uguale a 6 stelle è obbligatorio inserire un commento');
            component.set("v.MandatoryInputsMissing", true);
        //    this.stopSpinner(component);
        }
        else
        {
            var origin  = component.get("v.origin");
            var rType   = component.get("v.recordType");
            var caseId  = component.get("v.caseId");
            var action  = component.get("c.saveFeedback");
            //OAVERSANO 05/03/2019 : NMA Enhancement VII -- START
            //action.setParams({"serviceSpeed" : sSpeed, "answerCompleteness" : aCompleteness, "cmt" : comm, "origin" : origin, "recordType" : rType, "cCase" : caseId});
            action.setParams({"overallRating" : overallRating, "cmt" : comm, "origin" : origin, "recordType" : rType, "cCase" : caseId});
            //OAVERSANO 05/03/2019 : NMA Enhancement VII -- END
            action.setCallback(this, function(response) {
                
                var state = response.getState();
                if (state === "SUCCESS") {
                    if (component.get("v.jsDebug")) {
                        console.log('Success state');
                        //console.log('Data:' + JSON.stringify(response.getReturnValue()));
                    }
                    component.set("v.showError", response.getReturnValue().showError);
                	component.set("v.ErrorMsg",response.getReturnValue().ErrorMsg);
                    
                    
                    if(!response.getReturnValue().showError)
                    	component.set("v.isFeedbackToBeInsert", false);
                }
                else if (state === "INCOMPLETE") {
                    if (component.get("v.jsDebug"))
                        console.log('Incomplete state');
                }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    console.log(" ==> Error: ");
                    console.log(errors);
                    if (component.get("v.jsDebug")){
                        console.log("Error state");
                        console.log(errors);
                    }
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
               // this.stopSpinner(component);
            });  
            $A.enqueueAction(action);  
        }
	},
    closeFeedback : function(component,event,helper){
        //window.open(component.get("v.OrgLink") + component.get("v.caseId"), "_self");   
        //OAVERSANO 24/01/2019 : NMA Fix Mobile -- START
		/*if(component.get("v.UserTheme") == "Theme4t")
        {
           window.location = "salesforce1://sObject/"+component.get("v.caseId")+"/view";
           self.close();
        }
        else
        {
           window.open(component.get("v.OrgLink") + component.get("v.caseId"), "_self");
        }*/
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
        /*if(component.get("v.UserTheme") == "Theme4t")
        {
           window.location = "salesforce1://sObject/"+component.get("v.caseId")+"/view";
           self.close();
        }
        else
        {
            if(component.get("v.origin")=="Chat")
                window.close();
            else
                window.open(component.get("v.OrgLink") + component.get("v.caseId"), "_self");
        }*/
        
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