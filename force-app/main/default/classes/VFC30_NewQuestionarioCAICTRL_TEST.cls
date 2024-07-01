@isTest
public class VFC30_NewQuestionarioCAICTRL_TEST {
    
    @testSetup static void setup() 
    {
        //MDANTONIO 09/04/2019 popolamento custom settings per classi di test - start
        ServiceUtilsClass.populateCustomSettingsForTests();
        //MDANTONIO 09/04/2019 popolamento custom settings per classi di test - end
        List<Profile> profiles2 = [SELECT Id, Name FROM Profile WHERE Name = 'Caring Angel - Supporto HD1'];
        Profile p2;
        Id pSupport;
        Map<String,Id> mapAccountRecordtype = AP_Constants.getDeveloperIdMap( AP_Constants.sobjectAcc );
        if (profiles2.size() > 0)
        {
            p2       = profiles2[0];
            pSupport = p2.Id;
        } 
        
        Account acct = new Account(FirstName='TestName',
                                   LastName='TestSurname',
                                   Fiscal_ID__c='Fiscal1',
                                   PersonBirthDate=Date.valueOf('1986-01-01'),
                                   RecordtypeId = mapAccountRecordtype.get(AP_Constants.rtAccIndividualClient));
        insert acct;
        
        /*Account   acc2 = new Account(FirstName='TestName\'s 2',
                                     LastName='TestSurname\'s 2',
                                     AAI_Codice_fiscale__c='Fiscal2',
                                     PersonBirthDate=Date.valueOf('1986-01-01'),
                                     RecordtypeId = mapAccountRecordtype.get(AP_Constants.rtAccB2C));
        insert acc2;*/
        
        User newSupport = new User(Username                     = 'supporto@axa.test.com',
                                   LastName                     = 'testuser2',
                                   LanguageLocaleKey            = 'it',
                                   FirstName                    = 'test2',
                                   Email                        = 'test2@test.com', 
                                   Alias                        = 'test2',
                                   TimeZoneSidKey               = 'Europe/Dublin',
                                   LocaleSidKey                 = 'it_IT',
                                   EmailEncodingKey             = 'UTF-8',
                                   ProfileId                    = pSupport);
        insert newSupport;
        
        Account   acc2 = new Account(FirstName='TestName\'s 2',
                                     LastName='TestSurname\'s 2',
                                     AAI_Codice_fiscale__c='Fiscal2',
                                     PersonBirthDate=Date.valueOf('1986-01-01'),
                                     RecordtypeId = mapAccountRecordtype.get(AP_Constants.rtAccB2C),
                                    OwnerId = newSupport.Id );
        insert acc2;
        Case caseObj1 = new Case(Status    = 'Open',
                                 Origin    = 'Phone',
                                 OwnerId   = newSupport.Id,
                                 AccountId=acc2.id,
                                recordtypeid = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(AP_Constants.rtCaseSinistro).getRecordTypeId());
        insert caseObj1;
        
        AAI_Code_Variables__c modAcc= new AAI_Code_Variables__c();
        modAcc.Name='AccountEdit_IRSavingLink';
        modAcc.Value__c='https://axaitalia--pre.cs80.my.salesforce.com/';
        insert  modAcc;
        //OAVERSANO 21/05/2019 : AXA Assistance Enhancement Fase I -- START
        MPS_Code_Variables__c modCase= new MPS_Code_Variables__c();
        modCase.Name='RecordTypeSinistriLabel';
        modCase.Value__c='Sinsitri AAI;Sinistri Danni Banca;';
        insert  modCase;
        //OAVERSANO 21/05/2019 : AXA Assistance Enhancement Fase I -- END        
    }
    
    public class Test_MockIE_CreateClaim implements HttpCalloutMock 
    {
        
