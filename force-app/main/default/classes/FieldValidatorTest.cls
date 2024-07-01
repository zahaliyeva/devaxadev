@isTest
private class FieldValidatorTest {

    static testMethod void runTest() {
    	
        // Email
        String emailAddress = 'mario.rossi@test.it';
        Boolean checkEmailAddress = (FieldValidator.validateFieldValue('Email_RegEx', emailAddress)) ? true : false;
        System.assertEquals(true, checkEmailAddress);
        emailAddress = 'mario.r@ssi@test.it';
        checkEmailAddress = (FieldValidator.validateFieldValue('Email_RegEx', emailAddress)) ? true : false;
        System.assertEquals(false, checkEmailAddress);
        
        // Country code
        String countryCode = '+44';
        Boolean checkCountryCode = (FieldValidator.validateFieldValue('Generic_Country_Code_RegEx', countryCode.replaceAll( '\\s+', ''))) ? true : false;
        System.assertEquals(true, checkCountryCode);
        countryCode = '+39';
        checkCountryCode = (FieldValidator.validateFieldValue('Generic_Country_Code_RegEx', countryCode.replaceAll( '\\s+', ''))) ? true : false;
        System.assertEquals(true, checkCountryCode);
        countryCode = '0039';
        checkCountryCode = (FieldValidator.validateFieldValue('Generic_Country_Code_RegEx', countryCode.replaceAll( '\\s+', ''))) ? true : false;
        System.assertEquals(true, checkCountryCode);
        
        // National phone number
        String phoneNumber = '035 253210';
        Boolean checkPhoneNumber = (FieldValidator.validateFieldValue('National_Phone_RegEx', phoneNumber.replaceAll( '\\s+', ''))) ? true : false;
        System.assertEquals(true, checkPhoneNumber);
        // National phone number with country code: +39
        phoneNumber = '+39 035 253210';
        checkPhoneNumber = (FieldValidator.validateFieldValue('Generic_Phone_RegEx', phoneNumber.replaceAll( '\\s+', ''))) ? true : false;
        System.assertEquals(true, checkPhoneNumber);
        // National phone number with country code: 0039
        phoneNumber = '0039 035 253210';
        checkPhoneNumber = (FieldValidator.validateFieldValue('Generic_Phone_RegEx', phoneNumber.replaceAll( '\\s+', ''))) ? true : false;
        System.assertEquals(true, checkPhoneNumber);
        // Generic phone number
        phoneNumber = '035 253210';
        checkPhoneNumber = (FieldValidator.validateFieldValue('Generic_Phone_RegEx', phoneNumber.replaceAll( '\\s+', ''))) ? true : false;
        System.assertEquals(true, checkPhoneNumber);
        // National mobile phone number
        phoneNumber = '348 59 31 214';
        checkPhoneNumber = (FieldValidator.validateFieldValue('National_Mobile_Phone_RegEx', phoneNumber.replaceAll( '\\s+', ''))) ? true : false;
        System.assertEquals(true, checkPhoneNumber);
        // International phone number with country code: +1
        phoneNumber = '+1 214 701 2431';
        checkPhoneNumber = (FieldValidator.validateFieldValue('Generic_Phone_RegEx', phoneNumber.replaceAll( '\\s+', ''))) ? true : false;
        System.assertEquals(true, checkPhoneNumber);
        // International phone number with country code: 001
        phoneNumber = '001 214 701 2431';
        checkPhoneNumber = (FieldValidator.validateFieldValue('Generic_Phone_RegEx', phoneNumber.replaceAll( '\\s+', ''))) ? true : false;
        System.assertEquals(true, checkPhoneNumber);
        
        List<Field_Validator_Setting__mdt> fvs = FieldValidator.getListOfRegularExpressions();
        System.assertEquals(true, !fvs.isEmpty());
        System.assertEquals(false, fvs.isEmpty());
        
    }
     
}