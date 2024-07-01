/*------------------------------------------------------------------------
Author:        Davide Fabris
Company:       Deloitte
Class:         DashboardRemoter_TEST
Description:   Test for the DashboardRemoter class
History
09/09/2016     Davide Fabris - Created
----------------------------------------------------------------------------*/


@istest
public class DashboardRemoter_TEST{

    @testSetup static void setup() {//preparing test database
        test.startTest();
        //Insert custom settings
        AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
        insert acv;
        
        //Must prepare the procedure, and the tests
        Procedure_Definition__c PD = new Procedure_Definition__c();
        PD.is_Active__c=true;
        PD.Unique_Name__c='MonitoraggioTest';
        
        insert PD;
        
        Procedure_Step__c S1 = new Procedure_Step__c();
        S1.is_Active__c = true;
        S1.isNext__c = true;
        S1.Order__c = '1';
        S1.Procedure_Definition__c=PD.Id;
        S1.Query_To_Run__c = 'SELECT Contact.Account.RSAC_Description_Code__c,Contact.Account.Department_Chief_Description_Code__c, Contact.Account.RSA_Description_Code__c, Agency_Code__c, CommunityNickname, Email, FirstName, Id, IsActive, IsPortalEnabled, LastName, Main_Node__c, Name, Nodes__c, Nodes_tree__c, PortalRole, ProfileId, Username, UserRoleId, UserType,Profile.Name,UserRole.DeveloperName FROM User WHERE isActive= true AND IsPortalEnabled = true ORDER BY Agency_Code__c Limit 10';
        S1.Scope__c = 200;
        S1.Step_Handler_Class__c = 'PSH_UserHandler';
        
        Procedure_Step__c S2 = new Procedure_Step__c();
        S2.is_Active__c = true;
        S2.isNext__c = false;
        S2.Order__c = '2';
        S2.Procedure_Definition__c=PD.Id;
        S2.Query_To_Run__c = 'SELECT id, Owner__c, Status, LastModifieddateOfInterest__c, LastModifiedById, LastmodifiedDate, CampaignId,Agency_Code__c, Campaign_member_related_opportunity__c, Campaign_member_related_opportunity__r.StageName, Campaign_member_related_opportunity__r.LastModifieddateOfInterest__c, Campaign_member_related_opportunity__r.isWon FROM CampaignMember WHERE Owner__c!=\'\' and Owner__r.isactive=true AND ( (LastModifieddateOfInterest__c=THIS_WEEK) OR (Status in (\'To be contacted\', \'Call again\',\'Interested\', \'Not interested\', \'Wrong contact information\') ) ) ORDER BY Owner__c, Agency_Code__c';
        S2.Scope__c = 200;
        S2.Step_Handler_Class__c = 'PSH_CMHandler';
        //just insertig some DashboardRows with the batch

        List<Procedure_Step__c> theSteps = new List<Procedure_Step__c>{S1,S2};
        insert theSteps;
        
        Apex_Schedulation_Manager__c ASM_CS= new Apex_Schedulation_Manager__c(
        Name='TheBatchProcedure',
        Autoschedule__c=true,
        Expression__c='',
        Frequency__c=5,
        Scope__c=200,
        Send_Log__c=false
        );        
        insert ASM_CS;        
        
        
       //Some nodes for visibility
        List<Node__c> theNodes = new List<Node__c>();
        Node__c ManagerNode = new Node__c();
        ManagerNode.Node_level__c=6;
        ManagerNode.Node_unique_code__c='A001';
        ManagerNode.Parent_node_unique_code__c='TOP';
        ManagerNode.Tree_name__c='DIF';
        
        Node__c AgencyNode = new Node__c();
        AgencyNode.Node_level__c=7;
        AgencyNode.Node_unique_code__c='009999';
        AgencyNode.Parent_node_unique_code__c='A001';
        AgencyNode.Tree_name__c='DIF';
        
        Node__c SUBAgencyNode = new Node__c();
        SUBAgencyNode.Node_level__c=8;
        SUBAgencyNode.Node_unique_code__c='009999000001';
        SUBAgencyNode.Parent_node_unique_code__c='009999';
        SUBAgencyNode.Tree_name__c='DIF';
        
        
        List<Sobject> SoList = new List<Sobject>();
        SoList.add(AgencyNode);
        SoList.add(SUBAgencyNode);
        SoList.add(ManagerNode);

        Insert Solist;
        
        //Update the Agency Account with SalesManager &contact
        Account theAgency = [SELECT id from Account where Agency_Code__c = '009999' LIMIT 1];
        theAgency.RSAC_Description_Code__c = 'THE AREA MANAGER';
        theAgency.RSA_Description_Code__c = 'THE SALES MANAGER';
        theAgency.Department_Chief_Description_Code__c = 'THE WELFARE MANAGER';
        update theAgency;
        
        
        //Creating agent
        UserProvisioningAAI.UserDetailsInput UserInputAgent = new UserProvisioningAAI.UserDetailsInput();
        UserInputAgent.Active='0';
        UserInputAgent.FirstName='Agent';
        UserInputAgent.LastName='Agent';
        UserInputAgent.Email='agent@agent.it';
        UserInputAgent.UserName='agentXYZ@testXYZ.test';
        UserInputAgent.MyriamUserName = 'ag_agent';
        UserInputAgent.AgencyCode = '009999';
        //UserInputAgent.Phone = '3880000000';
        
        UserProvisioningAAI.UserNodeInput theNode = new UserProvisioningAAI.UserNodeInput();
        theNode.NodeCode = '9999';
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
//        system.debug('++++this answer 1 '+ theanswer );
        
        
        //Creating SUB- agent
        UserProvisioningAAI.UserDetailsInput UserInputSUBAgent = new UserProvisioningAAI.UserDetailsInput();
        UserInputSUBAgent.Active='0';
        UserInputSUBAgent.FirstName='SUBAgent';
        UserInputSUBAgent.LastName='SUBAgent';
        UserInputSUBAgent.Email='SUBagent@agent.it';
        UserInputSUBAgent.UserName='SUBagentXYZ@testXYZ.test';
        UserInputSUBAgent.MyriamUserName = 'subag_subagent';
        UserInputSUBAgent.AgencyCode = '009999';
        //UserInputSUBAgent.Phone = '3330000000';
        
        UserProvisioningAAI.UserNodeInput theNodeSUB = new UserProvisioningAAI.UserNodeInput();
        theNodeSUB.NodeCode = '999900001';
        theNodeSUB.NodeLevel = 8;
        theNodeSUB.Profile = 'NFE - AAI - Vendite Base';
        theNodeSUB.Functionality = 'User';
        theNodeSUB.AdminFlag = true;
        List<UserProvisioningAAI.UserNodeInput> thenodelistSUB = new List<UserProvisioningAAI.UserNodeInput>();
        thenodelistSUB.add(theNodeSUB);
        
        UserInputSUBAgent.Nodes = thenodelistSUB;
        
        //preparing the answer
        UserProvisioningAAI.ServiceResult theanswerSUB = new UserProvisioningAAI.ServiceResult();
        theanswerSUB = UserProvisioningAAI.UpsertUserAAI(UserInputSUBAgent);
//        system.debug('++++this answer 2 '+theanswerSUB );
        
        
        //Creating SALES MANAGER
        system.runas(new User(id=UserInfo.getuserID())) {
        UserProvisioningAAI.UserDetailsInput UserInputMANAGER = new UserProvisioningAAI.UserDetailsInput();
        UserInputMANAGER.Active='0';
        UserInputMANAGER.FirstName='THE SALES';
        UserInputMANAGER.LastName='MANAGER';
        UserInputMANAGER.Email='MANAGER@MANAGER.it';
        UserInputMANAGER.UserName='MANAGER@MANAGER.test';
        UserInputMANAGER.MyriamUserName = 'MANAGER';
        UserInputMANAGER.AgencyCode = '';
        //UserInputMANAGER.Phone = '3770000000';
        
        UserProvisioningAAI.UserNodeInput theNodeMANAGER = new UserProvisioningAAI.UserNodeInput();
        theNodeMANAGER.NodeCode = 'A001';
        theNodeMANAGER.NodeLevel = 6;
        theNodeMANAGER.Profile = 'AAI - Dipartimento Avanzato';
        theNodeMANAGER.Functionality = 'A001';
        theNodeMANAGER.AdminFlag = true;
        List<UserProvisioningAAI.UserNodeInput> thenodelistMANAGER = new List<UserProvisioningAAI.UserNodeInput>();
        thenodelistMANAGER.add(theNodeMANAGER);
        
        UserInputMANAGER.Nodes = thenodelistMANAGER;
        
        //preparing the answer
        UserProvisioningAAI.ServiceResult theanswerManager = new UserProvisioningAAI.ServiceResult();
        theanswerSUB = UserProvisioningAAI.UpsertUserAAI(UserInputMANAGER);
//        system.debug('++++this answer 3 '+theanswerManager );
        
        }
        
        TheBatchProcedure TheB = new TheBatchProcedure();
        Database.ExecuteBatch(TheB);
        test.stopTest();
    }
    
