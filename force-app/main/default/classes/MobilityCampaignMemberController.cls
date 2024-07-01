public with sharing class MobilityCampaignMemberController extends MobilityAbstract {

    public class MobilityCampaignMemberException extends Exception {}
    public class MobilityCampaignMemberResponse extends MobilityResponse {
        @AuraEnabled
        public List < String > contactValues;
    }

    @AuraEnabled
    public static MobilityCampaignMemberResponse changeStatus(List < String > customers, String status) {
        DebugStart('MobilityCampaignMemberController', 'changeStatus');
        Debug('Customers', customers);
        Debug('Status', status);

        MobilityCampaignMemberResponse response = new MobilityCampaignMemberResponse();

        try {
            List < CampaignMember > customersList = [
                SELECT Id, Status
                FROM CampaignMember
                WHERE Id =: customers
            ];

            for (CampaignMember campaignMember: customersList) {
                campaignMember.Status = status;
            }

            Debug('customerList', customersList);

            Database.SaveResult[] results = Database.update(customersList, false);
            for (Database.SaveResult result: results) {
                if (!result.isSuccess()) {
                    throw new MobilityCampaignMemberException(result.getErrors()[0].getMessage());
                }
            }
            response.isSuccess = true;

        } catch (MobilityCampaignMemberException ex) {
            response.errorMessage = ex.getMessage();
        }

        Debug('Response', response);
        DebugEnd();
        return response;
    }

    @AuraEnabled
    public static List < CampaignMember > getMembers(List < String > listMembers) {
        DebugStart('MobilityCampaignMemberController', 'getCampaignMembers');

        List < CampaignMember > selectMembers = [
            SELECT Id, Owner__c, Status, CampaignId, Nodes__c, Campaign.StartDate, Campaign.URL_Salesforce_campagna__c,
            Campaign.EndDate, Campaign.Name, Campaign.Type, LeadId, ContactId,
            Contact.Account.Ndg__c, Contact.Name, contact.Account.Id, contact.Account.Nodes__c
            FROM CampaignMember
            WHERE Id IN: listMembers
        ];

        Debug('selectMembers', selectMembers);
        DebugEnd();

        return selectMembers;
    }

    @AuraEnabled
    public static CampaignMember getMember(String campaignMemberId) {
        DebugStart('MobilityCampaignMemberController', 'getMember');
        List < CampaignMember > listMembers = MobilityCampaignMemberController.getMembers(new List < String > {
            campaignMemberId
        });

        if (listMembers.size() == 0) return null;

        Debug('selectMember', listMembers[0]);
        DebugEnd();
        return listMembers[0];
    }

    public static Void sendEmail(User userToAssign, Campaign campaign) {
        DebugStart('MobilityCampaignMemberController', 'sendEmail');

        String campaignId = campaign.Id;
        String campaignName = campaign.Name;
        String campaignType = campaign.Type;
        String campaignUrl = campaign.URL_Salesforce_campagna__c;

        String campaignStartDate = 'Non disponibile';
        String campaignEndDate = 'Non disponibile';

        if (campaign.StartDate != null) {
            campaignStartDate = campaign.StartDate.format();
        }

        if (campaign.EndDate != null) {
            campaignEndDate = campaign.EndDate.format();
        }

        Messaging.SingleEmailMessage mail = CampaignMembersViewCTRL.prepareEmailForAsssignment(userToAssign, campaignName, campaignId, campaignStartDate, campaignEndDate, campaignUrl);
        Debug('mail', mail);

        if (!test.isRunningTest()) {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {
                mail
            });
        }

        DebugEnd();
    }

    @AuraEnabled
    public static MobilityCampaignMemberResponse assignMembers(String campaignId, List < String > listIdMembers, String selectUserId, Boolean sendEmailToOwner) {
        DebugStart('MobilityCampaignMemberController', 'assignMembers');
        Debug('campaignId', campaignId);
        Debug('listIdMembers', listIdMembers);
        Debug('selectUserId', selectUserId);

        MobilityCampaignMemberResponse response = new MobilityCampaignMemberResponse();

        try {
            User currentUser = MobilityUserController.getCurrentUser();
            Debug('currentUser', currentUser);

            User selectUser = MobilityUserController.getUserById(selectUserId);
            Debug('selectUser', selectUser);

            List < CampaignMember > listMembers = MobilityCampaignMemberController.getMembers(listIdMembers);
            Debug('listMembers', listMembers);

            Map < String, CampaignMember > listMapMembers = new Map < String, CampaignMember > ();
            Set < String > listIdCheck = new Set < String > ();

            for (CampaignMember member: listMembers) {
                if (member.LeadId != null) listIdCheck.add(member.LeadId);
                if (member.ContactId != null) listIdCheck.add(member.ContactId);

                listMapMembers.put(member.Id, member);
            }

            Debug('listIdCheck', listIdCheck);

            List < UserRecordAccess > accessRecords = MobilityUserController.getAccess(selectUser.Id, new List < String > (listIdCheck));
            Debug('accessRecords', accessRecords);

            Set < Id > listIdAccess = new Set < Id > ();
            for (UserRecordAccess access: accessRecords) {
                if (access.hasReadAccess) listIdAccess.add(access.RecordId);
            }

            Debug('listIdAccess', listIdAccess);

            Boolean hasDenyAccess = false;
            Integer countDenyAccess = 0;
            for (CampaignMember member: listMembers) {
                if (listIdAccess.contains(member.LeadId) || listIdAccess.contains(member.ContactId)) {
                    member.Owner__c = selectUserId;

                    if (member.status.tolowercase() == 'da assegnare') member.Status = 'Da lavorare';
                } else {
                    hasDenyAccess = true;
                    countDenyAccess++;
                }
            }

            Debug('hasDenyAccess', hasDenyAccess);

            if (hasDenyAccess && 'NFE - AAI - Vendite Avanzato'.equalsIgnoreCase(currentUser.Profile.Name)) {
                throw new MobilityCampaignMemberException('Attenzione: ' + countDenyAccess + ' dei ' + listIdMembers.size() + ' clienti campagna selezionati non possono essere assegnati poiché non sono visibili all\'utente ' + selectUser.Name);
            } else {
                update listMembers;

                if (hasDenyAccess) {
                    throw new MobilityCampaignMemberException('Attenzione! L\'utente assegnatario non ha visibilità sul cliente selezionato');
                } else if (sendEmailToOwner) {
                    MobilityCampaignMemberController.sendEmailCampaign(selectUser, campaignId);
                }
            }
            response.isSuccess = true;
        } catch (MobilityCampaignMemberException ex) {
            response.errorMessage = ex.getMessage();
        }

        Debug('Response', response);
        DebugEnd();
        return response;
    }

    public static void sendEmailCampaign(User selectUser, String campaignId){
        Campaign currentCampaign = [
            SELECT Id, Name, Type, StartDate, EndDate, URL_Salesforce_campagna__c
            FROM Campaign
            WHERE Id =: campaignId
            LIMIT 1
        ];

        if (!test.isRunningTest()) {
            MobilityCampaignMemberController.sendEmail(selectUser, currentCampaign);
        }
    }

    @AuraEnabled
    public static MobilityCampaignMemberResponse getContactValue(String campaignId) {
        DebugStart('MobilityCampaignMemberResponse', 'getContactValue');

        MobilityCampaignMemberResponse response = new MobilityCampaignMemberResponse();

        try {
            Campaign campaign = [
                SELECT Id, Contact_Value__c FROM Campaign WHERE Id =: campaignId LIMIT 1
            ];

            if(campaign.Contact_Value__c == null) throw new MobilityCampaignMemberException('CONTACT_VALUE_NOT_DEFINED');

            response.contactValues = campaign.Contact_Value__c.split(';');
            response.isSuccess = true;
        } catch (MobilityCampaignMemberException ex) {
            response.errorMessage = ex.getMessage();
        }

        Debug('response', response);
        DebugEnd();
        return response;
    }

    @AuraEnabled
    public static MobilityCampaignMemberResponse proccessInformative(String campaignMemberId, String valueContact, String status, Boolean isReminder, Datetime reminderDateTime) {
        DebugStart('MobilityCampaignMemberResponse', 'proccessInformative');
        Debug('Current Value Contact: ', valueContact);

        MobilityCampaignMemberResponse response = new MobilityCampaignMemberResponse();

        try {

            CampaignMember campaignMember = MobilityCampaignMemberController.getMember(campaignMemberId);
            if (campaignMember == null) throw new MobilityCampaignMemberException('Campaign Member not found');

            if (status == null) status = 'Lavorato';
            campaignMember.Status = status;

            if (valueContact == null) valueContact = '';
            campaignMember.Informative_Contact_Outcome__c = valueContact;

            campaignMember.Owner__c = Userinfo.getUserId();

            update campaignMember;
            Debug('Campaign Member: ', campaignMember);

            RecordType taskRecordType = [ // NOPMD  Fix CRUD violation
                SELECT id
                FROM RecordType
                WHERE SobjectType = 'Task'
                AND DeveloperName = 'Generico' 
                LIMIT 1
            ];

            if (isReminder && status != 'Lavorato') {

                Task task = new Task();

                // TODO quali campi mandare al task?
                task.Subject = campaignMember.Contact.Name;
                task.RecordTypeId = taskRecordType.Id;
                task.OwnerId = Userinfo.getUserId();
                task.Status = 'Open';
                task.ReminderDateTime = reminderDateTime;
                task.Subject = 'Contatto';
                task.WhoId = campaignMember.Contact.Id;
                task.WhatId = campaignMember.Campaign.Id;
                task.Priority = 'Normal';
                task.IsReminderSet = true;
                task.ActivityDate = DateTime.now().date();

                
                insert task; // NOPMD  Fix CRUD violation

                Debug('Titolare: ', task.OwnerId);
                Debug('Owner: ', Userinfo.getUserId());
                Debug('Task: ', task);
            }

            response.isSuccess = true;

        } catch (MobilityCampaignMemberException ex) {

            response.errorMessage = ex.getMessage();

        }

        Debug('response', response);
        DebugEnd();
        return response;
    }

    @AuraEnabled
    public static MobilityCampaignMemberResponse proccessDataEnrichment(String campaignId) {
        DebugStart('MobilityCampaignMemberResponse', 'proccessDataEnrichment');

        MobilityCampaignMemberResponse response = new MobilityCampaignMemberResponse();

        try {

            response.isSuccess = true;
        } catch (MobilityCampaignMemberException ex) {
            response.errorMessage = ex.getMessage();
        }

        Debug('response', response);
        DebugEnd();
        return response;
    }

    @AuraEnabled
    public static MobilityCampaignMemberResponse proccessInterested(String campaignMemberId, Boolean createOpportunity, Boolean createEvent, SObject eventData, Boolean sendEmail) {
        DebugStart('MobilityCampaignMemberResponse', 'proccessInterested');
        Debug('campaignMemberId', campaignMemberId);
        Debug('createOpportunity', createOpportunity);
        Debug('createEvent', createEvent);
        Debug('eventData', eventData);
        Debug('sendEmail', sendEmail);

        MobilityCampaignMemberResponse response = new MobilityCampaignMemberResponse();

        try {
            CampaignMember campaignMember = MobilityCampaignMemberController.getMember(campaignMemberId);
            if (campaignMember == null) throw new MobilityCampaignMemberException('Campaign Member not found');

            RecordType taskRecordType = [ // NOPMD  Fix CRUD violation
                SELECT id
                FROM RecordType
                WHERE SobjectType = 'Task'
                AND DeveloperName = 'Generico' 
                LIMIT 1
            ];

            Task task = new Task();
            task.RecordTypeId = taskRecordType.Id;
            task.OwnerId = Userinfo.getUserId();
            task.Subject = 'Contattato per la campagna ' + campaignMember.Campaign.Name;
            task.Status = 'Completed';
            task.WhoId = campaignMember.Contact.Id;
            task.WhatId = campaignMember.CampaignId;
            task.Priority = 'Normal';
            insert task; // NOPMD  Fix CRUD violation

            Debug('task', task);
            Debug('taskCreated', task.CreatedDate);

            if (createOpportunity) {
                RecordType opportunityRecordType = [ // NOPMD  Fix CRUD violation
                    SELECT id
                    FROM RecordType
                    WHERE SobjectType = 'Opportunity'
                    AND DeveloperName = 'Opportunita_AXA_Assicurazioni' 
                    LIMIT 1
                ];

                Opportunity opportunity = new Opportunity();
                opportunity.Name = 'OPP-XXXXXXX';
                opportunity.StageName = 'Open';
                opportunity.Amount = 0;
                opportunity.AccountId = campaignMember.contact.Account.Id;
                opportunity.CampaignId = campaignMember.CampaignId;
                opportunity.RecordTypeId = opportunityRecordType.Id;
                opportunity.CloseDate = Date.today().AddDays(30);
                insert opportunity;

                campaignMember.Campaign_member_related_opportunity__c = opportunity.Id;
                Debug('opportunity', opportunity);

                if (createEvent) {
                    Event event = (Event) eventData;
                    event.WhoId = campaignMember.Contact.Id;
                    event.WhatId = opportunity.Id;
                    
                    insert event; // NOPMD  Fix CRUD violation
                    Debug('event', event);
                }
            }

            campaignMember.Status = 'Interessato';
            campaignMember.TECH_task_date_created__c = [SELECT CreatedDate  FROM TASK WHERE Id= :Task.Id limit 1].CreatedDate;
            campaignMember.Owner__c = Userinfo.getUserId();

            Debug('campaignMember', campaignMember);
            update campaignMember;

            if(sendEmail){
                User currentUser = MobilityUserController.getCurrentUser();
                Debug('currentUser', currentUser);

                MobilityCampaignMemberController.sendEmailCampaign(currentUser, campaignMember.CampaignId);
            }

            response.isSuccess = true;
        } catch (MobilityCampaignMemberException ex) {
            response.errorMessage = ex.getMessage();
        }

        Debug('response', response);
        DebugEnd();
        return response;
    }

    @AuraEnabled
    public static MobilityCampaignMemberResponse proccessRecontact(String campaignMemberId, Boolean isReminder, Datetime dateReminder) {
        DebugStart('MobilityCampaignMemberResponse', 'proccessRecontact');

        MobilityCampaignMemberResponse response = new MobilityCampaignMemberResponse();

        try {
            CampaignMember campaignMember = MobilityCampaignMemberController.getMember(campaignMemberId);
            if (campaignMember == null) throw new MobilityCampaignMemberException('Campaign Member not found');

            RecordType taskRecordType = [ // NOPMD  Fix CRUD violation
                SELECT id
                FROM RecordType
                WHERE SobjectType = 'Task'
                AND DeveloperName = 'Generico' 
                LIMIT 1
            ];

          
            //TODO CAPIRE CAMPI TASK
            Task task = new Task();
            task.RecordTypeId = taskRecordType.Id;
            task.OwnerId = Userinfo.getUserId();
            task.Subject = 'Contatto';
            task.Status = 'Open';
            task.WhoId = campaignMember.Contact.Id;
            task.Priority = 'Normal';            
            task.WhatId = campaignMember.CampaignId;
            task.Interest_Rate__c = 'Da ricontattare';
            task.Type = 'Contact';
            task.TECH_SourceId__c = campaignMember.Id;
 
            if (isReminder) {
            task.ReminderDateTime = dateReminder;
            tasK.ActivityDate=dateReminder.date();
            task.IsReminderSet = true;
            }

            insert task; // NOPMD  Fix CRUD violation

            Debug('task', task);

            campaignMember.Status = 'Da ricontattare';
            campaignMember.TECH_task_date_created__c = [SELECT CreatedDate  FROM TASK WHERE Id= :Task.Id limit 1].CreatedDate;
            campaignMember.Owner__c = Userinfo.getUserId();
            update campaignMember;

            Debug('campaignMember', campaignMember);

            response.isSuccess = true;
        } catch (MobilityCampaignMemberException ex) {
            response.errorMessage = ex.getMessage();
        }

        Debug('response', response);
        DebugEnd();
        return response;
    }

    @AuraEnabled
    public static MobilityCampaignMemberResponse proccessNotInterested(String campaignMemberId, String reason) {
        DebugStart('MobilityCampaignMemberResponse', 'proccessNotInterested');

        MobilityCampaignMemberResponse response = new MobilityCampaignMemberResponse();

        try {
            RecordType taskRecordType = [ // NOPMD  Fix CRUD violation
                SELECT id
                FROM RecordType
                WHERE SobjectType = 'Task'
                AND DeveloperName = 'Generico' 
                LIMIT 1
            ];

            CampaignMember campaignMember = MobilityCampaignMemberController.getMember(campaignMemberId);
            if (campaignMember == null) throw new MobilityCampaignMemberException('Campaign Member not found');

            Task task = new Task();
            task.Subject = 'Contatto';
            task.Type = 'Contact';
            task.Contact_Date__c = Date.today();
            task.RecordtypeId = taskRecordType.Id;
            task.TECH_SourceId__c = campaignMember.Id;
            task.WhoId = campaignMember.ContactId;
            task.WhatId = campaignMember.CampaignId;
            task.OwnerId = Userinfo.getUserId();
            task.Reason__c = reason;
            task.Status = 'Completed';
            task.Interest_Rate__c = 'Non interessato';
            task.IsReminderSet = false;
            task.ReminderDateTime = null;

            insert task; // NOPMD  Fix CRUD violation

            campaignMember.Status = 'Non interessato';
            campaignMember.Owner__c = Userinfo.getUserId();
            campaignMember.Not_Interested_Reason__c = reason;
            campaignMember.TECH_task_date_created__c = [SELECT CreatedDate  FROM TASK WHERE Id= :Task.Id limit 1].CreatedDate;
            update campaignMember;

            response.isSuccess = true;


        } catch (MobilityCampaignMemberException ex) {
            response.errorMessage = ex.getMessage();
        }

        Debug('response', response);
        DebugEnd();
        return response;
    }
}