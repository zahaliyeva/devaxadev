/**
 * Created by Augens on 09/11/2018.
 */

@IsTest
private class ContactHistoryCTRL_Test {

    @TestSetup static void setup() {
        //MDANTONIO 09/04/2019 popolamento custom settings per classi di test - start
        ServiceUtilsClass.populateCustomSettingsForTests();
        //MDANTONIO 09/04/2019 popolamento custom settings per classi di test - end
        string strRecordTypeId = [select id from RecordType where SobjectType='Account' AND DeveloperName='B2C_Client' limit 1].id;
        Account acc = new Account(
                Type = 'Prospect',
                LastName = 'TestAccountName',
                FirstName = 'test',
                RecordTypeId=strRecordTypeId ,
                PersonEmail = 'Test1@mail.test');
        insert acc ;

        // *****ACCOUNT_CONTACT_EVENT_001*****
        Event ev = new Event(Subject = 'Appuntamento per trattativa',
                            StartDateTime = Date.newInstance(2018, 02, 23),
                            WhatId = acc.Id,
                            DurationInMinutes = 60);
        insert ev;

        // *****ACCOUNT_CLAIM_001*****
        InsurancePolicy__c polizza = new InsurancePolicy__c(Name = 'TestPolizza', cuid__c = acc.Id);
        insert polizza;
        Claim__c claim = new Claim__c(Name = 'ClaimTest',
                                    Polizza__c = polizza.Id,
                                    Account__c = acc.Id,
                                    Opening_Date__c =Date.newInstance(2018, 02, 12));
        insert claim;

        // *****LEAD_EVENT_001*****
        List<LeadAssignmentConfiguration__c> listCustSett = new List<LeadAssignmentConfiguration__c>{
                new LeadAssignmentConfiguration__c(Name = 'Last n days for Lead duplication', DaysLimit__c = 7.0),
                new LeadAssignmentConfiguration__c(Name = 'Last n days for duplication M upload', DaysLimit__c = 7.0),
                new LeadAssignmentConfiguration__c(Name = 'Preventivo Impresa', Ranking__c = 'QUOTATORE CL', ASA__c = 4, Sub_ASA__c = 2),
                new LeadAssignmentConfiguration__c(Name = 'LimitAssignmentNumberToday', DaysLimit__c = 10.0),
                new LeadAssignmentConfiguration__c(Name = 'LimitAssignmentNumberWeek', DaysLimit__c = 40.0),
                new LeadAssignmentConfiguration__c(Name = 'Preventivo veloce', Ranking__c = 'QUOTATORE AUTO', ASA__c = 4, Sub_ASA__c = 2),
                new LeadAssignmentConfiguration__c(Name = 'Preventivo su misura', ASA__c = 4, Sub_ASA__c = 2)
        };

        insert listCustSett;

        MappingASA__c mapASA = new MappingASA__c(Name = '4',
                ASA__c = 'Attività',
                ASA_Description__c = '4 - Attività',
                Codice_ASA__c = 4);
        insert mapASA;

        MappingSottoASA__c mapSubASA = new MappingSottoASA__c(Name = '4.2',
                Codice_Sotto_ASA__c = 2,
                Sotto_ASA__c = 'ARTIGIANATO',
                Sotto_ASA_Description__c = '4.2 Artigianato');
        insert mapSubASA;
        Lead leadToAssign = new Lead(LastName = 'leadTestMethodOne',
                FirstName = 'test',
                Email = 'lead1@mail.test',
                Fiscal_ID__c = '123abcd4567895ez',
                AAI_Partita_IVA__c = '12345678901',
                Agency_Code__c = '000828',
                LeadSource = 'Web',
                Dettaglio__c = 'Salva quotazione',
                Privacy_Terms__c = true,
                Commercial_Activity_Consensus__c = true,
                TECH_Company__c = 'AAI',
                Phone = '3386754890',
                PostalCode = '105',
                ASA__c = 'Attività',
                Landing_Page__c = 'Preventivo Impresa');
        insert leadToAssign ;
        Event ev1 = new Event(Subject = 'Appuntamento per trattativa',
                                StartDateTime = Date.newInstance(2017, 03, 11),
                                WhoId = leadToAssign.Id,
                                DurationInMinutes = 60);
        insert ev1;

        //Problem: attempt to re-reference a null object(QuotazioneHandler line 24)
        User thisUser = [SELECT Id FROM User WHERE alias = 'utte'];
        System.runAs( thisUser ) {
                    AAI_Code_Variables__c mycs = AAI_Code_Variables__c.getValues(thisUser.Id);
                    if(mycs == null){
                        mycs = new AAI_Code_Variables__c(Name = 'AXA_TECHNICAL_USER_ID', value__c = thisUser.Id);
                        insert mycs;
                    }
        }
        Quotazione__c quot = new Quotazione__c(Name = 'Quotazione Lead Test',
                Lead__c = leadToAssign.Id,
                Origine__c = 'Preventivo Impresa');
        insert quot;

        // *****LEAD_TASK_001*****
        Task tsk = new Task(Tracking__c = 'Cliccato',
                WhoId = leadToAssign.Id,
                Subject = 'Test subject',
                Channel__c = 'SMS');
        insert tsk;

        // *****LEAD_INDIVIDUALEMAILRESULT_001*****
        et4ae5__Automated_Send__c testAt = new et4ae5__Automated_Send__c(Name = 'Test Yosra');
        insert testAt;
        et4ae5__IndividualEmailResult__c IndEmailResult = new et4ae5__IndividualEmailResult__c(et4ae5__DateSent__c = Date.newInstance(2018, 10, 23),
                                                                                                et4ae5__SubjectLine__c = 'Test Subject CASA',
                                                                                                et4ae5__Opened__c = false,
                                                                                                et4ae5__HardBounce__c = false,
                                                                                                et4ae5__SoftBounce__c = false,
                                                                                                et4ae5__DateOpened__c = Date.newInstance(2018, 10, 30),
                                                                                                et4ae5__Lead__c = leadToAssign.Id,
                                                                                                et4ae5__TriggeredSendDefinition__c = testAt.Id);
        insert IndEmailResult;

        // *****CONTACT_TASK_001*****
        // Case : create an Account(Persona giuridica)
        List<RecordType> Rty = [SELECT Id FROM RecordType WHERE developerName ='B2B_Client' LIMIT 1];
        Account acc2 = new Account(Name = 'TestPersonaGiuridica',
                                    AAI_Agency_Reference_Code__c = '000828',
                                    RecordTypeId = Rty[0].Id);
        insert acc2;

        Contact cs = new Contact(FirstName ='Test11',
                                LastName= 'Test11',
                                AccountId = acc2.Id);
        insert  cs;

        Task tsk1 = new Task(Channel__c = 'SMS',
                            WhoId = cs.Id,
                            Tracking__c = 'Cliccato',
                            Subject ='testTask');
        insert tsk1;
        // *****CONTACT_TASK_003*****
        Task tsk2 = new Task(Subject = 'call',
                        Type__c ='Other',
                        WhoId = cs.Id);
        insert tsk2;

        // *****LEAD_QUOTAZIONE_001*****
        Quotazione__C qt = new Quotazione__c(Origine__c = 'Preventivo impresa',
                                            Quotation_Code__c ='24555666',
                                            Lead__c = leadToAssign.Id);
        insert qt;

    }
    @IsTest
    static void getHistoryItemsAccountTest() {
       Test.startTest();
            List<Id> accList = new List<Id>();
            Account acc =[SELECT Id FROM Account WHERE LastName = 'TestAccountName'AND FirstName = 'test'];
            accList.add(acc.Id);
            ContactHistoryCTRL.ResponseDto result = ContactHistoryCTRL.getHistoryItemWrappers(accList,2);
            System.assertEquals(true, result.isSuccess);
            System.debug('***************************AccountSIZE'+result.message);
            List<ContactHistoryCTRL.HistoryItemWrapper> listItems = (List<ContactHistoryCTRL.HistoryItemWrapper>)result.Values.get('ContactHistoryList');
            System.assertEquals(false, listItems.size() > 0);
            //System.debug('***************************Map:ListValue'+listItems[0].Title);
            //System.assertEquals('ClaimTest',listItems[0].detail1);
            //System.assertEquals('Apertura sinistro da PCC/MyAXA',listItems[0].Title);
        Test.stopTest();
    }

