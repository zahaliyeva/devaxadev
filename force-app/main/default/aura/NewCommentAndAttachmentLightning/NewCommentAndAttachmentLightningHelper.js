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
    //deleteAttachments: function (component,event,helper,attachmentList) {
    deleteAttachments: function (component,attachmentList) {
        console.log('delete');
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
                var myEvent = $A.get("e.c:tabclosing");
                myEvent.setParams({"data":"cancel",
                                   "recordid":component.get("v.CaseId"),
                                   "Url":component.get("v.OrgLink")});
                myEvent.fire();
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
        window.location.replace(component.get("v.OrgLink") + component.get("v.CaseId"));
    },
    getPicklist: function(component, event, helper){
        var action = component.get("c.getMotivoTrasferimento");
        let caseId = component.get("v.CaseId")
        var params = {"caseId": caseId};
        action.setParams(params);
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                component.set("v.picklistValues", response.getReturnValue().options);
                console.log("Test:  ");
                console.log(response.getReturnValue().options);
            }
            else{
                console.log("Errore!!!!!");
            }
            
        });
        $A.enqueueAction(action);
    },
    checkError : function(component){
        var attributes = component.get("v.attributes") || {};
        if(attributes["CaseId"]) component.set("v.CaseId", attributes["CaseId"]);  
        
        var caseId = component.get("v.CaseId");
        //OAVERSANO 12/11/2018 : Nuovo Modello di Assistenza Biz-- START
        var buttonLabel = attributes["buttonLabel"];
        console.log('buttonLabel NCA: ',buttonLabel);
        component.set("v.buttonLabel",buttonLabel);
        //OAVERSANO 12/11/2018 : Nuovo Modello di Assistenza Biz -- END
        this.startSpinner(component);        
        var action = component.get("c.checkError");
        action.setParams({"cCase" : caseId});
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            console.log('State ===>' + state);
            if (state === "SUCCESS") {
                if (component.get("v.jsDebug")) {
                    console.log('Success state');
                    console.log('Data:' + JSON.stringify(response.getReturnValue()));
                }
                console.log('Success');
                //component.set("v.showError", response.getReturnValue());
                console.log("#### ",response.getReturnValue().show);
                component.set("v.showError", response.getReturnValue().show);
                component.set("v.Errorchecked", response.getReturnValue().message);
            }
            else if (state === "INCOMPLETE") {
                if (component.get("v.jsDebug"))
                    console.log('Incomplete state');
            }
            else if (state === "ERROR") {
                var errors = response.getError();
				console.log('Errors ===>');
				console.log(errors);
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
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if (component.get("v.jsDebug")) {
                    console.log('Success state');
                    console.log('Data:' + JSON.stringify(response.getReturnValue()));
                }
                component.set("v.showSupportHD1", response.getReturnValue());
                
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
    checkProfileHD2_RGI : function(component){
        //VIZZINI_D 25/06/2019: NMA - Lob Modulo di Calcolo - START
        var action = component.get("c.checkProfileRoleHD2_RGI");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var isHD2_RGI = response.getReturnValue();
                component.set("v.isHD2_RGI", isHD2_RGI);
            }
        });  
        $A.enqueueAction(action); 
    },
    checkProfileHD2_MDCAXA: function(component){
        //VIZZINI_D 25/06/2019: NMA - Lob Modulo di Calcolo - START
        var action = component.get("c.checkProfileRoleHD2_MDCAXA");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var isHD2_MdCAXA = response.getReturnValue();
                component.set("v.isHD2_MdCAXA", isHD2_MdCAXA);
            }
        });  
        $A.enqueueAction(action); 
        //VIZZINI_D 25/06/2019: NMA - Lob Modulo di Calcolo - END
    },
    checkProfileHD2 : function(component){
        //MOSCATELLI_M 25/10/2018: NMA Business -- START
        //var action = component.get("c.checkProfileHD2"); 
        var action = component.get("c.checkProfileHD2_lightning"); 
		//MOSCATELLI_M 25/10/2018: NMA Business -- END        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if (component.get("v.jsDebug")) {
                    console.log('Success state');
                    console.log('Data:' + JSON.stringify(response.getReturnValue()));
                }
                //MOSCATELLI_M 25/10/2018: NMA Business -- START
                if (response.getReturnValue().isHD2) 
                {
                    component.set("v.toggleRecordType", "Supporto");
                }
                console.log('isHD2:'+response.getReturnValue().isHD2BIz);
                component.set("v.isHD2BIz", response.getReturnValue().isHD2BIz);
                component.set("v.userRole", response.getReturnValue().UserRole);
                console.log("RUOLO :",component.get("v.userRole"));
                component.set("v.profileName", response.getReturnValue().UserProfile);
                //component.set("v.toggleRecordType", response.getReturnValue().DefaultRt);
                //MOSCATELLI_M 25/10/2018: NMA Business -- END
                //OAVERSANO 18/12/2018 : Enhancement NMA Biz III -- START //check whether to show or not the flag of the visibility of the file
                var isHD2BIz = component.get("v.isHD2BIz");
                var profileName = component.get("v.profileName");
                /*if(isHD2BIz || profileName == "AAI - Supporto HD2" || profileName == "AAI - Supervisor Supporto HD2")
                {
                	component.set("v.showShareFile_Flag", true);
                }*/
                //OAVERSANO 18/12/2018 : Enhancement NMA Biz III -- END
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
            this.checkVisibilitiesButtons(component);
            
            
        });  
        $A.enqueueAction(action);  
    },
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
        console.log(" ====> console: ", component);
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
            console.log('@@FIRE!!!');
            var myEvent = $A.get("e.c:tabclosing");
            myEvent.setParams({"data":"cancel",
                               "recordid":component.get("v.CaseId"),
                               "Url":component.get("v.OrgLink")});
            myEvent.fire();
        }  
    },
    closeComment : function(component,event,helper){
        console.log('@@FIRE!!!');
        var myEvent = $A.get("e.c:tabclosing");
        myEvent.setParams({"data":"cancel",
                           "recordid":component.get("v.CaseId"),
                           "Url":component.get("v.OrgLink")});
        myEvent.fire();
        //window.open(component.get("v.OrgLink") + component.get("v.caseId"), "_self");        
    },
    closeMissingInputsModal: function(component,event,helper){
        component.set("v.MandatoryInputsMissing", false);
    },
    clickCreate : function(component){
        var parentCmp           = component.get("v.parent");
        var comm           = component.get("v.comment");
        var attachmentList = component.get("v.attachmentList");
		var motivo = component.get("v.selectedValue");
        if(component.get("v.showCaringAngel")){
            if ((comm.length == 0  && motivo == "Altro")||(comm.length == 0 && motivo == "" && attachmentList.length ==0 )){
                component.set("v.error", 'Attenzione! Non è stato inserito alcun commento / allegato');
                component.set("v.MandatoryInputsMissing", true);}
            }
            
        if (comm.length == 0 && attachmentList.length == 0){
            component.set("v.error", 'Attenzione! Bisogna inserire almeno un allegato e/o inserire un nuovo commento ');
            component.set("v.MandatoryInputsMissing", true);
        } else {
            component.set("v.isOpen", false);
            component.set("v.isOpenModal", false);
            this.startSpinner(component);
            var caseId = component.get("v.CaseId");
            var rT     = component.get("v.toggleRecordType");
            console.log('@@rt: '+rT);
            var action = component.get("c.saveCommentAttachment");
            let fastPayment = component.get("v.FastPayment");
            console.log("cmt " + comm + " cCase " + caseId + " rT " + rT + " numberOfAttachment " + attachmentList.length + " attachmentList " + 
                        component.get("v.attachmentListFileNames") + " OrgUrl " + component.get("v.OrgLink"));
                        console.log('Fast Payment: ' + fastPayment);
            action.setParams({"cmt" : comm, "cCase" : caseId, "rT" : rT, "numberOfAttachment" : attachmentList.length, "attachmentList" : component.get("v.attachmentListFileNames"), "OrgUrl" :component.get("v.OrgLink"),
                              "Label": component.get("v.SupportType"), "profileName": component.get("v.profileName"),"userRole": component.get("v.userRole"),
                              "defectCheckbox" : component.get("v.defect_MdC"), "fastPayment" : fastPayment});//MOSCATELLI_M 25/10/2018: NMA Business -- added inputs
            action.setCallback(this, function(response) {
                
                var state = response.getState();
                if (state === "SUCCESS") {
                    console.log('Success state');
                    //console.log('Data:' + JSON.stringify(response.getReturnValue()));
                    var result = response.getReturnValue();
                    
                    if(result != "OK")
                    {
                    	console.log("output ==> " + result);
                        this.stopSpinner(component);
                        component.set("v.isOpen", true);
                        component.set("v.isOpenModal", true);
                        component.set("v.MandatoryInputsMissing",true);
                        component.set("v.error","Attenzione, non è stato possibile procedere con l'operazione richiesta. Riprova più tardi, se il problema persiste contattaci telefonicamente");
                    }
                    else{
                        location.reload();
                        //window.location.href =  '/lightning/r/Case/'+component.get("v.CaseId")+'/view';
                    }
                }
                else if (state === "INCOMPLETE") {
                    this.stopSpinner(component);
                    component.set("v.isOpen", true);
                    component.set("v.isOpenModal", true);
                    if (component.get("v.jsDebug")) 
                        console.log('Incomplete state');
                }
                else if (state === "ERROR") {   
                    this.stopSpinner(component);                 
                    component.set("v.isOpen", true);
                    component.set("v.isOpenModal", true);
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
        }        
    },
    getDefectMdC : function(component){
        //VIZZINI_D 27/06/2019: NMA - Lob Modulo di Calcolo - START
        var caseId = component.get("v.CaseId");
        var action = component.get("c.getDefectMdC");
        action.setParams({"idCase" : caseId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var isdefect_MdC = response.getReturnValue();
                component.set("v.defect_MdC", isdefect_MdC);
            }
        });  
        $A.enqueueAction(action); 
        //VIZZINI_D 27/06/2019: NMA - Lob Modulo di Calcolo - END
    },
    //Giorgio Bonifazi - START
    checkCaringAngel: function (component){
        var action = component.get("c.checkCaringAngel");
        action.setParams({"caseId" : component.get('v.CaseId')});        
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
    checkVisibilitiesButtons : function(component, event, helper) {
      
        var action = component.get("c.checkVisibilitiesButtonsSendSupport");
                  
        var caseId = component.get("v.CaseId");  
        var params = {caseId: caseId, userRole: component.get("v.userRole") };
        console.log("CASE ID ",component.get("v.CaseId"));
        console.log("USER ROLE ",component.get("v.userRole"));
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
                component.set("v.showButtonSend7" ,response.getReturnValue()['buttonSend7']);
                component.set("v.showButtonSend8" ,response.getReturnValue()['buttonSend8']);
            }
           
          
      
        });  
        $A.enqueueAction(action); 
        
    },
    showComponentInModal : function(component, event, helper,whichCmp) {
        //Dynamic creation of lightningModalChild component and appending its markup in a div
          
        var comm           = component.get("v.comment");
        var attachmentList = component.get("v.attachmentList");
        var rT     = component.get("v.toggleRecordType");
        var cCase = component.get("v.CaseId");
		var motive = component.get("v.selectedValue");
        //var defect = (component.get("v.defect_MdC")) ? 1 : 0;
        console.log('CASE ID ',component.get("v.CaseId"));
        console.log('comm --> ', comm);
        console.log('attachment --> ', component.get("v.attachmentListFileNames"));
        console.log('orglink --> ', component.get("v.OrgLink"));
        console.log('supportype --> ', component.get("v.SupportType"));
        console.log('profile --> ', component.get("v.profileName"));
        console.log('ruolo --> ', component.get("v.userRole"));
        console.log('defect --> ', component.get("v.defect_MdC"));
        console.log('motivo --> ', component.get("v.selectedValue"));

        /*if((comm != null && comm != undefined && comm != "")||
          	(motive==undefined || motive != 'altro')){
        	component.set("v.isOpenModal", false);
        }*/
        
		if(!((comm==null || comm==undefined || comm=="")&&
           (motive==undefined || motive==null  || motive==='Altro'|| motive==''))){
        component.set("v.isOpenModal", false);
        }
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
				"defect_MdC" : component.get("v.defect_MdC"),
                "motivoTrasferimento" : component.get("v.selectedValue"),
                "visibilities": component.get("v.visibilities")
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
                    console.log(errorMessage);
                }
            }
        );
        
	},
	   showToastStandard : function(component, event, helper,title,type, msg) {
        var toastEvent = $A.get("e.force:showToast");
      		if(typeof toastEvent != "undefined"){
        toastEvent.setParams({
            "type": type,
            "title": title,
            "message": msg
        });
        toastEvent.fire();
           }
           else{
               	component.set("v.messageToast", msg);
        		//component.set("v.DetailsMessageToast", msg)
        		component.set("v.typeToast", type);
        		component.set("v.showToast",true);
           }
    }
})