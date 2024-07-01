/*------------------------------------------------------------------------
Author:        Davide Fabris
Company:       Deloitte
Class:         CampaignMembersViewCTRLTest_V2
Description:   Test for the CampaignPaget page  
History

14/07/2015     Davide Fabris - Created
----------------------------------------------------------------------------*/


@istest
public class CampaignMembersViewCTRLTest_V2{



    @testSetup static void setup() {//preparing test database
        // test.startTest();
        
        //Insert custom settings
        AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
        insert acv;
        CM_Page_Settings__c pageS = new CM_Page_Settings__c (Name = 'PageRecords', Numerical_Value__c = 1);
        insert pageS;
        
        //Insert CM possible status
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
        
        
        
        
        // Insert Client 
        Account Theclient = new Account();
        TheClient.TECH_Company__c = 'AAI';
        TheClient.NDG__c='1111111111';
        TheClient.Nodes__c='004123';
        TheCLient.AAI_Agency_Reference_Code__c = '004123';
        RecordType PF_RT = [SELECT id from RecordType where DeveloperName ='B2C_Client' Limit 1];
        TheClient.RecordTypeId = PF_RT.Id;
        TheClient.LastName = 'Rossi';
        TheClient.FirstName = 'Mario';
        
        Account Theclient2 = new Account();
        Theclient2.TECH_Company__c = 'AAI';
        Theclient2.NDG__c='2222222222';
        Theclient2.Nodes__c='004123';
        TheCLient.AAI_Agency_Reference_Code__c = '004123';
        Theclient2.RecordTypeId = PF_RT.Id;
        Theclient2.LastName = 'Verdi';
        Theclient2.FirstName = 'Luca';
        
        //Some nodes for visibility
        List<Node__c> theNodes = new List<Node__c>();
        Node__c AgencyNode = new Node__c();
        AgencyNode.Node_level__c=7;
        AgencyNode.Node_unique_code__c='004123';
        AgencyNode.Parent_node_unique_code__c='A001';
        AgencyNode.Tree_name__c='DIF';
        
        Node__c SubAgencyNode = new Node__c();
        SubAgencyNode.Node_level__c=8;
        SubAgencyNode.Node_unique_code__c='004123000001';
        SubAgencyNode.Parent_node_unique_code__c='004123';
        SubAgencyNode.Tree_name__c='DIF';        

        Node__c SubAgencyNode2 = new Node__c();
        SubAgencyNode2.Node_level__c=8;
        SubAgencyNode2.Node_unique_code__c='004123000002';
        SubAgencyNode2.Parent_node_unique_code__c='004123';
        SubAgencyNode2.Tree_name__c='DIF'; 
        
        //Insert IE for visibilityIntegration
        /** PURE IT Commento per rimuovere referenza di una classe commentata
        IE_Configuration__c IE_CIF_nodes_onCampaign= new IE_Configuration__c();
        IE_CIF_nodes_onCampaign.Name = 'CIF_nodes_onCampaign';
        IE_CIF_nodes_onCampaign.Type__c = 'WebService';
        IE_CIF_nodes_onCampaign.Direction__c = 'OUTBOUND';
        IE_CIF_nodes_onCampaign.Request_compiler__c = 'IE_Request_CIF_Nodes';
        IE_CIF_nodes_onCampaign.Response_parser__c = 'IE_CIFparserNodes';
        IE_CIF_nodes_onCampaign.NameSpacePrefix1__c = 'soapenv';
        IE_CIF_nodes_onCampaign.NameSpacePrefix2__c = 'crm';
        IE_CIF_nodes_onCampaign.NameSpaceUri1__c = 'http://schemas.xmlsoap.org/soap/envelope/';
        IE_CIF_nodes_onCampaign.NameSpaceUri2__c = 'http://crm.service.rgi.it/';
        IE_CIF_nodes_onCampaign.Endpoint__c = 'https://esg-pp.axa-medla.com/AXA_MEDLA/INT/it-cif-operations-v1-0-0';
        PURE IT Comment closure*/

        List<Sobject> SoList = new List<Sobject>();
        /** PURE IT Commento per rimuovere referenza di una classe commentata
        SoList.add(IE_CIF_nodes_onCampaign);
        PURE IT Comment closure */
        // Solist.add(TheClient);
        // Solist.add(TheClient2);
        SoList.add(AgencyNode);
        SoList.add(SubAgencyNode);
        SoList.add(SubAgencyNode2);
        Insert Solist;

        //Creating agent
        UserProvisioningAAI.UserDetailsInput UserInputAgent = new UserProvisioningAAI.UserDetailsInput();
        UserInputAgent.Active='0';
        UserInputAgent.FirstName='Agent';
        UserInputAgent.LastName='Agent';
        UserInputAgent.Email='agent@agent.it';
        UserInputAgent.UserName='agent@test.test';
        UserInputAgent.UserName='agen123321t@test.test'; //CAPOBIANCO_A 21/02/2018 BUGFIX DUPLICATE USERNAME
        UserInputAgent.MyriamUserName = 'ag_agent';
        UserInputAgent.AgencyCode = '004123';
        //UserInputAgent.Phone = '+393331234567';
       // UserInputAgent.Nodes__c = '004123';
        
        UserProvisioningAAI.UserNodeInput theNode = new UserProvisioningAAI.UserNodeInput();
        theNode.NodeCode = '4123';
        theNode.NodeLevel = 7;
        theNode.Profile = 'NFE - AAI - Vendite Avanzato';
        theNode.Functionality = 'Manager';
        theNode.AdminFlag = true;
        List<UserProvisioningAAI.UserNodeInput> thenodelist = new List<UserProvisioningAAI.UserNodeInput>();
        thenodelist.add(theNode);
        
        UserInputAgent.Nodes = thenodelist;
        
        //preparing the answer
        UserProvisioningAAI.ServiceResult theanswer = new UserProvisioningAAI.ServiceResult();
        theanswer = UserProvisioningAAI.UpsertUserAAI(UserInputAgent);
        // system.debug('++++theanswer '+theanswer );
        //Creating sub-agent
        UserProvisioningAAI.UserDetailsInput UserInputSubAgent = new UserProvisioningAAI.UserDetailsInput();
        UserInputSubAgent.Active='0';
        UserInputSubAgent.FirstName='SubAgent';
        UserInputSubAgent.LastName='SubAgent';
        UserInputSubAgent.Email='SubAgent@SubAgent.it';
        //UserInputSubAgent.UserName='SubAgent@test.test';
        UserInputSubAgent.UserName='SubAgent123321@test.test'; //CAPOBIANCO_A 21/02/2018 BUGFIX DUPLICATE USERNAME
        UserInputSubAgent.MyriamUserName = 'sub_subagent';
        UserInputSubAgent.AgencyCode = '004123';
        //UserInputSubAgent.Phone = '+393331234568';
      //  UserInputSubAgent.Nodes__c = '004123000001';
        
        UserProvisioningAAI.UserNodeInput theNodeSub = new UserProvisioningAAI.UserNodeInput();
        theNodeSub.NodeCode = '412300001';
        theNodeSub.NodeLevel = 8;
        theNodeSub.Profile = 'NFE - AAI - Vendite Base';
        theNodeSub.Functionality = 'User';
        theNodeSub.AdminFlag = true;
        List<UserProvisioningAAI.UserNodeInput> thenodelistSub = new List<UserProvisioningAAI.UserNodeInput>();
        thenodelistSub.add(theNodeSub);
        
        UserInputSubAgent.Nodes = thenodelistSub;
        
        //preparing the answer
        UserProvisioningAAI.ServiceResult theanswerSub = new UserProvisioningAAI.ServiceResult();
        theanswerSub = UserProvisioningAAI.UpsertUserAAI(UserInputSubAgent);
        // system.debug('++++theanswerSub '+theanswerSub );
        
        //Insert the clients so that they are shared
        List<Account> theClients = new List<Account>();
        theClients.add(TheClient);
        theClients.add(TheClient2);
        insert theClients;
        
        
        //Do the data preparation as the agent
        // System.debug(' ===> users: ' + [SELECT id from User where FirstName='Agent' Limit 1]);
        User theAgentU = [SELECT id from User where FirstName='Agent' Limit 1];
        //Create a campaign
        RecordType cpRT = [SELECT Id FROM RecordType WHERE SobjectType = 'Campaign' AND DeveloperName = 'Agency_campaign'];
        Campaign cp = new Campaign(
        Name = 'CampagnaTest',
        IsActive = true,
        Status = 'On-going',
        RecordTypeID = cpRT.Id,
        OwnerId=theAgentU.Id
        );

        insert cp;
        
        //Add campaignMembers
        List<account> allacc = [SELECT Id,PersonContactId,IsPersonAccount,RecordTypeId, RecordType.DeveloperName FROM Account WHERE IsPersonAccount=true];
        // system.debug('+++++####'+allacc.size());
        account acc=allacc.get(0);
        account acc2=allacc.get(1);
        // system.debug('++1'+acc);
        // system.debug('++2'+acc2);
        
        List<CampaignMember> campaignMembers = new List<CampaignMember>{
            new CampaignMember(
            ContactId = acc.PersonContactId,
            CampaignId = cp.Id,
            Owner__c = userinfo.getUserId(),
            Status = 'Interessato',
            Note__c = 'NoteTest'       
            ),
            new CampaignMember(
            ContactId = acc2.PersonContactId,
            CampaignId = cp.Id,
            Owner__c = userinfo.getUserId(),
            Status = 'Interessato',
            Note__c = 'NoteTest2'           
            )
        };
            insert campaignMembers;
        

    }
    
