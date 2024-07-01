@istest
public class BulkRequest_BlackList_Broker_TEST {
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
        Send_Log__c=true
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
        AgencyNode.Intermediary_type__c = 'BROKER RATIFICATO';
        AgencyNode.Tree_name__c='DIF';
        
        Node__c SUBAgencyNode = new Node__c();
        SUBAgencyNode.Node_level__c=8;
        SUBAgencyNode.Node_unique_code__c='009999000001';
        SUBAgencyNode.Parent_node_unique_code__c='009999';
        SUBAgencyNode.Intermediary_type__c = 'BROKER RATIFICATO';
        SUBAgencyNode.Tree_name__c='DIF';
        
        
        List<Sobject> SoList = new List<Sobject>();
        SoList.add(AgencyNode);
        SoList.add(SUBAgencyNode);
        SoList.add(ManagerNode);

        Insert Solist;
        
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
    
    static testmethod void SingleRequest_TRUE(){ 
        //Insert a single request and schedule batch
        Bulk_Request__c thisBR = new Bulk_Request__c();
        thisBR.BulkRequestHandler__c = 'BulkRequest_BlackList_Broker';
        
        BulkRequest_BlackList_Broker BR_instance = new BulkRequest_BlackList_Broker();
        BR_instance.broker=true;

        thisBR.JsonInstance__c = JSON.serialize(BR_instance);
        thisBr.Node__c=[SELECT Id from Node__c WHERE Node_unique_code__c='009999' Limit 1].Id;
        thisBr.Query__c = 'SELECT Id, BlackList_Broker__c, Nodes__c ';
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
    
    static testmethod void SingleRequest_FALSE(){ 
        //Insert a single request and schedule batch
        Bulk_Request__c thisBR = new Bulk_Request__c();
        thisBR.BulkRequestHandler__c = 'BulkRequest_BlackList_Broker';
        
        BulkRequest_BlackList_Broker BR_instance = new BulkRequest_BlackList_Broker();
        BR_instance.broker=false;

        thisBR.JsonInstance__c = JSON.serialize(BR_instance);
        thisBr.Node__c=[SELECT Id from Node__c WHERE Node_unique_code__c='009999' Limit 1].Id;
        thisBr.Query__c = 'SELECT Id, BlackList_Broker__c, Nodes__c ';
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
}