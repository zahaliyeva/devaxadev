({
    
    helperMethod : function() {
        
    },
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
    deleteAttachments: function (component,event,helper,attachmentList){
        var action = component.get("c.deleteAttachments");              
        var params = {"attachmentIds": attachmentList,
                      //MMOSCATELLI 25022019: ICF CR — START
                      "recordId" : component.get("v.recordId")
                      //MMOSCATELLI 25022019: ICF CR — END
                     };
        action.setParams(params);
        action.setCallback(this, function(response) {
            this.redirectpage(component);
        });
        $A.enqueueAction(action); 
        
    },
    redirectpage : function (component){
        this.startSpinner(component);
        if (component.get("v.jsDebug")) console.log("inside redirect");
        var pathName = window.location.pathname;
        var agencyIndex = pathName.indexOf("agenzie");
        var myURL = "https://"+window.location.hostname;
        var record = component.get("v.recordId");
        //Giorgio Bonifazi - START
        var crmIndex = pathName.indexOf("crm");
        				   
		//Giorgio Bonifazi - END	
        if (agencyIndex!= -1)
        {
            myURL = myURL+"/agenzie";
        
        myURL = myURL+"/"+record;
        }
        //Giorgio Bonifazi - START
		if (crmIndex !== -1)
        {
            myURL = "https://"+window.location.hostname+"/crm/s/case/" + record + "/close-the-loop";
            window.parent.location.href = myURL;
        }
		//Giorgio Bonifazi - END
        if (component.get("v.jsDebug")) console.log("********"+myURL);
        if (component.get("v.jsDebug")) console.log ("*****sforce.one "+sforce.one);
        /*if ( (typeof sforce.one != 'undefined') && (sforce.one != null) )
        {
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": record,
                "slideDevName": "detail"
            });
            navEvt.fire();
            
        }
        else
        {	
            window.location.href = myURL;
        }*/
        var myEvent = $A.get("e.c:tabclosing");
        myEvent.setParams({"data":"refresh",
                           "recordid":record,
                           "Url":myURL});
        myEvent.fire();
        
        
    },
    setError: function (component,title,message)
    {
        component.set("v.isError",true);
        component.set("v.errorTitle",title);
        component.set("v.errorMsg",message);
    },
    getEmailFolders: function(component, event, helper) {
        this.startSpinner(component); 
        var actFolders = component.get("c.getEmailFolders");
        var foldersList=[];
        actFolders.setCallback(this, function(response) {
            var keys = Object.keys(response.getReturnValue());
            for(var i=0;i< keys.length;i++){
                foldersList.push({ value: keys[i], label: response.getReturnValue()[keys[i]]});
                if(i == 0) component.set ("v.selectedFolder", keys[0]);  
            } 
            component.set ("v.foldersList", foldersList); 
            this.stopSpinner(component); 
        });
        $A.enqueueAction(actFolders);
    },
    getEmailTemplates: function(component, event, helper) {
        this.startSpinner(component); 
        var actTemplates = component.get("c.getEmailTemplates");
        var templatesList=[];
        var selectedFolder = component.get("v.selectedFolder");
        console.log ("selectedFolder: "+selectedFolder );
        var params = {"folderId":selectedFolder};
        actTemplates.setParams(params);
        actTemplates.setCallback(this, function(response) {
            var keys = Object.keys(response.getReturnValue());
            templatesList.push({ value: "", label: "Nessun modello selezionato"});
            for(var i=0;i< keys.length;i++){
                templatesList.push({ value: keys[i], label: response.getReturnValue()[keys[i]]}); 
                //if(i == 0) component.set ("v.selectedTemplate", keys[0]);
            } 
            component.set ("v.templatesList", templatesList);  
            this.stopSpinner(component); 
        });
        $A.enqueueAction(actTemplates);
    },
    getTemplateHtml: function(component, event, helper) {
        this.startSpinner(component); 
        console.log("Gettemplate");
        var actTemplates = component.get("c.populateTemplate");
        var caseId = component.get("v.recordId");  
        var templateId = component.get("v.selectedTemplate"); 
		var defaultTemplate = component.get("v.defaultTemplate");        
        
        if(!templateId && defaultTemplate)
            templateId = defaultTemplate;
        
        if (templateId!= null &&  templateId!= ""){
            var params = {"templateId":templateId, "caseId":caseId};
            console.log("templateId: "+templateId+" caseId: "+caseId);
            actTemplates.setParams(params);
            actTemplates.setCallback(this, function(response) {
                //console.log("Response " + JSON.stringify(response.getReturnValue(), null, 4));
                
                //var esitoElaborazione = response.getReturnValue().values.esitoElaborazione;
                component.set ("v.body", response.getReturnValue().values.body);
                component.set ("v.subject", response.getReturnValue().values.subject);
                if(response.getReturnValue().values.defaultBCC != null){
                    component.set ("v.BCCAddresses", response.getReturnValue().values.defaultBCC);
                }else{
                    component.set ("v.BCCAddresses", "");
                }
                this.stopSpinner(component); 
            });
            $A.enqueueAction(actTemplates);
        }
    },
    getFromList: function(component, event, helper) {
        this.startSpinner(component); 
        var actFrom = component.get("c.getFromList");
        var fromList=[];
        actFrom.setCallback(this, function(response) {
            //console.log("Response " + JSON.stringify(response.getReturnValue(), null, 4));
            //MMOSCATELLI 25022019: ICF CR — START 
            //var keys = Object.keys(response.getReturnValue());
            var OrgWideMap = response.getReturnValue().OrgWideAddrMap;
            var isAgent = response.getReturnValue().isUserAgent;
            var ccAddress = response.getReturnValue().ccAddress; //OAVERSANO 06/03/2019 : ICF CR
            component.set("v.isAgentUser",isAgent);
            
            var keys = Object.keys(OrgWideMap);
            console.log("agent? "+isAgent+' map: '+OrgWideMap);
            //MMOSCATELLI 25022019: ICF CR — END
            var defaultSender = component.get("v.senderAddress");
            
            if(!component.get("v.defaultTemplate") && response.getReturnValue().DefaultTemplateId)
            {
               	component.set("v.defaultTemplate",response.getReturnValue().DefaultTemplateId);
                var self = this;
                self.getTemplateHtml(component, event, helper);
            }
         
            console.log("##template:"+component.get("v.defaultTemplate"));
            
            for(var i=0;i< keys.length;i++){
                var toBeSelected = false;
                if (keys[i] == defaultSender) toBeSelected = true;
                //MMOSCATELLI 25022019: ICF CR — START
                //fromList.push({ value: keys[i], label: response.getReturnValue()[keys[i]], selected: toBeSelected});
                fromList.push({ value: keys[i], label: OrgWideMap[keys[i]], selected: toBeSelected});
                //MMOSCATELLI 25022019: ICF CR — END
            } 
            component.set ("v.fromList", fromList);
            
            //OAVERSANO 06/03/2019 : ICF CR -- START
            if(ccAddress!=null)
            {
            	component.set("v.CCAddresses",ccAddress);
            }
            //OAVERSANO 06/03/2019 : ICF CR -- END
            
            if (defaultSender != "")
            {
                component.set("v.selectedFrom",defaultSender);
            }
            else{
                component.set ("v.selectedFrom", keys[0]);   
            }
            
            //console.log ("valore effettivamente selezionato: "+component.find("fromSelect").get("v.value"));
            
            this.stopSpinner(component); 
        });
        $A.enqueueAction(actFrom);
        
    },
    validateEmail: function (emailArray) {
        var results = [];
        
        for(var i = 0; i < emailArray.length; i++) {
            var email = emailArray[i];
            var re = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
            results[i] = re.test(String(email).toLowerCase());
        }
        
        return results;
    },
    splitEmailString: function (myString) {
        var emailArray = [];
        if(typeof myString!= undefined && myString!= null && myString != "")
        {
            var parsed;
            var emails = myString;
            emails = emails.replace(/,/g ,";");
            for(var i = emails.indexOf(";"); i != -1; i = emails.indexOf(";")) {
                parsed = emails.substring(0, i);
                emailArray.push(parsed);
                emails = emails.substring(i + 1);
            }  
            emailArray.push(emails);
        }
        return emailArray;
    },
    checkEmailField: function (component,event,helper,attributeName){
        var valid = true;
        var addresses = component.get("v."+attributeName);
        if (typeof addresses != "undefined" && addresses != null && addresses!=""){
            var results = [];
            var emailsToBeChecked = [];
            emailsToBeChecked = this.splitEmailString(addresses);
            results=this.validateEmail(emailsToBeChecked);
            for(var i=0;i< results.length;i++){
                if(results[i]==false) valid = false;
            }
        }
        return valid;
    },
    checkAllEmailFields: function (component,event,helper){
        var toValid = this.checkEmailField (component,event,helper,"toAddresses");
        var CCValid = this.checkEmailField (component,event,helper,"CCAddresses");
        var BCCValid = this.checkEmailField (component,event,helper,"BCCAddresses");
        //MMOSCATELLI 25022019: ICF CR — START
        var Subject = component.get("v.subject");
        var Body = component.get("v.body");
        //MMOSCATELLI 25022019: ICF CR — END
        var isError = false;
        var errorMsg = "";
        if (!toValid || !CCValid || !BCCValid)
        {
            isError =true;
            errorMsg = "Sono presenti delle email in formato non valido in: ";
            if (!toValid) errorMsg=errorMsg+"\n - Destinatari";
            if (!CCValid) errorMsg=errorMsg+"\n - CC";
            if (!BCCValid) errorMsg=errorMsg+"\n - BCC";
            //component.set("v.errorMsg",errorMsg);
            this.setError(component,"Dati non validi", errorMsg);
        }
        //MMOSCATELLI 25022019: ICF CR — START
        else if(!Body && !Subject)   
        {
            isError =true;
            errorMsg ="E' necessario sia specificare l'oggetto della comunicazione che compilare il corpo dell'email";
            this.setError(component,"Dati mancanti", errorMsg);
        }            
        else if(!Subject)
        {
            isError =true;
            errorMsg ="E'necessario specificare l'oggetto della comunicazione";
            this.setError(component,"Dati mancanti", errorMsg);
        }
        else if(!Body)
        {
            isError =true;
            errorMsg ="Il corpo dell'email risulta essere vuoto";
            this.setError(component,"Dati mancanti", errorMsg);
        }
        //MMOSCATELLI 25022019: ICF CR — END
        return isError;      
    }
})