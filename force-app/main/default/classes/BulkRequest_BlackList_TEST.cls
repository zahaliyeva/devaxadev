/*------------------------------------------------------------------------
   Author:        Davide fabris
   Company:       Deloitte
   Class:         BulkRequest_BlackList_TEST
   Description:   Test for the submission of bulk update from nodes

   History

   05/04/2017     Davide fabris - Created
   ----------------------------------------------------------------------------*/

@istest
public class BulkRequest_BlackList_TEST {

	@testSetup static void setup() {//preparing test database
		test.startTest();
		//Insert custom settings
		AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
		insert acv;
		Apex_Schedulation_Manager__c ASM_CS= new Apex_Schedulation_Manager__c(
			Name='BulkRequestManager',
			Autoschedule__c=true,
			Expression__c='',
			Frequency__c=1,
			Scope__c=200,
			Send_Log__c=true,
			From__c = String.valueOf(Datetime.now().hour() - 2),
			To__c = String.valueOf(Datetime.now().hour() - 1)
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



		//Creating agent
		UserProvisioningAAI.UserDetailsInput UserInputAgent = new UserProvisioningAAI.UserDetailsInput();
		UserInputAgent.Active='0';
		UserInputAgent.FirstName='Agent';
		UserInputAgent.LastName='Agent';
		UserInputAgent.Email='agent@agent.it';
		UserInputAgent.UserName='agent@test.test';
		UserInputAgent.MyriamUserName = 'ag_agent';
		UserInputAgent.AgencyCode = '009999';

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
		//system.debug('++++theanswer '+theanswer );


		//Creating SUB- agent
		UserProvisioningAAI.UserDetailsInput UserInputSUBAgent = new UserProvisioningAAI.UserDetailsInput();
		UserInputSUBAgent.Active='0';
		UserInputSUBAgent.FirstName='SUBAgent';
		UserInputSUBAgent.LastName='SUBAgent';
		UserInputSUBAgent.Email='SUBagent@agent.it';
		UserInputSUBAgent.UserName='SUBagent@test.test';
		UserInputSUBAgent.MyriamUserName = 'subag_subagent';
		UserInputSUBAgent.AgencyCode = '009999';

		UserProvisioningAAI.UserNodeInput theNodeSUB = new UserProvisioningAAI.UserNodeInput();
		theNodeSUB.NodeCode = '999900001';
		theNodeSUB.NodeLevel = 8;
		theNodeSUB.Profile = 'NFE - AAI - Vendite Avanzato';
		theNodeSUB.Functionality = 'User';
		theNodeSUB.AdminFlag = true;
		List<UserProvisioningAAI.UserNodeInput> thenodelistSUB = new List<UserProvisioningAAI.UserNodeInput>();
		thenodelistSUB.add(theNodeSUB);

		UserInputSUBAgent.Nodes = thenodelistSUB;

		//preparing the answer
		UserProvisioningAAI.ServiceResult theanswerSUB = new UserProvisioningAAI.ServiceResult();
		theanswerSUB = UserProvisioningAAI.UpsertUserAAI(UserInputSUBAgent);
		//system.debug('++++theanswer '+theanswerSUB );

		//Inserting some clients
		Account TheClient = new Account();
		TheClient.NDG__c='0099990000001138';
		RecordType PF_RT = [SELECT id from RecordType where DeveloperName ='B2C_Client' Limit 1];
		TheClient.RecordTypeId = PF_RT.Id;
		TheClient.LastName = 'Rossi';
		TheClient.FirstName = 'Maria';
		TheClient.CIF_Marital_Status__c = 'Coniugato/a';
		TheClient.CIF_Marital_Status_code__c = '1';
		TheClient.Nodes__c = '009999;009999000001';
		TheClient.AAI_Agency_Reference_Code__c ='009999';
		TheClient.State__c ='ATTIVO';
		TheClient.CIF_Job__c ='Agricoltore';
		TheClient.AAI_Codice_fiscale__c = 'MSSGNN64P24L929I';
		TheClient.State__c='ATTIVO';

		insert TheClient;


		BulkRequestManager TheB = new BulkRequestManager();
		Database.ExecuteBatch(TheB);

		test.stopTest();
	}

	static testmethod void SingleRequest_RESET(){
		//Insert a single request and schedule batch
		Bulk_Request__c thisBR = new Bulk_Request__c();
		thisBR.BulkRequestHandler__c = 'BulkRequest_BlackList';

		BulkRequest_BlackList BR_instance = new BulkRequest_BlackList();
		BR_instance.Auto=true;
		BR_instance.Abitazione=true;
		BR_instance.Infortuni=true;
		BR_instance.Malattia=true;
		BR_instance.Protection=true;
		BR_instance.Saving=true;
		BR_instance.Aziende=true;
		BR_instance.Rinnovo=true;
		BR_instance.Commerciale=true;
		BR_instance.Servizio=true;
		BR_instance.DataModifica = Datetime.Now();
		BR_instance.DateRequest = DateTime.Now();
		BR_instance.Origin='NODI_RESET';//In this way the BulkHandler update all flags

		thisBR.JsonInstance__c = JSON.serialize(BR_instance);
		thisBr.Node__c=[SELECT Id from Node__c WHERE Node_unique_code__c='009999' Limit 1].Id;
		thisBr.Query__c = 'SELECT Id,BlackList_Auto__c,'
						  +'            BlackList_Abitazione__c,'
						  +'            BlackList_Infortuni__c,'
						  +'            BlackList_Malattia__c,'
						  +'            BlackList_Protection__c,'
						  +'            BlackList_Saving__c,'
						  +'            BlackList_Aziende__c,'
						  +'            BlackList_Rinnovo__c,'
						  +'            BlackList_Commerciale__c,'
						  +'            BlackList_Servizio__c,'
						  +'            Ultima_modifica_blacklist__c ';

		thisBr.Query__c = thisBr.Query__c + 'FROM Account where AAI_Agency_Reference_Code__c=\''+'009999'+'\' AND Nodes__c LIKE \'%'+'009999000001'+'%\'';//looking for the specific subnode in the middle of the string
		thisBR.Request_by__c = Userinfo.getUserId();
		thisBR.Status__c='SUBMITTED';
		thisBR.Submission_date__c = DateTime.Now();

		insert thisBR;
		List<Bulk_Request__c> theList= [SELECT id FROM Bulk_Request__c WHERE Status__c='SUBMITTED'];
		List<Account> theAccounts = Database.Query(thisBr.Query__c);
		system.debug('found these requests'+theList);
		system.debug('found these accounts'+theAccounts);

		Test.StartTest();
		BulkRequestManager TheB = new BulkRequestManager();
		String sch = ApexSchedulationManager.getScheduleString('1');
		System.Schedule('BulkRequestManager', sch, TheB);
		Test.StopTest();
	}

	static testmethod void SingleRequest_NORMAL(){
		//Insert a single request and schedule batch
		Bulk_Request__c thisBR = new Bulk_Request__c();
		thisBR.BulkRequestHandler__c = 'BulkRequest_BlackList';

		BulkRequest_BlackList BR_instance = new BulkRequest_BlackList();
		BR_instance.Auto=true;
		BR_instance.Abitazione=true;
		BR_instance.Infortuni=true;
		BR_instance.Malattia=true;
		BR_instance.Protection=true;
		BR_instance.Saving=true;
		BR_instance.Aziende=true;
		BR_instance.Rinnovo=true;
		BR_instance.Commerciale=true;
		BR_instance.Servizio=true;
		BR_instance.DataModifica = Datetime.Now();
		BR_instance.DateRequest = DateTime.Now();

		thisBR.JsonInstance__c = JSON.serialize(BR_instance);
		thisBr.Node__c=[SELECT Id from Node__c WHERE Node_unique_code__c='009999' Limit 1].Id;
		thisBr.Query__c = 'SELECT Id,BlackList_Auto__c,'
						  +'            BlackList_Abitazione__c,'
						  +'            BlackList_Infortuni__c,'
						  +'            BlackList_Malattia__c,'
						  +'            BlackList_Protection__c,'
						  +'            BlackList_Saving__c,'
						  +'            BlackList_Aziende__c,'
						  +'            BlackList_Rinnovo__c,'
						  +'            BlackList_Commerciale__c,'
						  +'            BlackList_Servizio__c,'
						  +'            Ultima_modifica_blacklist__c ';

		thisBr.Query__c = thisBr.Query__c + 'FROM Account where AAI_Agency_Reference_Code__c=\''+'009999'+'\' AND Nodes__c LIKE \'%'+'009999000001'+'%\'';//looking for the specific subnode in the middle of the string
		thisBR.Request_by__c = Userinfo.getUserId();
		thisBR.Status__c='SUBMITTED';
		thisBR.Submission_date__c = DateTime.Now();

		insert thisBR;
		List<Bulk_Request__c> theList= [SELECT id FROM Bulk_Request__c WHERE Status__c='SUBMITTED'];
		List<Account> theAccounts = Database.Query(thisBr.Query__c);
		system.debug('found these requests'+theList);
		system.debug('found these accounts'+theAccounts);

		Test.StartTest();
		BulkRequestManager TheB = new BulkRequestManager();
		String sch = ApexSchedulationManager.getScheduleString('1');
		System.Schedule('BulkRequestManager', sch, TheB);
		Test.StopTest();
	}


	@isTest
	public static void testErrorStart(){
		Test.startTest();
		Bulk_Request__c thisBR = new Bulk_Request__c();
		thisBR.BulkRequestHandler__c = 'BulkRequest_BlackList';
		BulkRequest_BlackList BR_instance = new BulkRequest_BlackList();
		BR_instance.Auto=true;
		BR_instance.Abitazione=true;
		BR_instance.Infortuni=true;
		BR_instance.Malattia=true;
		BR_instance.Protection=true;
		BR_instance.Saving=true;
		BR_instance.Aziende=true;
		BR_instance.Rinnovo=true;
		BR_instance.Commerciale=true;
		BR_instance.Servizio=true;
		BR_instance.DataModifica = Datetime.Now();
		BR_instance.DateRequest = DateTime.Now();
		BR_instance.Origin='NODI_RESET';//In this way the BulkHandler update all flags

		thisBR.JsonInstance__c = JSON.serialize(BR_instance);
		thisBr.Node__c=[SELECT Id from Node__c WHERE Node_unique_code__c='009999' Limit 1].Id;
		thisBr.Query__c = 'SELECT  WORD TO THROW AN EXCEPTION Id,BlackList_Auto__c,'
						  +'            BlackList_Abitazione__c,'
						  +'            BlackList_Infortuni__c,'
						  +'            BlackList_Malattia__c,'
						  +'            BlackList_Protection__c,'
						  +'            BlackList_Saving__c,'
						  +'            BlackList_Aziende__c,'
						  +'            BlackList_Rinnovo__c,'
						  +'            BlackList_Commerciale__c,'
						  +'            BlackList_Servizio__c,'
						  +'            Ultima_modifica_blacklist__c ';

		thisBr.Query__c = thisBr.Query__c + 'FROM Account where AAI_Agency_Reference_Code__c=\''+'009999'+'\' AND Nodes__c LIKE \'%'+'009999000001'+'%\'';//looking for the specific subnode in the middle of the string
		thisBR.Request_by__c = Userinfo.getUserId();
		thisBR.Status__c='SUBMITTED';
		thisBR.Submission_date__c = DateTime.Now();

		insert thisBR;
		BulkRequestManager batch = new BulkRequestManager();
		String scheduler = ApexSchedulationManager.getScheduleString('1');
		System.Schedule('BulkRequestManager', scheduler, batch);
		Test.stopTest();
    }
    
    @isTest
	public static void testErrorExecute(){
        Test.startTest();
        Apex_Schedulation_Manager__c ASM_CS= [SELECT ID from Apex_Schedulation_Manager__c LIMIT  1];
        ASM_CS.To__c = String.valueOf(Datetime.now().hour() + 3);
        update ASM_CS;
		Bulk_Request__c thisBR = new Bulk_Request__c();
		thisBR.BulkRequestHandler__c = 'BulkRequest_BlackList';
        thisBR.JsonInstance__c = JSON.serialize(new BulkRequest_BlackList_TEST());
        thisBR.JsonInstance__c = null;
		thisBr.Node__c=[SELECT Id from Node__c WHERE Node_unique_code__c='009999' Limit 1].Id;
		thisBr.Query__c = 'SELECT Id,BlackList_Auto__c,'
						  +'            BlackList_Abitazione__c,'
						  +'            BlackList_Infortuni__c,'
						  +'            BlackList_Malattia__c,'
						  +'            BlackList_Protection__c,'
						  +'            BlackList_Saving__c,'
						  +'            BlackList_Aziende__c,'
						  +'            BlackList_Rinnovo__c,'
						  +'            BlackList_Commerciale__c,'
						  +'            BlackList_Servizio__c,'
						  +'            Ultima_modifica_blacklist__c ';

		thisBr.Query__c = thisBr.Query__c + 'FROM Account where AAI_Agency_Reference_Code__c=\''+'009999'+'\' AND Nodes__c LIKE \'%'+'009999000001'+'%\'';//looking for the specific subnode in the middle of the string
		thisBR.Request_by__c = Userinfo.getUserId();
		thisBR.Status__c='SUBMITTED';
		thisBR.Submission_date__c = DateTime.Now();

		insert thisBR;
		BulkRequestManager batch = new BulkRequestManager();
		String scheduler = ApexSchedulationManager.getScheduleString('1');
		System.Schedule('BulkRequestManager', scheduler, batch);
		Test.stopTest();
	}

}