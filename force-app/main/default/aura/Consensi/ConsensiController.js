({
    
         
    handleAccountReceived: function(component, event, helper) {
        var receivedAccount = event.getParam("containedAccount");
        var isPrivacy1populated = component.get("v.isPrivacy1populated");
        var EmailcontactsMap = {};
        var MobilePhonecontactsMap = {};

        //console.log('èèèè'+isPrivacy1populated);
        console.log("event received");
        console.log('receivedAccount:' + JSON.stringify(receivedAccount, null, 4));
        var isSuccess = component.get("v.isSuccess");
        var isOpen = component.get("v.OpenTask");


        
        if (isSuccess == true && isOpen == false){
        component.find("CIF_Privacy_1").set("v.value", "Sì");
        }

        if(receivedAccount.IsPersonAccount == true){
            var PersEmail = receivedAccount.CIF_PersonEmail__c;
            var MobilePhone = receivedAccount.CIF_PersonMobilePhone__c; 
        }else{
            var PersEmail = receivedAccount.CIF_Personalemail__c;
            var MobilePhone = receivedAccount.CIF_MobilePhone__c;
        }
        var WorkEmail = receivedAccount.CIF_Work_email__c;

        var ConsentEmail = receivedAccount.CIF_Mail_contact__c;
        var ConsentMobilePhone = receivedAccount.CIF_OTP_Phone_contact__c;

        if(ConsentEmail != PersEmail && ConsentEmail != WorkEmail){
        component.set("v.Differentcontact",ConsentEmail);
        }

        if(ConsentMobilePhone != MobilePhone){
        component.set("v.Differentphonecontact",ConsentMobilePhone);
        }

        EmailcontactsMap['Email personale'] = PersEmail;
        EmailcontactsMap['Email lavoro'] = WorkEmail;
        EmailcontactsMap['Email consenso'] = ConsentEmail;

        component.set("v.InitialEmailMap",EmailcontactsMap);

        MobilePhonecontactsMap['Cellulare'] = MobilePhone;
        MobilePhonecontactsMap['Cellulare consenso'] = ConsentMobilePhone;

        component.set("v.InitialMobilePhoneMap", MobilePhonecontactsMap);

        helper.fillEmailMap(component,receivedAccount);
        helper.fillArrayEmail(component, receivedAccount);        
        helper.fillMobilePhoneMap(component, receivedAccount);
        helper.fillArrayMobilePhone(component, receivedAccount);

        console.log('myOldInfo'+JSON.stringify(component.get("v.oldAccountInfo"), null, 4));
        console.log('myOldMobileInfo'+JSON.stringify(component.get("v.oldAccountInfoMobilePhone"),null,4));
        console.log('isDAOLAgency'+component.get("v.isDAOLAgency"));
        
    },

    onSelectChangePrivacy5: function(component, event, helper) { 
        var selected_status = component.find("Privacy5").get("v.value");
               

        if (selected_status == "No" || selected_status == "")
   
        {
            //clear values

            var contatto_mail = component.find("inputEmail").set("v.value", null);
            //component.find("Consent_collected_by_mail").set("v.value", false);
  
            document.getElementById('contatto_mail').className= 'dynamicStyle slds-form-element_label';
            //document.getElementById('collected_by_mail').className= 'dynamicStyle slds-form-element_label';
        }

        else if (selected_status == "Sì")
        {
            document.getElementById('contatto_mail').className= 'inputStyle slds-form-element_label';
            //document.getElementById('collected_by_mail').className= 'inputStyle slds-form-element_label';
        }
       
    },


    onSelectChangePrivacy7: function(component, event, helper) {
        var selected_status = component.find("Privacy7").get("v.value"); 
        var selected_status8 = component.find("Privacy8").get("v.value");      
        
        if (selected_status == "No" || selected_status == "")
   
        {   

            if(selected_status8 == "No" || selected_status8 == "")
             { 


            component.find("Number").set("v.value", null);
            component.find("Expiry_date").set("v.value", null);


            
            document.getElementById('Number_label').className= 'dynamicStyle slds-form-element_label';
            document.getElementById('Expiry_date_label').className= 'dynamicStyle slds-form-element_label';
            

        }else{


            document.getElementById('Number_label').className= 'inputStyle slds-form-element_label';
            document.getElementById('Expiry_date_label').className= 'inputStyle slds-form-element_label';
        }
        }

        else if (selected_status == "Sì")
        {
            document.getElementById('Number_label').className= 'inputStyle slds-form-element_label';
            document.getElementById('Expiry_date_label').className= 'inputStyle slds-form-element_label';
            
        }
    },

    onSelectChangePrivacy8: function(component, event, helper) { 
        var selected_status = component.find("Privacy8").get("v.value");
        var selected_status7 = component.find("Privacy7").get("v.value");               

        if (selected_status == "No" || selected_status == "")
   
        {


            //clear values

            var contatto_mail = component.find("contactOTP").set("v.value", null);
            //component.find("Consent_collected_by_mail").set("v.value", false);
  
            document.getElementById('OTP_contact').className= 'dynamicStyle slds-form-element_label';
            //document.getElementById('collected_by_mail').className= 'dynamicStyle slds-form-element_label';

            if(selected_status7 == "No" || selected_status7 == "")
             { 


            component.find("Number").set("v.value", null);
            component.find("Expiry_date").set("v.value", null);

            
            document.getElementById('Number_label').className= 'dynamicStyle slds-form-element_label';
            document.getElementById('Expiry_date_label').className= 'dynamicStyle slds-form-element_label';
            
         
        }else{


            document.getElementById('Number_label').className= 'inputStyle slds-form-element_label';
            document.getElementById('Expiry_date_label').className= 'inputStyle slds-form-element_label';
        }


            
        }

        else if (selected_status == "Sì")
        {
       
            document.getElementById('OTP_contact').className= 'inputStyle slds-form-element_label';
            document.getElementById('Number_label').className= 'inputStyle slds-form-element_label';
            document.getElementById('Expiry_date_label').className= 'inputStyle slds-form-element_label';
            //document.getElementById('collected_by_mail').className= 'inputStyle slds-form-element_label';
        }
       
    },

    onSelectChangeContattoMail: function (component, event, helper){

        var Email_contact = component.get("v.currentAccount.CIF_Mail_contact__c");
        var oldAccountInfo = component.get("v.oldAccountInfo");
        var inputEmail = component.find("inputEmail").get("v.value");
        Email_contact = component.set("v.currentAccount.CIF_Mail_contact__c",inputEmail);
        console.log('inputEmail'+inputEmail);
        console.log('oldAccountInfo1:' + JSON.stringify(oldAccountInfo, null, 4)); 
        var arrayLength = oldAccountInfo.length;

         if (oldAccountInfo[0].value == inputEmail)
        {
            oldAccountInfo[0].selected = true;
            oldAccountInfo[1].selected = false;
            oldAccountInfo[2].selected = false;
        }



        else if (oldAccountInfo[1].value == inputEmail)

        {
            oldAccountInfo[0].selected = false;
            oldAccountInfo[1].selected = true;
            oldAccountInfo[2].selected = false;
            oldAccountInfo[0].value = oldAccountInfo[1].value;
        }

        else if (oldAccountInfo[2].value == inputEmail)

        {

            oldAccountInfo[0].selected = false;
            oldAccountInfo[1].selected = false;
            oldAccountInfo[2].selected = true;
            oldAccountInfo[0].value = oldAccountInfo[2].value;
        }

        else if(oldAccountInfo[0].value != inputEmail && oldAccountInfo[1].value != inputEmail && inputEmail != ""){

            oldAccountInfo[0].value = inputEmail;
            oldAccountInfo[0].selected = true;
            oldAccountInfo[1].selected = false; 
            oldAccountInfo[2].selected = false;
        }

        else if (inputEmail == "")

        {
            oldAccountInfo[0].selected = false;
            oldAccountInfo[1].selected = false;
            oldAccountInfo[2].selected = false;
             oldAccountInfo[0].value = null;
        }

        console.log('oldAccountInfo2:' + JSON.stringify(oldAccountInfo, null, 4)); 

        
        component.set ("v.oldAccountInfo",oldAccountInfo);
        //var Account = component.get("v.currentAccount");
        //console.log('NEW ACCOUNT'+ JSON.stringify(Account, null, 4));
        //console.log('NEW SET ACCOUNT'+ JSON.stringify(oldAccountInfo, null, 4));
      

    },

    onSelectChangeContattoOTP: function (component, event, helper){

        var MobilePhone_contact = component.get("v.currentAccount.CIF_OTP_Phone_contact__c");
        var oldAccountInfoMobilePhone = component.get("v.oldAccountInfoMobilePhone");
        var contactOTP = component.find("contactOTP").get("v.value");
        MobilePhone_contact = component.set("v.currentAccount.CIF_OTP_Phone_contact__c",contactOTP);
        console.log('contactOTP'+contactOTP);
        console.log('oldAccountInfoMobilePhone1:' + JSON.stringify(oldAccountInfoMobilePhone, null, 4)); 
        var arrayLength = oldAccountInfoMobilePhone.length;

         if (oldAccountInfoMobilePhone[0].value == contactOTP)
        {
            console.log('I')
            oldAccountInfoMobilePhone[0].selected = true;
            oldAccountInfoMobilePhone[1].selected = false;
           
        }

        else if (oldAccountInfoMobilePhone[1].value == contactOTP)

        {
            console.log('II')
            oldAccountInfoMobilePhone[0].selected = false;
            oldAccountInfoMobilePhone[1].selected = true;

            oldAccountInfoMobilePhone[0].value = oldAccountInfoMobilePhone[1].value;
        }

        else if(oldAccountInfoMobilePhone[0].value != contactOTP && oldAccountInfoMobilePhone[1].value != contactOTP && contactOTP != ""){

            oldAccountInfoMobilePhone[0].value = contactOTP;
            oldAccountInfoMobilePhone[0].selected = true;
            oldAccountInfoMobilePhone[1].selected = false; 
        }


        else if (contactOTP == "")

        {
            console.log('IV')
            oldAccountInfoMobilePhone[0].selected = false;
            oldAccountInfoMobilePhone[1].selected = false;
            oldAccountInfoMobilePhone[0].value = null;
        }

        console.log('oldAccountInfoMobilePhone2:' + JSON.stringify(oldAccountInfoMobilePhone, null, 4)); 

        
        component.set ("v.oldAccountInfoMobilePhone",oldAccountInfoMobilePhone);
        //var Account = component.get("v.currentAccount");
        //console.log('NEW ACCOUNT'+ JSON.stringify(Account, null, 4));
        //console.log('NEW SET ACCOUNT'+ JSON.stringify(oldAccountInfo, null, 4));
      

    },

    // ChangeEmailEvent handler
   
    handlechangedEmails : function (component, event, helper) {

        var infoMap = event.getParam("changedEmail");
        var OpenTask = component.get("v.OpenTask");
        var isSuccess = component.get("v.isSuccess");
        console.log('OPEN OR NOT'+OpenTask);
        helper.changeEmailPicklistvalues(component,infoMap,OpenTask,isSuccess);

    },

    handlechangedMobilePhone : function (component, event, helper) {

        var infoMap = event.getParam("changedMobilePhone");
        var OpenTask = component.get("v.OpenTask");
        var isSuccess = component.get("v.isSuccess");
        console.log('OPEN OR NOT'+OpenTask);
        helper.changeMobilePhonePicklistvalues(component,infoMap,OpenTask,isSuccess);

    },

    onChangeFlagmail: function (component, event, currentAccount, receivedAccount) {


        var inputFlag = component.find("Consent_collected_by_mail").get("v.value");
        var  FlagHelpText = false;
        console.log(inputFlag);

        if (inputFlag == true){

            FlagHelpText = true; 
        }else{

            FlagHelpText = false;
        }
        //console.log('HELP'+FlagHelpText);

        component.set("v.FlagHelpText", FlagHelpText);
       
    },

    ChangePrivacy2: function(component,event,helper){

        var newPrivacy2 = component.find("Privacy2").get("v.value");
        component.set("v.Consensi.CIF_Privacy_2__c",newPrivacy2);
        console.log('newPrivacy2'+newPrivacy2);
        helper.sendPrivacy2(component,"Privacy2",newPrivacy2); 
     
    }

    }
        
})