({   
        
    
    sendEmailInfo: function(component,source,value) {
        
        var infoEvent = $A.get("e.c:ChangeEmailEvent");
        
        var map={};
        map[source]= value;
        //console.log(" map " + JSON.stringify(map, null, 4));
        
        infoEvent.setParams({ "changedEmail": map }).fire();
        
        
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
    
    
    WorkableContact: function (component){
        
        var OpenTask = component.get("v.OpenTask");
        
        var PersEmail = component.find("CIF_Person_email").get("v.value");
        
        var WorkEmail = component.find("CIF_Work_email").get("v.value");
        
        var ConsEmail = component.get("v.EmailConsenso");
        
        console.log('EMAIL PERSONALE'+PersEmail);
        console.log('EMAIL LAVORO'+ WorkEmail);
        console.log('EMAIL CONSENSO' +ConsEmail);

        if(OpenTask == true){

          console.log('Open Task'+OpenTask);

            if(ConsEmail == PersEmail && ConsEmail != null){

                component.set("v.BlockedPersEmail",true);
                component.set("v.BlockFlagPersEmail",true);
                document.getElementById('container_Emailpersonale').title="Il contatto Email personale non è modificabile nel caso in cui sia associato ad un fascicolo da lavorare";

                console.log('BLOCKPERSEMAIL'+component.get("v.BlockedPersEmail"));
                console.log('BLOCKFLAGPERSEMAIL'+component.get("v.BlockFlagPersEmail"));
            }
            if(ConsEmail == WorkEmail && ConsEmail != null){

                component.set("v.BlockedWorkEmail",true);
                component.set("v.BlockFlagWorkEmail",true);
                document.getElementById('container_Emaillavoro').title="Il contatto Email ufficio non è modificabile nel caso in cui sia associato ad un fascicolo da lavorare";

                console.log('BLOCKWORKEMAIL'+component.get("v.BlockedWorkEmail"));
                console.log('BLOCKWORKPERSEMAIL'+component.get("v.BlockFlagWorkEmail"));
            }
        }
        
        
    }
       


   

})