/**
 * Created by francesco on 2019-07-10.
 */
@IsTest
public class VFC34_GetFilenetDocumentCTRL_TEST {

    @TestSetup
    static void setup() {

        ServiceUtilsClass.populateCustomSettingsForTests();

        AAI_Code_Variables__c acv1 = new AAI_Code_Variables__c(
                Name = 'GetFilenetDocumentMissingArguments',
                Value__c = 'Informazioni mancanti per la visualizzazione del documento'
        );

        AAI_Code_Variables__c acv2 = new AAI_Code_Variables__c(
                Name = 'GetFilenetDocumentError',
                Value__c = 'Impossibile visualizzare il documento richiesto - Stato: {!STATUS} - ID Documento: {!ID}'
        );

        insert new List<AAI_Code_Variables__c>{
                acv1, acv2
        };

        IE_Configuration__c configuration = new IE_Configuration__c();
        configuration.Name = 'GetFilenetDocument';
        configuration.HTTPMethod__c = 'GET';
        configuration.Direction__c = 'OUTBOUND';
        configuration.Type__c = 'WebService_rest';
        configuration.Request_compiler__c = 'IE_Request_GetFilenetDocument';
        configuration.Response_parser__c = 'IE_Parser_GetFilenetDocument';
        configuration.EndPoint__c = 'https://test/get-filenet-document';
        configuration.log_records_flag__c = true;
        insert configuration;

        Id B2CId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('B2C_Client').getRecordTypeId();

        Account acc = new Account(
                FirstName = 'Piermauro',
                LastName = 'Tagliabue',
                NDG__c = '0008280000000888',
                AAI_Codice_fiscale__c = 'TGLPRM54C14G218F',
                RecordTypeId = B2CId);
        insert acc;
        /*
        Document__c doc = new Document__c(
                ID_Filenet__c = '234rt4873y958hjbg',
                Filenet_Platform__c = 'FN_LOC',
                Name = 'Documento Test',
                Account__c = acc.Id
        );
        insert doc;
        */

        Massive_Communication__c com = new Massive_Communication__c(
            Document_Univocal_Key__c = '{234rt4873y958hjbg}FN_LOC',
            Name = 'Com Test',
            Account__c = acc.Id

        );
        insert com;
    }

    private class OK implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {

            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');

            String content = 'XG9SFRHik9I6fvM8XL5FnF+IUnFepK39lu4TJcTbFDJpDSR4VFV4CPfDEE2ZhauGv/cIrjdAC2e4Ar0v+3OCbb' +
                    'Hpm364fOQ4WXCeqeXhgGbuX6d9kdIg1a6H6deD+PHzAnB88h0lmlnonZbPUTKJrguCN9Cz3iEUD3/vc04Cmyr9NNJpn9n10' +
                    'bqNQmb0ag0bLZV/Orqdo9FaVGKcU3Btw/oeDQzqPGGefz/Vqty8MTL2MJN9cOPRuM9p/WlijWKL0kgVofc/8707wMoLSj8u' +
                    '0I1P6THJHyXOoLV/kaETZ5BDpjwfU167NyBGNQ7OY7StBYXEshAiPbOSocIU8/k7';

            JSONGenerator generator = JSON.createGenerator(true);
            generator.writeStartObject();
            generator.writeFieldName('data');
            generator.writeStartObject();
            generator.writeStringField('type', 'document');
            generator.writeStringField('id', '9088515552cb681');
            generator.writeFieldName('attributes');
            generator.writeStartObject();
            generator.writeStringField('fileName', 'document.pdf');
            generator.writeStringField('mimeType', 'application/pdf');
            generator.writeStringField('content', content);
            generator.writeStringField('fileSize', '8000');
            generator.writeEndObject();
            generator.writeEndObject();
            generator.writeEndObject();

            String body = generator.getAsString();
            res.setBody(body);
            res.setStatusCode(200);

            return res;
        }
    }

    private class internalServerError implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {

            HttpResponse res = new HttpResponse();
            res.setHeader('Accept', 'application/json');

            JSONGenerator generator = JSON.createGenerator(true);

            generator.writeStartObject();
            generator.writeFieldName('error');
            generator.writeStartArray();
            generator.writeStartObject();
            generator.writeStringField('id', '3hfrgejnytbrfedrvtbn-thr-eqrfgh6575453');
            generator.writeStringField('status', 'Internal Server error');
            generator.writeStringField('code', '500');
            generator.writeStringField('title', 'Titolo errore');
            generator.writeStringField('detail', 'Dettagli errore');
            generator.writeFieldName('source');
            generator.writeStartObject();
            generator.writeStringField('pointer', '213rt45yju6kjyhtgrfe');
            generator.writeStringField('parameter', '32rt4yh5j654t3r2defrvg');
            generator.writeEndObject();
            generator.writeEndObject();
            generator.writeEndArray();

            String body = generator.getAsString();

            res.setBody(body);
            res.setStatusCode(500);

            return res;
        }
    }

    @IsTest
    static void OKTest() {
        Massive_Communication__c doc = [SELECT Id FROM Massive_Communication__c WHERE Name = 'Com Test' LIMIT 1];

        Test.startTest();

        PageReference pageRef = Page.VFP34_GetFilenetDocument;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', doc.Id);
        Test.setMock(HttpCalloutMock.class, new OK());
        VFC34_GetFilenetDocumentCTRL controller = new VFC34_GetFilenetDocumentCTRL();
        controller.getDocument();

        Test.stopTest();


        System.assert(controller.isSuccess);
        System.assertEquals('application/pdf', controller.contentType);
        System.assertNotEquals(null, controller.pdf);

    }

    @IsTest
    static void InternalServerErrorTest() {
        Massive_Communication__c doc = [SELECT Id FROM Massive_Communication__c WHERE Name = 'Com Test' LIMIT 1];

        Test.startTest();

        PageReference pageRef = Page.VFP34_GetFilenetDocument;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', doc.Id);
        Test.setMock(HttpCalloutMock.class, new internalServerError());
        VFC34_GetFilenetDocumentCTRL controller = new VFC34_GetFilenetDocumentCTRL();
        controller.getDocument();

        Test.stopTest();

        System.assert(!controller.isSuccess);
    }

    @IsTest
    static void otherErrorTest() {
        Massive_Communication__c doc = [SELECT Id FROM Massive_Communication__c WHERE Name = 'Com Test' LIMIT 1];
        doc.Document_Univocal_Key__c = null;
        update doc;

        Test.startTest();

        PageReference pageRef = Page.VFP34_GetFilenetDocument;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', doc.Id);
        VFC34_GetFilenetDocumentCTRL controller = new VFC34_GetFilenetDocumentCTRL();
        controller.getDocument();

        Test.stopTest();

        System.assert(!controller.isSuccess);

    }

}