        public HTTPResponse respond(HTTPRequest req) 
        {                 
            HttpResponse res = new HttpResponse();
            res.setHeader('Accept-Encoding','gzip,deflate');
            res.setHeader('Content-Type','application/json'); 
            res.setHeader('Content-Length','207'); 
            res.setHeader('Host','esg-pp.axa-medla.com'); 
            res.setHeader('Connection','Keep-Alive');
            res.setHeader('User-Agent','Apache-HttpClient/4.1.1 (java 1.5)');   
            res.setBody('{"MessageBody":{"Url":"http://precol.axa-italia.it/AXA_DENUNCE/Digital/CaringAngel/AperturaSinistroCaringAngel.aspx?IdCase=50025000007iqCsAAI&Valerr=21","Errori":null},"MessageHeader":{"ResultMessage":1,"Resultexception":null}}');
            res.setStatusCode(500);
            return res;
        }
    } 
    
    static testMethod void testmethod1() 
    {
        test.StartTest();
        
        User    support      = [SELECT Id, ProfileId FROM User WHERE Username = 'supporto@axa.test.com' LIMIT 1];
        Account currentAcc = [SELECT Id FROM Account where Fiscal_ID__c = 'Fiscal1' LIMIT 1];
        List<Case> caseobj = [SELECT Id, Origin FROM Case LIMIT 1];
        
        
        System.runAs(support)
        {
            Questionario_CA__c quest = new Questionario_CA__c();
            //OAVERSANO 21/05/2019 : AXA Assistance Enhancement Fase I -- START
            quest.Email_Contraente__c = 'prova@test.com';
            quest.Case__c = caseobj[0].Id;
            //OAVERSANO 21/05/2019 : AXA Assistance Enhancement Fase I -- END
            List<String> pickList = new List<String>{'Compagnia__c','Ambulanza__c','Autorit__c','Carro__c','Claim_Type__c','Event_Type__c','Feriti__c','Tipo_controparte__c','Note_ambulanza__c','Note_autorit__c','Note_carroattrezzi__c','Sinistro_canalizzabile__c','Sinistro_canalizzato__c','assistenza_cai_richiesta__c'};
                Map<String, String> parameterMap = new Map<String,String>();
            parameterMap.put('lob','Motor');
            parameterMap.put('category','Sinistro Caring Angel');
            parameterMap.put('subcategory','Denuncia sinistro'); 
            VFC30_NewQuestionarioCAICTRL.WrapperClass WrToReturn = new VFC30_NewQuestionarioCAICTRL.WrapperClass();
            WrToReturn = VFC30_NewQuestionarioCAICTRL.initializeCaCTRL(currentAcc.Id, quest, pickList, 'insert', parameterMap, '','');
            WrToReturn = VFC30_NewQuestionarioCAICTRL.initializeCaCTRL('', quest, pickList, 'insert', parameterMap, '',caseobj[0].Id);
            String toReturn = VFC30_NewQuestionarioCAICTRL.upsertQuestionarioCACTRL(quest, '11', '30', '12', '45', currentAcc.Id,'','test');
        }
        
        test.stopTest();
    } 
    
    static testMethod void testmethod2() 
    {
        test.StartTest();
        
        User    support      = [SELECT Id, ProfileId FROM User WHERE Username = 'supporto@axa.test.com' LIMIT 1];
        List<Case> caseobj = [SELECT Id, Origin FROM Case LIMIT 1];
        Account currentAcc = [SELECT Id FROM Account where AAI_Codice_fiscale__c = 'Fiscal2' LIMIT 1];
        
        System.runAs(support)
        {
            Questionario_CA__c quest = new Questionario_CA__c(Case__c= caseobj[0].id);
            insert quest;
            List<String> pickList = new List<String>{'Compagnia__c','Ambulanza__c','Autorit__c','Carro__c','Claim_Type__c','Event_Type__c','Feriti__c','Tipo_controparte__c','Note_ambulanza__c','Note_autorit__c','Note_carroattrezzi__c'};
                Map<String, String> parameterMap = new Map<String,String>();
            parameterMap.put('lob','Motor');
            parameterMap.put('category','Sinistro Caring Angel');
            parameterMap.put('subcategory','Denuncia sinistro'); 
            VFC30_NewQuestionarioCAICTRL.WrapperClass WrToReturn = new VFC30_NewQuestionarioCAICTRL.WrapperClass();
            WrToReturn = VFC30_NewQuestionarioCAICTRL.initializeCaCTRL(currentAcc.Id, quest, pickList, 'update', parameterMap, quest.id,'');
            String toReturn = VFC30_NewQuestionarioCAICTRL.upsertQuestionarioCACTRL(quest, '11', '30', '12', '45', currentAcc.Id,quest.id,'test');
        }
        
        test.stopTest();
    }     
    
