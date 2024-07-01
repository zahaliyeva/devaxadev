public without sharing class RecordSharing { //CAPOBIANCO_A 25/10/2017 Added the without sharing attribute

public static boolean runModelloDiAssistenzaInsert = true;
public static boolean runModelloDiAssistenzaUpdate = true;


    @future
    public static void shareRecordBasedOnFieldFuture(Set<Id> triggernewSet, String objectShare, String parentId, String rawCause, String accessLevelName, String accessLevelvalue, String fieldNameOfGroup, String separatorFieldNameOfGroup,  String sObjectTypeFuture)
    {   

        List<SObject> triggerNewList = Database.Query('select id, nodes_tree__c,Main_Node__c from ' + sObjectTypeFuture + ' where id in :triggernewSet '); 
        Map<Id,SObject> triggerNewMap = new Map<Id,SObject>();
        for (SObject s : triggerNewList)
        {
            triggerNewMap.put(s.id, s);
        }
        RecordSharing.shareRecordBasedOnField(triggerNewMap, objectShare, parentId, rawCause, accessLevelName, accessLevelvalue, fieldNameOfGroup, separatorFieldNameOfGroup);

    }
    
   // @future
  /*  public static void shareRecordBasedOnFieldFutureAlternative(Set<Id> triggernewSet, String objectShare, String parentId, String rawCause, String accessLevelName, String accessLevelvalue, String fieldNameOfGroup, String separatorFieldNameOfGroup,  String sObjectTypeFuture)
    {   
        //copy querying nodes__c instead of main node
        
        List<SObject> triggerNewList = Database.Query('select id, nodes_tree__c,Nodes__c from ' + sObjectTypeFuture + ' where id in :triggernewSet '); 
        Map<Id,SObject> triggerNewMap = new Map<Id,SObject>();
        for (SObject s : triggerNewList)
        {
            triggerNewMap.put(s.id, s);
            
            
        }
        system.debug('++++++++++triggerNewMap FUTURE'+triggerNewMap);
        RecordSharing.shareRecordBasedOnField(triggerNewMap, objectShare, parentId, rawCause, accessLevelName, accessLevelvalue, fieldNameOfGroup, separatorFieldNameOfGroup);
    }*/

        
    public static void shareRecordBasedOnField(Map<Id,sobject> triggernewMap, String objectShare, String parentId, String rawCause, String accessLevelName, String accessLevelvalue, String fieldNameOfGroup, String separatorFieldNameOfGroup)
    {

    system.debug('++++++++++processing'+triggernewMap.keyset().size());
            
            //V.02
            Map<Id,List<String>> mapShare2 = new Map<Id,List<String>>();
            
            Set<String> groupInitial = new Set <String>();
            //groupInitial.add('DIF_%');
            
            for (Id theId : triggernewMap.keySet())
            {   
                
                SObject so = triggernewMap.get(theId);  
                String Initial = so.get('nodes_tree__c')+'';
                groupInitial.add(so.get('nodes_tree__c')+'%');
                if(so.get(fieldNameOfGroup) != null)
                {

                    //V.02
                    String s = so.get(fieldNameOfGroup)+'';
                    List<String> groups2 = s.split(separatorFieldNameOfGroup);
                    List<String> groups3 = new List<String>();
                    for (String giName : groups2){
                        groups3.add(Initial+''+giName);
                    }
                    
                    system.debug('++++++++++groups2 '+groups3);

                    mapShare2.put(theId, groups3);
                }
    
            }
    
            List<sObject> toDelete = RecordSharing.getRecordShareToDelete(objectShare, parentId, rawCause, triggernewMap.keySet(),groupInitial);
            system.debug('+++++++++++toDelete'+toDelete);

    
            
            //V.02
            
            List<sObject> toShare = RecordSharing.getCurrentRecordShare(objectShare, parentId, rawCause, mapShare2, accessLevelName, accessLevelvalue);
            system.debug('+++++++++++toShare'+toShare);

            Map<String, SObject> MaptoInsert = new Map<String, SObject>();
            Map<String, SObject> MapToRemove = new Map<String, SObject>();

            for(SObject so : toDelete){
                MapToRemove.put(so.get(parentId) + '' + so.get('userorgroupid'), so);
            }

            for(SObject so : toShare){
                MapToInsert.put(so.get(parentId) + '' + so.get('userorgroupid'), so);
            }

            for(String s : MapToInsert.keySet()){
                if(MapToRemove.containsKey(s)){
                    MapToRemove.remove(s);
                    MapToInsert.remove(s);
                }
            }
        
        /*set<sObject> oldMinusNew = new set<sObject>();
        oldMinusNew.addAll(toDelete); 
        set<sObject> newMinusOld = new set<sObject>();
        newMinusOld.addAll(toShare); 
        
        set<sObject> oldMinusNew2 = new set<sObject>();
        oldMinusNew2.addAll(toDelete); 
        set<sObject> newMinusOld2 = new set<sObject>();
        newMinusOld2.addAll(toShare); 
        
        system.debug('++++++++++oldMinusNew'+oldMinusNew);  
        system.debug('++++++++++newMinusOld'+newMinusOld); 
        
        for (sObject oSm : oldMinusNew)
        {
            for (sObject nSm : newMinusOld)
            {
                //system.debug('++++++++++oSm'+oSm);  
                //system.debug('++++++++++nSm'+nSm);
                if ((oSm.get(parentId)==nSm.get(parentId)) && (oSm.get('userorgroupid')==nSm.get('userorgroupid')) )
                {
                    oldMinusNew.remove(oSm); //to be actually removed
                    system.debug('++++++++++MatchRemoval ');
                }
            }
           
        }   
        for (sObject nSm : newMinusOld2)
        {
            for (sObject oSm : oldMinusNew2)
            {
                //system.debug('++++++++++oSm'+oSm);  
                //system.debug('++++++++++nSm'+nSm);
                if ((oSm.get(parentId)==nSm.get(parentId)) && (oSm.get('userorgroupid')==nSm.get('userorgroupid')) )
                {
                    newMinusOld.remove(nSm); //to be actually added
                    system.debug('++++++++++MatchInsert ');
                }
            }
           
        }       
        
        for (sObject oSm : toDelete)
        {
            newMinusOld.remove(oSm); //to be actually inserted
        }*/       


        list<sObject> inShareMember = MapToInsert.values();//new list<sObject>(newMinusOld); //list of group sharing to be actually inserted
        list<sObject> outShareMember = MapToRemove.values();//new list<sObject>(oldMinusNew); //list of group sharing to be actually removed               
        system.debug('++++++++++inShareMember'+inShareMember);  
        system.debug('++++++++++outShareMember'+outShareMember);
        

        if(inShareMember.size()>0)
        {
            /*try {
                //check record access for account only
                
                id accid=(ID)inShareMember.get(0).get('AccountId');
                List<Account> accToshare = [Select Id, Name, Owner.Name FROM Account where Id=:accid];
                system.debug('+++++++++accToshare '+accToshare.get(0).Owner.Name );
                
                id groupid=(ID)inShareMember.get(0).get('UserOrGroupId');
                List<Group> groupToShare = [Select Id, DeveloperName FROM Group where Id=:groupid]; 
                system.debug('++++++++++groupToShare'+ groupToShare )   ;   

            } catch (Exception e)
            {
                //nothingtodo here
                system.debug('++++++++++++exception caught'+e);

                 
            }*/
        
            try 
            {
                insert inShareMember;
            } catch (Exception ee)
            {
            //nothingtodo here
                system.debug('++++++++++++exception caught'+ee);
                system.debug('++++++++++++exception caught with user'+userinfo.getUserId());
            }
        }   
         
        if(outShareMember.size()>0)
        {
        try 
        {
            delete outShareMember;
        } catch (Exception ee) {
           system.debug('++++++++++++exception caught'+ee);
           system.debug('++++++++++++exception caught with user'+userinfo.getUserId());   
        }
        }

    }



    public static Map<String,Id> getGroupNameWithId(List<String> groupNames){
    
        Map<String,Id> NameId_groups = new Map<String,Id>();
        List<Group> groups = [Select id, name,developername from group where developername in :groupNames];
        for (Group gi : groups){
            NameId_groups.put(gi.developername, gi.id);
        }
        return NameId_groups;
    }
    
    
    public static Map<String,Id> getGroupNameWithId(Set<String> groupNames){
    
        Map<String,Id> NameId_groups = new Map<String,Id>();
        List<Group> groups = [Select id, name,developername from group where developername in :groupNames];
        for (Group gi : groups){
            NameId_groups.put(gi.developername, gi.id);
        }
        return NameId_groups;
    }   
    

    
    
    public static List<sObject> getCurrentRecordShare(String objType, String parentFieldName, String RowCause, Map<Id,List<String>> recordId_groupNameList, String accessLevelFieldName, String accessLevelValue)
    {
        if (recordId_groupNameList.size()>0)
        {
            system.debug('+++++++++++recordId_groupNameList' +recordId_groupNameList );
            
            Set<String> groupNames = new Set<String>();
            for (Id myId : recordId_groupNameList.keySet())
            {
                
                groupNames.addAll(recordId_groupNameList.get(myId));
                system.debug('+++++++++++getCurrentRecordShare2 add groupNames' +'' );
                
            }
            system.debug('+++++++++++groupNames' + groupNames);
             
            Map<String,Id> theGroupMap = RecordSharing.getGroupNameWithId(groupNames);
            List<sObject> recordShare = new List<sObject>();
            system.debug('++++++++++theGroupMap'+theGroupMap);
             
            
            for (Id myId : recordId_groupNameList.keySet())
            {
        

                List<String> listGroups = recordId_groupNameList.get(myId);
                for (String gr : listGroups)
                {
                system.debug('++++++++++MAP_ID'+theGroupMap.get(gr));
                String sharingId = theGroupMap.get(gr);
                    if (theGroupMap.get(gr)!=null )
                    {
                        try
                        {
                            system.debug('++++++++++theGroupMap'+theGroupMap);
                            sObject sObj = Schema.getGlobalDescribe().get(objType).newSObject();
                            sObj.put('UserOrGroupId', theGroupMap.get(gr));
                            sObj.put(parentFieldName, myId);
                            sObj.put(accessLevelFieldName, accessLevelValue);
                            sObj.put('RowCause' , RowCause);
                            if (objType =='AccountShare')
                            {
                                sObj.put('OpportunityAccessLevel','Read');
                            }
                            recordShare.add(sObj);
                        }
                        catch(Exception e)
                        {
                            system.debug('+++++EXCEPTION' + e);
                            system.debug('+++++THE OWD OF THE OBJECT CANNOT BE PUBLIC READ WRITE IF WANT TO SHARE RECORDS' + e);
                        }
                    }
                 
                }
                
            }
            
            return recordShare;
        }
        else
        {
            return new List<sObject>();
        }
    }   
    
    
    
    
    
    public static List<sObject> getRecordShareToDelete(String objType, String parentFieldName, String RowCause, Set<Id> sObjIds, Set<String> groupInitial)
    {
        /*Set<String> groupInitial = new Set <String>();
        groupInitial.add('DIF_%');*/
        system.debug('+++++groupInitial' + groupInitial);
        String myQuery = 'select id, userorgroupid, rowcause, '+parentFieldName+' from '+objType+' WHERE RowCause = \'' +RowCause+'\' and '+parentFieldName+' in :sObjIds and userOrGroup.Type = \'Queue\' and UserOrGroup.name like :groupInitial';
        system.debug('+++++myQuery' + myQuery);
        List<sObject> toDeleteFiltered = Database.query(myQuery);
       // system.debug(myQuery);
        /*List<sObject> toDelete = Database.query(myQuery);
        system.debug('+++++toDelete' + toDelete);
        Set<String> setString = new Set<String>();
        for (sObject sG : toDelete)
        {
            //setString.add(sG.userorgroupid);
            setString.add(String.valueOf( sG.get('userorgroupid') ));
        }
        //String searchPar = groupInitial+'%';
        List<Group> rGroupIdsDIF = [SELECT Id from group where Id in :setString and developername like :groupInitial];
        system.debug('+++++rGroupIdsDIF' + rGroupIdsDIF);
        Set<Id> sGroupIdsDIF = (new Map<Id,Group>(rGroupIdsDIF)).keySet();
        String myQuery2 = 'select id, userorgroupid, rowcause, '+parentFieldName+' from '+objType+' WHERE RowCause = \'' +RowCause+'\' and '+parentFieldName+' in :sObjIds and UserOrGroupId in :sGroupIdsDIF';
        List<sObject> toDeleteFiltered  = Database.query(myQuery2);
        system.debug('+++++myQuery2' + myQuery2);
        */
        
        return toDeleteFiltered;
    }
    
    
    /* 
    //TO KNOW ALL THE POSSIBLE ROWCAUSE OF AN OBJECT (CHANGE "Object__Share" WITH THE CORRECT OBJECT, FOR EXAMPLE "CaseShare")
    Map<String, String> values = new Map<String, String>();
    for(PicklistEntry value: Schema.Object__Share.RowCause.getDescribe().getPicklistValues()) {
        values.put(value.getLabel(), value.getValue());
        System.Debug('++++++++:'+value.getValue());
    }
    */



    

}