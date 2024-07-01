/*------------------------------------------------------------------------
Author:        Davide Fabris
Company:       Deloitte
Class:         NodeManagement 
Description:   A test class created to validate the UserProvisioningManagement class
               Tests executed:
               1 - 
History

 24/07/2015     Davide Fabris    
----------------------------------------------------------------------------*/


@isTest
private class UserProvisioningManagement_TEST {
// I need userdetail object to get the correct instance of the class
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
    
    ////////////END of AUXILIARY METHODS////////////////7
        public static testmethod void testWrongCreator(){
        UserProvisioningManagement usr = new UserProvisioningManagement();
    }
    
    public static testmethod void testCorrectCreator(){
        UserProvisioningAAI.UserNodeInput Node1= new UserProvisioningAAI.UserNodeInput();
        Node1 = prepareNodesInput('3014', 7, 'myprofile', 'myrole', false);
        
        List<UserProvisioningAAI.UserNodeInput> NodesList= new List<UserProvisioningAAI.UserNodeInput>();   
        NodesList.add(Node1);
      
        UserProvisioningAAI.UserDetailsInput Usrdetails = new UserProvisioningAAI.UserDetailsInput();
        Usrdetails = prepareUserStructure('testname', 'testsurname', 'test@username.com', 'AG5014', NodesList);
        
        UserProvisioningManagement usrmgt =  new UserProvisioningManagement(Usrdetails);
        usrmgt.getAreUserInputsOK();
        usrmgt.getWasUserCreated();
        usrmgt.getProfile();
        usrmgt.getRoleID();
        usrmgt.getPartnerContact();
        usrmgt.getAllNodesLevelFromInput();
    }

    public static testmethod void testValidatePartnerUser(){
        UserProvisioningAAI.UserNodeInput Node1= new UserProvisioningAAI.UserNodeInput();
        Node1 = prepareNodesInput('3014', 7, 'myprofile', 'myrole', false);
        
        List<UserProvisioningAAI.UserNodeInput> NodesList= new List<UserProvisioningAAI.UserNodeInput>();   
        NodesList.add(Node1);
        
        
        //one with partner user
        UserProvisioningAAI.UserDetailsInput Usrdetails = new UserProvisioningAAI.UserDetailsInput();
        Usrdetails = prepareUserStructure('testname', 'testsurname', 'test@username.com', 'AG5014', NodesList);
        UserProvisioningManagement usrmgt =  new UserProvisioningManagement(Usrdetails);
        usrmgt.ValidateInputFields();
        
        //one without
        Usrdetails = prepareUserStructure('testname', 'testsurname', 'test@username.com', '', NodesList);
        usrmgt =  new UserProvisioningManagement(Usrdetails);
        usrmgt.ValidateInputFields();
    }  
    
    
    public static testmethod void testValidateAdminFlag(){
        UserProvisioningAAI.UserNodeInput Node1= new UserProvisioningAAI.UserNodeInput();
        UserProvisioningAAI.UserNodeInput Node2= new UserProvisioningAAI.UserNodeInput();
      
        Node1 = prepareNodesInput('30140001', 8, 'myprofile', 'myrole', true);
        Node2 = prepareNodesInput('3014', 7, 'myprofile', 'myrole', true);
        
        List<UserProvisioningAAI.UserNodeInput> NodesListOK= new List<UserProvisioningAAI.UserNodeInput>();   
        NodesListOK.add(Node1);
        
        List<UserProvisioningAAI.UserNodeInput> NodesListKO= new List<UserProvisioningAAI.UserNodeInput>();   
        NodesListKO.add(Node1);
        NodesListKO.add(Node2);
        
        //one with flag
        UserProvisioningAAI.UserDetailsInput Usrdetails = new UserProvisioningAAI.UserDetailsInput();
        Usrdetails = prepareUserStructure('testname', 'testsurname', 'test@class.com', '', NodesListOK);
        UserProvisioningManagement usrmgt =  new UserProvisioningManagement(Usrdetails);
        usrmgt.ValidateInputFields();
        
        //one without
        Usrdetails = prepareUserStructure('testname', 'testsurname', 'test@class.com', '', NodesListKO);
        usrmgt =  new UserProvisioningManagement(Usrdetails);
        usrmgt.ValidateInputFields();
    } 

