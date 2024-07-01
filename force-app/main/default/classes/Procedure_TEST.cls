/*------------------------------------------------------------------------
Author:        Davide Fabris
Company:       Deloitte
Class:         Procedure_TEST
Description:   Test for the procedure management classes and batches
History
09/09/2016     Davide Fabris - Created
----------------------------------------------------------------------------*/


@istest
public class Procedure_TEST{

    @testSetup static void setup() {//preparing test database
        test.startTest();
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
        S1.Query_To_Run__c = 'SELECT Contact.Account.RSAC_Description_Code__c,Contact.Account.Department_Chief_Description_Code__c, Contact.Account.RSA_Description_Code__c, Agency_Code__c, CommunityNickname, Email, FirstName, Id, IsActive, IsPortalEnabled, LastName, Main_Node__c, Name, Nodes__c, Nodes_tree__c, PortalRole, ProfileId, Username, UserRoleId, UserType,Profile.Name,UserRole.DeveloperName FROM User WHERE isActive= true AND IsPortalEnabled = true ORDER BY Agency_Code__c LIMIT 10';
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
        
        Procedure_Step__c S3 = new Procedure_Step__c();
        S3.is_Active__c = true;
        S3.isNext__c = false;
        S3.Order__c = '3';
        S3.Procedure_Definition__c=PD.Id;
        S3.Query_To_Run__c = 'Select Id,Status,OwnerId, LastModifiedDate,LastModifiedDateOfInterest__c,LastmodifiedById,isconverted FROM Lead WHERE owner.isactive=true and Owner.Profile.Name in (\'NFE - AAI - Vendite Avanzato\',\'NFE - AAI - Vendite Base\') and (LastModifiedDateOfInterest__c=THIS_WEEK or Status IN (\'To be contacted\',\'Call again\', \'Da contattare\', \'Da ricontattare\') ) order by OwnerId';
        S3.Scope__c = 200;
        S3.Step_Handler_Class__c = 'PSH_LeadHandler';
        
        Procedure_Step__c S4 = new Procedure_Step__c();
        S4.is_Active__c = true;
        S4.isNext__c = false;
        S4.Order__c = '4';
        S4.Procedure_Definition__c=PD.Id;
        S4.Query_To_Run__c = 'select id, ownerid, owner.name, LeadSource, StageName, CampaignId, lastmodifieddateOfInterest__c, CreatedDate, isWon,isClosed from opportunity where Owner.isactive=true and Owner.Profile.Name in (\'NFE - AAI - Vendite Avanzato\',\'NFE - AAI - Vendite Base\') and (lastmodifieddateOfInterest__c = THIS_WEEK or isClosed=false) order by ownerid';
        S4.Scope__c = 200;
        S4.Step_Handler_Class__c = 'PSH_OpportunityHandler';
        
        
        List<Procedure_Step__c> theSteps = new List<Procedure_Step__c>{S1,S2,S3,S4};
        insert theSteps;
        
        
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
            IsDefault__c = false         
            ),
            new CampaignMembStatus__c(
            Name = 'Call again',
            Status_Name__c = 'Da ricontattare',
            SortOrder__c = 5,
            IsDefault__c = false         
            ),
            new CampaignMembStatus__c(
            Name = 'Not interested',
            Status_Name__c = 'Non interessato',
            SortOrder__c = 6,
            IsDefault__c = false         
            )
        };
        insert cms;
        
        
        
        
        // Insert Client 
        Account Theclient = new Account();
        TheClient.TECH_Company__c = 'AAI';
        TheClient.NDG__c='1111111111';
        TheClient.Nodes__c='004123';
        RecordType PF_RT = [SELECT id from RecordType where DeveloperName ='B2C_Client' Limit 1];
        TheClient.RecordTypeId = PF_RT.Id;
        TheClient.LastName = 'Rossi';
        TheClient.FirstName = 'Mario';
        
        Account Theclient2 = new Account();
        Theclient2.TECH_Company__c = 'AAI';
        Theclient2.NDG__c='2222222222';
        Theclient2.Nodes__c='004123';
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
        
        
        List<Sobject> SoList = new List<Sobject>();
        SoList.add(AgencyNode);
        Insert Solist;
        
        
        //Creating agent
        UserProvisioningAAI.UserDetailsInput UserInputAgent = new UserProvisioningAAI.UserDetailsInput();
        UserInputAgent.Active='0';
        UserInputAgent.FirstName='Agent';
        UserInputAgent.LastName='Agent';
        UserInputAgent.Email='agent@agent.it';
        UserInputAgent.UserName='agentfake@testfake.test';
        UserInputAgent.MyriamUserName = 'ag_agent';
        UserInputAgent.AgencyCode = '004123';
        //UserInputAgent.Phone = '3660000000';

        
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
//        system.debug('++++theanswer '+theanswer );
        
        
        //Insert the clients so that they are shared
        insert TheClient;
        insert Theclient2;
        
        test.stopTest();
    }
    
    static testmethod void TEST_TheBatchProcedure(){
       //Do the data preparation as the agent
        User theAgentU = [SELECT id from User where UserName='agentfake@testfake.test' Limit 1];
        //Create a campaign
        RecordType cpRT = [SELECT Id FROM RecordType WHERE SobjectType = 'Campaign' AND DeveloperName = 'Agency_campaign'];
        Campaign cp = new Campaign(
        Name = 'CampagnaTest',
        IsActive = true,
        Status = 'On-going',
        RecordTypeID = cpRT.Id,
        OwnerId=theAgentU.Id
        );
        System.runAs(theAgentU) {
            //Creating campaign
            insert cp;
            
            //Add campaignMembers
            List<account> allacc = [SELECT Id,PersonContactId,IsPersonAccount,RecordTypeId, RecordType.DeveloperName FROM Account WHERE IsPersonAccount=true];
            system.debug('+++++####'+allacc.size());
            account acc=allacc.get(0);
            account acc2=allacc.get(1);
            system.debug('++1'+acc);
            system.debug('++2'+acc2);
            
            List<CampaignMember> campaignMembers = new List<CampaignMember>{
                new CampaignMember(
                ContactId = acc.PersonContactId,
                CampaignId = cp.Id,
                Owner__c = theAgentU.id,
                Status = 'Interested',
                Note__c = 'NoteTest',
                LastModifieddateOfInterest__c = datetime.now()                
                ),
                new CampaignMember(
                ContactId = acc2.PersonContactId,
                CampaignId = cp.Id,
                Owner__c = theAgentU.id,
                Status = 'Interested',
                Note__c = 'NoteTest2',
                LastModifieddateOfInterest__c = datetime.now()
                )
            };
            insert campaignMembers;
            
            //Creating some leads
            Lead myLead = new Lead();
            myLead.FirstName = 'Luca';
            myLead.LastName = 'Verdi';
            myLead.TECH_Company__c = 'AAI';
            myLead.email = 'test@test.test';
            myLead.Status = 'Interested';
            
            // insert myLead;
            
            Opportunity myOpp = new Opportunity();
            myOpp.Name='asas';
            myOpp.StageName='Open';
            myOpp.CloseDate=Date.today();
            
            Opportunity myOppWon = new Opportunity();
            myOppWon.Name='dsdsd';
            myOppWon.StageName='Closed Won';
            myOppWon.CloseDate=Date.today();
            
            Opportunity myOppWonLead = new Opportunity();
            myOppWonLead.Name='dsdsd';
            myOppWonLead.StageName='Closed Won';
            myOppWonLead.CloseDate=Date.today();
            myOppWonLead.LeadSource='TEst source';
            
            Opportunity myOppWonCampaign = new Opportunity();
            myOppWonCampaign.Name='dsdsd';
            myOppWonCampaign.StageName='Closed Won';
            myOppWonCampaign.CloseDate=Date.today();
            myOppWonCampaign.CampaignId=cp.Id;
            // insert myOpp;
            
            insert new List<Sobject> {myLead,myOpp,myOppWon,myOppWonLead,myOppWonCampaign};
            
            
            Test.setCreatedDate(myOppWonLead.Id, DateTime.newInstance(2015,12,12));
            Test.setCreatedDate(myOppWonCampaign.Id, DateTime.newInstance(2015,12,12));

            
            
   
        }
        
        // List<CampaignMember> campaignMembers = [SELECT id, Owner__c,Owner__r.isActive, Status, LastModifieddateOfInterest__c, LastModifiedById, LastmodifiedDate, CampaignId,Agency_Code__c, Campaign_member_related_opportunity__c, Campaign_member_related_opportunity__r.StageName, Campaign_member_related_opportunity__r.LastModifieddateOfInterest__c, Campaign_member_related_opportunity__r.isWon FROM CampaignMember ];
        // system.debug(' @#@#@##@#@ '+campaignMembers.size());
        // for (CampaignMember c : campaignMembers) {
            // system.debug('@#@#@##@#@ nut null '+c.Owner__c);
            // system.debug('@#@#@##@#@ owner active '+c.Owner__r.isActive);
            // system.debug('@#@#@##@#@ date modified of interest'+c.LastModifieddateOfInterest__c);
            // system.debug('@#@#@##@#@ status should be in english '+c.Status);
        // }
        
        
        
        //Checking that i get something on the batches
        for(Procedure_Step__c step : [select id, Query_To_Run__c FROM Procedure_Step__c]) {
            system.debug(' @#@#@##@#@ Query_To_Run__c=='+step.Query_To_Run__c);
            list<Sobject> theRecs = Database.query(step.Query_To_Run__c);
            system.debug(' @#@#@##@#@ found these many '+ theRecs.size());
        }

        Apex_Schedulation_Manager__c ASM_CS= new Apex_Schedulation_Manager__c(
        Name='TheBatchProcedure',
        Autoschedule__c=true,
        Expression__c='',
        Frequency__c=5,
        Scope__c=200,
        Send_Log__c=false
        );
        insert ASM_CS;
        test.startTest();
        TheBatchProcedure TheB = new TheBatchProcedure();
        String sch = ApexSchedulationManager.getScheduleString('1');
        System.Schedule('TheBatchProcedure_TEST', sch, TheB);
        test.stopTest();
    }    
    
    
}