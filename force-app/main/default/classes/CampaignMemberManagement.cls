/*------------------------------------------------------------------------
Author:        Dario Bovolenta
Company:       Deloitte
Class:         CampaignMemberManagement
Description:   Trigger to change the available status of campaign members
               in a new campaign
History

 06/07/2015     Dario Bovolenta  
 06/10/2016     Davide Fabris - Added Status for MArketing Campaigns 
----------------------------------------------------------------------------*/


public class CampaignMemberManagement 
{
    public static void ChangeDefaultStatus ( list <Campaign> newCampaigns) 
    {
        // for (Campaign c : newCampaigns)
        // {
             // system.debug('++++++++++++++++++'+c.id);
        // }
        Boolean NoCustom = false;//MOSCATELLI_M 05/07/2017: Bugfix_Blocco inserimento/esclusione clienti
        list<CampaignMemberStatus> newCMStatus = new list<CampaignMemberStatus>(); //list of campaign member status to be inserted
        list<CampaignMemberStatus> oldCMStatus = new list<CampaignMemberStatus>(); //list of campaign member status to be removed
        Set<Id> removeCampaignIDs = new Set<ID>(); //ids for the involved campaigns (used in the campaignmemberstatus table to identify the campaign)
        
        //USing Custom Metadata CM_default_status__mdt
        CM_default_status__mdt[] CMStatusList = [SELECT MasterLabel, QualifiedApiName,HasResponded__c,IsDefault__c,RT_Dev_Name__c,SortOrder__c,Status_Name__c FROM CM_default_status__mdt ];// NOPMD  Fix CRUD violation

        //Using Custom setting  CampaignMembStatus__c
        list<CampaignMembStatus__c> csList = new list<CampaignMembStatus__c>(); //custom settings table
        csList = CampaignMembStatus__c.getAll().Values(); //get all values from the table
                
        Map<Id,RecordType> campaignRecordTypeIdMap = new Map<Id,RecordType>();
        // 20161006 DF: Modified query to prevent filter on RT
        //campaignRecordTypeIdlist = [select RT.id
        //                from RecordType RT
        //                where RT.SobjectType = 'Campaign' and RT.DeveloperName in ('Agency_campaign','Performa_campaign') ];
        
        //consider extract the RT impacted from metadata
        campaignRecordTypeIdMap = new Map<Id,RecordType>([select id, DeveloperName from RecordType where SobjectType = 'Campaign' and isActive=true and RecordType.DeveloperName != :CampaignHandler.RECORD_TYPE_Informative_Campaign_PCC_MyAXA]);

        Set<Id> campaignRecordTypeId = campaignRecordTypeIdMap.keySet();
                
        for (Campaign cItem : newCampaigns)
        {
            if (campaignRecordTypeId.contains(cItem.RecordTypeId))
            {
                String CurrentCampaignType = campaignRecordTypeIdMap.get(cItem.RecordTypeId).DeveloperName;//MOSCATELLI_M 05/07/2017: Bugfix_Blocco inserimento/esclusione clienti
                removeCampaignIDs.add(cItem.id);  //id of the item

                //Adding status fom custom setting
                for(CampaignMembStatus__c csItem : csList){//field names from the salesforce field reference guide page 21 on summer 15  
          
                    //MOSCATELLI_M 05/07/2017: Bugfix_Blocco inserimento/esclusione clienti -- START                  
                    if(String.isNotBlank(csItem.Campaign_Record_Type__c))
                    {
                        for(String s : csItem.Campaign_Record_Type__c.split(';'))//added constraint on Campaign type
                        {
                            if(s == CurrentCampaignType)
                            {                               
                                newCMStatus.add (new CampaignMemberStatus( CampaignId = cItem.id,HasResponded = csItem.HasResponded__c, IsDefault = csItem.IsDefault__c, Label = csItem.Status_Name__c, 
                                SortOrder = integer.valueOf(csItem.SortOrder__c)));   //Sort order should not contain duplicates  :(1-2 are already used) so 3-4-5...
                            }
                        }
                    } 
                    //MOSCATELLI_M 05/07/2017: Bugfix_Blocco inserimento/esclusione clienti -- END
                }

                //MOSCATELLI_M 05/07/2017: Bugfix_Blocco inserimento/esclusione clienti -- START
                system.debug(newCMStatus.size());

                if(newCMStatus.isEmpty())
                    NoCustom = true;
                //MOSCATELLI_M 05/07/2017: Bugfix_Blocco inserimento/esclusione clienti -- END

                //Adding status from custom metadata
                for (CM_default_status__mdt thisStatus : CMStatusList) {
                    system.debug('thisStatus+++++'+thisStatus);
                    //Get the set of RT
                    List<String> tempRT_List = thisStatus.RT_Dev_Name__c.split(';');
                    Set<String> selectedRTforThisStatus = new set<String>(tempRT_List);
                    
                    system.debug('++++selectedRTforThisStatus+++'+selectedRTforThisStatus);
                    system.debug('++++campaignRecordTypeIdMap.get(cItem.RecordtypeId).DeveloperName)'+campaignRecordTypeIdMap.get(cItem.RecordtypeId).DeveloperName);
                    system.debug('++++++s'+selectedRTforThisStatus.contains(campaignRecordTypeIdMap.get(cItem.RecordtypeId).DeveloperName));
                    
                    if (selectedRTforThisStatus.contains(campaignRecordTypeIdMap.get(cItem.RecordtypeId).DeveloperName)) {
                        //add the status only if the RT of the campaign is specified
                        system.debug('+++adding thisStatus-->'+thisStatus);
                        newCMStatus.add (new CampaignMemberStatus( CampaignId = cItem.id,HasResponded = thisStatus.HasResponded__c, IsDefault = thisStatus.IsDefault__c, Label = thisStatus.Status_Name__c, SortOrder = integer.valueOf(thisStatus.SortOrder__c)));   //Sort order should not contain duplicates  :(1-2 are already used) so 3-4-5...
                    }
                }
            }
        }
                 
        //Retrieve all old campaign member status values to delete.
        oldCMStatus = [select cms.id
                        from CampaignMemberStatus cms
                        where cms.CampaignId in :removeCampaignIDs ]; // NOPMD  Fix CRUD violation
        //check that we are in the original status, with 
/*        integer oldCMStatusCount = [select count ()
                        from CampaignMemberStatus cms
                        where cms.CampaignId in :removeCampaignIDs 
                        and cms.Label in ('Inviato','Risposta')];
                        
        if (oldCMStatusCount==2)
        {*/
            insert newCMStatus;

            //MOSCATELLI_M 05/07/2017: Bugfix_Blocco inserimento/esclusione clienti -- START
            try
            {
                delete oldCMStatus;
            }
            catch(exception e)
            {
                if(NoCustom)
                    throw new CampaignMemberException('Impossibile creare la campagna, non risultano impostati stati per la stessa. Contattare l\'assistenza CRM AXA');
                else if(String.valueOf(e).contains('delete the selected campaign member status because it\'s the default'))
                    throw new CampaignMemberException('Impossibile creare la campagna, non risultano impostati stati di default per la stessa. Contattare l\'assistenza CRM AXA ');
                else
                    throw (e);
            }
            //MOSCATELLI_M 05/07/2017: Bugfix_Blocco inserimento/esclusione clienti -- END
       // }        
    }
    
