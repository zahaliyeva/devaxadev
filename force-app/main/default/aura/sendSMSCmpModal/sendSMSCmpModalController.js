(
    {	
        doInit : function(component, event, helper) {
         var action = component.get("c.init");
         let caseId = component.get("v.pageReference").state.c__recordId;
         let accountId = component.get("v.pageReference").state.c__accountId;
         component.set("v.recordId", caseId);
         component.set("v.accountId", accountId);
         console.log('Record Id', component.get("v.recordId"));
         console.log('Account Id', component.get("v.accountId"));
         action.setParams({  caseId :  component.get("v.recordId"), accountId : component.get("v.accountId")});
         action.setCallback(this, function(response) {
         var state = response.getState();
             if (state === "SUCCESS") {
                 var storeResponse = response.getReturnValue();
                 component.set("v.wrapper", storeResponse);
             }
         });
         $A.enqueueAction(action);
         
     },
     
     openModel: function(component, event, helper) {
       // for Display Model,set the "isOpen" attribute to "true"
       //component.set("v.isVisibleStep5",false);
       component.set("v.isActive", true);
    },
    CloseModal: function(component, event, helper) {
       component.set("v.isActive", false);      
       helper.getFocusedTabInfo(component).then(function (result){
            helper.closeTab(component, result.tabId);
       })
    },
        
  
         
    likenClose: function(component, event, helper) {
         var motive = component.find("motive").get("v.value");
        //var phoneNumber = component.find("phoneNumber").get("v.value");
        var phoneNumber = component.get("v.phoneNumber");
        var action = component.get("c.sendSms");
        var isQuestionario = component.get("v.isQuestionario");
        
        var commentForm = component.find('phoneNumber'), valid;
        commentForm.showHelpMessageIfInvalid();
        valid = commentForm.get("v.validity").valid;
       
        
        if(valid){
         action.setParams({  'mobileOutput' : component.get("v.wrapper"), 'motive' : motive, 'phoneNumber' : phoneNumber});
         action.setCallback(this, function(response) {
             var state = response.getState();
             if (state === "SUCCESS") {
                 var storeResponse = response.getReturnValue();
                 console.log(JSON.stringify(storeResponse));
                 if (storeResponse.status === "KO"){
                     if (isQuestionario == false){
                         helper.showStandardToast('error', 'Errore!', 'Attenzione ! Si è verificato un errore. Si prega di riprovare più tardi.');
                      }else{
                         helper.showToast(component, event, helper, 'error', 'Attenzione ! Si è verificato un errore. Si prega di riprovare più tardi.');
                      }
                 }else{
                     if (isQuestionario == false){
                         helper.showStandardToast('success', 'SMS Inviato!', 'SMS Inviato!');
                      }else{
                         helper.showToast(component, event, helper, 'success', 'SMS Inviato!');
                      }
                      //component.set("v.isActive", false);
                    //  component.set("v.isVisualforce", false);  
                    component.set("v.isActive", false);      
                    if (component.get("v.isVisualforce") == true) {
                         sforce.console.getEnclosingTabId(
                          $A.getCallback(function(result) {
                             sforce.console.closeTab(result.id);
                           }));
                       }
 
                 }
                
             }else{
                 if (isQuestionario == false){
                         helper.showStandardToast('error', 'Errore!', 'Attenzione ! Si è verificato un errore. Si prega di riprovare più tardi.');
                      }else{
                         helper.showToast(component, event, helper, 'error', 'Attenzione ! Si è verificato un errore. Si prega di riprovare più tardi.');
                      }
             }
         });
         $A.enqueueAction(action);
        /*
         var num = document.getElementsByClassName("numero")[0].value;      	
            
            if(num[0]==='+' || num.substring(0,2) === "00" ){
                alert("I suffissi '+' e '00' non sono supportati!");
            }
            else if (num.length > 10){
                alert("Numero non supportarto, riprova!");
            }
            else{
             //component.set("v.questionarioCA.Telefono_conducente__c","39"+num);
               component.set("v.isActive", false);     
           }
         */
        }
       
    },
        
        chiudiToast : function(component, event, helper) 
     {
         component.set("v.messageToast", "");
         component.set("v.typeToast", "");
         component.set("v.showToast",false);
     },
        
       
    
     
 })