    public static testmethod void testValidateallnodesString(){
        UserProvisioningAAI.UserNodeInput Node1= new UserProvisioningAAI.UserNodeInput();
        UserProvisioningAAI.UserNodeInput Node2= new UserProvisioningAAI.UserNodeInput();
       
        Node1 = prepareNodesInput('3014', 7, 'myprofile', 'myrole', true);
        Node2 = prepareNodesInput('3014', 7, 'myprofile', 'myrole', false);
        
        List<UserProvisioningAAI.UserNodeInput> NodesListOK= new List<UserProvisioningAAI.UserNodeInput>();   
        NodesListOK.add(Node1);
        
        List<UserProvisioningAAI.UserNodeInput> NodesListKO= new List<UserProvisioningAAI.UserNodeInput>();   
        NodesListKO.add(Node1);
        NodesListKO.add(Node2);
        
        //one with duplicates
        UserProvisioningAAI.UserDetailsInput Usrdetails = new UserProvisioningAAI.UserDetailsInput();
        Usrdetails = prepareUserStructure('testname', 'testsurname', 'test@class.com', '', NodesListKO);
        UserProvisioningManagement usrmgt =  new UserProvisioningManagement(Usrdetails);
        usrmgt.ValidateInputFields();
        
        //one without duplicates
        Usrdetails = prepareUserStructure('testname', 'testsurname', 'test@class.com', '', NodesListOK);
        usrmgt =  new UserProvisioningManagement(Usrdetails);
        usrmgt.ValidateInputFields();
    }      
    
    public static testmethod void testValidateAllNodesEnabled(){
        System.runas(new user(id=UserInfo.GetUserid())) {
        // I need to create the nodes before trying to profile users for them
        Node__c NodeA = new Node__c();
        NodeA = prepareNode('30140001', 'Z001', 8);
        insert NodeA;
        }
         
        UserProvisioningAAI.UserNodeInput Node1= new UserProvisioningAAI.UserNodeInput();
        UserProvisioningAAI.UserNodeInput Node2= new UserProvisioningAAI.UserNodeInput();
       
        Node1 = prepareNodesInput('30140001', 8, 'myprofile', 'myrole', true);
        Node2 = prepareNodesInput('30140002', 8, 'myprofile', 'myrole', false);
               
        List<UserProvisioningAAI.UserNodeInput> NodesListOK= new List<UserProvisioningAAI.UserNodeInput>();   
        NodesListOK.add(Node1);
        
        List<UserProvisioningAAI.UserNodeInput> NodesListKO= new List<UserProvisioningAAI.UserNodeInput>();   
        NodesListKO.add(Node1);
        NodesListKO.add(Node2);
        
        //one with nodes already inserted
        UserProvisioningAAI.UserDetailsInput Usrdetails = new UserProvisioningAAI.UserDetailsInput();
        Usrdetails = prepareUserStructure('testname', 'testsurname', 'test@class.com', '', NodesListOK);
        UserProvisioningManagement usrmgt =  new UserProvisioningManagement(Usrdetails);
        usrmgt.ValidateInputFields();
        
        //one without 
        Usrdetails = prepareUserStructure('testname', 'testsurname', 'test@class.com', '', NodesListKO);
        usrmgt =  new UserProvisioningManagement(Usrdetails);
        usrmgt.ValidateInputFields();
    }
    