    public class CampaignMemberException extends Exception {}//MOSCATELLI_M 05/07/2017: Bugfix_Blocco inserimento/esclusione clienti
    
    
    public static void stampDateStatusToAccount(List<CampaignMember> ListCM) {
        //given a list of campaign members stamp the date and status on the relative account on the correct date and status fields
        
        //get all campaigns id
        Set<Id> AllCampaignId = new Set<Id>();
        List<Id> AllCampaignMemberContactId = new List<Id>();
        for (CampaignMember thisCM : ListCM) {
            AllCampaignId.add(thisCM.CampaignId);
            AllCampaignMemberContactId.add(thisCM.ContactId);
        }
        system.debug('+++++++++AllCampaignId'+AllCampaignId);
        system.debug('+++++++++AllCampaignMemberContactId'+AllCampaignMemberContactId);
        
        // get all campaigns
        List<Campaign> AllCampaigns = new List<Campaign>();
        AllCampaigns = [SELECT Id, Type,Name FROM Campaign where Id IN :AllCampaignId];
        system.debug('+++++++++AllCampaigns '+AllCampaigns );

        // get all account id
        List<Account> AllAccount = new List<Account>();
        AllAccount = [SELECT Id, PersoncontactId from Account where PersoncontactId in:AllCampaignMemberContactId];
        system.debug('+++++++++AllAccount '+AllAccount );
        
        //get  map from personcontactid to accountid
        Map<Id,Id> MapPersoncontactIdToAccountId = new Map<Id,Id>();
        for (Account thisAcc : AllAccount) {
            MapPersoncontactIdToAccountId.put(thisAcc.PersoncontactId,thisAcc.Id);
        }
        system.debug('+++++++++MapPersoncontactIdToAccountId'+MapPersoncontactIdToAccountId);
        
    }
    
