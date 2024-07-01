global with sharing class PassAnagrafeInvocable {

    private static final String PASSANAGRAFE_UPDATED_OK = 'PassAnagrafe Updated OK';
    private static final String PASSANAGRAFE_UPDATED_KO = 'PassAnagrafe Updated KO';
    private static final String PASSANAGRAFE_FULL_SEARCH_KO = 'PassAnagrafe FullSearch KO';
    private static final String PASSANAGRAFE_UPDATED_NOT_NECESSARY = 'PassAnagrafe Update Not Necessary';
    private static final String PRIVACY_MODIFICATION_DATES_OUT_OF_RANGE = 'Privacy Modification Dates Out Of Range';
    
    @InvocableMethod
    public static void callPassAnagrafe(List<Communications_to_customer__c> communicationsToCustomer){
        for(Communications_to_customer__c communicationToCustomer: communicationsToCustomer){
            handleCallout(communicationToCustomer.Id);
        }
    }

    @Future(callout=true)
    public static void handleCallout(Id communicationToCustomerId){
            Communications_to_customer__c communicationToCustomer = [SELECT Id, Send_Date__c, AccountId__c, CIF_Privacy_5__c, CIF_Mail_contact__c, CallPassAnagrafe__c from Communications_to_customer__c where Id = :communicationToCustomerId];
            Account account = [SELECT Id, isPersonAccount, NDG__c, RecordTypeId, AAI_Agency__r.Agency_email__c, CIF_Privacy_1__c,CIF_Privacy_2__c,CIF_Privacy_3__c,CIF_Privacy_4__c,CIF_Privacy_5__c,CIF_Privacy_7__c,CIF_Mail_contact__c,CIF_Privacy_8__c,CIF_OTP_Phone_contact__c, 
                CIF_MobilePhone_IntPrefix__c,CIF_PersonMobilePhone_IntPrefix__c,CIF_Phone_IntPrefix__c,CIF_Work_phone_IntPrefix__c,Fax_IntPrefix__c,Fax,CIF_Job_code__c, CIF_Marital_Status_code__c, CIF_Work_phone__c,CIF_Work_email__c,CIF_PersonalEmail__c ,CIF_Job__c,CIF_Phone__c,CIF_PersonMobilePhone__c,CIF_MobilePhone__c,CIF_PersonEmail__c,CIF_Marital_Status__c,CIF_Document_type__c, CIF_Number__c, CIF_Expiry_date__c,
                CIF_Propaga_OMNIA_Work_Email__c,CIF_Propaga_OMNIA_Fax__c,CIF_Propaga_OMNIA_Personal_Email__c,CIF_Propaga_OMNIA_PersonEmail__c,CIF_Propaga_OMNIA_PersonMobilePhone__c,CIF_Propaga_OMNIA_Mobile_Phone__c,CIF_Propaga_OMNIA_Phone__c,CIF_Propaga_OMNIA_Work_Phone__c,
                CIF_Id_Contatto_Fax__c,CIF_Id_Contatto_MobilePhone__c,CIF_Id_Contatto_PersonalEmail__c,CIF_Id_Contatto_PersonEmail__c,CIF_Id_Contatto_PersonMobilePhone__c,CIF_Id_Contatto_Phone__c,CIF_Id_Contatto_WorkEmail__c,CIF_Id_Contatto_WorkPhone__c, 
                Flag_Opposizione_Tel_Princ__c, CIF_Commercial_Last_Modified_Date__c, CIF_OTP_Last_Modified_Date__c, Motivo_opposizione_Tel_Princ__c, Flag_Opposizione_Tel_Cell_B2C__c,Motivo_opposizione_Tel_Cell_B2C__c, Flag_Opposizione_Tel_Cell_B2B__c,Motivo_opposizione_Tel_Cell_B2B__c, Flag_Opposizione_Fax__c, Motivo_opposizione_Fax__c, Flag_Opposizione_Tel_Uff__c, Motivo_opposizione_Tel_Uff__c, Flag_Opposizione_Email_Pers_B2C__c,Motivo_opposizione_Email_Pers_B2C__c, Flag_Opposizione_Email_Pers_B2B__c, Motivo_opposizione_Email_Pers_B2B__c, Flag_Opposizione_Email_Uff__c, Motivo_opposizione_Email_Uff__c from Account where Id = :communicationToCustomer.AccountId__c];
            System.debug('Calling PartyServiceEdit: ' + communicationToCustomerId);
            try{
                if(!communicationToCustomer.CallPassAnagrafe__c){
                    communicationToCustomer.Status__c = PASSANAGRAFE_UPDATED_NOT_NECESSARY;
                    communicationToCustomer.AgencyEmail__c = account.AAI_Agency__r.Agency_email__c;
                    update communicationToCustomer;
                    return;
                }
                AccountSearchCtrl.ResponseDto fullSearchResponse = PassAnagrafeInvocable.callFullSearch(communicationToCustomer, account);
                    if(fullSearchResponse.isSuccess){
                        Account result = (Account) fullSearchResponse.values.get('returnedCIFAccount');
                        account.CIF_Privacy_1__c = result.CIF_Privacy_1__c; 
                        account.CIF_Privacy_2__c = result.CIF_Privacy_2__c;
                        account.CIF_Privacy_3__c = result.CIF_Privacy_3__c;
                        account.CIF_Privacy_4__c = result.CIF_Privacy_4__c;
                        account.CIF_Privacy_7__c = result.CIF_Privacy_7__c;
                        account.CIF_Privacy_8__c = result.CIF_Privacy_8__c;
                        account.CIF_Commercial_Last_Modified_Date__c = result.CIF_Commercial_Last_Modified_Date__c;
                        account.CIF_OTP_Last_Modified_Date__c = result.CIF_OTP_Last_Modified_Date__c;
                    }
                    account.CIF_Mail_contact__c = communicationToCustomer.CIF_Mail_contact__c;
                    account.CIF_Propaga_OMNIA_Personal_Email__c = true;
                    account.CIF_Privacy_5__c = communicationToCustomer.CIF_Privacy_5__c ? 'Sì' : 'No'; 
                    Boolean isChangedPersonEmail = false;
                    if(account.isPersonAccount){
                        account.CIF_PersonEmail__c =  communicationToCustomer.CIF_Mail_contact__c;
                        account.CIF_Work_email__c = communicationToCustomer.CIF_Mail_contact__c;
                        isChangedPersonEmail = true;
                    }
                    Boolean isChangedPersonalEmail = false;
                    if(!account.isPersonAccount){
                        account.CIF_PersonalEmail__c =  communicationToCustomer.CIF_Mail_contact__c;
                        account.CIF_Work_email__c = communicationToCustomer.CIF_Mail_contact__c;
                        isChangedPersonalEmail = true;
                    }
                    Boolean hasValidDates = hasValidDates(communicationToCustomer, account);
                    if(!fullSearchResponse.isSuccess){
                        communicationToCustomer.Status__c = PASSANAGRAFE_FULL_SEARCH_KO;
                        update communicationToCustomer;
                        return;
                    }
                    if(!hasValidDates){
                        communicationToCustomer.Status__c = PRIVACY_MODIFICATION_DATES_OUT_OF_RANGE;
                        update communicationToCustomer;
                        return;
                    }
                    CallPassAnagrafeQueueable queueable = new CallPassAnagrafeQueueable(communicationToCustomer, account, isChangedPersonEmail, isChangedPersonalEmail);
                    System.enqueueJob(queueable);
        } catch(Exception ex){
            ApplicationLogHelper.ERROR('PassAnagrafeInvocable', ex.getMessage(), ex.getStackTraceString());
        }
    }

    public static AccountSearchCtrl.ResponseDto callFullSearch(Communications_to_customer__c communicationToCustomer, Account account){
        return AccountSearchCtrl.sendRequest_fullsearch(account.NDG__c);
    }



    public static Boolean hasValidDates(Communications_to_customer__c communicationToCustomer, Account account){
        // se per un cliente anche solo una data di modifica di un consenso recuperata da fullSearchAccount è superiore alla data di invio della comunicazione, 
        // non deve essere effettuata la chiamata a Pass Anagrafe
        return (( account.CIF_Commercial_Last_Modified_Date__c == null || account.CIF_Commercial_Last_Modified_Date__c < communicationToCustomer.Send_Date__c) && 
        (account.CIF_OTP_Last_Modified_Date__c == null || account.CIF_OTP_Last_Modified_Date__c < communicationToCustomer.Send_Date__c));
    }

    public static accountEditLightningCTRL.ResponseDto call(Communications_to_customer__c communicationToCustomer, Account account, Boolean isChangedPersonEmail, Boolean isChangedPersonalEmail){
        accountEditLightningCTRL.FindModifiedFieldsGroupedDTO modifiedFieldsGrouped = accountEditLightningCTRL.findModifiedFieldsGrouped(account, null);
        Map<String,Boolean> editedFieldsMap = modifiedFieldsGrouped.fieldstatus;
        editedFieldsMap.put('One Click', true);
        editedFieldsMap.put('CIF_Privacy_7__c', true);
        editedFieldsMap.put('CIF_Privacy_1__c', true);
        editedFieldsMap.put('CIF_Privacy_2__c', true);
        editedFieldsMap.put('CIF_Privacy_3__c', true);
        editedFieldsMap.put('CIF_Privacy_4__c', true);
        editedFieldsMap.put('CIF_Privacy_5__c', true);
        editedFieldsMap.put('CIF_Mail_contact__c', true);
        if(isChangedPersonEmail){
            editedFieldsMap.put('CIF_PersonEmail__c', true);
        }
        if(isChangedPersonalEmail){
            editedFieldsMap.put('CIF_PersonalEmail__c', true);
        }
        editedFieldsMap.put('CIF_Privacy_8__c', false);
        return accountEditLightningCTRL.sendRequest(account, editedFieldsMap, null);
    }


    public class CallPassAnagrafeQueueable implements Queueable, Database.AllowsCallouts {

        public Communications_to_customer__c communicationToCustomer;
        public Account account;
        public Boolean isChangedPersonEmail;
        public Boolean isChangedPersonalEmail;

        public CallPassAnagrafeQueueable(Communications_to_customer__c communicationToCustomer, Account account, Boolean isChangedPersonEmail, Boolean isChangedPersonalEmail){
            this.communicationToCustomer = communicationToCustomer;
            this.account = account;
            this.isChangedPersonEmail = isChangedPersonEmail;
            this.isChangedPersonalEmail = isChangedPersonalEmail;
        }

        public void execute(QueueableContext context) {
            accountEditLightningCTRL.ResponseDto response = PassAnagrafeInvocable.call(communicationToCustomer, account, isChangedPersonEmail, isChangedPersonalEmail);
            if(response.isSuccess){
                communicationToCustomer.Status__c = PassAnagrafeInvocable.PASSANAGRAFE_UPDATED_OK;
                update account;
            } else {
               communicationToCustomer.Status__c = PassAnagrafeInvocable.PASSANAGRAFE_UPDATED_KO;
            } 
            // tracciare il caso in cui non sia possibile eseguire il mapping da account.AAI_Agency__r.Agency_email__c(String) a
            // communicationToCustomer.AgencyEmail__c (Email)
            // Il campo communicationToCustomer.AgencyEmail__c serve di tipo Email per far partire il process builder con Email Alert
            communicationToCustomer.AgencyEmail__c = account.AAI_Agency__r.Agency_email__c;
            update communicationToCustomer;
        }

    }

}