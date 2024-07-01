/**  http://developer.force.com/cookbook/recipe/trigger-pattern-for-tidy-streamlined-bulkified-triggers
 * Class UserHandler  
 *  
 * Trigger Handler for the User SObject. This class implements the ITrigger  
 * interface to help ensure the trigger code is bulkified and all in one place.  
 */ 

public with sharing class UserHandler implements ITrigger  
{     

    // Member variable to hold the Id's of User 'in use'  
    private Set<Id> RecordsInUse = new Set<Id>();  
    
    
    public final String objectShare = 'UserShare';  
    public final String parentId = 'UserId';
    public final String rawCause = 'Manual'; 
    public final String accessLevelName = 'UserAccessLevel';
    public final String accessLevelvalue = 'Read'; //'None','Read','Edit','All'
    public final String separatorOfGroups = ';';
    public final String fieldNameOfGroup ='Agency_Code__c';   

    // Constructor  
    public UserHandler()
    {  

    }  

    /**  
    * BULK 
    *  
    * Those methods are called prior to execution of a trigger. Use those to cache  
    * any data required into maps prior execution of the trigger.  
    */ 

    public void bulkBefore()
    {  

    }  

    public void bulkAfter()
    {  

    }  

    
    /*BEFORE SINGLE METHOD*/
    public void beforeInsert(SObject so)
    {  
        List<User> rList = new List<User>{(User)so};
        rList = AdminManagement.checkListOfUsers(rList); // check if the user it authorized to updated other users
    }  

    public void beforeUpdate(SObject oldSo, SObject so)
    {  
        List<User> rList = new List<User>{(User)oldSo};
        rList = AdminManagement.checkListOfUsers(rList); // check if the user it authorized to updated other users
    }  

    public void beforeDelete(SObject so)
    {     
        List<User> rList = new List<User>{(User)so};
        rList = AdminManagement.checkListOfUsers(rList); // check if the user it authorized to updated other users
    }
    
    /*BEFORE LIST METHOD*/
    public void beforeInsert(List<SObject> soList)
    {  
        List<User> rList = (List<User>) soList;
        rList = AdminManagement.checkListOfUsers(rList); // check if the user it authorized to updated other users
    }  

    public void beforeUpdate(List<SObject> oldSoList, List<SObject> soList)
    {  
        List<User> rList = (List<User>) oldSoList;
        rList = AdminManagement.checkListOfUsers(rList); // check if the user it authorized to updated other users
    }  


    public void beforeDelete(List<SObject> soList){     

    } 

    
    /*AFTER SINGLE METHOD*/
    public void afterInsert(SObject so)
    {  
        List<User> rList = new List<User>{(User)so};
        rList = AdminManagement.checkListOfUsers(rList); // check if the user it authorized to updated other users
    }         

    public void afterUpdate(SObject oldSo, SObject so)
    {  
        List<User> rList = new List<User>{(User)oldSo};
        rList = AdminManagement.checkListOfUsers(rList); // check if the user it authorized to updated other users
    }  

    public void afterDelete(SObject so)
    {  

    }
    
    public void afterUndelete(SObject so)
    {  

    }

    /*AFTER LIST METHOD*/
    public void afterInsert(List<SObject> soList)
    {  

        
        Map<Id,sObject> mapSObj = new Map<Id,sObject>();
        for (SObject sObj : soList)
        {
            mapSObj.put(sObj.id, sObj); 
        } 
        
        List<User> rList = (List<User>) soList;
        rList = AdminManagement.checkListOfUsers(rList); // check if the user it authorized to updated other users
        //UserManagement.RefreshNodes(rList);
                system.debug('++++++trigger afterinsert user is future '+system.isfuture());
        
        //MOSCATELLI 20/12/2016: EVO73--START
        if(system.isBatch()==false)
        {
            if (system.isfuture()==false) {
            system.debug('++++++++++++++attempt to refresh nodes with future method');
            UserManagement.RefreshNodesFuture(new list<id>(mapSObj.keyset()));
            } else {
            system.debug('+++++++++++++++++++++WARNING FUTURE METHOD WAS TRYING TO INVOKE FUTURE REFRESH OF NODES');
            }
        }
        else
            system.debug('+++++++++++++++++++++WARNING A BATCH WAS TRYING TO INVOKE FUTURE REFRESH OF NODES');    
        //MOSCATELLI 20/12/2016: EVO73--END
        /*
        system.debug('++++++++++++++++++attempt to shareRecordBasedOnField');
        //SHARING 
        RecordSharing.shareRecordBasedOnField(mapSObj, objectShare, parentId, rawCause, accessLevelName, accessLevelvalue, fieldNameOfGroup, separatorOfGroups);
    */
    } 
    
    public void afterUpdate(List<SObject> oldSoList, List<SObject> soList)
    {  

        
        Map<Id,sObject> mapSObj = new Map<Id,sObject>();
        Map<Id,sObject> mapOldSObj = new Map<Id,sObject>();
        Boolean isNodeChanged = false;
        for (SObject sObj : soList)
        {
            mapSObj.put(sObj.id, sObj); 
        } 

        for (SObject sObj : oldSoList)
        {
            User actualUser = (User) mapSObj.get(sobj.id);
            User oldUser = (User) sObj;
            if(actualUser.Nodes__c != oldUser.Nodes__c){
                isNodeChanged = true;
            }
        } 
        
        
        List<User> rList = (List<User>) soList;
        rList = AdminManagement.checkListOfUsers(rList); // check if the user it authorized to updated other users
        //UserManagement.RefreshNodes(rList);
        system.debug('++++++trigger user afterupdate is future '+system.isfuture());
        
        //MOSCATELLI 20/12/2016: EVO73--START
        if(system.isBatch()==false)
        {
            if (system.isfuture()==false) {
            system.debug('++++++++++++refreshingnodes');
                try{
                    if(isNodeChanged)
                        UserManagement.RefreshNodesFuture(new list<id>(mapSObj.keyset()));
                }
                catch(Exception e){
                    try{
                        ApplicationLogHelper.ERROR('UserHandler', e.getmessage(), e.getStackTraceString());
                    } catch (Exception ex) {
                        System.debug(System.LoggingLevel.ERROR,'Exception: ' + ex.getmessage() + '\tStackTrace: '+ex.getStackTraceString());
		            }
                }
            } else {
            system.debug('+++++++++++++++++++++WARNING FUTURE METHOD WAS TRYING TO INVOKE FUTURE REFRESH OF NODES');
            }
        }
        else
            system.debug('+++++++++++++++++++++WARNING A BATCH WAS TRYING TO INVOKE FUTURE REFRESH OF NODES');
        //MOSCATELLI 20/12/2016: EVO73--END
        /*
        system.debug('++++++++++++++++++attempt to shareRecordBasedOnField');
        //SHARING 
        RecordSharing.shareRecordBasedOnField(mapSObj, objectShare, parentId, rawCause, accessLevelName, accessLevelvalue, fieldNameOfGroup, separatorOfGroups);
*/
    }  
    
    public void afterDelete(List<SObject> soList)
    {  
    
        List<User> rList = (List<User>) soList;
        rList = AdminManagement.checkListOfUsers(rList); // check if the user it authorized to updated other users
        UserManagement.RefreshNodes(rList);

    }
    
    public void afterUndelete(List<SObject> soList)
    { 
    
        List<User> rList = (List<User>) soList;
        rList = AdminManagement.checkListOfUsers(rList); // check if the user it authorized to updated other users
        UserManagement.RefreshNodes(rList);

    }
       

    /** 
    * andFinally
    *  
    * This method is called once all records have been processed by the trigger. Use this   
    * method to accomplish any final operations such as creation or updates of other records.  
    */ 

    public void andFinally(){  

    }  
    
}