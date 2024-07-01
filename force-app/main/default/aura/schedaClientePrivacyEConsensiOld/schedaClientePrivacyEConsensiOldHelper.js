({
    manageTogglePrivacy : function(component) {
        
        try {
            let trattamentoDatiPersonali = component.find('trattamentoDatiPersonali');
            let CIF_Privacy_1__c = component.get('v.wrapper.account.CIF_Privacy_1__c'); 
            if(CIF_Privacy_1__c == 'Sì'){
                trattamentoDatiPersonali.set('v.checked', true);
            }
        } catch(exception) {
            console.error(exception);
        }

        try {
            let attPromoVendita = component.find('attPromoVendita');
            let CIF_Privacy_2__c = component.get('v.wrapper.account.CIF_Privacy_2__c'); 
            if(CIF_Privacy_2__c == 'Sì'){
                attPromoVendita.set('v.checked', true);
            }
        } catch(exception) {
            console.error(exception);
        }

        try {
            let ricercheMercato = component.find('ricercheMercato');
            let CIF_Privacy_3__c = component.get('v.wrapper.account.CIF_Privacy_3__c'); 
            if(CIF_Privacy_3__c == 'Sì'){
                ricercheMercato.set('v.checked', true);
            }
        } catch(exception) {
            console.error(exception);
        }

        try {
            let attPromoVendMerc = component.find('attPromoVendMerc');
            let CIF_Privacy_4__c = component.get('v.wrapper.account.CIF_Privacy_4__c'); 
            if(CIF_Privacy_4__c == 'Sì'){
                attPromoVendMerc.set('v.checked', true);
            }
        } catch(exception) {
            console.error(exception);
        }

        try {
            let invioDocDigit = component.find('invioDocDigit');
            let CIF_Privacy_5__c = component.get('v.wrapper.account.CIF_Privacy_5__c'); 
            if(CIF_Privacy_5__c == 'Sì'){
                invioDocDigit.set('v.checked', true);
            }
        } catch(exception) {
            console.error(exception);
        }

        try {
            let utilizzFirmGrafo = component.find('utilizzFirmGrafo');
            let CIF_Privacy_7__c = component.get('v.wrapper.account.CIF_Privacy_7__c'); 
            if(CIF_Privacy_7__c == 'Sì'){
                utilizzFirmGrafo.set('v.checked', true);
            }
        } catch(exception) {
            console.error(exception);
        }

        try {
            let adesioneSrvOtp = component.find('adesioneSrvOtp');
            let CIF_Privacy_8__c = component.get('v.wrapper.account.CIF_Privacy_8__c'); 
            if(CIF_Privacy_8__c == 'Sì'){
                adesioneSrvOtp.set('v.checked', true);
            }
        } catch(exception) {
            console.error(exception);
        }

        try{
            let adesioneSrvOtp = component.find('Preferenze');
            let CIF_Privacy_8__c = component.get('v.wrapper.account.Comunicazioni_informative__c'); 
            if(CIF_Privacy_8__c == 'Sì'){
                adesioneSrvOtp.set('v.checked', true);
            }
        } catch(exception){
            console.error(exception);
        }
    }
})