    public static testmethod void testgetProfileStringFromInput(){
        System.runas(new user(id=UserInfo.GetUserid())) {
        // I need to create the nodes before trying to profile users for them
        Node__c NodeA = new Node__c();
        Node__c NodeB = new Node__c();
        NodeA = prepareNode('30140001', '3014', 8);
        NodeB = prepareNode('30140002', '3014', 8);

        insert NodeA;
        insert NodeB;
        }
         
        UserProvisioningAAI.UserNodeInput Node1= new UserProvisioningAAI.UserNodeInput();
        UserProvisioningAAI.UserNodeInput Node2= new UserProvisioningAAI.UserNodeInput();
       
        Node1 = prepareNodesInput('30140001', 8, 'myprofile', 'myrole', true);
        Node2 = prepareNodesInput('30140002', 8, 'myDifferentprofile', 'myrole', false);
               
        List<UserProvisioningAAI.UserNodeInput> NodesListOK= new List<UserProvisioningAAI.UserNodeInput>();   
        NodesListOK.add(Node1);
        
        List<UserProvisioningAAI.UserNodeInput> NodesListKO= new List<UserProvisioningAAI.UserNodeInput>();   
        NodesListKO.add(Node1);
        NodesListKO.add(Node2);
        
        //one with only one profile
        UserProvisioningAAI.UserDetailsInput Usrdetails = new UserProvisioningAAI.UserDetailsInput();
        Usrdetails = prepareUserStructure('testname', 'testsurname', 'test@class.com', '', NodesListOK);
        UserProvisioningManagement usrmgt =  new UserProvisioningManagement(Usrdetails);
        usrmgt.ValidateInputFields();
        
        //one with two prifles
        Usrdetails = prepareUserStructure('testname', 'testsurname', 'test@class.com', '', NodesListKO);
        usrmgt =  new UserProvisioningManagement(Usrdetails);
        usrmgt.ValidateInputFields();
    }


    public static testmethod void testValidateProfileID(){
        System.runas(new user(id=UserInfo.GetUserid())) {
        // I need to create the nodes before trying to profile users for them
        Node__c NodeA = new Node__c();
        Node__c NodeB = new Node__c();
        NodeA = prepareNode('30140001', '3014', 8);
        NodeB = prepareNode('30140002', '3014', 8);
        
        insert NodeA;
        insert NodeB;
        }
        
        List<Profile> availableProf = new List<Profile>();
        availableProf= [SELECT Name FROM Profile];
        system.debug('++++++++++++availableProf in class test'+availableProf);
         
        UserProvisioningAAI.UserNodeInput Node1= new UserProvisioningAAI.UserNodeInput();
        UserProvisioningAAI.UserNodeInput Node2= new UserProvisioningAAI.UserNodeInput();
       
        Node1 = prepareNodesInput('30140001', 8, 'myprofile', 'myrole', true);
        Node2 = prepareNodesInput('30140002', 8, 'AAI - Marketing Avanzato', 'myrole', true);
               
        List<UserProvisioningAAI.UserNodeInput> NodesListOK= new List<UserProvisioningAAI.UserNodeInput>();   
        NodesListOK.add(Node2);
        
        List<UserProvisioningAAI.UserNodeInput> NodesListKO= new List<UserProvisioningAAI.UserNodeInput>();   
        NodesListKO.add(Node1);
        
        //one with correct profile
        UserProvisioningAAI.UserDetailsInput Usrdetails = new UserProvisioningAAI.UserDetailsInput();
        Usrdetails = prepareUserStructure('testname', 'testsurname', 'test@class.com', '', NodesListOK);
        UserProvisioningManagement usrmgt =  new UserProvisioningManagement(Usrdetails);
        usrmgt.ValidateInputFields();
        
        //one with wrong profile
        Usrdetails = prepareUserStructure('testname', 'testsurname', 'test@class.com', '', NodesListKO);
        usrmgt =  new UserProvisioningManagement(Usrdetails);
        usrmgt.ValidateInputFields();
    }

    public static testmethod void testgetRoleStringFromInput(){
        System.runas(new user(id=UserInfo.GetUserid())) {
        // I need to create the nodes before trying to profile users for them
        Node__c NodeA = new Node__c();
        Node__c NodeB = new Node__c();
        NodeA = prepareNode('30140001', '3014', 8);
        NodeB = prepareNode('30140002', '3014', 8);
        
        insert NodeA;
        insert NodeB;
        }
        

         
        UserProvisioningAAI.UserNodeInput Node1= new UserProvisioningAAI.UserNodeInput();
        UserProvisioningAAI.UserNodeInput Node2= new UserProvisioningAAI.UserNodeInput();
       
        Node1 = prepareNodesInput('30140001', 8, 'AAI - Marketing Avanzato', 'myrole', true);
        Node2 = prepareNodesInput('30140002', 8, 'AAI - Marketing Avanzato', 'mydifferentrole', false);
               
        List<UserProvisioningAAI.UserNodeInput> NodesListOK= new List<UserProvisioningAAI.UserNodeInput>();   
        NodesListOK.add(Node1);
        
        List<UserProvisioningAAI.UserNodeInput> NodesListKO= new List<UserProvisioningAAI.UserNodeInput>();   
        NodesListKO.add(Node1);
        NodesListKO.add(Node2);
        
        //one with correct profile
        UserProvisioningAAI.UserDetailsInput Usrdetails = new UserProvisioningAAI.UserDetailsInput();
        Usrdetails = prepareUserStructure('testname', 'testsurname', 'test@class.com', '', NodesListOK);
        UserProvisioningManagement usrmgt =  new UserProvisioningManagement(Usrdetails);
        usrmgt.ValidateInputFields();
        
        //one with wrong profile
        Usrdetails = prepareUserStructure('testname', 'testsurname', 'test@class.com', '', NodesListKO);
        usrmgt =  new UserProvisioningManagement(Usrdetails);
        usrmgt.ValidateInputFields();
    }
    
