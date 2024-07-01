public with sharing class CIF_Communication_Helper_Edit{

    private static final String dateFormat = 'yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'';

    public static String createJson(Account theNewAccount, Map<String, BOOLEAN> editedFields, Map<String,String> userinfo, Map<String, TelephoneWithPrefix> changedTelephoneFields){
        Map<String, TelephoneWithPrefix> allTelephoneFields = calculateAllTelephoneFields(theNewAccount, editedFields, changedTelephoneFields);
        

        String profile = userinfo.get('profile');
        String username = userinfo.get('username');
        String nickname = userinfo.get('nickname');
        String editinguser = '';

        if(profile == 'AAI - Vendite Avanzato' || profile == 'AAI - Vendite Base'){

            editinguser = nickname;

        }else{

            editinguser = username;
        }

        String recordTypename = [select name from RecordType where id = :theNewAccount.recordtypeid and SobjectType = 'Account'].name;
        JSONGenerator generator = JSON.createGenerator(true);

        //parties
        generator.writeStartObject();
        generator.writeFieldName('parties');
        generator.writeStartArray();
        generator.writeStartObject();

        //Start party
        generator.writeFieldName('party');
        generator.writeStartObject();
        
        //US - 0685
        Boolean isOneClick = editedFields.get('One Click');
        Boolean isFromUnsub = editedFields.containsKey('isFromUnsub');
        if(isOneClick == true){
            // modifica temporanea per permettere gli sviluppi a Pass Anagrafe - Il valore corretto sarà : generator.writeStringField('sourceExternal', ''+'One Click');
            generator.writeStringField('sourceExternal', ''+'One Click');
        } else if(isFromUnsub){
            generator.writeStringField('sourceExternal', ''+'Unsubscribe');
        }
        else {
            generator.writeStringField('sourceExternal', ''+'SFDC');
        }
        if(isOneClick == true){
             // modifica temporanea per permettere gli sviluppi a Pass Anagrafe 'O_C'
            generator.writeStringField('userExternal', 'O_C' + editinguser);
        } else {
            generator.writeStringField('userExternal', ''+editinguser);
        }
        /*String lastModify = '';
        String day = String.valueof(theNewAccount.PersonBirthdate.day());
        if (day.length() ==1){
            day='0'+day;
        }
        String month = String.valueof(theNewAccount.PersonBirthdate.month());
        if (month.length() ==1){
            month='0'+month;
        }
        String year = String.valueof(theNewAccount.PersonBirthdate.year());
        lastModify=''+year+'-'+month+'-'+day;//+'T00:00:00+02:00';*/
        generator.writeStringField('externalUpdateDateTime', ''+system.now().formatGMT(dateFormat));
        //US - 0685
        
        //Job is changed
        Boolean jobCodeChanged = editedFields.get('CIF_Job_code__c');
        if (jobCodeChanged==true){
            String jobCode = '';
            if (theNewAccount.CIF_Job_code__c!= null){
                jobCode = theNewAccount.CIF_Job_code__c;
            }
            generator.writeStringField('occupationCode', ''+jobCode);
        }
        
        //Martial status is changed
        Boolean maritalStatusCodeChanged = editedFields.get('CIF_Marital_Status_code__c');
        if (maritalStatusCodeChanged==true){
            String maritalStatusCode = '';
            if (theNewAccount.CIF_Marital_Status_code__c != null){
                maritalStatusCode = theNewAccount.CIF_Marital_Status_code__c;
            }
            generator.writeStringField('maritalStatus', ''+maritalStatusCode);
        }

        //NDG
        List<String> ndg = new List<String>();
        ndg.add(''+theNewAccount.NDG__c);
        generator.writeObjectField('ndg', ndg);






        //Privacy is changed
        Boolean privacy1changed = editedFields.get('CIF_Privacy_1__c') != null ? editedFields.get('CIF_Privacy_1__c') : false;
        Boolean privacy2changed = editedFields.get('CIF_Privacy_2__c') != null ? editedFields.get('CIF_Privacy_2__c') : false;
        Boolean privacy3changed = editedFields.get('CIF_Privacy_3__c') != null ? editedFields.get('CIF_Privacy_3__c') : false;
        Boolean privacy4changed = editedFields.get('CIF_Privacy_4__c') != null ? editedFields.get('CIF_Privacy_4__c') : false;
        Boolean privacy5changed = editedFields.get('CIF_Privacy_5__c') != null ? editedFields.get('CIF_Privacy_5__c') : false;
        Boolean privacy7changed = editedFields.get('CIF_Privacy_7__c') != null ? editedFields.get('CIF_Privacy_7__c') : false;
        Boolean privacyMailchanged = editedFields.get('CIF_Mail_contact__c') != null ? editedFields.get('CIF_Mail_contact__c') : false;//the email associated to privacy5
        Boolean privacy8changed = editedFields.get('CIF_Privacy_8__c') != null ? editedFields.get('CIF_Privacy_8__c') : false;
        Boolean privacyPhonechanged = editedFields.get('CIF_OTP_Phone_contact__c') != null ? editedFields.get('CIF_OTP_Phone_contact__c') : false; //the Phone contact associated to privacy8
        Boolean hasPrivacyChanged = privacy1changed || privacy2changed || privacy3changed || privacy4changed || privacy5changed || privacy7changed || privacyMailchanged || privacy8changed || privacyPhonechanged;
        if (hasPrivacyChanged) {

            //Privacy definition

            if (privacy1changed) {
                generator.writeBooleanField('operativePrivacy', theNewAccount.CIF_Privacy_1__c == 'Sì');
            }
            if (privacy2changed) {
                generator.writeBooleanField('promotionalPrivacy', theNewAccount.CIF_Privacy_2__c == 'Sì');
            }
            if (privacy3changed) {
                generator.writeBooleanField('marketResearchPrivacy', theNewAccount.CIF_Privacy_3__c == 'Sì');
            }
            if (privacy4changed) {
                generator.writeBooleanField('thirdPartiesPrivacy', theNewAccount.CIF_Privacy_4__c == 'Sì');
            }

            if (privacy5changed){
                generator.writeBooleanField('mailDigitalPrivacy', theNewAccount.CIF_Privacy_5__c == 'Sì');
            }   
            if (privacyMailchanged){
                String privacyMail = ''+theNewAccount.CIF_Mail_contact__c;
                if(privacyMail!='null'){
                    generator.writeStringField('emailDac', privacyMail);
                } else{
                    generator.writeStringField('emailDac', '');
                } 
            }
            if (privacy7changed) {
                generator.writeBooleanField('graphometricSignaturePrivacy', theNewAccount.CIF_Privacy_7__c=='Sì');
            }
            if(privacy8changed){
            generator.writeBooleanField('otpPrivacy', ''+theNewAccount.CIF_Privacy_8__c == 'Sì');
        }

            if (privacyPhonechanged){
                String privacyPhone = ''+theNewAccount.CIF_OTP_Phone_contact__c;
                if(privacyPhone!='null'){
                    generator.writeStringField('telephoneOtp', privacyPhone);
                } else{
                    generator.writeStringField('telephoneOtp', '');
                } 
            }

            //Editing User definition

            if(privacy1changed || privacy2changed || privacy3changed || privacy4changed){

                generator.writeStringField('marketResearchPrivacyUser', editinguser); //FM_ Check e conferma sul mapping del tag 
            }

            if(privacy5changed){

                generator.writeStringField('mailDigitalPrivacyUser', editinguser);
            }

            if(privacy7changed){

                generator.writeStringField('graphometricSignaturePrivacyUser', editinguser);
            }

            if(privacy8changed){

                generator.writeStringField('otpPrivacyUser', editinguser);
            }

            //Editing Date definition

            if(privacy1changed){

                generator.writeStringField('operativePrivacyDate', ''+system.now().formatGMT(dateFormat));
            }

            if(privacy2changed){

                generator.writeStringField('promotionalPrivacyDate', ''+system.now().formatGMT(dateFormat));
            }

            if(privacy3changed){

                generator.writeStringField('marketResearchPrivacyDate', ''+system.now().formatGMT(dateFormat));
            }

            if(privacy4changed){

                generator.writeStringField('thirdPartiesPrivacyDate', ''+system.now().formatGMT(dateFormat));
            }

            if(privacy5changed){

                generator.writeStringField('mailDigitalPrivacyDate', ''+system.now().formatGMT(dateFormat));
            }

            if(privacy7changed){

                generator.writeStringField('graphometricSignaturePrivacyDate', ''+system.now().formatGMT(dateFormat));
            }

            if(privacy8changed){

                generator.writeStringField('aggPrivacyOTP', ''+system.now().formatGMT(dateFormat));
            }
   
        }

        generator.writeEndObject();

        //Phone is changed
        generator = writeTelephoneList(generator, theNewAccount, editedFields, allTelephoneFields);


        //Telematic contact is changed
        generator = writeTelemContactList(generator, theNewAccount, editedFields);   
        generator.writeStringField('companyId', '2'); 


        generator.writeEndObject();
        generator.writeEndArray();
        generator.writeEndObject();

        String result = generator.getAsString();
        System.debug(result);
        return result;
    }

    private static Map<String, TelephoneWithPrefix> calculateAllTelephoneFields(Account theNewAccount, Map<String, BOOLEAN> editedFields, Map<String, TelephoneWithPrefix> changedTelephoneFields) {
        Set<String> fieldsToCheck = new Set<String>();
        if(changedTelephoneFields == null) {
            changedTelephoneFields = new Map<String, TelephoneWithPrefix>();
        }
        /*for(String telephoneField : accountEditLightningCTRL.telephoneFields) {
            if(editedFields.get(telephoneField)) {
                fieldsToCheck.add(telephoneField);
            }
        }*/
        for(String changedTelephoneField : changedTelephoneFields.keySet()) {
            editedFields.put(changedTelephoneField, true);
        }
        Map<String, TelephoneWithPrefix> editedTelephoneFields = TelephoneWithPrefixService.getTelephoneWithPrefixMapForTelephoneFields(accountEditLightningCTRL.telephoneFields, theNewAccount);
        return (Map<String, TelephoneWithPrefix>) UtilsMap.putAllIfNotPresent(editedTelephoneFields, changedTelephoneFields);
    }


    private static JSONGenerator writeTelemContactList(JSONGenerator generator, Account theNewAccount, Map<String, BOOLEAN> editedFields) {
        String personalEmail = '';
        String idContatto_personalEmail = '';
        String oppositionReason = '';
        Boolean opposition = false;
        Boolean personalEmailChanged = false;
        Boolean Omnia_personalEmailChanged = false;
        Boolean Omnia_personalEmail = false;
        Boolean opposition_personalEmailChanged = false; 
        Boolean oppositionReason_personalEmailChanged = false;

        if (theNewAccount.isPersonAccount){
            personalEmail = theNewAccount.CIF_PersonEmail__c == null ? '' : theNewAccount.CIF_PersonEmail__c;
            personalEmailChanged = editedFields.get('CIF_PersonEmail__c');
            idContatto_personalEmail = theNewAccount.CIF_Id_Contatto_PersonEmail__c;
            Omnia_personalEmail = theNewAccount.CIF_Propaga_OMNIA_PersonEmail__c;
            Omnia_personalEmailChanged = editedFields.get('CIF_Propaga_OMNIA_PersonEmail__c');
            oppositionReason = ''+theNewAccount.Motivo_opposizione_Email_Pers_B2C__c;
            opposition = theNewAccount.Flag_Opposizione_Email_Pers_B2C__c;
            opposition_personalEmailChanged = editedFields.get('Flag_Opposizione_Email_Pers_B2C__c');
            oppositionReason_personalEmailChanged = editedFields.get('Motivo_opposizione_Email_Pers_B2C__c');
        } else {
            personalEmail = theNewAccount.CIF_PersonalEmail__c == null ? '' : theNewAccount.CIF_PersonalEmail__c;
            personalEmailChanged = editedFields.get('CIF_PersonalEmail__c');
            idContatto_personalEmail = theNewAccount.CIF_Id_Contatto_PersonalEmail__c;
            Omnia_personalEmail = theNewAccount.CIF_Propaga_OMNIA_Personal_Email__c;
            Omnia_personalEmailChanged = editedFields.get('CIF_Propaga_OMNIA_Personal_Email__c');
            oppositionReason = ''+theNewAccount.Motivo_opposizione_Email_Pers_B2B__c;
            opposition = theNewAccount.Flag_Opposizione_Email_Pers_B2B__c;
            opposition_personalEmailChanged = editedFields.get('Flag_Opposizione_Email_Pers_B2B__c');
            oppositionReason_personalEmailChanged = editedFields.get('Motivo_opposizione_Email_Pers_B2B__c');
        }

        //Personal mail is changed
        generator.writeFieldName('telemContact');
        generator.writeStartArray();
        if(personalEmailChanged == true                 || 
           Omnia_personalEmailChanged == true           ||
           opposition_personalEmailChanged == true      ||
           oppositionReason_personalEmailChanged == true) {  

            generator.writeStartObject();
            generator.writeStringField('contactType', '1');
            generator.writeStringField('text', personalEmail);
            if(idContatto_personalEmail != null && idContatto_personalEmail != '' && idContatto_personalEmail != 'null'){
                generator.writeStringField('contactId', idContatto_personalEmail);
            } 
            generator.writeBooleanField('propagaOmniaindicator', Omnia_personalEmail);
            //US - 0690
            generator.writeBooleanField('opposition', opposition);
            if(oppositionReason != null && oppositionReason != '' && oppositionReason != 'null'){
                generator.writeStringField('oppositionReason', oppositionReason);
            }
            //US - 0690
            generator.writeEndObject(); 
        }

        //Work mail is changed
        Boolean workEmailChanged = editedFields.get('CIF_Work_email__c');        
        Boolean Omnia_workEmailChanged = editedFields.get('CIF_Propaga_OMNIA_Work_Email__c');
        Boolean opposition_workEmailChanged = editedFields.get('Flag_Opposizione_Email_Uff__c');
        Boolean oppositionReason_workEmailChanged = editedFields.get('Motivo_opposizione_Email_Uff__c');

        if(workEmailChanged == true                  || 
            Omnia_workEmailChanged == true           ||
            opposition_workEmailChanged == true      ||
            oppositionReason_workEmailChanged == true){   

            String idContatto_workEmail = ''+theNewAccount.CIF_Id_Contatto_WorkEmail__c;
            generator.writeStartObject();
            generator.writeStringField('contactType', '32');
            generator.writeStringField('text', ''+theNewAccount.CIF_Work_email__c);
            if(idContatto_workEmail != null && idContatto_workEmail != '' && idContatto_workEmail != 'null'){
                generator.writeStringField('contactId', idContatto_workEmail);
            }  
            generator.writeBooleanField('propagaOmniaindicator', theNewAccount.CIF_Propaga_OMNIA_Work_Email__c);
            //US - 0690
            generator.writeBooleanField('opposition', theNewAccount.Flag_Opposizione_Email_Uff__c);

            String oppositionReasonEmailUff = ''+theNewAccount.Motivo_opposizione_Email_Uff__c;
            if(oppositionReasonEmailUff != null && oppositionReasonEmailUff != '' && oppositionReasonEmailUff != 'null'){
                generator.writeStringField('oppositionReason', oppositionReasonEmailUff);
            }
            //US - 0690
            generator.writeEndObject(); 
        }
        generator.writeEndArray();

        return generator;
    }
    private static JSONGenerator writeTelephoneList(JSONGenerator generator, Account theNewAccount, Map<String, BOOLEAN> editedFields, Map<String, TelephoneWithPrefix> allTelephoneFields) {
        
        String mobilePhone = '';
        String idContatto_mobilePhone = '';
        String mobilePhonePrefix = '';
        String oppositionReason = '';
        Boolean mobileChanged = false;        
        Boolean Omnia_mobileChanged = false;        
        Boolean Omnia_mobilePhone = false;       
        Boolean opposition = false;
        Boolean opposition_mobileChanged = false; 
        Boolean oppositionReason_mobileChanged = false; 


        if (theNewAccount.isPersonAccount){
            mobilePhone = allTelephoneFields?.get('CIF_PersonMobilePhone__c')?.telephoneNumber;
            mobilePhonePrefix = allTelephoneFields?.get('CIF_PersonMobilePhone__c')?.getPrefix();
            mobileChanged = editedFields.get('CIF_PersonMobilePhone__c');
            idContatto_mobilePhone = theNewAccount.CIF_Id_Contatto_PersonMobilePhone__c;
            //Omnia_mobilePhone = theNewAccount.CIF_Propaga_OMNIA_PersonMobilePhone__c;
            //Omnia_mobileChanged = editedFields.get('CIF_Propaga_OMNIA_PersonMobilePhone__c');
            oppositionReason = ''+theNewAccount.Motivo_opposizione_Tel_Cell_B2C__c;
            opposition = theNewAccount.Flag_Opposizione_Tel_Cell_B2C__c;
            opposition_mobileChanged = editedFields.get('Flag_Opposizione_Tel_Cell_B2C__c');
            oppositionReason_mobileChanged = editedFields.get('Motivo_opposizione_Tel_Cell_B2C__c');
        } else {
            mobilePhone = allTelephoneFields?.get('CIF_MobilePhone__c')?.telephoneNumber;
            mobilePhonePrefix = allTelephoneFields?.get('CIF_MobilePhone__c')?.getPrefix();
            mobileChanged = editedFields.get('CIF_MobilePhone__c');
            idContatto_mobilePhone = theNewAccount.CIF_Id_Contatto_MobilePhone__c;
            //Omnia_mobilePhone = theNewAccount.CIF_Propaga_OMNIA_Mobile_Phone__c;
            //Omnia_mobileChanged = editedFields.get('CIF_Propaga_OMNIA_Mobile_Phone__c');
            oppositionReason = ''+theNewAccount.Motivo_opposizione_Tel_Cell_B2B__c;
            opposition = theNewAccount.Flag_Opposizione_Tel_Cell_B2B__c;
            opposition_mobileChanged = editedFields.get('Flag_Opposizione_Tel_Cell_B2B__c');
            oppositionReason_mobileChanged = editedFields.get('Motivo_opposizione_Tel_Cell_B2B__c');
        }

        //Start telephone
        generator.writeFieldName('telephone');
        generator.writeStartArray();

        //Main phone changed
        Boolean phoneChanged = editedFields.get('CIF_Phone__c');
        Boolean Omnia_phoneChanged = false;//editedFields.get('CIF_Propaga_OMNIA_Phone__c');
        Boolean opposition_phoneChanged = editedFields.get('Flag_Opposizione_Tel_Princ__c');
        Boolean oppositionReason_phoneChanged = editedFields.get('Motivo_opposizione_Tel_Princ__c');

        if (phoneChanged==true                 || 
            Omnia_phoneChanged==true           ||
            opposition_phoneChanged==true      ||
            oppositionReason_phoneChanged==true){

            String idContatto_mainPhone = ''+theNewAccount.CIF_Id_Contatto_Phone__c;
            System.debug('idContatto Main Phone: ' + idContatto_mainPhone);
            
            generator.writeStartObject();
            generator.writeStringField('number', ''+allTelephoneFields?.get('CIF_Phone__c')?.telephoneNumber);
            generator.writeStringField('internationalPrefix', ''+allTelephoneFields?.get('CIF_Phone__c')?.getPrefix());
            generator.writeStringField('telephoneType', '1');
            if(idContatto_mainPhone != null && idContatto_mainPhone != '' && idContatto_mainPhone != 'null'){
                generator.writeStringField('contactId', idContatto_mainPhone);
            } 
            generator.writeBooleanField('propagaOmnia', theNewAccount.CIF_Propaga_OMNIA_Phone__c);
            //US - 0690
            generator.writeBooleanField('opposition', theNewAccount.Flag_Opposizione_Tel_Princ__c);
            String oppositionReasonTelPrinc = ''+theNewAccount.Motivo_opposizione_Tel_Princ__c;
            if(oppositionReasonTelPrinc != null && oppositionReasonTelPrinc != '' && oppositionReasonTelPrinc != 'null'){
                generator.writeStringField('oppositionReason', oppositionReasonTelPrinc);
            }
            //US - 0690
            generator.writeEndObject();   
        }

        //Mobile phone changed
        if (mobileChanged==true                 || 
            Omnia_mobileChanged==true           ||
            opposition_mobileChanged==true      ||
            oppositionReason_mobileChanged==true){
            generator.writeStartObject();
            generator.writeStringField('number', mobilePhone);
            if(mobilePhonePrefix!=null && mobilePhonePrefix!=''&& mobilePhonePrefix!='null'){
            generator.writeStringField('internationalPrefix', mobilePhonePrefix);
        }
            generator.writeStringField('telephoneType', '2');
            if(idContatto_mobilePhone != null && idContatto_mobilePhone != '' && idContatto_mobilePhone != 'null'){
                generator.writeStringField('contactId', idContatto_mobilePhone);
            }  
            generator.writeBooleanField('propagaOmnia', Omnia_mobilePhone);
            //US - 0690
            generator.writeBooleanField('opposition', opposition);
            if(oppositionReason != null && oppositionReason != '' && oppositionReason != 'null'){
                generator.writeStringField('oppositionReason', oppositionReason);
            }
            //US - 0690
            generator.writeEndObject();   
        }

        //Fax changed
        Boolean faxChanged = editedFields.get('Fax');
        Boolean Omnia_faxChanged = editedFields.get('CIF_Propaga_OMNIA_Fax__c');
        Boolean opposition_FaxChanged = editedFields.get('Flag_Opposizione_Fax__c');
        Boolean oppositionReason_FaxChanged = editedFields.get('Motivo_opposizione_Fax__c');

        if (faxChanged == true               || 
            Omnia_faxChanged == true         ||
            opposition_FaxChanged == true    ||
            oppositionReason_FaxChanged==true){
            String idContatto_Fax = ''+theNewAccount.CIF_Id_Contatto_Fax__c;            
            generator.writeStartObject();
            generator.writeStringField('number', '' + allTelephoneFields?.get('Fax')?.telephoneNumber);
            generator.writeStringField('internationalPrefix', ''+allTelephoneFields?.get('Fax')?.getPrefix());
            generator.writeStringField('telephoneType', '4');
            if(idContatto_Fax != null && idContatto_Fax != '' && idContatto_Fax != 'null'){
                generator.writeStringField('contactId', idContatto_Fax);
            } 
            generator.writeBooleanField('propagaOmnia', theNewAccount.CIF_Propaga_OMNIA_Fax__c);
            //US - 0690
            generator.writeBooleanField('opposition', theNewAccount.Flag_Opposizione_Fax__c);
            String oppositionReasonFax = ''+theNewAccount.Motivo_opposizione_Fax__c;
            if(oppositionReasonFax != null && oppositionReasonFax != '' && oppositionReasonFax != 'null'){
                generator.writeStringField('oppositionReason', oppositionReasonFax);
            }
            //US - 0690
            generator.writeEndObject();   
        }

        //Work phone changed
        Boolean workPhoneChanged = editedFields.get('CIF_Work_phone__c');
        Boolean Omnia_workPhoneChanged = editedFields.get('CIF_Propaga_OMNIA_Work_Phone__c');
        Boolean opposition_workPhoneChanged = editedFields.get('Flag_Opposizione_Tel_Uff__c');
        Boolean oppositionReason_workPhoneChanged = editedFields.get('Motivo_opposizione_Tel_Uff__c');

        if (workPhoneChanged==true                 || 
            Omnia_workPhoneChanged == true         ||
            opposition_workPhoneChanged==true      ||
            oppositionReason_workPhoneChanged==true){

            String idContatto_workPhone = ''+theNewAccount.CIF_Id_Contatto_WorkPhone__c;
            generator.writeStartObject();
            generator.writeStringField('number', ''+allTelephoneFields?.get('CIF_Work_phone__c')?.telephoneNumber);
            generator.writeStringField('internationalPrefix', ''+allTelephoneFields?.get('CIF_Work_phone__c')?.getPrefix());
            generator.writeStringField('telephoneType', '8');
            if(idContatto_workPhone != null && idContatto_workPhone != '' && idContatto_workPhone != 'null'){
                generator.writeStringField('contactId', idContatto_workPhone);
            }  
            generator.writeBooleanField('propagaOmnia', theNewAccount.CIF_Propaga_OMNIA_Work_Phone__c);
            //US - 0690
            generator.writeBooleanField('opposition', theNewAccount.Flag_Opposizione_Tel_Uff__c);
            String oppositionReasonTelUff = ''+theNewAccount.Motivo_opposizione_Tel_Uff__c;
            if(oppositionReasonTelUff != null && oppositionReasonTelUff != '' && oppositionReasonTelUff != 'null'){
                generator.writeStringField('oppositionReason', oppositionReasonTelUff);
            }
            //US - 0690
            generator.writeEndObject();   
        }       

        generator.writeEndArray();

        return generator;
    }


    private static String createDate(Account theNewAccount){
        string day = String.valueof(theNewAccount.PersonBirthdate.day());
        if (day.length() ==1){
            day='0'+day;
        }
        string month = String.valueof(theNewAccount.PersonBirthdate.month());
        if (month.length() ==1){
            month='0'+month;
        }
        string year = String.valueof(theNewAccount.PersonBirthdate.year());
        return ''+year+'-'+month+'-'+day + 'T00:00:00.000Z';
    }
}