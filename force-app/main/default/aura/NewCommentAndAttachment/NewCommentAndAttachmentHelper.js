({
    startSpinner: function (cmp) {
        var spinner = cmp.find("mySpinner");
        $A.util.removeClass(spinner, 'slds-hide');
        //console.log("SPINNER START");
    },
    stopSpinner: function (cmp) {
        var spinner = cmp.find("mySpinner");
        $A.util.addClass(spinner, 'slds-hide');
        //console.log("SPINNER STOP");
    },
    //deleteAttachments: function (component,event,helper,attachmentList) {
    deleteAttachments: function (component,attachmentList) {
        //console.log('delete');
        this.startSpinner(component);
        var action = component.get("c.deleteAttachments");             
        var params = {"attachmentIds": attachmentList};
        action.setParams(params);
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if (component.get("v.jsDebug"))
                    console.log('Success state');
                // $A.get('e.force:refreshView').fire();
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
                }
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
        //window.location.replace(component.get("v.OrgLink") + component.get("v.caseId"));
    },
    checkError : function(component){

        
        this.startSpinner(component);
        var caseId = component.get("v.caseId");
        var action = component.get("c.checkError");
        action.setParams({"cCase" : caseId});
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
                if (component.get("v.jsDebug")) {
                    console.log('Success state');
                    console.log('Data:' + JSON.stringify(response.getReturnValue()));
                }
                component.set("v.showError", response.getReturnValue().show);
                console.log("ERROR :", response.getReturnValue().show);
                component.set("v.Errorchecked", response.getReturnValue().message);
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
    checkshowSupportHD1 : function(component){
        this.startSpinner(component);
        var action = component.get("c.checkProfileSupportHD1");       
        var caseId = component.get("v.caseId");  
        var params = {"caseId": caseId};
        action.setParams(params);
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if (component.get("v.jsDebug")) {
                    console.log('Success state');
                    console.log('Data:' + JSON.stringify(response.getReturnValue()));
                }
                
                //MOSCATELLI 11/02/2019: Lob Contabilità -- START
                var userRole = component.get("v.userRole");
                
                if(userRole!="HD1 Contabilita" && userRole!="HD1 Contenzioso")
                //MOSCATELLI 11/02/2019: Lob Contabilità -- END
                	component.set("v.showSupportHD1", response.getReturnValue());
                //OAVERSANO 17/12/2018 : Enhancement NMA Biz III -- START
                if(response.getReturnValue())
                {
                	component.set("v.showShareFile_Flag", true);
                }
                /*else
                {
                	component.set("v.showShareFile_Flag", false);
                }*/
                //OAVERSANO 17/12/2018 : Enhancement NMA Biz III -- END
                //MOSCATELLI_M 25/10/2018: NMA Business -- START
                if(component.get("v.showSupportHD1"))
                    component.set("v.SupportType","Supporto HD1 IT");
                //MOSCATELLI 11/02/2019: Lob Contabilità -- START
                //else if(component.get("v.showSupportHD1Biz"))
                //OAVERSANO 19/03/2019 : Fix Contenzioso -- START
                //else if(component.get("v.showSupportHD1Biz") || component.get("v.showSupportHD1Contabilita") || component.get("v.showSupportHD1Contenzioso"))
                else if(component.get("v.showSupportHD1Biz") || component.get("v.showSupportHD1Contabilita") )
                //MOSCATELLI 11/02/2019: Lob Contabilità -- END
                    component.set("v.SupportType","Supporto HD1 Biz");
                else if(component.get("v.showSupportHD1Contenzioso"))
                {
                    component.set("v.SupportType","Agente");
                    component.set("v.toggleRecordType","Agente");
                }
                //OAVERSANO 19/03/2019 : Fix Contenzioso -- END
                //MOSCATELLI_M 25/10/2018: NMA Business -- END     
            } else if (state === "INCOMPLETE") {
                if (component.get("v.jsDebug"))
                    console.log('Incomplete state');
            } else if (state === "ERROR") {
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
    checkProfileHD2 : function(component){
        var action = component.get("c.checkProfileHD2");         
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if (component.get("v.jsDebug")) {
                    console.log('Success state');
                    console.log('Data:' + JSON.stringify(response.getReturnValue()));
                }
                if (response.getReturnValue()) {
                    component.set("v.toggleRecordType", "Supporto");
                }
            } else if (state === "INCOMPLETE") {
                if (component.get("v.jsDebug"))
                    console.log('Incomplete state');
            } else if (state === "ERROR") {
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
        });  
        $A.enqueueAction(action);  
    },
    //Giorgio Bonifazi - START
    checkCaringAngel: function (component){
        var action = component.get("c.checkCaringAngel");         
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if (component.get("v.jsDebug")) {
                    console.log('Success state');
                    console.log('Data:' + JSON.stringify(response.getReturnValue()));
                }
                if (response.getReturnValue()) {
                    console.log("*****" +response.getReturnValue())
                    component.set("v.showCaringAngel", true);
                }
            } else if (state === "INCOMPLETE") {
                if (component.get("v.jsDebug"))
                    console.log('Incomplete state');
            } else if (state === "ERROR") {
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
        });  
        $A.enqueueAction(action); 
    },
    checkSmartCenterProfile: function (component){
        var action = component.get("c.checkSmartCenter");         
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if (component.get("v.jsDebug")) {
                    console.log('Success state');
                    console.log('Data:' + JSON.stringify(response.getReturnValue()));
                }
                if (response.getReturnValue()) {
                    
                    component.set("v.showSmartCenter", true);
                    console.log("SMART CENTER?", component.get("v.showSmartCenter"))
                }
            } else if (state === "INCOMPLETE") {
                if (component.get("v.jsDebug"))
                    console.log('Incomplete state');
            } else if (state === "ERROR") {
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
        });  
        $A.enqueueAction(action); 
    },
    // Giorgio Bonifazi - END
    getOrgURL : function(component){            
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
    cancelBtn : function(component){
        var attachmentList = component.get("v.attachmentList");
        if (component.get("v.jsDebug"))
            console.log(attachmentList);
        if (attachmentList.length != 0)
        {
            var self = this;
            //self.deleteAttachments(component, event, helper, attachmentList);   
            self.deleteAttachments(component, attachmentList);      
        }
        else
        {
            //console.log('@@FIRE!!!');
                        
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
            }
        }  
    },
    closeComment : function(component,event,helper){
        //console.log('@@FIRE!!!');
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
        }
        //window.open(component.get("v.OrgLink") + component.get("v.caseId"), "_self");        
    },
    closeMissingInputsModal: function(component,event,helper){
        component.set("v.MandatoryInputsMissing", false);
    },
    clickCreate : function(component){
        var comm           = component.get("v.comment");
        var attachmentList = component.get("v.attachmentList");
		// Giorgio Bonifazi 23/07/2019 : Caring Angel fase 2 - START -->
        var motivo = component.get("v.selectedValue");


        if(component.get("v.showCaringAngel") && (comm.length == 0  && motivo == "Altro")||(comm.length == 0 && motivo == "" && attachmentList.length ==0 )){
        
            component.set("v.error", 'Attenzione! Non è stato inserito alcun commento / allegato');
            component.set("v.MandatoryInputsMissing", true);
            return;}
         //else if(comm.length == 0  && attachmentList.length == 0 ){
            //component.set("v.error", 'Attenzione! Non è stato inserito alcun commento / allegato');
            //component.set("v.MandatoryInputsMissing", true);
        //}
        // Giorgio Bonifazi 23/07/2019 : Caring Angel fase 2 - END -->
        
            this.startSpinner(component);
            var caseId = component.get("v.caseId");
            var rT     = component.get("v.toggleRecordType");
            console.log('@@rt: '+rT);
            console.log('@@Label: '+component.get("v.SupportType"));
            
            var action = component.get("c.saveCommentAttachment");
            action.setParams({"cmt" : comm, "cCase" : caseId, "rT" : rT, "numberOfAttachment" : attachmentList.length, "attachmentList" : component.get("v.attachmentListFileNames"), "OrgUrl" :component.get("v.OrgLink"), "Label": component.get("v.SupportType"), "profileName": component.get("v.profileName"), "userRole": component.get("v.userRole"), "defectCheckbox" : "false"});
			// Giorgio Bonifazi 23/07/2019 : Caring Angel fase 2 - START -->
            let request = {
                "cmt" : comm, 
                "cCase" : caseId, 
                "rT" : rT, 
                "numberOfAttachment" : attachmentList.length, 
                "attachmentList" : component.get("v.attachmentListFileNames"), 
                "OrgUrl" :component.get("v.OrgLink"), 
                "Label": component.get("v.SupportType"), 
                "profileName": component.get("v.profileName"), 
                "userRole": component.get("v.userRole"),
				"defectCheckbox" : "false",
                "motivoTrasferimento" : component.get("v.selectedValue")
            };
            // Giorgio Bonifazi 23/07/2019 : Caring Angel fase 2 - END -->
            action.setParams(request);			   					  
            action.setCallback(this, function(response) {
                
                var state = response.getState();
                if (state === "SUCCESS") {
                    if (component.get("v.jsDebug")) {
                        console.log('Success state');
                        //console.log('Data:' + JSON.stringify(response.getReturnValue()));
                        var result = response.getReturnValue();
                        console.log(' server Response: '+result);
                        if(result != "OK")
                        {
                            component.set("v.MandatoryInputsMissing",true);
                            component.set("v.error","Attenzione, non è stato possibile procedere con l'operazione richiesta. Riprova più tardi, se il problema persiste contattaci telefonicamente.");
                        }
                        //console.log(" +++++ ====> è console: " + sforce.console.isInConsole());
                        if(typeof sforce != 'undefined' && sforce.one!= undefined ) {
                            if(sforce.console.isInConsole() && result == "OK"){
                                console.log(' ===> is in console');
                                sforce.console.getEnclosingPrimaryTabId(function(primarytab)
                                                                        {
                                                                            console.log('primary: '+primarytab.id );
                                                                            sforce.console.refreshPrimaryTabById(primarytab.id, 
                                                                                                                 true, 
                                                                                                                 function refreshSuccess(result) {
                                                                                                                     //Report whether refreshing the primary tab was successful
                                                                                                                     if (result.success == true) {
                                                                                                                         console.log('Primary tab refreshed successfully');
                                                                                                                     } else {
                                                                                                                         console.log('Primary did not refresh');
                                                                                                                     }
                                                                                                                 }, true);
                                                                        }); 
                                var myEvent = $A.get("e.c:tabclosing");
                                myEvent.setParams({"data":"cancel",
                                                   "recordid":component.get("v.caseId"),
                                                   "Url":component.get("v.OrgLink")});
                                myEvent.fire();
                            } else if(!sforce.console.isInConsole() && result == "OK") {
                                console.log(' ===> is in not console');
                                var myEvent = $A.get("e.c:tabclosing");
                                myEvent.setParams({"data":"cancel",
                                                   "recordid":component.get("v.caseId"),
                                                   "Url":component.get("v.OrgLink")});
                                myEvent.fire();                           
                                
                            }
                        }else{
                            var mobility = component.get("v.isMobility");
                            var myURL = "https://"+window.location.hostname;
                            var caseId = component.get("v.caseId");
                            if(mobility){
                                myURL = myURL+"/crm/s/case/"+caseId+"/detail";
                                window.location.href = myURL; 
                            }else{
                                var myEvent = $A.get("e.c:tabclosing");
                                myEvent.setParams({"data":"cancel",
                                                   "recordid":component.get("v.caseId"),
                                                   "Url":component.get("v.OrgLink")});
                                myEvent.fire();
                            }
                                

                        }
                    }
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
    checkProfileAgent : function(component){
        this.startSpinner(component);
        var action = component.get("c.verificaProfiloAgente");         
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if (component.get("v.jsDebug")) {
                    console.log('Success state');
                    console.log('Data:' + JSON.stringify(response.getReturnValue()));
                }
                if (response.getReturnValue()) {
                    component.set("v.toggleRecordType", "Agente");
                    //Giorgio Bonifazi ENH Automazione Case
                    
                    if(component.get("v.toggleRecordType") == "Agente")
                    component.set("v.showAgent", true);
                    console.log("ISAGENTE? ", component.get("v.showAgent"));
                }
            } else if (state === "INCOMPLETE") {
                if (component.get("v.jsDebug"))
                    console.log('Incomplete state');
            } else if (state === "ERROR") {
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
        });  
        $A.enqueueAction(action);      
    },
    //MOSCATELLI_M 25/10/2018: NMA Business -- START    
    checkshowSupportHD1Biz : function(component){      
        var profileName = component.get("v.profileName");
        var userRole = component.get("v.userRole");//MMOSCATELLI 11/02/2019: Lob Contabilità
        
        if(profileName=="AAI - Supporto HD1 BIZ" || profileName=="AAI - Supporto HD1 BIZ - Buon Lavoro")
        {
            component.set("v.showSupportHD1Biz",true);
            //OAVERSANO 17/12/2018 : Enhancement NMA Biz III -- START
            component.set("v.showShareFile_Flag", true);
            //OAVERSANO 17/12/2018 : Enhancement NMA Biz III -- END
        }
        //MMOSCATELLI 11/02/2019: Lob Contabilità --START
        else if(profileName=="AAI - Supervisor Supporto HD1 Contabilità" || profileName=="AAI - Supervisor Supporto HD1 Contabilita" ||
               userRole== "HD1 Contabilita")
        {
            component.set("v.showShareFile_Flag", true);
            component.set("v.showSupportHD1Contabilita",true);
        }
        else if(profileName=="AAI - Supervisor Supporto HD1 Contenzioso" ||
               userRole== "HD1 Contenzioso")
        {
            component.set("v.showShareFile_Flag", true);
            component.set("v.showSupportHD1Contenzioso",true);
        }
        //MMOSCATELLI 11/02/2019: Lob Contabilità --END
    },
    //MOSCATELLI_M 25/10/2018: NMA Business -- END  
    
    //OAVERSANO 19/12/2018 : Enhancement NMA Biz III -- START
    checkCaseRecordTypeServer : function(component, event, helper)
    {
    	console.log("checkCaseRecordTypeServer");
    	this.startSpinner(component);
    	var caseID = component.get("v.caseId");
        var action = component.get("c.checkCaseRecordType");   
        var params = {"caseId": caseID};
        action.setParams(params);      
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if (component.get("v.jsDebug")) {
                    console.log('Success state');
                    //console.log('Data:' + JSON.stringify(response.getReturnValue()));
                }
                if (response.getReturnValue()!=null) {
                	//OAVERSANO 09/05/2019 : NMA LOB Vita -- START
                    var recordType = response.getReturnValue().values['recordTypeToReturn'];
                    var LOB = response.getReturnValue().values['LOB'];
                    component.set('v.caseLob',LOB);
                    console.log("recordType: ",recordType);
                    console.log("LOB: ",LOB);
                    //OAVERSANO 09/05/2019 : NMA LOB Vita -- END
                    if(recordType == "Close the loop")
                    {
                    	component.set("v.toggleRecordType","Agente");
                    }
                }
            } else if (state === "INCOMPLETE") {
                if (component.get("v.jsDebug"))
                    console.log('Incomplete state');
            } else if (state === "ERROR") {
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
        });  
        $A.enqueueAction(action); 
    },
    //OAVERSANO 19/12/2018 : Enhancement NMA Biz III -- END
	//Giorgio Bonifazi 23/07/2019 : Caring Angel fase 2 - START -->
    getPicklistValues: function(component, event, helper) {
        var action = component.get("c.getPickListValuesIntoList");
        let request = {
            objectType: component.get("v.sObjectName"),
            selectedField: component.get("v.fieldName")
        };
        action.setParams(request);
        action.setCallback(this, function(response) {
            var list = response.getReturnValue(); 
            component.set("v.picklistValues", list);
        })
        $A.enqueueAction(action);
    },
    //Giorgio Bonifazi 23/07/2019 : Caring Angel fase 2 - END -->
    
     // d.pirelli send automatic case start
    checkVisibilitiesButtons : function(component, event, helper) {
      
        var action = component.get("c.checkVisibilitiesButtonsSendSupport");
                  
        var caseId = component.get("v.caseId");  
        var params = {caseId: caseId, userRole: component.get("v.userRole") };
        action.setParams(params);
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
            let mapVisibilities=response.getReturnValue();
            
                component.set("v.showButtonSend1" ,response.getReturnValue()['buttonSend1']); //Invio a Secondo livello
                component.set("v.showButtonSend2" ,response.getReturnValue()['buttonSend2']); //Ritorna al Primo livello
                component.set("v.showButtonSend3" ,response.getReturnValue()['buttonSend3']); //Invia ad Altra Area
                component.set("v.showButtonSend4" ,response.getReturnValue()['buttonSend4']); //Invia a Modulo di calcolo AXA
                component.set("v.showButtonSend5" ,response.getReturnValue()['buttonSend5']); //Invia a Modulo di calcolo
                component.set("v.showButtonSend6" ,response.getReturnValue()['buttonSend6']); //Invia ad Agenzia
            }
           
          
      
        });  
        $A.enqueueAction(action); 
        
    },
    
     showComponentInModal : function(component, event, helper,whichCmp) {
        //Dynamic creation of lightningModalChild component and appending its markup in a div
        
        var comm           = component.get("v.comment");
        var attachmentList = component.get("v.attachmentList");
        var rT     = component.get("v.toggleRecordType");
        var cCase = component.get("v.caseId");
        console.log('comm --> ', comm);
        $A.createComponent( whichCmp, {
                "caseId" : cCase,
                "cmt" : comm, 
                "rT" : rT, 
                "numberOfAttachment" : attachmentList.length, 
                "attachmentList" : component.get("v.attachmentListFileNames"), 
                "OrgUrl" :component.get("v.OrgLink"), 
                "Label": component.get("v.SupportType"), 
                "profileName": component.get("v.profileName"), 
                "userRole": component.get("v.userRole"),
				"defectCheckbox" : "false",
                "motivoTrasferimento" : component.get("v.selectedValue")
            },
            function(modalComponent, status, errorMessage) {
                if (status === "SUCCESS") {
                    //Appending the newly created component in div
                    var body = component.find( 'showChildModal' ).get("v.body");
                    body.push(modalComponent);
                    component.find( 'showChildModal' ).set("v.body", body);
                } else if (status === "INCOMPLETE") {
                	console.log('Server issue or client is offline.');
                } else if (status === "ERROR") {
                	console.log('error');
                }
            }
        );
	},

    
})