    public static void ShareWithFullAgency (list <Campaign> AllCampaigns) {
        //given a list of campaign shares them with all the corresponding Agency if they are Agency Campaign
        
        //Selecting the Agnecy Campaigns
        Recordtype AgencyRT = [SELECT Id, DeveloperName, SobjectType FROM RecordType Where DeveloperName='Agency_campaign' AND SobjectType='Campaign' Limit 1]; // NOPMD  Fix CRUD violation
        List<Campaign> CampaignToShare = new List<Campaign>();
        Map<ID,String> MapCampaignToNode = new Map<ID,String>();
        
        for (Campaign thisCampaign : AllCampaigns) {
            if (thisCampaign.RecordTypeId==AgencyRT.Id) {
                CampaignToShare.add(thisCampaign);
                MapCampaignToNode.put(thisCampaign.Id, thisCampaign.TECH_Agency_Code__c);
            }
        }
        system.debug('+++++MapCampaignToNode'+MapCampaignToNode);
        
        //Retrieving All involved nodes
        List<String> AllAgencyCodes = MapCampaignToNode.values() ;
        system.debug('++++++++AllAgencyCodes'+AllAgencyCodes);
        List<Node__c> Nodes7_AND_8 = [Select id, Node_unique_code__c, Parent_node_unique_code__c, Node_level__c FROM Node__c WHERE Node_unique_code__c IN :AllAgencyCodes OR  Parent_node_unique_code__c IN :AllAgencyCodes ]; // NOPMD  Fix CRUD violation
        system.debug('++++++++Nodes7_AND_8'+Nodes7_AND_8);

        Map<String,set<String>> MapAgencytoNodes = new Map<String,set<String>>();
        
        Map<String,Node__c> NodesLV7 = new Map<String,Node__c>();
        Map<String,Node__c> NodesLV8 = new Map<String,Node__c>();
        Map<String,Node__c> NodesLV9 = new Map<String,Node__c>();
        
        for (Node__c thisNode: Nodes7_AND_8) {           
            Set<String> currentNodeList = new set<String>();     

            if (thisNode.Node_level__c==7) {
                if (MapAgencytoNodes.get(thisNode.Node_unique_code__c)!=null) {
                    currentNodeList =   MapAgencytoNodes.get(thisNode.Node_unique_code__c);
                }    
                NodesLV7.put(thisNode.Node_unique_code__c,thisNode);
                currentNodeList.add('DIF_'+thisNode.Node_unique_code__c);
                MapAgencytoNodes.put(thisNode.Node_unique_code__c,currentNodeList);
            }
            
            if (thisNode.Node_level__c==8) {
                NodesLV8.put(thisNode.Node_unique_code__c,thisNode);
                String AgencyNode = thisNode.Parent_node_unique_code__c;
                if (MapAgencytoNodes.get(AgencyNode)!=null) {
                    currentNodeList =   MapAgencytoNodes.get(AgencyNode);
                }    
                currentNodeList.add('DIF_'+thisNode.Node_unique_code__c);
                MapAgencytoNodes.put(AgencyNode,currentNodeList);
            }
        }
        system.debug('++++++++MapAgencytoNodes'+MapAgencytoNodes);

        
        List<Node__c> Nodes9 = [Select id, Node_unique_code__c, Parent_node_unique_code__c, Node_level__c FROM Node__c WHERE Parent_node_unique_code__c IN :NodesLV8.keyset() ]; // NOPMD  Fix CRUD violation

        for (Node__c thisNode : Nodes9) {
            NodesLV9.put(thisNode.Node_unique_code__c,thisNode);
            String ParentNodeName = thisNode.Parent_node_unique_code__c;
            Node__c ParentNode = NodesLV8.get(ParentNodeName);
            Set<String> currentNodeList = new set<String>();     
            if (ParentNode!=null) {
                String AgencyCode = ParentNode.Parent_node_unique_code__c;
        
                if (MapAgencytoNodes.get(AgencyCode)!=null) {
                    currentNodeList = MapAgencytoNodes.get(AgencyCode);
                }
                currentNodeList.add('DIF_'+thisNode.Node_unique_code__c);
                MapAgencytoNodes.put(AgencyCode,currentNodeList);
            }
        }

        //The corresponding groups
        set<String> All_Nodes_Name = new set<String>();
        for (string thisAgency : MapAgencytoNodes.keyset()) {
            All_Nodes_Name.addAll(MapAgencytoNodes.get(thisAgency));
        }
        
        List<Group> All_Groups= [SELECT Id, Name, DeveloperName FROM Group WHERE Name IN:All_Nodes_Name ]; // NOPMD  Fix CRUD violation
        
        Map<String, Id> GroupMap = new Map<String,Id>();
        for (group thisGroup : All_Groups) {
            GroupMap.put(thisGroup.DeveloperName, thisGroup.Id);
        }
        system.debug('++++++GroupMap'+GroupMap);
        //For performance preparing, given a Node string of level 7, the Ids of the groups below
        Map<String, set<Id>> MapAgencytoGroupIds = new Map<String, set<Id>>();
        for (string thisAgency :MapAgencytoNodes.keyset()) {
            system.debug('+++++thisAgency'+thisAgency);
            system.debug('+++++thenodes'+ MapAgencytoNodes.get(thisAgency));
            set<Id> CurrentSet = new set<Id>();
            for (string thisNode :MapAgencytoNodes.get(thisAgency) ) {
                string nodetofind = thisNode;
                Id CurrentGroupId = GroupMap.get(nodetofind);
                system.debug('++++++adding node '+thisNode + ' with ID  '+ CurrentGroupId);
                CurrentSet.add(CurrentGroupId);
                system.debug('++++++CurrentSet'+CurrentSet);
            }
            MapAgencytoGroupIds.put(thisAgency,CurrentSet);
        }
        
        system.debug('++++++++MapAgencytoGroupIds'+MapAgencytoGroupIds);
        
        //Computing for each campaign the set of groups it should be shared to
        Map<Id, set<Id>> MapCampaignIDtoGroupID = new Map<Id, set<Id>>();
        
        for (Campaign thisCampaign : CampaignToShare) {
            //I get the nodes the current Campaing Should be shared with 
            string CurrentAgencyNode = MapCampaignToNode.get(thisCampaign.Id); //given the campaign ID finds the Agency Code
            set<Id> CurrentSet = MapAgencytoGroupIds.get(CurrentAgencyNode);            
            MapCampaignIDtoGroupID.put(thisCampaign.Id, CurrentSet);
        }
        system.debug('++++++++MapCampaignIDtoGroupID'+MapCampaignIDtoGroupID);

        
        //Computing current share status of all involved campaigns and groups
        List<CampaignShare> CurrentSharing = [SELECT CampaignAccessLevel, CampaignId, Id, RowCause,UserOrGroupId FROM CampaignShare where CampaignId IN:MapCampaignToNode.keyset() AND UserOrGroupId IN :GroupMap.values() ]; // NOPMD  Fix CRUD violation
        Map<Id,set<Id>> CampaignShareMap = new Map<Id,set<Id>>(); //Each Campaign with the set  of id it is hsared with
        
        for (CampaignShare thisCS : CurrentSharing) {
            set<Id> currentGroups =  new set<Id>();
            if (CampaignShareMap.get(thisCS.CampaignId)!=null) {
                currentGroups= CampaignShareMap.get(thisCS.CampaignId);
            }
            currentGroups.add(thisCS.UserOrGroupId);
            CampaignShareMap.put(thisCS.CampaignId,currentGroups);
        }
                system.debug('++++++++CampaignShareMap'+CampaignShareMap);

        //Comparing the existing share with the desired one
        list<CampaignShare> ShareToInsert = new List<CampaignShare>();
        
        for (id thiscampaignId : MapCampaignIDtoGroupID.keyset()) {
            set<Id> currentGroupsShared = CampaignShareMap.get(thiscampaignId);
            set<Id> GroupsToShare = MapCampaignIDtoGroupID.get(thiscampaignId);
            system.debug('+++++currentSharing'+currentGroupsShared);
            system.debug('+++++DesiredSharing'+GroupsToShare);
            if (currentGroupsShared!=null) {
                GroupsToShare.removeAll(currentGroupsShared);
            }
            
            system.debug('++++++NecessarySharing'+GroupsToShare );
            if (GroupsToShare!=null) {
                for (id thisGroupId: GroupsToShare) {
                    if(thisGroupId!=null)
                    ShareToInsert.add(new CampaignShare(CampaignId=thiscampaignId, UserOrGroupId=thisGroupId,CampaignAccessLevel='Read' ));
                }
            }

        }
        system.debug('++++++ShareToInsert'+ShareToInsert);
        if (!ShareToInsert.isempty()) {
            insert ShareToInsert; // NOPMD  Fix CRUD violation
            system.debug('++++sharing inserted correctly');
        } else {
            system.debug('++++no share inserted for the campaigns');
        }
    }
    
    
        //D.F. QuickEvo3 Trace the number of active Campaigns a client is partecipating to
                //Not Scalable, DSIMISSED
/*
    public static void traceActiveCampaignOnAccount ( list <Campaign> OldCampaigns, list <Campaign>NewCampaigns) {
        //I expect the OldCampaignList to be empty if it is not used (for example if you want to use this method after insert)
        
        ///////If an OLD LIST is provided I use the following logic
        // I need to trace only the campaigns that passed
        // form "ANYTHING but ongoing"-->Ongoing the CM will pre traced as (+1) on the Accounts
        // from Ongoing--> anything but ongoing (-1)
        
        
        ///////If an OLD LIST is NOT provided I use the following logic
        // Status==Ongoing then all CM will be traced as (+1) on the Accounts
        //Use with care as you may count campaigns twice
        
        Map<Id,Campaign> Map_Id_New_C = new Map<Id,Campaign>();
        Map<Id,Campaign> Map_Id_Old_C = new Map<Id,Campaign>();
        
                
        Map< Id, campaign> CampaignstoTrace_PlusOne = new  Map< Id, campaign>();
        Map< Id, campaign> CampaignstoTrace_MinusOne = new Map< Id, campaign>();
        
        if (NewCampaigns.size()==0) {
            system.debug('++++NO CAMPAIGNS PROVIDED');
            return;
        } else {
            for (campaign thiscampaign: NewCampaigns) {
                Map_Id_New_C.put(thiscampaign.id,thiscampaign);
            }
        }
        
        if (OldCampaigns.size()==0) {
            system.debug('++++NO  OLD CAMPAIGNS PROVIDED');
        } else {
            for (campaign thiscampaign: OldCampaigns) {
                Map_Id_Old_C.put(thiscampaign.id,thiscampaign);
            }
        }
        
        if (OldCampaigns.size()==0) { //I assume to be after insert
            for (campaign thiscampaign : NewCampaigns) {
                system.debug('++++++++thiscampaign'+ thiscampaign.id+'++++'+thiscampaign.status);
                if (thiscampaign.status=='On-going') {
                    CampaignstoTrace_PlusOne.put(thiscampaign.id,thiscampaign);
                }
            }
        } else { //I assume to be afterinsert and compare the two list of campaigns NEW/OLD
            for (campaign thiscampaignNew : NewCampaigns) {
                system.debug('++++++++thiscampaignNew'+ thiscampaignNew.id+'++++'+thiscampaignNew.status);
                campaign thiscampaignOld = Map_Id_Old_C.get(thiscampaignNew.Id);
                system.debug('++++++++thiscampaignOld'+ thiscampaignOld.id+'++++'+thiscampaignOld.status);
                if (thiscampaignNew.status=='On-going' && thiscampaignOld.status!='On-going') {
                    CampaignstoTrace_PlusOne.put(thiscampaignNew.id,thiscampaignNew);
                } else if (thiscampaignNew.status!='On-going' && thiscampaignOld.status=='On-going') {
                    CampaignstoTrace_MinusOne.put(thiscampaignNew.id,thiscampaignNew);
                } else {
                system.debug('++++++++thiscampaignNew NOT traced'+ thiscampaignNew.id+'++++'+thiscampaignNew.status);
                system.debug('++++++++thiscampaignOld NOT traced'+ thiscampaignOld.id+'++++'+thiscampaignOld.status);
                }
            }
        }
        

        system.debug('+++++++++CampaignstoTrace_MinusOne'+CampaignstoTrace_MinusOne.values());
        system.debug('+++++++++CampaignstoTrace_MinusOne SIZE'+CampaignstoTrace_MinusOne.size());

        system.debug('+++++++++CampaignstoTrace_PlusOne'+CampaignstoTrace_PlusOne.values());
        system.debug('+++++++++CampaignstoTrace_PlusOne SIZE'+CampaignstoTrace_PlusOne.size());
        
        //Now I need to retrieve all the campaignmembers
        // Case ADD ONE
        List<CampaignMember> ListCM_Plus_one = new List<CampaignMember>();
        ListCM_Plus_one = [SELECT Id,ContactId, Contact.AccountId, Contact.Account.Active_Campaigns__c From CampaignMember where CampaignId in:CampaignstoTrace_PlusOne.keyset()];
        Map<Id,Account> AllAccountToUpdate = new map<Id,Account>();
        
        for (campaignMember thisCM : ListCM_Plus_one) {
            system.debug('+++++thisCM'+thisCM);
            Account thisAcc= new Account(id=thisCM.Contact.AccountId);
            system.debug('++++thisAcc START'+thisAcc);
            if (AllAccountToUpdate.get(thisCM.Contact.AccountId)!=null) {//I already found the account in this transaction
                thisAcc=AllAccountToUpdate.get(thisCM.Contact.AccountId);
                system.debug('++++thisAcc FOUND'+thisAcc);
                thisAcc.Active_Campaigns__c+=1; //increment the number as it was already there
                system.debug('++++thisAcc Updated'+thisAcc);
            } else {
                system.debug('+++++thisCM.Contact.Account.Active_Campaigns__c'+thisCM.Contact.Account.Active_Campaigns__c);
                if (thisCM.Contact.Account.Active_Campaigns__c!=null) {
                thisAcc.Active_Campaigns__c=thisCM.Contact.Account.Active_Campaigns__c+1;
                } else { //treat the null option as 0
                    thisAcc.Active_Campaigns__c=1;
                }
            
                AllAccountToUpdate.put(thisAcc.Id,thisAcc);
            }
        }
        
        
        // Case MINUS ONE
        List<CampaignMember> ListCM_minus_one = new List<CampaignMember>();
        ListCM_minus_one = [SELECT Id,ContactId, contact.AccountId, Contact.Account.Active_Campaigns__c From CampaignMember where CampaignId in:CampaignstoTrace_MinusOne.keyset()];
        
        for (campaignMember thisCM : ListCM_minus_one) {
            Account thisAcc= new Account(id=thisCM.Contact.AccountId);
            if (AllAccountToUpdate.get(thisCM.Contact.AccountId)!=null) {//I already found the account in this transaction
                thisAcc=AllAccountToUpdate.get(thisCM.Contact.AccountId);
                thisAcc.Active_Campaigns__c-=1; //increment the number as it was already there
            } else {
                if (thisCM.Contact.Account.Active_Campaigns__c>0 && thisCM.Contact.Account.Active_Campaigns__c!=null) {
                    thisAcc.Active_Campaigns__c=thisCM.Contact.Account.Active_Campaigns__c-1;
                } else {
                    thisAcc.Active_Campaigns__c=0;
                }
                AllAccountToUpdate.put(thisAcc.Id,thisAcc);
            }
        }

        update AllAccountToUpdate.values();
    }
    
    
        //D.F. QuickEvo3 Trace the number of active Campaigns a client is partecipating to based on a list of CM
        //Not Scalable, DSIMISSED
//    public static void traceActiveCampaignOnAccount ( list <CampaignMember> allCM) {
        
        ///////If the CM are in a "on-going" campaign, they will be traced as a (+1) to the account
        // Meant to be used ONLY AFTER INSERT, to take into account CM added to an "on-going" campaign
        //Use with care as you may count campaigns twice (if used afterupdate)
        
        //I have to query for the accounts Id and other info on the parent object
/       List<id> allCMid = new List<Id>();
        for(campaignmember thisCM : allCM) {
            allCMid.add(thisCM.Id);
        }
        
        Map<id,campaignmember> allCM_Extended = new  Map<id,campaignmember>([SELECT Id,CampaignId, ContactId, Contact.AccountId, Contact.Account.Active_Campaigns__c from campaignmember where id in :allCM]);

        List<Id> allCampaignsId = new List<Id>();
        for (campaignmember thisCM :allCM_Extended.values()) {
            allCampaignsId.add(thisCM.campaignid);
        }
        system.debug('+++++allCampaignsId'+allCampaignsId);
        Map< Id, campaign> CampaignstoTrace_PlusOne = new Map<Id,Campaign>([SELECT id, status FROM Campaign where id in:allCampaignsId and status = 'On-going']); 

        system.debug('+++++++++CampaignstoTrace_PlusOne'+CampaignstoTrace_PlusOne.values());
        system.debug('+++++++++CampaignstoTrace_PlusOne SIZE'+CampaignstoTrace_PlusOne.size());
        
        //Now I need to retrieve all the campaignmembers
        // Case ADD ONE
        Map<Id,Account> AllAccountToUpdate = new map<Id,Account>();
        
        for (campaignMember thisCM : allCM_Extended.values()) {
            system.debug('+++++thisCM'+thisCM);
            Campaign thisCampaign = CampaignstoTrace_PlusOne.get(thisCM.campaignid);
            if (thiscampaign!=null){//it means I am adding a campaign member to a campaign that is already ongoing
                Account thisAcc= new Account(id=thisCM.Contact.AccountId);
                system.debug('++++thisAcc START'+thisAcc);
                if (AllAccountToUpdate.get(thisCM.Contact.AccountId)!=null) {//I already found the account in this transaction
                    thisAcc=AllAccountToUpdate.get(thisCM.Contact.AccountId);
                    system.debug('++++thisAcc FOUND'+thisAcc);
                    thisAcc.Active_Campaigns__c+=1; //increment the number as it was already there
                    system.debug('++++thisAcc Updated'+thisAcc);
                } else {
                    system.debug('+++++thisCM.Contact.Account.Active_Campaigns__c'+thisCM.Contact.Account.Active_Campaigns__c);
                    if (thisCM.Contact.Account.Active_Campaigns__c!=null) {
                    thisAcc.Active_Campaigns__c=thisCM.Contact.Account.Active_Campaigns__c+1;
                    } else { //treat the null option as 0
                        thisAcc.Active_Campaigns__c=1;
                    }
                
                    AllAccountToUpdate.put(thisAcc.Id,thisAcc);
                }
            }
        }
        update AllAccountToUpdate.values();
    }*/
    