    public static testmethod void testValidateAgencyCode(){
        // get the query of the agency node
        System.runAs(new User(Id=UserInfo.getUserId()) ) {
            AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
            insert acv;
        }
        
        System.runas(new user(id=UserInfo.GetUserid())) {
        // I need to create the nodes before trying to profile users for them
        Node__c NodeA = new Node__c();
        Node__c NodeB = new Node__c();
        NodeA = prepareNode('3014', 'Z001', 7);
        // NodeB = prepareNode('30140002', '3014', 8);
        
        insert NodeA;
        // insert NodeB;
        }

        UserProvisioningAAI.UserNodeInput Node1= new UserProvisioningAAI.UserNodeInput();
        UserProvisioningAAI.UserNodeInput Node2= new UserProvisioningAAI.UserNodeInput();
       
        Node1 = prepareNodesInput('3014', 7, 'NFE - AAI - Vendite Avanzato', 'myrole', true);
        // Node2 = prepareNodesInput('30140002', 8, 'AAI - Marketing Avanzato', 'mydifferentrole', false);
               
        List<UserProvisioningAAI.UserNodeInput> NodesListOK= new List<UserProvisioningAAI.UserNodeInput>();   
        NodesListOK.add(Node1);
        
        List<UserProvisioningAAI.UserNodeInput> NodesListKO= new List<UserProvisioningAAI.UserNodeInput>();   
        // NodesListKO.add(Node1);
        // NodesListKO.add(Node2);
        
        //one with correct agency code
        UserProvisioningAAI.UserDetailsInput Usrdetails = new UserProvisioningAAI.UserDetailsInput();
        Usrdetails = prepareUserStructure('testname', 'testsurname', 'test@class.com', '3014', NodesListOK);
        UserProvisioningManagement usrmgt =  new UserProvisioningManagement(Usrdetails);
        usrmgt.ValidateInputFields();
        
        //one with wrong agency code
        Usrdetails = prepareUserStructure('testname', 'testsurname', 'test@class.com', '33333333333', NodesListOK);
        usrmgt =  new UserProvisioningManagement(Usrdetails);
        usrmgt.ValidateInputFields();
    }
    
    public static testmethod void testValidateAgencyAccountID(){
        // get the query of the agency node
        System.runAs(new User(Id=UserInfo.getUserId()) ) {
            AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
            insert acv;
        }
        
        System.runas(new user(id=UserInfo.GetUserid())) {
        // I need to create the nodes before trying to profile users for them
        Node__c NodeA = new Node__c();
        Node__c NodeB = new Node__c();
        NodeA = prepareNode('3014', 'Z001', 7);
        NodeB = prepareNode('2014', 'Z002', 8); // use a lv 8 node as agency to prevent the creation of agency account
        
        insert NodeA;
        insert NodeB;
        }

        UserProvisioningAAI.UserNodeInput Node1= new UserProvisioningAAI.UserNodeInput();
        UserProvisioningAAI.UserNodeInput Node2= new UserProvisioningAAI.UserNodeInput();
       
        Node1 = prepareNodesInput('3014', 7, 'NFE - AAI - Vendite Avanzato', 'myrole', true);
        Node2 = prepareNodesInput('2014', 8, 'NFE - AAI - Vendite Avanzato', 'myrole', true);
               
        List<UserProvisioningAAI.UserNodeInput> NodesListOK= new List<UserProvisioningAAI.UserNodeInput>();   
        NodesListOK.add(Node1);
        
        List<UserProvisioningAAI.UserNodeInput> NodesListKO= new List<UserProvisioningAAI.UserNodeInput>();   
        NodesListKO.add(Node2);
        
        //one with the existing agency account
        UserProvisioningAAI.UserDetailsInput Usrdetails = new UserProvisioningAAI.UserDetailsInput();
        Usrdetails = prepareUserStructure('testname', 'testsurname', 'test@class.com', '3014', NodesListOK);
        UserProvisioningManagement usrmgt =  new UserProvisioningManagement(Usrdetails);
        usrmgt.ValidateInputFields();
        
        //one with the non existing agency account
        Usrdetails = prepareUserStructure('testname', 'testsurname', 'test@class.com', '2014', NodesListKO);
        usrmgt =  new UserProvisioningManagement(Usrdetails);
        usrmgt.ValidateInputFields();
    }
    
