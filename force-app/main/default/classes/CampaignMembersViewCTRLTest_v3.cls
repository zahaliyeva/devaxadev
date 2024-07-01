@istest
public with sharing class CampaignMembersViewCTRLTest_v3{

    // Preparing Test Database
    @testSetup static void setup() {
        
        test.startTest();
        
        Map<string,Map<string,string>> rtypes = UtilityClass.fetchAllRTypes();
        id contact_agency = UtilityClass.getRTid(rtypes, 'Contact', 'Agency_Contact');
        id account_agency = UtilityClass.getRTid(rtypes, 'Account', 'Agency');
        id account_B2C = UtilityClass.getRTid(rtypes, 'Account', 'B2C_Client');
        id campaign_agency = UtilityClass.getRTid(rtypes, 'Campaign', 'Agency_campaign');
        id campaign_informative = UtilityClass.getRTid(rtypes, 'Campaign', 'Informative_Campaign');
        
        Profile pvendite = [SELECT Id FROM Profile WHERE Name = 'NFE - AAI - Vendite Avanzato'];  
        
        
        // Fill custom setting MappingASA__c
        MappingASA__c mapASA = new MappingASA__c();
        mapASA.Name = '1';
        mapASA.ASA__c ='Auto';
        mapASA.Codice_ASA__c = 1;
        mapASA.ASA_Description__c ='1 - Auto';
        
        Database.insert(mapASA);
        
        
        //Creation Agencies and Contact
        
        List<Account> agencies = New List<Account>();
        
        Account agencyAccount = new Account(Name = 'Agency Test Account', RecordTypeId = account_agency, Agency_Code__c = '006345xxxxxxxxxxxxxxxxxxxxxxx');
        agencies.add(agencyAccount);
        Account agencyAccount2 = new Account(Name = 'Agency Test Account2', RecordTypeId = account_agency, Agency_Code__c = '002310xxxxxxxxxxxxxxxxxxxxxxx');
        agencies.add(agencyAccount2);
        
        insert agencies;
        
        
        System.runAs(new User(Id=UserInfo.getUserId())) {
            List<Account> testacc = new List<Account>();
            
            Account acc = new Account(FirstName = 'AccountTest99',
                                      LastName = 'AccountTest00',
                                      PersonEmail = 'account@mail.test',
                                      Phone = '0333333333',
                                      PersonMobilePhone = '3333333333',
                                      Agency_Code__c = '006345xxxxxxxxxxxxxxxxxxxxxxx',
                                      Nodes__c = '006345xxxxxxxxxxxxxxxxxxxxxxx;',
                                      RecordTypeID = account_B2C);
            testacc.add(acc);
            
            Account acc2 = new Account(FirstName = 'AccountTest992',
                                       LastName = 'AccountTest002',
                                       PersonEmail = 'account@mail.test',
                                       Phone = '0333333333',
                                       PersonMobilePhone = '3333333333',
                                       Agency_Code__c = '006345xxxxxxxxxxxxxxxxxxxxxxx',
                                       Nodes__c = '006345xxxxxxxxxxxxxxxxxxxxxxx;',
                                       RecordTypeID = account_B2C);
            testacc.add(acc2);
            
            insert testacc;
        }
        
        account acc = [SELECT Id,PersonContactId,IsPersonAccount,RecordTypeId FROM Account WHERE FirstName = 'AccountTest99' and LastName = 'AccountTest00' ];
        account acc2 = [SELECT Id,PersonContactId,IsPersonAccount,RecordTypeId FROM Account WHERE FirstName = 'AccountTest992' and LastName = 'AccountTest002'];
        
        
        List<Contact> agents = new List<Contact>();
        
        Contact agencyContact = new Contact(LastName = 'Agency Test Contact', RecordtypeId = contact_agency, AccountId = agencyAccount.Id);
        agents.add(agencyContact);
        
        Contact agencyContact2 = new Contact(LastName = 'Agency Test Contact2', RecordtypeId = contact_agency, AccountId = agencyAccount2.Id);
        agents.add(agencyContact2);
        
        Contact ct = new Contact(LastName = 'ContactTest', Account = acc);
        Contact ct2= new Contact(LastName = 'ContactTest2', Account = acc2);
        
        agents.add(ct);
        agents.add(ct2);
        
        insert agents;
        
        
        
        //Creating Partner User
        
        List<User> users = new List<User>();
        
        User usr1=new User(FirstName='Martijn',
                           LastName = 'Reekmans', 
                           Alias = 'mreekm11', 
                           Email = 'mreekmans@deloitte.com', 
                           Username = 'mreekm11@axa.com.masterdev', 
                           CommunityNickname = 'MartiRe', 
                           LanguageLocaleKey = 'en_US',
                           TimeZoneSidKey='Europe/Paris',
                           Agency_Code__c = '006345xxxxxxxxxxxxxxxxxxxxxxx',
                           Nodes__c = 'DIF_006345xxxxxxxxxxxxxxxxxxxxxxx',
                           Profileid = pvendite.Id,
                           LocaleSidKey='en_US',
                           EmailEncodingKey='ISO-8859-1',
                           ContactId = agencyContact.Id);
        users.add(usr1);
        
        User usr2=new User(FirstName='Martijn',
                           LastName = 'Reekmans2', 
                           Alias = 'mreekm12', 
                           Email = 'mreekmans2@deloitte.com', 
                           Username = 'mreekm12@axa.com.masterdev', 
                           CommunityNickname = 'MartiR2', 
                           LanguageLocaleKey = 'en_US',
                           TimeZoneSidKey='Europe/Paris',
                           Agency_Code__c = '002310xxxxxxxxxxxxxxxxxxxxxxx',
                           Nodes__c = 'DIF_002310xxxxxxxxxxxxxxxxxxxxxxx',
                           Profileid = pvendite.Id,
                           LocaleSidKey='en_US',
                           EmailEncodingKey='ISO-8859-1',
                           ContactId = agencyContact2.Id);
        users.add(usr2);
        
        //User
        user userAdmin = new User(Username = 'testclassNewActivityCampaign@test.axa.com',
                                  LastName = 'testuser',
                                  LanguageLocaleKey = 'en_US',
                                  FirstName = 'test',
                                  Email = 'test@test.com',
                                  Alias = 'test',
                                  TimeZoneSidKey = 'Europe/Dublin',
                                  LocaleSidKey = 'en_US',
                                  EmailEncodingKey = 'UTF-8',
                                  Nodes__c = 'DIF_002310xxxxxxxxxxxxxxxxxxxxxxx',
                                  Agency_Code__c = '002310xxxxxxxxxxxxxxxxxxxxxxx',
                                  ProfileId = AP_Constants.getProfileAdminId()
                                 );
        
        users.add(userAdmin);
        
        insert users;
        
        
        // Creation Campaign and Campaign Member
        List<CampaignMembStatus__c> cms = new List<CampaignMembStatus__c>{
            new CampaignMembStatus__c(
                Name = 'Interested',
                Status_Name__c = 'Interessato',
                SortOrder__c = 3,
                IsDefault__c = true         
            ),
            new CampaignMembStatus__c(
                Name = 'Excluded',
                Status_Name__c = 'Escluso',
                SortOrder__c = 4,
                IsDefault__c = true         
            ),
            new CampaignMembStatus__c(
                Name = 'Call again',
                Status_Name__c = 'Da ricontattare',
                SortOrder__c = 5,
                IsDefault__c = true         
            ),
            new CampaignMembStatus__c(
                Name = 'Not interested',
                Status_Name__c = 'Non interessato',
                SortOrder__c = 6,
                IsDefault__c = true         
            )
        };
        insert cms;
        
        Campaign cp = new Campaign(
            Name = 'CampagnaTest',
            IsActive = true,
            Status = 'On-going',
            ASA__c = '1',
            RecordTypeID = campaign_agency);
        insert cp;
        
        List<Lead> cpleads = new List<Lead>();
        
        Lead ld = new Lead(
            LastName = 'LeadTest',
            FirstName ='test',
            Email = 'lead@mail.test',
            Phone = '0333333333',
            Agency_Code__c = '006345xxxxxxxxxxxxxxxxxxxxxxx',
            MobilePhone = '3333333333');
        
        cpleads.add(ld);    
        
        Lead ld2 = new Lead(
            LastName = 'LeadTest2',
            FirstName ='test',
            Email = 'lead2@mail.test',
            Phone = '0333333333',
            Agency_Code__c = '006345xxxxxxxxxxxxxxxxxxxxxxx',
            MobilePhone = '3333333333');
        
        cpleads.add(ld2);
        
        insert cpleads;
        
        
        
        List<CampaignMember> allCMs = new List<CampaignMember>();
        
        CampaignMember cm = new CampaignMember(
            LeadId = ld.Id, 
            ContactId = acc.PersonContactId,
            CampaignId = cp.Id,
            Owner__c = usr1.Id,
            Status = 'Interessato',
            Note__c = 'CM1');
        
        CampaignMember cm2 = new CampaignMember(
            LeadId = ld2.Id, 
            ContactId = acc2.PersonContactId,
            CampaignId = cp.Id,
            Owner__c = usr1.Id,
            Status = 'Interessato',
            Note__c = 'CM2');
        
        allCMs.add(cm);    
        allCMs.add(cm2);
        
        insert allCMs;
        
        
        
        List<Task> allTasks = new List<Task>();
        
        Task tsk = new Task(
            Subject = 'Chiamata',
            TECH_SourceId__c = cm.Id,
            Way_of_contact__c = 'Altro'
        );

        Task tsk2 = new Task(
            Subject = 'Chiamata',
            TECH_SourceId__c = cm2.Id,
            Way_of_contact__c = 'Altro'
        );
        
        allTasks.add(tsk);    
        allTasks.add(tsk2);
        
        insert allTasks;
        
        
        
        //INFORMATIVE CAMPAIGN DATA SETUP
        Campaign infoCamp = new Campaign(
            Name = 'CampagnaInformativa1',
            IsActive = true,
            Status = 'On-going',
            ASA__c = '1',
            Contact_Value__c = 'Assicurato in vita;Assicurato deceduto;Non rintracciato',
            Contact_Alert__c = 'Assicurato in vita;Assicurato deceduto;Non rintracciato',
            Action__c = 'Tracciamento su Account vivo/morto/x',
            RecordTypeID = campaign_informative);
        insert infoCamp;
        
        List<CampaignMember> infoCMs = new List<CampaignMember>();

        CampaignMember icm1 = new CampaignMember(
            LeadId = ld.Id, 
            ContactId = acc.PersonContactId,
            CampaignId = infoCamp.Id,
            Owner__c = usr1.Id,
            Status = 'Non risponde',
            Note__c = 'ICM1');
        
        CampaignMember icm2 = new CampaignMember(
            LeadId = ld2.Id, 
            ContactId = acc2.PersonContactId,
            CampaignId = infoCamp.Id,
            Owner__c = usr1.Id,
            Status = 'Da ricontattare',
            Note__c = 'ICM2');
        infoCMs.add(icm1);    
        infoCMs.add(icm2);
        insert infoCMs;
        
        
        List<Task> infoTasks = new List<Task>();
        
        Task itask = new Task(
            Subject = 'Chiamata',
            TECH_SourceId__c = icm1.Id,
            Way_of_contact__c = 'Altro'
        );
        
        infoTasks.add(itask);
        insert infoTasks;
        
        
        
        // Creation Campaign and Campaign Member
        List<AccountClientIndex__c> ACI = new List<AccountClientIndex__c>{
            new AccountClientIndex__c(
                Name = '0 - non segmentabile',
                Client_Index_Name__c = '0 - non segmentabile',
                Client_Index_Number__c = 0,
                SortOrder__c = 1
            ),
            new AccountClientIndex__c(
                Name = '1 - prof P&C negativa',
                Client_Index_Name__c = '1 - profittabilità P&C negativa',
                Client_Index_Number__c = 1,
                SortOrder__c = 2
            ),
            new AccountClientIndex__c(
                Name = '2 - prof bassa',
                Client_Index_Name__c = '2 - profittabilità bassa',
                Client_Index_Number__c = 2,
                SortOrder__c = 3
            ),
            new AccountClientIndex__c(
                Name = '3 - prof media / det bassa',
                Client_Index_Name__c = '3 - profittabilità media / detenzione bassa',
                Client_Index_Number__c = 3,
                SortOrder__c = 4
            )
        };
        insert ACI;
        
        test.StopTest();
    }

    static testMethod void allGetMethods() {
        
        PageReference pageRef = Page.CampaignMembersView;       
        Test.setCurrentPage(pageRef);
        
        CM_Page_Settings__c pageS = new CM_Page_Settings__c (Name = 'PageRecords', Numerical_Value__c = 1);
        insert pageS;
        AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId()); 
        insert acv;
        AAI_Code_Variables__c acv2 = new AAI_Code_Variables__c(Name='DAOL_URL_Prefix_CreaPropostaAccount', Value__c=''); 
        insert acv2;
        
        Campaign cp = [SELECT Id, Name, isActive, Status, RecordTypeID FROM Campaign where Name='CampagnaTest' LIMIT 1];
        CampaignMembersViewCTRL controller = new CampaignMembersViewCTRL(new ApexPages.StandardController(cp));
        
        List<CampaignMember> campaignMembers =[SELECT Id FROM CampaignMember WHERE CampaignId = :cp.Id];
        controller.selectedRecordIds.add(campaignMembers[0].Id);
        controller.removeCampaignMember();
        controller.SelectedUser = userinfo.getUserId();
        controller.changeCampaignMemberOwner();
        
        
        controller.getHasNext();
        controller.getHasPrevious();
        controller.doNext();
        controller.doPrevious();
        controller.getNodesForVisibility();
        controller.getClientiPrioritari();
        controller.getIndiceCliente();
        controller.getPriorityList();
        controller.getOpportunityStatus();
        
        /*
        controller.getNodesList();
        controller.getOwnerList();
        controller.getStatusCampaignLists();
        controller.getStatusCampaignListsForAssignment();
        controller.getSubstatusCampaignLists();
        controller.getIsProcessedList();
		*/
        
        controller.showPopupAssegnazione();
        controller.showPopupStato();
        controller.showPopupVisibility();
        controller.showPopupEsclusione();
        controller.closePopup();
        
        controller.cmID = campaignMembers[0].Id;
        
        controller.tcPositive();
        controller.tcRecall();
        controller.tcNegative();
        controller.tcInformative();
        
        controller.saveTC();
                
        controller.createProposal();
        controller.closeCP();
        
        
        
        // Location
        
        Boolean flag = true;
        controller.myAppointment.Luogo_appuntamento__c = '';
        controller.changeIndirizzo();
        if(controller.myAppointment.Location != '')
            flag = false;
        controller.myAppointment.Luogo_appuntamento__c = 'Presso cliente';
        controller.changeIndirizzo();
        System.assertEquals(true,flag);
        
    }
    
    static testMethod void Filter() {
        
        AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
        insert acv;
        
        test.startTest();
        
        PageReference pageRef = Page.CampaignMembersView;       
        Test.setCurrentPage(pageRef);
        
        
        CM_Page_Settings__c pageS = new CM_Page_Settings__c (Name = 'PageRecords', Numerical_Value__c = 1);
        insert pageS;
        
        Campaign cp = [SELECT Id, Name, isActive, Status, RecordTypeID FROM Campaign where Name='CampagnaTest' LIMIT 1];
        User userVendite = [SELECT FirstName, LastName, Alias, Email, Username, CommunityNickname, LanguageLocaleKey, TimeZoneSidKey, Agency_Code__c, Nodes__c, Profileid, LocaleSidKey,EmailEncodingKey,ContactId FROM User WHERE username = 'mreekm11@axa.com.masterdev'];
        
        CampaignMembersViewCTRL controller = new CampaignMembersViewCTRL(new ApexPages.StandardController(cp));
        
        Integer res = controller.getSelectedCount();
        res = controller.getPageNumber();
        controller.getPolicyBranchList();
        controller.getStatusCampaignLists();
        controller.getStatusCampaignListsForAssignment();
        controller.getSubstatusCampaignLists();
        controller.getClientiPrioritari();
        controller.getStatusListsForAssignment();
        
        /////////////////// select a node /////////////////////
        system.runAs(new User(Id=UserInfo.getUserId())) {
        //system.runAs(userVendite) {
            
            //controller.CampaignId = cp.Id;
            
            controller.SelectedNode='00005014';
            controller.SelectedOwner=userinfo.getUserId();//'Dario Bovolenta';
            controller.SelectedStatus='Da contattare';
            controller.SelectedSubstatus='Richiesta di contatto da Email';
            controller.SelectedPriority='true';
            controller.SelectedPolicyBranch='RE';
            controller.LastNameFilter='AccountTest22';
            controller.FirstNameFilter='AccountTest11';
            controller.startTask.d.RecurrenceEndDateOnly=System.Today();
            controller.endTask.d.RecurrenceEndDateOnly=System.Today().adddays(10);
            
            controller.getNodesList();
            controller.getStatusLists();
            controller.getAssignmentUser();
            controller.sendEmailToOwner=false;
            
            res = controller.getSelectedCount();
            controller.executequery();
            controller.SelectedOwner='Nessun Titolare';
            controller.executequery();  
            
            controller.resetFilter();
            controller.getRecords();
            controller.refresh();
            controller.refreshAfterPopup();
        }
        test.stopTest();

     }
        
    static testMethod void changeAppointmentTime() {
        
        PageReference pageRef = Page.CampaignMembersView;       
        Test.setCurrentPage(pageRef);
        
        CM_Page_Settings__c pageS = new CM_Page_Settings__c (Name = 'PageRecords', Numerical_Value__c = 1);
        insert pageS;
        
        Campaign cp = [SELECT Id, Name, isActive, Status, RecordTypeID FROM Campaign where Name='CampagnaTest' LIMIT 1];
        CampaignMembersViewCTRL controller = new CampaignMembersViewCTRL(new ApexPages.StandardController(cp));
        
        
        // Time
        
        Boolean flag = true;
        list<SelectOption> InappTimes = controller.getInTimesAppointment();
        list<SelectOption> outappTimes = controller.getOutTimesAppointment();
        list<SelectOption> taskTimes = controller.getTimesTask();
        list<SelectOption> taskEventTimes = controller.getTimesTaskEvent();
        
        list<SelectOption> assignmentUsers = controller.getTaskAssignmentUser();
        //controller.tmp.Effective_date__c = Date.newInstance(1700,1,1);
        controller.inTime = '11:15';
        controller.updateEventEndTime();
        
        if(controller.myAppointment.StartDateTime != Datetime.newInstance(1700,1,1,11,15,0)) flag = false;
        if(controller.myAppointment.EndDateTime != Datetime.newInstance(1700,1,1,12,15,0)) flag = false;
        
        controller.outTime = '19:45';
        
        if(controller.myAppointment.StartDateTime != Datetime.newInstance(1700,1,1,11,15,0)) flag = false;
        if(controller.myAppointment.EndDateTime != Datetime.newInstance(1700,1,1,19,45,0)) flag = false;
        
    }
    
    static testMethod void informativeCampaign() {
        // INFORMATIVE CAMPAIGN TEST
        test.startTest();
        
        PageReference pageRef = Page.CampaignMembersView;
        Test.setCurrentPage(pageRef);
        
        CM_Page_Settings__c pageS = new CM_Page_Settings__c (Name = 'PageRecords', Numerical_Value__c = 1);
        insert pageS;
        
        Campaign cp = [SELECT Id, Name, isActive, Status, RecordTypeID FROM Campaign where Name='CampagnaInformativa1' LIMIT 1];
        CampaignMembersViewCTRL controller = new CampaignMembersViewCTRL(new ApexPages.StandardController(cp));
        
        CampaignMember icm1 = [SELECT LeadId, ContactId, CampaignId, Owner__c, Status,Note__c FROM CampaignMember WHERE Note__c= 'ICM1'];
        User usrAdm = [SELECT FirstName, LastName, Alias, Email, Username, CommunityNickname, LanguageLocaleKey, TimeZoneSidKey, Agency_Code__c, Nodes__c, Profileid, LocaleSidKey,EmailEncodingKey,ContactId FROM User WHERE username ='testclassNewActivityCampaign@test.axa.com'];  
        
        system.runAs(usrAdm){
            controller.cmID = icm1.Id;
            controller.tcInformative();
            controller.buttonValue = 'Assicurato in vita';
            controller.informativaClick();
            controller.selectEsitoDiServizio();
            controller.backTC();
            controller.closePopupInformative();
        }
        
        test.stopTest();
    }
}