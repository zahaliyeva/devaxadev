({
    manageAddress : function(component) {
        try {
            let isPF = component.get('v.wrapper.isPerson');
            let address = "";
            if(isPF){
                address = component.get('v.wrapper.account.PersonMailingAddress'); 
            } else {
                address = component.get('v.wrapper.account.BillingAddress'); 
            }
            let fullAddr =  "";
            fullAddr += typeof address.street !== 'undefined' ? address.street : "";
            fullAddr += typeof address.postalCode !== 'undefined' ? ", " + address.postalCode : "";
            fullAddr += typeof address.city !== 'undefined' ? ", " +address.city : "";
            fullAddr += typeof address.stateCode !== 'undefined' ? " (" + address.stateCode + ")" : "";

            /*
            {
            "city": "AGRIGENTO",
            "country": "Italy",
            "countryCode": "IT",
            "geocodeAccuracy": null,
            "latitude": null,
            "longitude": null,
            "postalCode": "92100",
            "state": "Agrigento",
            "stateCode": "AG",
            "street": "VIA ROMA, 1"
            }
            */   
            component.set('v.fullAddress', fullAddr);
        
        } catch (e) {
            // Error handling
            console.error(e);
        }
    },

    manageBulletPrivacy : function(component) {
        /*
        
                            <span class="dot green"></span>
                            <span class="dot green"></span>
                            <span class="dot red"></span>
                            <span class="dot red"></span>
                            <span class="dot grey"></span>    
                            */
        let bullets = "";
        
        try {
            let trattamentoDatiPersonali = component.find('trattamentoDatiPersonaliBullet');
            let CIF_Privacy_1__c = component.get('v.wrapper.account.CIF_Privacy_1__c'); 
            
            if(CIF_Privacy_1__c == 'Sì'){
                $A.util.addClass(trattamentoDatiPersonali, 'green');
                bullets+="<span class='dot green'></span>";
            } else if(CIF_Privacy_1__c == 'No'){
                $A.util.addClass(trattamentoDatiPersonali, 'red');
                bullets+="<span class='dot red'></span>";
            } else {
                $A.util.addClass(trattamentoDatiPersonali, 'grey');
                bullets+="<span class='dot grey'></span>";
            }
        } catch(exception) {
            console.error(exception);
        }

        
        try {
            let attPromoVendita = component.find('attPromoVenditaBullet');
            let CIF_Privacy_2__c = component.get('v.wrapper.account.CIF_Privacy_2__c'); 
            if(CIF_Privacy_2__c == 'Sì'){
                $A.util.addClass(attPromoVendita, 'green');
                bullets+="<span class='dot green'></span>";
            } else if(CIF_Privacy_2__c == 'No'){
                $A.util.addClass(attPromoVendita, 'red');
                bullets+="<span class='dot red'></span>";
            } else {
                $A.util.addClass(attPromoVendita, 'grey');
                bullets+="<span class='dot grey'></span>";
            }
        } catch(exception) {
            console.error(exception);
        }

        try {
            let ricercheMercato = component.find('ricercheMercatoBullet');
            let CIF_Privacy_3__c = component.get('v.wrapper.account.CIF_Privacy_3__c'); 
            if(CIF_Privacy_3__c == 'Sì'){
                $A.util.addClass(ricercheMercato, 'green');
                bullets+="<span class='dot green'></span>";
            } else if(CIF_Privacy_3__c == 'No'){
                $A.util.addClass(ricercheMercato, 'red');
                bullets+="<span class='dot red'></span>";
            } else {
                $A.util.addClass(ricercheMercato, 'grey');
                bullets+="<span class='dot grey'></span>";
            }
        } catch(exception) {
            console.error(exception);
        }

        try {
            let attPromoVendMerc = component.find('attPromoVendMercBullet');
            let CIF_Privacy_4__c = component.get('v.wrapper.account.CIF_Privacy_4__c'); 
            if(CIF_Privacy_4__c == 'Sì'){
                $A.util.addClass(attPromoVendMerc, 'green');
                bullets+="<span class='dot green'></span>";
            } else if(CIF_Privacy_4__c == 'No'){
                $A.util.addClass(attPromoVendMerc, 'red');
                bullets+="<span class='dot red'></span>";
            } else {
                $A.util.addClass(attPromoVendMerc, 'grey');
                bullets+="<span class='dot grey'></span>";
            }
        } catch(exception) {
            console.error(exception);
        }

        component.set("v.privacyBullets", bullets);

    },

    manageBulletClienteDigitale : function(component) {
        let bullets = "";

        try {
            let invioDocDigit = component.find('invioDocDigitBullet');
            let CIF_Privacy_5__c = component.get('v.wrapper.account.CIF_Privacy_5__c'); 
            if(CIF_Privacy_5__c == 'Sì'){
                $A.util.addClass(invioDocDigit, 'green');
                bullets+="<span class='dot green'></span>";
            } else if(CIF_Privacy_5__c == 'No'){
                $A.util.addClass(invioDocDigit, 'red');
                bullets+="<span class='dot red'></span>";
            } else {
                $A.util.addClass(invioDocDigit, 'grey');
                bullets+="<span class='dot grey'></span>";
            }
        } catch(exception) {
            console.error(exception);
        }

        try {
            let utilizzFirmGrafo = component.find('utilizzFirmGrafoBullet');
            let CIF_Privacy_7__c = component.get('v.wrapper.account.CIF_Privacy_7__c'); 
            if(CIF_Privacy_7__c == 'Sì'){
                $A.util.addClass(utilizzFirmGrafo, 'green');
                bullets+="<span class='dot green'></span>";
            } else if(CIF_Privacy_7__c == 'No'){
                $A.util.addClass(utilizzFirmGrafo, 'red');
                bullets+="<span class='dot red'></span>";
            } else {
                $A.util.addClass(utilizzFirmGrafo, 'grey');
                bullets+="<span class='dot grey'></span>";
            }
        } catch(exception) {
            console.error(exception);
        }

        try {
            let adesioneSrvOtp = component.find('adesioneSrvOtpBullet');
            let CIF_Privacy_8__c = component.get('v.wrapper.account.CIF_Privacy_8__c'); 
            if(CIF_Privacy_8__c == 'Sì'){
                $A.util.addClass(adesioneSrvOtp, 'green');
                bullets+="<span class='dot green'></span>";
            } else if(CIF_Privacy_8__c == 'No'){
                $A.util.addClass(adesioneSrvOtp, 'red');
                bullets+="<span class='dot red'></span>";
            } else {
                $A.util.addClass(adesioneSrvOtp, 'grey');
                bullets+="<span class='dot grey'></span>";
            }
        } catch(exception) {
            console.error(exception);
        }
        
        component.set("v.clientDigiBullets", bullets);
    },

    manageBulletPreferenze : function(component){
        let bullets = "";
        try{
            let PreferenzeBullet =  component.find('PreferenzeBullet');
            
            let Comunicazioni_Informative__c = component.get('v.wrapper.account.Comunicazioni_informative__c');
            if(Comunicazioni_Informative__c == 'Sì'){
                $A.util.addClass(PreferenzeBullet, 'green');
                bullets+="<span class='dot green'></span>";
            } else if(Comunicazioni_Informative__c == 'No'){
                $A.util.addClass(PreferenzeBullet, 'red');
                bullets+="<span class='dot red'></span>";
            }
        }catch(exception){
            console.log(exception);
        }
        component.set("v.PreferenzeBullet", bullets);
    }
})