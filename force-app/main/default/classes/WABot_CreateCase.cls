public without sharing class WABot_CreateCase {

    public class CreateCaseInput{

        @InvocableVariable
        public String  status;
        @InvocableVariable
        public String  messagingSessionId;
        @InvocableVariable
        public String  messagingUserId;
        @InvocableVariable
        public String  oggetto;

        public CreateCaseInput() {

        }

        public CreateCaseInput( String messagingSessionId, String status, String messagingUserId, String oggetto ) {
            this.messagingSessionId = messagingSessionId;
            this.status = status;
            this.messagingUserId = messagingUserId;
            this.oggetto = oggetto;

        }
 
    }


    public class CreateCaseOutput{

        @InvocableVariable
        public String  newCaseId;

        public CreateCaseOutput( String newCaseId ) {
            this.newCaseId = newCaseId;

        }
 
    }

    @InvocableMethod(Label ='Create Case' description='Create Case related to Messaging Session Id')
    public static List<CreateCaseOutput> createCase(List<CreateCaseInput> inputList) {

        System.debug('WABot_CreateCase.createCase - START - ' + System.now());
        Set<String> messagingSessionIds = new Set<String>();
        Set<String> messagingUserIds = new Set<String>();
        Map<String, CreateCaseInput> inputMap = new Map<String, CreateCaseInput>();
        Map<String, Case> casesPerMessagingSessionId = new Map<String, Case>();


        List<Case> caseToInsert = new List<Case>();

        for(CreateCaseInput input: inputList) {
            messagingSessionIds.add(input.messagingSessionId);
            messagingUserIds.add(input.messagingUserId);
            inputMap.put(input.messagingSessionId, input);
        }

        List<CreateCaseOutput> res = new List<CreateCaseOutput>();
        Map<Id, MessagingSession> messagingSessionMap = new Map<Id, MessagingSession>([SELECT Id, CaseId, OwnerId, Owner.Name, MessagingEndUserId  FROM MessagingSession WHERE Id in :messagingSessionIds]);
        Map<Id, MessagingEndUser> messagingUserMap = new Map<Id, MessagingEndUser>([SELECT Id, Name, CreatedDate, MessagingChannelId, MessageType, MessagingPlatformKey, HasInitialResponseSent, AccountId, ContactId, IsoCountryCode, MessagingConsentStatus, IsFullyOptedIn, (SELECT id FROM Cases__r ORDER BY CreatedDate desc LIMIT 1) FROM MessagingEndUser WHERE Id in :messagingUserIds] );

        Group queue = [SELECT Id FROM Group WHERE DeveloperName = 'HD1_BIZ_Whatsapp' AND Type = 'Queue' LIMIT 1];
        CaseHandler.RunTrigger = false;

        System.debug('WABot_CreateCase.createCase - Data Retrieved - ' + System.now());

        Set<String> userOwnerIds = new Set<String>();
        Set<String> queuesOwnerIds = new Set<String>();

        for(String messagingSessionId : messagingSessionIds) {
            MessagingSession session = messagingSessionMap.get(messagingSessionId);
            MessagingEndUser endUser = messagingUserMap.get(session.MessagingEndUserId);
            Case lastEndUserCase = endUser?.Cases__r?.size() > 0 ? endUser.Cases__r.get(0) : null;
            Case newCase = new Case();

            if(String.valueOf(session.OwnerId).startsWith('005') && session.Owner.Name != 'Automated Process' && session.Owner.Name != 'Utente Tecnico') {
                newCase.OwnerId = session.OwnerId;
                userOwnerIds.add(session.OwnerId);
            } else {
                newCase.OwnerId = queue.Id;
                queuesOwnerIds.add(queue.Id);
            }
            newCase.Category__C = 'Informazioni su e-commerce e preventivatori online';
            newCase.Complainant__c = 'Customer';
            newCase.LOB__c = 'Auto';
            newCase.Origin  = 'Whatsapp';
            newCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Axa_Assicurazioni').getRecordTypeId();
            newCase.Status = inputMap.get(messagingSessionId).status;
            newCase.MessagingUser__c = endUser?.Id;
            newCase.ParentId = lastEndUserCase?.Id;
            newCase.ContactId = endUser?.ContactId;
            newCase.AccountId = endUser?.AccountId;
            newCase.Distribution_Network__c = 'Axa Assicurazioni';
            newCase.Oggetto_Apertura_Case__c = inputMap.get(messagingSessionId).oggetto;//'Contatto Whatsapp Preventivatore Auto Fuori Orario';
            newCase.Subject = 'Axa Assicurazioni';
            newCase.TECH_LastHD1Queue__c = 'Axa_Assicurazioni';

            caseToInsert.add(newCase);
            casesPerMessagingSessionId.put(messagingSessionId, newCase);
        }
        System.debug('WABot_CreateCase.createCase - Case Insert Before - ' + System.now());
        insert caseToInsert;
        System.debug('WABot_CreateCase.createCase - Case Insert After - ' + System.now());
        Map<String, Case> oldValues = new Map<String,Case>();

        for(Case c : caseToInsert) {
            oldValues.put(c.Id, new Case(Status=c.Status));
            res.add(new CreateCaseOutput(c.Id));
        }

        for(String messagingSessionId : messagingSessionIds) {
            messagingSessionMap.get(messagingSessionId).CaseId = casesPerMessagingSessionId.get(messagingSessionId).Id;
        }
        System.debug('WABot_CreateCase.createCase - UpdateMessaging Before - ' + System.now());
        update messagingSessionMap.values();
        System.debug('WABot_CreateCase.createCase - UpdateMessaging After - ' + System.now());

        ModelloDiAssistenzaUtils.UserInformation uInformation =  ModelloDiAssistenzaUtils.getProfileAndRole(userOwnerIds, queuesOwnerIds);

    
        if(!Test.isRunningTest()){
            System.debug('WABot_CreateCase.createCase - processMilestoneandWorkingTime Before - ' + System.now());
            NewMilestoneTrackingManagement.processMilestoneandWorkingTime(caseToInsert,oldValues, uInformation.mapProfileToId,uInformation.mapRoleToId);
            System.debug('WABot_CreateCase.createCase - processMilestoneandWorkingTime After - ' + System.now());
        }

        return res;

    }

}