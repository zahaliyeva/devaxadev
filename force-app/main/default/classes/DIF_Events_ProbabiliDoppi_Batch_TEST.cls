/**
    created by Vizzini D. on 29/07/2019
 */
@IsTest
public class DIF_Events_ProbabiliDoppi_Batch_TEST {
    
    @TestSetup
    public static void setup() {
        
        insert new AAI_Code_Variables__c(Name = 'AXA_TECHNICAL_USER_ID', Value__c = '00524000001FY2LAAW');

        Profile maketingProfile = [SELECT Id FROM Profile WHERE Name = 'AAI - Marketing Avanzato'];
        Id account_B2C_Id = UtilityClass.getRTid(UtilityClass.fetchAllRTypes(), 'Account', 'B2C_Client');
        Id account_B2B_Id = UtilityClass.getRTid(UtilityClass.fetchAllRTypes(), 'Account', 'B2B_Client');
        Id agency_Campaign_id = UtilityClass.getRTid(UtilityClass.fetchAllRTypes(), 'Campaign', 'Agency_campaign');
        Id nucleo_RecordType_id = UtilityClass.getRTid(UtilityClass.fetchAllRTypes(), 'Nucleo_di_appartenenza__c', 'Nucleo_altro');
        Id membroNucleo_RecordType_id = UtilityClass.getRTid(UtilityClass.fetchAllRTypes(), 'Membro_del_nucleo__c', 'Nucleo_altro');

        Integer randomNumber = Integer.valueof((Math.random() * 100));

        List<User> users = new List<User>();
        User usr1 = new User(FirstName = 'Test1',
                LastName = 'Nome1',
                Agency_Code__c = '123ABC',
                Nodes__c = 'DIF_000AAA',
                CommunityNickname = 'oldNickname1',
                DIF_Event_New_User__c = 'newNickname2',
                Alias = 'test1',
                Email = 'test1@fakeemail.com',
                Username = 'test1@fakeemail.com'+randomNumber+System.now().getTime(),
                LanguageLocaleKey = 'en_US',
                TimeZoneSidKey = 'Europe/Paris',
                Profileid = maketingProfile.Id,
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'ISO-8859-1');
        users.add(usr1);
        User usr2 = new User(FirstName = 'Test2',
                LastName = 'Nome2',
                Agency_Code__c = 'CBA321',
                Nodes__c = 'DIF_000AAA',
                CommunityNickname = 'oldNickname2',
                DIF_Event_New_User__c = 'newNickname3',
                Alias = 'test2',
                Email = 'test2@fakeemail.com',
                Username = 'test2@fakeemail.com'+randomNumber+System.now().getTime(),
                LanguageLocaleKey = 'en_US',
                TimeZoneSidKey = 'Europe/Paris',
                Profileid = maketingProfile.Id,
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'ISO-8859-1');
        users.add(usr2);
        insert users;

        List<Account> accounts = new List<Account>();
        Account acc1 = new Account(LastName = 'RollBack_Account_LastName_1',
                                    FirstName = 'RollBack_Account_FirstName_1',
                                    DIF_Event_Timestamp__c = System.now(),
                                    DIF_Event_New_NDG__c = '987654321',
                                    AAI_Agency_Reference_Code__c = '123ABC',
                                    RecordTypeId = account_B2C_Id,
                                    NDG_Vincente__c = '123456789',
                                    NDG__c = '999999999',
                                    Nodes__c = '123456789;000000');
        accounts.add(acc1);
        Account acc2 = new Account(LastName = 'RollBack_Account_LastName_2',
                                    FirstName = 'RollBack_Account_FirstName_2',
                                    DIF_Event_New_NDG__c = '187654329',
                                    AAI_Agency_Reference_Code__c = '123ABC',
                                    RecordTypeId = account_B2C_Id,
                                    NDG__c = '123456789',
                                    Nodes__c = '123456789;000000');
        accounts.add(acc2);
        Account acc3 = new Account(LastName = 'RollBack_Account_LastName_3',
                                    FirstName = 'RollBack_Account_FirstName_3',
                                    DIF_Event_New_NDG__c = '111111111',
                                    AAI_Agency_Reference_Code__c = 'CBA321',
                                    RecordTypeId = account_B2C_Id,
                                    OwnerId = usr1.Id,
                                    NDG_Vincente__c = '111111111',
                                    NDG__c = '222222222');
        accounts.add(acc3);
        Account acc4 = new Account(Name = 'RollBack_Account_Name_4',
                                    DIF_Event_New_NDG__c = '127654398',
                                    AAI_Agency_Reference_Code__c = '123ABC',
                                    RecordTypeId = account_B2B_Id,
                                    NDG_Vincente__c = '444444444',
                                    NDG__c = '333333333',
                                    Nodes__c = '444444444;000000');
        accounts.add(acc4);
        Account acc5 = new Account(Name = 'RollBack_Account_Name_5',
                                    DIF_Event_New_NDG__c = '777777777',
                                    AAI_Agency_Reference_Code__c = 'CBA321',
                                    RecordTypeId = account_B2B_Id,
                                    NDG_Vincente__c = '555555555',
                                    NDG__c = '888888888');
        accounts.add(acc5);
        Account acc6 = new Account(Name = 'RollBack_Account_Name_6',
                                    DIF_Event_New_NDG__c = '127439865',
                                    AAI_Agency_Reference_Code__c = '123ABC',
                                    RecordTypeId = account_B2B_Id,
                                    NDG__c = '444444444',
                                    Nodes__c = '444444444;000000');
        accounts.add(acc6);
        insert accounts;
        
        List<Contact> contacts = new List<Contact>();
        Contact ctc = new Contact(AccountId = acc4.Id,
                                    LastName = 'Test Last Name');
        contacts.add(ctc);
        Contact ctc2 = new Contact(AccountId = acc5.Id,
                                    LastName = 'Test Last Name 2');
        contacts.add(ctc2);
        Contact ctc3 = new Contact(AccountId = acc6.Id,
                                    LastName = 'Test Last Name 3');
        contacts.add(ctc3);
        insert contacts;

        Campaign campgn = new Campaign(Name = 'Test Campaign');
        insert campgn;

        String difEventLog = 'TIMESTAMP,';
        difEventLog += 'EVENTO_DIF,';
        difEventLog += 'AGENCY_CODE_NEW,';
        difEventLog += 'CBA321,';
        difEventLog += 'NDG_NEW,';
        difEventLog += 'NDG_OLD,';
        difEventLog += 'OWNER_ID_NEW,';
        difEventLog += acc3.OwnerId+',';
        difEventLog += 'RECORD_ID_NEW,';
        difEventLog += 'RECORD_ID_OLD,';
        difEventLog += 'PARENT_ID_NEW,';
        difEventLog += 'PARENT_ID_OLD,';
        difEventLog += 'POLICY_ID_NEW,';
        difEventLog += 'POLICY_ID_OLD,';
        difEventLog += 'NUCLEO_ID_NEW,';
        difEventLog += 'NUCLEO_ID_OLD,';
        difEventLog += 'CONTACT_ID_NEW,';
        difEventLog += ctc.Id+',';
        difEventLog += 'LEAD_ID_NEW,';
        difEventLog += 'LEAD_ID_OLD,';
        difEventLog += 'CAMPAIGN_ID_NEW,';
        difEventLog += campgn.Id+',';
        difEventLog += 'ACCOUNT_ID_NEW,';
        difEventLog += acc3.Id+',';
        difEventLog += 'WHO_ID_NEW,';
        difEventLog += 'WHO_ID_OLD,';
        difEventLog += 'WHAT_ID_NEW,';
        difEventLog += 'WHAT_ID_OLD';
        List<Communications_to_customer__c> communications = new List<Communications_to_customer__c>();
        Communications_to_customer__c comm1 = new Communications_to_customer__c(DIF_Event_Timestamp__c = System.now(),
                                                                                DIF_Event_Log__c = difEventLog,
                                                                                AccountId__c = acc1.Id,
                                                                                Message__c = 'Test Message 1',
                                                                                Mobile_Phone__c = '123456789');
        communications.add(comm1);
        Communications_to_customer__c comm2 = new Communications_to_customer__c(DIF_Event_Timestamp__c = System.now(),
                                                                                DIF_Event_Log__c = difEventLog,
                                                                                AccountId__c = acc2.Id,
                                                                                Message__c = 'Test Message 2',
                                                                                Mobile_Phone__c = '123456789');
        communications.add(comm2);
        Communications_to_customer__c comm3 = new Communications_to_customer__c(DIF_Event_Timestamp__c = System.now(),
                                                                                DIF_Event_Log__c = difEventLog,
                                                                                AccountId__c = acc3.Id,
                                                                                Message__c = 'Test Message 3',
                                                                                Mobile_Phone__c = '123456789');
        communications.add(comm3);
        insert communications;

        Storico_Chiamate__c sc1 = new Storico_Chiamate__c(DIF_Event_Timestamp__c = System.now(),
                                                            DIF_Event_Log__c = difEventLog,
                                                            Customer__c = acc1.Id);
        insert sc1;

        LiveChatVisitor lcv = new LiveChatVisitor();
        insert lcv;

        LiveChatTranscript lct1 = new LiveChatTranscript(DIF_Event_Timestamp__c = System.now(),
                                                            DIF_Event_Log__c = difEventLog,
                                                            AccountId = acc1.Id,
                                                            LiveChatVisitorId = lcv.Id);
        insert lct1;

        Competitor_Contract__c cc1 = new Competitor_Contract__c(DIF_Event_Timestamp__c = System.now(),
                                                                DIF_Event_Log__c = difEventLog,
                                                                Account__c = acc1.Id);
        insert cc1;

        List<Customer_Event__c> customerEvents = new List<Customer_Event__c>();
        Customer_Event__c cEvent1 = new Customer_Event__c(DIF_Event_Timestamp__c = System.now(),
                                                                                DIF_Event_Log__c = difEventLog,
                                                                                Account__c = acc1.Id);
        customerEvents.add(cEvent1);
        Customer_Event__c cEvent2 = new Customer_Event__c(DIF_Event_Timestamp__c = System.now(),
                                                                                DIF_Event_Log__c = difEventLog,
                                                                                Account__c = acc3.Id);
        customerEvents.add(cEvent2);
        insert customerEvents;

        Life_event__c le1 = new Life_event__c(DIF_Event_Timestamp__c = System.now(),
                                                                DIF_Event_Log__c = difEventLog,
                                                                Account_name__c = acc1.Id);
        insert le1;

        et4ae5__Automated_Send__c tr = new 	et4ae5__Automated_Send__c();
        insert tr;
		// errore deploy prod 21/04/2020
		// Field does not exist: DIF_Event_Timestamp__c on et4ae5__IndividualEmailResult__c
		// Field does not exist: DIF_Event_Log__c on et4ae5__IndividualEmailResult__c
        et4ae5__IndividualEmailResult__c ier1 = new et4ae5__IndividualEmailResult__c(
																//DIF_Event_Timestamp__c = System.now(),
                                                                //DIF_Event_Log__c = difEventLog,
                                                                et4ae5__Contact__c = ctc.Id,
                                                                et4ae5__TriggeredSendDefinition__c = tr.Id,
                                                                Account__c = acc4.Id);
        //insert ier1;

        Feedback__c fb1 = new Feedback__c(DIF_Event_Timestamp__c = System.now(),
                                                                DIF_Event_Log__c = difEventLog,
                                                                Account__c = acc1.Id);
        insert fb1;

        Opportunity opp1 = new Opportunity(DIF_Event_Timestamp__c = System.now(),
                                                                DIF_Event_Log__c = difEventLog,
                                                                AccountId = acc1.Id,
                                                                Name = 'Test Oppt',
                                                                StageName = 'Open',
                                                                CloseDate = System.now().Date());
        insert opp1;

        Nucleo_di_appartenenza__c na = new Nucleo_di_appartenenza__c(DIF_Event_Timestamp__c = System.now(),
                                                                DIF_Event_Log__c = difEventLog,
                                                                RecordTypeId = nucleo_RecordType_id,
                                                                Referente_principale__c = acc1.Id);
        insert na;

        Membro_del_nucleo__c membroNucleo = new Membro_del_nucleo__c(DIF_Event_Timestamp__c = System.now(),
                                                                DIF_Event_Log__c = difEventLog,
                                                                Nucleo_di_appartenenza__c = na.Id,
                                                                RecordTypeId = membroNucleo_RecordType_id,
                                                                Account_correlato__c = acc1.Id);
        insert membroNucleo;

        List<Campaign> campaigns = new List<Campaign>();
        Campaign cp1 = new Campaign(DIF_Event_Timestamp__c = System.now(),
                                    DIF_Event_Log__c = difEventLog,
                                    OwnerId = usr1.Id,
                                    RecordTypeId = agency_Campaign_id,
                                    Name = 'CP 1');
        campaigns.add(cp1);
        Campaign cp2 = new Campaign(DIF_Event_Timestamp__c = System.now(),
                                    DIF_Event_Log__c = difEventLog,
                                    OwnerId = usr1.Id,
                                    RecordTypeId = agency_Campaign_id,
                                    Name = 'CP 2');
        campaigns.add(cp2);
        Campaign cp3 = new Campaign(DIF_Event_Timestamp__c = System.now(),
                                    DIF_Event_Log__c = difEventLog,
                                    OwnerId = usr2.Id,
                                    RecordTypeId = agency_Campaign_id,
                                    Name = 'CP 3');
        campaigns.add(cp3);
        insert campaigns;

        List<CampaignMember> campMembers = new List<CampaignMember>();
        CampaignMember cm1 = new CampaignMember(DIF_Event_Timestamp__c = System.now(),
                                                DIF_Event_Log__c = difEventLog,
                                                ContactId = ctc.Id,
                                                CampaignId = cp1.Id);
        campMembers.add(cm1);
        CampaignMember cm2 = new CampaignMember(DIF_Event_Timestamp__c = System.now(),
                                                DIF_Event_Log__c = difEventLog,
                                                ContactId = ctc.Id,
                                                CampaignId = cp2.Id);
        campMembers.add(cm2);
        CampaignMember cm3 = new CampaignMember(DIF_Event_Timestamp__c = System.now(),
                                                DIF_Event_Log__c = difEventLog,
                                                ContactId = ctc3.Id,
                                                CampaignId = cp2.Id);
        campMembers.add(cm3);
        insert campMembers;

        Task task = new Task(WhatId = acc1.Id);
        insert task;

        Event event = new Event(WhatId = acc1.Id,
                                DurationInMinutes = 10,
                                ActivityDateTime = System.now());
        insert event;

        Note note = new Note(Title = 'Note Test',
                             ParentId = acc1.Id);
        insert note;

        Attachment attch = new Attachment(Name = 'Test Attch',
                                          ParentId = acc1.Id,
                                          Body = blob.valueof('attachment body 1'));
        insert attch;
        /*
        Document__c doc = new Document__c(Name = 'Test Doc',
                                          Account__c = acc1.Id);
        insert doc;
        */
        Massive_Communication__c mc = new Massive_Communication__c(Name = 'Test Massive Communication',
                                          Account__c = acc1.Id);
        insert mc;
    }

