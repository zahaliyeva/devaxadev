/**
 * Created by francesco on 2019-07-09.
 */

public with sharing class VFC34_GetFilenetDocumentCTRL {

    @AuraEnabled
    public String pdf { get; private set; }
    @AuraEnabled
    public String contentType { get; private set; }
    @AuraEnabled
    public Boolean isSuccess { get; private set; }
    @AuraEnabled
    public String message { get; private set; }

    public VFC34_GetFilenetDocumentCTRL() {
    }

    public void getDocument() {

        try {

            Id recordId = ApexPages.currentPage().getParameters().get('id');

            /*Document__c doc = [
                    SELECT Id, ID_Filenet__c, Filenet_Platform__c, Document_Univocal_Key__c
                    FROM Document__c
                    WHERE Id = :recordId
            ];*/
            Massive_Communication__c com = [
                SELECT Id, Document_Univocal_Key__c
                FROM Massive_Communication__c
                WHERE Id = :recordId
            ];

            String FilenetId, FilenetPlatform;
            if(com != null && String.isNotBlank(com.Document_Univocal_Key__c)){
                FilenetId = com.Document_Univocal_Key__c.substring(0, com.Document_Univocal_Key__c.indexOf('}')+1);
                FilenetPlatform = com.Document_Univocal_Key__c.substringAfter('}');
            }

            if (String.isBlank(FilenetId) || String.isBlank(FilenetPlatform)) {
                isSuccess = false;
                message = 'Cannot call the service - Missing arguments';

                AAI_Code_Variables__c acv = AAI_Code_Variables__c.getValues('GetFilenetDocumentMissingArguments');
                if (acv != null && String.isNotBlank(acv.Value__c)) {
                    message = acv.Value__c;
                }

            } else {

                System.debug('DBG - getDocumentRequest(' + FilenetId + ', ' + FilenetPlatform + ', ' + recordId + ')');
                IE_GetFilenetDocument.ResponseDto response = IE_GetFilenetDocument.getDocument(FilenetId, FilenetPlatform, recordId);

                isSuccess = response.statusCode == 200;

                if (isSuccess) {
                    contentType = response.body.data.attributes.mimeType;
                    pdf = response.body.data.attributes.content;

                } else {

                    message = 'An error occurred loading the document' +
                            ' - Status: ' + response.statusCode +
                            ' - Document ID: ' + FilenetId.replace('{','').replace('}','') + FilenetPlatform;

                    AAI_Code_Variables__c acv = AAI_Code_Variables__c.getValues('GetFilenetDocumentError');
                    if (acv != null && String.isNotBlank(acv.Value__c)) {
                        message = acv.Value__c;
                        message = message.replace('{!STATUS}', String.valueOf(response.statusCode));
                        message = message.replace('{!ID}', String.valueOf(FilenetId.replace('{','').replace('}','') + FilenetPlatform));
                    }

                }
            }

        } catch (Exception e) {
            isSuccess = false;
            AAI_Code_Variables__c acv = AAI_Code_Variables__c.getValues('GetFilenetDocumentMissingArguments');
                if (acv != null && String.isNotBlank(acv.Value__c)) {
                    message = acv.Value__c;
                }
            /*String error = e.getTypeName() + ' - ' + e.getMessage() + ' - ' + e.getStackTraceString();
            System.debug('DBG - Exception: ' + error);
            message = error;*/
        }

    }

}