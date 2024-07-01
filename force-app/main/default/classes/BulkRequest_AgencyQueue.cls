/*------------------------------------------------------------------------
Author:        Dario Bovolenta
Company:       Deloitte
Class:         BulkRequest_BlackList 
Description:   Handling the agency queue updates (from the end users)
History

18/12/2017     Created - Dario Bovolenta
09/08/2018     Added Case Vs Lead queue handling

----------------------------------------------------------------------------*/
public with sharing class BulkRequest_AgencyQueue implements BulkRequestHandler{ 

//These are the attributes to be used for the update START
public List<String> userNamesToAdd {get;set;} //users to insert into the queue
public String AgencyCode {get;set;} //agency code
public String queueType {get;set;} //queue type
//END

//These are attributes to manage some business logics
public String Origin {get;set;}
public Datetime DateRequest {get;set;}


    public List<String> process(List<Sobject> scope){
        system.debug('thisinstance_Origin '+Origin);
        List<User> usrToUpdate = (List<User>)scope;
        //List<User> allAgencyUsers = [SELECT Agency_Code__c,Email,FirstName,LastName,Main_Node__c,Name,Nodes_tree__c,Nodes__c,UserType,Username,IsActive FROM User WHERE Agency_Code__c = :AgencyCode ];
        List<User> agencyUsersToBeIn = [SELECT Agency_Code__c,Email,FirstName,LastName,Main_Node__c,Name,Nodes_tree__c,Nodes__c,UserType,Username,IsActive FROM User WHERE Agency_Code__c = :AgencyCode AND Username IN :userNamesToAdd AND IsPortalEnabled = True];
        List<User> agencyUsersToBeOut = [SELECT Agency_Code__c,Email,FirstName,LastName,Main_Node__c,Name,Nodes_tree__c,Nodes__c,UserType,Username,IsActive FROM User WHERE Agency_Code__c = :AgencyCode AND Username NOT IN :userNamesToAdd AND IsPortalEnabled = True];
        //CHECK THAT AT LEAST ONE USER IS ACTIVE
        Boolean checkActive = false; 
        for (User uIn :agencyUsersToBeIn)
        {
            if (uIn.IsActive == true)
            {
                checkActive = true;
            }
        }
        if (agencyUsersToBeIn.size()<=0 || !checkActive)
        {
            //FATAL ERROR, QUEUE WILL NOT BE MODIFIED
            return null;
        }
        else
        {
            return rearrangeQueue (AgencyCode,agencyUsersToBeOut,agencyUsersToBeIn,queueType);
        }
        
    }

    public static List<String> rearrangeQueue (String agencyCode,List<User> agencyUsersToBeOut,List<User> agencyUsersToBeIn,String queueType)
    {
        Map<Id,GroupMember> currentGMmap = new map <Id,GroupMember>();
        List<GroupMember> gmToRemove = new List<GroupMember> ();
        List<GroupMember> gmToAdd = new List<GroupMember> ();
        List<String> insertErrors = new List<String>(); 
        List<String> deleteErrors = new List<String>(); 
        String queueDevName ='';
        if (queueType== null || queueType == '' || queueType =='Lead') queueDevName= 'Coda_Agenzia_'+agencyCode;
        if (queueType =='Case') queueDevName= 'Coda_Agenzia_Case_'+agencyCode;
        Group currentQueue = [Select Id, DeveloperName from group where type='Queue' and DeveloperName  = :queueDevName limit 1]; //if the queue is not present something is really wrong
        List<GroupMember> currentGroupMembers = [Select Id, GroupId,Group.DeveloperName, UserOrGroupId from GroupMember where GroupId = :currentQueue.Id];
        
        if (currentGroupMembers.size()>0)
        {
            for (GroupMember gm :currentGroupMembers)
            {
                currentGMmap.put(gm.UserOrGroupId,gm);
            }
            system.debug('***currentGMmap'+currentGMmap);
            for (User uOut :agencyUsersToBeOut)
            {
                GroupMember checkUsr = new GroupMember();
                checkUsr = currentGMmap.get(uOut.id);
                if (checkUsr!= null)
                {
                    gmToRemove.add(checkUsr);
                }
                
            }       
        }
        for (User uIn :agencyUsersToBeIn)
        {
            GroupMember checkUsr = new GroupMember();
            checkUsr = currentGMmap.get(uIn.id);
            if (checkUsr== null)
            {
                GroupMember newGm = new GroupMember();
                newGm.GroupId = currentQueue.Id;
                newGm.UserOrGroupId = uIn.Id;
                gmToAdd.add(newGm);
            }
            
        }
        if (gmToAdd.size()>0)
        {
            system.debug ('gmToAdd values: ' +gmToAdd);
            List<Database.SaveResult>  insertResults = Database.Insert (gmToAdd,false);


            insertErrors = BulkRequestManager.getErrors(insertResults, gmToAdd, insertErrors);
            
        }       
        if (gmToRemove.size()>0)
        {
            system.debug ('gmToRemove values: ' +gmToRemove);
            List<Database.DeleteResult>  deleteResults = Database.Delete (gmToRemove,false);
            deleteErrors = BulkRequestManager.getErrors(deleteResults, gmToRemove, deleteErrors);
        }
        insertErrors.addAll(deleteErrors);
        return insertErrors;
        
        
    }



}