    static testmethod void TEST_DashboardRemoter(){
    //check if you can see the rows
    List<Dashboard_Row__c> Drs = [SELECT id from Dashboard_Row__c];
    system.debug('+++++ùùùùù'+Drs.size());
        //Retreive filter options
        //the order is UserId, Anno, Mese, AreaManager,SalesManager,Agenzia
        DashboardRemoter.PageDetails PD = DashboardRemoter.retrieveFilterOptions('','null','null','','','');
        system.debug('++++PD'+PD);
        //the order is AreaManager, SalesManager, Agency, UserId, Anno, Mese, Settimana, Focus,  Type
        DashboardRemoter.retrievePlotPoints( 'Tutti','Tutti','Tutte','Tutti',PD.SelectedYear,PD.SelectedMonth,PD.WeekOptionsId[0],'', 'Campaign');
        DashboardRemoter.retrieveTableRows( 'Tutti','Tutti','Tutte','Tutti',PD.SelectedYear,PD.SelectedMonth,PD.WeekOptionsId[0],'', 'Campaign');
        
        //Assuming there is always an agency active user
        User theAgent = [Select Id from User where isPortalEnabled= true AND isActive = true AND Username='agentXYZ@testXYZ.test' Limit 1 ];
        system.runAs(theAgent) {
            DashboardRemoter.PageDetails PDAgent = DashboardRemoter.retrieveFilterOptions('','null','null','','','');
            system.debug('àòàòàòàò'+PDAgent);
            DashboardRemoter.retrievePlotPoints( PDAgent.AreaManagerOptions[0],PDAgent.SalesManagerOptions[0],PDAgent.AgencyOptions[0],'Tutti',PDAgent.SelectedYear,PDAgent.SelectedMonth,PDAgent.WeekOptionsId[0],'', 'Campaign');
            DashboardRemoter.retrieveTableRows( PDAgent.AreaManagerOptions[0],PDAgent.SalesManagerOptions[0],PDAgent.AgencyOptions[0],'Tutti',PDAgent.SelectedYear,PDAgent.SelectedMonth,PDAgent.WeekOptionsId[0],'', 'Campaign');
        }
        
        User theSubAgent = [Select Id from User where isPortalEnabled= true AND isActive = true AND Username='SUBagentXYZ@testXYZ.test' Limit 1 ];
        system.runAs(theSubAgent) {
            DashboardRemoter.PageDetails PDSUBAgent = DashboardRemoter.retrieveFilterOptions('','null','null','','','');
            DashboardRemoter.retrievePlotPoints( PDSUBAgent.AreaManagerOptions[0],PDSUBAgent.SalesManagerOptions[0],PDSUBAgent.AgencyOptions[0],theSubAgent.Id,PDSUBAgent.SelectedYear,PDSUBAgent.SelectedMonth,PDSUBAgent.WeekOptionsId[0],'', 'Campaign');
            DashboardRemoter.retrieveTableRows( PDSUBAgent.AreaManagerOptions[0],PDSUBAgent.SalesManagerOptions[0],PDSUBAgent.AgencyOptions[0],theSubAgent.Id,PDSUBAgent.SelectedYear,PDSUBAgent.SelectedMonth,PDSUBAgent.WeekOptionsId[0],'', 'Campaign');
        }
        
        User theManager = [Select Id from User where isActive = true AND UserName='MANAGER@MANAGER.test' Limit 1 ];
        system.runAs(theManager) {
            DashboardRemoter.PageDetails PD_MANAGER = DashboardRemoter.retrieveFilterOptions('','null','null','','','');
            DashboardRemoter.retrievePlotPoints( PD_MANAGER.AreaManagerOptions[0],PD_MANAGER.SalesManagerOptions[0],PD_MANAGER.AgencyOptions[0],theSubAgent.Id,PD_MANAGER.SelectedYear,PD_MANAGER.SelectedMonth,PD_MANAGER.WeekOptionsId[0],'', 'Campaign');
            DashboardRemoter.retrieveTableRows( PD_MANAGER.AreaManagerOptions[0],PD_MANAGER.SalesManagerOptions[0],PD_MANAGER.AgencyOptions[0],theSubAgent.Id,PD_MANAGER.SelectedYear,PD_MANAGER.SelectedMonth,PD_MANAGER.WeekOptionsId[0],'', 'Campaign');
        }
        
        
        //some generic methods
        DashboardRemoter.isInLastWeek(DateTime.Now());
        DashboardRemoter.isInLastWeek(DateTime.Now().addDays(-10));
        DashboardRemoter.isInThisWeek(DateTime.Now());
        DashboardRemoter.isInThisWeek(DateTime.Now().addDays(-10));
    }    
    
    
}