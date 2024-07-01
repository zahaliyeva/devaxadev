/*------------------------------------------------------------------------
Author:        Francesca Marchese
Company:       Deloitte
Class:         BatchICFIntegrationTest
Description:   Test class for BatchICFIntegration class

History

27/12/2016     Created - F.M.
----------------------------------------------------------------------------*/
/**
 * @description PURE IT 22/05 - commentata la classe
 */
@istest
public class BatchICFIntegrationTest{
    /** PURE IT
    @testSetup static void setup() { //preparing test database
        // UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        // system.debug('portalRole is ' + portalRole);

        // Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
        // User portalAccountOwner1 = new User(
        // UserRoleId = portalRole.Id,
        // ProfileId = profile1.Id,
        // Username = System.now().millisecond() + 'test2@test.com',
        // Alias = 'batman',
        // Email='bruce.wayne@wayneenterprises.com',
        // EmailEncodingKey='UTF-8',
        // Firstname='Bruce',
        // Lastname='Wayne',
        // LanguageLocaleKey='en_US',
        // LocaleSidKey='en_US',
        // TimeZoneSidKey='America/Chicago'
        // );
        // Database.insert(portalAccountOwner1);

        // //User u1 = [Select ID From User Where Id =: portalAccountOwner1.Id];

        // System.runAs ( portalAccountOwner1 ) {
            // //Create account
            // Account portalAccount1 = new Account(
            // Name = 'TestAccount',
            // OwnerId = portalAccountOwner1.Id
            // );
            // Database.insert(portalAccount1);

            // //Create contact
            // Contact contact1 = new Contact(
            // FirstName = 'Test',
            // Lastname = 'McTesty',
            // AccountId = portalAccount1.Id,
            // Email = System.now().millisecond() + 'test@test.com'
            // );
            // Database.insert(contact1);

            // //Create user
            // Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'NFE - AAI - Vendite Avanzato'];
            // Profile baseProfile = [SELECT Id FROM Profile WHERE  Name='NFE - AAI - Vendite Base'];
            // User usr000828 = new User(
            // FirstName='Agente000828',
            // LastName = 'TESTUSER000', 
            // Alias = 'mree000', 
            // Email = 'mreekmans000@deloitte.com', 
            // Username = 'mreekm000@axa.com.masterdev',
            // ContactId = contact1.Id, 
            // CommunityNickname = 'MartiRe000', 
            // LanguageLocaleKey = 'en_US',
            // TimeZoneSidKey='Europe/Rome',
            // Agency_Code__c = '000828',
            // Nodes__c = 'DIF_000828',
            // Profileid = portalProfile.Id,
            // LocaleSidKey='en_US',
            // EmailEncodingKey='ISO-8859-1'
            
            // ); 

            // Database.insert(usr000828);

            //config record
            AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
            insert acv;
            IE_Configuration__c Integration_record = new IE_Configuration__c();
            Integration_record.Name = 'ICF_Sales';
            Integration_record.Type__c = 'WebService';
            Integration_record.Direction__c = 'OUTBOUND';
            Integration_record.EndPoint__c = '___https://axa-api.sandsiv.com__STOP'; 
            Integration_record.Request_compiler__c = 'IE_ICF_Compiler';
            Integration_record.Response_parser__c = 'IE_ICF_Parser';
            insert Integration_record;
            //child records
            IE_CR2PH_junction__c junc = new IE_CR2PH_junction__c();
            junc.ExpV_External__c='';
            junc.ExpV_SFDC__c='';
            junc.FieldToUse__c='Account__r.Age__c';
            junc.IE_Configuration__c=Integration_record.id;
            junc.Is_Nillable__c=true;
            junc.SObject_Type__c='Interazione__c';
            junc.Tag__c='Age';
            junc.Type__c='REQUEST';
            insert junc;
            
            // system.debug('INTEGRATION RECORD' +Integration_record);

            Account ac = new Account (
            FirstName = 'test',
            LastName = 'LeadTest',
            CIF_PersonEmail__c = 'dfabris@deloitte.it',
            Phone = '0333333333',
            CIF_PersonMobilePhone__c = '23492349',
            NDG__c = '0008280000001175',
            Nodes__c = '000828;000828000302',
            TECH_Company__c='AAI',
            AAI_Agency_Reference_Code__c='000828'
            
            );
            Database.insert(ac);          
            
            system.debug('ACCOUNT INSERTED'+ac);
            
            Interazione__c interazione = new Interazione__c();
            interazione.Account__c=ac.Id;
            interazione.Stato__c='Questionario inviato';
            interazione.Tipologia__c='Altro';
            interazione.Tipologia_Prodotto__c='AUTO';
            interazione.TECH_Da_inviare__c=True;
            Database.insert(interazione);

            system.debug('INTERAZIONE'+interazione);


            // //check lista interazioni
            // //List<Interazione__c> checkList = [select id, TECH_Da_inviare__c from Interazione__c];
            // List<Interazione__c> checkList2= [SELECT Id, Account__c, Account__r.NDG__c, Account__r.FirstName, Account__r.LastName, Account__r.Gender__c, Account__r.Age__c, Account__r.AAI_Codice_fiscale__c, Account__r.CIF_PersonEmail__c, Account__r.CIF_PersonMobilePhone__c, Account__r.Promotional_privacy__c, Account__r.Market_research_privacy__c, Account__r.AAI_Agency_Reference_Code__c, CreatedDate, Tipologia__c,Tipologia_Prodotto__c, CreatedById, TECH_Da_inviare__c, Stato__c, Questionario_richiesto_da__c, Created_By__c FROM Interazione__c  WHERE TECH_Da_inviare__c=true AND Limite_massimo_invio_survey__c >=TODAY AND (Account__r.CIF_PersonEmail__c!=null OR Account__r.CIF_PersonMobilePhone__c !=null) AND Stato__c='Questionario inviato' LIMIT 100];
            // //system.debug('+è+è+è'+checklist);
            // system.debug('+è+è+è'+checklist2);

        // }
    }



    static testmethod void TEST_SendSurveys(){
            //batch.query =  'SELECT Id, Account__c, Account__r.NDG__c, Account__r.FirstName, Account__r.LastName, Account__r.Gender__c, Account__r.Age__c, Account__r.AAI_Codice_fiscale__c, Account__r.CIF_PersonEmail__c, Account__r.CIF_PersonMobilePhone__c, Account__r.Promotional_privacy__c, Account__r.Market_research_privacy__c, Account__r.AAI_Agency_Reference_Code__c, CreatedDate, Tipologia__c,Tipologia_Prodotto__c, CreatedById, TECH_Da_inviare__c, Stato__c, Questionario_richiesto_da__c, Created_By__c FROM Interazione__c  WHERE TECH_Da_inviare__c=true AND Limite_massimo_invio_survey__c >=TODAY AND (Account__r.CIF_PersonEmail__c!=null OR Account__r.CIF_PersonMobilePhone__c !=null) AND Stato__c=\'Questionario inviato\' LIMIT 100'; 
            //system.debug('batch.query'+batch.query);
            Test.startTest();
            BatchICFIntegration batch = new BatchICFIntegration();
            Test.setMock(HttpCalloutMock.class, new fakecallout());
            ID batchprocessid = Database.executeBatch(batch,200); 
            Test.stopTest();
            List<Feedback__c> allF = [SELECT Id from Feedback__c];
            update allF;//for covering trigger handler
            delete allF;//for covering trigger handler
    }


    public class fakecallout implements HttpCalloutMock {

    public HTTPResponse respond(HTTPRequest req) {



        // Create a fake response based on the attribute TestCase
        HttpResponse res = new HttpResponse();

        string myXml='<soapenv:Envelope xmlns="urn:partner.soap.sforce.com" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Header /><soapenv:Body><elencoInterazionipercuihoinviatoSurvey><input><Id_of_import_operation>680</Id_of_import_operation></input></elencoInterazionipercuihoinviatoSurvey></soapenv:Body></soapenv:Envelope>';
        
        myXml=myXml.normalizespace();
        res.setBody(myXml);
        return res;
    }

    }    


PURE IT */
}