    @IsTest
    public static void testProbabiliDoppiBatch(){
        
        Test.startTest();
        DIF_Events_ProbabiliDoppi_Batch difEventsProbabiliDoppiBatch = new DIF_Events_ProbabiliDoppi_Batch();
        difEventsProbabiliDoppiBatch.agencyCode = new List<String>{'123ABC'};
        Id batchId = Database.executeBatch(difEventsProbabiliDoppiBatch);
        Test.stopTest();
 
        AsyncApexJob batchJob = [SELECT Id, Status FROM AsyncApexJob WHERE Id = :batchId];
        System.assertEquals('Completed', batchJob.Status);
    }

    @isTest 
    public static void DIFUtilityCoverage() {

        String s='';
        for (Integer i = 0; i < DIF_Utility_Log.DataLogs.values().size()-1; i++) {
            s += i+',';
        }
        s+='&quot;';

        DIF_events_log_users__c emailuser = new DIF_events_log_users__c(Name='testuser', Email_address__c='fake.email@doma1n.example');
        insert emailuser;

        Id adminid = [SELECT Id FROM Profile WHERE Name = 'System Administrator' limit 1].id;
        User usr1=new User(FirstName='Marzia',
                    LastName = 'Rossi',
                    Alias = 'mro666',
                    Email = 'fake.email2@doma1n.example',
                    Username = 'mrkskmrr45@axa.com.masterdev',
                    CommunityNickname = 'MarziRo',
                    LanguageLocaleKey = 'en_US',
                    TimeZoneSidKey='Europe/Rome',
                    Agency_Code__c = '000828',
                    Nodes__c = 'DIF_000828',
                    Profileid = adminid,
                    LocaleSidKey='en_US',
                    EmailEncodingKey='ISO-8859-1'
            );
        insert usr1;

        SObject so = Schema.getGlobalDescribe().get('Storico_Chiamate__c').newSObject();
        so.put('DIF_Event_Log__c','value');

        Test.startTest();
        DIF_Utility_Log.updateRecord(so,Datetime.now(), new Map<DIF_Utility_Log.DataLogs, String>());
        DIF_Utility_Log.createHeader();
        DIF_Utility_Log.createMapForLog();
        DIF_Utility_Log.createRecord(Datetime.now(),'level','desc');
        DIF_Utility_Log.convertCsvStringToMap(s);
        
        System.runAs(usr1){
        DIF_Utility_Log.sendEmail('CustomObject','Test','filecsvtest',1,0,0);
        DIF_Utility_Log.sendEmail('CustomObject','Test','filecsvtest',0,1,0);
        DIF_Utility_Log.sendEmail('CustomObject','Test','filecsvtest',0,0,1);
        }
        Test.stopTest();
    }
    
}