    public static void createCommunicationBounceEvents (List<CampaignMember> cmList) {
        List<Customer_Communication_Bounce__e> emailBounceEvents = new List<Customer_Communication_Bounce__e>();

        List<Id> campaignIds = new List<Id>();
        for(CampaignMember cm : cmList){
            campaignIds.add(cm.CampaignId);
        }

        //Map<Id, Campaign> campaignList = new Map<Id, Campaign>([SELECT Name FROM Campaign WHERE Id IN :campaignIds]);

        for(CampaignMember cm : cmList){
            if(cm.Sottostato__c != null && (/*cm.Sottostato__c.equals('Email non recapitabile') ||*/
                cm.Sottostato__c.equals('SMS non recapitabile'))){
                String bounceType = cm.Sottostato__c.equals('Email non recapitabile') ? 'Email' : 'SMS';
                System.debug('===> Campaign Member: ' + cm);
                Customer_Communication_Bounce__e evt = new Customer_Communication_Bounce__e(
                    Account__c = '',
                    Bounce_Contact__c = cm.ContactId,
                    Customer_Company__c = 'AAI',
                    NDG__c = cm.Account_NDG__c,
                    Source_Process__c = cm.Campaign_Name__c,
                    Source_System__c = 'Marketing Cloud',
                    Timestamp__c = DateTime.newInstance(System.currentTimeMillis()),
                    Type__c = bounceType);
                emailBounceEvents.add(evt);
            }
        }

        List<Database.SaveResult> results = EventBus.publish(emailBounceEvents);
        System.debug('===> Platform event insert results: ' + results);
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
}