    @IsTest
    static void getHistoryItemsLeadTest() {
        Test.startTest();
            List<Id> accountsList = new List<Id>();
            List<Id> leadsList = new List<Id>();
            Lead lead = [SELECT Id FROM Lead WHERE Fiscal_ID__c = '123abcd4567895ez'];
            leadsList.add(lead.Id);
            Account acc =[SELECT Id FROM Account WHERE LastName = 'TestAccountName'AND FirstName = 'test'];
            accountsList.add(acc.Id);
                     
            ContactHistoryCTRL.ResponseDto result1 = ContactHistoryCTRL.getHistoryItemWrappers(leadsList,3);
            ContactHistoryCTRL.ResponseDto result2 = ContactHistoryCTRL.getHistoryItemWrappers(accountsList,3);
            
            
            System.assertEquals(true, result1.isSuccess);
            System.assertEquals(true,result1.Values.size() > 0);
            List<ContactHistoryCTRL.HistoryItemWrapper> listItems1 = (List<ContactHistoryCTRL.HistoryItemWrapper>)result1.Values.get('ContactHistoryList');
            System.assertEquals(true,listItems1.size() > 0);
            System.debug('*******************MapLeadSIZE1'+listItems1[0].Title);
            System.debug('*******************MapLeadSIZE2'+listItems1[1].Title);
            System.debug('*******************MapLeadSIZE3'+listItems1[2].Title);
        Test.stopTest();
    }
    @IsTest
    static void getHistoryItemsLeadTest2() {
        Test.startTest();
       
            Account acc =[SELECT Id FROM Account WHERE LastName = 'TestAccountName'AND FirstName = 'test'];
            List<Id> conList = new List<Id>();
            Contact cnt = [SELECT Id FROM Contact WHERE AccountId =:acc.Id];
            conList.add(cnt.Id);
            ContactHistoryCTRL.ResponseDto result3 = ContactHistoryCTRL.getHistoryItemWrappers(conList,3);
            
            Test.stopTest();
    }
    @IsTest
    static void generateHistoryItemt3() {
        Test.startTest();
       Contact_History_Configuration__mdt cnf=[SELECT Id, Label, QualifiedApiName, Field_Type__c,
                    Query__c, Query2__c, Query2_Field_Id__c, Query2_Object__c, 
                    Filter_SOQL_Field__c, Filter_SOQL_Values__c, Filter_SOQL_Operator__c, 
                    Title__c, Title_Link__c, Icon_Component__c, IconSVG_Component__c, Communication_Direction__c,
                    Detail_1__c, Detail_1_Link__c, Detail_1_Link_NFE__c, Detail_2__c, Detail_2_Link__c, Detail_2_Link_NFE__c, Detail_3__c, Detail_3_Link__c, Detail_3_Link_NFE__c, Detail_4__c, Detail_4_Link__c, Detail_4_Link_NFE__c,
                    Detail_5__c,Detail_5_Link__c,Detail_5_Link_NFE__c,Date_and_Time__c, Date_and_Time_Link__c, Date_Unsubscribed__c, 
                    Flag_Open_Field__c, Flag_Open_Parameter__c, Flag_Open_Operator__c,
                    Flag_Sent_Field__c, Flag_Sent_Parameter__c, Flag_Sent_Operator__c, Icon__c,
                    Flag_Click_Field__c, Flag_Click_Parameter__c, Flag_Click_Operator__c, 
                    Flag_Hard_Bounce_Field__c, Flag_Hard_Bounce_Parameter__c, Flag_Hard_Bounce_Operator__c, 
                    Flag_Soft_Bounce_Field__c, Flag_Soft_Bounce_Parameter__c, Flag_Soft_Bounce_Operator__c, 
                   Flag_Mouseover_Sent__c, Flag_Mouseover_Open__c, Flag_Mouseover_Bounce__c, Flag_Mouseover_Click__c, HideInNFE__c  from Contact_History_Configuration__mdt where Detail_1_Link_NFE__c !=null and Detail_1_Link__c !=null and Field_Type__c='Account/Contact' limit 1 ];
            ContactHistoryCTRL.generateHistoryItem(cnf,cnf,null);
         Contact_History_Configuration__mdt cnf2=[SELECT Id, Label, QualifiedApiName, Field_Type__c,
                    Query__c, Query2__c, Query2_Field_Id__c, Query2_Object__c, 
                    Filter_SOQL_Field__c, Filter_SOQL_Values__c, Filter_SOQL_Operator__c, 
                    Title__c, Title_Link__c, Icon_Component__c, IconSVG_Component__c, Communication_Direction__c,
                    Detail_1__c, Detail_1_Link__c, Detail_1_Link_NFE__c, Detail_2__c, Detail_2_Link__c, Detail_2_Link_NFE__c, Detail_3__c, Detail_3_Link__c, Detail_3_Link_NFE__c, Detail_4__c, Detail_4_Link__c, Detail_4_Link_NFE__c,
                    Detail_5__c,Detail_5_Link__c,Detail_5_Link_NFE__c,Date_and_Time__c, Date_and_Time_Link__c, Date_Unsubscribed__c, 
                    Flag_Open_Field__c, Flag_Open_Parameter__c, Flag_Open_Operator__c,
                    Flag_Sent_Field__c, Flag_Sent_Parameter__c, Flag_Sent_Operator__c, Icon__c,
                    Flag_Click_Field__c, Flag_Click_Parameter__c, Flag_Click_Operator__c, 
                    Flag_Hard_Bounce_Field__c, Flag_Hard_Bounce_Parameter__c, Flag_Hard_Bounce_Operator__c, 
                    Flag_Soft_Bounce_Field__c, Flag_Soft_Bounce_Parameter__c, Flag_Soft_Bounce_Operator__c, 
                   Flag_Mouseover_Sent__c, Flag_Mouseover_Open__c, Flag_Mouseover_Bounce__c, Flag_Mouseover_Click__c, HideInNFE__c  from Contact_History_Configuration__mdt where  Detail_5__c !=null and Field_Type__c='Account/Contact' limit 1 ];
            ContactHistoryCTRL.generateHistoryItem(cnf2,cnf2,null);
            
            Test.stopTest();
    }
    
