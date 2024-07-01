/*------------------------------------------------------------------------
Author:        Davide Fabris
Company:       Deloitte
Class:         NodeManagement 
Description:   A test class created to validate the NodeManagement class
               Tests executed:
               1 - 
History

 23/07/2015     Davide Fabris    
----------------------------------------------------------------------------*/


@isTest
private class NodeManagement_TEST {

    public static Node__c prepareNode(string Name, string Parent, integer level){
        Node__c testNode= new Node__c();    
        testNode.Node_description__c='testdescription'+Name;
        testNode.Node_level__c=level;
        testNode.Node_unique_code__c=Name;
        testNode.Parent_node_unique_code__c='Parent';
        testNode.Tree_name__c='TEST_TREE';
        testNode.Management_type__c='TGest';
        testNode.Intermediary_type__c='TIntermediario';
        return testNode;
    }

     public static testmethod void MapNodeListNoInsert(){
         Node__c testNode1= new Node__c();
         Node__c testNode2= new Node__c();   
         Node__c testNode3= new Node__c();   
   
         testNode1=prepareNode('child1','parent',5);
         testNode2=prepareNode('child2','parent',5);
         testNode3=prepareNode('child3','parent',5);

         List<Node__c> testNodeList = new List<Node__c>();
         testNodeList.add(testNode1);
         testNodeList.add(testNode2);
         testNodeList.add(testNode3); 
         testNodeList.add(testNode3);    
   

         NodeManagement testNM = new NodeManagement();
         Test.startTest();
         testNM.MapNodesToGroups(testNodeList);
         Test.stopTest();    
     }
    
        public static testmethod void MapNodeListInsert(){
        Node__c testNode1= new Node__c();
        Node__c testNode2= new Node__c();   
        Node__c testNode3= new Node__c();   
   
        testNode1=prepareNode('child1','parent',5);
        testNode2=prepareNode('child2','parent',5);
        testNode3=prepareNode('child3','parent',5);

        List<Node__c> testNodeList = new List<Node__c>();
        testNodeList.add(testNode1);
        testNodeList.add(testNode2);
        testNodeList.add(testNode3); 
        
        System.runAs(new user(id=UserInfo.GetuserId())) {
        
        insert testNodeList;
        //Author: Luca Bassani------------------
        update testNodeList;
        delete testNodeList;
        undelete testNodeList;
        //--------------------------------------
        }
    }
    
    public static testmethod void UpdateNodeList(){
        Node__c testNode1= new Node__c();
        Node__c testNode2= new Node__c();   
        Node__c testNode3= new Node__c();   
   
        testNode1=prepareNode('child1','parent',5);
        testNode2=prepareNode('child2','parent',5);
        testNode3=prepareNode('child3','parent',5);
        
        List<Node__c> testNodeList = new List<Node__c>();
        testNodeList.add(testNode1);
        testNodeList.add(testNode2);
        testNodeList.add(testNode3); 
        testNodeList.add(testNode3);
        
        // create the groups manually
        group TEST_TREE_child1 = new group(Name='TEST_TREE_child1');
        group TEST_TREE_child2 = new group(Name='TEST_TREE_child2');
        group TEST_TREE_child3 = new group(Name='TEST_TREE_child3');
        group TEST_TREE_parent = new group(Name='TEST_TREE_parent');

        
        List<Group> Listgroups = new List<Group>();
        Listgroups.add(TEST_TREE_child1);
        Listgroups.add(TEST_TREE_child2);
        Listgroups.add(TEST_TREE_child3);
        Listgroups.add(TEST_TREE_parent);
        insert Listgroups;
        
        // connect groups manually
        List<GroupMember> ListGM = new List<GroupMember>();

        groupmember child1inparent = new groupmember();
        child1inparent.groupid=TEST_TREE_child1.id;
        child1inparent.UserOrGroupId=TEST_TREE_parent.id;

        groupmember child2inparent = new groupmember();
        child2inparent.groupid=TEST_TREE_child2.id;
        child2inparent.UserOrGroupId=TEST_TREE_parent.id;

        groupmember child3inparent = new groupmember();
        child3inparent.groupid=TEST_TREE_child3.id;
        child3inparent.UserOrGroupId=TEST_TREE_parent.id;
        
        ListGM.add(child1inparent);
        ListGM.add(child2inparent);
        ListGM.add(child3inparent);
        insert  ListGM;

        NodeManagement testNM = new NodeManagement();
        Test.startTest();
        testNM.MapNodesToGroups(testNodeList);
        Test.stopTest();    
    }
    
    //Author: Luca Bassani------------------
    static testMethod void handlerCall(){
        Node__c n = new Node__c();
        n =prepareNode('child1','parent',5);
        
        List<Node__c> nList = new List<Node__c>();
        nList.add(n);
         
        System.runAs(new user(id=UserInfo.GetuserId())) {
        
            insert nList;
            update nList;
            delete nList;
            undelete nList; 
            }
    }
    //--------------------------------------
   
    
}