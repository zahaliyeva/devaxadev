/*------------------------------------------------------------------------
Author:        Davide Fabris
Company:       Deloitte
Class:         TheBatchRecalculateVisibility_TEST
Description:   Test for the batch that recalculates the visibility based on TECH_Batch_Visibility__c
History

04/07/2015     Davide Fabris - Created
----------------------------------------------------------------------------*/
/**
 * @description PURE IT 22/05 - commentata la classe
 */

@istest
public class TheBatchRecalculateVisibility_TEST {
    /** PURE IT

    @testSetup static void setup() {//preparing test database
        // test.startTest();

        //Insert custom settings
        AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name = 'AXA_TECHNICAL_USER_ID', Value__c = UserInfo.getUserId());
        insert acv;

        // Insert Client 
        Account Theclient = new Account();
        TheClient.TECH_Company__c = 'AAI';
        TheClient.NDG__c = '1111111111';
        TheClient.Nodes__c = '004123';
        TheClient.AAI_Agency_Reference_Code__c = '004123';
        RecordType PF_RT = [SELECT id from RecordType where DeveloperName = 'B2C_Client' Limit 1];
        TheClient.RecordTypeId = PF_RT.Id;
        TheClient.LastName = 'Rossi';
        TheClient.TECH_Batch_Visibility__c = true;
        TheClient.FirstName = 'Mario';

        Account Theclient2 = new Account();
        Theclient2.TECH_Company__c = 'AAI';
        Theclient2.NDG__c = '2222222222';
        Theclient2.Nodes__c = '004123';
        Theclient2.AAI_Agency_Reference_Code__c = '004123';
        Theclient2.RecordTypeId = PF_RT.Id;
        Theclient2.LastName = 'Verdi';
        Theclient2.TECH_Batch_Visibility__c = true;
        Theclient2.FirstName = 'Luca';


        //Some nodes for visibility
        List<Node__c> theNodes = new List<Node__c>();
        Node__c AgencyNode = new Node__c();
        AgencyNode.Node_level__c = 7;
        AgencyNode.Node_unique_code__c = '004123';
        AgencyNode.Parent_node_unique_code__c = 'A001';
        AgencyNode.Tree_name__c = 'DIF';

        Node__c SubAgencyNode = new Node__c();
        SubAgencyNode.Node_level__c = 8;
        SubAgencyNode.Node_unique_code__c = '004123000001';
        SubAgencyNode.Parent_node_unique_code__c = '004123';
        SubAgencyNode.Tree_name__c = 'DIF';

        Node__c SubAgencyNode2 = new Node__c();
        SubAgencyNode2.Node_level__c = 8;
        SubAgencyNode2.Node_unique_code__c = '004123000002';
        SubAgencyNode2.Parent_node_unique_code__c = '004123';
        SubAgencyNode2.Tree_name__c = 'DIF';


        List<Sobject> SoList = new List<Sobject>();
        Solist.add(TheClient);
        Solist.add(TheClient2);
        Solist.add(AgencyNode);
        Solist.add(SubAgencyNode);
        Solist.add(SubAgencyNode2);
        Insert Solist;


        UserProvisioningAAI.UserDetailsInput UserInputAgent = new UserProvisioningAAI.UserDetailsInput();
        UserInputAgent.Active = '0';
        UserInputAgent.FirstName = 'Agent';
        UserInputAgent.LastName = 'Agent';
        UserInputAgent.Email = 'agent@agent.it';
        UserInputAgent.UserName = 'agentfake@testfake.test';
        UserInputAgent.MyriamUserName = 'ag_agent';
        UserInputAgent.AgencyCode = '004123';
       //UserInputAgent.Phone = '3330000000';

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
        system.debug('++++theanswer ' + theanswer);
        system.debug('++++theanswer1 ' + UserInputAgent);

        //Inserting child records
        // List<Sobject> SoList_CHILD = new List<Sobject>();
        //InsertOpportunity
        Opportunity Opp1 = new Opportunity();
        Opp1.Name = 'test';
        //CAPOBIANCO_A 05/01/2018 -- START
        //RecordType OPP_RE = [SELECT id from RecordType where DeveloperName ='No_Auto' AND SobjectType='Opportunity' Limit 1];
        //Opp1.RecordTypeId=OPP_RE.Id;
        RecordType OPP_AAI = [SELECT id from RecordType where DeveloperName = 'Opportunita_AXA_Assicurazioni' AND SobjectType = 'Opportunity' Limit 1];
        Opp1.RecordTypeId = OPP_AAI.Id;
        //CAPOBIANCO_A 05/01/2018 -- END
        Opp1.StageName = 'Open';
        Opp1.CloseDate = Date.Today().addDays(90);
        Opp1.AccountId = TheClient.Id;

        insert Opp1;

    }


    static testmethod void TEST_TheBatchRecalculateVisibilityt() {
        Apex_Schedulation_Manager__c ASM_CS = new Apex_Schedulation_Manager__c(
                Name = 'TheBatchRecalculateVisibility',
                Autoschedule__c = true,
                Expression__c = '',
                Frequency__c = 5,
                Scope__c = 20,
                Send_Log__c = true
        );
        insert ASM_CS;

        test.startTest();
        TheBatchRecalculateVisibility TheB = new TheBatchRecalculateVisibility();
        String sch = ApexSchedulationManager.getScheduleString('1');
        System.Schedule('TEST__TheBatchRecalculateVisibility', sch, TheB);
        test.stopTest();
    }

    //static testmethod void TEST_setMorningScheduleTime(){
    //    Datetime testTime = Datetime.now();
    //    Datetime testTime2 = Datetime.newInstance(testTime.year(), testTime.month(), testTime.day(), 22, testTime.minute(), testTime.second());
    //    TheBatchRecalculateVisibility TheB = new TheBatchRecalculateVisibility();

    //    test.startTest();
    //    TheB.setMorningScheduleTime(testTime, '');
    //    TheB.setMorningScheduleTime(testTime2, '');
    //    test.stopTest();
    //}
    PURE IT */
}