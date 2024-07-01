({   


fillArrayEmail: function (component, receivedAccount){
    // Email objects to put in the array 

    var ConsentEmail = {};
    var PersonEmail  = {};
    var WorkEmail = {};
    var Email_array = [];

    ConsentEmail = {type: "Email consenso", value: receivedAccount.CIF_Mail_contact__c , selected: true };
    if (receivedAccount.IsPersonAccount == true)
    {
     PersonEmail  = {type: "Email personale", value: receivedAccount.CIF_PersonEmail__c , selected: false};
    }
    else 
    {
     PersonEmail  = {type: "Email personale", value: receivedAccount.CIF_Personalemail__c , selected: false};
    }
    WorkEmail    = {type: "Email lavoro", value: receivedAccount.CIF_Work_email__c, selected: false};

    // Populate the Email array with dedicated objects

    Email_array[0] = ConsentEmail;
    Email_array[1] = PersonEmail;
    Email_array[2] = WorkEmail;

    component.set ("v.oldAccountInfo",Email_array);

    return Email_array;

},    
    
fillEmailMap: function (component, receivedAccount){

    var inputEmail = component.find("inputEmail");
    //console.log('*****'+inputEmail);
    var EmailcontactsMap={}; 
    var receivedConsEmail = '';
    var receivedPersEmail = '';
    var receivedWorkEmail = '';
    var opts=[];
    
    // JS MAP: Create and populate the Email Map 
    
    receivedConsEmail = receivedAccount.CIF_Mail_contact__c;
    if (receivedAccount.IsPersonAccount == true)
    {
      receivedPersEmail = receivedAccount.CIF_PersonEmail__c;
    }
    else
    {
      receivedPersEmail = receivedAccount.CIF_Personalemail__c;
    }
    receivedWorkEmail = receivedAccount.CIF_Work_email__c;

    EmailcontactsMap['Email personale'] = receivedPersEmail;
    EmailcontactsMap['Email lavoro'] = receivedWorkEmail;
    EmailcontactsMap['Email consenso'] = receivedConsEmail;
    //console.log( 'Mappa contatti mail:' + JSON.stringify(EmailcontactsMap, null, 4));
    
    // Populate the Contatto mail Picklist

    opts.push({"class": "optionClass", label: "Nessuna email associata", value: null});    
    if (typeof receivedConsEmail != 'undefined' && receivedConsEmail!= null && receivedConsEmail != '')
    {
      opts.push({"class": "optionClass", label: receivedConsEmail+ " - Email già associata", value: receivedConsEmail});
    }
    if (typeof receivedPersEmail != 'undefined' && receivedPersEmail!= null && receivedPersEmail != '' && receivedPersEmail != receivedConsEmail)
    {
      opts.push({"class": "optionClass", label: receivedPersEmail+ " - Email personale", value: receivedPersEmail});
    }
    if (typeof receivedWorkEmail != 'undefined' && receivedWorkEmail!= null && receivedWorkEmail != '' && receivedWorkEmail != receivedConsEmail && receivedWorkEmail != receivedPersEmail)
    {
      opts.push({"class": "optionClass", label: receivedWorkEmail+ " - Email lavoro", value: receivedWorkEmail});
    }
      inputEmail.set("v.options", opts);
      inputEmail.set("v.value", receivedConsEmail);


    },

fillArrayMobilePhone: function (component, receivedAccount){
    // Email objects to put in the array 

    var ConsentMobilePhone = {};
    var MobilePhone  = {};
   
    var MobilePhone_array = [];

    ConsentMobilePhone = {type: "Cellulare consenso", value: receivedAccount.CIF_OTP_Phone_contact__c , selected: true };
    if (receivedAccount.IsPersonAccount == true)
    {
     MobilePhone  = {type: "Cellulare", value: receivedAccount.CIF_PersonMobilePhone__c , selected: false};
    }
    else 
    {
     MobilePhone  = {type: "Cellulare", value: receivedAccount.CIF_MobilePhone__c , selected: false};
    }
    

    // Populate the MobilePhone array with dedicated objects

    MobilePhone_array[0] = ConsentMobilePhone;
    MobilePhone_array[1] = MobilePhone;
   

    component.set("v.oldAccountInfoMobilePhone",MobilePhone_array);

    return MobilePhone_array;

},  

fillMobilePhoneMap: function (component, receivedAccount){

    var contactOTP = component.find("contactOTP");
    //console.log('*****'+inputEmail);
    var MobilePhonecontactsMap={}; 
    var receivedConsMobilePhone = '';
    var receivedPersMobilePhone = '';
    
    var opts=[];
    
    // JS MAP: Create and populate the Email Map 
    
    receivedConsMobilePhone = receivedAccount.CIF_OTP_Phone_contact__c;
    if (receivedAccount.IsPersonAccount == true)
    {
      receivedPersMobilePhone = receivedAccount.CIF_PersonMobilePhone__c;
    }
    else
    {
      receivedPersMobilePhone = receivedAccount.CIF_MobilePhone__c;
    }
    

    MobilePhonecontactsMap['Cellulare'] = receivedPersMobilePhone;
    MobilePhonecontactsMap['Cellulare consenso'] = receivedConsMobilePhone;
   
    console.log( 'Mappa contatti cellulare:' + JSON.stringify(MobilePhonecontactsMap, null, 4));
    
    // Populate the Contatto OTP Picklist

    opts.push({"class": "optionClass", label: "Nessun cellulare associato", value: null});    
    if (typeof receivedConsMobilePhone != 'undefined' && receivedConsMobilePhone!= null && receivedConsMobilePhone != '')
    {
      opts.push({"class": "optionClass", label: receivedConsMobilePhone+ " - Cellulare già associato", value: receivedConsMobilePhone});
    }
    if (typeof receivedPersMobilePhone != 'undefined' && receivedPersMobilePhone!= null && receivedPersMobilePhone != '' && receivedPersMobilePhone != receivedConsMobilePhone)
    {
      opts.push({"class": "optionClass", label: receivedPersMobilePhone+ " - Cellulare", value: receivedPersMobilePhone});
    }
    
      contactOTP.set("v.options", opts);
      contactOTP.set("v.value", receivedConsMobilePhone);


    },

    changeEmailPicklistvalues: function (component, infoMap, helper, OpenTask, isSuccess) {
      
      var isSuccess = component.get("v.isSuccess");
      var OpenTask = component.get("v.OpenTask"); 
      var inputEmail = component.find("inputEmail");
      var infoPersMail = infoMap["Personal Email"];
      var infoWorkMail = infoMap["Work Email"];
      var Differentcontact = component.get("v.Differentcontact");
      console.log('contatto mail legato a consenso'+Differentcontact);
      var InitialEmailMap = component.get("v.InitialEmailMap");
      var labeloldconsentemail = '';

      console.log("OPEN TASK"+OpenTask);

      if (OpenTask == false && isSuccess == true) {
    
      console.log(infoPersMail);
      console.log(infoWorkMail);

      var oldAccountInfo = component.get("v.oldAccountInfo");


      console.log('oldAccountInfo3:' + JSON.stringify(oldAccountInfo, null, 4)); 
      console.log('sono qui');
      var oldConsentEmail = oldAccountInfo[0].value;
          
          if(oldConsentEmail == undefined){
    
            oldConsentEmail = "";
          }
      var oldPersonEmail = oldAccountInfo[1].value;
      var oldWorkEmail = oldAccountInfo[2].value;

      if(oldConsentEmail != null){

      
      if(typeof infoPersMail!="undefined" && infoPersMail!= '' && infoPersMail!=null)
        {

       if( oldAccountInfo[1].selected == true || oldConsentEmail == oldPersonEmail)
   
        {

          if (oldConsentEmail == InitialEmailMap['Email consenso']){
            labeloldconsentemail = 'Email già associata';
          }
          else{
            
            if(oldConsentEmail == oldPersonEmail){
              labeloldconsentemail = 'Email personale';
            }
            if (oldConsentEmail == oldWorkEmail){
              labeloldconsentemail = 'Email lavoro';
            }

          }

        console.log('1');
        console.log('Differentcontact'+Differentcontact);
        console.log('oldConsentEmail'+oldConsentEmail);

      var opts=[]; 
      opts.push({"class": "optionClass", label: "Nessuna email associata", value: null}); 
      if (typeof oldConsentEmail != 'undefined' && oldConsentEmail!= null && oldConsentEmail != '' && oldConsentEmail != infoPersMail && oldConsentEmail != oldWorkEmail && oldConsentEmail != oldPersonEmail)
        {
       opts.push({"class": "optionClass", label: oldConsentEmail+ " - "+labeloldconsentemail, value: oldConsentEmail});
        }
      
      if (typeof Differentcontact != 'undefined' && Differentcontact!= null && Differentcontact != '' && Differentcontact != oldConsentEmail)
        {
      opts.push({"class": "optionClass", label: Differentcontact+ " - Email già associata", value: Differentcontact});
        }
      if(typeof infoPersMail != 'undefined' && infoPersMail!= null && infoPersMail != '') 
      {
        opts.push({"class": "optionClass", label: infoPersMail+ " - Email personale", value: infoPersMail});
      }
      /*  if (infoPersMail != oldConsentEmail)
        {
      opts.push({"class": "optionClass", label: infoPersMail+ "- Email personale", value: infoPersMail});
        }*/
      if(typeof oldWorkEmail != 'undefined' && oldWorkEmail != infoPersMail)
        {
      opts.push({"class": "optionClass", label: oldWorkEmail+ " - Email lavoro", value: oldWorkEmail});
        }

      inputEmail.set("v.options", opts);

      //inputEmail.set("v.value", infoPersMail);
      

      oldAccountInfo[0].value = infoPersMail;
      oldAccountInfo[1].value = infoPersMail;
      oldAccountInfo[2].value = oldWorkEmail;
      //oldAccountInfo[3].value = oldConsentEmail;

      component.set("v.oldAccountInfo", oldAccountInfo);


      }

      else
      {

        if (oldConsentEmail == InitialEmailMap['Email consenso']){
            labeloldconsentemail = 'Email già associata';
          }
          else{
            
            if(oldConsentEmail == oldPersonEmail){
              labeloldconsentemail = 'Email personale';
            }
            if (oldConsentEmail == oldWorkEmail){
              labeloldconsentemail = 'Email lavoro';
            }

          }

        console.log('2');

       var opts=[]; 
       opts.push({"class": "optionClass", label: "Nessuna email associata", value: null}); 
        if (typeof oldConsentEmail != 'undefined' && oldConsentEmail!= null && oldConsentEmail != '' )
        {
       opts.push({"class": "optionClass", label: oldConsentEmail+ " - "+labeloldconsentemail, value: oldConsentEmail});
        }
        if (typeof Differentcontact != 'undefined' && Differentcontact!= null && Differentcontact != '' && Differentcontact != oldConsentEmail )
        {
       opts.push({"class": "optionClass", label: Differentcontact+ " - Email già associata", value: Differentcontact});
        }
        if (infoPersMail != oldConsentEmail)
        {
       opts.push({"class": "optionClass", label: infoPersMail+ " - Email personale", value: infoPersMail});
         }
        if (typeof oldWorkEmail != 'undefined' && oldWorkEmail != oldConsentEmail && oldWorkEmail != infoPersMail ) 
        {
       opts.push({"class": "optionClass", label: oldWorkEmail+ " - Email lavoro", value: oldWorkEmail});
        }
       inputEmail.set("v.options", opts);

      inputEmail.set("v.value", oldConsentEmail);

      oldAccountInfo[0].value = oldConsentEmail;
      oldAccountInfo[1].value = infoPersMail;
      oldAccountInfo[2].value = oldWorkEmail;


      component.set("v.oldAccountInfo", oldAccountInfo);

      }
      } 
    
    if(typeof infoWorkMail!="undefined" && infoWorkMail!= '' && infoWorkMail!=null)

    {

      if ( (oldAccountInfo[2].selected == true || oldConsentEmail == oldWorkEmail) )
        {

          if (oldConsentEmail == InitialEmailMap['Email consenso']){
            labeloldconsentemail = 'Email già associata';
          }
          else{
            
            if(oldConsentEmail == oldPersonEmail){
              labeloldconsentemail = 'Email personale';
            }
            if (oldConsentEmail == oldWorkEmail){
              labeloldconsentemail = 'Email lavoro';
            }

          }

        console.log('3');

      var opts=[]; 
      opts.push({"class": "optionClass", label: "Nessuna email associata", value: null}); 
      if (typeof oldConsentEmail != 'undefined' && oldConsentEmail!= null && oldConsentEmail != '' && oldConsentEmail != infoWorkMail && oldConsentEmail != oldWorkEmail && oldConsentEmail != oldPersonEmail)
        {
       opts.push({"class": "optionClass", label: oldConsentEmail+ " - "+labeloldconsentemail, value: oldConsentEmail});
        }
      if (typeof Differentcontact != 'undefined' && Differentcontact!= null && Differentcontact != '' && Differentcontact != oldConsentEmail )
        {
      opts.push({"class": "optionClass", label: Differentcontact+ " - Email già associata", value: Differentcontact});
        }
      if (typeof infoWorkMail != 'undefined' && infoWorkMail!= null && infoWorkMail != '' )
        {
      opts.push({"class": "optionClass", label: infoWorkMail+ " - Email lavoro", value: infoWorkMail});
        }
      if(typeof oldPersonEmail != 'undefined' && oldPersonEmail != infoWorkMail)
        {
      opts.push({"class": "optionClass", label: oldPersonEmail+ " - Email personale", value: oldPersonEmail});
        }
      /*if (infoWorkMail != oldConsentEmail)
        {
      opts.push({"class": "optionClass", label: infoWorkMail+ "- Email lavoro", value: infoWorkMail});
        }*/

      inputEmail.set("v.options", opts);

      //inputEmail.set("v.value", infoWorkMail);
      
      oldAccountInfo[0].value = infoWorkMail;
      oldAccountInfo[1].value = oldPersonEmail;
      oldAccountInfo[2].value = infoWorkMail;
      //oldAccountInfo[3].value = oldConsentEmail;

      component.set("v.oldAccountInfo", oldAccountInfo);

        }

      else 
        {

          if (oldConsentEmail == InitialEmailMap['Email consenso']){
            labeloldconsentemail = 'Email già associata';
          }
          else{
            
            if(oldConsentEmail == oldPersonEmail){
              labeloldconsentemail = 'Email personale';
            }
            if (oldConsentEmail == oldWorkEmail){
              labeloldconsentemail = 'Email lavoro';
            }

          }

           console.log('4');
           console.log('Differentcontact'+Differentcontact);
          console.log('oldConsentEmail'+oldConsentEmail);

       var opts=[]; 
       opts.push({"class": "optionClass", label: "Nessuna email associata", value: null}); 
        if (typeof oldConsentEmail != 'undefined' && oldConsentEmail!= null && oldConsentEmail != '' )
        {
       opts.push({"class": "optionClass", label: oldConsentEmail+ " - "+labeloldconsentemail, value: oldConsentEmail});
        }
        if (typeof Differentcontact != 'undefined' && Differentcontact!= null && Differentcontact != '' && Differentcontact != oldConsentEmail)
        {
       opts.push({"class": "optionClass", label: Differentcontact+ " - Email già associata", value: Differentcontact});
        }
        if (typeof oldPersonEmail != 'undefined' && oldPersonEmail != oldConsentEmail && oldPersonEmail != infoWorkMail) 
        {
       opts.push({"class": "optionClass", label: oldPersonEmail+ " - Email personale", value: oldPersonEmail});
        }
        if (infoWorkMail != oldConsentEmail)
        {
       opts.push({"class": "optionClass", label: infoWorkMail+ " - Email lavoro", value: infoWorkMail});
        }
       inputEmail.set("v.options", opts);



       inputEmail.set("v.value", oldConsentEmail); 

      oldAccountInfo[0].value = oldConsentEmail;
      oldAccountInfo[1].value = oldPersonEmail;
      oldAccountInfo[2].value = infoWorkMail;

      component.set("v.oldAccountInfo", oldAccountInfo);

      }

      }

    }
  }
  },

  changeMobilePhonePicklistvalues: function (component, infoMap, helper, OpenTask, isSuccess) {

    var isSuccess = component.get("v.isSuccess");
    var OpenTask = component.get("v.OpenTask"); 
    var contactOTP = component.find("contactOTP");
    var infoMobilePhone = infoMap["Person Mobile Phone"];
    var Differentphonecontact = component.get("v.Differentphonecontact");
    console.log('contatto cellulare legato a consenso'+Differentphonecontact);
    var InitialMobilePhoneMap = component.get("v.InitialMobilePhoneMap");
    var labeloldconsentphone = '';

    console.log('infoMap' + JSON.stringify(infoMap, null, 4)); 
    console.log('InitialMobilePhoneMap'+ JSON.stringify(InitialMobilePhoneMap, null, 4)); 
    console.log('oldAccountInfoMobilePhone'+ JSON.stringify(component.get("v.oldAccountInfoMobilePhone"), null, 4)); 


     if (OpenTask == false && isSuccess == true) {
    
      console.log('infoMobilePhone'+infoMobilePhone);
      
      var oldAccountInfoMobilePhone = component.get("v.oldAccountInfoMobilePhone");


      console.log('oldAccountInfoMobilePhone3:' + JSON.stringify(oldAccountInfoMobilePhone, null, 4)); 
      console.log('sono qui');

      var oldConsentMobilePhone = oldAccountInfoMobilePhone[0].value;

      console.log('OLDCONSENTMOBILEPHONE'+oldConsentMobilePhone);
          
          if(oldConsentMobilePhone == undefined){
    
            oldConsentMobilePhone = "";
          }

      var oldMobilePhone = oldAccountInfoMobilePhone[1].value;
     
      if(oldConsentMobilePhone != null){


        if(typeof infoMobilePhone!="undefined" && infoMobilePhone!= '' && infoMobilePhone!=null)
        {

       if( oldAccountInfoMobilePhone[1].selected == true || oldConsentMobilePhone == oldMobilePhone)
   
        {

          if (oldConsentMobilePhone == InitialMobilePhoneMap['Cellulare consenso']){
            labeloldconsentphone = ' Cellulare già associato';
          }
          else{
            
            if(oldConsentMobilePhone == oldMobilePhone){
              labeloldconsentphone = ' Cellulare';
            }
           

          }

        console.log('1');
        console.log('Differentphonecontact'+Differentphonecontact);
        console.log('oldConsentMobilePhone'+oldConsentMobilePhone);

      var opts=[]; 
      opts.push({"class": "optionClass", label: "Nessun cellulare associato", value: null}); 
      if (typeof oldConsentMobilePhone != 'undefined' && oldConsentMobilePhone!= null && oldConsentMobilePhone != '' && oldConsentMobilePhone != infoMobilePhone  && oldConsentMobilePhone != oldMobilePhone && labeloldconsentphone != '')
        {
       opts.push({"class": "optionClass", label: oldConsentMobilePhone+ " - "+labeloldconsentphone, value: oldConsentMobilePhone});
        }
      
      if (typeof Differentphonecontact != 'undefined' && Differentphonecontact!= null && Differentphonecontact != '' && Differentphonecontact != oldConsentMobilePhone)
        {
      opts.push({"class": "optionClass", label: Differentphonecontact+ " - Cellulare già associato", value: Differentphonecontact});
        }
      if(typeof infoMobilePhone != 'undefined' && infoMobilePhone!= null && infoMobilePhone != '') 
      {
        opts.push({"class": "optionClass", label: infoMobilePhone+ " - Cellulare", value: infoMobilePhone});
      }


      contactOTP.set("v.options", opts);

      //contactOTP.set("v.value", infoMobilePhone);
      

      oldAccountInfoMobilePhone[0].value = infoMobilePhone;
      oldAccountInfoMobilePhone[1].value = infoMobilePhone;
      

      component.set("v.oldAccountInfoMobilePhone", oldAccountInfoMobilePhone);


      }

      else
      {

        if (oldConsentMobilePhone == InitialMobilePhoneMap['Cellulare consenso']){
            labeloldconsentphone = 'Cellulare già associato';
          }
          else{
            
            if(oldConsentMobilePhone == oldMobilePhone){
              labeloldconsentphone = 'Cellulare';
            }
            

          }

        console.log('2');

       var opts=[]; 
       opts.push({"class": "optionClass", label: "Nessun cellulare associato", value: null}); 
        if (typeof oldConsentMobilePhone != 'undefined' && oldConsentMobilePhone!= null && oldConsentMobilePhone != '' )
        {
       opts.push({"class": "optionClass", label: oldConsentMobilePhone+ " - "+labeloldconsentphone, value: oldConsentMobilePhone});
        }
        if (typeof Differentphonecontact != 'undefined' && Differentphonecontact!= null && Differentphonecontact != '' && Differentphonecontact != oldConsentMobilePhone )
        {
       opts.push({"class": "optionClass", label: Differentphonecontact+ " - Cellulare già associato", value: Differentphonecontact});
        }
        if (infoMobilePhone != oldConsentMobilePhone)
        {
       opts.push({"class": "optionClass", label: infoMobilePhone+ " - Cellulare", value: infoMobilePhone});
         }

      contactOTP.set("v.options", opts);

      contactOTP.set("v.value", oldConsentMobilePhone);

      oldAccountInfoMobilePhone[0].value = oldConsentMobilePhone;
      oldAccountInfoMobilePhone[1].value = infoMobilePhone;


      component.set("v.oldAccountInfoMobilePhone", oldAccountInfoMobilePhone);

      }
      } 


      }else{



      }
    }


  },




 sendPrivacy2: function(component,source,value) {
        
        var infoEvent = $A.get("e.c:ChangePrivacy2Event");

        var map={};
        map[source]= value;
        //console.log(" map " + JSON.stringify(map, null, 4));
        
        infoEvent.setParams({ "changedPrivacy2": map }).fire();
       

    }

        
   
})