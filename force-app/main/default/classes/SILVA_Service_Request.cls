/**
 * @author Reply
 * @date 03/2023
 * @description Wrapper della classe CreateSilvaTicket
 */
public class SILVA_Service_Request {
    public String assignment_group;
    public String correlation_display;
    public String correlation_id;
    public String description;
    public DateTime due_date;
    public String quantity;
    public String short_description;
    public String u_appointment_date;
    public String u_business_service;
    public String u_caller;
    public String u_configuration_item;
    public String u_project_id;
    public DateTime u_reported_on;
    public String u_requested_for;
    public DateTime u_fulfilment_end_date;
    public DateTime closed_at;
    public Double duration;
    Map<String, Object> variables = new Map<String, Object>();

    private static final transient String IE_Conf_Name = 'SILVA_generic';

/**
* @param Case
* @description Constructor
*/
    public SILVA_Service_Request(Case caseRequest) {
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

        DateTime report = BusinessHours.add(defaultBHour.Id, closeDate, -1 * timeSpentTotal);

        assignment_group = c.Application_EAGP__r.Prefix__c + currOwnToSearch;
        closed_at = closeDate;
        duration = timeSpentDouble;
        u_fulfilment_end_date = closeDate;
        due_date = closeDate;
        u_reported_on = report;
        short_description = c.CaseNumber + ' ' + c.Oggetto_Apertura_Case__c;
        correlation_id = c.id;
        u_business_service = c.Application_EAGP__r.External_Id__c;
        
        correlation_display = c.CaseNumber;
        quantity = '1';
        u_caller = 'Tech_AXA_ITALY_SALESFORCE_WS';
        description = c.Description;
        u_appointment_date = '';
        u_project_id = '';
        u_requested_for = c.SuppliedEmail;
        if (u_requested_for == null) {
            u_requested_for = 'xxx@xxx.com';
        }

        variables.put('saleforce_reported_on', report);
        variables.put('saleforce_u_fulfilment_end_date', closeDate);
        variables.put('saleforce_due_date', closeDate);
        variables.put('saleforce_closed_at', closeDate);
        variables.put('saleforce_business_service', c.Application_EAGP__r.External_id__c);
    }

    public static String getConfName() {
        return IE_Conf_Name;
    }
}