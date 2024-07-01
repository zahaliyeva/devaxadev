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
private class NodeManagementAgency_TEST {

    public static Node__c prepareNode(string Name, string Parent, integer level){
        Node__c testNode= new Node__c();    
        testNode.Node_description__c='testdescription'+Name;
        testNode.Node_level__c=level;
        testNode.Node_unique_code__c=Name;
        testNode.Parent_node_unique_code__c='Parent';
        testNode.Tree_name__c='DIF'; //does not work with different tree name due to naming convention
        testNode.Management_type__c='TGest';
        testNode.Intermediary_type__c='TIntermediario';
        return testNode;
    }

     public static testmethod void MapNodeListNoInsert(){
         System.runAs(new User(Id=UserInfo.getUserId()) ) {
         AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
         insert acv;
         }
         Node__c testNode1= new Node__c();
         Node__c testNode2= new Node__c();   
         Node__c testNode3= new Node__c();   
   
         testNode1=prepareNode('child1','parent',7);
         testNode2=prepareNode('child2','parent',7);
         testNode3=prepareNode('child3','parent',7);

         List<Node__c> testNodeList = new List<Node__c>();
         testNodeList.add(testNode1);
         testNodeList.add(testNode2);
         testNodeList.add(testNode3); 
         //testNodeList.add(testNode3);    
   

         NodeManagementAgency testNMA = new NodeManagementAgency();
         NodeManagement testNM = new NodeManagement();
         List<user> u = new List<user>();
         u = [SELECT id from User where Name LIKE '%D%' AND isActive=true];
         System.runAs(new User(Id=UserInfo.getUserId()) ) {
         testNM.MapNodesToGroups(testNodeList);
         testNMA.UpsertAgencyAccounts(testNodeList);
         }
     } 
    
       public static testmethod void MapNodeListInsert(){
        List<user> u = new List<user>();
        u = [SELECT id from User where Name LIKE '%D%' AND isActive=true];
        System.runAs(u.get(0)) {

        AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
        insert acv;
        }


        Node__c testNode1= new Node__c();
        Node__c testNode2= new Node__c();   
        Node__c testNode3= new Node__c();   
   
        testNode1=prepareNode('child1','parent',7);
        testNode2=prepareNode('child2','parent',7);
        testNode3=prepareNode('child3','parent',7);

        List<Node__c> testNodeList = new List<Node__c>();
        List<Account> testAccountList = new List<Account>();

        testAccountList  = [SELECT Agency_Code__c from Account where Agency_Code__c != null and Active__c = true];
        

        
        testNodeList.add(testNode1);
        testNodeList.add(testNode2);
        testNodeList.add(testNode3); 
        
        test.startTest();
        System.runAs(new user(id=UserInfo.GetuserId())) {
        //System.runAs(u.get(0)) {

        insert testNodeList;
        }
        test.stopTest();
        
        testNodeList.get(0).Management_type__c='TGmodified';
        System.runAs(new user(id=UserInfo.GetuserId())) {
        update testNodeList;
        }
    }
}