    static testMethod void changeOwnerAndExtendVisibility() {
        test.startTest();

        system.debug('+++++++_____SOQL'+Limits.getQueries()+'/'+Limits.getLimitQueries());
        system.debug('+++++++_____DML'+Limits.getDMLStatements());
        
        List<User> theUsers = [Select id, isactive, FirstName from user where FirstName='Agent' OR FirstName='SubAgent'];
        User theAgent = new User();
        User theSubAgent = new User();
        
        for (user U : theUsers) {
            if(U.FirstName=='Agent') {
                theAgent = U;
            }
            if(U.FirstName=='SubAgent') {
                theSubAgent=U;
            }
        }

        // system.debug('+++theagent'+theagent);
        // system.debug('+++theSubAgent'+theSubAgent);
        
        Campaign theCampaign = [SELECT id FROM Campaign WHERE Name='CampagnaTest' Limit 1];

        system.debug('+++++++_____SOQL'+Limits.getQueries()+'/'+Limits.getLimitQueries());
        system.debug('+++++++_____DML'+Limits.getDMLStatements());


            
        System.runAs(theAgent) {
        CampaignMembersViewCTRL controller = new CampaignMembersViewCTRL(new ApexPages.StandardController(theCampaign));
        
        system.debug('-------'+controller.RowRecords);
        controller.selectedAllpicks =true;
        for (CampaignMembersViewCTRL.CCWRowItem thisR : controller.RowRecords) {
            thisR.isSelected=true;
        }
        List<SelectOption> userToassign = controller.getAssignmentUser();
        system.debug('++++++'+userToassign);
        controller.SelectedUser = userToassign[2].getvalue();//0 is empty, 1 is the agent, 2 is the sub agent
        controller.sendEmailToOwner=true;
        

        controller.changeCampaignMemberOwner();

        //PageReference pgref = controller.gotToVisibilityMngmt();
        Test.setCurrentPage(Page.VisibilityManagement);

        //Select a node
        List<SelectOption> NodeToextend = controller.getNodesForVisibility();
        system.debug ('*******NodeToextend'+NodeToextend);
        controller.SelectedNodeVisibility = NodeToextend[1].getvalue();//0 is empty

        //Select all CM
        controller.selectedAllpicksVisibility=true;
        for (CampaignMembersViewCTRL.VisibilityRowItem thisR : controller.cmNotVisible) {
            thisR.isSelected=true;
        }
        system.debug('+++++++_____SOQL'+Limits.getQueries()+'/'+Limits.getLimitQueries());
        system.debug('+++++++_____DML'+Limits.getDMLStatements());

        CIF_Nodes_Mock mockServer = new CIF_Nodes_Mock();
        mockServer.TestCase = '';
        Test.setMock(HttpCalloutMock.class, mockServer);
        //controller.ExtendVisibility(); PURE IT - Necessita IE_configuration ma sopra l'abbiamo commentata per rimuovere la referenza
        } //runas Agent

        //push the button
        
                            

        // controller.goRimuovi();
        // controller.goAggiungi();
        // controller.OptionNodes[0].isSelected = true;
        // controller.modificaVisiblita();
        test.stopTest();

        
    }
}