    public static testmethod void testValidateRolePartnerUser(){
        // get the query of the agency node
        System.runAs(new User(Id=UserInfo.getUserId()) ) {
            AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
            insert acv;
        }
        
        System.runas(new user(id=UserInfo.GetUserid())) {
        // I need to create the nodes before trying to profile users for them
        Node__c NodeA = new Node__c();
        NodeA = prepareNode('3014', 'Z001', 7);     
        insert NodeA;
        }

        UserProvisioningAAI.UserNodeInput Node1= new UserProvisioningAAI.UserNodeInput();
        UserProvisioningAAI.UserNodeInput Node2= new UserProvisioningAAI.UserNodeInput();
        UserProvisioningAAI.UserNodeInput Node3= new UserProvisioningAAI.UserNodeInput();
        UserProvisioningAAI.UserNodeInput Node4= new UserProvisioningAAI.UserNodeInput();


        Node1 = prepareNodesInput('3014', 7, 'NFE - AAI - Vendite Avanzato', 'Executive', true);
        Node2 = prepareNodesInput('3014', 7, 'NFE - AAI - Vendite Avanzato', 'Manager', true);
        Node3 = prepareNodesInput('3014', 7, 'NFE - AAI - Vendite Avanzato', 'User', true);

        Node4 = prepareNodesInput('3014', 7, 'NFE - AAI - Vendite Avanzato', 'myrole', true);
               
        List<UserProvisioningAAI.UserNodeInput> NodesListOK1= new List<UserProvisioningAAI.UserNodeInput>();   
        NodesListOK1.add(Node1);
        List<UserProvisioningAAI.UserNodeInput> NodesListOK2= new List<UserProvisioningAAI.UserNodeInput>();   
        NodesListOK2.add(Node2);
        List<UserProvisioningAAI.UserNodeInput> NodesListOK3= new List<UserProvisioningAAI.UserNodeInput>();   
        NodesListOK3.add(Node3);
        
        List<UserProvisioningAAI.UserNodeInput> NodesListKO= new List<UserProvisioningAAI.UserNodeInput>();   
        NodesListKO.add(Node4);
        
        //3 with the correct roles
        UserProvisioningAAI.UserDetailsInput Usrdetails = new UserProvisioningAAI.UserDetailsInput();
        Usrdetails = prepareUserStructure('testname', 'testsurname', 'test@class.com', '3014', NodesListOK1);
        UserProvisioningManagement usrmgt =  new UserProvisioningManagement(Usrdetails);
        usrmgt.ValidateInputFields();
        
        //UserProvisioningAAI.UserDetailsInput Usrdetails = new UserProvisioningAAI.UserDetailsInput();
        Usrdetails = prepareUserStructure('testname', 'testsurname', 'test@class.com', '3014', NodesListOK2);
        usrmgt =  new UserProvisioningManagement(Usrdetails);
        usrmgt.ValidateInputFields();
        
        //UserProvisioningAAI.UserDetailsInput Usrdetails = new UserProvisioningAAI.UserDetailsInput();
        Usrdetails = prepareUserStructure('testname', 'testsurname', 'test@class.com', '3014', NodesListOK3);
        usrmgt =  new UserProvisioningManagement(Usrdetails);
        usrmgt.ValidateInputFields();
        
        //one with wrong roles
        Usrdetails = prepareUserStructure('testname', 'testsurname', 'test@class.com', '3014', NodesListKO);
        usrmgt =  new UserProvisioningManagement(Usrdetails);
        usrmgt.ValidateInputFields();
    }
    
