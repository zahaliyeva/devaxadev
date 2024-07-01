({   
    
    
    

    sendEmailInfo: function(component,source,value) {
        
        var infoEvent = $A.get("e.c:ChangeEmailEvent");

        var map={};
        map[source]= value;
        //console.log(" map " + JSON.stringify(map, null, 4));
        
        infoEvent.setParams({ "changedEmail": map }).fire();
       

    },

    sendMobilePhoneInfo: function(component,source,value) {
        
        var infoEvent = $A.get("e.c:ChangeMobilePhoneEvent");

        var map={};
        map[source]= value;
        //console.log(" map " + JSON.stringify(map, null, 4));
        
        infoEvent.setParams({ "changedMobilePhone": map }).fire();
       

    },

    storeInitialInfo : function (component,receivedAccount){

        console.log('receivedAccount'+ JSON.stringify(receivedAccount, null, 4));
        var infoMap = {};
        
        var Phone = receivedAccount.CIF_Phone__c;
        var MobilePhone = receivedAccount.CIF_PersonMobilePhone__c;
        var Fax = receivedAccount.Fax;
        var WorkPhone = receivedAccount.CIF_Work_phone__c;
        var PersonEmail = receivedAccount.CIF_PersonEmail__c;
        var WorkEmail = receivedAccount.CIF_Work_email__c;

        infoMap['CIF_Phone'] = Phone;
        infoMap['CIF_Person_Mobile_Phone'] = MobilePhone;
        infoMap['Fax_'] = Fax;
        infoMap['CIF_Work_phone'] = WorkPhone;
        infoMap['CIF_Person_email'] = PersonEmail;
        infoMap['CIF_Work_email'] = WorkEmail;

        component.set ("v.InitialInfo",infoMap);

    },

    checkifNewContact: function(component,field,Opposizione,MotivoOpp) {
        
        var InitialInfo = component.get("v.InitialInfo");

        console.log('InitialInfo'+ JSON.stringify(InitialInfo, null, 4));

        if(InitialInfo[field] == null){

          if(component.find(field).get("v.value") == null || component.find(field).get("v.value") == ''){

            component.find(Opposizione).set("v.value",false);
            component.find(MotivoOpp).set("v.value",'');


          }else{

          console.log('nuovo inserimento');


          }     

           }else{

            if(component.find(field).get("v.value") == null || component.find(field).get("v.value") == ''){

            component.find(Opposizione).set("v.value",false);
            component.find(MotivoOpp).set("v.value",'');
          }


           }

    },


    checkifNewContactMailPersonale: function(component,field,Opposizione,MotivoOpp) {
        
        var InitialInfo = component.get("v.InitialInfo");

        console.log('InitialInfo'+ JSON.stringify(InitialInfo, null, 4));

        if(InitialInfo[field] == null){

          if(component.find(field).get("v.value") == null || component.find(field).get("v.value") == ''){

            component.find(Opposizione).set("v.value",false);
            component.find(MotivoOpp).set("v.value",'');


          }else{

          console.log('nuovo inserimento');

          }     

           }else{

            if(component.find(field).get("v.value") == null || component.find(field).get("v.value") == ''){

            component.find(Opposizione).set("v.value",false);
            component.find(MotivoOpp).set("v.value",'');
          }


           }

    },

    checkifNewContactMailUfficio: function(component,field,Opposizione,MotivoOpp) {
        
        var InitialInfo = component.get("v.InitialInfo");

        console.log('InitialInfo'+ JSON.stringify(InitialInfo, null, 4));

        if(InitialInfo[field] == null){

          if(component.find(field).get("v.value") == null || component.find(field).get("v.value") == ''){

            component.find(Opposizione).set("v.value",false);
            component.find(MotivoOpp).set("v.value",'');

          }else{

          console.log('nuovo inserimento');

          }     

           }else{

            if(component.find(field).get("v.value") == null || component.find(field).get("v.value") == ''){

            component.find(Opposizione).set("v.value",false);
            component.find(MotivoOpp).set("v.value",'');
          }


           }

    },

    WorkableContact: function (component){

        var OpenTask = component.get("v.OpenTask");
        var PersEmail = component.find("CIF_Person_email").get("v.value");
        var WorkEmail = component.find("CIF_Work_email").get("v.value");
        var ConsEmail = component.get("v.EmailConsenso");
        var MobilePhone = component.find("CIF_Person_Mobile_Phone").get("v.value");
        var ConsPhone = component.get("v.PhoneConsenso");

        console.log('EMAIL PERSONALE'+PersEmail);
        console.log('EMAIL LAVORO'+ WorkEmail);
        console.log('EMAIL CONSENSO' +ConsEmail);
        console.log('PHONE MOBILE' + MobilePhone);
        console.log('PHONE CONSENSO' + ConsPhone);

        if(OpenTask == true){

          console.log('Open Task'+OpenTask);

            if(ConsEmail == PersEmail && ConsEmail != null){

                component.set("v.BlockedPersEmail",true);
                component.set("v.BlockFlagPersEmail",true);
                component.set("v.BlockOppPersEmail",true);
                document.getElementById('container_Emailpersonale').title="Il contatto Email personale non è modificabile nel caso in cui sia associato ad un fascicolo da lavorare";

                console.log('BLOCKPERSEMAIL'+component.get("v.BlockedPersEmail"));
                console.log('BLOCKFLAGPERSEMAIL'+component.get("v.BlockFlagPersEmail"));
            }
            if(ConsEmail == WorkEmail && ConsEmail != null){

                component.set("v.BlockedWorkEmail",true);
                component.set("v.BlockFlagWorkEmail",true);
                component.set("v.BlockOppWorkEmail",true);
                document.getElementById('container_Emaillavoro').title="Il contatto Email ufficio non è modificabile nel caso in cui sia associato ad un fascicolo da lavorare";

                console.log('BLOCKWORKEMAIL'+component.get("v.BlockedWorkEmail"));
                console.log('BLOCKWORKPERSEMAIL'+component.get("v.BlockFlagWorkEmail"));
            }

            if(ConsPhone == MobilePhone && ConsPhone != null){

                component.set("v.BlockedMobilePhone",true);
                component.set("v.BlockFlagMobilePhone",true);
                component.set("v.BlockOppMobilePhone",true);
                //document.getElementById('container_mobilephone').title="Il telefono cellulare non è modificabile nel caso in cui sia associato ad un fascicolo da lavorare";

                console.log('BLOCKMOBILEPHONE'+component.get("v.BlockedMobilePhone"));
                
            }
        }
    },


    disableOpposizionifields: function (component,helper){


        var OpposizionePhone = component.find("OppPrincipale").get("v.value");
        var OpposizioneMobile = component.find("OppCellulare").get("v.value");
        var OpposizioneFax = component.find("OppFax").get("v.value");
        var OpposizioneWorkPhone = component.find("OppTelUff").get("v.value");
        var OpposizioneEmail = component.find("OppEmail").get("v.value");
        var OpposizioneEmailUff = component.find("OppEmailUff").get("v.value");
        
        if(OpposizionePhone == true){
        component.find("OppPrincipale").set("v.value",false);
        component.find("MotivoOppPrincipale").set("v.value",'');
        }
        if(OpposizioneMobile == true){
        component.find("OppCellulare").set("v.value",false);
        component.find("MotivoOppCellulare").set("v.value",'');
        }
        if(OpposizioneFax == true){
        component.find("OppFax").set("v.value", false);
        component.find("MotivoOppFax").set("v.value",'');
        }
        if(OpposizioneWorkPhone == true){
        component.find("OppTelUff").set("v.value",false);
        component.find("MotivoOppTelUff").set("v.value",'');
        }
        if(OpposizioneEmail == true){
        component.find("OppEmail").set("v.value",false);
        component.find("MotivoOppEmail").set("v.value",'');
        }
        if(OpposizioneEmailUff == true){
        component.find("OppEmailUff").set("v.value",false);
        component.find("MotivoOppEmailUff").set("v.value",'');
        }

        }

    
       

 
   

})