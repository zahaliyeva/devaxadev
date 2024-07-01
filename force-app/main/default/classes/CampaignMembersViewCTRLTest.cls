/*------------------------------------------------------------------------
Author:        Dario Bovolenta, Davide Fabris
Company:       Deloitte
Class:         CampaignMembersExtendedViewTest
Description:   Test for the extension of the VF page of campaign members
               VF Page: CampaignMembersExtendedView
History

 06/07/2015     Dario Bovolenta    , Davide Fabris
----------------------------------------------------------------------------*/


@istest
public with sharing class CampaignMembersViewCTRLTest{



     @testSetup static void setup() {//preparing test database
     
     test.startTest();
    
   List<CampaignMembStatus__c> cms = new List<CampaignMembStatus__c>{
            new CampaignMembStatus__c(
                Name = 'Interested',
                Status_Name__c = 'Interessato',
                SortOrder__c = 3,
                IsDefault__c = true,
                Campaign_Record_Type__c='Agency_campaign'//MOSCATELLI_M 05/07/2017: Bugfix_Blocco inserimento/esclusione clienti                  
            ),
            new CampaignMembStatus__c(
                Name = 'Excluded',
                Status_Name__c = 'Escluso',
                SortOrder__c = 4,
                IsDefault__c = true,
                Campaign_Record_Type__c='Agency_campaign'//MOSCATELLI_M 05/07/2017: Bugfix_Blocco inserimento/esclusione clienti                  
            ),
            new CampaignMembStatus__c(
                Name = 'Call again',
                Status_Name__c = 'Da ricontattare',
                SortOrder__c = 5,
                IsDefault__c = true,
                Campaign_Record_Type__c='Agency_campaign'//MOSCATELLI_M 05/07/2017: Bugfix_Blocco inserimento/esclusione clienti                  
            ),
            new CampaignMembStatus__c(
                Name = 'Not interested',
                Status_Name__c = 'Non interessato',
                SortOrder__c = 6,
                IsDefault__c = true,
                Campaign_Record_Type__c='Agency_campaign'//MOSCATELLI_M 05/07/2017: Bugfix_Blocco inserimento/esclusione clienti                  
            )
        };
        insert cms;
        
        RecordType cpRT = [SELECT Id FROM RecordType WHERE SobjectType = 'Campaign' AND DeveloperName = 'Agency_campaign'];
        
        Campaign cp = new Campaign(
            Name = 'CampagnaTest',
            IsActive = true,
            Status = 'On-going',
            RecordTypeID = cpRT.Id,
            StartDate = Date.today(),
            EndDate = Date.today()+3
        );
        insert cp;
        
        Lead ld = new Lead(
            LastName = 'LeadTest',
            FirstName = 'test',
            Email = 'lead@mail.test',
            Phone = '0333333333',
            MobilePhone = '3333333333'
        );
        insert ld;
        

        
        System.runAs(new User(Id=UserInfo.getUserId()))
        {
                
                RecordType accRT = [SELECT Id,IsPersonType FROM RecordType WHERE SObjectType = 'Account' and DeveloperName = 'B2C_Client' ];
                List<Account> accountz = new List<Account>{
                 new Account(
                FirstName = 'AccountTest99',
                LastName = 'AccountTest00',
                PersonEmail = 'account@mail.test',
                Phone = '0333333333',
                PersonMobilePhone = '3333333333',
                Nodes__c = '5014',
                AAI_Agency_Reference_Code__c = '005014',
                RecordTypeID = accRT.id
            ),new Account(
                FirstName = 'AccountTest11',
                LastName = 'AccountTest22',
                PersonEmail = 'account@mail.test',
                Phone = '03333333331111',
                PersonMobilePhone = '3333333333111',
                Nodes__c = '5014',
                AAI_Agency_Reference_Code__c = '005014',
                RecordTypeID = accRT.id
            )};
            insert accountz;
            
        EmailTemplate validEmailTemplate = new EmailTemplate();
        validEmailTemplate.isActive = true;
        validEmailTemplate.Name = 'name';
        validEmailTemplate.DeveloperName = 'test';
        validEmailTemplate.TemplateType = 'text';
        validEmailTemplate.FolderId = UserInfo.getUserId();
        validEmailTemplate.Subject = 'Your Subject Here';
        insert validEmailTemplate;
            
        }
            //account acc =  [SELECT Id,PersonContactId,IsPersonAccount,RecordTypeId FROM Account WHERE FirstName = 'AccountTest99' and LastName = 'AccountTest00' ];
            List<account> allacc = [SELECT Id,PersonContactId,IsPersonAccount,RecordTypeId FROM Account WHERE PersonEmail= 'account@mail.test'];
        account acc=allacc.get(0);
        account acc2=allacc.get(1);

        
List<CampaignMember> campaignMembers = new List<CampaignMember>{
            new CampaignMember(
                LeadId = ld.Id, 
                ContactId = acc.PersonContactId,
                CampaignId = cp.Id,
                Owner__c = userinfo.getUserId(),
                Status = 'Interessato',
                Note__c = 'NoteTest'       
            ),
            new CampaignMember(
                LeadId = ld.Id, 
                ContactId = acc2.PersonContactId,
                CampaignId = cp.Id,
                Owner__c = userinfo.getUserId(),
                Status = 'Escluso',
                Note__c = 'NoteTest2'       
            )
        };
        insert campaignMembers;

List<Task> campaignTasks = new List<Task>{
            new Task(
                Subject = 'ContattoTEST',
                TECH_SourceId__c = campaignMembers[0].Id       
            ),
            new Task(
                Subject = 'ContattoTEST2',
                TECH_SourceId__c = campaignMembers[1].Id      
            )
        };
        insert campaignTasks;
        
        

        test.stopTest();
    }

    static testMethod void errorNodeExtendVisibility(){
        test.startTest();

        System.runAs(new User(Id=UserInfo.getUserId()))
        {
            AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
            insert acv;
        }

        PageReference pageRef = Page.CampaignMembersView;       
        Test.setCurrentPage(pageRef);

        ApexPages.currentPage().getParameters().put('pgType', 'LavorazioneCampagna');
        
        CM_Page_Settings__c pageS = new CM_Page_Settings__c (Name = 'PageRecords', Numerical_Value__c = 1);
        insert pageS;

        Campaign cp = [select id, Name, isActive, Status, RecordTypeID, StartDate, EndDate FROM Campaign where Name='CampagnaTest' limit 1];
        CampaignMembersViewCTRL controller = new CampaignMembersViewCTRL(new ApexPages.StandardController(cp));

        controller.ExtendVisibility();
        controller.goToCampaignPage();


        test.stopTest();
    }
    
    static testMethod void changeOwner() {
            test.startTest();
      
        System.runAs(new User(Id=UserInfo.getUserId()))
        {
            AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
            insert acv;
        }

        
       // Profile pvendite = [SELECT Id FROM Profile WHERE Name = 'NFE - AAI - Vendite Avanzato']; 
        
        PageReference pageRef = Page.CampaignMembersView;       
        Test.setCurrentPage(pageRef);

        ApexPages.currentPage().getParameters().put('pgType', 'LavorazioneCampagna');
        
        CM_Page_Settings__c pageS = new CM_Page_Settings__c (Name = 'PageRecords', Numerical_Value__c = 1);
        insert pageS;
     
        
        Campaign cp = [select id, Name, isActive, Status, RecordTypeID, StartDate, EndDate FROM Campaign where Name='CampagnaTest' limit 1];
        CampaignMembersViewCTRL controller = new CampaignMembersViewCTRL(new ApexPages.StandardController(cp));
        
        //controller.getExpireDateList();
        //controller.calcTotalPages();
        controller.getNodesList();
        controller.getStatusLists();
        controller.getAssignmentUser();
        controller.sendEmailToOwner=true; //true
        
        EmailTemplate validEmailTemplate = [SELECT Id, Name, FolderId, TemplateType, Subject FROM EmailTemplate WHERE Name='name' AND DeveloperName='test'];
        
        
        
List<CampaignMember> campaignMembers =[select id from CAmpaignMember where CampaignId = :cp.Id];
        controller.selectedRecordIds.add(campaignMembers[0].Id);
        controller.removeCampaignMember();
        controller.SelectedUser = userinfo.getUserId(); //usr1.id;//
        controller.changeCampaignMemberOwner();
        
        controller.doSelectAllItem();
       // controller.doDeselectAllItem();
       // controller.doSelectItem();
       // controller.doDeselectItem();

        controller.getHasNext();
        controller.getHasPrevious();
        controller.doNext();
        controller.doPrevious();
        controller.getNodesForVisibility();

        
        Integer res = controller.getSelectedCount();
        res = controller.getPageNumber();
      //  res = controller.getTotalPages();
       controller.changeCampaignMemberOwner();
       controller.selectedRecordIds.add(campaignMembers[0].Id);
       
       controller.SelectedUser = userinfo.getUserId();
       controller.changeCampaignMemberOwner();
     //   controller.removeCampaignMember();

       

     /*   */
        
        
        // set "nesun titolare" as owner
 
        
        
        
/*      
        
        controller.SelectedPrevCampaign='TCM Q2';
        controller.SelectedPrevStatus='Interessato';
        controller.executequery();
        
        controller.resetFilter();
        
        //I create a campaign to fill the previous campaign CM
        Campaign cp_old = new Campaign(
            Name = 'CampagnaTest_Previous',
            IsActive = false,
            Status = 'Completed',
            RecordTypeID = cpRT.Id
        );
        insert cp_old;
        
        CampaignMember cm_old = new CampaignMember(
            LeadId = ld.Id, 
            ContactId = acc.PersonContactId,
            CampaignId = cp_old.Id,
            Owner__c = userinfo.getUserId(),
            Status = 'Interessato',
            Note__c = 'NoteTest'
        );
        insert cm_old;
        
        controller.SelectedPrevCampaign=cp_old.Id;
        controller.SelectedPrevStatus='Interessato';
        controller.getPrevCampaignLists();
        controller.executequery();
        
        
        System.runAs(new User(Id=UserInfo.getUserId())) {
            system.debug('++++++++++++++++++');
            controller.resetfilter();
            controller.doSelectAllItem();
            controller.executequery();
        }
        
 */
    //Author: Luca Bassani----------------------------
    controller.getAll();
    controller.getvisibilityCheck();
    controller.getOwnerList();
    controller.showPopupAssegnazione();
    //controller.closePopupAssegnazione();
    controller.showPopupEsclusione();
    //controller.closePopupEsclusione();
    controller.showPopupStato();
    //controller.closePopupStato();
    controller.RefreshAfterPopup();
    //------------------------------------------------
            test.stopTest();

    }

static testMethod void noCM() {

        AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId()); 
        insert acv;
        test.startTest();
        
        

        PageReference pageRef = Page.CampaignMembersView;       
        Test.setCurrentPage(pageRef);

        ApexPages.currentPage().getParameters().put('pgType', 'GestioneCampagna');
        
        CM_Page_Settings__c pageS = new CM_Page_Settings__c (Name = 'PageRecords', Numerical_Value__c = 1);
        insert pageS;
        
         RecordType cpRT = [SELECT Id FROM RecordType WHERE SobjectType = 'Campaign' AND DeveloperName = 'Agency_campaign'];
        
        Campaign C = new Campaign(
            Name = 'CampagnaAgenzia',
            IsActive = true,
            Status = 'On-going',
            RecordTypeID = cpRT.Id
        );
        insert C;
        
Campaign cp = [select id, Name, isActive, Status, RecordTypeID FROM Campaign where Name='CampagnaAgenzia' limit 1];
CampaignMembersViewCTRL controller = new CampaignMembersViewCTRL(new ApexPages.StandardController(cp));
       
        Integer res = controller.getSelectedCount();
        res = controller.getPageNumber();
        //controller.getPromoPrivacy();
        controller.getPolicyBranchList();
        //controller.getPrevCampaignLists();
        /////////////////// select a node /////////////////////
        system.runAs(new User(Id=UserInfo.getUserId())) {
        controller.SelectedNode='5014';
        controller.SelectedOwner=userinfo.getUserId();//'Dario Bovolenta';
        controller.SelectedStatus='Interessato';
        controller.SelectedPolicyBranch='RE';
        //controller.promotionalPrivacyTerm='FALSE';
        controller.startTask.d.RecurrenceEndDateOnly=System.Today();
        controller.endTask.d.RecurrenceEndDateOnly=System.Today().adddays(10);
        controller.getNodesList();
        controller.getStatusLists();
        controller.getAssignmentUser();
        controller.sendEmailToOwner=false;
        
        //controller.SelectedPrevCampaign=allCampaigns[1].Id;
        //controller.SelectedPrevStatus='Interessato';
        //controller.getPrevCampaignLists();      
        
        

        
        res = controller.getSelectedCount();
      //  res = controller.getPageNumber();
       // res = controller.getTotalPages();
       controller.executequery();
       controller.SelectedOwner=userinfo.getUserId(); //Marchese
       //controller.promotionalPrivacyTerm='TRUE';
       controller.executequery();  
         
       controller.resetFilter();
       controller.getRecords();      
        }   
        
       ApexPages.currentPage().getParameters().put('pgType', 'LavorazioneCampagna');
       system.runAs(new User(Id=UserInfo.getUserId())) {
        controller.SelectedNode='5014';
        controller.SelectedOwner=userinfo.getUserId();//'Dario Bovolenta';
        controller.SelectedStatus='Interessato';
        controller.SelectedPolicyBranch='RE';
        //controller.promotionalPrivacyTerm='FALSE';
        controller.startTask.d.RecurrenceEndDateOnly=System.Today();
        controller.endTask.d.RecurrenceEndDateOnly=System.Today().adddays(10);
        controller.getNodesList();
        controller.getStatusLists();
        controller.getAssignmentUser();
        controller.sendEmailToOwner=false;
        
        //controller.SelectedPrevCampaign=allCampaigns[1].Id;
        //controller.SelectedPrevStatus='Interessato';
        //controller.getPrevCampaignLists();      
        
        

        
        res = controller.getSelectedCount();
      //  res = controller.getPageNumber();
       // res = controller.getTotalPages();
       controller.executequery();
       controller.SelectedOwner=userinfo.getUserId(); //Marchese
       //controller.promotionalPrivacyTerm='TRUE';
       controller.executequery();  
         
       controller.resetFilter();
       controller.getRecords();      
        }   
  
        test.stopTest();

     }      
        
        
        
        
 
 static testMethod void Filter() {
        AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
        insert acv;

/*        //user
        Map<string,Map<string,string>> rtypes = UtilityClass.fetchAllRTypes();
        id contact_agency = UtilityClass.getRTid(rtypes, 'Contact', 'Agency_Contact');
        id account_agency = UtilityClass.getRTid(rtypes, 'Account', 'Agency');
        id account_B2C = UtilityClass.getRTid(rtypes, 'Account', 'B2C_Client');
        Profile pvendite = [SELECT Id FROM Profile WHERE Name = 'NFE - AAI - Vendite Avanzato'];  
         
        //Create Partner User
        Account agencyAccount = new Account(Name = 'Agency Test Account',
                                            RecordTypeId = account_agency,
                                            Agency_Code__c = '006345');
        insert agencyAccount;
                       
        Contact agencyContact = new Contact(LastName = 'Agency Test Contact',
                                            RecordtypeId = contact_agency,
                                            AccountId = agencyAccount.Id);
        insert agencyContact;
               
        User usr1=new User(FirstName='Martijn12435123',
                           LastName = 'Reekmans', 
                           Alias = 'mreekm11', 
                           Email = 'mreekmans@deloitte.com', 
                           Username = 'mreekm11@axa.com.masterdev', 
                           CommunityNickname = 'MartiRe', 
                           LanguageLocaleKey = 'en_US',
                           TimeZoneSidKey='Europe/Paris',
                           Agency_Code__c = '006345',
                           Nodes__c = 'DIF_006345',
                           Profileid = pvendite.Id,
                           LocaleSidKey='en_US',
                           EmailEncodingKey='ISO-8859-1',
                           ContactId = agencyContact.Id);
        insert usr1;*/
        
       // Profile pvendite = [SELECT Id FROM Profile WHERE Name = 'NFE - AAI - Vendite Avanzato']; 
                test.startTest();

        PageReference pageRef = Page.CampaignMembersView;       
        Test.setCurrentPage(pageRef);

        //ApexPages.currentPage().getParameters().put('pgType', 'LavorazioneCampagna');
        
        CM_Page_Settings__c pageS = new CM_Page_Settings__c (Name = 'PageRecords', Numerical_Value__c = 1);
        insert pageS;
        /*Moved to setup
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
        insert cms;*/
        
        RecordType cpRT = [SELECT Id FROM RecordType WHERE SobjectType = 'Campaign' AND DeveloperName = 'Agency_campaign'];
        
    /*    Campaign cp = new Campaign(
            Name = 'CampagnaTest',
            IsActive = true,
            Status = 'On-going',
            RecordTypeID = cpRT.Id
        );
        insert cp;*/
        List<Campaign> allCampaigns = new List<Campaign>{
            new Campaign(
                Name = 'CampagnaTest',
                IsActive = true,
                Status = 'On-going',
                RecordTypeID = cpRT.Id      
            ),
            new Campaign(
                Name = 'CampagnaTest_Previous',
                IsActive = false,
                Status = 'Completed',
                RecordTypeID = cpRT.Id    
            )
        };
        insert allCampaigns;
            
        
        
        
        Lead ld = new Lead(
            LastName = 'LeadTest',
            FirstName = 'test',
            Email = 'lead@mail.test',
            Phone = '0333333333',
            MobilePhone = '3333333333'
        );
        insert ld;
        
        System.runAs(new User(Id=UserInfo.getUserId()))
        {
                
                RecordType accRT = [SELECT Id,IsPersonType FROM RecordType WHERE SObjectType = 'Account' and DeveloperName = 'B2C_Client' ];
                List<Account> accountz = new List<Account>{
                 new Account(
                FirstName = 'AccountTest99',
                LastName = 'AccountTest00',
                PersonEmail = 'account@mail.test',
                Phone = '0333333333',
                PersonMobilePhone = '3333333333',
                Nodes__c = '005014',
                RecordTypeID = accRT.id
            ),new Account(
                FirstName = 'AccountTest11',
                LastName = 'AccountTest22',
                PersonEmail = 'account@mail.test',
                Phone = '03333333331111',
                PersonMobilePhone = '3333333333111',
                Nodes__c = '005014',
                RecordTypeID = accRT.id
            )};
            insert accountz;
            

            
        }
            //account acc =  [SELECT Id,PersonContactId,IsPersonAccount,RecordTypeId FROM Account WHERE FirstName = 'AccountTest99' and LastName = 'AccountTest00' ];
            List<account> allacc = [SELECT Id,PersonContactId,IsPersonAccount,RecordTypeId FROM Account WHERE PersonEmail= 'account@mail.test'];
        account acc=allacc.get(0);
        account acc2=allacc.get(1);
      /*  Contact ct = new Contact(
            LastName = 'ContactTest',
            Account = acc
        );
        insert ct;*/


        
        List<CampaignMember> campaignMembers = new List<CampaignMember>{
            new CampaignMember(
                LeadId = ld.Id, 
                ContactId = acc.PersonContactId,
                CampaignId = allCampaigns[0].Id,
                Owner__c = userinfo.getUserId(),
                Status = 'Interessato',
                Sottostato__c='Inviata Email',   
                Note__c = 'NoteTest'       
            ),
            new CampaignMember(
                LeadId = ld.Id, 
                ContactId = acc2.PersonContactId,
                CampaignId = allCampaigns[0].Id,
                Owner__c = userinfo.getUserId(),
                Status = 'Da contattare',
                Sottostato__c='Richiesta di contatto da Email',  
                Note__c = 'NoteTest2'       
            )
        };
        insert campaignMembers;

        List<Task> campaignTasks = new List<Task>{
            new Task(
                Subject = 'ContattoTEST',
                TECH_SourceId__c = campaignMembers[0].Id       
            ),
            new Task(
                Subject = 'ContattoTEST2',
                TECH_SourceId__c = campaignMembers[1].Id      
            )
        };
        insert campaignTasks;
        
        
    /*  //I create a campaign to fill the previous campaign CM
        Campaign cp_old = new Campaign(
            Name = 'CampagnaTest_Previous',
            IsActive = false,
            Status = 'Completed',
            RecordTypeID = cpRT.Id
        );
        insert cp_old;*/
        
        CampaignMember cm_old = new CampaignMember(
            LeadId = ld.Id, 
            ContactId = acc.PersonContactId,
            CampaignId = allCampaigns[1].Id,
            Owner__c = userinfo.getUserId(),
            Status = 'Interessato',
            Note__c = 'NoteTest'
        );
        insert cm_old;
        


        
        CampaignMembersViewCTRL controller = new CampaignMembersViewCTRL(new ApexPages.StandardController(allCampaigns[0]));
        

       
        Integer res = controller.getSelectedCount();
        res = controller.getPageNumber();
        //controller.getPromoPrivacy();
        controller.getPolicyBranchList();
        controller.getStatusCampaignLists();
        controller.getStatusCampaignListsForAssignment();
        controller.getSubstatusCampaignLists();
        controller.getClientiPrioritari();
        controller.getStatusListsForAssignment();
        //controller.getPrevCampaignLists();
        /////////////////// select a node /////////////////////
        system.runAs(new User(Id=UserInfo.getUserId())) {
        controller.SelectedNode='00005014';
        controller.SelectedOwner=userinfo.getUserId();//'Dario Bovolenta';
        controller.SelectedStatus='Da contattare';
        controller.SelectedSubstatus='Richiesta di contatto da Email';
        controller.SelectedPriority='true';
        controller.SelectedPolicyBranch='RE';
        controller.LastNameFilter='AccountTest22';
        controller.FirstNameFilter='AccountTest11';
        //controller.promotionalPrivacyTerm='FALSE';
        controller.startTask.d.RecurrenceEndDateOnly=System.Today();
        controller.endTask.d.RecurrenceEndDateOnly=System.Today().adddays(10);
        controller.getNodesList();
        controller.getStatusLists();
        controller.getAssignmentUser();
        controller.sendEmailToOwner=false;
        
        //controller.SelectedPrevCampaign=allCampaigns[1].Id;
        //controller.SelectedPrevStatus='Interessato';
        //controller.getPrevCampaignLists();      
        
        //controller.showPopupVisibility();
        //controller.closePopupVisibility();

        
        res = controller.getSelectedCount();
      //  res = controller.getPageNumber();
       // res = controller.getTotalPages();
       controller.executequery();
       controller.SelectedOwner='Nessun Titolare';
       //controller.promotionalPrivacyTerm='TRUE';
       controller.executequery();  
         
       controller.resetFilter();
       controller.getRecords();
       controller.refresh();      
        }     
        test.stopTest();

     }
}