    public static testmethod void testValidateRoleInternalUser(){
        // get the query of the agency node
        System.runAs(new User(Id=UserInfo.getUserId()) ) {
            AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
            insert acv;
        }
        
        System.runas(new user(id=UserInfo.GetUserid())) {
        // I need to create the nodes before trying to profile users for them
        Node__c NodeA = new Node__c();
        NodeA = prepareNode('3014', 'Z001', 7);
        insert NodeA;
        }

        UserProvisioningAAI.UserNodeInput Node1= new UserProvisioningAAI.UserNodeInput();
        UserProvisioningAAI.UserNodeInput Node2= new UserProvisioningAAI.UserNodeInput();
       
        Node1 = prepareNodesInput('3014', 7, 'AAI - Marketing Avanzato', 'AXA_Assicurazioni', true);
        Node2 = prepareNodesInput('3014', 7, 'AAI - Marketing Avanzato', 'xxxxxxxxxxxxxxxxxxx', true);
               
        List<UserProvisioningAAI.UserNodeInput> NodesListOK= new List<UserProvisioningAAI.UserNodeInput>();   
        NodesListOK.add(Node1);
        
        List<UserProvisioningAAI.UserNodeInput> NodesListKO= new List<UserProvisioningAAI.UserNodeInput>();   
        NodesListKO.add(Node2);
        
        //one with the existing agency account
        UserProvisioningAAI.UserDetailsInput Usrdetails = new UserProvisioningAAI.UserDetailsInput();
        Usrdetails = prepareUserStructure('testname', 'testsurname', 'test@class.com', '', NodesListOK);
        UserProvisioningManagement usrmgt =  new UserProvisioningManagement(Usrdetails);
        usrmgt.ValidateInputFields();
        
        //one with the non existing agency account
        Usrdetails = prepareUserStructure('testname', 'testsurname', 'test@class.com', '', NodesListKO);
        usrmgt =  new UserProvisioningManagement(Usrdetails);
        usrmgt.ValidateInputFields();
    }
    
    
    public static testmethod void testCreateUserINTERNAL(){
        // get the query of the agency node
        System.runAs(new User(Id=UserInfo.getUserId()) ) {
            AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
            insert acv;
        }
        
        System.runas(new user(id=UserInfo.GetUserid())) {
        // I need to create the nodes before trying to profile users for them
        Node__c NodeA = new Node__c();
        NodeA = prepareNode('3014', 'Z001', 4);
        insert NodeA;
        }

        UserProvisioningAAI.UserNodeInput Node1= new UserProvisioningAAI.UserNodeInput();
       
        Node1 = prepareNodesInput('3014', 4, 'AAI - Marketing Avanzato', 'AXA_Assicurazioni', true);
               
        List<UserProvisioningAAI.UserNodeInput> NodesListOK= new List<UserProvisioningAAI.UserNodeInput>();   
        NodesListOK.add(Node1);

        
        //one with INSERT
        UserProvisioningAAI.UserDetailsInput Usrdetails = new UserProvisioningAAI.UserDetailsInput();
        Usrdetails = prepareUserStructure('testname', 'testsurname', 'test@class.com', '', NodesListOK);
        UserProvisioningManagement usrmgt =  new UserProvisioningManagement(Usrdetails);
        usrmgt.ValidateInputFields();
        usrmgt.CreateUser();
        
        // one with UPDATE
        Usrdetails = prepareUserStructure('testname', 'testsurnameBIS', 'test@class.com', '', NodesListOK);
        Usrdetails.Active='11';
        usrmgt =  new UserProvisioningManagement(Usrdetails);
        usrmgt.ValidateInputFields();
        usrmgt.CreateUser();


        // one with EXCEPTION
        Usrdetails = prepareUserStructure('testname', 'testsurname', 'testclass.com', '', NodesListOK);
        usrmgt =  new UserProvisioningManagement(Usrdetails);
        usrmgt.ValidateInputFields();
        usrmgt.CreateUser();

    }
    
