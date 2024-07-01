({
  //MOSCATELLI_M 31/07/2017: Data Enrichment--START

  //MOSCATELLI_M 29/11/2017: Data enrichment SmartCenter Fase 1 -- START
   updateAccount: function(component, account) {
  
    var SkipVerificheForSC = false;
    let telephoneWithPrefix = component.get("v.telephoneWithPrefix");

    console.log('Account To Save: ' + JSON.stringify(account));
    console.log('Telephone To Save:'+ JSON.stringify(telephoneWithPrefix, null, 4));

    console.log('@Advisor?: '+component.get("v.UserIsAdvisor"));

    if(component.get("v.UserIsAdvisor"))
    {
      SkipVerificheForSC = this.SkipChecks(component);     
    }
    if (component.get("v.jsDebug")) console.log("UPDATING");
    var isPerson_Account = component.get("v.currentAccount.IsPersonAccount");  
    if (component.get("v.jsDebug")) console.log("isPerson_Account" + isPerson_Account );  
    console.log('DENTRO METODO UPDATE'); 

    var Validation = false; 
    var ValidationConsensi = false;

  //MOSCATELLI_M 18/01/2018: Data enrichment SmartCenter Fase 1 --START
  if(!SkipVerificheForSC)
  { 
    console.log('validations');
    ValidationConsensi = this.validateConsensi(component);
    if(isPerson_Account == true ) {
      if (component.get("v.jsDebug")) console.log("ACCOUNT B2C");        
        Validation = this.validate_B2C(component);
      } else {
        Validation = this.validate_B2B(component);
    }
    if (component.get("v.jsDebug")) console.log("Validation= " + Validation );
  }
  

    if( ( Validation && ValidationConsensi )  || SkipVerificheForSC)   
    {
    //MOSCATELLI_M 18/01/2018: Data enrichment SmartCenter Fase 1 -- END

    component.set("v.ValidazioniOK",true);
    console.log('validazioni ok');

    this.concatenateTelephoneValues(component);

    console.log('account after concatenation: ' + JSON.stringify(component.get("v.currentAccount")));

    this.startSpinner(component); 
    var isPerson_Account = component.get("v.currentAccount.IsPersonAccount");  
    var action = component.get("c.updateAccount");


    action.setParams({
        "accountToSave": component.get("v.currentAccount"),
        "telephoneWithPrefixJson" : JSON.stringify(telephoneWithPrefix),
        "AvoidEnrich" : component.get("v.AvoidEnrichmentCheck"),
        "Phonecallid" : component.get("v.PhoneCallId"),
        "MPSEnrichment" : component.get("v.MPSEnrichment"),
        "CaseId" : component.get("v.CaseId")
    });

    action.setCallback(this, function(response){
        console.log('dentro setCallback');
        console.log(response);
        console.log('response***'+JSON.stringify(response.getReturnValue(), null, 4));
        var state = response.getState();
        console.log('STATE'+state);
        console.log('Error'+JSON.stringify(response.getError()));
        
        var OpenTask = component.get("v.OpenTask");
        console.log('OpenTask'+OpenTask);
        if (component.get("v.jsDebug")) console.log("response"+response); 
        if (component.get("v.jsDebug")) console.log("response.state"+state); 
        //if (component.get("v.jsDebug")) console.log("response.isSuccess:"+isSuccess);       
        if (component.isValid() && state === "SUCCESS" && response.getReturnValue().isSuccess) {
          
          
           if (component.get("v.jsDebug")) console.log("before redirect");
           if (component.get("v.jsDebug")) console.log("updated account success: "+JSON.stringify(response.getReturnValue(), null, 4));
           console.log("****updated account success: "+JSON.stringify(response.getReturnValue(), null, 4));
           var esitoElaborazione = response.getReturnValue().values.esitoElaborazione;
           component.set("v.esitoElaborazione",esitoElaborazione);
           var esitoChiamataDAC = response.getReturnValue().values.esitoChiamataDAC;
           console.log('esitoChiamataDAC'+esitoChiamataDAC);
           var EsitoDAC = [];
           if(esitoChiamataDAC!= undefined){
           EsitoDAC = esitoChiamataDAC.split(' - ');
           console.log('EsitoDAC'+EsitoDAC);
           
           console.log("****esitochiamataDAC: "+JSON.stringify(response.getReturnValue().values.esitoChiamataDAC, null, 4));
         }
           //MOSCATELLI_M 31/07/2017: Data Enrichment--START

           
           if(response.getReturnValue().isSuccess == true){
           var EnrichmentMsg = response.getReturnValue().values.ModalMsg;


            if(response.getReturnValue().values.List != null && response.getReturnValue().values.List != ''){
              //console.log('#######LIST: '+response.getReturnValue().values.List);
              component.set("v.ListString",response.getReturnValue().values.List);
              component.set("v.ListPopulated",true);
      
               this.splitData(component);
            }else{
              component.set("v.ListString",response.getReturnValue().values.List);
              component.set("v.ListPopulated",false);
            }

            //MOSCATELLI_M 29/09/2017: Data Enrichment Enhancement--START
            console.log('#######: '+response.getReturnValue().values.RelevantField);
           
           if(response.getReturnValue().values.RelevantField != null && response.getReturnValue().values.RelevantField != ''){
               component.set("v.ListRELPopulated",true);
               component.set("v.ListStringREL",response.getReturnValue().values.RelevantField);
               this.splitData(component);
            }
            else{
              component.set("v.ListStringREL",response.getReturnValue().values.List);
              component.set("v.ListRELPopulated",false);
            }
            //this.splitData(component);
            //MOSCATELLI_M 29/09/2017: Data Enrichment Enhancement--END  

           if(EnrichmentMsg!='' && EnrichmentMsg!=null)
           {

            

             component.set("v.EnrichmentMsg",EnrichmentMsg);
             component.set("v.EnrichError",true);
             this.stopSpinner(component);
          
           

           }
           else
           {
            component.set("v.EnrichError",false); 
           }
         }else{

            component.set("v.EnrichError",false); 

         }
          

           //MOSCATELLI_M 31/07/2017: Data Enrichment--END


          if (typeof esitoChiamataDAC != 'undefined' && esitoChiamataDAC != null && esitoChiamataDAC != ""){
           var esitoChiamata = EsitoDAC[0];
           var dettaglio = EsitoDAC[1];
           //debugger;
           console.log('dettaglio'+dettaglio);
           console.log('esitoChiamata'+esitoChiamata);
          
          }
           
           // expenses.push(response.getReturnValue());
           // component.set("v.currentAccount", accountUpdated);*/
        } else if (state == "ERROR" || (state === "SUCCESS" && !response.getReturnValue().isSuccess)) {
                this.stopSpinner(component);
                var errors = response.getError();
              if (component.get("v.jsDebug")) console.log("errors "+errors);
              if ( (state === "SUCCESS" && !response.getReturnValue().isSuccess) ) {
                    // Did catch on the Server Side
                    //component.set("v.message", response.getReturnValue().message);
                    if (component.get("v.jsDebug")) console.log("Apex Failure");
                    component.set("v.ValidazioniOK",false);
                    this.throwErrorCatched (component,response.getReturnValue().message);
                    if (component.get("v.jsDebug")) console.log("returnedObj "+JSON.stringify(response.getReturnValue(), null, 4));
                    if (response.getReturnValue().values.RollbackedAccount!= null)
                    {
                      component.set("v.currentAccount", response.getReturnValue().values.RollbackedAccount);
                      this.sendAccount (component);
                    }
                }
            }
            this.stopSpinner(component);
      });
      console.log('before calling update');
      $A.enqueueAction(action);

    } else{
      component.set("v.ValidazioniOK",false);
    }
},

concatenateTelephoneValues : function(component) {
  let telephoneWithPrefix = component.get("v.telephoneWithPrefix");
  let currentAccount = component.get("v.currentAccount");
  console.log('###telephoneWithPrefix: ' + JSON.stringify(telephoneWithPrefix))
  for (const telephoneField in telephoneWithPrefix) {
    
    currentAccount[telephoneField] = telephoneWithPrefix[telephoneField].prefix + telephoneWithPrefix[telephoneField].telephoneNumber
  }
  component.set("v.currentAccount", currentAccount);
},
  
  redirectpage : function (component){
  if (component.get("v.jsDebug")) console.log("inside redirect");
    var pathName = window.location.pathname;
    var agencyIndex = pathName.indexOf("agenzie");
    var account = component.get("v.currentAccount");
    var id = account.Id;
    var myURL = "https://"+window.location.hostname;
    if (agencyIndex!= -1)
    {
      myURL = myURL+"/agenzie";
    }
    myURL = myURL+"/"+id;
    if (component.get("v.jsDebug")) console.log("********"+myURL);
    window.location.href = myURL;
   // window.location.href = myURL;
/*
    var sObjectEvent = $A.get("e.force:navigateToSObject");
    sObjectEvent.setParams({
        "recordId": component.get("v.currentAccount.Id"),
        "slideDevName": 'related'
    })
    sObjectEvent.fire();*/

 },   

redirectToRelationship : function (component){
  if (component.get("v.jsDebug")) console.log("inside redirect");
    var pathName = window.location.pathname;
    var agencyIndex = pathName.indexOf("agenzie");
    var account = component.get("v.currentAccount");
    var id = account.Id;
    var lead = component.get("v.currentLead");
    var id2 = lead.Account_referente__c;
    var myURL = "https://"+window.location.hostname;
    if (agencyIndex!= -1)
    {
      myURL = myURL+"/agenzie";
    }
    var endURL = "apex/gestionenucleo?id1=" + id + "&id2=" + id2;
    myURL = myURL+"/"+endURL;
    if (component.get("v.jsDebug")) console.log("********"+myURL);
    window.location.href = myURL;
 },  
  
  throwErrorCatched: function(component,errorsHandled) {
      if (component.get("v.jsDebug")) console.log("Apex Failure Handled"+errorsHandled);
      console.log("Apex Failure Handled"+errorsHandled);

     if (errorsHandled!="") {
          $A.createComponents([
              ["ui:message",{
                  "title" : "Errore",
                  "severity" : "error",
                  "aura:id" : "errorPopup"
              }],
              ["ui:outputText",{
                  "value" : errorsHandled
              }]
              ],
              function(components) {
                  var message = components[0];
                  var outputText = components[1];
                  // set the body of the ui:message to be the ui:outputText
                  message.set("v.body", outputText);
                  component.set("v.messages", message);  
               /*   setTimeout(function() {
                  $A.run(function() {
                      component.set("v.messages", []);                                       
                  });
              }, 10000)*/
              } )   
          } else {
          // $A.error("Unknown error");
          }
         },
           startSpinner: function (cmp) {
           var spinner = cmp.find("mySpinner");
       $A.util.removeClass(spinner, 'slds-hide');
           },
           stopSpinner: function (cmp) {
           var spinner = cmp.find("mySpinner");
           $A.util.addClass(spinner, 'slds-hide');
           }, 
 

     
  
  sendAccount: function(component) {
      var accountRetrieved = component.get("v.currentAccount");
     // var retrievalEvent = component.getEvent("accountFound");
      var retrievalEvent = $A.get("e.c:AccountEvent");
      retrievalEvent.setParams({ "containedAccount": accountRetrieved });
      console.log ("event ready to be sent"+retrievalEvent);
      retrievalEvent.fire();
  },  


  validateMail : function(component, regEx, email) {  
      console.log("*** validateMail email: " + email);
      var reg_ex = component.get("v.regEx");
      console.log("*** validateMail - reg_ex[" + regEx + "]: " + reg_ex[regEx]);	
      var emailFilter = new RegExp(reg_ex[regEx]);
      if (typeof  email == "undefined" || email == "") {
          return true;
      }else{  
          return emailFilter.test(email);
      } 
  },

  validatePhone : function(component, regEx, phone_number) { 
      console.log("*** validatePhone phone_number: " + phone_number);
      var reg_ex = component.get("v.regEx");
      console.log("*** validatePhone - reg_ex[" + regEx + "]: " + reg_ex[regEx]);	
      var phoneFilter = new RegExp(reg_ex[regEx]);
      if (typeof  phone_number == "undefined" || phone_number == "" || phone_number == null) {
          return true;
      } else {  
          return phoneFilter.test(phone_number);
      }
  },

validatePrefix : function(component, regEx, prefix_number) {
      console.log("*** validatePrefix prefix_number: " + prefix_number);
       var reg_ex = component.get("v.regEx");
      console.log("*** validatePrefix - reg_ex[" + regEx + "]: " + reg_ex[regEx]);	
      var prefixFilter = new RegExp(reg_ex[regEx]);
      if (typeof  prefix_number == "undefined" || prefix_number == "") {
          return true;
      } else {  
          return prefixFilter.test(prefix_number);
      } 
  },
  
  isEmpty : function(str) {
    return (!str || 0 === str.length);
},

validateConsensi : function(component, oldAccountInfo){

  //MOSCATELLI_M 29/09/2017: Data Enrichment Enhancement -- START
  var errorFound_privacy  =  false
  var errorFound_privacy2 =  false
  var errorFound_privacy7 =  false
  //MOSCATELLI_M 29/09/2017: Data Enrichment Enhancement -- END

  var currentAccount = component.get("v.currentAccount");
  var infoMap = component.get("v.oldAccountInfo");
  var OpenTask = component.get("v.OpenTask");
  var isSuccess = component.get("v.isSuccess");
  var oldPrivacy_1 = component.get("v.isPrivacy1populated");
  var UserIsAdvisor = component.get("v.UserIsAdvisor");
  var isDAOLAgency = component.get("v.isDAOLAgency");
  console.log('OLD PRIVACY 1'+oldPrivacy_1);
   
  console.log('oldAccount'+ JSON.stringify(infoMap, null, 4));
  console.log('Account'+ JSON.stringify(currentAccount, null, 4));



  //var oldPrivacy_1 = infoMap["v.currentAccount.CIF_Privacy_1__c"];
  var oldPrivacy_2 = infoMap["v.currentAccount.CIF_Privacy_2__c"];
  var oldPrivacy_3 = infoMap["v.currentAccount.CIF_Privacy_3__c"];
  var oldPrivacy_4 = infoMap["v.currentAccount.CIF_Privacy_4__c"];
  var oldEmail = infoMap["v.currentAccount.CIF_Privacy_5__c"];
  var oldFirma = infoMap["v.currentAccount.CIF_Privacy_7__c"];
  var oldContact = infoMap["v.currentAccount.CIF_Mail_contact__c"];
  var oldNum = infoMap["v.currentAccount.CIF_Number__c"];
  var oldExp = infoMap["v.currentAccount.CIF_Expiry_date__c"];
  var oldOTP = infoMap["v.currentAccount.CIF_Privacy_8__c"];
  var oldOTPContact = infoMap["v.currentAccount.CIF_OTP_Phone_contact__c"];

  var check_oldPrivacy_2 = this.checkConsensi(oldPrivacy_2);
  var check_oldPrivacy_3 = this.checkConsensi(oldPrivacy_3);
  var check_oldPrivacy_4 = this.checkConsensi(oldPrivacy_4);
  var check_oldEmail= this.checkConsensi(oldEmail);
  var check_oldFirma = this.checkConsensi(oldFirma);
  var check_oldContact = this.checkConsensi(oldContact);
  var check_oldOTP = this.checkConsensi(oldOTP);
  var check_oldOTPContact = this.checkConsensi(oldOTPContact);



  //console.log('Commerciali '+oldCommerciale1+' '+oldCommerciale2+' '+oldCommerciale3);

  var Privacy_1 = component.get("v.currentAccount.CIF_Privacy_1__c");
  var Privacy_2 = component.get("v.currentAccount.CIF_Privacy_2__c");
  var Privacy_3 = component.get("v.currentAccount.CIF_Privacy_3__c");
  var Privacy_4 = component.get("v.currentAccount.CIF_Privacy_4__c");
  var Privacy_5 = component.get("v.currentAccount.CIF_Privacy_5__c");
  var Privacy_7 = component.get("v.currentAccount.CIF_Privacy_7__c"); 
  var Contact_mail = component.get("v.currentAccount.CIF_Mail_contact__c");
  var Numero = component.get("v.currentAccount.CIF_Number__c");
  var Scadenza = component.get("v.currentAccount.CIF_Expiry_date__c");
  var Privacy_8 = component.get("v.currentAccount.CIF_Privacy_8__c");
  var Contact_OTP = component.get("v.currentAccount.CIF_OTP_Phone_contact__c");
  //console.log('mail contact'+Contact_mail);
 

  
  var check_Privacy1 = this.checkConsensi(Privacy_1);
  var check_Privacy2 = this.checkConsensi(Privacy_2);
  var check_Privacy3 = this.checkConsensi(Privacy_3);
  var check_Privacy4 = this.checkConsensi(Privacy_4);
  var check_Privacy5 = this.checkConsensi(Privacy_5);
  var check_Privacy7 = this.checkConsensi(Privacy_7);
  var check_Contact_mail = this.checkConsensi(Contact_mail);
  var check_Numero = this.checkConsensi(Numero);
  var check_Scadenza = this.checkConsensi(Scadenza);
  var check_Privacy8 = this.checkConsensi(Privacy_8);
  var check_Contact_OTP = this.checkConsensi(Contact_OTP);

  var errormessage_Privacy = 'Impossibile procedere al salvataggio: compilare tutti i consensi per completare l\'operazione ';  //Attenzione compilare tutti i consensi!
  var errormessage_Privacy2 = 'Attenzione selezionare il contatto email per l\'invio della documentazione in formato digitale!';
  var errormessage_Privacy7 = 'Attenzione, indicare un contatto cellulare valido per l\'utilizzo del servizio OTP';

    
if ((  oldPrivacy_1 != check_Privacy1             ||
       oldPrivacy_2 != Privacy_2                  ||
       oldPrivacy_3 != Privacy_3                  ||
       oldPrivacy_4 != Privacy_4                  ||
       oldEmail != Privacy_5                      ||
       oldFirma != Privacy_7                      ||
       check_oldContact != check_Contact_mail     ||
       oldOTP != Privacy_8                        ||
       check_oldOTPContact != check_Contact_OTP) && OpenTask ==false && isSuccess==true){


      if(Privacy_7 == 'SÃ¬' && oldExp != Scadenza && oldNum != Numero && (check_Privacy8 == false && !UserIsAdvisor && isDAOLAgency)){

        errorFound_privacy = true;
      }
    //debugger;

     if (check_oldPrivacy_2 == true && 
         check_oldPrivacy_3 == true && 
         check_oldPrivacy_4 == true && 
         check_oldEmail == false && 
         check_oldFirma == false && 
         check_oldOTP == false){ //soggettoPREDAC
         
         console.log('dentro');

         if (check_Privacy5 == false && 
             check_Privacy7 == false && 
             (check_Privacy8 == false && !UserIsAdvisor && isDAOLAgency)){

                 errorFound_privacy = true;
          
         }else if (check_Privacy5 == true && (check_Privacy7 == false || (check_Privacy8 == false && !UserIsAdvisor && isDAOLAgency))){

             if (Privacy_5 == 'SÃ¬'){ 

                   if(check_Contact_mail == false){

                          errorFound_privacy2 = true;
                   }
             }



            if ((check_Privacy7 == false) || (check_Privacy8 == false && !UserIsAdvisor && isDAOLAgency))
                    errorFound_privacy = true;
           
         }
         
         else if (check_Privacy5 == true && (check_Privacy7 == true && check_Privacy8 == true)){
           if (Privacy_5 == 'SÃ¬' && check_Contact_mail == false){
             errorFound_privacy2 = true;
           }
          
           if (Privacy_8 == 'SÃ¬' && check_Contact_OTP == false){
             errorFound_privacy7 = true;

           }
           

         }
         else if ((check_Privacy5 == false && (check_Privacy7 == true || check_Privacy8 == true))){
          console.log('check 1');
           errorFound_privacy = true;
         } 
       }else if ((check_Privacy1 == false || 
                  check_Privacy2 == false || 
                  check_Privacy3 == false || 
                  check_Privacy4 == false || 
                  check_Privacy5 == false || 
                  check_Privacy7 == false || 
                  (check_Privacy8 == false && !UserIsAdvisor && isDAOLAgency))) {//Soggetto NoDAC/DAC 

        console.log('check 2');

             errorFound_privacy = true;
         } 

       if (Privacy_5 == 'SÃ¬' && check_Contact_mail == false){
         
         errorFound_privacy2 = true;
       }

       if (Privacy_8 == 'SÃ¬'){
         if(check_Contact_OTP == false){

           errorFound_privacy7 = true;
         } 

       }
       

           if(errorFound_privacy  == true)
           {
             errormessage_Privacy = errormessage_Privacy ;
             this.throwErrorCatched (component,errormessage_Privacy);       
            return false;
           }

           if(errorFound_privacy2  == true)
           {
             errormessage_Privacy2 = errormessage_Privacy2 ;
             this.throwErrorCatched (component,errormessage_Privacy2);       
            return false;
           }

           if(errorFound_privacy7  == true)
           {
             errormessage_Privacy7 = errormessage_Privacy7 ;
             this.throwErrorCatched (component,errormessage_Privacy7);       
            return false;
           }

        

}

return true;

},
  
  getListOfRegularExpressions : function(component) {
      console.log('*** getListOfRegularExpressions');
      var action = component.get("c.getListOfRegularExpressions");
      action.setCallback(this, function(response) {
          var state = response.getState();
          console.log('*** getListOfRegularExpressions - state: ' + state);
          if (state === "SUCCESS") {
              var response = response.getReturnValue();
              console.log("*** getListOfRegularExpressions - From server: " + JSON.stringify(response));    
              var validations = {};
              for (var i = 0; i < response.length; i++) {
        validations[response[i].QualifiedApiName] = response[i].RegEx__c;
              }
              component.set("v.regEx", validations);
          }
          else if (state === "ERROR") {
              var errors = response.getError();
              if (errors) {
                  if (errors[0] && errors[0].message) {
                      console.log("*** getListOfRegularExpressions - Error message: " + errors[0].message);
                      var validations = {};
                      component.set("v.regEx", validations);
                  }
              } else {
                  console.log("getListOfRegularExpressions - Unknown error");
                  var validations = {};
                  component.set("v.regEx", validations);
              }
          }
      });
      $A.enqueueAction(action);
  },
  //ANASTASI_S 19072019: Email and Phone Validation -----END
  
  checkConsensi : function(consenso){
        
        if (typeof  consenso == "undefined" || consenso == "" || consenso == null || consenso == false){
        return false;
        }else{  
            return true;
        }
  }, 

              
  validate_B2B : function(component) {
    let telephoneWithPrefix = component.get("v.telephoneWithPrefix");
    
    var person_email = component.get("v.currentAccount.CIF_Personalemail__c");
    var work_email = component.get("v.currentAccount.CIF_Work_email__c");

    var phone = telephoneWithPrefix.CIF_Phone__c ? telephoneWithPrefix.CIF_Phone__c.telephoneNumber : '';
    var mobile_phone = telephoneWithPrefix.CIF_MobilePhone__c ? telephoneWithPrefix.CIF_MobilePhone__c.telephoneNumber : '';
    var work_phone = telephoneWithPrefix.CIF_Work_phone__c ? telephoneWithPrefix.CIF_Work_phone__c.telephoneNumber : '';
    var fax = telephoneWithPrefix.Fax ? telephoneWithPrefix.Fax.telephoneNumber : '';
    
    var phone_intprefix = telephoneWithPrefix.CIF_Phone__c ? telephoneWithPrefix.CIF_Phone__c.prefix : '';
    var mobile_phone_intprefix = telephoneWithPrefix.CIF_MobilePhone__c ? telephoneWithPrefix.CIF_MobilePhone__c.prefix : '';
    var work_phone_intprefix = telephoneWithPrefix.CIF_Work_phone__c ? telephoneWithPrefix.CIF_Work_phone__c.prefix : '';
    var fax_intprefix = telephoneWithPrefix.Fax ? telephoneWithPrefix.Fax.prefix : '';

    var OppTelPrinc = component.get("v.currentAccount.Flag_Opposizione_Tel_Princ__c");
    var OppTelCell = component.get("v.currentAccount.Flag_Opposizione_Tel_Cell_B2B__c");
    var OppFax = component.get("v.currentAccount.Flag_Opposizione_Fax__c");
    var OppTelUff = component.get("v.currentAccount.Flag_Opposizione_Tel_Uff__c")
    var OppEmailPers = component.get("v.currentAccount.Flag_Opposizione_Email_Pers_B2B__c");
    var OppEmailUff = component.get("v.currentAccount.Flag_Opposizione_Email_Uff__c");

    var MotivoOppTelPrinc = component.get("v.currentAccount.Motivo_opposizione_Tel_Princ__c");
    var MotivoOppTelCell = component.get("v.currentAccount.Motivo_opposizione_Tel_Cell_B2B__c");
    var MotivoOppFax = component.get("v.currentAccount.Motivo_opposizione_Fax__c");
    var MotivoOppTelUff = component.get("v.currentAccount.Motivo_opposizione_Tel_Uff__c")
    var MotivoOppEmailPers = component.get("v.currentAccount.Motivo_opposizione_Email_Pers_B2B__c");
    var MotivoOppEmailUff = component.get("v.currentAccount.Motivo_opposizione_Email_Uff__c");

    var check_TelPrinc = this.validateOpp(OppTelPrinc, MotivoOppTelPrinc);
    var check_TelCell = this.validateOpp(OppTelCell, MotivoOppTelCell);
    var check_TFax = this.validateOpp(OppFax, MotivoOppFax);
    var check_TelUff = this.validateOpp(OppTelUff, MotivoOppTelUff);
    var check_Email = this.validateOpp(OppEmailPers, MotivoOppEmailPers);
    var check_EmailUff = this.validateOpp(OppEmailUff, MotivoOppEmailUff);


    var check_person_email= this.validateMail(component, 'Email_RegEx', person_email);
    console.log('*** validate_B2B - check_person_email: ' + check_person_email);
    var check_work_email= this.validateMail(component, 'Email_RegEx', work_email);
    console.log('*** validate_B2B - check_work_email: ' + check_work_email);
    var check_phone = this.validatePhone(component, 'Generic_Phone_RegEx', phone);
    console.log('*** validate_B2B - check_phone: ' + check_phone);  
    var check_mobile_phone = false; 
    if ( this.isEmpty(mobile_phone_intprefix) || (!this.isEmpty(mobile_phone_intprefix)  &&  (mobile_phone_intprefix === '+39' || mobile_phone_intprefix === '0039')) ) {
   check_mobile_phone = this.validatePhone(component, 'National_Mobile_Phone_RegEx', mobile_phone);      
       console.log('*** validate_B2B - check_mobile_phone 1: ' + check_mobile_phone);
    } else {
   check_mobile_phone = this.validatePhone(component, 'Generic_Phone_RegEx', mobile_phone);  
       console.log('*** validate_B2B - check_mobile_phone 2: ' + check_mobile_phone); 
    }
    var check_fax = this.validatePhone(component, 'Generic_Phone_RegEx', fax);
    console.log('*** validate_B2B - check_fax: ' + check_fax);
    var check_work_phone = this.validatePhone(component, 'Generic_Phone_RegEx', work_phone); 
    console.log('*** validate_B2B - check_work_phone: ' + check_work_phone);
    var check_phone_intprefix = this.validatePrefix(component, 'Generic_Country_Code_RegEx', phone_intprefix);
    console.log('*** validate_B2B - check_phone_intprefix: ' + check_phone_intprefix);  
    var check_mobile_phone_intprefix = this.validatePrefix(component, 'Generic_Country_Code_RegEx', mobile_phone_intprefix);
    console.log('*** validate_B2B - check_mobile_phone_intprefix: ' + check_mobile_phone_intprefix);   
    var check_fax_intprefix = this.validatePrefix(component, 'Generic_Country_Code_RegEx', fax_intprefix);
    console.log('*** validate_B2B - check_fax_intprefix: ' + check_fax_intprefix);   
    var check_work_intprefix = this.validatePrefix(component, 'Generic_Country_Code_RegEx', work_phone_intprefix); 
    console.log('*** validate_B2B - check_work_intprefix: ' + check_work_intprefix);   
    //ANASTASI_S 19072019: Email and Phone Validation -----END
    
    var errorprefix_Found= false;
    var erroremail_Found= false;     
    var errorphone_Found= false;
    var errorFound = false;
    var errorFound1 = false;
    var errorFoundprefix = false;
    var errorMotivoOpp = false;
    var error1 = "Impossibile procedere al salvataggio di un campo di tipo prefisso senza compilare il corrispondente campo di tipo numero telefonico. Per procedere compilare i seguenti campi:";
    var error = "Impossibile procedere al salvataggio dei seguenti dati: ";
    var errormessage_email = "Nei campi di tipo Email sono ammessi i seguenti valori: \n - per lo username lettere, numeri e i caratteri speciali _.&\-+ ;  \n - per il dominio solo lettere";      
    var errormessage_phone = "Nei campi di tipo numero di telefono sono ammessi unicamente valori numerici"; 
    var errormessage_prefix = "Nei campi di tipo prefisso è possibile inserire il carattere speciale + ed espressioni numeriche di lunghezza massima pari a quattro cifre";
    var error_MotivoOpp = "Selezionare il Motivo Opposizione per i seguenti dati: "
    
      
    if(check_person_email == false){
     error = error + " -Email";
     erroremail_Found = true;
     errorFound = true;  
    }
    if(check_work_email == false){
     error = error + " -Email ufficio"; 
     erroremail_Found = true;
     errorFound = true; 
    }
     if(check_phone == false){
     error = error + " -Telefono principale";
     errorphone_Found = true;
     errorFound = true;   
    } 
    if(check_mobile_phone == false){
     error = error + " -Telefono cellulare";
     errorphone_Found = true;
     errorFound = true;     
    } 
    if(check_fax == false){
     error = error + " -Fax";
     errorphone_Found = true;
     errorFound = true;   
    }   
    if(check_work_phone == false){
      error = error + " -Telefono ufficio"; 
      errorphone_Found = true;
      errorFound = true;    
    }  
    if(check_phone_intprefix == false){
     error = error + " -Prefisso internazionale del telefono principale";  
     errorFound = true;
     var errorprefix_Found= true;
    } 
    if(check_mobile_phone_intprefix == false){
     error = error + " -Prefisso internazionale del telefono cellulare";
     errorFound = true;
     var errorprefix_Found= true;
    } 
    if(check_fax_intprefix == false){
     error = error + " -Prefisso internazionale del fax";  
     errorFound = true;
     var errorprefix_Found= true;
    }   
    if(check_work_intprefix == false){
      error = error + " -Prefisso internazionale del telefono ufficio"; 
      errorFound = true;
      var errorprefix_Found= true;
    }
    if((phone_intprefix != "" && typeof phone_intprefix != "undefined") &&  (phone == "" || typeof phone == "undefined")){
      error1 = error1 + " -Telefono principale";
      errorFound1 = true;
    }
    if((work_phone_intprefix != "" && typeof work_phone_intprefix != "undefined") &&  (work_phone == "" || typeof work_phone == "undefined")){
      error1 = error1 + " -Telefono ufficio";
      errorFound1 = true;
    }
    if((mobile_phone_intprefix != "" && typeof mobile_phone_intprefix != "undefined") &&  (mobile_phone == "" || typeof mobile_phone == "undefined")){
      error1 = error1 + " -Telefono cellulare";
      errorFound1 = true; 
    }
    if((fax_intprefix != "" && typeof fax_intprefix != "undefined") &&  (fax == "" || typeof fax == "undefined")){
      error1 = error1 + " -Fax";
      errorFound1 = true;
    }

    if(check_TelPrinc == false){
     error_MotivoOpp = error_MotivoOpp + " -Telefono principale";
     errorMotivoOpp = true;
    } 
    if(check_TelCell == false){
     error_MotivoOpp = error_MotivoOpp + " -Telefono cellulare";
     errorMotivoOpp = true; 
    }
    if(check_TFax == false){
     error_MotivoOpp = error_MotivoOpp + " -Fax";
     errorMotivoOpp = true; 
    }
    if(check_TelUff == false){
     error_MotivoOpp = error_MotivoOpp + " -Telefono ufficio";
     errorMotivoOpp = true;   
    }
    if(check_Email == false){
     error_MotivoOpp = error_MotivoOpp + " -Email";
     errorMotivoOpp = true; 
    }
    if(check_EmailUff == false){
     error_MotivoOpp = error_MotivoOpp + " -Email ufficio";
     errorMotivoOpp = true; 
    }



    
       if(errorFound1 == true && errorFound == true  ){
       if(errorphone_Found == true && erroremail_Found == true && errorprefix_Found == true ){
          error = error + '.' + '\n'+ errormessage_email + '\n'+ errormessage_phone + '\n' + errormessage_prefix + '\n\r' +  error1;
       }
        else if(errorphone_Found == true){
           error = error + '.' + '\n' + errormessage_phone + '\n\r' +  error1+'.';    
       } 
        else if(erroremail_Found == true) {
           error = error + '.' + '\n' + errormessage_email + '\n\r' +  error1 +'.';     
       }
         else if(errorprefix_Found == true) {
           error = error + '.' + '\n' + errormessage_prefix + '\n\r' +  error1+'.';     
       }
        if (component.get("v.jsDebug")) console.log(error);
        this.throwErrorCatched (component,error);         
        return false;
      } 

      
      
   if(errorFound == true){
       if (component.get("v.jsDebug")) console.log("FOR1");
     if(errorphone_Found == true && erroremail_Found == true && errorprefix_Found == true){
         if (component.get("v.jsDebug")) console.log("FOR_both");
          error = error + '.' +'\n'+ errormessage_email +'\n'+ errormessage_phone + '\n' + errormessage_prefix ;
       }
     else if(errorphone_Found == true){
           if (component.get("v.jsDebug")) console.log("FOR2");
           error = error + '.' + '\n'+ errormessage_phone ;    
       } 
     else if(erroremail_Found == true) {
           if (component.get("v.jsDebug")) console.log("FOR3");
           error = error + '.' + '\n\r'+ errormessage_email +'.';     
       }
     else if(errorprefix_Found == true){
          if (component.get("v.jsDebug")) console.log("FOR_prefix");
           error = error + '.' + '\n\r'+ errormessage_prefix;   
         }
     this.throwErrorCatched (component,error);       
     return false;
    }

    if(errorMotivoOpp == true){

      error = error + '.' +'\n'+ error_MotivoOpp ;
      this.throwErrorCatched (component,error_MotivoOpp);       
     return false;

    }

      
  if(errorFound1 == true){
    this.throwErrorCatched (component,error1);
    return false;
    } 
   
    else{return true;}
   },

   validateOpp : function(Opp, MotivoOpp){

    if (Opp == true && (MotivoOpp == '' || MotivoOpp == null || MotivoOpp == undefined || MotivoOpp == 'undefined')){
        return false;
        }else{  
            return true;
        }
  },

  
  validate_B2C : function(component) {
    let telephoneWithPrefix = component.get("v.telephoneWithPrefix");
    var person_email = component.get("v.currentAccount.CIF_PersonEmail__c");
    var work_email = component.get("v.currentAccount.CIF_Work_email__c");

    var phone = telephoneWithPrefix.CIF_Phone__c ? telephoneWithPrefix.CIF_Phone__c.telephoneNumber : '';
    var mobile_phone = telephoneWithPrefix.CIF_PersonMobilePhone__c ? telephoneWithPrefix.CIF_PersonMobilePhone__c.telephoneNumber : '';
    var work_phone = telephoneWithPrefix.CIF_Work_phone__c ? telephoneWithPrefix.CIF_Work_phone__c.telephoneNumber : '';
    var fax = telephoneWithPrefix.Fax ? telephoneWithPrefix.Fax.telephoneNumber : '';

    var phone_intprefix = telephoneWithPrefix.CIF_Phone__c ? telephoneWithPrefix.CIF_Phone__c.prefix : '';
    var mobile_phone_intprefix = telephoneWithPrefix.CIF_PersonMobilePhone__c ? telephoneWithPrefix.CIF_PersonMobilePhone__c.prefix : '';
    var work_phone_intprefix = telephoneWithPrefix.CIF_Work_phone__c ? telephoneWithPrefix.CIF_Work_phone__c.prefix : '';
    var fax_intprefix = telephoneWithPrefix.Fax ? telephoneWithPrefix.Fax.prefix : '';

    var OppTelPrinc = component.get("v.currentAccount.Flag_Opposizione_Tel_Princ__c");
    var OppTelCell = component.get("v.currentAccount.Flag_Opposizione_Tel_Cell_B2C__c");
    var OppFax = component.get("v.currentAccount.Flag_Opposizione_Fax__c");
    var OppTelUff = component.get("v.currentAccount.Flag_Opposizione_Tel_Uff__c")
    var OppEmailPers = component.get("v.currentAccount.Flag_Opposizione_Email_Pers_B2C__c");
    var OppEmailUff = component.get("v.currentAccount.Flag_Opposizione_Email_Uff__c");

    var MotivoOppTelPrinc = component.get("v.currentAccount.Motivo_opposizione_Tel_Princ__c");
    var MotivoOppTelCell = component.get("v.currentAccount.Motivo_opposizione_Tel_Cell_B2C__c");
    var MotivoOppFax = component.get("v.currentAccount.Motivo_opposizione_Fax__c");
    var MotivoOppTelUff = component.get("v.currentAccount.Motivo_opposizione_Tel_Uff__c")
    var MotivoOppEmailPers = component.get("v.currentAccount.Motivo_opposizione_Email_Pers_B2C__c");
    var MotivoOppEmailUff = component.get("v.currentAccount.Motivo_opposizione_Email_Uff__c");

    var check_TelPrinc = this.validateOpp(OppTelPrinc, MotivoOppTelPrinc);
    var check_TelCell = this.validateOpp(OppTelCell, MotivoOppTelCell);
    var check_TFax = this.validateOpp(OppFax, MotivoOppFax);
    var check_TelUff = this.validateOpp(OppTelUff, MotivoOppTelUff);
    var check_Email = this.validateOpp(OppEmailPers, MotivoOppEmailPers);
    var check_EmailUff = this.validateOpp(OppEmailUff, MotivoOppEmailUff);

    //debugger;
    console.log('check_TelPrinc'+ check_TelPrinc);
     console.log('check_TelCell'+ check_TelCell);
      console.log('check_TFax'+ check_TFax);
       console.log('check_TelUff'+ check_TelUff);
        console.log('check_Email'+ check_Email);
         console.log('check_EmailUff'+ check_EmailUff);

    var check_person_email= this.validateMail(component, 'Email_RegEx', person_email);
    console.log('*** validate_B2C - check_person_email: ' + check_person_email);
    var check_work_email= this.validateMail(component, 'Email_RegEx', work_email);
    console.log('*** validate_B2C - check_work_email: ' + check_work_email);
    var check_phone = this.validatePhone(component, 'Generic_Phone_RegEx', phone);
    console.log('*** validate_B2C - check_phone: ' + check_phone);  
    var check_mobile_phone = false; 
    if ( this.isEmpty(mobile_phone_intprefix) || (!this.isEmpty(mobile_phone_intprefix)  &&  (mobile_phone_intprefix === '+39' || mobile_phone_intprefix === '0039')) ) {
       check_mobile_phone = this.validatePhone(component, 'National_Mobile_Phone_RegEx', mobile_phone); 
       console.log('*** validate_B2C - check_mobile_phone 1: ' + check_mobile_phone); 
    } else {
   check_mobile_phone = this.validatePhone(component, 'Generic_Phone_RegEx', mobile_phone); 
       console.log('*** validate_B2C - check_mobile_phone 2: ' + check_mobile_phone);  
    }       
    var check_fax = this.validatePhone(component, 'Generic_Phone_RegEx', fax);
    console.log('*** validate_B2C - check_fax: ' + check_fax);   
    var check_work_phone = this.validatePhone(component, 'Generic_Phone_RegEx', work_phone); 
    console.log('*** validate_B2C - check_work_phone: ' + check_work_phone);
    var check_phone_intprefix = this.validatePrefix(component, 'Generic_Country_Code_RegEx', phone_intprefix);
    console.log('*** validate_B2C - check_phone_intprefix: ' + check_phone_intprefix);
    var check_mobile_phone_intprefix = this.validatePrefix(component, 'Generic_Country_Code_RegEx', mobile_phone_intprefix);
    console.log('*** validate_B2C - check_mobile_phone_intprefix: ' + check_mobile_phone_intprefix);
    var check_fax_intprefix = this.validatePrefix(component, 'Generic_Country_Code_RegEx', fax_intprefix);
    console.log('*** validate_B2C - check_fax_intprefix: ' + check_fax_intprefix);
    var check_work_intprefix = this.validatePrefix(component, 'Generic_Country_Code_RegEx', work_phone_intprefix); 
    console.log('*** validate_B2C - check_work_intprefix: ' + check_work_intprefix);
    //ANASTASI_S 19072019: Email and Phone Validation -----END
                
    var errorprefix_Found= false;
    var erroremail_Found= false
    var errorphone_Found= false;
    var errorFound = false;
    var errorFound1 = false;
    var errorMotivoOpp = false;
    var error1 = "Impossibile procedere al salvataggio di un campo di tipo prefisso senza compilare il corrispondente campo di tipo numero telefonico. Per procedere compilare i seguenti campi:";
    var error = "Impossibile procedere al salvataggio dei seguenti dati: ";
    var errormessage_email = "Nei campi di tipo Email sono ammessi i seguenti valori: \n - per lo username lettere, numeri e i caratteri speciali _.&\-+ ;  \n - per il dominio solo lettere";      
    var errormessage_phone = "Nei campi di tipo numero di telefono sono ammessi unicamente valori numerici"; 
    var errormessage_prefix = "Nei campi di tipo prefisso è possibile inserire il carattere speciale + ed espressioni numeriche di lunghezza massima pari a quattro cifre";  
    var error_MotivoOpp = "Selezionare il Motivo Opposizione per i seguenti dati: "
      
     if(check_person_email == false){
     error = error + " -Email"; 
     errorFound = true; 
     var erroremail_Found= true;
    }
    if(check_work_email == false){
     error = error + " -Email ufficio"; 
     errorFound = true;   
    var erroremail_Found= true;
    }
     if(check_phone == false){
     error = error + " -Telefono principale";  
     errorFound = true; 
     var errorphone_Found= true; 
    } 
    if(check_mobile_phone == false){
     error = error + " -Telefono cellulare";
     errorFound = true; 
     var errorphone_Found= true;
    } 
    if(check_fax == false){
     error = error + " -Fax";  
     errorFound = true; 
     var errorphone_Found= true;
    }   
    if(check_work_phone == false){
      error = error + " -Telefono ufficio"; 
      errorFound = true;
      var errorphone_Found= true;
    } 
    if(check_phone_intprefix == false){
     error = error + " -Prefisso internazionale del telefono principale";
     errorprefix_Found = true;
     errorFound = true;   
    } 
    if(check_mobile_phone_intprefix == false){
     error = error + " -Prefisso internazionale del telefono cellulare ";
     errorprefix_Found = true;
     errorFound = true;     
    } 
    if(check_fax_intprefix == false){
     error = error + " -Prefisso internazionale del fax";
     errorprefix_Found = true;
     errorFound = true;   
    }   
    if(check_work_intprefix == false ){
      error = error + " -Prefisso internazionale del telefono ufficio";
      errorprefix_Found = true;
      errorFound = true;    
    }
    if((phone_intprefix != "" && typeof phone_intprefix != "undefined") &&  (phone == "" || typeof phone == "undefined")){
    error1 = error1 + " -Telefono principale";
    errorFound1 = true;
    }
    if((work_phone_intprefix != "" && typeof work_phone_intprefix != "undefined") &&  (work_phone == "" || typeof work_phone == "undefined")){
    errorFound1 = true;
    }
    if((mobile_phone_intprefix != "" && typeof mobile_phone_intprefix != "undefined") &&  (mobile_phone == "" || typeof mobile_phone == "undefined")){
    error1 = error1 + " -Telefono cellulare";
    errorFound1 = true;
    }
    if((fax_intprefix != "" && typeof fax_intprefix != "undefined") && (fax == "" || typeof fax == "undefined")){
    error1 = error1 + " -Fax";
    errorFound1 = true;
    }

    if(check_TelPrinc == false){
     error_MotivoOpp = error_MotivoOpp + " -Telefono principale";
     errorMotivoOpp = true;
    } 
    if(check_TelCell == false){
     error_MotivoOpp = error_MotivoOpp + " -Telefono cellulare";
     errorMotivoOpp = true; 
    }
    if(check_TFax == false){
     error_MotivoOpp = error_MotivoOpp + " -Fax";
     errorMotivoOpp = true; 
    }
    if(check_TelUff == false){
     error_MotivoOpp = error_MotivoOpp + " -Telefono ufficio";
     errorMotivoOpp = true;   
    }
    if(check_Email == false){
     error_MotivoOpp = error_MotivoOpp + " -Email";
     errorMotivoOpp = true; 
    }
    if(check_EmailUff == false){
     error_MotivoOpp = error_MotivoOpp + " -Email ufficio";
     errorMotivoOpp = true; 
    }


    
    if(errorFound1 == true && errorFound == true  ){
       if(errorphone_Found == true && erroremail_Found == true && errorprefix_Found == true ){
          error = error + '.' + '\n'+ errormessage_email + '\n'+ errormessage_phone + '\n' + errormessage_prefix + '\n\r' +  error1;
       }
        else if(errorphone_Found == true){
           error = error + '.' + '\n' + errormessage_phone + '\n\r' +  error1+'.';    
       } 
        else if(erroremail_Found == true) {
           error = error + '.' + '\n' + errormessage_email + '\n\r' +  error1 +'.';     
       }
         else if(errorprefix_Found == true) {
           error = error + '.' + '\n' + errormessage_prefix + '\n\r' +  error1+'.';     
       }
        if (component.get("v.jsDebug")) console.log(error);
        this.throwErrorCatched (component,error);         
        return false;
      } 
    
   if(errorFound == true){
       if (component.get("v.jsDebug")) console.log("FOR1");
     if(errorphone_Found == true && erroremail_Found == true && errorprefix_Found == true){
         if (component.get("v.jsDebug")) console.log("FOR_both");
          error = error + '.' +'\n'+ errormessage_email +'\n'+ errormessage_phone + '\n' + errormessage_prefix ;
       }
     else if(errorphone_Found == true){
           if (component.get("v.jsDebug")) console.log("FOR2");
           error = error + '.' + '\n'+ errormessage_phone ;    
       } 
     else if(erroremail_Found == true) {
           if (component.get("v.jsDebug")) console.log("FOR3");
           error = error + '.' + '\n\r'+ errormessage_email +'.';     
       }
     else if(errorprefix_Found == true){
          if (component.get("v.jsDebug")) console.log("FOR_prefix");
           error = error + '.' + '\n\r'+ errormessage_prefix +'.' ;   
         }
   this.throwErrorCatched (component,error);       
   return false;
    }

    if(errorMotivoOpp == true){

      error = error + '.' +'\n'+ error_MotivoOpp ;
      this.throwErrorCatched (component,error_MotivoOpp);       
     return false;

    }

      
  if(errorFound1 == true){
    this.throwErrorCatched (component,error1);
    return false;
    } 
      
   else{return true;}
    },

  
  
  setOldInfo : function (component,infoName){
    console.log("Returned Account " + JSON.stringify(component.get("v.oldAccountInfo"), null, 4));
    var oldInfo = component.get("v.oldAccountInfo")[infoName];

    if (oldInfo==undefined) 
    {
      oldInfo = "";
    }
    component.set(infoName, oldInfo);
  },

  storeOldInfo : function(component,source,value){
      var infoMap = {};
      var oldAccountInfo = component.get("v.oldAccountInfo");
      if (oldAccountInfo!= null)
      {
        infoMap=oldAccountInfo;
      }
      infoMap[source] = value;
      component.set ("v.oldAccountInfo",infoMap);
  },

  storeInitialInfo : function (component){
      //MOSCATELLI_M 18/01/2018: Data enrichment SmartCenter Fase 1 -- START
      var fieldListSC = ["Additional_Comments__c","Additional_Phone__c","Additional_Email__c","CIF_PersonEmail__c","CIF_Work_email__c","CIF_Personalemail__c","CIF_Phone__c","CIF_MobilePhone__c","CIF_Work_phone__c","CIF_PersonMobilePhone__c","CIF_Phone_IntPrefix__c","CIF_MobilePhone_IntPrefix__c","CIF_Work_phone_IntPrefix__c","CIF_PersonMobilePhone_IntPrefix__c"];        
      var infoMapSC = {};
      var arrayLengthSC = fieldListSC.length;
      for (var i = 0; i < arrayLengthSC; i++) {       
        var targetSC = "v.currentAccount."+fieldListSC[i];          
          infoMapSC[targetSC] = (component.get(targetSC)==null)?'':component.get(targetSC);
      }
      component.set ("v.oldAccountInfoSC",infoMapSC);
      console.log('CIAO:+ '+JSON.stringify(infoMapSC));
      //MOSCATELLI_M 18/01/2018: Data enrichment SmartCenter Fase 1 -- END

      var infoMap = {};
      var fieldList = ["CIF_PersonEmail__c","CIF_Work_email__c","CIF_Personalemail__c","CIF_Phone__c","CIF_MobilePhone__c","Fax","CIF_Work_phone__c","CIF_PersonMobilePhone__c","CIF_Privacy_1__c","CIF_Privacy_2__c","CIF_Privacy_3__c","CIF_Privacy_4__c","CIF_Privacy_5__c","CIF_Privacy_7__c","CIF_Mail_contact__c","CIF_Document_type__c","CIF_Propaga_OMNIA_Phone__c","CIF_Propaga_OMNIA_Mobile_Phone__c","CIF_Propaga_OMNIA_PersonMobilePhone__c","CIF_Propaga_OMNIA_Fax__c","CIF_Propaga_OMNIA_Work_Phone__c","CIF_Propaga_OMNIA_PersonEmail__c","CIF_Propaga_OMNIA_Personal_Email__c","CIF_Propaga_OMNIA_Work_Email__c","CIF_Privacy_8__c", "CIF_OTP_Phone_contact__c","CIF_Numero__c","CIF_Expiry_date__c","Net_Promoter_Score_NPS__c"];//MMOSCATELLI 28/03/2019: ICF CR2 : ADDED NPS

      var arrayLength = fieldList.length;
      for (var i = 0; i < arrayLength; i++) {       
        var target = "v.currentAccount."+fieldList[i];
        infoMap[target] = component.get(target);
      }
      component.set ("v.oldAccountInfo",infoMap);
  },

  OpenTask : function (component){

    var OpenTask = component.get("v.OpenTask");
    var isSuccess = component.get("v.isSuccess");
    //console.log('OPENTASK!'+OpenTask);
    //console.log('isSuccessREOLcall'+isSuccess);
    
    if (OpenTask==true || isSuccess == false){
    var Consensimodificabili = false;
    component.set("v.Consensimodificabili",Consensimodificabili);
    } 
    component.set("v.OpenTask", OpenTask);
  },

  //MOSCATELLI_M 31/07/2017: Data Enrichment -- START
  goBacktoModify : function (component)
  {
    console.log("GOBACK--ENTER");

    if (component.get("v.EnrichError"))
        component.set("v.EnrichError",false);

 },
  
  
  splitData: function(component)
  {
      var ListString = component.get("v.ListString");
      var ListStringREL = component.get("v.ListStringREL");//MOSCATELLI_M 29/09/2017: Data Enrichment Enhancement
      console.log('ListStringREL: '+ListStringREL);
      console.log('ListString: '+ListString);
      var ListRecapiti = [];
      var ListConsensi = [];
      var ListAltriDati = [];
      //MOSCATELLI_M 29/09/2017: Data Enrichment Enhancement--START
      var ListRecapitiREL = [];
      var ListConsensiREL = [];
      var ListAltriDatiREL = [];       
      var arrayLength = ListString.length; 
      var arrayLengthREL = ListStringREL.length;
      //MOSCATELLI_M 29/09/2017: Data Enrichment Enhancement--END

      for (var i = 0; i < arrayLength; i++) { 
          console.log('string'+ListString[i]);
          if(ListString[i].includes('Email')){
             ListRecapiti.push('Email');
             break;
          }
      }

      for (var i = 0; i < arrayLength; i++) { 
          console.log('string'+i);
          if(ListString[i].includes('Telefono'))
          {
             ListRecapiti.push('Cellulare');
             break;
          }
      }

       for (var i = 0; i < arrayLength; i++) { 
          if(ListString[i].includes('Attività promozionali e di vendita') || ListString[i].includes('Ricerche di mercato') || ListString[i].includes('Att promoz-vendita-ric merc di partner') || ListString[i] == 'Invio documentazione in formato digitale' || ListString[i] == 'Utilizzo della firma grafometrica'){
              ListConsensi.push(ListString[i]);
          }
          if(ListString[i] == 'Stato civile' || ListString[i] == 'Professione' || ListString[i] == 'Fascia di reddito'){
              ListAltriDati.push(ListString[i]);
          }
      }

      //MOSCATELLI_M 29/09/2017: Data Enrichment Enhancement--START
      for (var i = 0; i < arrayLengthREL; i++) { 
          console.log('string'+i);
          if(ListStringREL[i].includes('Email')){
             ListRecapitiREL.push('Email');
             break;
          }
      }

      for (var i = 0; i < arrayLengthREL; i++) { 
          console.log('stringt'+ListStringREL[i]);
          if(ListStringREL[i].includes('Telefono')){
             ListRecapitiREL.push('Cellulare');
             break;
          }
      }

       for (var i = 0; i < arrayLengthREL; i++) { 
          if(ListStringREL[i].includes('Attività promozionali e di vendita') || ListStringREL[i].includes('Ricerche di mercato') || ListStringREL[i].includes('Att promoz-vendita-ric merc di partner') || ListStringREL[i] == 'Invio documentazione in formato digitale' || ListStringREL[i] == 'Utilizzo della firma grafometrica'){
              ListConsensiREL.push(ListStringREL[i]);
          }
          if(ListStringREL[i] == 'Stato civile' || ListStringREL[i] == 'Professione' || ListStringREL[i] == 'Fascia di reddito'){
              ListAltriDatiREL.push(ListStringREL[i]);
          }
      }      
      component.set ("v.ListRecapitiREL",ListRecapitiREL);
      component.set ("v.ListConsensiREL",ListConsensiREL);
      component.set ("v.ListAltriDatiREL",ListAltriDatiREL);          
      //MOSCATELLI_M 29/09/2017: Data Enrichment Enhancement--END

      component.set ("v.ListRecapiti",ListRecapiti);
      component.set ("v.ListConsensi",ListConsensi);
      component.set ("v.ListAltriDati",ListAltriDati);
      console.log('##Lists: '+ListAltriDatiREL+'   '+ListRecapitiREL+'ListREL :'+ListConsensiREL);

  },

  //MOSCATELLI_M 18/01/2018: Data enrichment SmartCenter Fase 1 -- START
  SkipChecks: function (component)
  {
     var infoMap = component.get("v.oldAccountInfoSC");
     var countCIFfields = 0;
     var countSmartFields=0;

     console.log("old##: "+JSON.stringify(infoMap));

     for(var v in infoMap)
     {
        console.log('old:'+(infoMap[v]!=null)?infoMap[v]:''+'-----new'+(component.get(v)!=null)?component.get(v):'');

        if((v!="v.currentAccount.Additional_Email__c") && (v!="v.currentAccount.Additional_Phone__c") && (v!="v.currentAccount.Additional_Comments__c"))
        {
          if(((infoMap[v]!=null)?infoMap[v]:'') != ((component.get(v)!=null)?component.get(v):''))
            countCIFfields++;
        }
        else 
        {
          if(((infoMap[v]!=null)?infoMap[v]:'') != ((component.get(v)!=null)?component.get(v):''))
            countSmartFields++;
        }
     }

 
     console.log('@@@countCIFfields: '+countCIFfields);
     console.log('@@@countSmartFields: '+countSmartFields);

     if(countCIFfields==0 && countSmartFields>0)
      return true;
     else
        return false;

  },
  //MOSCATELLI_M 18/01/2018: Data enrichment SmartCenter Fase 1 -- END

 //MOSCATELLI_M 31/07/2017: Data Enrichment -- END

 
  
  //FM_ 02/05/2018 : GPDR - START
  
  setPopuptoShow: function(component){
  
  var UserIsAdvisor = component.get("v.UserIsAdvisor")    
  var MPSEnrichment = component.get("v.MPSEnrichment");
  var PhoneCallId = component.get("v.PhoneCallId");
  var IsGDPRCase = component.get("v.IsGDPRCase");
  var isCall = true;
  console.log('PhonecallId'+PhoneCallId);
  
      if(UserIsAdvisor){    
      
  if(typeof PhoneCallId != 'undefined' && PhoneCallId != null && PhoneCallId != ''){
    var IsCall = true; 
    component.set("v.IsCall",true);
  }

  console.log('IsCall'+IsCall);
  
  if(IsCall && IsGDPRCase){

    console.log('dentro contact dpo')
  
      component.set("v.ContactDPO",true);
     
}
      
  if((IsCall && !IsGDPRCase && !MPSEnrichment) || 
     (!IsCall && !IsGDPRCase && !MPSEnrichment) || 
     (!IsCall && IsGDPRCase && !MPSEnrichment)){
          
        component.set("v.SearchonCCIR",true);
        console.log("searchonccir"+component.get("v.SearchonCCIR"));
  }
}
  },

   checkWarning : function(component, event, helper) {
      var action = component.get("c.getHiearchySettings");
      
      action.setCallback(this, function(response){
          if(component.isValid() && response !== null && response.getState() == 'SUCCESS'){
              if(response.getReturnValue().Warning_Edit_Account__c){
                  component.set("v.showWarning", true);
              }
              
          }
      });
      
      $A.enqueueAction(action);   
  },
})