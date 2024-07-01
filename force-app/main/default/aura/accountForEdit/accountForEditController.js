({
    clickUpdateAccount: function(component, event, helper) {
        
        var currentAccount = component.get("v.currentAccount");
        helper.updateAccount(component, currentAccount);
        
    },
 
   
    // Load account from Salesforce
    Initialize: function(component, event, helper,userinfomap) {
        
		helper.checkWarning(component, event, helper);
		 
        var accountId = component.get("v.accountId");       
        var CaseId = component.get("v.CaseId");
        var UserIsAdvisor = component.get("v.UserIsAdvisor");
        
    	helper.getListOfRegularExpressions(component);

        component.set("v.AvoidEnrichmentCheck",false);
        component.set("v.ListPopulated",false);
        component.set("v.ListRELPopulated",false);
        
        if (component.get("v.jsDebug")) console.log("id dentro helper: " + accountId);
        
         if (UserIsAdvisor){
            console.log('ACCOUNTID****'+accountId);
            console.log('CASEID****'+CaseId);
                
            var action = component.get("c.getCaseCategory");
            var params = {"CaseId":CaseId};
            action.setParams(params);
            
            action.setCallback(this, function(response) {
                helper.stopSpinner(component);

                if (component.get("v.jsDebug")) console.log("stopping spinner..");
                var state = response.getState();
                if (component.isValid() && state === "SUCCESS") {
                     
                    component.set("v.IsGDPRCase", response.getReturnValue());
                    console.log('IS GDPR CASE'+ JSON.stringify(response.getReturnValue(), null, 4));
                    console.log('is gdpr' + component.get("v.IsGDPRCase"));
                    helper.setPopuptoShow(component);
                    
                   
                
                    var actionTask = component.get("c.getTaskDAOL");
                    var params = {"accountKey":accountId};
                    actionTask.setParams(params);
                    
                    // Add callback behavior for when response is received
                    actionTask.setCallback(this, function(response) {
                    helper.stopSpinner(component);

                    if (component.get("v.jsDebug")) console.log("stopping spinner..");
                        var state = response.getState();
                        if (component.isValid() && state === "SUCCESS") {
                            //component.set("v.OpenTask", response.getReturnValue());
                            console.log("Response " + JSON.stringify(response.getReturnValue(), null, 4)); 
                            var isOpen = response.getReturnValue()["values"]["check"];
                            var isCallSuccess = response.getReturnValue()["isSuccess"];
                            console.log('SUCCESS?'+isCallSuccess);
                            component.set("v.OpenTask",isOpen);
                            component.set("v.isSuccess",isCallSuccess);
                            helper.OpenTask(component);

                        }
                        else {
                            if (component.get("v.jsDebug")) console.log("Failed with state: " + state);
                        }
                    });
                
                    // Send action off to be executed
                    $A.enqueueAction(actionTask);
              
                    

                }
                else {
                    if (component.get("v.jsDebug")) console.log("Failed with state: " + state);
                }
             
                
            });
        
            // Send action off to be executed
            $A.enqueueAction(action);
            }
        
        //FM_02/05/2018 : GDPR - END
        
        
            
       if (!UserIsAdvisor){//accountId!=null
            // Create the action
            console.log('ACCOUNTID****'+accountId);
                
            var actionTask = component.get("c.getTaskDAOL");
            var params = {"accountKey":accountId};
            actionTask.setParams(params);
            
            // Add callback behavior for when response is received
            actionTask.setCallback(this, function(response) {
                helper.stopSpinner(component);

                if (component.get("v.jsDebug")) console.log("stopping spinner..");
                var state = response.getState();
                if (component.isValid() && state === "SUCCESS") {
                    //component.set("v.OpenTask", response.getReturnValue());
                    console.log("Response " + JSON.stringify(response.getReturnValue(), null, 4)); 
                    var isOpen = response.getReturnValue()["values"]["check"];
                    var isCallSuccess = response.getReturnValue()["isSuccess"];
                    console.log('SUCCESS?'+isCallSuccess);
                    component.set("v.OpenTask",isOpen);
                    component.set("v.isSuccess",isCallSuccess);
                    helper.OpenTask(component);

                }
                else {
                    if (component.get("v.jsDebug")) console.log("Failed with state: " + state);
                }
            });
        
            // Send action off to be executed
            $A.enqueueAction(actionTask);
            }


     
            // Create the action
            var action = component.get("c.getAccount");
            var params = {"StringAccountId":accountId};
            action.setParams(params);
            
            // Add callback behavior for when response is received
            action.setCallback(this, function(response) {
                helper.stopSpinner(component);

                if (component.get("v.jsDebug")) console.log("stopping spinner..");
                var state = response.getState();
                if (component.isValid() && state === "SUCCESS") {
                    component.set("v.currentAccount", response.getReturnValue().currentAccount);
                    
                    let telephoneWithPrefix = response.getReturnValue().telephoneWithPrefix;
                    component.set("v.telephoneWithPrefix", JSON.parse(telephoneWithPrefix));
                    if (component.get("v.jsDebug")) console.log("Returned Account " + JSON.stringify(response.getReturnValue().currentAccount, null, 4));
                    if (component.get("v.jsDebug")) console.log("Returned Telephones " + JSON.stringify(response.getReturnValue().telephoneWithPrefix, null, 4));
                    console.log('IL MIO ACCOUNT'+ JSON.stringify(response.getReturnValue().currentAccount, null, 4));
                    var privacy1 = response.getReturnValue().currentAccount.CIF_Privacy_1__c;   
                    if(  privacy1 == undefined || privacy1 == '' || privacy1 == null ){
                            //console.log('DENTRO IF')

                        component.set("v.isPrivacy1populated",false);
                    }
                    
                    helper.sendAccount (component);
                    helper.storeInitialInfo(component);
                    
                   

                }
                else {
                    if (component.get("v.jsDebug")) console.log("Failed with state: " + state);
                }
            });
        
            // Send action off to be executed
            $A.enqueueAction(action);
            //$document.getElementById("imposta_dim").style.width=screen.width + "px";
        

   

            var action_user = component.get("c.getUserInfos");
            var params_user = {"MapUserInfo":userinfomap};
            action_user.setParams(params_user); 
            action_user.setCallback(this, function(response) {
                var state = response.getState();
                if (component.isValid() && state === "SUCCESS") {  
                    component.set("v.UserInfo", response.getReturnValue());  
                    console.log("Returned UserInfo " + JSON.stringify(response.getReturnValue(), null, 4));
                    var userinfomap = response.getReturnValue();
                    component.set("v.UserInfo",userinfomap);
                    var isDAOLAgency = true; 
                    if(userinfomap.isDAOLAgency == 'false')
                        isDAOLAgency = false;
                    component.set("v.isDAOLAgency",isDAOLAgency);
                }
                else {
                    if (component.get("v.jsDebug")) console.log("Failed with state: " + state);
                }
            });
            
            $A.enqueueAction(action_user); 
    },
    
    gotoURL : function (component, event, helper) {
    helper.redirectpage(component, event);   
    },


     
    setGoToCCIR : function (component, event, helper){
    component.set("v.SearchonCCIR",false); //FM_02/05/2018 : GDPR 
    },
	
	setShowWarning : function (component, event, helper){
    component.set("v.showWarning",false); 
    },

    gotoURLcreateRelationship : function (component, event, helper) {
    helper.redirectToRelationship(component, event);   
    },

    //MOSCATELLI_M 31/07/2017: Data Enrichment -- START    
    goBacktoModify : function (component,event,helper)
    {
        helper.goBacktoModify(component); 
   
    },
    goFinishUpdate : function (component,event,helper)
    {

        component.set("v.EnrichError",false);
        component.set("v.AvoidEnrichmentCheck",true);


        
        var currentAccount = component.get("v.currentAccount");
        helper.updateAccount(component, currentAccount);
   
    }
})