    public static testmethod void testCreateUserPARTNER_InsertNEWAg(){
        // get the query of the agency node
        System.runAs(new User(Id=UserInfo.getUserId()) ) {
            AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
            insert acv;
        }
        
        System.runas(new user(id=UserInfo.GetUserid())) {
        // I need to create the nodes before trying to profile users for them
        Node__c NodeA = new Node__c();
        NodeA = prepareNode('003014', 'Z001', 7);
        insert NodeA;
        }

        UserProvisioningAAI.UserNodeInput Node1= new UserProvisioningAAI.UserNodeInput();
       
        Node1 = prepareNodesInput('3014', 7, 'NFE - AAI - Vendite Avanzato', 'Executive', true);
               
        List<UserProvisioningAAI.UserNodeInput> NodesListOK= new List<UserProvisioningAAI.UserNodeInput>();   
        NodesListOK.add(Node1);

        test.starttest();
        System.runAs(new User(Id=UserInfo.getUserId()) ) {
        //one with INSERT on new agency
        UserProvisioningAAI.UserDetailsInput Usrdetails = new UserProvisioningAAI.UserDetailsInput();
        Usrdetails = prepareUserStructure('testname', 'testsurname', 'test@class.com', '3014', NodesListOK);
        UserProvisioningManagement usrmgt =  new UserProvisioningManagement(Usrdetails);
        usrmgt.ValidateInputFields();
        usrmgt.CreateUser();
        }
        test.stoptest();

    }

    public static testmethod void testCreateUserPARTNER_InsertEXISTINGAg(){
        // get the query of the agency node
        System.runAs(new User(Id=UserInfo.getUserId()) ) {
            AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
            insert acv;
        }
        
        System.runas(new user(id=UserInfo.GetUserid())) {
        // I need to create the nodes before trying to profile users for them
        Node__c NodeA = new Node__c();
        NodeA = prepareNode('003014', 'Z001', 7);
        insert NodeA;
        
        List<Account> thisagency = [SELECT Id, Name FROM Account where Agency_Code__c='003014' ];
        system.debug('++++++thisagency'+thisagency);
        List<Profile> thisprofile = [SELECT Id, Name FROM Profile where Name='NFE - AAI - Vendite Base' ];

        //prepare contact for user
        contact supp_contact = new Contact();
        supp_contact.FirstName='test_suppFN';
        supp_contact.LastName='test_suppLN';
        supp_contact.AccountId=thisagency.get(0).Id;
        insert supp_contact;
        
        //prepare user
        user supp_usr = new user();
     //just passing all details to the user instance
        supp_usr.FirstName='usrFN';
        supp_usr.LastName='usrLN';
        supp_usr.Alias='usrtst';
        supp_usr.CommunityNickname='usrtstFNLN';
        supp_usr.ProfileId=thisprofile.get(0).id;

        supp_usr.Email='tst@tst.tst';
        supp_usr.Username='tst@tst.tst.AXAITALY';

        
        supp_usr.LanguageLocaleKey = 'it';
        supp_usr.EmailEncodingKey = 'ISO-8859-1';
        supp_usr.TimeZoneSidKey = 'Europe/Rome';
        supp_usr.LocaleSidKey = 'it_IT';
        supp_usr.contactid=supp_contact.id;
         //insert supp_usr;


        }
        
        //one with INSERT on existing agency
        test.starttest();
        System.runAs(new User(Id=UserInfo.getUserId()) ) {
        
        UserProvisioningAAI.UserNodeInput Node1= new UserProvisioningAAI.UserNodeInput();
       
        Node1 = prepareNodesInput('3014', 7, 'NFE - AAI - Vendite Avanzato', 'Executive', true);
               
        List<UserProvisioningAAI.UserNodeInput> NodesListOK= new List<UserProvisioningAAI.UserNodeInput>();   
        NodesListOK.add(Node1);
                
        UserProvisioningAAI.UserDetailsInput Usrdetails = new UserProvisioningAAI.UserDetailsInput();
        Usrdetails = prepareUserStructure('testname2', 'testsurname2', 'test2@class2.com', '3014', NodesListOK);
        UserProvisioningManagement usrmgt =  new UserProvisioningManagement(Usrdetails);
        usrmgt.ValidateInputFields();
        usrmgt.CreateUser();
        }
        test.stoptest();

    }

