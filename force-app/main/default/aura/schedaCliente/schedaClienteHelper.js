({
    parseResponse: function(component, helper, returnValue){
        let wrapper = returnValue;
        //helper.formatPhone(wrapper, 'Telefono_cellulare_ListView__c');
        //helper.formatPhone(wrapper, 'CIF_PersonMobilePhone__c');
        //helper.formatPhone(wrapper, 'CIF_Phone__c');
        //helper.formatPhone(wrapper, 'Additional_Phone__c');
        //helper.formatPhone(wrapper, 'PersonMobilePhone');
        //helper.formatPhone(wrapper, 'Phone');
        //helper.formatPhone(wrapper, 'PersonOtherPhone');
        //helper.formatPhone(wrapper, 'CIF_Work_phone__c');
        //helper.formatPhoneAgency(wrapper, 'Phone');
        //helper.formatPhone(wrapper, 'Claim_PersonalMobile__c');
        //helper.formatPhone(wrapper, 'CIF_OTP_Phone_contact__c');
        component.set("v.wrapper", wrapper);
        //component.set("v.wrapper.isAAI", false);
        //component.set("v.wrapper.isPerson", true);
    },
    formatPhone: function(wrapper, fiedName){
        if(wrapper.account[fiedName]){
            wrapper.account[fiedName] = wrapper.account[fiedName].split(/\s+/).join('');
            if(!wrapper.account[fiedName].startsWith('0039') && !wrapper.account[fiedName].startsWith('+')){
                wrapper.account[fiedName] = '0039' + wrapper.account[fiedName];
            }
        }
    },
    formatPhoneAgency: function(wrapper, fiedName){
        if(wrapper.account.AAI_Agency__r && wrapper.account.AAI_Agency__r[fiedName]){
            wrapper.account.AAI_Agency__r[fiedName] = wrapper.account.AAI_Agency__r[fiedName].split(/\s+/).join('');
            if(!wrapper.account.AAI_Agency__r[fiedName].startsWith('0039') && !wrapper.account.AAI_Agency__r[fiedName].startsWith('+')){
                wrapper.account.AAI_Agency__r[fiedName] = '0039' + wrapper.account.AAI_Agency__r[fiedName];
            }
        }
    }
})