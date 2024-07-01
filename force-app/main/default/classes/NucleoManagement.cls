/*------------------------------------------------------------------------
Author:        Dario Bovolenta
Company:       Deloitte
Class:         NucleoManagement
Description:   Trigger to change the available status of Nucleo_di_appartenenza__c members
               in a new Nucleo_di_appartenenza__c
History

 13/05/2016     Dario Bovolenta    
----------------------------------------------------------------------------*/

/**
 * @description PURE IT 22/05 - commentata la classe
 */
public class NucleoManagement 
{
 /**PURE IT
    public static void ShareWithFullAgency (list <Nucleo_di_appartenenza__c> allGroups) {
        //given a list of Nucleo_di_appartenenza__c shares them with all the corresponding Agency if they are Agency Nucleo_di_appartenenza__c
        
        //Selecting the Agnecy Nucleo_di_appartenenza__cs
      //  Recordtype AgencyRT = [SELECT Id, DeveloperName, SobjectType FROM RecordType Where DeveloperName='Agency_Nucleo_di_appartenenza__c' AND SobjectType='Nucleo_di_appartenenza__c' Limit 1];
        List<Nucleo_di_appartenenza__c> GroupToShare = new List<Nucleo_di_appartenenza__c>();
        Map<ID,String> MapGroupToNode = new Map<ID,String>();
        
        for (Nucleo_di_appartenenza__c thisGroup : allGroups) {
            GroupToShare.add(thisGroup);
            MapGroupToNode.put(thisGroup.Id, thisGroup.Agency_Code__c);
        }
        system.debug('+++++MapGroupToNode'+MapGroupToNode);
        
        //Retrieving All involved nodes
        List<String> AllGroupCodes = MapGroupToNode.values() ;
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
        
        //Computing for each Nucleo_di_appartenenza__c the set of groups it should be shared to
        Map<Id, set<Id>> MapNucleoIDtoGroupID = new Map<Id, set<Id>>();
        
        for (Nucleo_di_appartenenza__c thisGroup : GroupToShare) {
            //I get the nodes the current Campaing Should be shared with 
            string CurrentAgencyNode = MapGroupToNode.get(thisGroup.Id); //given the Nucleo_di_appartenenza__c ID finds the Agency Code
            set<Id> CurrentSet = MapAgencytoGroupIds.get(CurrentAgencyNode);            
            MapNucleoIDtoGroupID.put(thisGroup.Id, CurrentSet);
        }
        system.debug('++++++++MapNucleoIDtoGroupID'+MapNucleoIDtoGroupID);

        
        //Computing current share status of all involved Nucleo_di_appartenenza__cs and groups
        List<Nucleo_di_appartenenza__Share> CurrentSharing = [SELECT AccessLevel, ParentId, Id, RowCause,UserOrGroupId FROM Nucleo_di_appartenenza__Share where ParentId IN:MapGroupToNode.keyset() AND UserOrGroupId IN :GroupMap.values()];
        Map<Id,set<Id>> Nucleo_di_appartenenza_ShareMap = new Map<Id,set<Id>>(); //Each Nucleo_di_appartenenza__c with the set  of id it is hsared with
        
        for (Nucleo_di_appartenenza__Share thisCS : CurrentSharing) {
            set<Id> currentGroups =  new set<Id>();
            if (Nucleo_di_appartenenza_ShareMap.get(thisCS.ParentId)!=null) {
                currentGroups= Nucleo_di_appartenenza_ShareMap.get(thisCS.ParentId);
            }
            currentGroups.add(thisCS.UserOrGroupId);
            Nucleo_di_appartenenza_ShareMap.put(thisCS.ParentId,currentGroups);
        }
                system.debug('++++++++Nucleo_di_appartenenza_ShareMap'+Nucleo_di_appartenenza_ShareMap);

        //Comparing the existing share with the desired one
        list<Nucleo_di_appartenenza__Share> ShareToInsert = new List<Nucleo_di_appartenenza__Share>();
        
        for (id thisGroupId : MapNucleoIDtoGroupID.keyset()) {
            set<Id> currentGroupsShared = Nucleo_di_appartenenza_ShareMap.get(thisGroupId);
            set<Id> GroupsToShare = MapNucleoIDtoGroupID.get(thisGroupId);
            system.debug('+++++currentSharing'+currentGroupsShared);
            system.debug('+++++DesiredSharing'+GroupsToShare);
            if (currentGroupsShared!=null) {
                GroupsToShare.removeAll(currentGroupsShared);
            }
            
            system.debug('++++++NecessarySharing'+GroupsToShare );
            if (GroupsToShare!=null) {
                for (id thisGroupId2: GroupsToShare) {
                    ShareToInsert.add(new Nucleo_di_appartenenza__Share(ParentId=thisGroupId, UserOrGroupId=thisGroupId2,AccessLevel='Edit' ));
                }
            }

        }
        system.debug('++++++ShareToInsert'+ShareToInsert);
        if (!ShareToInsert.isempty()) {
            insert ShareToInsert;
            system.debug('++++sharing inserted correctly');
        } else {
            system.debug('++++no share inserted for the Nucleo_di_appartenenza__cs');
        }
    } 
/*
@future
    public static void reassingGroups(Set<id> myIds)
    {
        Id AXA_TECHNICAL_USER_ID = (AAI_Code_Variables__c.getAll()).get('AXA_TECHNICAL_USER_ID').Value__c != null ? (AAI_Code_Variables__c.getAll()).get('AXA_TECHNICAL_USER_ID').Value__c : UserInfo.getUserId();
        System.debug('°°°°°°°°destinationId'+AXA_TECHNICAL_USER_ID);
        List<Nucleo_di_appartenenza__c> rList = [SELECT Id, OwnerId FROM Nucleo_di_appartenenza__c Where Id IN :myIds];
        for (Nucleo_di_appartenenza__c groupElement :rList)
        {
            groupElement.ownerid = AXA_TECHNICAL_USER_ID;
        }
        update rList;
    }
*/    
}