    public static testmethod void testCreateUserPARTNER_UpdateFail(){
        // get the query of the agency node
        System.runAs(new User(Id=UserInfo.getUserId()) ) {
            AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
            insert acv;
        }
        
        System.runas(new user(id=UserInfo.GetUserid())) {
        // I need to create the nodes before trying to profile users for them
            Node__c NodeA = new Node__c();
            NodeA = prepareNode('003014', 'Z001', 7);
            insert NodeA;
        
            List<Account> thisagency = [SELECT Id, Name FROM Account where Agency_Code__c='003014' ];
            List<Profile> thisprofile = [SELECT Id, Name FROM Profile where Name='NFE - AAI - Vendite Base' ];

            //prepare contact for user
            contact supp_contact = new Contact();
            supp_contact.FirstName='test_suppFN';
            supp_contact.LastName='test_suppLN';
            supp_contact.AccountId=thisagency.get(0).Id;
            insert supp_contact;
        
            //prepare user
            user supp_usr = new user();
            //just passing all details to the user instance
            supp_usr.FirstName='usrFN';
            supp_usr.LastName='usrLN';
            supp_usr.Alias='usrtst';
            supp_usr.CommunityNickname='usrtstFNLN';
            supp_usr.ProfileId=thisprofile.get(0).id;

            supp_usr.Email='tst@tst.tst';
            supp_usr.Username='tst@tst.tst.AXAITALY';

        
            supp_usr.LanguageLocaleKey = 'it';
            supp_usr.EmailEncodingKey = 'ISO-8859-1';
            supp_usr.TimeZoneSidKey = 'Europe/Rome';
            supp_usr.LocaleSidKey = 'it_IT';
            supp_usr.contactid=supp_contact.id;
           // insert supp_usr;
            }
        
        //one with UPDATE, not giving the agency so is going to fail (change of agency)
        test.starttest();
        System.runAs(new User(Id=UserInfo.getUserId()) ) {
        
            UserProvisioningAAI.UserNodeInput Node1= new UserProvisioningAAI.UserNodeInput();
       
            Node1 = prepareNodesInput('3014', 7, 'NFE - AAI - Vendite Avanzato', 'Executive', true);
               
            List<UserProvisioningAAI.UserNodeInput> NodesListOK= new List<UserProvisioningAAI.UserNodeInput>();   
            NodesListOK.add(Node1);
                
            UserProvisioningAAI.UserDetailsInput Usrdetails = new UserProvisioningAAI.UserDetailsInput();
            Usrdetails = prepareUserStructure('testname2', 'testsurname2', 'tst@tst.tst.AXAITALY', '3014', NodesListOK);
            UserProvisioningManagement usrmgt =  new UserProvisioningManagement(Usrdetails);
            usrmgt.ValidateInputFields();
            usrmgt.CreateUser();
        }
        test.stoptest();
    }
    
     public static testmethod void testCreateUserPARTNER_InsertException(){
                // get the query of the agency node
        System.runAs(new User(Id=UserInfo.getUserId()) ) {
            AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
            insert acv;
        }
        
        System.runas(new user(id=UserInfo.GetUserid())) {
        // I need to create the nodes before trying to profile users for them
        Node__c NodeA = new Node__c();
        NodeA = prepareNode('003014', 'Z001', 7);
        insert NodeA;
        }

        UserProvisioningAAI.UserNodeInput Node1= new UserProvisioningAAI.UserNodeInput();
       
        Node1 = prepareNodesInput('3014', 7, 'NFE - AAI - Vendite Avanzato', 'Executive', true);
               
        List<UserProvisioningAAI.UserNodeInput> NodesListOK= new List<UserProvisioningAAI.UserNodeInput>();   
        NodesListOK.add(Node1);

        test.starttest();
        System.runAs(new User(Id=UserInfo.getUserId()) ) {
        //one with INSERT on new agency
        UserProvisioningAAI.UserDetailsInput Usrdetails = new UserProvisioningAAI.UserDetailsInput();
        Usrdetails = prepareUserStructure('testname', 'testsurname', 'testclass.com', '3014', NodesListOK);
        UserProvisioningManagement usrmgt =  new UserProvisioningManagement(Usrdetails);
        usrmgt.ValidateInputFields();
        usrmgt.CreateUser();
        }
        test.stoptest();
    } 
    
}