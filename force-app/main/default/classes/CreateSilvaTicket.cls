/**
 * @author Reply
 * @date 03/2023
 * @description Classe che gestisce la creazione del ticket silva
 */
public without sharing class CreateSilvaTicket {
    public static Map<String, IE_Configuration__c> confMap;

    /**
     * @param caseId
     * @return
     * @example 
     * @description Metodo invocato dal flow per prendere l'id e passare il case a createRequest
     */
    @InvocableMethod(Label='Create Silva Ticket' description='Create Silva Ticket related to the case')
    public static void invokeSilvaCallout(list<String> silvaParams) {
        System.debug('SILVA **** silvaParams: ' + silvaParams);
        String caseId;
        for (String param : silvaParams) {
            caseId = param;
        }
        Case caseData = [
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
            WHERE id = :caseId
            LIMIT 1
        ];
        createRequest(caseData);
    }

    /**
     * @param Case
     * @return HttpResponse
     * @example 
     * @description Chiamata al servizio Silva
     */
    public static HttpResponse createRequest(Case caseData) {
        IE_Configuration__c conf = [
            SELECT Id, Name, EndPoint__c, Silva_Access_Token__c, Silva_Token_Expiration_DateTime__c
            FROM IE_Configuration__c
            WHERE name = 'SILVA_generic'
            LIMIT 1
        ];
        System.debug('SILVA **** Start createRequest');
        String ticketType = caseData.Tipologia_Ticket_Silva__c;
        String body = '';
        boolean isSuccess = true;
        System.debug('SILVA **** ticketType: ' + ticketType);
        if (ticketType == 'Incident') {
            //rimetti il mapping di silva incident
            SILVA_Incident_Request silva_req = new SILVA_Incident_Request(caseData);
            body = JSON.serialize(silva_req);
        } else if (ticketType == 'Service Request') {
            SILVA_Service_Request silva_req = new SILVA_Service_Request(caseData);
            body = JSON.serialize(silva_req);
        }

        System.debug('SILVA **** ticket request body : ' + body);

        String accessToken = conf.Silva_Access_Token__c;
        if (accessToken == null || SILVA_Utility.isTokenExpired(conf) == true) {
            Map<String, String> getTokenResponse = SILVA_Utility.getAuthToken();
            accessToken = String.valueOf(getTokenResponse.get('access_token'));
            System.debug('SILVA **** new accessToken :' + accessToken);
        } else {
            System.debug('SILVA **** current valid accessToken :' + accessToken);
        }

        String authorizationHeader = 'Bearer ' + accessToken;
        //String authorizationHeader = 'Bearer ' + 'eyJhbGciOiJSUzI1NiIsImtpZCI6IkFUMjAxODA1MDkifQ.eyJhdWQiOiJzaWx2YSIsInJsbSI6ImNsaWVudCIsImNlaSI6IjQ0MWNlMGFiIiwic2NvcGUiOiJ1cm46YXhhOmF4YS1nbzpzaWx2YTpnZW5lcmljLWludGVncmF0aW9uLWZyYW1ld29yayIsImlzcyI6Imh0dHBzOlwvXC9tYWFtLXN0Zy5heGEuY29tXC9tYWFtXC92MiIsImV4cCI6MTY2Njc4MjI0MiwiaWF0IjoxNjY2Nzc4NjQyLCJqdGkiOiI3Y2M4MDk4MS00ZDhjLTQwMTYtOWQzZS01Njk1N2M0YmY3ZDMiLCJjbGllbnRfaWQiOiIxZTk5NmEzNSJ9.ABX0kpmvgBULcG9_9L_AvvwJd2kXS_FaES081pkmimrb73sYON15VXg9VfTmFHgiaXjYO90xlrNIe007jjoss_Rx3f0lhwEQAKtV72XMhR8wioWJ-BTiJgNlMz8idxdvLUk92ttZ80W850-kRnfS2BPgU94Tzu3rNoQosaipYcn3_RgkkZDoPMPq2i0SlLCBm2vfh3bCAsPZ0VihQXCAhoB2CG20En0bYyBQBIL3MBIndd75bS7cLi6ZTPjB-1Yyc7xzPAYWjEDK-kFmBQA0xHZj4Q_-9kFalJiLe_JpxdCzcRKhB46KoPgGwBJOT1iZVZeSSG8VMFatag8vbNwErQ';
        HttpRequest request = new HttpRequest();
        if (ticketType == 'Incident') {
            request.setHeader('GTItable', 'incident');
            request.setHeader('GTIcatitem', 'AXA_Salesforce_italia');
        } else if (ticketType == 'Service Request') {
            request.setHeader('GTItable', 'sc_req_item');
            request.setHeader('GTIcatitem', 'Salesforce_Italia_service_request');
        }
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', authorizationHeader);
        request.setBody(body);
        request.setEndpoint(conf.EndPoint__c + 'create');
        request.setMethod('POST');
        request.setTimeout(60000);
        System.debug('SILVA **** ticket request : ' + request);
        Http call = new Http();
        HttpResponse response = call.send(request);

        String respString = response.getBody();
        System.debug('SILVA **** ticket response : ' + respString);

        SILVA_Utility.actionsAfterResponse(body, respString, caseData);

        if (SILVA_Utility.isTokenExpired(conf) == true) {
            conf.Silva_Access_Token__c = accessToken;
            conf.Silva_Token_Expiration_DateTime__c = System.Now().addHours(1);
            update conf;
        }

        return response;
    }
}