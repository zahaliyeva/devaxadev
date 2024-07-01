public with sharing class SchedaClienteController {

    private static final List<String> RECORD_TYPE_DEVELOPER_NAMES_AAI = new List<String>{
        'B2B_Client',
        'B2C_Client'
    };
    private static final List<String> RECORD_TYPE_DEVELOPER_NAMES_PERSON = new List<String>{
        'Client',
        'AAF_B2C',
        'B2C_Client'
        
    }; 
    
    public class Wrapper {
        @AuraEnabled
        public String profile = [SELECT Id, Name FROM Profile WHERE Id=:Userinfo.getProfileId() LIMIT 1].get(0).Name;
        @AuraEnabled
        public Account account;
        @AuraEnabled 
        public Integer customerPrivateAreaAccessCounter;
        @AuraEnabled
        public Boolean isAAI;
        @AuraEnabled
        public Boolean isMPS;
        @AuraEnabled
        public Boolean isQuadra;
        @AuraEnabled
        public Boolean isAMAV;
        @AuraEnabled
        public Boolean isAMAD;
        @AuraEnabled
        public Boolean isPerson;
        @AuraEnabled
        public Boolean canEditAccount;
        @AuraEnabled
        public String companyName;
        @AuraEnabled
        public String errorMessage;
        @AuraEnabled
        public String schedaClienteType;
        @AuraEnabled
        public String schedaClientePolizzaType;
		@AuraEnabled
        public List<String> processList;
        @AuraEnabled
        public boolean showResetModal = (AAI_Code_Variables__c.getAll()).get('showResetModal') != null ? (Boolean.ValueOf((AAI_Code_Variables__c.getAll()).get('showResetModal').Value__c)) : false;
    }
    
    
    @AuraEnabled
    public static Wrapper getWrapper(String accountId) {
        Wrapper wrapper = new Wrapper();
        List<Account> accounts = getAccount(accountId);

        String schedaClienteType = getSchedaClienteType(accounts?.get(0));

        if(schedaClienteType == AP_Constants.SCHEDACLIENTE_TYPE_NEW) {
            return getWrapperNew(accountId, accounts);
        }

        return getWrapperOld(accountId, accounts);
        
    }

    private static Wrapper getWrapperNew(String accountId, List<Account> accounts) {
        Wrapper wrapper = new Wrapper();
        try {
            SObjectAccessDecision decision = Security.stripInaccessible(
                AccessType.READABLE,
                accounts
            );
            Account accountNotStripped = accounts?.get(0);
            Account account = (Account) decision.getRecords().get(0);
            String companyName = getCompanyName(accountNotStripped);
            wrapper.account = account;
            wrapper.processList = getProcessList(account);
            wrapper.isAAI = isAAI(accountNotStripped);
            wrapper.isMPS = isMPS(companyName);
            wrapper.isPerson = isPerson(accountNotStripped);
            wrapper.isQuadra = wrapper.isMPS ? accountNotStripped.Flag_Fonte_Quadra__c == AP_Constants.FLAG_SI : false;
            wrapper.isAMAV   = wrapper.isMPS ? accountNotStripped.Flag_Fonte_AMAV__c   == AP_Constants.FLAG_SI : false;
            wrapper.isAMAD   = wrapper.isMPS ? accountNotStripped.Flag_Fonte_AMAD__c   == AP_Constants.FLAG_SI : false;
            wrapper.companyName = companyName;
            wrapper.customerPrivateAreaAccessCounter = getCustomerPrivateAreaAccessCounter(accountNotStripped);
            wrapper.canEditAccount = canEditAccount(wrapper.profile);
            wrapper.schedaClienteType = AP_Constants.SCHEDACLIENTE_TYPE_NEW;
            wrapper.schedaClientePolizzaType = getSchedaClientePolizzaType(AP_Constants.SCHEDACLIENTE_TYPE_NEW);
        } catch(Exception ex){
            wrapper.errorMessage = ex.getMessage() + ': ' + ex.getStackTraceString();
        } 
        return wrapper;
    }

    private static Wrapper getWrapperOld(String accountId, List<Account> accounts) {
        Wrapper wrapper = new Wrapper();
        try {
            SObjectAccessDecision decision = Security.stripInaccessible(
                AccessType.READABLE,
                accounts
            );
            Account accountNotStripped = accounts?.get(0);
            Account account = (Account) decision.getRecords().get(0);
            String companyName = getCompanyNameOld(accountNotStripped);
            wrapper.account = account;
            wrapper.processList = getProcessList(account);
            wrapper.isAAI = isAAI(accountNotStripped);
            wrapper.isMPS = isMPS(companyName);
            wrapper.isPerson = isPerson(accountNotStripped);
            wrapper.companyName = companyName;
            wrapper.customerPrivateAreaAccessCounter = getCustomerPrivateAreaAccessCounter(accountNotStripped);
            wrapper.canEditAccount = canEditAccount(wrapper.profile);
            wrapper.schedaClienteType = AP_Constants.SCHEDACLIENTE_TYPE_OLD;
            wrapper.schedaClientePolizzaType = getSchedaClientePolizzaType(AP_Constants.SCHEDACLIENTE_TYPE_OLD);
        } catch(Exception ex){
            wrapper.errorMessage = ex.getMessage() + ': ' + ex.getStackTraceString();
        } 
        return wrapper;
    }
    private static List<String> getProcessList(Account account) {
        if(Schema.sObjectType.Account.fields.Blacklist_Processi__c.isAccessible() && account?.Blacklist_Processi__c != null) {
           return account.Blacklist_Processi__c.split(';');
        }
        
        return new List<String>();
    }

    private static Boolean isPerson(Account account){
        return RECORD_TYPE_DEVELOPER_NAMES_PERSON.contains(account.RecordType.DeveloperName);
    }

    private static Boolean isAAI(Account account){
        return RECORD_TYPE_DEVELOPER_NAMES_AAI.contains(account.RecordType.DeveloperName);
    }

    private static Boolean isMPS(String companyName){
        return 'AXA MPS'.equalsIgnoreCase(companyName);
    }


    private static Boolean canEditAccount(String profileName){
        return Schema.sObjectType.Account.isUpdateable();
    }

    private static String getCompanyName(Account account){


        FilterValuesService filterValueService = new FilterValuesService('SchedaClienteAccount');
        filterValueService.filterBySObject('Account').filterByField('TECH_Company__c');

        if(account.TECH_Company__c == filterValueService.getValueByKey(AP_Constants.TECHCompany_AAI)) {
            if(String.isNotBlank(account.Nodes__c) && ((String)account.Nodes__c).contains(AP_Constants.ING_NODE)){
                return filterValueService.getValueByKey(AP_Constants.TECHCompany_ING);
            }
            else if(String.isNotBlank(account.Nodes__c) && ((String)account.Nodes__c).contains(AP_Constants.RCI_NODE)) {
                return filterValueService.getValueByKey(AP_Constants.TECHCompany_RCI);
            } else {
                return filterValueService.getValueByKey(AP_Constants.TECHCompany_AAIDefault);
            }
        }

        if(filterValueService.getValueByKey(account.TECH_Company__c) != null) {
            return filterValueService.getValueByKey(account.TECH_Company__c);
        }


        throw new IllegalArgumentException('Compagnia non supportata');



        /*switch on account.TECH_Company__c {




             when 'MPS', 'AXA MPS', 'AXA MPS ASSICURAZIONI DANNI'{
                return 'AXA MPS';
            } when 'AAF'{
                return 'AAF';
            } when 'AMF'{
                return 'AMF';
            } when 'AAI'{
                if(String.isNotBlank(account.Nodes__c) && ((String)account.Nodes__c).contains('001040')){
                    return 'ING';
                }
                else if(String.isNotBlank(account.Nodes__c) && ((String)account.Nodes__c).contains('000728')) {
                    return 'RCI';
                }
                else {
                    return 'AXA Assicurazioni';
                }
            }
            when else {
                throw new IllegalArgumentException('Compagnia non supportata');
            }
        }*/
    } 

    private static String getCompanyNameOld(Account account){
        switch on account.TECH_Company__c {
            when 'AXA QUADRA ASSICURAZIONI DANNI'{
                return 'Quadra';
            } when 'MPS', 'AXA MPS', 'AXA MPS ASSICURAZIONI DANNI'{
                return 'AXA MPS';
            } when 'AAF'{
                return 'AAF';
            } when 'AMF'{
                return 'AMF';
            } when 'AAI'{
                if(String.isNotBlank(account.Nodes__c) && ((String)account.Nodes__c).contains('001040')){
                    return 'ING';
                }
                else if(String.isNotBlank(account.Nodes__c) && ((String)account.Nodes__c).contains('000729')) {
                    return 'RCI';
                }
                else {
                    return 'AXA Assicurazioni';
                }
            }
            when else {
                throw new IllegalArgumentException('Compagnia non supportata');
            }
        }
    } 

    private static Integer getCustomerPrivateAreaAccessCounter(Account account){
        return Database.countQuery('SELECT COUNT() FROM Customer_event__c WHERE Timestamp__c = LAST_N_DAYS:30 AND Source_System__c = \'PCC/MyAxa\' AND Result__c =\'OK\' AND Account__c =\'' + account.Id + '\'');
    }

    private static String getSchedaClienteType(Account account) {
        TransitorySettings__c transitorySetting = TransitorySettings__c.getInstance();
        if(transitorySetting?.SchedaClienteAccount__c == AP_Constants.TRANSITORYSETTING_FORCED_NEW) {
            return AP_Constants.SCHEDACLIENTE_TYPE_NEW;
        }

        if(transitorySetting?.SchedaClienteAccount__c == AP_Constants.TRANSITORYSETTING_FORCED_OLD) {
            return AP_Constants.SCHEDACLIENTE_TYPE_OLD; 
        }

        FilterValuesService filterValueService = new FilterValuesService('SchedaClienteAccount');

        Set<String> getNewSchedaClienteTechWorkflows = filterValueService.filterBySObject('Account').filterByField('TECH_WorkFlow_ETL__c').getValuesAndReset();

        if(getNewSchedaClienteTechWorkflows?.contains(account?.TECH_WorkFlow_ETL__c)) {
            return AP_Constants.SCHEDACLIENTE_TYPE_NEW;
        } 
        
        return AP_Constants.SCHEDACLIENTE_TYPE_OLD;

    }

    private static String getSchedaClientePolizzaType(String schedaClienteAccountType) {
        TransitorySettings__c transitorySetting = TransitorySettings__c.getInstance(); 

        if(String.isBlank(transitorySetting?.SchedaClienteInsurancePolicy__c)) {
            return AP_Constants.TRANSITORYSETTING_FIELD_BASED;
        }

        if(transitorySetting.SchedaClienteInsurancePolicy__c == AP_Constants.TRANSITORYSETTING_ACCOUNT_BASED) {
            return schedaClienteAccountType;
        }
        
        return transitorySetting?.SchedaClienteInsurancePolicy__c;
    }


    private static List<Account> getAccount(String accountId) {
        return [SELECT RecordType.DeveloperName, Id, Name, LastName, Ccittadinanza__c,Cdesc_Titolo_Studio__c,Cdesc_Forma_Societaria__c, 
        Bcert_Privacy_1_Ndg_AAI__c, Bcert_Privacy_2_Ndg_AAI__c, Bcert_Privacy_3_Ndg_AAI__c, Bcert_Privacy_4_Ndg_AAI__c, Bcert_Privacy_Email_Ndg_AAI__c, 
        Bcert_Privacy_Firma_Ndg_AAI__c, Bcert_Privacy_Otp_Ndg_AAI__c, Bcert_Privacy_Profilazione_Ndg_AAI__c,
        Cprivacy_1_LE_AAI_QUADRA__c,Cprivacy_2_LE_AAI_QUADRA__c,Cprivacy_3_LE_AAI_QUADRA__c,Cprivacy_4_LE_AAI_QUADRA__c,Cprivacy_1_LE_AMAV__c,Cprivacy_2_LE_AMAV__c,
        Cprivacy_3_LE_AMAV__c,Cprivacy_4_LE_AMAV__c,Cprivacy_1_LE_AMAD__c,Cprivacy_2_LE_AMAD__c,Cprivacy_3_LE_AMAD__c,Cprivacy_4_LE_AMAD__c,
        Bcert_Privacy_1_LE_AAI_QUADRA__c,Bcert_Privacy_2_LE_AAI_QUADRA__c,Bcert_Privacy_3_LE_AAI_QUADRA__c,Bcert_Privacy_4_LE_AAI_QUADRA__c,
        Bcert_Privacy_1_LE_AMAV__c,Bcert_Privacy_2_LE_AMAV__c,Bcert_Privacy_3_LE_AMAV__c,Bcert_Privacy_4_LE_AMAV__c,Bcert_Privacy_1_LE_AMAD__c,
        Bcert_Privacy_2_LE_AMAD__c,Bcert_Privacy_3_LE_AMAD__c,Bcert_Privacy_4_LE_AMAD__c, Blacklist_Processi__c,
        Cdesc_Settore_Attivita__c, Cdesc_Codice_Ateco__c, Cdesc_Dipendenti__c, Cdesc_Fatturato__c, FirstName,Mobile_Master_AAI__c, Email_Master_AAI__c, 
        Mobile_Master_AMAD__c, Mobile_Master_AMAV__c, Mobile_Master_QUADRA__c, Mobile_Recente_1_AAI__c, Mobile_Recente_2_AAI__c, Mobile_Recente_3_AAI__c,
        Email_Master_AMAV__c, Email_Master_AMAD__c, Email_Master_QUADRA__c, Email_Recente_1_AAI__c, Email_Recente_2_AAI__c, Email_Recente_3_AAI__c,
        Cprivacy_Profilazione_Ndg_AAI__c, Flag_Fonte_Quadra__c, Flag_Fonte_AMAV__c, Flag_Fonte_AMAD__c, Salutation, Type, RecordTypeId, ParentId, 
        BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingStateCode, BillingCountryCode, BillingLatitude, BillingLongitude, 
        BillingGeocodeAccuracy, BillingAddress, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry, ShippingStateCode, ShippingCountryCode, 
        ShippingLatitude, ShippingLongitude, ShippingGeocodeAccuracy, ShippingAddress, Phone, Fax, AccountNumber, Website, PhotoUrl, Sic, Industry, AnnualRevenue, NumberOfEmployees, 
        Ownership, TickerSymbol, Description, Rating, Site, OwnerId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, LastViewedDate, 
        LastReferencedDate, IsPartner, PersonContactId, IsPersonAccount, ChannelProgramName, ChannelProgramLevelName, PersonMailingStreet, PersonMailingCity, PersonMailingState, 
        PersonMailingPostalCode, PersonMailingCountry, PersonMailingStateCode, PersonMailingCountryCode, PersonMailingLatitude, PersonMailingLongitude, PersonMailingGeocodeAccuracy, 
        PersonMailingAddress, PersonOtherStreet, PersonOtherCity, PersonOtherState, PersonOtherPostalCode, PersonOtherCountry, PersonOtherStateCode, PersonOtherCountryCode, 
        PersonOtherLatitude, PersonOtherLongitude, PersonOtherGeocodeAccuracy, PersonOtherAddress, PersonMobilePhone, PersonHomePhone, PersonOtherPhone, PersonAssistantPhone, 
        PersonEmail, PersonTitle, PersonDepartment, PersonAssistantName, PersonLeadSource, PersonBirthdate, PersonHasOptedOutOfEmail, PersonHasOptedOutOfFax, PersonDoNotCall, 
        PersonLastCURequestDate, PersonLastCUUpdateDate, PersonEmailBouncedReason, PersonEmailBouncedDate, PersonIndividualId, Jigsaw, JigsawCompanyId, AccountSource, SicDesc, 
        Account_email__c, TECH_Company__c, Tech_Flag__c, Partita_IVA__c, AAI_Agency_Reference_Code__c, AAI_Agency__c, AAI_Codice_fiscale__c, AAI_Partita_IVA__c, Active__c, Age__c, 
        Agency_Code__c, Agency_Holder__c, Agency_email__c, Agency_isActive__c, Matricola__c, City_Search__c, Client_Index__c, Department_Chief_Description_Code__c, 
        First_expiration_date__c, First_policy_subscription_date__c, Gender__c, Head_Office_Address__c, Industrial_privacy__c, Is_duplicate__c, Fiscal_ID__c, MobilePhone__c, 
        Market_research_privacy__c, NDG_Vincente__c, NDG__c, Nodes__c, Nodes_tree__c, Place_of_birth__c, Profession__c, Promotional_privacy__c, RSAC_Description_Code__c, 
        RSA_Description_Code__c, Sales_Volume__c, Segment__c, Segment_for_industry__c, Segment_for_number_of_employers__c, Special_privacy__c, State__c, Subject_email__c, 
        TECH_Lead_birthdate__c, TECH_Nominee_Birthdate__c, Third_party_transfer_privacy__c, AXA_MPS_Codice_Filiale__c, AXA_MPS_Descrizione_Filiale__c, Servizio__c, Active_Campaigns__c, 
        Active_Insurance_Contracts__c, Notes__c, Net_Promoter_Score_NPS__c, Additional_Comments__c, Additional_Phone__c, Additional_Email__c, TECH_CIF_status__c, Registered_on_PCC__c, 
        Updated_by_ETL__c, TECH_DeduplicationKey__c, Bank_Service_Model__c, TECH_Batch_Visibility__c, Codice_Fiscale_AAF__c, BlackList_Abitazione__c, City_Search2__c, Client_Index_Image__c, 
        Client_Index_Letter__c, Email_Search__c, Fiscal_ID_Search__c, Assurbanking__c, CIF_Job__c, CIF_Job_code__c, CIF_Marital_Status__c, CIF_Marital_status_code__c, 
        CIF_MobilePhone_IntPrefix__c, CIF_MobilePhone__c, CIF_PersonEmail__c, CIF_PersonMobilePhone_IntPrefix__c, CIF_PersonMobilePhone__c, CIF_Personalemail__c, CIF_Phone_IntPrefix__c, 
        CIF_Phone__c, CIF_Work_email__c, CIF_Work_phone_IntPrefix__c, CIF_Work_phone__c, Codice_canale_commerciale__c, Data_inizio_assurbanking__c, Descrizione_canale_commerciale__c,
        Fax_IntPrefix__c, Claim_PersonalEmail__c, Claim_PersonalMobile__c, Provincia_di_nascita__c, BlackList_Auto__c, BlackList_Aziende__c, BlackList_Commerciale__c, BlackList_Infortuni__c,
        BlackList_Malattia__c, BlackList_Protection__c, BlackList_Rinnovo__c, BlackList_Saving__c, BlackList_Servizio__c, Tutte_le_tipologie__c, Tutti_i_prodotti__c, 
        Ultima_modifica_blacklist__c, Sistema_fonte__c, Ultima_modifica_blacklist_giorno__c, CIF_Document_type__c, CIF_Expiry_date__c, CIF_Mail_contact__c, CIF_Number__c, 
        Comunicazioni_informative__c, CIF_Privacy_1__c, CIF_Privacy_2__c, CIF_Privacy_3__c, CIF_Privacy_4__c, CIF_Privacy_5__c, CIF_Privacy_7__c, CIF_Id_Contatto_Fax__c, 
        CIF_Id_Contatto_MobilePhone__c, CIF_Id_Contatto_PersonEmail__c, CIF_Id_Contatto_PersonMobilePhone__c, CIF_Id_Contatto_PersonalEmail__c, CIF_Id_Contatto_Phone__c, 
        CIF_Id_Contatto_WorkEmail__c, CIF_Id_Contatto_WorkPhone__c, CIF_Propaga_OMNIA_Fax__c, CIF_Propaga_OMNIA_Mobile_Phone__c, CIF_Propaga_OMNIA_PersonEmail__c, 
        CIF_Propaga_OMNIA_PersonMobilePhone__c, CIF_Propaga_OMNIA_Personal_Email__c, CIF_Propaga_OMNIA_Phone__c, CIF_Propaga_OMNIA_Work_Email__c, CIF_Propaga_OMNIA_Work_Phone__c, 
        Codice_fiscale_ListView__c, Email_ListView__c, Telefono_cellulare_ListView__c, Telefono_principale_ListView__c, Accordo_Digitale__c, Data_ora_modifica__c, 
        DAOL_2_0__c, NPS__c, Last_Private_Area_Access__c, Flag_registrazione_area_privata__c, Mail_Registrazione_Area_Clienti__c, Motivo_opposizione_Email_Pers_B2B__c, 
        Motivo_opposizione_Email_Pers_B2C__c, Motivo_opposizione_Email_Uff__c, Motivo_opposizione_Fax__c, Motivo_opposizione_Tel_Cell_B2B__c, Motivo_opposizione_Tel_Cell_B2C__c, 
        Motivo_opposizione_Tel_Princ__c, Motivo_opposizione_Tel_Uff__c, Sorgente__c, Utente_modifica__c, TECH_WorkFlow_ETL__c, MC_MainEmail__c, MC_MainPhone__c, BlackList_Broker__c, 
        Onboarding_Products__c, CIF_Commercial_Last_Modified_Date__c, CIF_Commercial_Last_Modified_System__c, CIF_Commercial_Last_Modified_by__c, CIF_Firma_Last_Modified_Date__c, 
        CIF_Firma_Last_Modified_System__c, CIF_Firma_Last_Modified_by__c, CIF_Mail_Last_Modified_Date__c, CIF_Mail_Last_Modified_System__c, CIF_Mail_Last_Modified_by__c, 
        CIF_OTP_Last_Modified_Date__c, CIF_OTP_Last_Modified_System__c, CIF_OTP_Last_Modified_by__c, CIF_OTP_Phone_contact__c, CIF_Privacy_8__c, Flag_Opposizione_Email_Pers_B2B__c, 
        Flag_Opposizione_Email_Pers_B2C__c, Flag_Opposizione_Email_Uff__c, Flag_Opposizione_Fax__c, Flag_Opposizione_Tel_Cell_B2B__c, Flag_Opposizione_Tel_Cell_B2C__c, 
        Flag_Opposizione_Tel_Princ__c, Flag_Opposizione_Tel_Uff__c, Check_Contacts_Validity__c, Check_Contacts_Validity_code__c, Check_Special_Char_in_Contact_Code__c, 
        Check_Special_Char_in_Contact__c, DataDeletion__c, Migrato_a_PA__c, DIF_Event_New_NDG__c, DIF_Event_Timestamp__c, Destinatario_notifica_Feedback_Case__c, Contatto_tecnico__pc, 
        CLTSEX__pc, Lotto__pc, TECH_NDG__pc, et4ae5__HasOptedOutOfMobile__pc, et4ae5__Mobile_Country_Code__pc, TECH_WorkFlow_ETL__pc, CAB__pc, Bank_Name__pc, AAI_Agency__r.Agency_Code__c, 
        AAI_Agency__r.Name, AAI_Agency__r.Head_Office_Address__c, AAI_Agency__r.Agency_email__c, AAI_Agency__r.Phone  from Account where Id =:accountId];
    }

}