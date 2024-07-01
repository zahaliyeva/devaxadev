({
    doInit : function(component, event, helper) {
		var action = component.get("c.init");
        action.setParams({  caseId :  component.get("v.recordId"), accountId : component.get("v.accountId")});
        action.setCallback(this, function(response) {
        var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                storeResponse.name = component.get("v.FirstName") + ' ' +  component.get("v.LastName");
                component.set("v.wrapper", storeResponse);
            }
            else{
                var error=response.getError()[0].message;
                helper.showToast(component, event, helper, 'error', error);
                console.log('errore init: '+error);
            }
        });
        $A.enqueueAction(action);
        
    },
    
    validatePhone : function(component, event, helper){
        var validate = component.get('c.validate');
        validate.setParams({'PhoneNumber' : component.get('v.PhoneNumber')});
        var valid;
        validate.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                console.log('Response validate: ' + response.getReturnValue());
                valid = response.getReturnValue();
            }
            else{
                console.log('Errore Validation Numero di telefono');
            }
        });
        $A.enqueueAction(validate);
        return valid;
    },
    
    prepareSMS : function(component, event, helper) {
        component.set("v.isLoading", true);
        
        var saveSurvey = $A.get("e.c:saveSurveyEvent");     
        saveSurvey.fire();       
        
        var msgDatlasErr= $A.get("$Label.c.ErrorMessageDatlas");
        
        if(component.get("v.successSaveSurvey")){
        setTimeout(function() {
        if (component.get('v.PhoneNumber')!="" &&    typeof  component.get('v.PhoneNumber') != "undefined"){
        var motive = 'CDC';
        var wrapper = component.get("v.wrapper");
        wrapper.company = 'Datlas';
        component.set("v.wrapper", wrapper);
        
        console.log(wrapper);
        var URL;
        
        var OpenDatlas = component.get('c.ConnectToDatlas');
        OpenDatlas.setParams({'caseId':component.get('v.recordId')});
        OpenDatlas.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                URL = response.getReturnValue();
                if(URL){
                    var phoneNumber = component.get('v.PhoneNumber');
                    console.log('cond = contr : ' + component.get('v.ConducenteEqualscontraente'));
                        var v = component.get('c.validate');
                        v.setParams({'PhoneNumber' : phoneNumber});
                        v.setCallback(this, function(response){
                            //var regex = /^(38[03890]|34[1-90]|36[123680]|33[13-90]|32[034789]|39[01237]|37[0137]|35[01])\d{6,7}$/;
                            //var valid = regex.test(phoneNumber);
                            var valid = response.getReturnValue();
                            console.log('phone: ' + phoneNumber);
                            console.log('Valid: ' + valid);
                            if(valid){
                               var action = component.get('c.sendSms2');
                                action.setParams({ 'caseId' :  component.get("v.recordId"), 'mobileOutput' : component.get("v.wrapper"), 'motive' : motive, 'phoneNumber' : phoneNumber, 'URL' : URL.URLSMS});
                                action.setCallback(this, function(response) {
                            var state = response.getState();
                            if (state === "SUCCESS") {
                               var storeResponse = response.getReturnValue();
                            
                              if (storeResponse.status === "KO"){
                                        component.set("v.isLoading", false);                                 
                                        helper.showToast(component, event, helper, 'error', msgDatlasErr);
                                  
                             }else{
                                component.set("v.isLoading", false);
                                    helper.showToast(component, event, helper, 'success', 'SMS Inviato!');
                                    
                                }
                           
                             }else{
                                    component.set("v.isLoading", false);
                                    helper.showToast(component, event, helper, 'error', 'Attenzione! Non è stato possibile inviare il messaggio SMS!');
                            }	
                        });
                        $A.enqueueAction(action);
                        }
                        else{
                            console.log('Numero invalido!');
                              component.set("v.isLoading", false);
                              helper.showToast(component, event, helper, 'error','Errore', 'Numero invalido');
                        }
                        });
               $A.enqueueAction(v);     
        }           
        
                
            window.open(URL.URLWebAPP, '_blank');
            }
            else {
                component.set("v.isLoading", false);
                helper.showToast(component, event, helper, 'error', msgDatlasErr);
                console.log('Ko Apertura Datlas');
            }
            
        });
        $A.enqueueAction(OpenDatlas);
        
        
        //window.open('https://www.google.com','_top')
        
        }else{
        component.set("v.isLoading", false);
        helper.showToast(component, event, helper, 'error','Errore', 'Per procedere all\’invio della CAI Digitale è necessario valorizzare il numero di telefono del conducente nella schermata \“Informazioni contraente (conducente veicolo contraente)\"');
        }
        }, 2000);}
        
    },
       chiudiToast : function(component, event, helper) 
    {
        component.set("v.messageToast", "");
        component.set("v.typeToast", "");
        component.set("v.DetailsMessageToast", "");
        component.set("v.showToast",false);
    },
})