({
    Initialize : function(component, event, helper) {
        var action = component.get("c.getAgencyUsers"); 
        var queueType  = component.get("v.queueType");
        var params = {"queueType":queueType};
        action.setParams(params);
        
        // Add callback behavior for when response is received
        action.setCallback(this, function(response) {
            helper.stopSpinner(component);
            
            if (component.get("v.jsDebug")) console.log("stopping spinner..");
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                
                if (component.get("v.jsDebug")) console.log("Response " + JSON.stringify(response.getReturnValue(), null, 4));
                var isCallSuccess = response.getReturnValue()["isSuccess"];
                if (isCallSuccess)
                {                    
                    var usrList = response.getReturnValue().values.userList;
                    //console.log("usrList " + JSON.stringify(usrList, null, 4));                    
                    component.set('v.userList', usrList);

                    if (usrList && usrList[0]) {
                        component.set('v.officialEmail', usrList[0].singleUser.Contact.Account.Destinatario_notifica_Feedback_Case__c);
                    }

                    var regExpValidator = response.getReturnValue().values.regExpValidator;                  
                    if (regExpValidator) {
                        
                        var validations = {};
                        for (var i = 0; i < regExpValidator.length; i++) 
                            validations[regExpValidator[i].QualifiedApiName] = regExpValidator[i].RegEx__c;                      
  
                        component.set("v.patternEmail", validations['Email_RegEx']);                                              
                    }

                }else
                {
                    component.set('v.insufficientPermissions', true);
                }
                
                if (component.get("v.jsDebug")) console.log("isCallSuccess " + isCallSuccess);
            }
            else {
                if (component.get("v.jsDebug")) console.log("Failed with state: " + state);
            }
        });
        
        // Send action off to be executed
        $A.enqueueAction(action);
        
    },
    saveUpdates : function(component, event, helper) {
        var usrList = component.get("v.userList");
        //console.log("usrList " + JSON.stringify(usrList, null, 4));
        var atLeastOneActiveInQueue = false;
        var isInQueueArray =[];
        var userArray=[];
        for (var i = 0; i < usrList.length; i++) {
			  
            var currentUser = usrList[i];
            //console.log(currentUser);
            if(component.get("v.queueType") === "Case"){
            currentUser.isInQueue = currentUser.AbilitazioneCTL || currentUser.AbilitazioneIvass;
            currentUser.singleUser.Abilitazione_CTL__c = currentUser.AbilitazioneCTL;
            currentUser.singleUser.Abilitazione_IVASS41__c = currentUser.AbilitazioneIvass;
            }
            userArray.push(currentUser.singleUser); 
            isInQueueArray.push(currentUser.isInQueue);
            if (currentUser.isInQueue && currentUser.singleUser.IsActive)
            {
                atLeastOneActiveInQueue = true;
            }
        }
        if (!atLeastOneActiveInQueue)
        {
            helper.setError(component,"Coda vuota","Impossibile salvare in quanto deve essere selezionato almeno un utente di Agenzia");
        }
        else
        {
            //SEND THIS VARIABLE TO THE SERVER
            var action = component.get("c.saveUpdateRequest");
            var queueType  = component.get("v.queueType");                   
            var params = {"isInQueue":isInQueueArray,
                         "userList":userArray,
                        "queueType":queueType};
            action.setParams(params);
            
            // Add callback behavior for when response is received
            action.setCallback(this, function(response) {
                helper.startSpinner(component);
                var state = response.getState();
                if (component.isValid() && state === "SUCCESS") {
                    helper.stopSpinner(component);
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
    closeError : function(component, event, helper) {
        component.set("v.isError",false);
    },  
    closeWarning : function(component, event, helper) {
        component.set("v.showWarningMessageSaveEmail",false);
    },
    openWarning : function(component, event, helper) {
        component.set("v.showWarningMessageSaveEmail",true);
    },
    finish : function(component, event, helper) {
        helper.redirectpage(component);
    },
    gotoURL : function (component, event, helper) {
    	helper.redirectpage(component, event);   
    },

    saveEmail : function(component, event, helper) {
        component.set("v.showWarningMessageSaveEmail",false);
       
        var emails = component.get("v.officialEmail"); 
        
        if (typeof emails !='undefined' &&  emails !='')
        {
            var listEmail = emails.split(";");  
            var validatorEmails = true;
            
            for (let i = 0; i < listEmail.length; i++) {
            let check = helper.validateMail(component,listEmail[i]);
                if(!check)
                {
                validatorEmails = false;
                break;
                }
            }
          
            if(!validatorEmails)
               helper.setError(component,"Errore di salvataggio","Formato email non valido.");  
            else
            {
                const action = component.get("c.setOfficialAgencyEmail");
                const params = {
                    "emailValue": component.get("v.officialEmail")
                };
                action.setParams(params);
        
                action.setCallback(this, function(response) {
                    helper.startSpinner(component);
                    const state = response.getState();
                    //console.log(state);
                    if (component.isValid() && state === "SUCCESS") {
                        helper.stopSpinner(component);
                        if (component.get("v.jsDebug")) console.log("Response " + JSON.stringify(response.getReturnValue(), null, 4));
                        const isCallSuccess = response.getReturnValue()["isSuccess"];
                        if (isCallSuccess) {
                            self.alert('La mail è stata correttamente modificata.');
                        } else {
                            helper.setError(component,"Errore di salvataggio",response.getReturnValue()["message"]);
                        }
                        if (component.get("v.jsDebug")) console.log("isCallSuccess " + isCallSuccess);
                    } else {
                        if (component.get("v.jsDebug")) console.log("Failed with state: " + state);
                        helper.setError(component,"Errore","Si è verificato un errore nella comunicazione con il server, riprovare più tardi");
                    }
                });
                $A.enqueueAction(action);
                
            }  
        }
        else 
          helper.setError(component,"Errore","Campo vuoto");
      }
    
})