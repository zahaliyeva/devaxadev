@isTest
private class LM_Email_CTRL_TEST{
    
    static BusinessHours bhAfterLunch;
    static BusinessHours bhBeforeLunch;
    static List<Lead> theLeads;
    static Lead theLead;
    static List<Lead> theLeadsAuto;
    static Lead theLeadAuto;
    static List<Lead> theLeadsTurismo;
    static Lead theLeadTurismo;
    static List<Lead> theLeadsSitiAgenti;
    static Lead theLeadSitiAgenti;
    static LM_Email_CTRL testClass;
    
    static User userAdmin;
    
    static void init(){
        
        bhAfterLunch = [SELECT CreatedById,CreatedDate,FridayEndTime,FridayStartTime,Id,IsActive,IsDefault,LastModifiedById,LastModifiedDate,MondayEndTime,MondayStartTime,Name,SaturdayEndTime,SaturdayStartTime,SundayEndTime,SundayStartTime,SystemModstamp,ThursdayEndTime,ThursdayStartTime,TimeZoneSidKey,TuesdayEndTime,TuesdayStartTime,WednesdayEndTime,WednesdayStartTime FROM BusinessHours WHERE Name = 'AAI_Agency_AfterLunch' ];
        bhBeforeLunch = [SELECT CreatedById,CreatedDate,FridayEndTime,FridayStartTime,Id,IsActive,IsDefault,LastModifiedById,LastModifiedDate,MondayEndTime,MondayStartTime,Name,SaturdayEndTime,SaturdayStartTime,SundayEndTime,SundayStartTime,SystemModstamp,ThursdayEndTime,ThursdayStartTime,TimeZoneSidKey,TuesdayEndTime,TuesdayStartTime,WednesdayEndTime,WednesdayStartTime FROM BusinessHours WHERE Name = 'AAI_Agency_BeforeLunch' ];

        theLeads = [SELECT LastName,FirstName,Company,Email,Phone,MobilePhone,Fiscal_ID__c,AAI_Partita_IVA__c,Ultima_data_di_riassegnazione__c,Landing_Page__c,Provenienza_Campagne_Agenti__c FROM Lead WHERE LastName = 'LeadTest' LIMIT 1];
        theLead = null;
        
        theLeadsAuto = [SELECT LastName,FirstName,Company,Email,Phone,MobilePhone,Fiscal_ID__c,AAI_Partita_IVA__c,Ultima_data_di_riassegnazione__c,Landing_Page__c,Provenienza_Campagne_Agenti__c FROM Lead WHERE LastName = 'LeadTest2' LIMIT 1];
        theLeadAuto = null;
        
        theLeadsTurismo = [SELECT LastName,FirstName,Company,Email,Phone,MobilePhone,Fiscal_ID__c,AAI_Partita_IVA__c,Ultima_data_di_riassegnazione__c,Landing_Page__c,Provenienza_Campagne_Agenti__c FROM Lead WHERE LastName = 'LeadTest3' LIMIT 1];
        theLeadTurismo = null;

        theLeadsSitiAgenti = [SELECT LastName,FirstName,Company,Email,Phone,MobilePhone,Fiscal_ID__c,AAI_Partita_IVA__c,Ultima_data_di_riassegnazione__c,Landing_Page__c,Provenienza_Campagne_Agenti__c FROM Lead WHERE LastName = 'LeadTest4' LIMIT 1];
        theLeadSitiAgenti = null;

        if(theLeads.size() > 0){
            theLead = theLeads[0];
        } else {
            system.debug('LEAD IS NULL');
        }  
        
        if(theLeadsAuto.size() > 0){
            theLeadAuto = theLeadsAuto[0];
        } else {
            system.debug('LEAD IS NULL');
        } 
        
        if(theLeadsTurismo.size() > 0){
            theLeadTurismo = theLeadsTurismo[0];
        } else {
            system.debug('LEAD IS NULL');
        } 

        if(theLeadsSitiAgenti.size() > 0){
            theLeadSitiAgenti = theLeadsSitiAgenti[0];
        } else {
            system.debug('LEAD IS NULL');
        }  
        
        
        List<User> usersAdmin = [SELECT Id From User Where Username = 'admin@axa.test.com' Limit 1];
        
        if(usersAdmin.size() > 0){
            userAdmin = usersAdmin[0];
        } else {
            system.debug('USER IS NULL');
        }  
    }
   