    @IsTest
    static void generateHistoryItemt4() {
        Test.startTest();
       Contact_History_Configuration__mdt cnf=[SELECT Id, Label, QualifiedApiName, Field_Type__c,
                    Query__c, Query2__c, Query2_Field_Id__c, Query2_Object__c, 
                    Filter_SOQL_Field__c, Filter_SOQL_Values__c, Filter_SOQL_Operator__c, 
                    Title__c, Title_Link__c, Icon_Component__c, IconSVG_Component__c, Communication_Direction__c,
                    Detail_1__c, Detail_1_Link__c, Detail_1_Link_NFE__c, Detail_2__c, Detail_2_Link__c, Detail_2_Link_NFE__c, Detail_3__c, Detail_3_Link__c, Detail_3_Link_NFE__c, Detail_4__c, Detail_4_Link__c, Detail_4_Link_NFE__c,
                    Detail_5__c,Detail_5_Link__c,Detail_5_Link_NFE__c,Date_and_Time__c, Date_and_Time_Link__c, Date_Unsubscribed__c, 
                    Flag_Open_Field__c, Flag_Open_Parameter__c, Flag_Open_Operator__c,
                    Flag_Sent_Field__c, Flag_Sent_Parameter__c, Flag_Sent_Operator__c, Icon__c,
                    Flag_Click_Field__c, Flag_Click_Parameter__c, Flag_Click_Operator__c, 
                    Flag_Hard_Bounce_Field__c, Flag_Hard_Bounce_Parameter__c, Flag_Hard_Bounce_Operator__c, 
                    Flag_Soft_Bounce_Field__c, Flag_Soft_Bounce_Parameter__c, Flag_Soft_Bounce_Operator__c, 
                   Flag_Mouseover_Sent__c, Flag_Mouseover_Open__c, Flag_Mouseover_Bounce__c, Flag_Mouseover_Click__c, HideInNFE__c  from Contact_History_Configuration__mdt where  Detail_3__c!=null and Detail_3_Link__c !=null and Field_Type__c='Account/Contact' limit 1 ];
        Contact_History_Configuration__mdt cnf2=[SELECT Id, Label, QualifiedApiName, Field_Type__c,
                    Query__c, Query2__c, Query2_Field_Id__c, Query2_Object__c, 
                    Filter_SOQL_Field__c, Filter_SOQL_Values__c, Filter_SOQL_Operator__c, 
                    Title__c, Title_Link__c, Icon_Component__c, IconSVG_Component__c, Communication_Direction__c,
                    Detail_1__c, Detail_1_Link__c, Detail_1_Link_NFE__c, Detail_2__c, Detail_2_Link__c, Detail_2_Link_NFE__c, Detail_3__c, Detail_3_Link__c, Detail_3_Link_NFE__c, Detail_4__c, Detail_4_Link__c, Detail_4_Link_NFE__c,
                    Detail_5__c,Detail_5_Link__c,Detail_5_Link_NFE__c,Date_and_Time__c, Date_and_Time_Link__c, Date_Unsubscribed__c, 
                    Flag_Open_Field__c, Flag_Open_Parameter__c, Flag_Open_Operator__c,
                    Flag_Sent_Field__c, Flag_Sent_Parameter__c, Flag_Sent_Operator__c, Icon__c,
                    Flag_Click_Field__c, Flag_Click_Parameter__c, Flag_Click_Operator__c, 
                    Flag_Hard_Bounce_Field__c, Flag_Hard_Bounce_Parameter__c, Flag_Hard_Bounce_Operator__c, 
                    Flag_Soft_Bounce_Field__c, Flag_Soft_Bounce_Parameter__c, Flag_Soft_Bounce_Operator__c, 
                   Flag_Mouseover_Sent__c, Flag_Mouseover_Open__c, Flag_Mouseover_Bounce__c, Flag_Mouseover_Click__c, HideInNFE__c  from Contact_History_Configuration__mdt where Detail_4__c!=null and Detail_4_Link__c !=null and Field_Type__c='Account/Contact' limit 1 ];
            ContactHistoryCTRL.generateHistoryItem(cnf,cnf,null);
            ContactHistoryCTRL.generateHistoryItem(cnf2,cnf2,null);
        
            
            Test.stopTest();
    }
     @IsTest
    static void generateHistoryItemt5() {
        
        
     Test.startTest(); 
        Contact_History_Configuration__mdt cnf2=[SELECT Id, Label, QualifiedApiName, Field_Type__c,
                    Query__c, Query2__c, Query2_Field_Id__c, Query2_Object__c, 
                    Filter_SOQL_Field__c, Filter_SOQL_Values__c, Filter_SOQL_Operator__c, 
                    Title__c, Title_Link__c, Icon_Component__c, IconSVG_Component__c, Communication_Direction__c,
                    Detail_1__c, Detail_1_Link__c, Detail_1_Link_NFE__c, Detail_2__c, Detail_2_Link__c, Detail_2_Link_NFE__c, Detail_3__c, Detail_3_Link__c, Detail_3_Link_NFE__c, Detail_4__c, Detail_4_Link__c, Detail_4_Link_NFE__c,
                    Detail_5__c,Detail_5_Link__c,Detail_5_Link_NFE__c,Date_and_Time__c, Date_and_Time_Link__c, Date_Unsubscribed__c, 
                    Flag_Open_Field__c, Flag_Open_Parameter__c, Flag_Open_Operator__c,
                    Flag_Sent_Field__c, Flag_Sent_Parameter__c, Flag_Sent_Operator__c, Icon__c,
                    Flag_Click_Field__c, Flag_Click_Parameter__c, Flag_Click_Operator__c, 
                    Flag_Hard_Bounce_Field__c, Flag_Hard_Bounce_Parameter__c, Flag_Hard_Bounce_Operator__c, 
                    Flag_Soft_Bounce_Field__c, Flag_Soft_Bounce_Parameter__c, Flag_Soft_Bounce_Operator__c, 
                   Flag_Mouseover_Sent__c, Flag_Mouseover_Open__c, Flag_Mouseover_Bounce__c, Flag_Mouseover_Click__c, HideInNFE__c  from Contact_History_Configuration__mdt where Date_Unsubscribed__c !=null  limit 1 ];
            ContactHistoryCTRL.generateHistoryItem(cnf2,cnf2,null);
         Contact_History_Configuration__mdt cnf=[SELECT Id, Label, QualifiedApiName, Field_Type__c,
                    Query__c, Query2__c, Query2_Field_Id__c, Query2_Object__c, 
                    Filter_SOQL_Field__c, Filter_SOQL_Values__c, Filter_SOQL_Operator__c, 
                    Title__c, Title_Link__c, Icon_Component__c, IconSVG_Component__c, Communication_Direction__c,
                    Detail_1__c, Detail_1_Link__c, Detail_1_Link_NFE__c, Detail_2__c, Detail_2_Link__c, Detail_2_Link_NFE__c, Detail_3__c, Detail_3_Link__c, Detail_3_Link_NFE__c, Detail_4__c, Detail_4_Link__c, Detail_4_Link_NFE__c,
                    Detail_5__c,Detail_5_Link__c,Detail_5_Link_NFE__c,Date_and_Time__c, Date_and_Time_Link__c, Date_Unsubscribed__c, 
                    Flag_Open_Field__c, Flag_Open_Parameter__c, Flag_Open_Operator__c,
                    Flag_Sent_Field__c, Flag_Sent_Parameter__c, Flag_Sent_Operator__c, Icon__c,
                    Flag_Click_Field__c, Flag_Click_Parameter__c, Flag_Click_Operator__c, 
                    Flag_Hard_Bounce_Field__c, Flag_Hard_Bounce_Parameter__c, Flag_Hard_Bounce_Operator__c, 
                    Flag_Soft_Bounce_Field__c, Flag_Soft_Bounce_Parameter__c, Flag_Soft_Bounce_Operator__c, 
                   Flag_Mouseover_Sent__c, Flag_Mouseover_Open__c, Flag_Mouseover_Bounce__c, Flag_Mouseover_Click__c, HideInNFE__c  from Contact_History_Configuration__mdt where Detail_2_Link_NFE__c !=null  limit 1 ];
            ContactHistoryCTRL.generateHistoryItem(cnf,cnf,null);
        Test.stopTest();
    }
        
