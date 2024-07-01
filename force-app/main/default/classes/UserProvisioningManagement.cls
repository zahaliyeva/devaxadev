public class UserProvisioningManagement { 
    //Class Constants
    private static final boolean SALESFORCE1USER=false;//UserPreferencesHideS1BrowserUI
    private static final boolean FORCECOM_FLOW_USER=true;// UserPermissionsInteractionUser is for force.com flow user must be TRUE
    private static final boolean REMINDER_POPUP_FLAG=true;// UserPreferencesActivityRemindersPopup default to TRUE
    private static final map<String,String> MARKETING_USER = new map<string,string>{
     'AAI - Marketing Avanzato'=>'TRUE',
     'AAI - Marketing Consultazione'=>'FALSE',
     'AAI - Digital Avanzato'=>'FALSE',
     'AAI - Vendite Avanzato'=>'TRUE',
     'AAI - Vendite Base'=>'FALSE',
     'AAI - Dipartimento Avanzato'=>'FALSE',
     'AAI - Digital Consultazione'=>'FALSE',
     'AAI - Distribuzione Avanzato'=>'FALSE',
     'Default'=>'FALSE'
    };
    
    //Attributes
    public String Message; //to be provided to the WS
    private boolean AreUserInputsOK; // result of input check
    private boolean WasUserCreated; //result of creation checks
    public UserProvisioningAAI.UserDetailsInput UserDetailInput; //object structured as accorded with AXA
    public user userToCreate; // instance of the user to create or update
    public contact PartnerContact; // contact of the Partner user
    public Account AgencyAccount; // partner account of the agency
    public list<string> allNodesStrings; // Nodes strings provided
    public list<Node__c> allNodesEnabled; // Nodes objects obtained from the strings
    public Node__c AgencyNode; // Node object of the agency
    public list<integer> allNodesLevel; // Nodes levels
    public string ProfileString; // profile requested
    public string SFDC_PortalRole; // converting the role passed into the portalrole option
    public string RoleString; // Role requested
    public boolean isPartnerUser; // if an agency code is provided the user is considered a partner user
    private Profile UserProfile; // object profile
    private UserRole Role; //object role
    private Recordtype AgencyAccountRecordtype; 
    private RecordType AgencyContactRecordtype;
    public ID SSOPermissionSetID;

    // CORE Methods
   
    // Validation of the input fields
    public void ValidateInputFields() {
       
        this.ValidateIsPartnerUser();// simply checks if an agency code is provided
        
        this.ValidateAdminFlag(); //checks that only one admin flag is provided
        if (!this.AreUserInputsOK) {return;}
        
        this.allNodesStrings = this.getAllNodesStringsFromInput(); 
        this.ValidateAllNodesStrings(); //checks that the nodes profiled are all different
        if (!this.AreUserInputsOK) {return;}

        //find all nodes object the user is profiled for
        this.ValidateAllNodesEnabled(); // check that all provided nodes are on the CRM
        if (!this.AreUserInputsOK) {return;}
        
        this.ValidateMainNode(); //put the nodecode flagged on the correct field (check on flag and nodes already performed)

        this.ProfileString = this.getProfileStringFromInput(); //checking profiles are the same for all nodes
        if (!this.AreUserInputsOK) {return;}

        this.ValidateProfileID(); // getting profile ID with QUERY
        if (!this.AreUserInputsOK) {return;}

        this.RoleString = this.getRoleStringFromInput(); //checking roles are the same for all nodes
        if (!this.AreUserInputsOK) {return;}

        //different checks are necessary for internal and partner users
        if (this.isPartnerUser) {
            //Do the partner user checks
            this.ValidateAgencyCode();// find Agency node
            if (!this.AreUserInputsOK) {return;}

            this.ValidateAgencyAccountID();// find account id with QUERY
            if (!this.AreUserInputsOK) {return;}
            
            this.ValidateRolePartnerUser(); //find the Portalrole only, setting actual required role is done with future method 
            if (!this.AreUserInputsOK) {return;}

        } else {
            //Do the internal user checks
            this.ValidateRoleInternalUser();
            if (!this.AreUserInputsOK) {return;}   
        }
        
        this.Message=this.Message+'Validation passed';
    }
    
    public void CreateUser() {
        //Create the user
        // Different set of information are necessary for internal or partner users
        if (this.isPartnerUser) {
            this.CreatePartnerUserInstance(); //Create the instance of the partner user FIRST
            this.CreatePartnerContactInstance();// and the relevant partner contact instance
            
            system.debug('++++++++++++USER instance'+this.userToCreate);
            List<user> existing_user = [select id,contactid,Agency_Code__c from user where username=:this.userToCreate.username ]; // NOPMD  Fix CRUD violation
            try {
                if (existing_user.isempty()){
                    if (this.AgencyAccount.isPartner) {
                        // create new user to active agency
                        // insert the contact first
                        system.debug('+++++++++++++trying to insert new contact'+this.PartnerContact);
                        insert this.PartnerContact;
                        system.debug('+++++++++++++++++++insert succesfull of contact'+this.PartnerContact);
                        //this.Message=this.Message+'Created Partner Contact (on active agency) ('+this.PartnerContact.Id+')';
                        
                        //add contact to user instance
                        this.UserToCreate.ContactId=this.PartnerContact.Id;
                        
                        // role not provided even if present to avoid DML exception
                        // this.UserToCreate.userRoleId=null;
                        //insert user
                        system.debug('++++++++++++trying to insert user with contact'+this.userToCreate+' and without role');
                        insert this.UserToCreate;
                        system.debug('++++++++++++insert of user succesful'+this.userToCreate+' need to update role with future method');
                        // this.Message=this.Message+'Created Partner User (On active agency) without role ('+this.UserToCreate.Id+')';
                        
                        system.debug('+++++++attempt to update role with future method');
                        UserProvisioningManagement.UpdatePartnerRole(this.UserToCreate.Id, this.AgencyAccount.Id, this.SFDC_PortalRole);
                        system.debug('+++++++++++++future method  for update role called');                        
                    } else {
                        // Create new user to new agency
                        // insert the contact first
                        system.debug('+++++++++++++trying to insert new contact for new agency'+this.PartnerContact);
                        insert this.PartnerContact;
                        system.debug('+++++++++++++++++++insert succesfull of contact'+this.PartnerContact);
                        // this.Message=this.Message+'Created Partner Contact (on agency to be activated) ('+this.PartnerContact.Id+')';

                        //add contact to user instance
                        this.UserToCreate.ContactId=this.PartnerContact.Id;
                        system.debug('++++++++++++trying to insert user with contactid'+this.userToCreate.contactid);
                        
                        // add role to user instance
                        system.debug('++++++++++++trying insert of user without role'+this.userToCreate.userRoleId);

                        insert this.UserToCreate;
                        system.debug('++++++++++++insert of user succesful'+this.userToCreate.userRoleid);

                        // this.Message=this.Message+'Created Partner User(on agency to be activated) ('+this.UserToCreate.Id+')';
                        
                        system.debug('+++++++attempt to update role with future method');
                        UserProvisioningManagement.UpdatePartnerRole(this.UserToCreate.Id, this.AgencyAccount.Id, this.SFDC_PortalRole);
                        system.debug('+++++++++++++future update of role ok');
                        
                        //Update Active Flag on Agency with future method
                        UserProvisioningManagement.UpdateAgencyAccountFlag(this.AgencyAccount.Id);
                        system.debug('+++++++updated agency account flag');
                        // this.Message=this.Message+'Updated Active Flag on Agency Account('+this.AgencyAccount.Id+')';
                    }
                  //BOVOLENTA_D 09012018 -- MOVED THIS PART ONLY IN THE INSERT
                  List<Id> myListUserId = new List<Id>();
                  myListUserId.add(this.UserToCreate.id);
                  UserManagement.AddUsersToQsFuture(myListUserId);
                  //BOVOLENTA_D 09012018 --END  MOVED THIS PART ONLY IN THE INSERT 
                    
                } else { 
                // Updating a partner user
                system.debug('++++++++++++trying to update a partner user'+existing_user.get(0));
                    if (!(existing_user.get(0).Agency_Code__c==this.userToCreate.Agency_Code__c)) {
                        this.Message='Moving a user between agencies is not allowed';
                        this.WasUserCreated=false;
                        return;
                    }
                    
                    //if (!(this.AgencyAccount.IsPartner)){//never happens as a user is disabled if the account is disabled
                        //this.Message='Updating a user on a disabled account. Should not happen';
                        //this.WasUserCreated=false;
                        //return;
                    //}
                                        
                    this.userToCreate.Id = existing_user.get(0).Id;
                    
                    system.debug('+++++++++++++++++++PartnerUserBeforeUpdate'+this.userToCreate);
                    update this.UserToCreate;
                    // this.Message=this.Message+'Updated Partner User('+this.UserToCreate.Id+')';

                    //then update the contact
                    //if (existing_user.get(0).contactid==null) { //never happens, SFDC gives exception if one tries to cancel a contact of a partner user
                        //this.message=this.Message+'Updating a portal user that did not have a cotact. This should not happen';
                        //this.WasUserCreated=false;
                        //return;
                    //} else {
                        this.PartnerContact.Id=existing_user.get(0).contactid;
                        //Update Contact with the information on the updated user
                        UserProvisioningManagement.UpdatePartnerContact(this.UserToCreate.Id); 
                        // this.Message=this.Message+'Updated Partner contact('+this.UserToCreate.Id+')';
                    //}
                    
                    system.debug('+++++++attempt to update role with future method');
                    UserProvisioningManagement.UpdatePartnerRole(this.UserToCreate.Id, this.AgencyAccount.Id, this.SFDC_PortalRole);
                    system.debug('+++++++++++++future method  for update role called');
                    
                }
                
                //Insert single user to QName at the end of everything
                /*
                List<User> myListUser = new List<User>();
                myListUser.add(this.UserToCreate);
                UserManagement.AddUsersToQs(myListUser);
                */
                //BOVOLENTA_D 09012018 -- MOVED THIS PART ONLY IN THE INSERT
                //List<Id> myListUserId = new List<Id>();
                //myListUserId.add(this.UserToCreate.id);
                //UserManagement.AddUsersToQsFuture(myListUserId);
                //BOVOLENTA_D 09012018 --END  MOVED THIS PART ONLY IN THE INSERT
                //
                this.Message = this.Message + ' Upsert of partner user succesful, ID(' + this.userToCreate.Id+')';
            } catch (exception e) { // try at the beginning of partner user case
                system.debug('++++++++++++++++++'+e.getStackTraceString());
                this.WasUserCreated=false;
                this.Message='UNKNOWN EXCEPTION on upsert of partner user, contact a CRM system administrator '+e.getMessage();
                if (existing_user.isempty()&& this.PartnerContact.Id!=null){ //this means I was creating a NEW user and succeeded in creating the contact only. Now clean up!!
                    system.debug('+++++++++++Deleting contact record'+this.PartnerContact);
                    try {
                        delete this.PartnerContact;
                        system.debug('+++++++++++Partner contact deleted');
                    } catch (exception exceptionForContact) {
                        system.debug('+++++++++++Partner contact NOT deleted:'+exceptionForContact );
                    }
                }
                return;
            }
        } else {
            // create internal user
            this.CreateInternalUserInstance();
            
            List<user> existing_user = [select id from user where username=:this.userToCreate.username ]; // NOPMD  Fix CRUD violation
            system.debug('++++++++++++++++QUERY for EXISTING internal users'+existing_user );
            try {
                if (existing_user.isempty()){
                    //creating user
                    insert this.UserToCreate;
                    system.debug('++++++insert of internal user OK');

                    //Check if SSO permissionSet is required
                    if (checkSSO_PermissionSet(this.ProfileString, this.RoleString) ) {
                        assignSSO_PermissionSet(this.userToCreate.ID, this.SSOPermissionSetID);
                    }
                } else {
                    //updating user
                this.userToCreate.Id = existing_user.get(0).Id;
                    update this.userToCreate; // NOPMD  Fix CRUD violation
                    system.debug('+++++++++update of internal user OK');
                    
                    //Check if SSO permissionSet is required
                    if (checkSSO_PermissionSet(this.ProfileString, this.RoleString) ) {
                        assignSSO_PermissionSet(this.userToCreate.ID, this.SSOPermissionSetID);
                    }
                }
                this.Message = this.Message + ' Upsert of standard user succesful, ID(' + this.userToCreate.Id+')';
            } catch (exception e) { // try at the beginning of standard user
                system.debug('++++++++++++++++++'+e.getStackTraceString());
                this.WasUserCreated=false;
                this.Message='UNKNOWN EXCEPTION on upsert of standard user, contact a CRM system administrator '+e.getMessage();
                return;
            }
        }
        // system.debug('++++++++++forcingexception at the end');
        // integer force_exception = 0/0;
    }

                

    
    ////////////Auxiliary methods////////////
    // empty constructor 
    public UserProvisioningManagement() {
        system.debug('+++++++++++++++++++++++++++Empty constructor used for UserProvisioningManagement. DO NOT USE');
    } 
    
    // constructor accepting the user details input
    public UserProvisioningManagement(UserProvisioningAAI.UserDetailsInput UserD) {
        system.debug('+++++++++++++++++++++++++++Custom constructor used for UserProvisioningManagement');
        // use the passed details to store the user info
        this.UserDetailInput = UserD;
        this.Message = '';  
        this.AreUserInputsOK = true; //MUST be set true only here. All checks should but it to FALSE in case they fail
        this.WasUserCreated = true; //MUST be set true only here. All checks should but it to FALSE in case they fail
        this.userToCreate = new user(); 
        
        //Retriving the permission set ID for SSO in case it is necessary
        PermissionSet SSOPermissionSet = [SELECT ID from PermissionSet Where Name='SSO_Permission_Set' ]; // NOPMD  Fix CRUD violation
        this.SSOPermissionSetID = SSOPermissionSet.Id;
    }
    
    //check if the role and profile of the current user are present in the Custom setting
    public boolean checkSSO_PermissionSet(String ProfileName, String RoleName) {
        system.debug('++++checkSSO_PermissionSet FOR Profile'+ProfileName+' AND Role '+RoleName);
        List<SSO_Permission_Set_Assignment__c> config= [SELECT Profile__c, Role__c FROM SSO_Permission_Set_Assignment__c WHERE Role__c=:RoleName AND Profile__c =:ProfileName  limit 1]; // NOPMD  Fix CRUD violation
        system.debug('++++found this corresponding custom setting'+config);
        if (config.isempty()) {
            return false;
        } else {
            return true;
        }
    }
    
    public void assignSSO_PermissionSet(ID UserID, ID PermissionSetID) {
        PermissionSetAssignment psa = new PermissionSetAssignment (
            PermissionSetId = PermissionSetID, 
            AssigneeId = UserID);
        //Must check if the current user already has the permission set
        list<PermissionSetAssignment> currentAssignments = [select id from PermissionSetAssignment where PermissionSetId=:PermissionSetID AND AssigneeId=:UserID ]; // NOPMD  Fix CRUD violation
        system.debug('++++++found this assignment'+currentAssignments );
        if (currentAssignments.isempty()) {
            insert psa; // NOPMD  Fix CRUD violation 
        } else {
            system.debug('++++++SSO Assigment already present for current user');
        }
    }
    public static void assign_PermissionSetLicense(ID UserID,ID PermissionSetID) {
        //PermissionSetAssignment
        PermissionSetAssignment psa = new PermissionSetAssignment (
            PermissionSetId = PermissionSetID, 
            AssigneeId = UserID);
        list<PermissionSetAssignment> currentAssignments = [select id from PermissionSetAssignment where PermissionSetId=:PermissionSetID AND AssigneeId=:UserID ]; // NOPMD  Fix CRUD violation
        system.debug('++++++found this assignment'+currentAssignments );
        if (currentAssignments.isempty()) {
            try {
                
            } catch (Exception e) {
                System.debug('assign_PermissionSetLicense - Error: '+e.getMessage());
            }
            insert psa; // NOPMD  Fix CRUD violation 
        } else {
            system.debug('++++++SSO Assigment already present for current user');
        }
    }
    
    // GET methods for private attributes
    public boolean getAreUserInputsOK() {
        return this.AreUserInputsOK;
    }
    
    public boolean getWasUserCreated() {
        return this.WasUserCreated;
    }
    
    public Profile getProfile() {
        return this.UserProfile;
    }
    
    public UserRole getRoleID() {
        return this.Role;
    }
    
    // Validation Methods
    private void ValidateActiveFlag() {
         if (this.UserDetailInput.Active=='0') {
            this.userToCreate.isActive=true;
        } else {
            this.userToCreate.isActive=false;
        }
        system.debug('+++++++++++++++++++++++++++Active flag turned to boolean' + this.userToCreate.isActive);
    }
    
    private void ValidateIsPartnerUser() {
        //If an Agency code is provided it is a partner user
        if (String.isBlank(this.UserDetailInput.AgencyCode)) {
            this.isPartnerUser=false;
        } else {
            this.isPartnerUser=true;
        }
    }
    
    private void ValidateMainNode() {
        Map<String,String> MyriamToLongFormat= getLongNodesFormat(allNodesStrings);
        for (UserProvisioningAAI.UserNodeInput a: this.UserDetailInput.Nodes){
            if (a.AdminFlag) {
                this.UserToCreate.Main_Node__c=MyriamToLongFormat.get(a.NodeCode);
            }
        }
    }
    
    private void ValidateAdminFlag() {
        integer numberOfAdminFlags=0;
        for (UserProvisioningAAI.UserNodeInput a: this.UserDetailInput.Nodes){
            if (a.AdminFlag) {
                numberOfAdminFlags=numberOfAdminFlags+1;
                system.debug('+++++++thisnode.adminflag'+a.AdminFlag);
            }
        }
        if (numberOfAdminFlags!=1) {
            this.AreUserInputsOK=false;
            this.Message='The admin flag is not unique';
        }
        system.debug('+++++++++++++++++++++++++++Admin flag checked' + numberOfAdminFlags);
    }
    
    private list<string> getAllNodesStringsFromInput() {
        list<string> thisMethodResult = new list<string>();
        for (UserProvisioningAAI.UserNodeInput a: this.UserDetailInput.Nodes){
            thisMethodResult.add(a.NodeCode);
        }
        system.debug('+++++++++++++++++++++++++++List of Nodes String' + thisMethodResult);
        return thisMethodResult;
    }

    private void ValidateAllNodesStrings() {
        set<string> allUniqueNodes =new set<string>(this.allNodesStrings); //remove duplicates
        if (UserDetailInput.Nodes.Size()!=allUniqueNodes.size()) {
            this.AreUserInputsOK=false;
            this.Message=this.Message+'The user was profiled more than once for the same node';
        }
    }
    
    private void ValidateAllNodesStrings_field() {
        string NodesFieldString ='';
        for (Node__c a: this.allNodesEnabled ) {
            //NodesFieldString=NodesFieldString+a+';';//senza il nome del tree
            NodesFieldString=NodesFieldString+a.Group_name__c+';';//fatto a mano
        }
        this.userToCreate.Nodes__c=NodesFieldString.removeEnd(';');
    }
    
    public Map<String,Integer> getNodeLevelMap() {
        Map<String,Integer> thisMethodResult = new Map<String,Integer>();
        for (UserProvisioningAAI.UserNodeInput a: this.UserDetailInput.Nodes){
            thisMethodResult.put(a.NodeCode,a.NodeLevel);
        }
        system.debug('+++++++++++++++++++++++++++List of Nodes String' + thisMethodResult);
        return thisMethodResult;
    }
    
    private Map<String,String> getLongNodesFormat(List<String> allNodesStrings) {
        // given the list of nodes strings, returns a map with keys the nodes in Myriam form (4+5) and values the Long format (6+6)
        // If the node 777712345 is provided, then the corresponding long format is 007777012345
        
        Map<String,Integer> NodeLevelMap = this.getNodeLevelMap();
        
        Map<String,String> MyriamToLongFormat = new Map<String,String>();
        for (string thisNodeString : allNodesStrings) {
            //I need to change only the format of nodes with level 7-8-9
            if (NodeLevelMap.get(thisNodeString)>6) { //this means it is an agency node
                //Sort out agency codes that are shorter than 6 by padding with left zeros
                if (thisNodeString.length()<=6) { 
                    string stringToEdit=thisNodeString;
                    while (stringToEdit.length()<6) {
                        stringToEdit='0'+stringToEdit;
                    }
                    MyriamToLongFormat.put(thisNodeString,stringToEdit);
                } else {
                    //sort out subnodes that are shorter than 12 (and therefore longer than 6)
                    // I first take the rightmost 5 digits and add a zero
                    string SubnodeCode='0'+thisNodeString.right(5);
                    //then I take the remaining digits from the node and padd it with left zeros to obtain a string of 12 characters
                    string stringToEdit=thisNodeString.removeEnd(thisNodeString.right(5))+SubnodeCode;
                    while (stringToEdit.length()<12) {
                        stringToEdit='0'+stringToEdit;
                    }
                MyriamToLongFormat.put(thisNodeString,stringToEdit);
                }
            } else {// here I have nodes with level 1-6
                //simply keep the same key and value
                MyriamToLongFormat.put(thisNodeString,thisNodeString);
            }
            
        }
        return MyriamToLongFormat;
    }

    
    
    private void ValidateAllNodesEnabled() {
        // change the format of nodes to get correct results from query for agency users
        Map<String,String> MyriamToLongFormat = getLongNodesFormat(allNodesStrings);
        
        for (string thisNode : allNodesStrings ) {
            system.debug('+++++++Input node: '+thisNode);
            system.debug('+++++++Long format node: '+MyriamToLongFormat.get(thisNode));            
        }

        //Original Query without Myriam format
        //this.allNodesEnabled = [SELECT Id,Node_unique_code__c,Parent_node_unique_code__c,Group_name__c,Tree_name__c FROM Node__c WHERE Node_unique_code__c IN :this.allNodesStrings];
        this.allNodesEnabled = [SELECT Id,Node_unique_code__c,Parent_node_unique_code__c,Group_name__c,Tree_name__c FROM Node__c WHERE Node_unique_code__c IN :MyriamToLongFormat.values() ]; // NOPMD  Fix CRUD violation
        system.debug('+++++++looking for nodes'+MyriamToLongFormat.values());
        system.debug('++++found these nodes'+this.allNodesEnabled);
        if (allNodesEnabled.size()!=UserDetailInput.Nodes.size()) {
            this.AreUserInputsOK=false;
            integer missing_nodes=UserDetailInput.Nodes.size()-allNodesEnabled.size();
            this.Message=this.Message+'Could not find in the CRM database '+string.valueof(missing_nodes)+' of the '+string.valueof(UserDetailInput.Nodes.size())+' profiled nodes';
        }
    }
    
    private string getProfileStringFromInput() {
        string thisMethodResult = '';
        list<string> allProfileStrings = new list<string>();
        for (UserProvisioningAAI.UserNodeInput a: this.UserDetailInput.Nodes){
            allProfileStrings.add(a.Profile);
        }
        system.debug('+++++++++++++++++++++++++++List of Profiles String' + allProfileStrings);
        set<string> allUniqueProfiles =new set<string>(allProfileStrings);
        system.debug('+++++++++++++++++++++++++++SET of Profiles String' + allUniqueProfiles);
        
        if (allUniqueProfiles.size()!=1){
            this.Message=this.Message+'Could not find a single profile \n';
            this.AreUserInputsOK=false;
        } else {
            thisMethodResult=allProfileStrings.get(0);
        }
        return thisMethodResult;
    }
    
    private void ValidateProfileID() {
        List<Profile> SelectedProfile =   [SELECT Id,Name FROM Profile WHERE Name= :this.ProfileString ]; // NOPMD  Fix CRUD violation
        system.debug('++++++++++++++++++++++++++++++QUERY RESULT'+SelectedProfile);
        if (SelectedProfile.size()!=1) {
            this.Message=this.Message+'The profile provided does not match the profiles available \n';
            this.AreUserInputsOK=false;
        } else {
            this.UserProfile=selectedProfile.get(0);// profile read only
        }
    }
    
    public list<integer> getAllNodesLevelFromInput() {
        list<integer> thisMethodResult = new list<integer>();
        for (UserProvisioningAAI.UserNodeInput a: this.UserDetailInput.Nodes){
            thisMethodResult.add(a.NodeLevel);
        }
        system.debug('+++++++++++++++++++++++++++List of Nodes levels' + thisMethodResult);
        return thisMethodResult;
    }
    
    private string getRoleStringFromInput() {
        string thisMethodResult = '';
        list<string> allRoleStrings = new list<string>();
        for (UserProvisioningAAI.UserNodeInput a: this.UserDetailInput.Nodes){
            allRoleStrings.add(a.Functionality);
        }
        system.debug('+++++++++++++++++++++++++++List of ROLES String' + allRoleStrings);
        set<string> allUniqueRoles =new set<string>(allRoleStrings);
        system.debug('+++++++++++++++++++++++++++SET of ROLES String' + allRoleStrings);
        if (allUniqueRoles.size()!=1){
            this.Message=this.Message+'Could not find a single role \n';
            this.AreUserInputsOK=false;
        } else {
            thisMethodResult=allRoleStrings.get(0);
        }
        return thisMethodResult;
    }
    
    private void ValidateAgencyCode() {
        List<Node__c> resultQueryAgency = new List<Node__c>();
        
        //I must pad the agency code to get a 6 digit code
        string AgencycodeLong = this.UserDetailInput.AgencyCode;
        while (AgencycodeLong.length()<6) {
            AgencycodeLong='0'+AgencycodeLong;
        }
        
        system.debug('+++++++++++Input AgencyCode'+this.UserDetailInput.AgencyCode);
        system.debug('+++++++++++Long Format AgencyCode'+AgencycodeLong);
        
        //Old query without checking format
        //resultQueryAgency =  [SELECT Id,Node_unique_code__c,Node_description__c, Parent_node_unique_code__c,Group_name__c,Tree_name__c FROM Node__c WHERE Node_unique_code__c = :this.UserDetailInput.AgencyCode];
        resultQueryAgency =  [SELECT Id,Node_unique_code__c,Node_description__c, Parent_node_unique_code__c,Group_name__c,Tree_name__c FROM Node__c WHERE Node_unique_code__c = :AgencycodeLong ]; // NOPMD  Fix CRUD violation

        if (resultQueryAgency.size()!=1) {
            this.Message=this.Message+'Agency Node provided not correct or not found on the CRM';
            this.AreUserInputsOK=false;
        } else {
            this.AgencyNode = resultQueryAgency.get(0);
        }
    }
    
    private void ValidateAgencyAccountID() {
        List<Recordtype> AgencyRecordtype =[SELECT id, DeveloperName, SobjectType FROM RecordType WHERE SobjectType in ('Account','Contact') AND DeveloperName in ('Agency','Agency_Contact') ]; // NOPMD  Fix CRUD violation
        for (recordtype r :AgencyRecordtype) {
            if (r.DeveloperName=='Agency' && r.SobjectType=='Account') {
                        this.AgencyAccountRecordtype=r; //Account record type for agency
            } else if (r.DeveloperName=='Agency_Contact' && r.SobjectType=='Contact') {
                        this.AgencyContactRecordtype=r; //Account record type for agency
            }
        }
        system.debug('++++++++++++++++++QUERYRESULT recordtype' + AgencyRecordtype);
        List<Account> SelectedAgencyAccount = new List<Account>();
        SelectedAgencyAccount = [SELECT Id, Name, Agency_Code__c,OwnerId, isPartner FROM Account WHERE Agency_Code__c= :this.AgencyNode.Node_unique_code__c AND RecordTypeId=:this.AgencyAccountRecordtype.Id ]; // NOPMD  Fix CRUD violation
        system.debug('++++++++++++++++++QUERY RESULT Account ag'+SelectedAgencyAccount);
        if (SelectedAgencyAccount.isempty()) {
            this.AreUserInputsOK=false;
            this.Message=this.Message+'Agency account not found on the CRM';
        } else {
            this.AgencyAccount=SelectedAgencyAccount.get(0);
        }
    }
    
    // private void ValidateAgencyQueue() {
        // string ExpectedQueueName ='Coda Agenzia ' + this.AgencyNode.Node_unique_code__c;
        // List<Group> selectedQueues = [SELECT Id, Name, Type FROM Group WHERE Name = :ExpectedQueueName];
        // if (selectedQueues.isempty()) {
            // this.CreateAgencyQueueInstance();
        // } else {
            // this.AgencyQueue=selectedQueues.get(0);
        // }
    // }

    private void ValidateRolePartnerUser() {
        if (this.RoleString == 'Executive') {
            this.SFDC_PortalRole='Executive';
        }
        
        if (this.RoleString == 'Manager') {
            this.SFDC_PortalRole='Manager';
        }
        
        if (this.RoleString == 'User') {
            this.SFDC_PortalRole='Worker';
        }
        
        if (String.isblank(this.SFDC_PortalRole)) {
            this.Message=this.Message+'The role provided does not match the roles available for partner users\n';
            this.AreUserInputsOK=false;
            return;
        } //else {
            // if (this.AgencyAccount.isPartner) { //Agency already activated
                // List<UserRole> SelectedPartnerRole = new List<UserRole>();
                // SelectedPartnerRole = [SELECT Id, PortalAccountId, PortalRole FROM UserRole WHERE PortalRole = :this.SFDC_PortalRole AND PortalAccountId= :this.AgencyAccount.Id];
                // system.debug('++++++++++++++++++++QUERYRESULTPARTNERROLE'+SFDC_PortalRole+'++++++'+this.AgencyAccount.Id);
                // if (selectedPartnerRole.isempty()) {
                    // this.Message=this.Message+'The Role Provided does not match the roles availableQUERY \n';
                    // this.AreUserInputsOK=false;
                    // return;
                // } else {
                    // this.Role=SelectedPartnerRole.get(0);
                // }
            // } else {
                //Agency to activate, I can only pass the portal role
                // system.debug('++++++++++++the agency acc is not active, could not validate the id of the required role');
            // }
        // }
    }

    private void ValidateRoleInternalUser() {
        List<UserRole> SelectedRole =   [SELECT Id,Name FROM UserRole WHERE DeveloperName= :this.RoleString ]; // NOPMD  Fix CRUD violation
            system.debug('++++++++++++++++++++++++QUERY RESULT ROLES'+ SelectedRole);
            if (SelectedRole.isempty()) {
                this.Message=this.Message+'The role provided does not match the roles available for internal users';
                this.AreUserInputsOK=false;
            } else {
                this.Role=SelectedRole.get(0);
            }
    }
    
    private void CreateInternalUserInstance() {
        //just passing all details to the user instance
        this.userToCreate.FirstName=UserDetailInput.FirstName;
        this.ValidateActiveFlag(); //simply put active flag on the user
        this.userToCreate.LastName=UserDetailInput.LastName;
        this.userToCreate.Alias=this.userToCreate.FirstName.deleteWhitespace().left(1)+this.UserToCreate.LastName.deleteWhitespace().left(3);
        this.userToCreate.CommunityNickname=this.UserDetailInput.MyriamUserName.deleteWhitespace();
        this.userToCreate.FederationIdentifier=this.UserDetailInput.MyriamUserName.deleteWhitespace();//MOSCATELLI_M 19/12/2017: Accesso tramite SAML        
        this.userToCreate.ProfileId=this.UserProfile.Id;
        this.userToCreate.UserRoleId=this.Role.Id;
        this.userToCreate.Email=this.UserDetailInput.Email;
        this.userToCreate.Username=this.UserDetailInput.Username;
        this.userToCreate.LanguageLocaleKey = 'it';
        this.userToCreate.EmailEncodingKey = 'ISO-8859-1';
        this.userToCreate.TimeZoneSidKey = 'Europe/Rome';
        this.userToCreate.LocaleSidKey = 'it_IT';
        
        
        this.userToCreate.UserPermissionsMarketingUser = boolean.valueof(MARKETING_USER.containsKey(this.ProfileString) ? MARKETING_USER.get(this.ProfileString) : MARKETING_USER.get('Default'));
        system.debug('+++++++checkonmarketinguser+this.ProfileString'+this.ProfileString+'in the map found+MARKETING_USER.get(this.ProfileString)'+MARKETING_USER.get(this.ProfileString));
        this.userToCreate.UserPermissionsInteractionUser=FORCECOM_FLOW_USER;
        this.userToCreate.UserPreferencesHideS1BrowserUI=SALESFORCE1USER;
        this.userToCreate.UserPreferencesActivityRemindersPopup = REMINDER_POPUP_FLAG; //DB Send reminder default ON
        this.ValidateAllNodesStrings_field(); // simply put the nodes groups with ";" separator into correct field
        system.debug('+++++++++++++++++++++'+this.userToCreate);
    }
    
    private void CreatePartnerUserInstance() {
        //just passing all details to the user instance
        this.userToCreate.FirstName=UserDetailInput.FirstName;
        this.ValidateActiveFlag(); //simply put active flag on the user
        this.userToCreate.LastName=UserDetailInput.LastName;
        this.userToCreate.Alias=this.userToCreate.FirstName.deleteWhitespace().left(1)+this.UserToCreate.LastName.deleteWhitespace().left(3);
        this.userToCreate.CommunityNickname=this.UserDetailInput.MyriamUserName.deleteWhitespace();
        this.userToCreate.FederationIdentifier=this.UserDetailInput.MyriamUserName.deleteWhitespace();//MOSCATELLI_M 19/12/2017: Accesso tramite SAML                
        this.userToCreate.ProfileId=this.UserProfile.Id;
        // if (this.AgencyAccount.IsPartner) {
            // this.userToCreate.UserRoleId=this.Role.Id; //NOT DONE HERE as it works only for update of existing partner user but not for insert
        // }
        this.userToCreate.Email=this.UserDetailInput.Email;
        this.userToCreate.Username=this.UserDetailInput.Username;
        this.userToCreate.Agency_Code__c=this.AgencyNode.Node_unique_code__c;
        
        this.userToCreate.LanguageLocaleKey = 'it';
        this.userToCreate.EmailEncodingKey = 'ISO-8859-1';
        this.userToCreate.TimeZoneSidKey = 'Europe/Rome';
        this.userToCreate.LocaleSidKey = 'it_IT';
         
        this.userToCreate.UserPermissionsMarketingUser = boolean.valueof(MARKETING_USER.containsKey(this.ProfileString) ? MARKETING_USER.get(this.ProfileString) : MARKETING_USER.get('Default'));
        system.debug('+++++++checkonmarketinguser+this.ProfileString'+this.ProfileString+'in the map found+MARKETING_USER.get(this.ProfileString)'+MARKETING_USER.get(this.ProfileString));
        this.userToCreate.UserPermissionsInteractionUser=!FORCECOM_FLOW_USER;
        this.userToCreate.UserPreferencesHideS1BrowserUI=SALESFORCE1USER;
        this.userToCreate.UserPreferencesActivityRemindersPopup = REMINDER_POPUP_FLAG; //DB Send reminder default ON
        this.ValidateAllNodesStrings_field(); // simply put the nodes string with ";" separator into correct field
        
        
        system.debug('+++++++++++++++++++++'+this.userToCreate);
    }
    
    // private void CreateAgencyAccountInstance() { written when agency creation was together with user prov
        // Create Agency account
        // this.AgencyAccount=new Account();
        // this.AgencyAccount.Name=this.AgencyNode.Node_description__c;
        // this.AgencyAccount.Agency_Code__c=this.AgencyNode.Node_unique_code__c;
        // this.AgencyAccount.RecordtypeId=this.AgencyAccountRecordtype.Id;
        // this.AgencyAccount.IsPartner=true;
    // }
    

    
    private void CreatePartnerContactInstance() {
        this.PartnerContact = new contact();
        this.PartnerContact.LastName=this.UserToCreate.LastName;
        this.PartnerContact.FirstName=this.UserToCreate.FirstName;
        this.PartnerContact.AccountId=this.AgencyAccount.Id;
        this.PartnerContact.RecordTypeId=this.AgencyContactRecordtype.Id;
        this.PartnerContact.Email=this.UserToCreate.Email;
        this.PartnerContact.OwnerId=this.AgencyAccount.OwnerID;
        
        
    }
    public contact getPartnerContact(){
        return this.PartnerContact;
    }
    
    @future
    private static void UpdatePartnerRole(id userid, id AgencyAccountid, string PortalRole) {
        //Need to update the user with correct role
        User UserToUpdate = [SELECT id, PortalRole,Profile.name  FROM User WHERE id=:userid ]; // NOPMD  Fix CRUD violation
        system.debug('UpdatePartnerRole - UserToUpdate: '+UserToUpdate);
        
        system.debug('UpdatePartnerRole - PortalRole: '+PortalRole +'and Agencyaccid'+AgencyAccountid);
        UserRole RoleToUpdate = [SELECT Id FROM UserRole WHERE PortalRole = :PortalRole AND PortalAccountId= :AgencyAccountid ]; // NOPMD  Fix CRUD violation
        system.debug('UpdatePartnerRole - RoleToUpdate: '+RoleToUpdate);
        UserToUpdate.UserRoleId=RoleToUpdate.Id;
        update UserToUpdate;
        
        /*PermissionSetSetting__mdt[] psSett = [SELECT ProfileName1__c, ProfileName2__c, 	PermissionName__c FROM PermissionSetSetting__mdt];
		system.debug('UpdatePartnerRole - psSett: '+psSett);*/
        
        Boolean isNFE_Profile = false;
        Set<String> permName = new Set<String>();
        
        try{
            
            /*for(PermissionSetSetting__mdt pss : psSett){
                if(pss.ProfileName1__c.contains( UserToUpdate.Profile.name) || 
                   pss.ProfileName2__c.contains( UserToUpdate.Profile.name)){
                    isNFE_Profile = true;
                    permName.add(pss.PermissionName__c);
                }
            }
            system.debug('UpdatePartnerRole - isNFE_Profile: '+isNFE_Profile);
            system.debug('UpdatePartnerRole - permName: '+permName);
            
            // controlli del profilo per Analytics   
            if(isNFE_Profile){
                PermissionSet PermissionSetAnalytics = [SELECT ID from PermissionSet Where Name=: permName limit 1 ]; // NOPMD  Fix CRUD violation
                assign_PermissionSetLicense(userid,PermissionSetAnalytics.Id);
            }*/
        } catch (Exception e) {
            ApplicationLogHelper.ERROR('UserProvisioningManagement', e.getMessage(), e.getStackTraceString()); 
        }
    }
    
    @future
    private static void UpdatePartnerContact(id userid) {
        List<user> userInserted=new List<user>();
        userInserted = [SELECT ID, FirstName,LastName,Email,ContactId, Account.OwnerId FROM User Where id=:userid ]; // NOPMD  Fix CRUD violation
        
        contact contactToUpdate = new contact();        
        contactToUpdate.Id=userInserted.get(0).contactId;
        contactToUpdate.FirstName=userInserted.get(0).FirstName;
        contactToUpdate.LastName=userInserted.get(0).LastName;
        contactToUpdate.Email=userInserted.get(0).Email;
        contactToUpdate.OwnerID=userInserted.get(0).Account.OwnerId;
        
        update contactToUpdate;
    }
    
    //@future
    private static void UpdateAgencyAccountFlag(id AgencyId) {
        List<account> AgencyAccount= new List<Account>();
        AgencyAccount = [SELECT Id, ispartner, Active__c FROM Account where id=:AgencyId ]; // NOPMD  Fix CRUD violation
        
        if (AgencyAccount.get(0).isPartner) {
            AgencyAccount.get(0).Active__c=true;
            update AgencyAccount.get(0);
        } else {
            system.debug('++++++++++++++++++++++++++++++++UpdatingAgencyAacc. I created a new user but ispartner still false');
        }
    }
}