    static void executeMethods(Lead theLead, String method){
        
        testClass = new LM_Email_CTRL();
        testClass.relatedToLeadId = theLead.Id;
        
        if (method.equals('getReassignDateTime')){
            
            testClass.getReassignDateTime();
            
        } else if(method.equals('getAgencyString')){
            
            testClass.getAgencyString();
            
        } else if(method.equals('getAgencyNumberString')){
            
            testClass.getAgencyNumberString();
            
        } else if(method.equals('getError')){
            
            testClass.getError('', true);
        
             
        }else if(method.equals('getInfoString')){
            
            testClass.getInfoString();
            
        
        
        }else if(method.equals('getImageDocURL')){
            
            testClass.getImageDocURL();
            
        
        
        }
        
        /*if (testClass.theLead == null && testClass.minDatetimeForReassign == null)
            throw new Exception('Exception - executeMethods');*/
            
    }


    @testSetup static void setup() {
        
        list<Profile> profiles = [SELECT Id,Name FROM Profile WHERE Name in ('System Administrator') ];
        Profile p;
        Id pSadmin;
        if (profiles.size() > 0){
            p = profiles[0];
            pSadmin = p.Id;
        } else {
            system.debug('ERRORE NELLA ASSEGNAZIONE PROFILO ADMIN');
        }
        
        UserRole role = [SELECT Id FROM UserRole where name = 'AXA Assicurazioni'];
        Id pRol = role.Id;
        
        User userInsert = new User(Username = 'admin@axa.test.com',
                            LastName = 'testuser',
                            LanguageLocaleKey = 'it',
                            FirstName = 'test',
                            Email = 'test@test.com',
                            Alias = 'test',
                            TimeZoneSidKey = 'Europe/Dublin',
                            LocaleSidKey = 'it_IT',
                            EmailEncodingKey = 'UTF-8',
                            ProfileId = pSadmin,
                            UserRoleId = pRol,
                            UserPermissionsKnowledgeUser=true);
        insert userInsert;
        

        List<LeadAssignmentConfiguration__c> listCustSett = new List<LeadAssignmentConfiguration__c>
        {
            new LeadAssignmentConfiguration__c(Name='Last n days for Lead duplication',DaysLimit__c=7.0),
            new LeadAssignmentConfiguration__c(Name='Last n days for duplication M upload',DaysLimit__c = 7.0),
            new LeadAssignmentConfiguration__c(Name='Preventivo Impresa',Ranking__c = 'QUOTATORE CL',ASA__c = 4,Sub_ASA__c = 2),
            new LeadAssignmentConfiguration__c(Name='LimitAssignmentNumberToday',DaysLimit__c =10.0),
            new LeadAssignmentConfiguration__c(Name='LimitAssignmentNumberWeek',DaysLimit__c =40.0),
            new LeadAssignmentConfiguration__c(Name='Preventivo su misura', ASA__c = 4, Sub_ASA__c = 2),
            new LeadAssignmentConfiguration__c(Name='ToBeProcessedTimeLimitHours',HoursLimit__c=7.0)
        };

        Id idUtenteTecnico = [SELECT Id FROM User WHERE Name = 'Utente Tecnico' LIMIT 1].Id;
            
        List<AAI_Code_Variables__c> customSettingAAIList = new List<AAI_Code_Variables__c>
        {
            new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID',
                                      Value__c =idUtenteTecnico),

            new AAI_Code_Variables__c(Name='LeadStatusEventError',
                                      Value__c ='Test'),

            new AAI_Code_Variables__c(Name='LeadStatusTaskError',
                                      Value__c ='Test')
        };

        
        
        
        system.runAs(userInsert){
            
            insert listCustSett;
            insert customSettingAAIList;
            MappingASA__c mapASA = new MappingASA__c();
            mapASA.Name = '3';
            mapASA.ASA__c ='Famiglia';
            mapASA.Codice_ASA__c = 3;
            mapASA.ASA_Description__c ='3 - Famiglia';
            
            Database.insert(mapASA);
            
            MappingASA__c mapASA2 = new MappingASA__c();
            mapASA2.Name = '1';
            mapASA2.ASA__c ='Auto';
            mapASA2.Codice_ASA__c = 1;
            mapASA2.ASA_Description__c ='1 - Auto';
            
            Database.insert(mapASA2);
            
            MappingASA__c mapASA3 = new MappingASA__c();
            mapASA3.Name = '4';
            mapASA3.ASA__c ='Attività';
            mapASA3.Codice_ASA__c = 4;
            mapASA3.ASA_Description__c ='4 - Attività';
            
            Database.insert(mapASA3);
            
            MappingSottoASA__c mapSottoASA = new MappingSottoASA__c();
            mapSottoASA.Name = '3.1';
            mapSottoASA.Sotto_ASA__c ='ABITAZIONE';
            mapSottoASA.Codice_Sotto_ASA__c = 1;
            mapSottoASA.Sotto_ASA_Description__c ='3.1 Abitazione';
            
            Database.insert(mapSottoASA);
            
            MappingSottoASA__c mapSottoASA2 = new MappingSottoASA__c();
            mapSottoASA2.Name = '4.5';
            mapSottoASA2.Sotto_ASA__c ='ALBERGHI';
            mapSottoASA2.Codice_Sotto_ASA__c = 5;
            mapSottoASA2.Sotto_ASA_Description__c ='4.5 Alberghi';
            
            Database.insert(mapSottoASA2);
            
            List<LeadAssignmentConfiguration__c> LeadAssConfList = new List<LeadAssignmentConfiguration__c>();
            
            LeadAssignmentConfiguration__c LeadAssConf = new LeadAssignmentConfiguration__c();
            LeadAssConf.Name = 'Semplicemente casa';    
            LeadAssConf.ASA__c = 3;
            LeadAssConf.Sub_ASA__c = 1;
            
            LeadAssignmentConfiguration__c LeadAssConf2 = new LeadAssignmentConfiguration__c();
            LeadAssConf2.Name = 'Preventivo veloce';    
            LeadAssConf2.ASA__c = 1;
            
            LeadAssignmentConfiguration__c LeadAssConf3 = new LeadAssignmentConfiguration__c();
            LeadAssConf3.Name = 'Preventivatore Turismo';   
            LeadAssConf3.ASA__c = 4;
            LeadAssConf3.Sub_ASA__c = 5;
            
            LeadAssConfList.add(LeadAssConf);
            LeadAssConfList.add(LeadAssConf2);
            LeadAssConfList.add(LeadAssConf3);
            
            Database.insert(LeadAssConfList);
            
            Folder f = [SELECT Id FROM Folder WHERE Name = 'Public Images' LIMIT 1]; 
            String fId = f.id;
            
            List<Document> mydocs = new List<Document>();
            
            Document mydocCASA = New Document(name='sconto_NPC', FolderId = fId);
            Document mydocAUTO = New Document(name='sconto_NPA', FolderId = fId);
            Document mydocPT = New Document(name='sconto_PT', FolderId = fId);
            
            mydocs.add(mydocCASA);
            mydocs.add(mydocAUTO);
            mydocs.add(mydocPT);
            
            insert mydocs;
            
        }

