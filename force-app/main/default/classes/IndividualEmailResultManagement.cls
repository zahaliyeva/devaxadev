public class IndividualEmailResultManagement {
	public static void createCommunicationBounceEvents(List<et4ae5__IndividualEmailResult__c> resultsList){
        List<Customer_Communication_Bounce__e> communicationBounceEvents = new List<Customer_Communication_Bounce__e>();
		for (et4ae5__IndividualEmailResult__c res : resultsList){
            if(res.et4ae5__HardBounce__c){
                System.debug('===> Individual Email Result: ' + res);
                Customer_Communication_Bounce__e evt = new Customer_Communication_Bounce__e(
                    Account__c = res.et4ae5__Contact__r.AccountId,
                    Bounce_Contact__c = res.et4ae5__Contact__c,
                    Customer_Company__c = 'AAI',
                    NDG__c = res.Account_NDG__c,
                    Source_Process_ID__c = res.Id,
                    Source_Process__c = res.Name,
                    Source_System__c = 'Marketing Cloud',
                    Timestamp__c = res.et4ae5__DateBounced__c,
                    Type__c = 'Email');
                communicationBounceEvents.add(evt);
            }
        }

        List<Database.SaveResult> results = EventBus.publish(communicationBounceEvents);
        for (Database.SaveResult sr : results) {
            if (sr.isSuccess()) {
                System.debug('===> Successfully published event.');
            } 
            else {
                for (Database.Error err : sr.getErrors()) {
                    System.debug('===> Error returned: ' +
                    err.getStatusCode() +
                    ' - ' +
                    err.getMessage());
                }
            }
        }
	}

    public static void createEmailUnsubscribingEvents(List<et4ae5__IndividualEmailResult__c> resultsList){
        List<Customer_Email_Unsubscribing__e> emailUnsubscribingEvents = new List<Customer_Email_Unsubscribing__e>();
        for (et4ae5__IndividualEmailResult__c res : resultsList){
            if(res.et4ae5__DateUnsubscribed__c != null){
                Customer_Email_Unsubscribing__e evt = new Customer_Email_Unsubscribing__e(
                    Account__c = res.et4ae5__Contact__r.AccountId,
                    Customer_Company__c = 'AAI',
                    NDG__c = res.Account_NDG__c,
                    Source_Process__c = res.Name,
                    Source_System__c = 'Marketing Cloud',
                    Timestamp__c = res.et4ae5__DateUnsubscribed__c,
                    Unsubscribing_Contact__c = res.et4ae5__Contact__c);
                emailUnsubscribingEvents.add(evt);
            }
        }

        List<Database.SaveResult> results = EventBus.publish(emailUnsubscribingEvents);
        for (Database.SaveResult sr : results) {
            if (sr.isSuccess()) {
                System.debug('===> Successfully published event.');
            } 
            else {
                for (Database.Error err : sr.getErrors()) {
                    System.debug('===> Error returned: ' +
                    err.getStatusCode() +
                    ' - ' +
                    err.getMessage());
                }
            }
        }
    }

    @future
    public static void ShareWithFullAgency (set <Id> allEmailIds) {

        List<et4ae5__IndividualEmailResult__c> allEmails = [SELECT Lead_Agency_Code__c, Id FROM et4ae5__IndividualEmailResult__c WHERE Id IN :allEmailIds];
        ShareWithFullAgency(allEmails);
        /**
        List<Quotazione__c> allEmails = new List<Quotazione__c>();
        
        for (Id myID : allQuotIds) {
            Quotazione__c myQuot = [SELECT Agency_Code__c, Id FROM Quotazione__c WHERE Id =: myID];
            allEmails.add(myQuot);
        }
        
        ShareWithFullAgency(allEmails);
        **/
    }
    
    
    public static void ShareWithFullAgency (list<et4ae5__IndividualEmailResult__c> allEmails) {
        //given a list of Quotazione__c shares them with all the corresponding Agency if they are Agency Quotazione__c
        
        List<Id> IdEmail = new List<Id>();                 
        List<et4ae5__IndividualEmailResult__c> EmailsToShare = new List<et4ae5__IndividualEmailResult__c>();
        List<et4ae5__IndividualEmailResult__c> EmailsNoAgency = new List<et4ae5__IndividualEmailResult__c>();
        Map<ID,String> MapEmailsToNode = new Map<ID,String>();
        List<et4ae5__IndividualEmailResult__Share> SharetoDelete = new List<et4ae5__IndividualEmailResult__Share>();
        
        for (et4ae5__IndividualEmailResult__c thisEmail : allEmails) {
            if(thisEmail.Lead_Agency_Code__c == null){
                EmailsNoAgency.add(thisEmail); 
            }
            IdEmail.add(thisEmail.id);
            EmailsToShare.add(thisEmail);
            MapEmailsToNode.put(thisEmail.Id, thisEmail.Lead_Agency_Code__c);
        }
        
        /*if(EmailsNoAgency.size()>0){
            
            if(!(Test.isRunningTest())){
     
            update(EmailsNoAgency);
            
            }
        
        }*/
        
        SharetoDelete = [SELECT AccessLevel,Id,IsDeleted,LastModifiedById,LastModifiedDate,ParentId,RowCause,UserOrGroupId FROM et4ae5__IndividualEmailResult__Share WHERE ParentId IN: IdEmail AND RowCause = 'Manual'];
        delete(SharetoDelete);
        
        system.debug('+++++MapEmailsToNode'+MapEmailsToNode);
        
        //Retrieving All involved nodes
        List<String> AllGroupCodes = MapEmailsToNode.values() ;
        system.debug('++++++++AllGroupCodes'+AllGroupCodes);
        List<Node__c> Nodes7_AND_8 = [Select id, Node_unique_code__c, Parent_node_unique_code__c, Node_level__c FROM Node__c WHERE Node_unique_code__c IN :AllGroupCodes OR  Parent_node_unique_code__c IN :AllGroupCodes ];
        system.debug('++++++++Nodes7_AND_8'+Nodes7_AND_8);

        Map<String,set<String>> MapGrouptoNodes = new Map<String,set<String>>();
        
        Map<String,Node__c> NodesLV7 = new Map<String,Node__c>();
        Map<String,Node__c> NodesLV8 = new Map<String,Node__c>();
        Map<String,Node__c> NodesLV9 = new Map<String,Node__c>();
        
        for (Node__c thisNode: Nodes7_AND_8) {           
            Set<String> currentNodeList = new set<String>();     

            if (thisNode.Node_level__c==7) {
                if (MapGrouptoNodes.get(thisNode.Node_unique_code__c)!=null) {
                    currentNodeList =   MapGrouptoNodes.get(thisNode.Node_unique_code__c);
                }    
                NodesLV7.put(thisNode.Node_unique_code__c,thisNode);
                currentNodeList.add('DIF_'+thisNode.Node_unique_code__c);
                MapGrouptoNodes.put(thisNode.Node_unique_code__c,currentNodeList);
            }
            
            if (thisNode.Node_level__c==8) {
                NodesLV8.put(thisNode.Node_unique_code__c,thisNode);
                String AgencyNode = thisNode.Parent_node_unique_code__c;
                if (MapGrouptoNodes.get(AgencyNode)!=null) {
                    currentNodeList =   MapGrouptoNodes.get(AgencyNode);
                }    
                currentNodeList.add('DIF_'+thisNode.Node_unique_code__c);
                MapGrouptoNodes.put(AgencyNode,currentNodeList);
            }
        }
        system.debug('++++++++MapGrouptoNodes'+MapGrouptoNodes);

        
        List<Node__c> Nodes9 = [Select id, Node_unique_code__c, Parent_node_unique_code__c, Node_level__c FROM Node__c WHERE Parent_node_unique_code__c IN :NodesLV8.keyset()];

        for (Node__c thisNode : Nodes9) {
            NodesLV9.put(thisNode.Node_unique_code__c,thisNode);
            String ParentNodeName = thisNode.Parent_node_unique_code__c;
            Node__c ParentNode = NodesLV8.get(ParentNodeName);
            Set<String> currentNodeList = new set<String>();     
            if (ParentNode!=null) {
                String AgencyCode = ParentNode.Parent_node_unique_code__c;
        
                if (MapGrouptoNodes.get(AgencyCode)!=null) {
                    currentNodeList = MapGrouptoNodes.get(AgencyCode);
                }
                currentNodeList.add('DIF_'+thisNode.Node_unique_code__c);
                MapGrouptoNodes.put(AgencyCode,currentNodeList);
            }
        }

        //The corresponding groups
        set<String> All_Nodes_Name = new set<String>();
        for (string thisAgency : MapGrouptoNodes.keyset()) {
            All_Nodes_Name.addAll(MapGrouptoNodes.get(thisAgency));
        }
        
        List<Group> All_Groups= [SELECT Id, Name, DeveloperName FROM Group WHERE Name IN:All_Nodes_Name];
        
        Map<String, Id> GroupMap = new Map<String,Id>();
        for (group thisGroup : All_Groups) {
            GroupMap.put(thisGroup.DeveloperName, thisGroup.Id);
        }
        system.debug('++++++GroupMap'+GroupMap);
        //For performance preparing, given a Node string of level 7, the Ids of the groups below
        Map<String, set<Id>> MapAgencytoGroupIds = new Map<String, set<Id>>();
        for (string thisAgency :MapGrouptoNodes.keyset()) {
            system.debug('+++++thisAgency'+thisAgency);
            system.debug('+++++thenodes'+ MapGrouptoNodes.get(thisAgency));
            set<Id> CurrentSet = new set<Id>();
            for (string thisNode :MapGrouptoNodes.get(thisAgency) ) {
                string nodetofind = thisNode;
                Id CurrentGroupId = GroupMap.get(nodetofind);
                system.debug('++++++adding node '+thisNode + ' with ID  '+ CurrentGroupId);
                CurrentSet.add(CurrentGroupId);
                system.debug('++++++CurrentSet'+CurrentSet);
            }
            MapAgencytoGroupIds.put(thisAgency,CurrentSet);
        }
        
        system.debug('++++++++MapAgencytoGroupIds'+MapAgencytoGroupIds);
        
        //Computing for each Quotazione__c the set of groups it should be shared to
        Map<Id, set<Id>> MapEmailIDtoGroupID = new Map<Id, set<Id>>();
        
        for (et4ae5__IndividualEmailResult__c thisEmail : EmailsToShare) {
            //I get the nodes the current Quotazione__c Should be shared with 
            string CurrentAgencyNode = MapEmailsToNode.get(thisEmail.Id); //given the Quotazione__c ID finds the Agency Code
            set<Id> CurrentSet = MapAgencytoGroupIds.get(CurrentAgencyNode);            
            MapEmailIDtoGroupID.put(thisEmail.Id, CurrentSet);
        }
        system.debug('++++++++MapEmailIDtoGroupID'+MapEmailIDtoGroupID);

        
        //Computing current share status of all involved Quotazione__cs and groups
        List<et4ae5__IndividualEmailResult__Share> CurrentSharing = [SELECT AccessLevel, ParentId, Id, RowCause,UserOrGroupId FROM et4ae5__IndividualEmailResult__Share where ParentId IN:MapEmailsToNode.keyset() AND UserOrGroupId IN :GroupMap.values()];
        Map<Id,set<Id>> Email_ShareMap = new Map<Id,set<Id>>(); //Each Quotazione__c with the set  of id it is shared with
        
        for (et4ae5__IndividualEmailResult__Share thisCS : CurrentSharing) {
            set<Id> currentGroups =  new set<Id>();
            if (Email_ShareMap.get(thisCS.ParentId)!=null) {
                currentGroups= Email_ShareMap.get(thisCS.ParentId);
            }
            currentGroups.add(thisCS.UserOrGroupId);
            Email_ShareMap.put(thisCS.ParentId,currentGroups);
        }
                system.debug('++++++++Email_ShareMap'+Email_ShareMap);

        //Comparing the existing share with the desired one
        list<et4ae5__IndividualEmailResult__Share> ShareToInsert = new List<et4ae5__IndividualEmailResult__Share>();
        
        for (id thisGroupId : MapEmailIDtoGroupID.keyset()) {
            set<Id> currentGroupsShared = Email_ShareMap.get(thisGroupId);
            set<Id> GroupsToShare = MapEmailIDtoGroupID.get(thisGroupId);
            system.debug('+++++currentSharing'+currentGroupsShared);
            system.debug('+++++DesiredSharing'+GroupsToShare);
            if (currentGroupsShared!=null && GroupsToShare!=null) {
                GroupsToShare.removeAll(currentGroupsShared);
            }
            
            system.debug('++++++NecessarySharing'+GroupsToShare );
            if (GroupsToShare!=null) {
                for (id thisGroupId2: GroupsToShare) {
                    ShareToInsert.add(new et4ae5__IndividualEmailResult__Share(ParentId=thisGroupId, UserOrGroupId=thisGroupId2,AccessLevel='Read' ));
                }
            }

        }
        system.debug('++++++ShareToInsert'+ShareToInsert);
        if (!ShareToInsert.isempty()) {
            insert ShareToInsert;
            system.debug('++++sharing inserted correctly');
        } else {
            system.debug('++++no share inserted for the Quotazione__cs');
        }
    }
    public static void setAgencyCode(List<SObject> myLeads){
        
        system.debug('*************myLeads'+myLeads);
    
        List<Lead> Leads = (List<Lead>)myLeads;
        List<Id> IdLeads = new List<Id>();
        List <et4ae5__IndividualEmailResult__c> ListEmails = new List<et4ae5__IndividualEmailResult__c>();
        for(Lead l: Leads){
            IdLeads.add(l.Id); 
        }
        ListEmails = [SELECT Id, Lead_Agency_Code__c, et4ae5__Lead__c FROM et4ae5__IndividualEmailResult__c WHERE et4ae5__Lead__c IN: IdLeads];     
        
        Database.SaveResult[] srList = Database.update(ListEmails, false);
        system.debug('MY RESULT'+srList);    
    }     

}