    static testMethod void testmethod3() 
    {
        
        
        User    support      = [SELECT Id, ProfileId FROM User WHERE Username = 'supporto@axa.test.com' LIMIT 1];
        List<Case> caseobj = [SELECT Id, Origin FROM Case LIMIT 1];
        Account currentAcc = [SELECT Id FROM Account where AAI_Codice_fiscale__c = 'Fiscal2' LIMIT 1];
        IE_Configuration__c IE_conf = new IE_Configuration__c(Name = 'SOL_Claim_Insert', HTTPMethod__c='POST', Type__c = 'webservice_rest', 
                                                              Request_compiler__c='IE_SOLClaimOpening_Request_Compiler', Response_parser__c = 'IE_SOLClaimOpening_Response_parser',
                                                              Endpoint__c = 'http://www.mocky.io/v2/5bc9b7c93000007b0085a616',Insert_IR_WS__c=false);
        insert IE_conf;
        
        System.runAs(support)
        {
            Questionario_CA__c quest = new Questionario_CA__c(Case__c= caseobj[0].id,
                                                              Data_Evento__c= Date.newInstance(2018, 2, 17),
                                                              Numero_Polizza__c='1.1340.5.235419458',
                                                              Targa__c='BZ493ZT',
                                                              Nome_contraente__c='ELENA',
                                                              Cognome_Contraente__c='RIPELLINO',
                                                              Data_di_nascita_contraente__c= Date.newInstance(1960, 2, 17),
                                                              Codice_fiscale_contraente__c='FIS1',
                                                              Email_Contraente__c = 'prova@test.com', //OAVERSANO 21/05/2019 : AXA Assistance Enhancement Fase I -- START
                                                              Indirizzo_Contraente__c='VIA PO 1',
                                                              Citt_Contraente__c='ROMA',
                                                              Provincia_Contraente__c='RM',
                                                              Stato_Contraente__c='ITALIA',
                                                              CAP_Contraente__c='00100',
                                                              Nome_conducente__c='ELENA',
                                                              Cognome_conducente__c='RIPELLINO',
                                                              Data_di_nascita_conducente__c= Date.newInstance(1960, 2, 17),
                                                              Codice_fiscale_conducente__c='FIS1',
                                                              Indirizzo_Conducente__c='VIA PO 1',
                                                              Citt_Conducente__c='ROMA',
                                                              Provincia_Conducente__c='RM',
                                                              Stato_Conducente__c='ITALIA',
                                                              CAP_Conducente__c='00100',
                                                              Nome_Controparte__c='PIERO',
                                                              Cognome_Controparte__c='RIPELLINA',
                                                              Data_di_nascita_Controparte__c= Date.newInstance(1960, 2, 20),
                                                              Codice_fiscale_Controparte__c='FIS1',
                                                              Indirizzo_Controparte__c='VIA PO 1',
                                                              Citt_Controparte__c='MILANO',
                                                              Provincia_Controparte__c='MI',
                                                              Stato_Controparte__c='ITALIA',
                                                              CAP_Controparte__c='00100',
                                                              Conducente_contraente__c=true,
                                                              Ambulanza__c='No',
                                                              Autorit__c='No',
                                                              Carro__c = 'No',
                                                              Sinistro_canalizzabile__c='Da verificare',
                                                              Sinistro_canalizzato__c='No',
                                                              assistenza_cai_richiesta__c='No');
            insert quest;
            VFC30_NewQuestionarioCAICTRL.SOL_Response_Details WrToReturn = new VFC30_NewQuestionarioCAICTRL.SOL_Response_Details();
            test.StartTest();
            Test.setMock(HttpCalloutMock.class, new Test_MockIE_CreateClaim());
            WrToReturn = VFC30_NewQuestionarioCAICTRL.OpenNewClaim(quest, caseobj[0].id, quest.id);
            test.stopTest();
        }
        
        
    } 
    
