//BOVOLENTA_D 2018 - Controller for the agency self-care queue management - lead queues
//Logic moved to utility class in order to reuse it with the case queues
public with sharing class agencyQueueManagerCTRL {
    public boolean jsDebug{get;set;}
    
    public agencyQueueManagerCTRL ()
    {
        Id user_debug_id;
        try
        {
            user_debug_id = (AAI_Code_Variables__c.getAll()).get('JS_USER_DEBUG') != null ? (AAI_Code_Variables__c.getAll()).get('JS_USER_DEBUG').Value__c : null;
        }
        catch (Exception e)
        {
            user_debug_id = null;
        }
        if (user_debug_id != null && (user_debug_id  == UserInfo.getUserId()))
        {
            jsDebug= true;
        }
        else
        {
            jsDebug=false;
        }    
    
    
    }

    @AuraEnabled
    public static agencyQueueManagerUtilities.ResponseDto getAgencyUsers (String queueType) {
		agencyQueueManagerUtilities.ResponseDto pageResponse = new agencyQueueManagerUtilities.ResponseDto();
		pageResponse = agencyQueueManagerUtilities.getAgencyUsers(queueType);
		return pageResponse ;
    }


   @AuraEnabled
    public static agencyQueueManagerUtilities.ResponseDto saveUpdateRequest (List<Boolean> isInQueue, List<User> userList, String queueType) {
		agencyQueueManagerUtilities.ResponseDto pageResponse = new agencyQueueManagerUtilities.ResponseDto();
		pageResponse = agencyQueueManagerUtilities.saveUpdateRequest(isInQueue,userList,queueType);	
		return pageResponse ;
    }

    @AuraEnabled
    public static agencyQueueManagerUtilities.ResponseDto setOfficialAgencyEmail (String emailValue) {
        agencyQueueManagerUtilities.ResponseDto pageResponse = new agencyQueueManagerUtilities.ResponseDto();
        User currentUser = [
                SELECT Id, UserName, Agency_code__c, Profile.Name, IsActive, ContactId, Contact.AccountId, Contact.Account.Destinatario_notifica_Feedback_Case__c
                FROM User
                WHERE Id = :UserInfo.getUserId()
                LIMIT 1
        ];
        if (currentUser.ContactId != null && currentUser.Contact.AccountId != null) {
            List<Account> accounts = [
                    SELECT Id, Destinatario_notifica_Feedback_Case__c
                    FROM Account
                    WHERE Id = :currentUser.Contact.AccountId
                    LIMIT 1
            ];
            if (accounts != null && !accounts.isEmpty()) {
                for (Account account : accounts) {
                    account.Destinatario_notifica_Feedback_Case__c = emailValue;
                }
                agencyQueueManagerUtilities.UsersUtils usersUtils = new agencyQueueManagerUtilities.UsersUtils();
                List<Database.SaveResult> updateResult = usersUtils.updateRecords(accounts, false);
                for (Database.SaveResult result : updateResult) {
                    if (result.isSuccess()) {
                        pageResponse.isSuccess = true;
                    } else {
                        String errorMsg = 'Si è verificato un errore nella richiesta di modifica della mail: ';
                        for (Database.Error err : result.getErrors()) {
                            errorMsg = err.getMessage();
                        }
                        pageResponse.message = errorMsg;
                    }
                }
                return pageResponse;
            }
        }

        pageResponse.isSuccess = false;
        pageResponse.message = 'Non è possibile effettuare la modifica richiesta.';
        return pageResponse;
    }


    @AuraEnabled
    public static agencyQueueManagerUtilities.ResponseDto setAgencyPhone(String phone) {
        agencyQueueManagerUtilities.ResponseDto pageResponse = new agencyQueueManagerUtilities.ResponseDto();
        if(SendSMSCmpController.validate(phone)){

            
            User currentUser = [
                    SELECT Id, UserName, Agency_code__c, Profile.Name, IsActive, ContactId, Contact.AccountId, Contact.Account.Destinatario_notifica_Feedback_Case__c
                    FROM User
                    WHERE Id = :UserInfo.getUserId()
                    LIMIT 1
            ];
            if (currentUser.ContactId != null && currentUser.Contact.AccountId != null) {
                List<Account> accounts = [
                        SELECT Id, MobilePhone__c
                        FROM Account
                        WHERE Id = :currentUser.Contact.AccountId
                        LIMIT 1
                ];
                if (accounts != null && !accounts.isEmpty()) {
                    for (Account account : accounts) {
                        account.MobilePhone__c = phone;
                    }
                    agencyQueueManagerUtilities.UsersUtils usersUtils = new agencyQueueManagerUtilities.UsersUtils();
                    List<Database.SaveResult> updateResult = usersUtils.updateRecords(accounts, false);
                    for (Database.SaveResult result : updateResult) {
                        if (result.isSuccess()) {
                            pageResponse.isSuccess = true;
                        } else {
                            String errorMsg = 'Si è verificato un errore nella richiesta di modifica del numero: ';
                            for (Database.Error err : result.getErrors()) {
                                errorMsg = err.getMessage();
                            }
                            pageResponse.message = errorMsg;
                        }
                    }
                    return pageResponse;
                }
            }

            pageResponse.isSuccess = false;
            pageResponse.message = 'Non è possibile effettuare la modifica richiesta.';
            return pageResponse;
        }
        pageResponse.isSuccess = false;
        pageResponse.message = 'Il numero inserito non è valido. Il formato corretto è: 3XXXXXXXXX (es. 3351134567)';
        return pageResponse;
    }
}