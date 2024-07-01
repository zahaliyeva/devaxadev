({ /*   
    startSpinner: function (cmp) {
        var spinner = cmp.find("mySpinner");
        $A.util.removeClass(spinner, 'slds-hide');
        console.log("SPINNER START");
    },
    stopSpinner: function (cmp) {
        var spinner = cmp.find("mySpinner");
        $A.util.addClass(spinner, 'slds-hide');
        console.log("SPINNER STOP");
    },*/
    getOrgURL: function(component) {
       // this.startSpinner(component);
        var action = component.get("c.getOrgURL");
        action.setParams({"cCase" : component.get("v.caseId")});//new
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
               if (component.get("v.jsDebug")) {
                   console.log('Success state');
                   console.log('Data:' + JSON.stringify(response.getReturnValue()));
               }
               var results = response.getReturnValue();
               component.set("v.OrgLink", response.getReturnValue().OrgUrl);
               component.set("v.isFunctionalityAvailable", response.getReturnValue().isAvailable);
               //component.set("v.OrgLink", response.getReturnValue());
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
           // this.stopSpinner(component);
           component.set("v.showWhite", false);
        });  
        $A.enqueueAction(action);            
    },
    cancelBtn : function(component) { 
        //OAVERSANO 23/01/2019 : NMA Fix Mobile -- START
        //window.location.replace(component.get("v.OrgLink") + component.get("v.caseId"));
        
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
    closeCaseBtn : function(component) {
        //this.startSpinner(component);
        var comm = component.get("v.comment");
        if (comm.length != 0)
        {
            var cCase  = component.get("v.caseId");
            //OAVERSANO 05/12/2018 : FIX -- START
            var caseStatus = component.get("v.caseStatus");
            console.log('caseStatus: ',caseStatus);
            //OAVERSANO 05/12/2018 : FIX -- END
            var action = component.get("c.closeCase");
            action.setParams({"cmt" : comm, "cCase" : cCase,
                          //OAVERSANO 05/12/2018 : FIX -- START
                          "CaseStatus" : caseStatus});
        					//OAVERSANO 05/12/2018 : FIX -- END
            action.setCallback(this, function(response) {
                
                var state = response.getState();
                if (state === "SUCCESS") {
                    if (component.get("v.jsDebug")) {
                        console.log('Success state');
                        if(response.getReturnValue())
                        {
                            component.set("v.error",response.getReturnValue());
                            component.set("v.MandatoryInputsMissing",true)
                        }
                        else
                            component.set("v.isCommentToBeInsert", false);
                        //console.log('Data:' + JSON.stringify(response.getReturnValue()));
                    }
                    //component.set("v.isCommentToBeInsert", false);
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
              //  this.stopSpinner(component);
            });  
            $A.enqueueAction(action);  
        }
        else
        {
           component.set("v.error", "Attenzione! Bisogna lasciare obbligatoriamente un commento");
           component.set("v.MandatoryInputsMissing", true); 
        }   
    },
    CloseMissingInputsModal: function(component){
        component.set("v.MandatoryInputsMissing", false);
    },
    closePage : function(component){
        //OAVERSANO 23/01/2019 : NMA Fix Mobile -- START
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
    }
})