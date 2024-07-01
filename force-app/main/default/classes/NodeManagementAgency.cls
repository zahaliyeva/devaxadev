public class NodeManagementAgency {
    // Class constants
    public static final string TECH_COMPANY = 'AAI';
    public static final string QUEUE_SOBJECT_TYPE = 'Lead';
    public static final String QUEUE_SOBJECT_TYPE_CASE = 'Case';
    // Class Attributes
    public id AgencyRT;
    List<Account> ExistingAgencies;
    
    
    
    // Class Methods
    public NodeManagementAgency() {
        list<Recordtype> AgencyRT = new List<Recordtype>();
        AgencyRT = [SELECT Id FROM Recordtype Where Name = 'Agency'];
        this.AgencyRT = AgencyRT.get(0).Id;
        this.ExistingAgencies = new List<Account>();
    }
    

    public List<Account> UpsertAgencyAccounts(List<Node__c> ListN) {

        // now I create a list with all agency instances
        Set<Account> AllAgencies = new Set<Account>();
        AllAgencies = PrepareAgencyInstance(ListN);//check that ListN is of lv 7 is done inside the method


        // from the level 7 nodes I get the existing agencies (QUERY)
        this.ExistingAgencies = getExistingAgenciesAcc(ListN); //check that ListN is of lv 7 is done inside the method
        
        
        Set<Account> AgenciesToInsert = new Set<Account>(AllAgencies);// copy of the full list from which I remove the existing ones
        Set<Account> AgenciesToUpdate = new Set<Account>(); // Enmpty list of Agencies to update

        
        // for a given element of the full list, run over all existing accounts and find the one (if existing) that should be updated, or create a new Agency
        for (Account thisAgencyAccount: AllAgencies) {
            for (Account thisexistingAgencyaccount: this.ExistingAgencies) {
                if (thisAgencyAccount.Agency_Code__c == thisexistingAgencyaccount.Agency_Code__c) {
                    AgenciesToInsert.remove(thisAgencyAccount); //remove from the list of the one to Create
                    
                    thisAgencyAccount.Id=thisexistingAgencyaccount.Id;
                    AgenciesToUpdate.add(thisAgencyAccount);//add the existing agency to the list of the ones to update with correct id
                }
            }
        }
        
        system.debug('+++++++++++++++++++++++AgenciesToInsert'+AgenciesToInsert);
        system.debug('+++++++++++++++++++++++AgenciesToUpdate'+AgenciesToUpdate);

        // now I can proceed with the insert
        AccountHandler.setForceActivateTrigger(true);
        List<Account> AgenciesCreated = new List<Account>(AgenciesToInsert);
        insert AgenciesCreated;
        
        //and with the update 
        system.debug('+++++++++++++++++++++++AgenciesToUpdate'+AgenciesToUpdate);
        List<Account> AgenciesUpdated = new List<Account>(AgenciesToUpdate);
        system.debug('+++++++++++++++++++++++AgenciesUpdated'+AgenciesUpdated);
        update AgenciesUpdated;
        system.debug('+++++++++++++++++++++++AgenciesToInsert'+AgenciesToInsert);
        system.debug('+++++++++++++++++++++++AgenciesToUpdate'+AgenciesToUpdate);
        
        
        // I return the full list of created and existing agencies
        List<Account> AllAgenciesRecords = new List<Account>(AgenciesCreated);
        AllAgenciesRecords.addAll(AgenciesUpdated);
        
        List<Group> QueuesCreated = new List<group>();
        QueuesCreated=this.AssociateQueuesToAgencies(AllAgenciesRecords);
        
        
        //Update the list of existing agencies
        this.ExistingAgencies=AllAgenciesRecords;
        return AllAgenciesRecords;
    }
    
    public List<Group> AssociateQueuesToAgencies(List<Account> AccountList) {
        
        // now I can sort the queues
        List<String> QueuesNames = new List<String>();
        for (account a:AccountList) {
            string thisqueuename = 'Coda Agenzia '+ a.Agency_Code__c;
            QueuesNames.add(thisqueuename);
            //BOVOLENTA_D 06082018 ICF Case Queue
            String caseQueueName = 'Coda Agenzia Case '+a.Agency_Code__c;
            QueuesNames.add(caseQueueName);
            //BOVOLENTA_D 06082018 ICF Case Queue END
        }
        
        List<Group> AllExistingQueues =new List<Group>();
        AllExistingQueues = [SELECT Id, Name FROM group WHERE type='Queue' and Name IN:QueuesNames];

        //BOVOLENTA_D 06082018 creating a map name;group to speed up the search
        Map<String,Group> AllExistingQueuesMap = new Map<String,Group>(); 
        for (group thisExistingQueue : AllExistingQueues) {
            AllExistingQueuesMap.put(thisExistingQueue.Name,thisExistingQueue);
        }
        //BOVOLENTA_D END

        List<Group> queuesToBeCreated = new List <Group>();
        
        for (string thisqueue: QueuesNames) {
            boolean DoesthisQueueExist = false;

            //BOVOLENTA_D 06082018 ICF Case Queue - switched to maps for performance 
            Group thisExistingQueue = AllExistingQueuesMap.get(thisqueue);
            if(thisExistingQueue!= null && thisExistingQueue.Name==thisqueue)
            {
                DoesthisQueueExist = true;
            }
            else
            {
                group queuetobeadded = new group();
                queuetobeadded.Name = thisqueue;
                queuetobeadded.type='Queue';
                queuetobeadded.DoesSendEmailToMembers=true;
                queuesToBeCreated.add(queuetobeadded);
            }
            /*for (group thisExistingQueue : AllExistingQueues) {
                if (thisExistingQueue.Name==thisqueue) {
                    system.debug('+++++++++++++Confrontcheck+++++++Queue'+thisqueue+'++++++++Existing'+thisExistingQueue.Name);
                    DoesthisQueueExist = true;
                }
            }
            if (!DoesthisQueueExist) {
                group queuetobeadded = new group();
                queuetobeadded.Name = thisqueue;
                queuetobeadded.type='Queue';
                queuetobeadded.DoesSendEmailToMembers=true;
                queuesToBeCreated.add(queuetobeadded);
            }*/
            //BOVOLENTA_D END
        }
        
        
        system.debug('+++++++++++++++++++queuesToBeCreated'+queuesToBeCreated);
        //Now I can insert the queues
        insert queuesToBeCreated;
        system.debug('+++++++++++++++++++++queuesToBeCreated'+queuesToBeCreated);
        List<Id> QueuesCreatedIds=new List<Id>();
        for (group thisqueue:queuesToBeCreated) {
            QueuesCreatedIds.add(thisqueue.Id);
        }
        
        // now I put only the lead on the queues and the corresponding agency group as member of the queue
        if (QueuesCreatedIds.size()>0){
            NodeManagementAgency.FillQueueFuture(QueuesCreatedIds);
        }
        return queuesToBeCreated;
        
    }
    
    public Set<Account> PrepareAgencyInstance(List<Node__c> ListN) {
        List<Node__c> AgencyNodes = new List<Node__c>();
        AgencyNodes = getAgencyNodes(ListN);
        

        
        Set<Account> AgencyInstances = new set<Account>();
        for (Node__c thisnode : AgencyNodes) {
            Account thisagencyinstance = new Account();
            if (thisnode.Node_description__c=='' || thisnode.Node_description__c==null) {
                thisagencyinstance.Name=thisnode.Node_unique_code__c;
            } else {
                thisagencyinstance.Name=thisnode.Node_description__c;
            }
            thisagencyinstance.Agency_email__c=thisnode.Email__c;
            thisagencyinstance.Agency_Code__c=thisnode.Node_unique_code__c;
            thisagencyinstance.Agency_Holder__c=thisnode.Agency_holder__c;
            thisagencyinstance.RecordTypeId=this.AgencyRT;
            thisagencyinstance.TECH_Company__c=TECH_COMPANY;
            thisagencyinstance.Type=null;
            thisagencyinstance.Head_Office_Address__c=thisnode.Address__c+', '+thisnode.CAP__c;
            thisagencyinstance.Phone=thisnode.Phone__c;
            thisagencyinstance.OwnerId=AAI_Code_Variables__c.getInstance('AXA_TECHNICAL_USER_ID').Value__c;//I give the agency account in ownership to the tech user
            
            thisagencyinstance.Nodes__c=thisnode.Node_unique_code__c;
            //thisagencyinstance.Nodes__c = '';
            //thisagencyinstance.isHidden__c = true;    
            
            AgencyInstances.add(thisagencyinstance);
        }
        return AgencyInstances;
    }
    
    public List<Account> getExistingAgenciesAcc(List<Node__c> ListN) {
        if (0==0){
            //get the agency nodes
            List<Node__c> AgencyNodes = new List<Node__c>();
            AgencyNodes=getAgencyNodes(ListN);
            
            
            //get the list of agency codes
            set<String> Allagencycodes = new set<String>();
            for (Node__c a: AgencyNodes) {
                Allagencycodes.add(a.Node_unique_code__c);
            }
            
            // List<Account> ExistingAgencies = new List<Account>();
            
            this.ExistingAgencies = [SELECT Id,
                                Name,
                                Agency_email__c,
                                Active__c,
                                Agency_Code__c,
                                Agency_Holder__c,
                                IsPartner,
                                isHidden__c,
                                RecordTypeId,
                                TECH_Company__c FROM Account WHERE 
                                Agency_Code__c in:Allagencycodes AND TECH_Company__c=:TECH_COMPANY];
        }
        return this.ExistingAgencies;
    }
    
    public List<Node__c> getAgencyNodes(List<Node__c> ListN){
        
        List<Node__c> AgencyNodes = new List<Node__c>();
        
        for (Node__c a: ListN) {
            if(a.Node_level__c==7){
                AgencyNodes.add(a);
            }
        }
        
        return AgencyNodes;
    }
    
    
     public static Map<String,Id> getMapUniqueNameToIdAgencyAccount(List<Account> ListA) 
     {
        Set<String> agencyCodes = new Set<String>();
        List<Account> agencyAccount = new List<Account>();
        system.debug('++++++++++accounts that needs mapping'+ListA);
        Map<String,Id> mapUniqueNameIdAgency = new Map<String,Id>();
        for (Account a : ListA)
        {
            if (a.AAI_Agency_Reference_Code__c!= null) agencyCodes.add(a.AAI_Agency_Reference_Code__c); 
        }
        system.debug('+++++++++++++ agencyCodes:'+agencyCodes);
        if (agencyCodes.size()>0)
        {
            agencyAccount = [select id, Agency_Code__c  from Account where recordtype.name = 'Agency' and Agency_Code__c  in :agencyCodes ];
        }
        system.debug('+++++++++++++ agencyAccount:'+agencyAccount);
        for (Account a : agencyAccount)
        {
            mapUniqueNameIdAgency.put(a.Agency_Code__c , a.id);
        }
        system.debug('+++++++++++++ mapUniqueNameIdAgency:'+mapUniqueNameIdAgency);
        return mapUniqueNameIdAgency;
     }
    
    
    @future
    public static void FillQueueFuture(List<Id> QueuesId) {
        system.debug('++++QueuesId'+QueuesId);
         List<Group> QueuesToBeFilled = new List<Group>();
        QueuesToBeFilled = [SELECT Id,Name from Group where Id IN:QueuesId]; 
        system.debug('++++QueuesToBeFilled '+QueuesToBeFilled );
        //This was the logic to add the groups to the Qs
        //Not done anymore, otherwise all parent group receive email alerts.
        // The single agency users are included in the Q in provisioning (AddUsersToQsFuture)        
        
        /*List<String> DIF_names = new List<String>();
        
        for (group thisqueue: QueuesToBeFilled) {
            string tempstring = 'DIF_'+thisqueue.Name.remove('Coda Agenzia ');
            DIF_names.add(tempstring.deleteWhitespace());
        }
        system.debug('+++++++++++++++++++++DIF names from Q'+DIF_names);
        
        List<Group> DIF_Groups = new List<Group>();
        DIF_Groups = [SELECT Id,Name FROM Group where Name IN:DIF_names];
        system.debug('++++++++++++++++++++++++++++++DIF_Groups'+DIF_Groups);
        
        Map<String, Id> MapQnameToGroupId = new Map<String,Id>();
        
        for (group thisqueue: QueuesToBeFilled) {
            String thisDIFName = 'DIF_'+thisqueue.Name.remove('Coda Agenzia ');
            for (group thisDIFgroup: DIF_Groups) {
                if (thisDIFName.deleteWhitespace()==thisDIFgroup.Name) {
                    MapQnameToGroupId.put(thisqueue.Name,thisDIFgroup.Id);
                }
            }
        }*/
        
        List<SObject> ToBeAddedToQ = new List<SObject>();
        
        for (group thisqueue :QueuesToBeFilled) {
            //first i sort the Lead
            QueueSobject thisqsobject = new QueueSobject();
            thisqsobject.QueueId=thisqueue.Id;
            //BOVOLENTA_D 06082018 ICF Case queue
            String queueName = thisqueue.Name;
            if (!(queueName.containsIgnoreCase('case')))
            {
                thisqsobject.SobjectType=QUEUE_SOBJECT_TYPE;
            }
            else
            {
                thisqsobject.SobjectType=QUEUE_SOBJECT_TYPE_CASE;
            }
            ToBeAddedToQ.add(thisqsobject);
            //BOVOLENTA_D END

            //Not done anymore, otherwise all parent group receive email alerts.
            // The single agency users are included in the Q in provisioning (AddUsersToQsFuture)
            /*//then i include the relative group
            GroupMember thisGroupMember = new GroupMember();
            thisGroupMember.GroupId=thisqueue.Id;
            thisGroupMember.UserOrGroupId=MapQnameToGroupId.get(thisqueue.Name);
            //ToBeAddedToQ.add(thisGroupMember); */ 
        }
        system.debug('++++++++++++++++++++++++++ToBeAddedToQ'+ToBeAddedToQ);
        insert ToBeAddedToQ;
    } 
    
    
    /* public Map<String,Id> MapAgencyCodeToOwnerId(List<Node__c> ListN) {
        
        // given a list of nodes provides the map between the agency code and the owners found
        Map<String,Id> AllAgenciesMapped = new Map<String, Id>();
        
        //get the agency nodes
        List<Node__c> AgencyNodes = new List<Node__c>();
        AgencyNodes=getAgencyNodes(ListN);
        
        //this will be shrinking as I start finding the owners
        Set<Node__c> RemainingAgencyNodes = new Set<Node__c>(AgencyNodes);
        
        integer LevelToCheck=6; //I start looking for users on level 6
        while (LevelToCheck>1) { // I will check up to level 2, where the service user will be found
            // do checks for the ciurrent level starting from 6
            system.debug('++++++++++++++++++++checking users on level'+LevelToCheck);
            system.debug('++++++++++++++++++++I have to find the owner for '+RemainingAgencyNodes.size()+' Agencies');
            
            Map<String,Id> AgenciesMappedToUsersOnThisLevel = New Map<String,Id>();
            AgenciesMappedToUsersOnThisLevel = findAgencyOwners(RemainingAgencyNodes,LevelToCheck); 
            //returns the agencies that is possible to give in ownership to users on a given set of Roles end relative nodes
            
            // Add the found values to the total map
            AllAgenciesMapped.PutAll(AgenciesMappedToUsersOnThisLevel);
            
            //Remove the Agency Nodes that have been mapped from the remaining list;
            for (Node__c thisAgencyNode:AgencyNodes) {
                if (AllAgenciesMapped.containsKey(thisAgencyNode.Node_unique_code__c)) {
                    RemainingAgencyNodes.remove(thisAgencyNode);
                }
            }
            
            if (AllAgenciesMapped.size()!=AgencyNodes.size()) {
                //I have not found all owners
                LevelToCheck=LevelToCheck-1;
            } else {
                // I have found all owners, exit the while loop
                LevelToCheck=0;
            }
        }
        
        // final check before return
        if (AllAgenciesMapped.size()!=AgencyNodes.size()) {
            //I have not found all owners
            system.debug('++++++++++++++++++++++++++++COULD NOT FIND ALL OWNERS'+AllAgenciesMapped);
            return AllAgenciesMapped;
        } else {
            // I have found all owners, exit the while loop
            system.debug('++++++++++++++++++++++++++++ALL OWNERS found'+AllAgenciesMapped);
            return AllAgenciesMapped;
        }
    } */
}