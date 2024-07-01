public class NodeManagement {
    //Class constants
    public static final boolean DOES_INCLUDE_BOSSES = true;
    
    //Class Attributes
    string Message;
    //Class Methods
    
    public List<groupMember> MapNodesToGroups(List<Node__c> NodesList) {
        
        
        //Getting all necessary groups
        Set<String> StringSetOfUniqueNodesWithParents = getStringsOfNodesWithParents(NodesList); //the resulting strings are the groups names
        
        //Creating all necessary groups
        Set<Group> SetOfAllGroups =new Set<Group>();
        SetOfAllGroups = insertAllGroupsNotExisting(StringSetOfUniqueNodesWithParents);//returning set of all groups (inserted and existing)
        
        
        Set<Group> SetOfChildGroups = new set<Group>();
        SetOfChildGroups = getChildGroups(NodesList, SetOfAllGroups);
        
        Map<string,id> MapNameToIdALLGroup =new Map<String,id>();
        MapNameToIdALLGroup = getMapNameToIdGroup(SetOfAllGroups);
        
        
        //Now that I have all the necessary Groups
        
        // now that all groups are created I can do all necessary inclusions
        SetOfChildGroups = getChildGroups(NodesList, SetOfAllGroups);
        
        Map<String,Id> MapNameToIdChildGroups = new map<String,id>();
        MapNameToIdChildGroups = getMapNameToIdGroup(SetOfChildGroups);
        system.debug('++++++++++++++++++++++++MapNameToIdChildGroups.values '+MapNameToIdChildGroups.Values());

        
        // first I disconnect all given nodes from their parents with a query
        // List<GroupMember> GroupMemberToBeDeleted = [SELECT id FROM GroupMember WHERE UserOrGroupId in:MapNameToIdChildGroups.Values()];
        List<GroupMember> GroupMemberToBeDeleted = [SELECT id, UserOrGroupId FROM GroupMember WHERE GroupId in:MapNameToIdChildGroups.Values() ]; // NOPMD  Fix CRUD violation
        system.debug('++++++++++++++++++++++++GM to be deleted'+GroupMemberToBeDeleted );
        
        List<Id> GroupMemberIdToBedeleted = new List<Id>();
        
        for (GroupMember a : GroupMemberToBeDeleted) {
            String elementId = a.UserOrGroupId;
            if(elementId != null && elementId.startsWith('00G'))
            GroupMemberIdToBedeleted.add(a.Id);
        }
        
        
        // delete GroupMemberToBeDeleted;
        //NodeManagement.DeleteOldConnectionsFuture(GroupMemberIdToBedeleted);
        
        List<GroupMember> AllGroupMembers =new List<GroupMember>();
        
        List<id> GroupsId = new List<Id>();
        for (group a: SetOfAllGroups) {
           GroupsId.add(a.id);
        }
        
                
        Set<id> NodesIdSet = new Set<Id>();
        for (Node__c a: NodesList) {
           NodesIdSet.add(a.id);
        }
        
        List<Id> NodesId = new List<Id>(NodesIdSet);
        
        NodeManagement.ConnectAllGroupsFuture(NodesId,GroupsId,GroupMemberIdToBedeleted );

        

        return AllGroupMembers;
        
    }
    
    public set<Group> getChildGroups(List<Node__c> ListN, Set<Group> GroupSet) {
        // given a list of nodes returns all the corresponding group instance found in the set of groups provided
        set<Group> ChildGroups = new set<Group>();
        
        for (Node__c thisnode : ListN) {
            for (Group thisgroup : GroupSet) {
                if (thisgroup.Name == thisnode.Tree_Name__c+'_'+thisnode.Node_unique_code__c) {
                    ChildGroups.add(thisgroup);
                }
            }
        }
        return ChildGroups;
        
    }
    
    public Map<String,Id> getMapNameToIdGroup(Set<Group> ListToMap) {
        Map<String,id> MapResult=new Map<string,id>();
        for (group a: ListToMap) {
            MapResult.put(a.Name,a.id);
        }
        return MapResult;
    }
    
    
    // public List<GroupMember> ConnectAllGroups(List<Node__c> ListN,Map<String,Id> MapNameToIdGroup) {
        // List<Node__c> ListNUnique=new List<Node__c>();
        // ListNUnique=checkNodesDuplicates(ListN);
        
        // Set<GroupMember> AllGroupMembers =new Set<GroupMember>();
        // for (Node__c a:ListNUnique) {
            // GroupMember thisGroupMember=new GroupMember();
            // thisGroupMember.GroupID=MapNameToIdGroup.get(a.Tree_Name__c+'_'+a.Parent_node_unique_code__c);
            // thisGroupMember.UserOrGroupId=MapNameToIdGroup.get(a.Tree_name__c+'_'+a.Node_unique_code__c);
            // AllGroupMembers.add(thisGroupMember);
        // }
        // insert new List<GroupMember>(AllGroupMembers);
        
        // return new List<GroupMember>(AllGroupMembers);
    // }
    
    /* @future
    public static void ConnectAllGroupsFuture(List<id> IdListOfNodes, List<id> IdListofGroups) {
        List<Node__c> Nodes = new List<Node__c>();
        Nodes = [SELECT Id, Tree_Name__c,Parent_node_unique_code__c,Node_unique_code__c FROM Node__c WHERE id in:IdListOfNodes];

        List<Group> Groups = new List<Group>();
        Groups = [SELECT Id, Name FROM Group WHERE id in:IdListofGroups];
        
        
        Map<String,Id> MapNameToIdGroup = new Map<String,Id>();
        for (group a: Groups) {
            MapNameToIdGroup.put(a.Name,a.id);
        }
        
        Set<GroupMember> AllGroupMembers =new Set<GroupMember>();
        for (Node__c a:Nodes) {
            GroupMember thisGroupMember=new GroupMember();
            // thisGroupMember.GroupID=MapNameToIdGroup.get(a.Tree_Name__c+'_'+a.Parent_node_unique_code__c);
            // thisGroupMember.UserOrGroupId=MapNameToIdGroup.get(a.Tree_name__c+'_'+a.Node_unique_code__c);

            thisGroupMember.UserOrGroupId=MapNameToIdGroup.get(a.Tree_Name__c+'_'+a.Parent_node_unique_code__c);
            thisGroupMember.GroupID=MapNameToIdGroup.get(a.Tree_name__c+'_'+a.Node_unique_code__c);
            AllGroupMembers.add(thisGroupMember);
        }
        insert new List<GroupMember>(AllGroupMembers);
        system.debug('+++++++++GM to be added'+AllGroupMembers);
        
        // return new List<GroupMember>(AllGroupMembers);
    } */
    
    
    @future
    public static void ConnectAllGroupsFuture(List<id> IdListOfNodes, List<id> IdListofGroups, List<Id> groupMemberIdToDelete) {
        List<GroupMember> GMToBeDeleted = new List<GroupMember>();
        GMToBeDeleted = [SELECT Id From GroupMember Where Id IN:groupMemberIdToDelete ]; // NOPMD  Fix CRUD violation
        delete GMToBeDeleted; // NOPMD  Fix CRUD violation
        system.debug('+++++++GM to be deleted'+ GMToBeDeleted);
        
        List<Node__c> Nodes = new List<Node__c>();
        Nodes = [SELECT Id, Tree_Name__c,Parent_node_unique_code__c,Node_unique_code__c FROM Node__c WHERE id in:IdListOfNodes ]; // NOPMD  Fix CRUD violation

        List<Group> Groups = new List<Group>();
        Groups = [SELECT Id, Name FROM Group WHERE id in:IdListofGroups ]; // NOPMD  Fix CRUD violation
        
        
        Map<String,Id> MapNameToIdGroup = new Map<String,Id>();
        for (group a: Groups) {
            MapNameToIdGroup.put(a.Name,a.id);
        }
        
        Set<GroupMember> AllGroupMembers =new Set<GroupMember>();
        for (Node__c a:Nodes) {
            GroupMember thisGroupMember=new GroupMember();
            // thisGroupMember.GroupID=MapNameToIdGroup.get(a.Tree_Name__c+'_'+a.Parent_node_unique_code__c);
            // thisGroupMember.UserOrGroupId=MapNameToIdGroup.get(a.Tree_name__c+'_'+a.Node_unique_code__c);

            thisGroupMember.UserOrGroupId=MapNameToIdGroup.get(a.Tree_Name__c+'_'+a.Parent_node_unique_code__c);
            thisGroupMember.GroupID=MapNameToIdGroup.get(a.Tree_name__c+'_'+a.Node_unique_code__c);
            AllGroupMembers.add(thisGroupMember);
        }
        insert new List<GroupMember>(AllGroupMembers);
        system.debug('+++++++++GM to be added'+AllGroupMembers);
        
        // return new List<GroupMember>(AllGroupMembers);
    }
    
    
    @future
    public static void DeleteOldConnectionsFuture(List<Id> groupMemberIdToDelete) {
        List<GroupMember> GMToBeDeleted = new List<GroupMember>();
        GMToBeDeleted = [SELECT Id From GroupMember Where Id IN:groupMemberIdToDelete ]; // NOPMD  Fix CRUD violation
        delete GMToBeDeleted; // NOPMD  Fix CRUD violation
        system.debug('+++++++GM to be deleted'+ GMToBeDeleted);
    }


    


    
    public Set<Group> insertAllGroupsNotExisting(Set<String> AllGroups) {
        
        //getting all existing groups (AS INSTANCE OF GROUPS WITH ID). 
        // I dont need to update as the only thing on the group object I can manage is the Name
        List<Group> GroupsToUpdate = new List<Group>();
        GroupsToUpdate = [SELECT Id, Name, OwnerId,Type FROM Group where Name in:AllGroups ]; // NOPMD  Fix CRUD violation
        
        //get list of strings of existing groups
        set<String> groupsExisting =new Set<String>();
        for (group a:GroupsToUpdate) {
            groupsExisting.add(a.Name);
        }
        
        //getting all groups that I have to insert (ALL strings provided minus the on existing)
        Set<String> GroupsToInsertString=AllGroups; // first copy all groups
        GroupsToInsertString.removeAll(groupsExisting); //then remove the existing
        
        // Creating instances for the new groups from the set of strings to insert
        Set<Group> GroupsToInsert =new set<Group>();
        
        for (string a:GroupsToInsertString) {
            group thisgroup=new group();
            thisgroup.Name=a;
            thisgroup.DoesIncludeBosses=DOES_INCLUDE_BOSSES;
            GroupsToInsert.add(thisgroup);
        }

        insert new List<Group>(GroupsToInsert);
        system.debug('++++++++Groups inserted GroupsToInsert'+GroupsToInsert);
        //must return a set
        Set<group> AllGroupsInstance = new Set<Group>();
        AllGroupsInstance.addAll(GroupsToUpdate);
        AllGroupsInstance.addAll(GroupsToInsert);
        return AllGroupsInstance; 
    }
    
    public Set<String> getStringsOfNodesWithParents(List<Node__c> ListN) {
        // return a list of nodes with all parents included
        
        List<Node__c> ListNUnique=new List<Node__c>();
        ListNUnique=checkNodesDuplicates(ListN);
        Set<String> NodesWithParentString =new Set<String>();
        
        for (Node__c a: ListNUnique) {// HERE I could Concatenate the TREE Name
            NodesWithParentString.add(a.Tree_Name__c+'_'+a.Parent_node_unique_code__c);
            NodesWithParentString.add(a.Tree_Name__c+'_'+a.Node_unique_code__c);
        }
        return NodesWithParentString;
        
    }
    
    public List<Node__c> checkNodesDuplicates(List<Node__c> ListToDeduplicate) {
        // return a list without duplicates
        set<Node__c> UniqueElementsInList = new set<Node__c>(ListToDeduplicate);
        if (UniqueElementsInList.size()!=ListToDeduplicate.size()) {
            integer difference=ListToDeduplicate.size()-UniqueElementsInList.size();
            this.Message=this.Message+'WARNING, ignored '+difference+' duplicates';
        }
        return new List<Node__c>(UniqueElementsInList);
    }

    //Start ID277 

    public void prepareBulkRequestProcess(List<Node__c> ListNd) {

    List<Bulk_Request__c> BRtoInsert = new List<Bulk_Request__c>();

    for (Node__c thisN : ListNd) {
        Bulk_Request__c thisBR = new Bulk_Request__c();
        thisBR.BulkRequestHandler__c = 'BulkRequest_BlackListProcess';

        BulkRequest_BlackListProcess BR_instance = new BulkRequest_BlackListProcess();

        BR_instance.listProcess = (thisN.Blacklist_Processi__c != null) ? thisN.Blacklist_Processi__c.split(';') : new string[0];
        BR_instance.DataModifica = thisN.Ultima_modifica_blacklist__c;

            if(thisN.Ultima_modifica_blacklist__c==null) {
                BR_instance.DateRequest = DateTime.Now();
                BR_instance.DataModifica = DateTime.Now(); 
            } else {
                BR_instance.DateRequest=thisN.Ultima_modifica_blacklist__c;
            }
        
        //BR_instance.Origin='NODI_RESET';

        thisBR.JsonInstance__c = JSON.serialize(BR_instance);

        thisBr.Node__c=thisN.id;

        thisBr.Query__c = 'SELECT Id, Blacklist_Processi__c, Ultima_modifica_blacklist__c ';

        if (thisN.Node_Unique_Code__c.length()>6) {
            thisBr.Query__c = thisBr.Query__c + 'FROM Account where AAI_Agency_Reference_Code__c=\''+thisN.Node_Unique_code__c.left(6)+'\' AND Nodes__c LIKE \'%'+thisN.Node_Unique_Code__c+'%\'';
        } else {
            thisBr.Query__c = thisBr.Query__c + 'FROM Account where AAI_Agency_Reference_Code__c=\''+thisN.Node_Unique_code__c.left(6)+'\' AND (Nodes__c = \''+thisN.Node_Unique_Code__c+'\' OR Nodes__c = \''+thisN.Node_Unique_Code__c+';\') ';
        }

        thisBR.Request_by__c = Userinfo.getUserId();
        thisBR.Status__c='SUBMITTED';

        thisBR.Submission_date__c = DateTime.Now();
        
        BRtoInsert.add(thisBR);
    }
    system.debug('prepared the following BR-->'+BRtoInsert );

    try{
        upsert BRtoInsert; // NOPMD  Fix CRUD violation
    } catch(Exception ex){
        System.debug(' ===> Error upsert node process: ' + ex.getMessage());
    }
}
    public void updateBlacklistfield(List<Node__c> ListNd){
        for (Node__c nd : ListNd){
            if(nd.Blacklist_Processi__c == null || !String.isNotBlank(nd.Blacklist_Processi__c)){
                nd.Blacklist_Processi__c = 'Rinnovi';
        }
    }
}

//END ID277 03/03/22

    public void prepareBulkRequestBroker(List<Node__c> newNodes, List<Node__c> oldNodes, String triggerType) {
        //this method, given a List of nodes with the blacklist broker flag and date populated insert the corresponding bulkRequest reocrds. one per each node

        List <Blacklist_Broker__mdt> blacklistBrokerSettings = [SELECT Intermediary_Type__c FROM Blacklist_Broker__mdt ]; // NOPMD  Fix CRUD violation
        List<String> brokerType = new List<String>();
        for(Blacklist_Broker__mdt b : blacklistBrokerSettings){
            brokerType.add(b.Intermediary_Type__c.toLowerCase());
        }

        System.debug(' ===> brokerType: ' + brokerType);

        List<Bulk_Request__c> BRtoInsert = new List<Bulk_Request__c>();

        Map<Id, Node__c> mapOldNodes = new Map<Id, Node__c>();
        if(oldNodes != null){
            mapOldNodes = new Map<Id, Node__c>(oldNodes);
        }

        for (Node__c thisN : newNodes) {
            Boolean addToSupportTable = true;
            Bulk_Request__c thisBR = new Bulk_Request__c();
            thisBR.BulkRequestHandler__c = 'BulkRequest_BlackList_Broker';
            //computing the json instance for the batch
            //remeber it will be tha batch to check account per account wheter to ovverride or not
            
            //this instance is the same as the handler 
            BulkRequest_BlackList_Broker BR_instance = new BulkRequest_BlackList_Broker();
            switch on triggerType{
                when 'insert', 'undelete'{
                    System.debug(' ===> Trigger insert/undelete');
                    System.debug(' ===> thisN: ' + thisN);
                    System.debug(' ===> thisN.Intermediary_type__c: ' + thisN.Intermediary_type__c);
                    if(thisN.Intermediary_type__c != null && brokerType.contains(thisN.Intermediary_type__c.toLowerCase())){
                        BR_instance.broker=true;
                    } /**else if(thisN.Intermediary_type__c != null && !brokerType.contains(thisN.Intermediary_type__c.toLowerCase())){
                        BR_instance.broker=false;
                    } **/ else {
                        addToSupportTable = false;
                    }
                }
                when 'delete'{
                    System.debug(' ===> Trigger delete');
                    BR_instance.broker = false;
                }
                when 'update'{
                    System.debug(' ===> Trigger update');
                    Node__c oldNode = mapOldNodes.get(thisN.Id);
                    if(thisN.Intermediary_type__c != null && oldNode.Intermediary_type__c != null && brokerType.contains(thisN.Intermediary_type__c.toLowerCase()) && !brokerType.contains(oldNode.Intermediary_type__c.toLowerCase())){
                        BR_instance.broker = true;
                    } else if(thisN.Intermediary_type__c != null && oldNode.Intermediary_type__c != null && !brokerType.contains(thisN.Intermediary_type__c.toLowerCase()) && brokerType.contains(oldNode.Intermediary_type__c.toLowerCase())){
                        BR_instance.broker = false;
                    } else {
                        addToSupportTable = false;
                    }
                }
            }

            if(addToSupportTable){
                thisBR.JsonInstance__c = JSON.serialize(BR_instance);
                if(!triggerType.equalsIgnoreCase('delete')){
                    thisBr.Node__c=thisN.id;
                }
                thisBr.Query__c = 'SELECT Id, BlackList_Broker__c, Nodes__c ';

                if (thisN.Node_level__c>7) {
                    //BOVOLENTA_D 25062018 removed active client filter State__c =\'Active Client\' AND 
                    thisBr.Query__c = thisBr.Query__c + 'FROM Account where AAI_Agency_Reference_Code__c=\''+thisN.Node_Unique_code__c.left(6)+'\' AND Nodes__c LIKE \'%'+thisN.Node_Unique_Code__c+'%\'';//looking for the specific subnode in the middle of the string
                } else {
                    thisBr.Query__c = thisBr.Query__c + 'FROM Account where AAI_Agency_Reference_Code__c=\''+thisN.Node_Unique_code__c.left(6)+'\' AND (Nodes__c = \''+thisN.Node_Unique_Code__c+'\' OR Nodes__c = \''+thisN.Node_Unique_Code__c+';\') ';//looking only for the agency code (also with ;)
                }
                
                thisBR.Request_by__c = Userinfo.getUserId();
                thisBR.Status__c='SUBMITTED';
                BRtoInsert.add(thisBR);
            }
        }
        system.debug('prepared the following BR-->'+BRtoInsert );
        
        try{
            upsert BRtoInsert; // NOPMD  Fix CRUD violation
        } catch(Exception ex){
            System.debug(' ===> Error upsert node broker: ' + ex.getMessage());
        }
        
    }
}