    static testMethod void testmethod4() 
    {
        test.StartTest();
        
        User    support      = [SELECT Id, ProfileId FROM User WHERE Username = 'supporto@axa.test.com' LIMIT 1];
        List<Case> caseobj = [SELECT Id, Origin FROM Case LIMIT 1];
        Account currentAcc = [SELECT Id FROM Account where AAI_Codice_fiscale__c = 'Fiscal2' LIMIT 1];
        
        
        System.runAs(support)
        {
            Questionario_CA__c quest = new Questionario_CA__c(Case__c= caseobj[0].id);
            insert quest;
            
            VFC30_NewQuestionarioCAICTRL.DeleteOutputs WrToReturn = new VFC30_NewQuestionarioCAICTRL.DeleteOutputs();
            WrToReturn = VFC30_NewQuestionarioCAICTRL.eraseRecords(caseobj[0].id, quest.id);
            system.assertEquals(true,WrToReturn.isSuccess);
        }
        
        test.stopTest();
    } 
    
    static testMethod void testmethod5() 
    {
        test.StartTest();
        
        User    support      = [SELECT Id, ProfileId FROM User WHERE Username = 'supporto@axa.test.com' LIMIT 1];
        List<Case> caseobj = [SELECT Id, Origin FROM Case LIMIT 1];
        Account currentAcc = [SELECT Id FROM Account where AAI_Codice_fiscale__c = 'Fiscal2' LIMIT 1];
        
        
        System.runAs(support)
        {
            VFC30_NewQuestionarioCAICTRL.DeleteOutputs WrToReturn = new VFC30_NewQuestionarioCAICTRL.DeleteOutputs();
            WrToReturn = VFC30_NewQuestionarioCAICTRL.eraseRecords(caseobj[0].id, '');
            system.assertEquals(true,WrToReturn.isSuccess);
        }
        
        test.stopTest();
    }        
    
    static testMethod void testmethod6() 
    {
        test.StartTest();
        
        User    support      = [SELECT Id, ProfileId FROM User WHERE Username = 'supporto@axa.test.com' LIMIT 1];
        List<Case> caseobj = [SELECT Id, Origin FROM Case LIMIT 1];
        Account currentAcc = [SELECT Id FROM Account where AAI_Codice_fiscale__c = 'Fiscal2' LIMIT 1];
        
        
        System.runAs(support)
        {
            VFC30_NewQuestionarioCAICTRL.DeleteOutputs WrToReturn = new VFC30_NewQuestionarioCAICTRL.DeleteOutputs();
            WrToReturn = VFC30_NewQuestionarioCAICTRL.eraseRecords('testca', '');
            system.assertEquals(false,WrToReturn.isSuccess);
        }
        
        test.stopTest();
    }   
    
    static testMethod void testmethod7() 
    {
        test.StartTest();
        
        User    support      = [SELECT Id, ProfileId FROM User WHERE Username = 'supporto@axa.test.com' LIMIT 1];
        List<Case> caseobj = [SELECT Id, Origin FROM Case LIMIT 1];
        Account currentAcc = [SELECT Id FROM Account where AAI_Codice_fiscale__c = 'Fiscal2' LIMIT 1];
        
        
        System.runAs(support)
        {
            VFC30_NewQuestionarioCAICTRL.DeleteOutputs WrToReturn = new VFC30_NewQuestionarioCAICTRL.DeleteOutputs();
            WrToReturn = VFC30_NewQuestionarioCAICTRL.eraseRecords('', 'testque');
            system.assertEquals(false,WrToReturn.isSuccess);
        }
        
        test.stopTest();
    }

