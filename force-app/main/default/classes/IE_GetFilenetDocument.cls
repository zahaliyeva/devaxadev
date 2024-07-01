/**
 * Created by francesco on 2019-07-09.
 */

public class IE_GetFilenetDocument {

    // 200 -> http://www.mocky.io/v2/5d2488832f0000c697241a3b
    // 500 -> http://www.mocky.io/v2/5d30414a3200000d00204301

    private static IE_Integration_Record__c getIntegrationRecord(String documentId, String filenetInstance, Id scopeId) {
        IE_Integration_Record__c integrationRecord = new IE_Integration_Record__c();
        String configurationName = 'GetFilenetDocument';
        IE_Configuration__c configuration = [
                SELECT Id, NameSpacePrefix1__c, NameSpacePrefix2__c, NameSpaceUri1__c,
                        NameSpaceUri2__c, Type__c, EndPoint__c, Certificate__c, Timeout__c,
                        Name, Insert_IR_WS__c, HTTPMethod__c
                FROM IE_Configuration__c
                WHERE Name = :configurationName
                LIMIT 1
        ];

        documentId = EncodingUtil.urlEncode(documentId, 'UTF-8');

        configuration.EndPoint__c += '/v1/documents/' + documentId + '?filenetInstance=' + filenetInstance;

        System.debug('DBG - URL: ' + configuration.EndPoint__c);

        integrationRecord.ScopeID__c = scopeId;
        integrationRecord.IE_Configuration__c = configuration.Id;
        integrationRecord.URLRequest__c = configuration.EndPoint__c;
        integrationRecord.RequestBody__c = configuration.EndPoint__c; // avoids null pointer exception

        return integrationRecord;
    }

    /**
     * @param documentId Document__c.ID_Filenet__c
     * @param filenetInstance Document__c.Filenet_Platform__c [FN_LOC, FN_REG]
     * @param scopeId SF object record Id (history log)
     */
    public static ResponseDto getDocument(String documentId, String filenetInstance, Id scopeId) {
        documentId = documentId.replace('{', '');
        documentId = documentId.replace('}', '');
        Map<String, String> headerAttributes = getHttpHeaders();
        IE_Integration_Record__c integrationRecord = getIntegrationRecord(documentId, filenetInstance, scopeId);
        IE_Engine IEInstance = new IE_Engine(integrationRecord);
        IEInstance.compileRequest();
        IEInstance.sendRequest(headerAttributes);
        IEInstance.interpretResponse();
        return getResponseDto(IEInstance);

    }

    private static Map<String, String> getHttpHeaders() {
        Map<String, String> headerAttributes = new Map<String, String>();

        headerAttributes.put('Accept', 'application/json');

        List<MPS_Code_Utils__mdt> mpsCodeUtils = [
                SELECT Key__c, Value__c
                FROM MPS_Code_Utils__mdt
                WHERE DeveloperName LIKE 'GetFilenetDocumentHeader%'
                AND Key__c != NULL
                AND Value__c != NULL
        ];

        for (MPS_Code_Utils__mdt mps : mpsCodeUtils) {
            headerAttributes.put(mps.Key__c, mps.Value__c);

        }

        System.debug('DBG - headerAttributes: ' + headerAttributes);

        return headerAttributes;
    }

    private static ResponseDto getResponseDto(IE_Engine IEInstance) {
        Integer statusCode = IEInstance.RawResponse.getStatusCode();
        String json = IEInstance.JSONResponse;
        GetFilenetDocumentResponse body = (GetFilenetDocumentResponse) System.JSON.deserialize(json, GetFilenetDocumentResponse.class);
        return new ResponseDto(statusCode, body);
    }

    public class ResponseDto { // Object to better handle errors from http://blog.terrasky.com/blog/how-to-handle-apex-errors-for-lightning-component-implementations
        public Integer statusCode;
        public GetFilenetDocumentResponse body;

        public ResponseDto(Integer statusCode, GetFilenetDocumentResponse body) {
            this.statusCode = statusCode;
            this.body = body;

        }
    }

}