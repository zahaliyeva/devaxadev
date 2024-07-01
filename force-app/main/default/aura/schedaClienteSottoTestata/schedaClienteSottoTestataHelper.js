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

    getBulletClass : function(privacyField, certificazioneField) {
        if(privacyField == 'Sì' && certificazioneField == 'Sì') {
            return 'green';
        }

        if( !privacyField) {
            return 'grey';
        }

        return 'red';

    },

    getBulletClassNoCertificazione : function(privacyField) {
        if(privacyField == 'Sì') {
            return 'green';
        }

        if(privacyField == 'No') {
            return 'red';
        }

        return 'grey';

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
        const certificazionePrivacy1 = component.get('v.wrapper.account.Bcert_Privacy_1_Ndg_AAI__c'); 
        const certificazionePrivacy2 = component.get('v.wrapper.account.Bcert_Privacy_2_Ndg_AAI__c'); 
        const certificazionePrivacy3 = component.get('v.wrapper.account.Bcert_Privacy_3_Ndg_AAI__c'); 
        const certificazionePrivacy4 = component.get('v.wrapper.account.Bcert_Privacy_4_Ndg_AAI__c'); 
        const certificazionePrivacyProfilazione = component.get('v.wrapper.account.Bcert_Privacy_Profilazione_Ndg_AAI__c'); 
        let bulletClass = '';
        
        try {
            let trattamentoDatiPersonali = component.find('trattamentoDatiPersonaliBullet');
            let CIF_Privacy_1__c = component.get('v.wrapper.account.CIF_Privacy_1__c'); 
            
            bulletClass = this.getBulletClass(CIF_Privacy_1__c, certificazionePrivacy1);
            $A.util.addClass(trattamentoDatiPersonali, bulletClass);
            bullets+="<span class='dot " + bulletClass + "'></span>";

        } catch(exception) {
            console.error(exception);
        }

        
        try {
            let attPromoVendita = component.find('attPromoVenditaBullet');
            let CIF_Privacy_2__c = component.get('v.wrapper.account.CIF_Privacy_2__c'); 

            bulletClass = this.getBulletClass(CIF_Privacy_2__c, certificazionePrivacy2);
            $A.util.addClass(attPromoVendita, bulletClass);
            bullets+="<span class='dot " + bulletClass + "'></span>";

        } catch(exception) {
            console.error(exception);
        }

        try {
            let ricercheMercato = component.find('ricercheMercatoBullet');
            let CIF_Privacy_3__c = component.get('v.wrapper.account.CIF_Privacy_3__c'); 

            bulletClass = this.getBulletClass(CIF_Privacy_3__c, certificazionePrivacy3);
            $A.util.addClass(ricercheMercato, bulletClass);
            bullets+="<span class='dot " + bulletClass + "'></span>";

           
        } catch(exception) {
            console.error(exception);
        }

        try {
            let attPromoVendMerc = component.find('attPromoVendMercBullet');
            let CIF_Privacy_4__c = component.get('v.wrapper.account.CIF_Privacy_4__c'); 

            bulletClass = this.getBulletClass(CIF_Privacy_4__c, certificazionePrivacy4);
            $A.util.addClass(attPromoVendMerc, bulletClass);
            bullets+="<span class='dot " + bulletClass + "'></span>";

            
        } catch(exception) {
            console.error(exception);
        }

        try {
            let profilazioneBullet = component.find('profilazioneBullet');
            let Cprivacy_Profilazione_Ndg_AAI__c = component.get('v.wrapper.account.Cprivacy_Profilazione_Ndg_AAI__c'); 

            bulletClass = this.getBulletClass(Cprivacy_Profilazione_Ndg_AAI__c, certificazionePrivacyProfilazione);
            $A.util.addClass(profilazioneBullet, bulletClass);
            bullets+="<span class='dot " + bulletClass + "'></span>";

            
        } catch(exception) {
            console.error(exception);
        }

        component.set("v.privacyBullets", bullets);

    },

    manageBulletClienteDigitale : function(component) {
        let bullets = "";

        const certificazionePrivacy5 = component.get('v.wrapper.account.Bcert_Privacy_Email_Ndg_AAI__c'); 
        const certificazionePrivacy7 = component.get('v.wrapper.account.Bcert_Privacy_Firma_Ndg_AAI__c'); 
        const certificazionePrivacy8 = component.get('v.wrapper.account.Bcert_Privacy_Otp_Ndg_AAI__c');  
        let bulletClass = '';

        try {
            let invioDocDigit = component.find('invioDocDigitBullet');
            let CIF_Privacy_5__c = component.get('v.wrapper.account.CIF_Privacy_5__c'); 

            bulletClass = this.getBulletClass(CIF_Privacy_5__c, certificazionePrivacy5);
            $A.util.addClass(invioDocDigit, bulletClass);
            bullets+="<span class='dot " + bulletClass + "'></span>";

        } catch(exception) {
            console.error(exception);
        }

        try {
            let utilizzFirmGrafo = component.find('utilizzFirmGrafoBullet');
            let CIF_Privacy_7__c = component.get('v.wrapper.account.CIF_Privacy_7__c'); 
            
            bulletClass = this.getBulletClass(CIF_Privacy_7__c, certificazionePrivacy7);
            $A.util.addClass(utilizzFirmGrafo, bulletClass);
            bullets+="<span class='dot " + bulletClass + "'></span>";

        } catch(exception) {
            console.error(exception);
        }

        try {
            let adesioneSrvOtp = component.find('adesioneSrvOtpBullet');
            let CIF_Privacy_8__c = component.get('v.wrapper.account.CIF_Privacy_8__c'); 
            
            bulletClass = this.getBulletClass(CIF_Privacy_8__c, certificazionePrivacy8);
            $A.util.addClass(adesioneSrvOtp, bulletClass);
            bullets+="<span class='dot " + bulletClass + "'></span>";

        } catch(exception) {
            console.error(exception);
        }
        
        component.set("v.clientDigiBullets", bullets);
    },

    manageBulletPreferenze : function(component){
        let bullets = "";

        let bulletClass = '';

        try{
            let PreferenzeBullet =  component.find('PreferenzeBullet');
            
            let Comunicazioni_Informative__c = component.get('v.wrapper.account.Comunicazioni_informative__c');
            
            bulletClass = this.getBulletClassNoCertificazione(Comunicazioni_Informative__c);
            $A.util.addClass(PreferenzeBullet, bulletClass);
            bullets+="<span class='dot " + bulletClass + "'></span>";

        }catch(exception){
            console.log(exception);
        }
        component.set("v.PreferenzeBullet", bullets);
    }
})