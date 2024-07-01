/**
 * @author Reply
 * @date 03/2023
 * @description Classe con i metodi utili alla gestione dell'integrazione con Silva
 */
public class SILVA_Utility {
    /**
     * @param 
     * @return responseMap
     * @example 
     * @description Se necessario, il metodo viene chiamato per effettuare la chiamata per prendere l'auth token
     */
    public static Map<String, String> getAuthToken() {
        System.debug('SILVA **** Start getAuthToken');
        IE_Configuration__c conf = [
            SELECT Id, Name, ClientId__c, Client_Secret__c, EndPoint__c
            FROM IE_Configuration__c
            WHERE name = 'SILVA_Get_Token'
            LIMIT 1
        ];
        HttpRequest request = new HttpRequest();
        //request.setHeader('Connection', 'keep-alive');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        String body =
            'client_id=' +
            EncodingUtil.urlEncode(conf.ClientId__c, 'UTF-8') +
            '&client_secret=' +
            EncodingUtil.urlEncode(conf.Client_Secret__c, 'UTF-8') +
            '&grant_type=client_credentials' +
            '&scope=' +
            'urn:axa:axa-go:silva:generic-integration-framework';
        request.setBody(body);
        request.setEndpoint(conf.EndPoint__c);
        request.setMethod('POST');
        //request.setTimeout(60000);
        Http call = new Http();
        HttpResponse response = call.send(request);
        String respString = response.getBody();
        System.debug('SILVA **** respString: ' + respString);
        Map<string, String> responseMap = (Map<string, String>) JSON.deserialize(respString, Map<String, String>.class);
        String accessToken = String.valueOf(responseMap.get('access_token'));
        return responseMap;
    }

    /**
     * @param 
     * @return isExpired
     * @example 
     * @description Controllo se il token � valido o scaduto
     */
    public static boolean isTokenExpired(IE_Configuration__c conf) {
        boolean isExpired = false;
        if (System.now() > conf.Silva_Token_Expiration_DateTime__c) {
            isExpired = true;
        }
        return isExpired;
    }

    /**
     * @param ticketType, requestBody, respString, isSuccess
     * @return 
     * @example 
     * @description Inserimento dell'IE_Integration_Record__c dopo la chiamata
     */
    public static void insertIr(String ticketType, String requestBody, String respString, boolean isSuccess) {
        IE_Configuration__c conf = [
            SELECT Id, Name, EndPoint__c, Silva_Access_Token__c, Silva_Token_Expiration_DateTime__c
            FROM IE_Configuration__c
            WHERE name = 'SILVA_generic'
            LIMIT 1
        ];
        System.debug('SILVA **** start insertIr');
        IE_Integration_Record__c ir = new IE_Integration_Record__c();
        ir.IE_Configuration__c = conf.id;
        ir.RequestBody__c = requestBody;
        ir.URLRequest__c = conf.Endpoint__c + 'create';
        ir.ResponseBody__c = respString;
        if (isSuccess == true) {
            ir.status__c = 'OK';
        } else {
            ir.status__c = 'Failure';
        }
        insert ir;
    }

    /**
     * @param requestBody, respString, caseData
     * @return 
     * @example 
     * @description update del case dopo la chiamata e chiamata al metodo InsertIr
     */
    public static void actionsAfterResponse(String requestBody, String respString, Case caseData) {
        boolean isSilvaSuccess = isSilvaSuccess(respString);
        SILVA_Ticket_Response str = DeserializeResponse(respString);
        //str = (SILVA_Ticket_Response) JSON.deserialize(respString, SILVA_Ticket_Response.class);
        if (isSilvaSuccess == true) {
            caseData.Stato_Integrazione_Silva__c = 'Success';
            caseData.Silva_Id__c = str.result.SilvaNumber;
        } else {
            caseData.Stato_Integrazione_Silva__c = 'Error';
        }
        update caseData;
        insertIr(caseData.Tipologia_Ticket_Silva__c, requestBody, respString, isSilvaSuccess);
    }

    /**
     * @param respString
     * @return SILVA_Ticket_Response
     * @example 
     * @description deserializzazione della response
     */
    private static SILVA_Ticket_Response DeserializeResponse(String respString) {
        if (respString.contains('[')) {
            respString = respString.replace('result', 'resultList');
        }
        if (respString.contains('number')) {
            respString = respString.replace('number', 'SilvaNumber');
        }
        return (SILVA_Ticket_Response) JSON.deserialize(respString, SILVA_Ticket_Response.class);
    }

    /**
     * @param respString
     * @return isSilvaSuccess
     * @example 
     * @description controllo se la chiamata e andata a buon fine ed ha restituito un success
     */
    public static boolean isSilvaSuccess(String respString) {
        boolean isSilvaSuccess = false;
        SILVA_Ticket_Response str = DeserializeResponse(respString);
        System.debug('SILVA **** str ' + str);
        if (str.status == 'failure') {
            isSilvaSuccess = false;
        } else if (str.status != 'failure' && str.result.GTIstatus == 'success') {
            isSilvaSuccess = true;
        }
        return isSilvaSuccess;
    }
}