({
    manageTogglePrivacy : function(component) {
        
        const auraIdToFields = [
            { auraId: "trattamentoDatiPersonali", field: "v.wrapper.account.CIF_Privacy_1__c" },
            { auraId: "attPromoVendita", field: "v.wrapper.account.CIF_Privacy_2__c"},
            { auraId: "ricercheMercato", field: "v.wrapper.account.CIF_Privacy_3__c"},
            { auraId: "attPromoVendMerc", field: "v.wrapper.account.CIF_Privacy_4__c"},
            { auraId: "profilazione", field: "v.wrapper.account.Cprivacy_Profilazione_Ndg_AAI__c"},
            { auraId: "invioDocDigit", field: "v.wrapper.account.CIF_Privacy_5__c"},
            { auraId: "utilizzFirmGrafo", field: "v.wrapper.account.CIF_Privacy_7__c"},
            { auraId: "adesioneSrvOtp", field: "v.wrapper.account.CIF_Privacy_8__c"},
            { auraId: "Preferenze", field: "v.wrapper.account.Comunicazioni_informative__c"},
            { auraId: "trattamentoDatiPersonaliCertificazione", field: "v.wrapper.account.Bcert_Privacy_1_Ndg_AAI__c"},
            { auraId: "attPromoVenditaCertificazione", field: "v.wrapper.account.Bcert_Privacy_2_Ndg_AAI__c"},
            { auraId: "ricercheMercatoCertificazione", field: "v.wrapper.account.Bcert_Privacy_3_Ndg_AAI__c"},
            { auraId: "attPromoVendMercCertificazione", field: "v.wrapper.account.Bcert_Privacy_4_Ndg_AAI__c"},
            { auraId: "profilazioneCertificazione", field: "v.wrapper.account.Bcert_Privacy_Profilazione_Ndg_AAI__c"},
            { auraId: "invioDocDigitCertificazione", field: "v.wrapper.account.Bcert_Privacy_Email_Ndg_AAI__c"},
            { auraId: "utilizzFirmGrafoCertificazione", field: "v.wrapper.account.Bcert_Privacy_Firma_Ndg_AAI__c"},
            { auraId: "adesioneSrvOtpCertificazione", field: "v.wrapper.account.Bcert_Privacy_Otp_Ndg_AAI__c"},
            { auraId: "trattamentoDatiPersonaliQuadra", field: "v.wrapper.account.Cprivacy_1_LE_AAI_QUADRA__c"},
            { auraId: "attPromoVenditaQuadra", field: "v.wrapper.account.Cprivacy_2_LE_AAI_QUADRA__c"},
            { auraId: "ricercheMercatoQuadra", field: "v.wrapper.account.Cprivacy_3_LE_AAI_QUADRA__c"},
            { auraId: "attPromoVendMercQuadra", field: "v.wrapper.account.Cprivacy_4_LE_AAI_QUADRA__c"},
            { auraId: "trattamentoDatiPersonaliAMAV", field: "v.wrapper.account.Cprivacy_1_LE_AMAV__c"},
            { auraId: "attPromoVenditaAMAV", field: "v.wrapper.account.Cprivacy_2_LE_AMAV__c"},
            { auraId: "ricercheMercatoAMAV", field: "v.wrapper.account.Cprivacy_3_LE_AMAV__c"},
            { auraId: "attPromoVendMercAMAV", field: "v.wrapper.account.Cprivacy_4_LE_AMAV__c"},
            { auraId: "trattamentoDatiPersonaliAMAD", field: "v.wrapper.account.Cprivacy_1_LE_AMAD__c"},
            { auraId: "attPromoVenditaAMAD", field: "v.wrapper.account.Cprivacy_2_LE_AMAD__c"},
            { auraId: "ricercheMercatoAMAD", field: "v.wrapper.account.Cprivacy_3_LE_AMAD__c"},
            { auraId: "attPromoVendMercAMAD", field: "v.wrapper.account.Cprivacy_4_LE_AMAD__c"},
            { auraId: "trattamentoDatiPersonaliQuadraCert", field: "v.wrapper.account.Bcert_Privacy_1_LE_AAI_QUADRA__c"},
            { auraId: "attPromoVenditaQuadraCert", field: "v.wrapper.account.Bcert_Privacy_2_LE_AAI_QUADRA__c"},
            { auraId: "ricercheMercatoQuadraCert", field: "v.wrapper.account.Bcert_Privacy_3_LE_AAI_QUADRA__c"},
            { auraId: "attPromoVendMercQuadraCert", field: "v.wrapper.account.Bcert_Privacy_4_LE_AAI_QUADRA__c"},
            { auraId: "trattamentoDatiPersonaliAMAVCert", field: "v.wrapper.account.Bcert_Privacy_1_LE_AMAV__c"},
            { auraId: "attPromoVenditaAMAVCert", field: "v.wrapper.account.Bcert_Privacy_2_LE_AMAV__c"},
            { auraId: "ricercheMercatoAMAVCert", field: "v.wrapper.account.Bcert_Privacy_3_LE_AMAV__c"},
            { auraId: "attPromoVendMercAMAVCert", field: "v.wrapper.account.Bcert_Privacy_4_LE_AMAV__c"},
            { auraId: "trattamentoDatiPersonaliAMADCert", field: "v.wrapper.account.Bcert_Privacy_1_LE_AMAD__c"},
            { auraId: "attPromoVenditaAMADCert", field: "v.wrapper.account.Bcert_Privacy_2_LE_AMAD__c"},
            { auraId: "ricercheMercatoAMADCert", field: "v.wrapper.account.Bcert_Privacy_3_LE_AMAD__c"},
            { auraId: "attPromoVendMercAMADCert", field: "v.wrapper.account.Bcert_Privacy_4_LE_AMAD__c"},



        ]
        try {
            for(let privacyWrap of auraIdToFields) {
                let privacyBullet = component.find(privacyWrap.auraId);
                let privacyField = component.get(privacyWrap.field); 

                $A.util.addClass(privacyBullet, this.getBulletClass(privacyField));
            }
            
            
        } catch(exception) {
            console.error(exception);
        }

    },
    getBulletClass : function(privacyField) {
        if(privacyField == 'Sì') {
            return 'green';
        }

        if(privacyField == 'No') {
            return 'red';
        }

        return 'grey';

    }
})