        Lead testLead = new Lead(
                Salutation = '',
                LastName = 'LeadTest',
                FirstName = 'test',
                Company = 'TestCompany',
                Email = 'lead@mail.test',
                Phone = '0333333333',
                MobilePhone = '3333333333',
                Fiscal_ID__c = '1234567890abcdez',
                AAI_Partita_IVA__c = '12345678901',
                Landing_Page__c = 'Semplicemente casa',
                Premio_in_promozione_NPC__c = 100, 
                Prezzo_annuo_Nuova_Protezione_Casa__c = 200
                
        );
        
        Lead testLead2 = new Lead(
                Salutation = '',
                LastName = 'LeadTest2',
                FirstName = 'test2',
                Company = 'TestCompany2',
                Email = 'lead@mail.test',
                Phone = '0333333333',
                MobilePhone = '3333333333',
                Fiscal_ID__c = '1234567890abcred',
                AAI_Partita_IVA__c = '12345678922',
                Landing_Page__c = 'Preventivo veloce',
                Premio_in_promozione_RC_Auto__c = 100,
                RC_Car_Price__c  = 200
                
        );
        
        Lead testLead3 = new Lead(
                Salutation = '',
                LastName = 'LeadTest3',
                FirstName = 'test2',
                Company = 'TestCompany3',
                Email = 'lead@mail.test',
                Phone = '0333333333',
                MobilePhone = '3333333333',
                Fiscal_ID__c = '1234567890abcred',
                AAI_Partita_IVA__c = '12345678922',
                Landing_Page__c = 'Preventivatore Turismo'
                
        );

