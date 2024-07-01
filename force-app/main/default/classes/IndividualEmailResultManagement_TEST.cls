/**
 * Created by Augens on 26/11/2018.
 */

@IsTest
private class IndividualEmailResultManagement_TEST {

    public static Node__c prepareNode(string Name, string Parent, integer level) {
        Node__c testNode = new Node__c();
        testNode.Node_description__c = 'testdescription' + Name;
        testNode.Node_level__c = level;
        testNode.Node_unique_code__c = Name;
        testNode.Parent_node_unique_code__c = Parent;
        testNode.Tree_name__c = 'TEST_TREE';
        testNode.Management_type__c = 'TGest';
        testNode.Intermediary_type__c = 'TIntermediario';
        return testNode;
    }

    @TestSetup
    static void setup() {
        Account acc = new Account(Name = 'MyAccount', AAI_Agency_Reference_Code__c = '000828');
        insert acc;
        Contact c = new Contact(LastName = 'TestContact', AccountId = acc.Id);
        insert c;

        List<Lead> leadList = new List<Lead>();
        Lead l1 = new Lead(LastName = 'Test1', Agency_Code__c = '006345');
        Lead l2 = new Lead(LastName = 'Test2', Agency_Code__c = '00634500002');
        Lead l3 = new Lead(LastName = 'Test3', Agency_Code__c = '00634500003');
        Lead l4 = new Lead(LastName = 'Test4');
        Lead l5 = new Lead(LastName = 'Test5');
        leadList.add(l1);
        leadList.add(l2);
        leadList.add(l3);
        leadList.add(l4);
        leadList.add(l5);
        insert leadList;

        et4ae5__Automated_Send__c auto1 = new et4ae5__Automated_Send__c(et4ae5__FromEmail__c = 'test@test.za');
        insert auto1;

        List<et4ae5__IndividualEmailResult__c> individualEmails = new List<et4ae5__IndividualEmailResult__c>();
        et4ae5__IndividualEmailResult__c email1 = new et4ae5__IndividualEmailResult__c(et4ae5__Lead__c = l1.Id, Name = 'EmailTest1',
                et4ae5__TriggeredSendDefinition__c = auto1.Id);
        et4ae5__IndividualEmailResult__c email2 = new et4ae5__IndividualEmailResult__c(et4ae5__Lead__c = l2.Id, Name = 'EmailTest2',
                et4ae5__TriggeredSendDefinition__c = auto1.Id);
        et4ae5__IndividualEmailResult__c email3 = new et4ae5__IndividualEmailResult__c(et4ae5__Lead__c = l3.Id, Name = 'EmailTest3',
                et4ae5__TriggeredSendDefinition__c = auto1.Id);
        et4ae5__IndividualEmailResult__c email4 = new et4ae5__IndividualEmailResult__c(
                Name = 'individualEmailTest1',
                Account__c = acc.Id,
                et4ae5__Contact__c = c.Id,
                et4ae5__HardBounce__c = true,
                et4ae5__TriggeredSendDefinition__c = auto1.Id);
        et4ae5__IndividualEmailResult__c email5 = new et4ae5__IndividualEmailResult__c(
                Name = 'individualEmailTest2',
                Account__c = acc.Id,
                et4ae5__Contact__c = c.Id,
                et4ae5__HardBounce__c = false,
                et4ae5__TriggeredSendDefinition__c = auto1.Id);
        individualEmails.add(email1);
        individualEmails.add(email2);
        individualEmails.add(email3);
        individualEmails.add(email4);
        individualEmails.add(email5);
        insert individualEmails;

        AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name = 'AXA_TECHNICAL_USER_ID', Value__c = UserInfo.getUserId());
        insert acv;

        //Prepare Nodes and Groups

        Node__c testNode1 = new Node__c();
        Node__c testNode2 = new Node__c();
        Node__c testNode3 = new Node__c();

        testNode1 = prepareNode('006345', 'z023', 7);
        testNode2 = prepareNode('00634500002', '006345', 8);
        testNode3 = prepareNode('00634500003', '00634500002', 9);

        List<Node__c> testNodeList = new List<Node__c>();
        testNodeList.add(testNode1);
        testNodeList.add(testNode2);
        testNodeList.add(testNode3);