    @IsTest
    static void getHistoryItemsContactsTest() {
        Test.startTest();
            List<Id> conList = new List<Id>();
            Account acc =[SELECT Id FROM Account WHERE LastName = 'TestAccountName'AND FirstName = 'test'];
            Contact cnt = [SELECT Id FROM Contact WHERE AccountId =:acc.Id];
            conList.add(cnt.Id);
            System.debug('********************************************testttt'+conList[0]);
            ContactHistoryCTRL.ResponseDto result2 = ContactHistoryCTRL.getHistoryItemWrappers(conList,2);
            System.assertEquals(true, result2.isSuccess);
            System.assertEquals(true,result2.Values.size() > 0);
            List<ContactHistoryCTRL.HistoryItemWrapper> listItems2 = (List<ContactHistoryCTRL.HistoryItemWrapper>)result2.Values.get('ContactHistoryList');
            System.assertEquals(false,listItems2.size()>0);
            //System.debug('*****************************************ContactSIZE'+listItems2[0].Title);
            // first HistoryItemWrapper
            /*System.assertEquals('Contattato per telefono',listItems2[0].Title);
            System.assertEquals('Other',listItems2[0].detail1);
            System.assertEquals('testTask',listItems2[1].Title);
            // second HistoryItemWrapper
            System.assertEquals('SMS correttamente inviato',listItems2[1].FlagMouseoverSent);
            //System.assertEquals('Il cliente ha aperto l\'SMS il GG/MM/AAAA',listItems2[1].FlagMouseoverOpen);
            System.assertEquals('Il cliente ha chiesto maggiori informazioni',listItems2[1].FlagMouseoverClick);
            System.assertEquals('SMS non recapitato',listItems2[1].FlagMouseoverBounce);*/
        Test.stopTest();
    }
    @IsTest
    static void getHistoryItemsAccountCaseTest() {
    System.debug('I have performed '+Limits.getQueries()+' and I am allowed up to '+Limits.getLimitQueries()+ ' within this request');
        Test.startTest();
            Account a =[SELECT Id FROM Account WHERE LastName = 'TestAccountName'AND FirstName = 'test' LIMIT 1];
            System.debug('I have performed '+Limits.getQueries()+' and I am allowed up to '+Limits.getLimitQueries()+ ' within this request');
            RecordType rt =[SELECT Id FROM RecordType WHERE Name ='Assistenza Agenti' LIMIT 1];
            Case c = new Case(Complainant__c='Customer',
                                Status = 'Open',
                                Phone_Call_Ids__c='78384',
                                Origin='Phone',
                                AccountId=a.Id,
                                Category__c='Duplicati polizza di risparmio',
                                SubCategory__c='Altro',
                                Distribution_Network__c='BNL',
                                RecordTypeId=rt.Id);
            insert c;

        // *****ACCOUNT_EMAILMESSAGE_001*****
            EmailMessage emailMSG2 = new EmailMessage(ParentId = c.Id,
                                                    Incoming= true);
            insert emailMSG2;
        // *****ACCOUNT_EMAILMESSAGE_002*****
           EmailMessage emailMSG1 = new EmailMessage(ParentId = c.Id,
                    Incoming = false,
                    FromName ='ContactHistoryTest');
            insert emailMSG1;
        Test.stopTest();
            List<Id> accList = new List<Id>();
            accList.add(a.Id);
    /*    Test.startTest();
            ContactHistoryCTRL.ResponseDto result3 = ContactHistoryCTRL.getHistoryItemWrappers(accList,2);
            System.assertEquals(true,result3.isSuccess);
            System.assertEquals(true,result3.Values.size() > 0);
            List<ContactHistoryCTRL.HistoryItemWrapper> listItems3 = (List<ContactHistoryCTRL.HistoryItemWrapper>)result3.Values.get('ContactHistoryList');
            System.debug('********'+listItems3);
            System.assertEquals(true, listItems3.size() > 0);
        Test.stopTest();*/
    }

