public abstract class MobilityAbstract extends RLY_Behaviour {

    public class MobilityVisibilityException extends Exception {}
    public class MobilityVisibilityResponse extends MobilityResponse {
        @AuraEnabled public String profileName;
        @AuraEnabled public String portalRole;
        @AuraEnabled public List<MobilityMessages__mdt> messages;
    }

    @AuraEnabled
    public static MobilityVisibilityResponse getVisibility(String componentView) {
        DebugStart('MobilityAbstract', 'getVisibility');

        MobilityVisibilityResponse response = new MobilityVisibilityResponse();

        try {
            /**
             * Retrieve Current User
             */
            User currentUser = [
                SELECT CommunityNickname, Email, Profile.Name, UserRole.Name, UserRole.PortalRole
                FROM User
                WHERE Id =: Userinfo.getUserId()
            ];

            /**
             * Retrieve All messages Rules
             */
            List<MobilityMessages__mdt> messages = [
                SELECT Id, DeveloperName, ErrorCode__c, LabelName__c, RegExp__c
                FROM MobilityMessages__mdt
            ];

            response.messages = messages;

            /**
             * User Role
             * - Executive
             * - Manager
             * - Worker
             */
            response.portalRole = currentUser.UserRole.PortalRole;
            //response.portalRole = 'Executive';
            //response.portalRole = 'Manager';
            //response.portalRole = 'Worker';

            /**
             * Profile Name
             * - NFE - AAI - Vendite Base
             * - NFE - AAI - Vendite Avanzato
             * - NFE - AAI - Vendite Solo Assistenza
             */
            response.profileName = currentUser.Profile.Name;
            //response.profileName = 'NFE - AAI - Vendite Base';
            //response.profileName = 'NFE - AAI - Vendite Avanzato';
            //response.profileName = 'NFE - AAI - Vendite Solo Assistenza';
            
            /**
             * Check if not have visibiity
             */
            List<MobilityVisibilities__mdt> records = [
                SELECT Id, DeveloperName, ComponentName__c, ProfileName__c
                FROM MobilityVisibilities__mdt
                WHERE ProfileName__c = :currentUser.Profile.Name // Per profilo collegato
                AND ComponentName__c = :componentView // Per componente visualizzato
            ];

            response.isSuccess = records.size() == 0;
        } catch (MobilityVisibilityException ex) {
            response.errorMessage = ex.getMessage();
        }

        Debug('response', response);
        DebugEnd();
        return response;
    }

}