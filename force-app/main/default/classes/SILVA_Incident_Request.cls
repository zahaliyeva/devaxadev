/**
 * @author Reply
 * @date 03/2023
 * @description Wrapper della classe CreateSilvaTicket
 */
public without sharing class SILVA_Incident_Request {
    public String u_requested_for;
    public String caller_id;
    public String state;
    public String u_vendor_interface;
    public String urgency = '2';
    public String impact = '2';
    public String subcategory = 'Performance';
    public String category = 'Application';
    public String close_code = 'Solved (Permanently)';
    public String short_description;
    public String description;
    public String u_business_service;
    public String approval;
    public String work_notes;
    public String u_owner;
    public String u_configuration_item;
    public String u_on_behalf_of;
    public String parent_incident;
    public String assignment_group;
    public String service_offering;
    public String correlation_id;
    public String correlation_display;
    public DateTime u_real_start_date;
    public String u_communication = '1';
    public DateTime u_actual_resolution_date;
    public DateTime closed_at;
    public String close_notes;
    public DateTime u_reported_on;
    public DateTime opened_at;
    public Decimal duration;
    //public String u_resolver_group;

    private static final transient String IE_Conf_Name = 'SILVA_generic';

/**
* @param Case
* @description Constructor
*/
    public SILVA_Incident_Request(Case caseRequest) {
        Case c = [
            SELECT
                id,
                Oggetto_Apertura_Case__c,
                Application_EAGP__r.Prefix__c,
                Application_EAGP__r.Service_Offering__c,
                Silva_Assignment_Group__c,
                subject,
                caseNumber,
                Application_EAGP__r.External_Id__c,
                Description,
                ClosedDate,
                Application_EAGP__c,
                SuppliedEmail,
                Tipologia_Ticket_Silva__c
            FROM Case
            WHERE id = :caseRequest.Id
            LIMIT 1
        ];
        //String BusinessHoursName = 'Default';
        DateTime closeDate;
        if (c.ClosedDate != null) {
            closeDate = c.ClosedDate;
        } else {
            closeDate = DateTime.now();
        }
        system.debug('Case di partenza: ' + c);
        BusinessHours defaultBHour = [SELECT id FROM BusinessHours WHERE IsDefault = TRUE]; //NOPMD query admin configuration
        //Working_Times__c  wt = [SELECT id, userProfile__c, Time_Spent__c FROM Working_Times__c  where Case__c =: c.id LIMIT 1];
        String currOwnToSearch = c.Silva_Assignment_Group__c != null ? c.Silva_Assignment_Group__c.replaceAll('_', ' ') : '';
        List<Milestone_Tracking__c> milesList = [
            SELECT ID, TimeSpent__c
            FROM Milestone_Tracking__c
            WHERE Case__c = :c.id AND Gruppo_di_Lavoro__c = :currOwnToSearch
        ];
        Long timeSpentTotal = 0;
        Double timeSpentDouble = 0;
        for (Milestone_Tracking__c mt : milesList) {
            timeSpentTotal += (Long) (mt.TimeSpent__c * 3600000);
            timeSpentDouble += mt.TimeSpent__c;
        }
        caseRequest.TECH_LastHD2IT_Time_Spent__c = timeSpentDouble;
        //Long timeSpentMillis = (Long) (-1 * timeSpentTotal );
        DateTime report = BusinessHours.add(defaultBHour.Id, closeDate, -1 * timeSpentTotal);
        caller_id = 'Tech_AXA_ITALY_SALESFORCE_WS';
        u_vendor_interface = 'SALESFORCE.COM SARL';
        close_code = 'Solved';
        category = 'Application';
        subcategory = 'Other';
        impact = '4';
        urgency = '4';
        state = '7';
        u_real_start_date = report;
        assignment_group = c.Application_EAGP__r.Prefix__c + currOwnToSearch;
        u_business_service = c.Application_EAGP__r.External_Id__c; //giusto?
        u_reported_on = report;
        service_offering = c.Application_EAGP__r.Service_Offering__c;
        short_description = c.CaseNumber + ' ' + c.Oggetto_Apertura_Case__c;
        description = c.Description;
        u_actual_resolution_date = closeDate;
        //u_resolver_group = c.Application_EAGP__r.Prefix__c + currOwnToSearch;
        closed_at = closeDate;
        duration = timeSpentDouble;
        opened_at = report;
        correlation_id = c.Id;
        correlation_display = c.CaseNumber;
        approval = 'approved';
        work_notes = '';
        u_owner = '';
        u_configuration_item = '';
        u_on_behalf_of = '';
        parent_incident = '';
        close_notes = 'Solution';
        u_communication = '1';
        u_requested_for = c.SuppliedEmail;
        if (u_requested_for == null) {
            u_requested_for = 'xxx@xxx.com';
        }
    }

    public static String getConfName() {
        return IE_Conf_Name;
    }
}