    static testMethod void testmethod8() 
    {
        test.StartTest();
        
        User    support      = [SELECT Id, ProfileId FROM User WHERE Username = 'supporto@axa.test.com' LIMIT 1];
        Account currentAcc = [SELECT Id FROM Account where AAI_Codice_fiscale__c = 'Fiscal2' LIMIT 1];
        Case c = new Case(Accountid=currentAcc.id,RecordtypeId=Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(AP_Constants.rtCaseCaringAngel).getRecordTypeId());
        insert c;
        Questionario_CA__c q = new Questionario_CA__c(Case__c=c.id);
        insert q;
        InsurancePolicy__c pol = new InsurancePolicy__c(Name='1234',Tech_company__c='AAI',Cuid__c=currentAcc.id);
        insert pol;

        PageReference pageRef = Page.VFP30_NewQuestionarioCAI;   
        Test.setCurrentPage(pageRef);
       
        ApexPages.currentPage().getParameters().put('caseId', c.Id);

        ApexPages.StandardController sc = new ApexPages.StandardController(q);
        VFC30_NewQuestionarioCAICTRL vf = new VFC30_NewQuestionarioCAICTRL(sc);
        

        Boolean checkpol = VFC30_NewQuestionarioCAICTRL.VerifyPolicy('1234');
        system.assertEquals(checkpol,true);
        VFC30_NewQuestionarioCAICTRL.DeleteOutputs WrToReturn = new VFC30_NewQuestionarioCAICTRL.DeleteOutputs();
        WrToReturn = VFC30_NewQuestionarioCAICTRL.eraseRecords('', 'testque');
        system.assertEquals(false,WrToReturn.isSuccess);
        
        
        test.stopTest();
    }   
    
     static testMethod void testmethod9() 
    {
        test.StartTest();
        VFC30_NewQuestionarioCAICTRL.calculateFiscalCodeCtrl('Salvi', 'Filippo', 'Milano', 'Mi', '1972-10-01', 'M');
        test.stopTest();
    }    
    
        static testMethod void testmethod10() 
    {
        test.StartTest();
        VFC30_NewQuestionarioCAICTRL.getListOfRegularExpressions();
        test.stopTest();
    }
    static testMethod void testmethod11(){
        List<Case> caseobj = [SELECT Id, Origin FROM Case LIMIT 1];
        test.StartTest();
        List<RecordType> rec = [Select DeveloperName, id from Recordtype where sobjecttype = 'Testimone_Ferito__c'];
        Map<String, id> mapRec = new Map<String, Id>();
        for(Recordtype temp: rec){
            maprec.put(temp.Developername, temp.ID);

        }
        User    support      = [SELECT Id, ProfileId FROM User WHERE Username = 'supporto@axa.test.com' LIMIT 1];
        Account currentAcc = [SELECT Id FROM Account where Fiscal_ID__c = 'Fiscal1' LIMIT 1];
        system.debug(caseobj);
        
        
        
        
        
        
            Questionario_CA__c quest = new Questionario_CA__c();
            //OAVERSANO 21/05/2019 : AXA Assistance Enhancement Fase I -- START
            quest.Email_Contraente__c = 'prova@test.com';
            quest.Case__c = caseobj[0].Id;
            //OAVERSANO 21/05/2019 : AXA Assistance Enhancement Fase I -- END
            
            
          	/**/
            list<Testimone_Ferito__c> Testimoni = new List<Testimone_Ferito__c>();
            list<Testimone_Ferito__c> Feriti = new List<Testimone_Ferito__c>();
            
            Testimoni.add(new Testimone_Ferito__c(nome__c = 'AAA', cognome__c = 'BBB', recordtypeId = mapRec.get('Testimone')));
            Feriti.add(new Testimone_Ferito__c(nome__c = 'AAAA', cognome__c = 'BBBB', recordtypeId = mapRec.get('Ferito')));
            VFC30_NewQuestionarioCAICTRL.upsertQuestionarioCACTRL(quest,null,'11', '30', '12', '45', currentAcc.Id,quest.id,'','',Testimoni,Feriti,'Test');
        VFC30_NewQuestionarioCAICTRL.initializeFeritiCTRL(String.valueOf(quest.id), new list<Testimone_Ferito__c>());
            VFC30_NewQuestionarioCAICTRL.initializeTestimoniCTRL(String.valueOf(quest.id), new list<Testimone_Ferito__c>());
            //VFC30_NewQuestionarioCAICTRL.upsertQuestionarioCACTRL(questionario,oraEvento,minutiEvento,oraRecall,minutiRecall,accountIdToUpdate,QuestionarioToUpdate,null,null,null,null,surveyStatus);
        
        test.stopTest();
        
    }
}