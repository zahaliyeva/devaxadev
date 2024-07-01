/*------------------------------------------------------------------------
Author:        Marco Moscatelli
Company:       Deloitte
Class:         SocialPostHandler
Description:   Apex class used to manage all the events related to the DML 
			   operations related to Social Post

History

14/07/2017     Created - Marco Moscatelli.
----------------------------------------------------------------------------*/
public with sharing class SocialPostHandler implements ITrigger {
    public final String AccountPrefix = Schema.SObjectType.Account.getKeyPrefix();
    public final String objectShare = 'SocialPostShare';
    public final String parentId = 'ParentId';
    public final String rawCause = 'Manual';
    public final String accessLevelName = 'AccessLevel';
    public final String accessLevelvalue = 'Read';
    public final String separatorOfGroups = ';';
    public final String fieldNameOfGroup = 'Account_Nodes__c';

    public SocialPostHandler() {

    }

    /**
    * BULK 
    *  
    * Those methods are called prior to execution of a trigger. Use those to cache  
    * any data required into maps prior execution of the trigger.  
    */

    public void bulkBefore() {

    }

    public void bulkAfter() {

    }

    /*BEFORE SINGLE METHOD*/
    public void beforeInsert(SObject so) {

    }

    public void beforeUpdate(SObject oldSo, SObject so) {

    }

    public void beforeDelete(SObject so) {

    }

    /*BEFORE LIST METHOD*/
    public void beforeInsert(List<SObject> soList) {
        System.debug('*****Davide: BEFORE INSERT_SOCIAL POST HANDLER');
        Set<String> PersonasIdSet = new Set<String>();
        Map<String, String> PersonaToAccountMap = new Map<String, String>();
        Map<String, String> PostToPersonaMap = new Map<String, String>();
        List<SocialPost> SocialPostList = new List<SocialPost>();
        Set<Case> CaseSet = new Set<Case>();
        Map<String, String> PostToCaseMap = new Map<String, String>();
        Map<String, String> UpdPostToAccountMap = new Map<String, String>();

        for (sObject sObj : soList) {
            if (String.isNotBlank((String) sObj.get('PersonaId'))) {
                PersonasIdSet.add((String) sObj.get('PersonaId'));
                PostToPersonaMap.put((String) sObj.get('Id'), (String) sObj.get('PersonaId'));
            }

            if (String.isNotBlank((String) sObj.get('ParentId'))) {
                if (String.isNotBlank((String) sObj.get('WhoId')) && ((String) sObj.get('WhoId')).startsWith(AccountPrefix)) {
                    Case c = new Case(Id = (String) sObj.get('ParentId'), AccountId = (String) sObj.get('WhoId'));
                    CaseSet.add(c);
                } else
                        PostToCaseMap.put((String) sObj.get('Id'), (String) sObj.get('ParentId'));
            }
        }

        System.debug('===> PersonasIdSet: ' + PersonasIdSet);
        System.debug('===> PostToPersonaMap: ' + PostToPersonaMap);
        System.debug('===> PostToCaseMap: ' + PostToCaseMap);
        System.debug('===> CaseSet: ' + CaseSet);

        SocialPostManagement SPM = new SocialPostManagement();
        UpdPostToAccountMap = SPM.AddAccount(PersonasIdSet, PostToPersonaMap, PostToCaseMap, CaseSet);

        if (UpdPostToAccountMap.size() > 0) {
            for (sObject sObj : soList) {
                if (UpdPostToAccountMap.containsKey((String) sObj.get('Id')) && (!((String) sObj.get('WhoId')).startsWith(AccountPrefix))) {
                    String oldwho = (String) sObj.put('WhoId', UpdPostToAccountMap.get((String) sObj.get('Id')));
                }
            }
        }

        System.debug('===> UpdPostToAccountMap: ' + UpdPostToAccountMap);
        //BOVOLENTA_D CONTACT HISTORY 23112018 - START
        //put the account's nodes in a field to handle sharing
        List<String> accountIds = UpdPostToAccountMap.values();
        System.debug('===> accountIds: ' + accountIds);
        Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Nodes__c,Id,Nodes_Tree__c FROM Account WHERE Id in :accountIds]);
        System.debug('===> accountMap: ' + accountMap);
        if (accountMap != null && !accountMap.isEmpty()) {
            for (sObject sObj : soList) {
                if (String.isNotBlank((String) sObj.get('ParentId'))) {
                    String theWhoId = (String) sObj.get('WhoId');
                    if (String.isNotBlank(theWhoId) && (theWhoId).startsWith(AccountPrefix)) {
                        //put nodes value in a field of the sobject then call the recordsharing method
                        sObj.put('Account_Nodes__c', accountMap.get(theWhoId).Nodes__c);
                        sObj.put('Nodes_Tree__c', accountMap.get(theWhoId).Nodes_Tree__c);
                    }
                }
            }
        }
    }


    public void beforeUpdate(List<SObject> oldSoList, List<SObject> soList) {
        System.debug('*****Davide: BEFORE UPDATE_SOCIAL POST HANDLER');
        Set<String> PersonasIdSet = new Set<String>();
        Map<String, String> PersonaToAccountMap = new Map<String, String>();
        Map<String, String> PostToPersonaMap = new Map<String, String>();
        List<SocialPost> SocialPostList = new List<SocialPost>();
        Set<Case> CaseSet = new Set<Case>();
        Map<String, String> PostToCaseMap = new Map<String, String>();
        Map<String, String> UpdPostToAccountMap = new Map<String, String>();
        Integer counter = 0;

        System.debug('*****Davide: ' + soList);

        for (sObject sObj : soList) {
            System.debug('*****°°°°°Davide oldSoList[counter].get....: ' + oldSoList[counter].get('PersonaId'));
            System.debug('*****°°°°°Davide sObj.get(\'PersonaId\')' + sObj.get('PersonaId'));

            //if (String.isNotBlank((String) sObj.get('PersonaId')) && ((String) sObj.get('PersonaId') <> (String) oldSoList[counter].get('PersonaId'))) {
            // 2019-01-14 Davide: questo confronto ((String) sObj.get('PersonaId') <> (String) oldSoList[counter].get('PersonaId'))
            //                    non lascia mai entrare all'interno dell'IF e successivamente il metodo SPM.AddAccount(..) non riesce a creare lo Sharing

            if (String.isNotBlank((String) sObj.get('PersonaId'))) {
                System.debug('*****Davide inside if 1: ' + (String) sObj.get('PersonaId'));
                PersonasIdSet.add((String) sObj.get('PersonaId'));
                PostToPersonaMap.put((String) sObj.get('Id'), (String) sObj.get('PersonaId'));
            }

            if (String.isNotBlank((String) sObj.get('ParentId'))) {
                System.debug('*****Davide: ' + String.isNotBlank((String) sObj.get('ParentId')));
                if (String.isNotBlank((String) sObj.get('WhoId')) && ((String) sObj.get('WhoId')).startsWith(AccountPrefix)) {
                    Case c = new Case(Id = (String) sObj.get('ParentId'), AccountId = (String) sObj.get('WhoId'));
                    CaseSet.add(c);
                    System.debug('*****Davide CASE: ' + c);
                } else {
                    System.debug('*****Davide else case 001: ');
                    PostToCaseMap.put((String) sObj.get('Id'), (String) sObj.get('ParentId'));
                }
            }

            counter++;
        }

        SocialPostManagement SPM = new SocialPostManagement();
        System.debug('===> PersonasIdSet: ' + PersonasIdSet);
        System.debug('===> PostToPersonaMap: ' + PostToPersonaMap);
        System.debug('===> PostToCaseMap: ' + PostToCaseMap);
        System.debug('===> CaseSet: ' + CaseSet);
        UpdPostToAccountMap = SPM.AddAccount(PersonasIdSet, PostToPersonaMap, PostToCaseMap, CaseSet);

        if (UpdPostToAccountMap.size() > 0) {
            for (sObject sObj : soList) {
                if (UpdPostToAccountMap.containsKey((String) sObj.get('Id')) && (!((String) sObj.get('WhoId')).startsWith(AccountPrefix)))
                    String oldwho = (String) sObj.put('WhoId', UpdPostToAccountMap.get((String) sObj.get('Id')));
            }
        }
        System.debug('===> UpdPostToAccountMap: ' + UpdPostToAccountMap);
        //BOVOLENTA_D CONTACT HISTORY 23112018 - START
        //put the account's nodes in a field to handle sharing
        List<String> accountIds = UpdPostToAccountMap.values();
        System.debug('===> accountIds: ' + accountIds);
        Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Nodes__c,Id,Nodes_Tree__c FROM Account WHERE Id in :accountIds]);
        System.debug('===> accountMap: ' + accountMap);
        //DANTONIO_M bug fix to prevent null pointer exception when accountMap is null 27/11/2018 - START
        if (accountMap != null && !accountMap.isEmpty()) {
            //DANTONIO_M bug fix to prevent null pointer exception when accountMap is null 27/11/2018 - END
            for (sObject sObj : soList) {
                if (String.isNotBlank((String) sObj.get('ParentId'))) {
                    String theWhoId = (String) sObj.get('WhoId');
//                    if (String.isNotBlank(theWhoId) && (theWhoId).startsWith(AccountPrefix)) {
                    //2019-01-02 Davide B. Augens - bug fix to prevent null pointer exception - START
                    if (String.isNotBlank(theWhoId) && accountMap.containsKey(theWhoId) && (theWhoId).startsWith(AccountPrefix)) {
                        //2019-01-02 Davide B. Augens - bug fix to prevent null pointer exception - END
                        //put nodes value in a field of the sobject then call the recordsharing method
                        sObj.put('Account_Nodes__c', accountMap.get(theWhoId).Nodes__c);
                        sObj.put('Nodes_Tree__c', accountMap.get(theWhoId).Nodes_Tree__c);
                    }
                }
            }
        }
        //BOVOLENTA_D CONTACT HISTORY 23112018 - END
    }


    public void beforeDelete(List<SObject> soList) {

    }

    /*AFTER SINGLE METHOD*/
    public void afterInsert(SObject so) {

    }

    public void afterUpdate(SObject oldSo, SObject so) {

    }

    public void afterDelete(SObject so) {

    }

    public void afterUndelete(SObject so) {

    }

    /*AFTER LIST METHOD*/
    public void afterInsert(List<SObject> soList) {
        System.debug('*****Davide: AFTER INSERT_ SOCIAL POST HANDLER');
        Map<Id, sObject> mapSObj = new Map<Id, sObject>();
        Map<String, sObject> CaseToContentMap = new Map<String, sObject>();
        SocialPostManagement SPM = new SocialPostManagement();

        for (sObject sObj : soList) {
            mapSObj.put(sObj.Id, sObj);
            if (String.isNotBlank((String) sObj.get('ParentId')) && !(Boolean) sObj.get('IsOutbound')) {
                if (String.isNotBlank((String) sObj.get('Content')))
                    CaseToContentMap.put((String) sObj.get('ParentId'), sObj);
            }
        }

        if (CaseToContentMap.size() > 0) {
            SPM.SendNotification(CaseToContentMap);
        }
        //DANTONIO_M SocialPost share 27/11/2018 - START
        RecordSharing.shareRecordBasedOnField(mapSObj, objectShare, parentId, rawCause, accessLevelName, accessLevelvalue, fieldNameOfGroup, separatorOfGroups);
        //DANTONIO_M SocialPost share 27/11/2018 - END
    }

    public void afterUpdate(List<SObject> oldSoList, List<SObject> soList) {
        System.debug('*****Davide: AFTER UPDATE_SOCIAL POST HANDLER');
        //DANTONIO_M SocialPost share 27/11/2018 - START
        Map<Id, sObject> mapSObj = new Map<Id, sObject>();
        for (sObject sObj : soList) {
            mapSObj.put(sObj.Id, sObj);
        }

        RecordSharing.shareRecordBasedOnField(mapSObj, objectShare, parentId, rawCause, accessLevelName, accessLevelvalue, fieldNameOfGroup, separatorOfGroups);
        //DANTONIO_M SocialPost share 27/11/2018 - END
    }

    public void afterDelete(List<SObject> soList) {

    }

    public void afterUndelete(List<SObject> soList) {

    }


    /** 
    * andFinally
    *  
    * This method is called once all records have been processed by the trigger. Use this   
    * method to accomplish any final operations such as creation or updates of other records.  
    */
    public void andFinally() {

    }
}