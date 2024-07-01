public class UserManagement 
{
    
        public static void RefreshNodes ( list <User> nUsers) 
    {
        Set<String> groupInitial = new Set <String>();
        groupInitial.add('DIF_%');

        list<GroupMember> newGroupMember = new list<GroupMember>(); //list of group membership to be inserted
        list<GroupMember> oldGroupMember = new list<GroupMember>(); //list of group membership to be removed
        
        
        Set<Id> removeMembershipsId = new Set<ID>(); //ids for the involved users
        
        Map<Id,Set<String>> mapShare = new Map<Id,Set<String>>();
        Map<Id,Set<String>> mapRemove = new Map<Id,Set<String>>();
        
        Set<String> groupNames = new Set<String>();
                
        for (User uItem : nUsers) 
        {
            removeMembershipsId.add (uItem.id);
            Set<String> nameGroups = new Set<String>();
            if (uItem.Nodes__c!='' && uItem.Nodes__c!=null)
            {
                nameGroups.addAll(uItem.Nodes__c.split('\\;'));
                groupNames.addAll(uItem.Nodes__c.split('\\;'));
                
                if (!nameGroups.isEmpty()) //check that there is at least 1 node
                {
                    mapShare.put(uItem.Id, nameGroups); //metto id utente/set dei gruppi da aggiungere nella mappa  
                }
            }

        }
        List<GroupMember> rGroupIds = [SELECT GroupId FROM GroupMember where UserOrGroupId in :removeMembershipsId ]; // NOPMD  Fix CRUD violation
        Set<String> setString = new Set<String>();
        for (GroupMember sG : rGroupIds)
        {
            setString.add(sG.groupid);
        }
        //String searchPar = groupInitial+'%';
        List<Group> rGroupIdsDIF = [SELECT Id from group where Id in :setString and developername like :groupInitial ]; // NOPMD  Fix CRUD violation
        Set<Id> sGroupIdsDIF = (new Map<Id,Group>(rGroupIdsDIF)).keySet();
        oldGroupMember = [SELECT UserOrGroupId,GroupId FROM GroupMember where UserOrGroupId in :removeMembershipsId and GroupId in :sGroupIdsDIF ]; // NOPMD  Fix CRUD violation
        
        Map<String,Id> theGroupMap = getGroupNameWithId(groupNames);
        
        for (Id usId : mapShare.keySet()) 
        {
            Set<String> setGroups = mapShare.get(usId);
            for (String sG : setGroups)
            {
                if (theGroupMap.get(sG) != null) //to filter out invalid group names (they would have null Id)
                {
                    newGroupMember.add (new GroupMember(UserOrGroupId = usId,GroupId = theGroupMap.get(sG)));
                }
            }
        }
        
        
        //retrieve all the current group memberships
    //  String oldGroupsM ='select  GM.UserOrgroupId , Id,developername from group where Id in (SELECT GroupId FROM GroupMember GM where UserOrGroupId in :removeMembershipsId) and developername like \''&groupStartName&'%\' ';//Name, DeveloperName,
      //  String oldGroupsM ='SELECT Id FROM GroupMember where UserOrGroupId in :removeUsersId and GroupId in (select  Id from group where developername like \''&groupStartName&'%\' )' ;//Name, DeveloperName,00524000000R6ERAA0
     /*   set<GroupMember> newGM = new set <GroupMember> (newGroupMember);
        set<GroupMember> oldGM = new set <GroupMember> (oldGroupMember);
        
        set<GroupMember> oldMinusNew = new set<GroupMember>(oldGroupMember); 
        set<GroupMember> newMinusOld = new set<GroupMember>(newGroupMember); 
        
        for (GroupMember nGm : newGroupMember)
        {
            oldMinusNew.remove(nGm); //to be actually removed
        }   
        for (GroupMember oGm : oldGroupMember)
        {
            newMinusOld.remove(oGm); //to be actually inserted
        }       

        list<GroupMember> inGroupMember = new list<GroupMember>(newMinusOld); //list of group membership to be actually inserted
        list<GroupMember> outGroupMember = new list<GroupMember>(oldMinusNew); //list of group membership to be actually removed        
system.debug('+++++++outGroupMember'+outGroupMember);
system.debug('+++++++inGroupMember'+inGroupMember);

        if (outGroupMember.size()!=0) {delete outGroupMember;}      
        if (inGroupMember.size()!=0) {insert inGroupMember;}
        */
        
        
        
        set<GroupMember> oldMinusNew = new set<GroupMember>();
        oldMinusNew.addAll(oldGroupMember); 
        set<GroupMember> newMinusOld = new set<GroupMember>();
        newMinusOld.addAll(newGroupMember); 
        
        set<GroupMember> oldMinusNew2 = new set<GroupMember>();
        oldMinusNew2.addAll(oldGroupMember); 
        set<GroupMember> newMinusOld2 = new set<GroupMember>();
        newMinusOld2.addAll(newGroupMember); 
        
        system.debug('++++++++++oldMinusNew'+oldMinusNew);  
        system.debug('++++++++++newMinusOld'+newMinusOld); 
        
        for (GroupMember oSm : oldMinusNew)
        {
            for (GroupMember nSm : newMinusOld)
            {
                system.debug('++++++++++oSm'+oSm);  
                system.debug('++++++++++nSm'+nSm);
                if ((oSm.get('GroupId')==nSm.get('GroupId')) && (oSm.get('userorgroupid')==nSm.get('userorgroupid')) )
                {
                    oldMinusNew.remove(oSm); //to be actually removed
                    system.debug('++++++++++MatchRemoval ');
                }
            }
           
        }   
        for (GroupMember nSm : newMinusOld2)
        {
            for (GroupMember oSm : oldMinusNew2)
            {
                system.debug('++++++++++oSm'+oSm);  
                system.debug('++++++++++nSm'+nSm);
                if ((oSm.get('GroupId')==nSm.get('GroupId')) && (oSm.get('userorgroupid')==nSm.get('userorgroupid')) )
                {
                    newMinusOld.remove(nSm); //to be actually added
                    system.debug('++++++++++MatchInsert ');
                }
            }
           
        }       
        
    /*    for (GroupMember oSm : toDelete)
        {
            newMinusOld.remove(oSm); //to be actually inserted
        }  */     

        list<GroupMember> inShareMember = new list<GroupMember>(newMinusOld); //list of group sharing to be actually inserted
        list<GroupMember> outShareMember = new list<GroupMember>(oldMinusNew); //list of group sharing to be actually removed               
        system.debug('++++++++++inShareMember'+inShareMember);  
        system.debug('++++++++++outShareMember'+outShareMember);        
        if(inShareMember.size()>0)
        {
            insert inShareMember; // NOPMD  Fix CRUD violation
        }    
        if(outShareMember.size()>0)
        {
            delete outShareMember; // NOPMD  Fix CRUD violation
        }       
        
        
        
        
        
    }
    
    
    
    
    
    
    @future
    public static void RefreshNodesFuture ( list <id> nUsersid) 
    {
        list<User> nUsers = new list<user>();
        nUsers = [SELECT Id, Nodes__c from User where id in :nUsersid ]; // NOPMD  Fix CRUD violation

        UserManagement.RefreshNodes (nUsers) ;        
    }
    
    public static Map<String,Id> getGroupNameWithId(Set<String> groupNames){
    
        Map<String,Id> NameId_groups = new Map<String,Id>();
        List<Group> groups = [Select id, name,developername from group where developername in :groupNames ]; // NOPMD  Fix CRUD violation
        for (Group gi : groups){
            NameId_groups.put(gi.developername, gi.id);
        }
        return NameId_groups;
    }       
    
 @future
    public static void AddUsersToQsFuture (List<id> nUserId) {
        list<User> nUsers = new list<user>();
        nUsers = [SELECT Id, Nodes__c,Name, Agency_Code__c from User where id in :nUserId ]; // NOPMD  Fix CRUD violation
        UserManagement.AddUsersToQs (nUsers) ;        
    }


    public static void AddUsersToQs (List<User> nUser) {
        //Required fields for user Id, Nodes__c,Name, Agency_Code__c
     //   Map<Id,string> MapNewUserIdToQName = new Map<Id,String>(); //Map to store the Q info of a user provided. If the user is not profiled for the agency node an empty string will be used
        Map<Id,List<String>> MapNewUserIdToQNames = new Map<Id,List<String>>(); //BOVOLENTA_D 06082018 ICF Case Queue - List added to handle more queues for the same user
        List<String> UserNodeList = new List<String>(); //Set to store the nodes of the user
        Set<String> AllQsNamesSet = new Set<String>();
        for (user thisuser : nUser) {
            UserNodeList.clear(); //remove all nodes at the beginning
            string Nodes = thisuser.Nodes__c.remove('DIF_');
            UserNodeList = Nodes.split(';');
            system.debug('+++++ ('+thisuser.Id+') userNodes'+UserNodeList);
            Set<String > UserNodesSet = new set<String>(UserNodeList);
            AllQsNamesSet.add('Coda_Agenzia_'+thisuser.Agency_Code__c);
            AllQsNamesSet.add('Coda_Agenzia_Case_'+thisuser.Agency_Code__c);  //BOVOLENTA_D 06082018 ICF Case Queue
            if (UserNodesSet.contains(thisuser.Agency_Code__c) ) {
              //  MapNewUserIdToQName.put(thisuser.id, 'Coda_Agenzia_'+thisuser.Agency_Code__c);
                //BOVOLENTA_D 06082018 ICF Case Queue - List added to handle more queues for the same user
                List<String> tempQueueNames = new List<String>();
                tempQueueNames.add('Coda_Agenzia_'+thisuser.Agency_Code__c);
                tempQueueNames.add('Coda_Agenzia_Case_'+thisuser.Agency_Code__c);
                MapNewUserIdToQNames.put(thisuser.id, tempQueueNames);
                //BOVOLENTA_D END
            } else {
             //   MapNewUserIdToQName.put(thisuser.id, ''); //the user should not be added to the lead Q
                //BOVOLENTA_D 06082018 ICF Case Queue - List added to handle more queues for the same user
                MapNewUserIdToQNames.put(thisuser.id, null);
            }
        }
        
       // system.debug('++++MapNewUserIdToQName'+MapNewUserIdToQName); //BOVOLENTA_D Variable  removed
        system.debug('++++AllQsNamesSet '+AllQsNamesSet );
        system.debug('++++MapNewUserIdToQNames'+MapNewUserIdToQNames);

        List<Group> AllQsList = [Select Id, DeveloperName from group where type='Queue' and DeveloperName IN:AllQsNamesSet ];// NOPMD  Fix CRUD violation,Get All Qs considered in this transaction 
        Map<Id, Group> AllQs = new Map<Id,Group>(AllQsList);
        Map<String, Id > AllQsNames = new Map<String, Id>(); //Map to creat new GM
        
        for (group thisgroup : AllQs.values()) {
            AllQsNames.put(thisgroup.DeveloperName,thisgroup.id);
        }
        
        List<GroupMember> All_Prev_GMembersList = [Select Id, GroupId,Group.DeveloperName, UserOrGroupId from GroupMember where GroupId IN:AllQs.keyset() ];// NOPMD  Fix CRUD violation, get all members related to this transaction (same user or same Q) 
        Map <Id, GroupMember> All_Prev_GMembers = new Map<Id,GroupMember>(All_Prev_GMembersList);
        system.debug('+++++All_Prev_GMembersList '+All_Prev_GMembersList );
        //Map<Id, Id> MapPrevUserIdToGMId = new Map<Id,Id> (); //Map to retrieve the GM to delete

        Map<Id, List<GroupMember>> MapPrevUserIdToGMs = new Map<Id,List<GroupMember>> (); //BOVOLENTA_D 07082018 ICF Case Queue - Map to retrieve the GM to delete

        for (GroupMember thisGM : All_Prev_GMembers.values()) {
            //MapPrevUserIdToGMId.put(thisGM.UserOrGroupId, thisGM.Id); //BOVOLENTA_D  REMOVED
            List<GroupMember> newGMlist = new List<GroupMember>();
            List<GroupMember> retrievedGMlist = MapPrevUserIdToGMs.get(thisGM.UserOrGroupId);
            if(retrievedGMlist!= null)
            {
                newGMlist = retrievedGMlist;
            }
            newGMlist.add(thisGM);
            MapPrevUserIdToGMs.put(thisGM.UserOrGroupId,newGMlist);
        }
        
        /*//BOVOLENTA_D 07082018 CHECK REMOVED AS IT IS POINTLESS NOW
        if (All_Prev_GMembers.keyset().size()!=MapPrevUserIdToGMId.keyset().size()) {
            system.debug('++++++WARNING, A USER/GROUP WAS IN TWO DIFFERENT Qs+++++++++++');
            system.debug('++++All_Prev_GMembers'+All_Prev_GMembers);
            system.debug('++++MapPrevUserIdToGMId'+MapPrevUserIdToGMId);
        }*/
        
        //prepare list for update
        Set<GroupMember> GmToBeRemoved = new set<GroupMember>();
        Set<GroupMember> GmToBeAdded = new set<GroupMember>();
        
        for (user thisuser : nUser) {
            if (MapNewUserIdToQNames.get(thisuser.Id)==null) {// the user should not be in any Q as it is not profiled for the agency node
                if (MapPrevUserIdToGMs.containsKey(thisuser.id)) {// the user that should not be in any Q was previously in a Q
                
                    GmToBeRemoved.addAll(MapPrevUserIdToGMs.get(thisuser.id));// retrieve the GM id and return the object
                    system.debug('+++++ this user ('+thisuser.id+') was in Q' +MapPrevUserIdToGMs.get(thisuser.id));
                    system.debug('++++++this user ('+thisuser.id+') is now profiled only for'+thisuser.Nodes__c);
                    system.debug('+++++this user ('+thisuser.id+') is going to be removed from the Q');
                } else {
                    system.debug('+++++ thisuser ('+thisuser.Name+') left untouched as it was not in the Q before, or now'+ thisuser.Nodes__c);
                }
            } else { // the user should be in a QName
                if(MapPrevUserIdToGMs.containsKey(thisuser.id) && (MapPrevUserIdToGMs.get(thisuser.id).size()>=2)) {// the user that should be in a Q was already in a Q. Should be already OK
                    system.debug('+++++ this user ('+thisuser.id+') was in Q'+MapPrevUserIdToGMs.get(thisuser.id));
                    system.debug('++++++this user  ('+thisuser.id+') is now profiled only for'+thisuser.Nodes__c);
                    system.debug('+++++this user  ('+thisuser.id+') is already OK');
                } 
                //BOVOLENTA_D 07082018 ICF Case Queue 
                else// if (MapPrevUserIdToGMs.containsKey(thisuser.id) && ((MapPrevUserIdToGMs.get(thisuser.id).size()<2)||MapPrevUserIdToGMs.containsKey(thisuser.id)))
                {
                    List<GroupMember> retrievedGMlist = MapPrevUserIdToGMs.get(thisuser.id);
                    Map<String,GroupMember> MapNameToGm = new Map<String,GroupMember>();
                    if ( retrievedGMlist != null)
                    {
                        for (GroupMember thisGM : retrievedGMlist)
                        {
                            MapNameToGm.put(thisGM.Group.DeveloperName,thisGM);
                        }
                    }
                    if (!MapNameToGm.containsKey('Coda_Agenzia_'+thisuser.Agency_Code__c))
                    {
                        GmToBeAdded.add(new GroupMember(
                        GroupId=AllQsNames.get('Coda_Agenzia_'+thisuser.Agency_Code__c),
                        UserOrGroupId= thisuser.id)
                        );                       
                    }
                    if (!MapNameToGm.containsKey('Coda_Agenzia_Case_'+thisuser.Agency_Code__c))
                    {
                        GmToBeAdded.add(new GroupMember(
                        GroupId=AllQsNames.get('Coda_Agenzia_Case_'+thisuser.Agency_Code__c),
                        UserOrGroupId= thisuser.id)
                        );                       
                    }
                }
                /*
                 else { // the user must be added to the Q;
                    system.debug('++++++this user ('+thisuser.id+') is now profiled for'+thisuser.Nodes__c);
                    system.debug('++++++therefore I am going to add  ('+thisuser.id+') to the Q '+AllQsNames.get('Coda_Agenzia_'+thisuser.Agency_Code__c));
                    GmToBeAdded.add(new GroupMember(
                    GroupId=AllQsNames.get('Coda_Agenzia_'+thisuser.Agency_Code__c),
                    UserOrGroupId= thisuser.id)
                    ); 
                } */
            }   //BOVOLENTA_D 07082018 ICF Case Queue END
        } // end of for loop for user provided
        
        system.debug('++according to the checks i should add '+GmToBeAdded.size()+' GM and remove '+GmToBeRemoved.size()+' GM');
        if (GmToBeAdded.size()>0){
            //system.debug('++++ I am going to create the followinf GM'+ GmToBeAdded);
            //insert new List<Groupmember>(GmToBeAdded);
            QueueableUser queueClass = new QueueableUser(GmToBeAdded);
            Integer minutes = 2;
            Id jobId = System.enqueueJob(queueClass,minutes);
        }
        
        if (GmToBeRemoved.size()>0) {
            system.debug('++++ I am going to delete de following GM'+GmToBeRemoved);
            delete new List<Groupmember>(GmToBeRemoved);
        }
    }
    /*
    //MOSCATELLI_M 02/08/2018: Nuovo Modello di assistenza -- START
    @future
    public static void assignHDUserToQueue(Set<String> MapHDUserToQueue)
    {
        List<Groupmember> HDGroupmember = new List<Groupmember>();
        Map<String,String> MapUserToQueue = new Map<String,String>();
        Set<String> HDQueuesDeveloperNames = new Set<String>();
        //Map<String,GroupMember> RemoveMemberMap = new  Map<String,GroupMember>();
        //Map<String,String> RemoveMemberMap_1 = new  Map<String,String>();
        Set<String> RemoveMemberSet = new Set<String>();
        List<String> RemoveMemberList = new List<String>();
        Map<String,String> UserTypeMap = new Map<String,String>();

        String OldUserId ='';
        String NewUserId ='';
        String UserId;
        String UserType ='';
        String UserQueues ='';
        String MemberId='';
        String ProvisioningQueues ='';

        for(String s: MapHDUserToQueue)
        {
            NewUserId = s.substringbefore('$');

            if(NewUserId<>OldUserId)
            {
               UserId =  s.substringbefore('$');
               UserType = s.substringafterlast('$');
            }

            if(!MapUserToQueue.containsKey(UserId))   
                MapUserToQueue.put(UserId,(s.substringAfter('$')).substringBefore('$'));
            else
            {
                if(!((MapUserToQueue.get(UserId)).contains((s.substringAfter('$')).substringBefore('$'))))
                {
                    UserQueues = MapUserToQueue.get(UserId)+'$'+(s.substringAfter('$')).substringBefore('$');

                    system.debug('@@UserQueues: '+UserQueues);

                    MapUserToQueue.put(UserId,UserQueues);
                }
            }

            OldUserId = NewUserId;

            HDQueuesDeveloperNames.add((s.substringAfter('$')).substringBefore('$'));
            UserTypeMap.put(UserId,UserType);
        }
        system.debug('@@MapUserToQueue: '+MapUserToQueue);
        system.debug('@@HDQueuesDeveloperNames: '+HDQueuesDeveloperNames);
        system.debug('@@UserTypeMap: '+UserTypeMap);

        for(GroupMember Gm:[Select id,Group.DeveloperName, UserOrGroupId, GroupId from GroupMember where UserOrGroupId in:MapUserToQueue.keySet() and Group.Type in ('Queue','Regular')])
        {
            MemberId = Gm.UserOrGroupId;

            ProvisioningQueues = MapUserToQueue.get(MemberId);

            system.debug('@@ExistentQueue: '+Gm.Group.DeveloperName);

            if(!ProvisioningQueues.contains(Gm.Group.DeveloperName))
                RemoveMemberSet.add(Gm.id);
        }

        system.debug('@@RemoveMemberSet: '+RemoveMemberSet);


        for(Group queue : [Select id,type from Group where type in ('Queue','Regular') and DeveloperName in: HDQueuesDeveloperNames])
        {
            if(queue.type =='Queue')
            {
                if(UserTypeMap.get(UserId) == 'QueueMember')
                    HDGroupmember.add(new Groupmember(GroupId=queue.id,UserOrGroupId=UserId));
            } 
            else
                HDGroupmember.add(new Groupmember(GroupId=queue.id,UserOrGroupId=UserId));
        }

        if(HDGroupmember.size()>0)
            Database.insert(HDGroupmember,false);

        if(RemoveMemberSet.size()>0)
        {
           RemoveMemberList.addAll(RemoveMemberSet);
           Database.delete(RemoveMemberList,false); 
        }
    }
    //MOSCATELLI_M 02/08/2018: Nuovo Modello di assistenza -- END
    */
}