    @IsTest
    static void getHistoryItemsAccountCaseTest_Cont() {
    System.debug('I have performed '+Limits.getQueries()+' and I am allowed up to '+Limits.getLimitQueries()+ ' within this request');

            Account a =[SELECT Id FROM Account WHERE LastName = 'TestAccountName'AND FirstName = 'test' LIMIT 1];
    /*        System.debug('I have performed '+Limits.getQueries()+' and I am allowed up to '+Limits.getLimitQueries()+ ' within this request');
            RecordType rt =[SELECT Id FROM RecordType WHERE Name ='Assistenza Agenti' LIMIT 1];
            Case c = new Case(Complainant__c='Customer',
                                Status = 'Open',
                                Phone_Call_Ids__c='78384',
                                Origin='Phone',
                                AccountId=a.Id,
                                Category__c='Duplicati polizza di risparmio',
                                SubCategory__c='Altro',
                                Distribution_Network__c='BNL',
                                RecordTypeId=rt.Id);
            insert c;

        // *****ACCOUNT_EMAILMESSAGE_001*****
            EmailMessage emailMSG2 = new EmailMessage(ParentId = c.Id,
                                                    Incoming= true);
            insert emailMSG2;
        // *****ACCOUNT_EMAILMESSAGE_002*****
           EmailMessage emailMSG1 = new EmailMessage(ParentId = c.Id,
                    Incoming = false,
                    FromName ='ContactHistoryTest');
            insert emailMSG1;*/
            List<Id> accList = new List<Id>();
            accList.add(a.Id);
        Test.startTest();
            ContactHistoryCTRL.ResponseDto result3 = ContactHistoryCTRL.getHistoryItemWrappers(accList,2);
            System.assertEquals(true,result3.isSuccess);
            System.assertEquals(true,result3.Values.size() > 0);
            List<ContactHistoryCTRL.HistoryItemWrapper> listItems3 = (List<ContactHistoryCTRL.HistoryItemWrapper>)result3.Values.get('ContactHistoryList');
            System.debug('********'+listItems3);
            System.assertEquals(false, listItems3.size() > 0);
        Test.stopTest();
    }    
}