({
    
    handleAccountReceived: function(component, event, helper) {
        var receivedAccount = event.getParam("containedAccount");
        //console.log('receivedPwoc'+receivedPwoc);
        helper.storeInitialInfo(component,receivedAccount); 
        var OpenTask = component.get("v.OpenTask");
        var EmailConsenso = receivedAccount.CIF_Mail_contact__c;
        var PhoneConsenso = receivedAccount.CIF_OTP_Phone_contact__c; 
        component.set("v.EmailConsenso",EmailConsenso);
        component.set("v.PhoneConsenso",PhoneConsenso);
        helper.WorkableContact(component);
        console.log('OPEN TASK RECAPITI'+OpenTask);   
    }, 

    PhoneChange : function(component, event, helper) {
        var new_Phone = component.find("CIF_Phone").get("v.value");
        console.log('cif_phone'+new_Phone);
        var field = 'CIF_Phone';
        var Opposizione = 'OppPrincipale';
        var MotivoOpp = 'MotivoOppPrincipale';
        helper.checkifNewContact(component,field,Opposizione,MotivoOpp);
 

    },


    MobilePhoneChange : function(component, event, helper) {
        var new_MobilePhone = component.find("CIF_Person_Mobile_Phone").get("v.value");
        var field = 'CIF_Person_Mobile_Phone';
        var Opposizione = 'OppCellulare';
        var MotivoOpp = 'MotivoOppCellulare';
        component.set("v.Recapiti_B2B.CIF_MobilePhone__c", new_MobilePhone);
        helper.sendMobilePhoneInfo(component, "Person Mobile Phone",new_MobilePhone);
        helper.checkifNewContact(component,field,Opposizione,MotivoOpp); 


    },

    FaxChange : function(component, event, helper) {
        var new_Fax = component.find("Fax_").get("v.value");
        var field = 'Fax_';
        var Opposizione = 'OppFax';
        var MotivoOpp ='MotivoOppFax';
        helper.checkifNewContact(component,field,Opposizione,MotivoOpp); 


    },

     WorkPhoneChange : function(component, event, helper) {
        var new_Email = component.find("CIF_Work_phone_IntPrefix").get("v.value");
        var field = 'CIF_Work_phone';   
        var Opposizione = 'OppTelUff';
        var MotivoOpp = 'MotivoOppTelUff';
        helper.checkifNewContact(component,field,Opposizione,MotivoOpp); 

    },

    PersEmailChange : function(component, event, helper) {
        var new_Email = component.find("CIF_Personal_email").get("v.value");
        var field = 'CIF_Personal_email';
        var Opposizione = 'OppEmail';
        var MotivoOpp = 'MotivoOppEmail';
        //console.log("New personal Email" + new_Email);
        component.set("v.Recapiti_B2B.CIF_Personalemail__c", new_Email);
        helper.sendEmailInfo(component,"Personal Email", new_Email);   
        helper.checkifNewContactMailPersonale(component,field,Opposizione,MotivoOpp);

    },

    WorkEmailChange: function (component, event, helper){
        var new_WorkEmail = component.find("CIF_Work_email").get("v.value");
        var field = 'CIF_Work_email';
        var Opposizione = 'OppEmailUff';
        var MotivoOpp = 'MotivoOppEmailUff';
        //console.log("New work Email" + new_WorkEmail);
        component.set("v.Recapiti_B2B.CIF_Work_email__c", new_WorkEmail);
        helper.sendEmailInfo(component,"Work Email", new_WorkEmail); 
        helper.checkifNewContactMailUfficio(component,field,Opposizione,MotivoOpp);
    },


    OpposizioneChange: function (component,helper){

        var OpposizionePhone = component.find("OppPrincipale").get("v.value");
        var OpposizioneMobile = component.find("OppCellulare").get("v.value");
        var OpposizioneFax = component.find("OppFax").get("v.value");
        var OpposizioneWorkPhone = component.find("OppTelUff").get("v.value");
        var OpposizioneEmail = component.find("OppEmail").get("v.value");
        var OpposizioneEmailUff = component.find("OppEmailUff").get("v.value");
       
        if(OpposizionePhone == false){

           component.find("MotivoOppPrincipale").set("v.value",'');

        }

        if(OpposizioneMobile == false){

           component.find("MotivoOppCellulare").set("v.value",'');

        }

        if(OpposizioneFax == false){

           component.find("MotivoOppFax").set("v.value",'');

        }

        if(OpposizioneWorkPhone == false){

           component.find("MotivoOppTelUff").set("v.value",'');

        }

        if(OpposizioneEmail == false){

           component.find("MotivoOppEmail").set("v.value",'');

        }

        if(OpposizioneEmailUff == false){

           component.find("MotivoOppEmailUff").set("v.value",'');

        }




    },

    handlePrivacy2change: function(component,event,helper){
        var receivedPrivacy2 = event.getParam("changedPrivacy2");

        console.log('event received');
        console.log('is '+JSON.stringify(receivedPrivacy2, null, 4)+', privacy 2 is changed and is true');

        if(receivedPrivacy2["Privacy2"] == 'Sì'){

            helper.disableOpposizionifields(component);
        }

    }
    

  
 
})