        Lead testLead4 = new Lead(
                Salutation = '',
                LastName = 'LeadTest4',
                FirstName = 'test4',
                Company = 'TestCompany4',
                Email = 'lead@mail.test',
                Phone = '0333333333',
                MobilePhone = '3333333333',
                Fiscal_ID__c = '1234567890abcred',
                AAI_Partita_IVA__c = '12345678922',
                Landing_Page__c = 'Siti Agenti',
                Provenienza_Campagne_Agenti__c = 'Sito_Agenti'
                
        );
        
        List<Lead> testLeads = new List<Lead>();
        testLeads.add(testLead);
        testLeads.add(testLead2);
        testLeads.add(testLead3);
        testLeads.add(testLead4);

        system.runAs(userInsert){
            insert testLeads;
        }
    }
    
    

    @isTest static void inBeforeLunchBH(){
        
        init();
        
        system.runAs(userAdmin) {
            
            theLead.Ultima_data_di_riassegnazione__c = Datetime.newInstance(2017, 12, 15, 10, 00, 00);
            update theLead;
    
            executeMethods(theLead, 'getReassignDateTime');
            
            String msgReturn = testClass.minDateTimeForReassignString;
                    
            system.assertEquals(msgReturn, '18/12/2017 9.00');
        }
        // '15/12/2017 18.00'
                
    }
    
    @isTest static void inBeforeLunchBHSitiAgenti(){
        
        init();
        
        system.runAs(userAdmin) {
            
            theLeadSitiAgenti.Ultima_data_di_riassegnazione__c = Datetime.newInstance(2017, 12, 15, 10, 00, 00);
            update theLeadSitiAgenti;
    
            executeMethods(theLeadSitiAgenti, 'getReassignDateTime');
            
            String msgReturn = testClass.minDateTimeForReassignString;
                    
            system.assertEquals(msgReturn, null);
        }
        // '15/12/2017 18.00'
                
    }

    @isTest static void inAfterLunchBH(){
        
        init();
        
        system.runAs(userAdmin) {
            
            theLead.Ultima_data_di_riassegnazione__c = Datetime.newInstance(2017, 12, 15, 15, 55, 00);
            update theLead;
    
            executeMethods(theLead, 'getReassignDateTime');
            
            String msgReturn = testClass.minDateTimeForReassignString;
            
            system.assertEquals(msgReturn, '18/12/2017 14.55');
        }
        
        // '18/12/2017 14.55'        
    }
    
    @isTest static void inLunchBH(){
        
        init();
        
        system.runAs(userAdmin) {
            

            
            theLead.Ultima_data_di_riassegnazione__c = Datetime.newInstance(2017, 12, 15, 13, 30, 00);
            update theLead;
    
            executeMethods(theLead, 'getReassignDateTime');
            
            String msgReturn = testClass.minDateTimeForReassignString;
            
            system.assertEquals(msgReturn, '18/12/2017 11.30');
        }
        
        // '18/12/2017 12.00'
    }
    
    @isTest static void inWeekend(){
        
        init();
        
        system.runAs(userAdmin) {
        
            theLead.Ultima_data_di_riassegnazione__c = Datetime.newInstance(2017, 12, 16, 16, 30, 00);
            update theLead;
    
            executeMethods(theLead, 'getReassignDateTime');
            
            String msgReturn = testClass.minDateTimeForReassignString;
            
            system.assertEquals(msgReturn, '18/12/2017 16.00');
        }
        
        // '18/12/2017 17.00'
                
    }
    
    @isTest static void inWeekendLunch(){
        
        init();
        
        system.runAs(userAdmin) {
            
            theLead.Ultima_data_di_riassegnazione__c = Datetime.newInstance(2017, 12, 16, 13, 30, 00);
            update theLead;
    
            executeMethods(theLead, 'getReassignDateTime');
            
            String msgReturn = testClass.minDateTimeForReassignString;
            
            system.assertEquals(msgReturn, '18/12/2017 16.00');
        }
        
        // '18/12/2017 17.00'     
    }
    
    @isTest static void ultimaDataNull(){
        
        init();
        
        system.runAs(userAdmin) {

            
            theLead.Ultima_data_di_riassegnazione__c = null;
            update theLead;
    
            executeMethods(theLead, 'getReassignDateTime');
            
            String msgReturn = testClass.minDateTimeForReassignString;
            
            system.assertEquals(msgReturn, null);
        }
        
        // '18/12/2017 17.00'
                
    }
    
    @isTest static void inClose(){
        
        init();
        
        system.runAs(userAdmin) {

            
            theLead.Ultima_data_di_riassegnazione__c = Datetime.newInstance(2017, 12, 16, 18, 55, 00);
            update theLead;
    
            executeMethods(theLead, 'getReassignDateTime');
            
            String msgReturn = testClass.minDateTimeForReassignString;
            
            system.assertEquals(msgReturn, '18/12/2017 16.00');
        }
        
        // '18/12/2017 17.00'
                
    }
    
    @isTest static void getAgencyStringTest(){
        init();
        
        theLead.Ultima_data_di_riassegnazione__c = Datetime.newInstance(2017, 12, 16, 18, 55, 00);
        update theLead;
        
        executeMethods(theLead, 'getAgencyString');
        
        String msgReturn = testClass.Agency;
        system.assertEquals(msgReturn, null);
        
    }
    
    
    @isTest static void getAgencyStringTestError(){

        LM_Email_CTRL testClass = new LM_Email_CTRL();
        testClass.relatedToLeadId = '00Q7E00000C4ybn';
        testClass.getAgencyString();
        
        String msgReturn = testClass.Error2;
        
        system.assertEquals(msgReturn, 'agenzia/e');
    }
    
    
    
    @isTest static void ErrorTest(){
        init();
        
        theLead.Ultima_data_di_riassegnazione__c = null;
        update theLead;
        
        executeMethods(theLead, 'getError');
        
        String msgReturn = testClass.minDateTimeForReassignString;
        system.assertEquals(msgReturn, null);
    }
    
    @isTest static void getAgencyNumberStringTest(){
        init();
        
        theLead.Ultima_data_di_riassegnazione__c = Datetime.newInstance(2017, 12, 16, 18, 55, 00);
        theLead.Numero_assegnazioni_eseguite__c = 3;
        update theLead;
        
        executeMethods(theLead, 'getAgencyNumberString');
        
        String msgReturn =  testClass.AgNumber;
        system.assertEquals(msgReturn, String.valueOf(2));
        
    }
    
    @isTest static void getAgencyNumberStringErrorTest(){
        
        LM_Email_CTRL testClass = new LM_Email_CTRL();
        testClass.relatedToLeadId = '00Q7E00000C4ybn';
        testClass.getAgencyNumberString();
        
        String msgReturn =  testClass.Error2;
        
        system.assertEquals(msgReturn, 'numero agenzie non disponibile');
    }
    
    @isTest static void getImageDocURLTest(){
        init();
        
        theLead.Ultima_data_di_riassegnazione__c = Datetime.newInstance(2017, 12, 16, 18, 55, 00);
        update theLead;
        
        executeMethods(theLead, 'getInfoString');
        executeMethods(theLead, 'getImageDocURL');
        
        String Return1 = testClass.InfoBanner;
        String Return2 = testClass.InfoBanner2;
        
        system.assertEquals(Return1, null);
        //system.assertEquals(Return2, null);
        
    }
    
     @isTest static void getImageDocURLTestAuto(){
        init();
        
        theLeadAuto.Ultima_data_di_riassegnazione__c = Datetime.newInstance(2017, 12, 16, 18, 55, 00);
        update theLeadAuto;
        
        executeMethods(theLeadAuto, 'getInfoString');
        executeMethods(theLeadAuto, 'getImageDocURL');
        
        String Return1 = testClass.InfoBanner;
        String Return2 = testClass.InfoBanner2;
        
        system.assertEquals(Return1, null);
        //system.assertEquals(Return2, null);
        
    }
    
     @isTest static void getImageDocURLTestTurismo(){
        init();
        
        theLeadTurismo.Ultima_data_di_riassegnazione__c = Datetime.newInstance(2017, 12, 16, 18, 55, 00);
        update theLeadTurismo;
        
        executeMethods(theLeadTurismo, 'getInfoString');
        executeMethods(theLeadTurismo, 'getImageDocURL');
        
        String Return1 = testClass.InfoBanner;
        String Return2 = testClass.InfoBanner2;
        
        system.assertEquals(Return1, null);
        //system.assertEquals(Return2, null);
        
    }
    
    @isTest static void getImageDocURLTestError(){

        LM_Email_CTRL testClass = new LM_Email_CTRL();
        testClass.relatedToLeadId = '00Q7E00000C4ybn';
        testClass.getImageDocURL();
        
        String ListInfoBanner = testClass.ErrorInfo;
        String ListInfoBanner2 = testClass.ErrorInfo2;
        
        //system.assertEquals(msgReturn, 'agenzia/e');
    }
    
}