        System.runAs(new user(id = UserInfo.GetuserId())) {

            List<Group> myGroups = new List<Group>();

            Group group1 = new Group(
                    Name = 'DIF_' + '006345',
                    DeveloperName = 'DIF_' + '006345'
            );

            myGroups.add(group1);

            Group group2 = new Group(
                    Name = 'DIF_' + '00634500002',
                    DeveloperName = 'DIF_' + '00634500002'
            );

            myGroups.add(group2);

            Group group3 = new Group(
                    Name = 'DIF_' + '00634500003',
                    DeveloperName = 'DIF_' + '00634500003'
            );

            myGroups.add(group3);

            insert(myGroups);

            insert testNodeList;

            NodeManagementAgency testNMA = new NodeManagementAgency();
            NodeManagement testNM = new NodeManagement();
            List<user> u = new List<user>();
            u = [SELECT id from User where Name LIKE '%D%' AND isActive = true];
            testNM.MapNodesToGroups(testNodeList);
            testNMA.UpsertAgencyAccounts(testNodeList);

        }
    }

    @IsTest
    static void CommunicationBounceEventsTest() {
        Account acc = [SELECT Id FROM Account WHERE Name = 'MyAccount'];
        Contact c = [SELECT Id FROM Contact WHERE LastName = 'TestContact'];
        et4ae5__Automated_Send__c auto1 = [SELECT Id FROM et4ae5__Automated_Send__c WHERE et4ae5__FromEmail__c = 'test@test.za'];

        List<et4ae5__IndividualEmailResult__c> emailResultList = [
                SELECT Id,Name,Account__c,Account_NDG__c,et4ae5__Contact__r.AccountId,et4ae5__HardBounce__c,et4ae5__TriggeredSendDefinition__c,et4ae5__DateBounced__c
                FROM et4ae5__IndividualEmailResult__c
                WHERE Name IN ('individualEmailTest1', 'individualEmailTest2')
        ];

        Test.startTest();
        IndividualEmailResultManagement.createCommunicationBounceEvents(emailResultList);
        Test.stopTest();
    }

    @IsTest
    static void ShareWithFullAgencyTest() {
        Lead l1 = [SELECT Id FROM Lead WHERE LastName = 'Test1' AND Agency_Code__c = '006345'];
        Lead l2 = [SELECT Id FROM Lead WHERE LastName = 'Test2' AND Agency_Code__c = '00634500002'];
        Lead l3 = [SELECT Id FROM Lead WHERE LastName = 'Test3' AND Agency_Code__c = '00634500003'];
        List<Id> leadListId = new List<Id>();
        leadListId.add(l1.Id);
        leadListId.add(l2.Id);
        leadListId.add(l3.Id);

        List<et4ae5__IndividualEmailResult__c> individualEmails = [SELECT Id,Lead_Agency_Code__c FROM et4ae5__IndividualEmailResult__c WHERE et4ae5__Lead__c IN :leadListId];

        Test.startTest();
        IndividualEmailResultManagement.ShareWithFullAgency(individualEmails);
        Test.stopTest();
    }

    @IsTest
    static void ShareWithFullAgencyFutureTest() {
        List<et4ae5__IndividualEmailResult__c> individualEmails = [SELECT Id,Lead_Agency_Code__c FROM et4ae5__IndividualEmailResult__c];
        Set<Id> setIds = new Set<Id>();
        setIds.add(individualEmails[0].Id);
        Test.startTest();
        IndividualEmailResultManagement.ShareWithFullAgency(setIds);
        Test.stopTest();
    }

    @IsTest
    static void setAgencyCodeTest() {
        List<Lead> leadList = new List<Lead>();
        leadList = [SELECT Id FROM Lead WHERE LastName IN ('Test4', 'Test5')];

        Test.startTest();
        IndividualEmailResultManagement.setAgencyCode(leadList);
        Test.stopTest();
    }

    @IsTest
    static void massiveCommunicationTest() {

        Account acc1 = new Account(Name = 'Test Account 1', AAI_Agency_Reference_Code__c = '000828', NDG__c = '0034453657349574');
        Account acc2 = new Account(Name = 'Test Account 2', AAI_Agency_Reference_Code__c = '000828', NDG__c = '0034453657349888');
        insert new List<Account> {acc1, acc2};

        Contact cont1 = new Contact(LastName = 'Test Contact 1', AccountId = acc1.Id);
        Contact cont2 = new Contact(LastName = 'Test Contact 2', AccountId = acc2.Id);
        insert new List<Contact> {cont1, cont2};


        IE_Configuration__c iec1 = new IE_Configuration__c(Name = 'Customer_Email_Unsubscribing');
        IE_Configuration__c iec2 = new IE_Configuration__c(Name = 'Customer_Communication_Bounce');

        insert new List<IE_Configuration__c> {iec1, iec2};

        et4ae5__Automated_Send__c auto1 = new et4ae5__Automated_Send__c(et4ae5__FromEmail__c = 'test@test.za');
        insert auto1;

        Test.startTest();
        et4ae5__IndividualEmailResult__c individualEmailResult1 = new et4ae5__IndividualEmailResult__c(
                Name = 'One',
                Account__c = acc1.Id,
                et4ae5__Contact__c = cont1.Id,
                et4ae5__HardBounce__c = true,
                et4ae5__TriggeredSendDefinition__c = auto1.Id,
                et4ae5__DateUnsubscribed__c = System.now()
        );

        et4ae5__IndividualEmailResult__c individualEmailResult2 = new et4ae5__IndividualEmailResult__c(
                Name = 'ComMassive_Two',
                Account__c = acc2.Id,
                et4ae5__Contact__c = cont2.Id,
                et4ae5__HardBounce__c = true,
                et4ae5__TriggeredSendDefinition__c = auto1.Id,
                et4ae5__DateUnsubscribed__c = System.now()
        );

        insert new List<et4ae5__IndividualEmailResult__c>{
                individualEmailResult1, individualEmailResult2
        };

        Test.stopTest();

        List<Customer_Event__c> events = [SELECT Id, Account__c FROM Customer_Event__c];
        System.assertEquals(2, events.size());

        for(Customer_Event__c ce : events) {
            System.assertEquals(acc1.Id, ce.Account__c);
        }

    }
}