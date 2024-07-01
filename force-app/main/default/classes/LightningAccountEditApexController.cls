public with sharing class LightningAccountEditApexController {

    private static Set<String> aaiRT = new Set<String> {
        'B2C_Client',
        'B2B_Client'
    };
    
    public class GetDataDTO {
        @AuraEnabled
        public Boolean showAAIEdit = false;
        @AuraEnabled
        public Boolean userIsAdvisor = false;
        @AuraEnabled
        public Boolean jsDebug = false;
        @AuraEnabled
        public Boolean MPSEnrichment = false;
        @AuraEnabled
        public String foundCaseId = '';
    }


    @AuraEnabled
    public static GetDataDTO getData(Id recordId, String callId){
        System.debug('### recordId: ' + recordId);
        System.debug('### callId: ' + callId);
        try {
            String currentUserProfile = [SELECT Id,Name FROM Profile WHERE Id = :UserInfo.getProfileId()].Name;
            Account queriedAccount = [SELECT isPersonAccount,RecordType.DeveloperName,AAI_Partita_IVA__c,AAI_Codice_fiscale__c FROM Account where id = :recordId limit 1];

            FilterValuesService filterValueService = new FilterValuesService('EditAccountPage');

            Set<String> allowedProfiles = filterValueService.filterBySObject('Profile').filterByField('Name').getValues();
            Set<String> advisorsProfiles = filterValueService.filterByKey('Advisor').getValues();


            Boolean userIsAdvisor = advisorsProfiles.contains(currentUserProfile);

            GetDataDTO response = new GetDataDTO();
            response.showAAIEdit = getShowAAIEdit(queriedAccount, currentUserProfile, allowedProfiles);
            response.userIsAdvisor = userIsAdvisor;
            response.jsDebug = getJsDebug();
            response.MPSEnrichment = getSmCenEnrAvail(userIsAdvisor, queriedAccount);
            response.foundCaseId = getFoundCaseId(callId);

            return response;




        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    private static Boolean getShowAAIEdit(Account queriedAccount, String currentUserProfile, Set<String> allowedProfiles) {
        return aaiRT.contains(queriedAccount?.RecordType.DeveloperName) && allowedProfiles.contains(currentUserProfile); 
    }

    private static Boolean getJsDebug() {
        Id user_debug_id;
        
        try{
            user_debug_id = (AAI_Code_Variables__c.getAll()).get('JS_USER_DEBUG') != null ? (AAI_Code_Variables__c.getAll()).get('JS_USER_DEBUG').Value__c : null;
        }
        catch (Exception e)
        {
            user_debug_id = null;
        }

        return (user_debug_id != null && (user_debug_id  == UserInfo.getUserId()));
    }

    private static Boolean getSmCenEnrAvail(Boolean userIsAdvisor, Account queriedAccount) {
        if(userIsAdvisor) {
            return accountEditLightningCTRL.SmartCenterEnrichmentAvailability(queriedAccount);
        }

        return false;
    }

    private static String getFoundCaseId(String callId) {

        if(String.isNotBlank(callId)) {
            callId = callId.split('_')[0];

           Set<String> SetSC= new Set<String>();
           List<String> ListSC= new List<String>();
           
           for(Storico_Chiamate__c c : [Select Case__c from Storico_Chiamate__c where Call_ID__c =:callId])
           {
             SetSC.add(c.Case__c);
           }

           if(SetSC.size()==1)
           {
             ListSC.addAll(SetSC);
             return ListSC[0];
           }
        }

        return '';
    }
}