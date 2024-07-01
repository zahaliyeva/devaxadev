/*------------------------------------------------------------------------
Author:        Davide Fabris
Company:       Deloitte
Class:         NodeManagement 
Description:   A test class created to validate the UserProvisioningAAI class
               Tests executed:
               1 - 
History

 24/07/2015     Davide Fabris    
----------------------------------------------------------------------------*/


@isTest
private class UserProvisioningAAI_TEST {

    public static UserProvisioningAAI.UserDetailsInput  prepareUserStructure(string Name, string Surname, string Username, string AgencyCode, List<UserProvisioningAAI.UserNodeInput> NodesInput){
        UserProvisioningAAI.UserDetailsInput UserInputs = new UserProvisioningAAI.UserDetailsInput();
        UserInputs.Active='0';
        UserInputs.FirstName=Name;
        UserInputs.LastName=Surname;
        UserInputs.Email='tes@test.test';
        UserInputs.UserName=Username;
        UserInputs.MyriamUserName='myriamUsrname';
        UserInputs.AgencyCode=AgencyCode;
        UserInputs.Nodes=NodesInput;
        return UserInputs; 
    }
    
    public static UserProvisioningAAI.UserNodeInput prepareNodesInput(string nodecode, integer nodelevel, string profile, string functionality, boolean Admin){
        UserProvisioningAAI.UserNodeInput oneNode = new UserProvisioningAAI.UserNodeInput();
        oneNode.NodeCode=nodecode;
        oneNode.NodeLevel=nodelevel;
        oneNode.Profile=profile;
        oneNode.Functionality=functionality;
        oneNode.AdminFlag=Admin;
        return oneNode;
    }
    
          

      

     public static testmethod void callUpsertUserAAIFailValidation(){
       UserProvisioningAAI.UserNodeInput Node1= new UserProvisioningAAI.UserNodeInput();
       Node1 = prepareNodesInput('3014', 7, 'myprofile', 'myrole', false);
       
       List<UserProvisioningAAI.UserNodeInput> NodesList= new List<UserProvisioningAAI.UserNodeInput>();   
       NodesList.add(Node1);

       UserProvisioningAAI.UserDetailsInput Usrdetails = new UserProvisioningAAI.UserDetailsInput();
       Usrdetails = prepareUserStructure('testname', 'testsurname', 'test@username.com', 'AG5014', NodesList);
       
       UserProvisioningAAI.UpsertUserAAI(Usrdetails);
    }
    
    public static testmethod void callUpsertUserAAISuccesCreation(){
       user tempusr = new user(Id=UserInfo.getUserId());
       System.runAs(tempusr) {
       Node__c thisagencynode = new Node__c();
       thisagencynode.node_unique_code__c='9999';
       thisagencynode.parent_node_unique_code__c='z999'; 
       thisagencynode.node_description__c='Descrizione nodo 999';
       thisagencynode.Node_level__c=6;
       thisagencynode.Intermediary_type__c='TI9999';
       thisagencynode.Management_type__c='TG999';
       insert thisagencynode;
       }
       
       UserProvisioningAAI.UserNodeInput Node1= new UserProvisioningAAI.UserNodeInput();
       Node1 = prepareNodesInput('9999', 7, 'AAI - Marketing Avanzato', 'Direzione_AAI', true);
       
       List<UserProvisioningAAI.UserNodeInput> NodesList= new List<UserProvisioningAAI.UserNodeInput>();   
       NodesList.add(Node1);

       UserProvisioningAAI.UserDetailsInput Usrdetails = new UserProvisioningAAI.UserDetailsInput();
       Usrdetails = prepareUserStructure('testname', 'testsurname', 'testclass@tesstclass.com', '', NodesList);
       
       UserProvisioningAAI.UpsertUserAAI(Usrdetails);
    }
    
     public static testmethod void callUpsertUserAAICreationFail(){
       user tempusr = new user(Id=UserInfo.getUserId());
       System.runAs(tempusr) {
       Node__c thisagencynode = new Node__c();
       thisagencynode.node_unique_code__c='9999';
       thisagencynode.parent_node_unique_code__c='z999'; 
       thisagencynode.node_description__c='Descrizione nodo 999';
       thisagencynode.Node_level__c=6;
       thisagencynode.Intermediary_type__c='TI9999';
       thisagencynode.Management_type__c='TG999';
       insert thisagencynode;
       }
       
       UserProvisioningAAI.UserNodeInput Node1= new UserProvisioningAAI.UserNodeInput();
       Node1 = prepareNodesInput('9999', 7, 'AAI - Marketing Avanzato', 'Direzione_AAI', true);
       
       List<UserProvisioningAAI.UserNodeInput> NodesList= new List<UserProvisioningAAI.UserNodeInput>();   
       NodesList.add(Node1);

       UserProvisioningAAI.UserDetailsInput Usrdetails = new UserProvisioningAAI.UserDetailsInput();
       Usrdetails = prepareUserStructure('testname', 'testsurname', 'testclasstesstclass', '', NodesList);
       
       UserProvisioningAAI.UpsertUserAAI(Usrdetails);
    }
    
    
}