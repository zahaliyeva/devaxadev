public with sharing class IndividualEmailResultHandler implements ITrigger

{

    public final String objectShare = 'et4ae5__IndividualEmailResult__Share';
    public final String parentId = 'ParentId';
    public final String rawCause = 'Manual';
    public final String accessLevelName = 'AccessLevel';
    public final String accessLevelvalue = 'Read';
    public final String separatorOfGroups = ';';
    public final String fieldNameOfGroup = 'Account_Nodes__c';

    // Constructor  

    public IndividualEmailResultHandler() {

    }


    /**  

     * bulkBefore  

     *  

     * This method is called prior to execution of a BEFORE trigger. Use this to cache  

     * any data required into maps prior execution of the trigger.  

     */

    public void bulkBefore() {

    }


    public void bulkAfter() {

    }


    public void beforeInsert(SObject so) {

    }

    public void beforeInsert(List<SObject> soList) {

        for (SObject sObj : soList) {
            if (String.isNotBlank('' + sObj.get('et4ae5__Contact__c'))) {
                sObj.put('Account__c', sObj.get('AccountId__c'));
            } else {
                sObj.put('Account__c', null);
            }
        }

        // 2019-01-30 Davide B. Augens
        // If "et4ae5__SubjectLine__c" is a string like: "%%=v(@Name)=%% qua la zampa!", "%%=v(@Name)=%% un altro anno insieme", etc.
        // Sets the field "Subject_Line_No_Amp_Script" removing the substring "%%_anything_written_here_between_double_percent_characters_%%"
        // If substring is not found, it straightly clones the value
        for (et4ae5__IndividualEmailResult__c res : (List<et4ae5__IndividualEmailResult__c>) soList) {
            if (res.et4ae5__SubjectLine__c != null && res.et4ae5__SubjectLine__c != 'undefined') {
                String regex = '%%.*%% |%%.*%%';
                res.Subject_Line_No_Amp_Script__c = res.et4ae5__SubjectLine__c.replaceAll(regex, '');
            }
        }
    }

    public void beforeUpdate(SObject oldSo, SObject so) {


    }


    public void beforeUpdate(List<SObject> oldSoList, List<SObject> soList) {

        for (SObject sObj : soList) {
            if (String.isNotBlank('' + sObj.get('et4ae5__Contact__c'))) {
                sObj.put('Account__c', sObj.get('AccountId__c'));
            } else {
                sObj.put('Account__c', null);
            }
        }

        // 2019-01-30 Davide B. Augens
        // If "et4ae5__SubjectLine__c" is a string like: "%%=v(@Name)=%% qua la zampa!", "%%=v(@Name)=%% un altro anno insieme", etc.
        // Sets the field "Subject_Line_No_Amp_Script" removing the substring "%%_anything_written_here_between_double_percent_characters_%%"
        // If substring is not found, it straightly clones the value
        for (et4ae5__IndividualEmailResult__c res : (List<et4ae5__IndividualEmailResult__c>) soList) {
            if (res.et4ae5__SubjectLine__c != null && res.et4ae5__SubjectLine__c != 'undefined') {
                String regex = '%%.*%% |%%.*%%';
                res.Subject_Line_No_Amp_Script__c = res.et4ae5__SubjectLine__c.replaceAll(regex, '');
            }
        }
    }

    /**  

     * beforeDelete  

     *  

     * This method is called iteratively for each record to be deleted during a BEFORE  

     * trigger.  

     */

    public void beforeDelete(SObject so) {

    }

    public void beforeDelete(List<SObject> soList) {

    }

    public void afterInsert(SObject so) {

    }


    public void afterInsert(List<SObject> soList) {
        if (UtilityClass.isFirstRun) {
            Map<Id, sObject> mapSObjContact = new Map<Id, sObject>();
            List<et4ae5__IndividualEmailResult__c> leadEmailsList = new list<et4ae5__IndividualEmailResult__c>();
            List<et4ae5__IndividualEmailResult__c> individualEmailResults = new list<et4ae5__IndividualEmailResult__c>();

            for (SObject sObj : soList) {
                if (!String.isEmpty((String) sObj.get('et4ae5__Contact__c'))) {
                    system.debug('et4ae5__Contact__c: ' + '' + sObj.get('et4ae5__Contact__c'));
                    mapSObjContact.put(sObj.id, sObj);

                    //FOZDEN 17/07/2019: comunicazioni massive - start
                    if (sObj.get('Email_type__c') == null
                            || (sObj.get('Email_type__c') != null && !((String)sObj.get('Email_type__c')).startsWithIgnoreCase('ComMassive'))) {
                        individualEmailResults.add((et4ae5__IndividualEmailResult__c) sObj);
                    }
                    //FOZDEN 17/07/2019: comunicazioni massive - end

                } else if (!String.isEmpty((String) sObj.get('et4ae5__Lead__c'))) {
                    leadEmailsList.add((et4ae5__IndividualEmailResult__c) sObj);
                }

            }
            if (!mapSObjContact.isEmpty())
                RecordSharing.shareRecordBasedOnField(mapSObjContact, objectShare, parentId, rawCause, accessLevelName, accessLevelvalue, fieldNameOfGroup, separatorOfGroups);
            if (leadEmailsList.size() > 0)
                IndividualEmailResultManagement.ShareWithFullAgency(leadEmailsList);
//            IndividualEmailResultManagement.createCommunicationBounceEvents((List<et4ae5__IndividualEmailResult__c>) mapSObjContact.values());
//            IndividualEmailResultManagement.createEmailUnsubscribingEvents((List<et4ae5__IndividualEmailResult__c>) mapSObjContact.values());
            //FOZDEN 17/07/2019: comunicazioni massive - start
            IndividualEmailResultManagement.createCommunicationBounceEvents((List<et4ae5__IndividualEmailResult__c>) individualEmailResults);
            IndividualEmailResultManagement.createEmailUnsubscribingEvents((List<et4ae5__IndividualEmailResult__c>) individualEmailResults);
            //FOZDEN 17/07/2019: comunicazioni massive - end
            UtilityClass.isFirstRun = false;
        }
    }


    public void afterUpdate(SObject oldSo, SObject so) {

    }

    public void afterUpdate(List<SObject> oldSoList, List<SObject> soList) {
        if (UtilityClass.isFirstRun) {
            Map<Id, et4ae5__IndividualEmailResult__c> oldMap = new Map<Id, et4ae5__IndividualEmailResult__c>();
            List<et4ae5__IndividualEmailResult__c> resList = (List<et4ae5__IndividualEmailResult__c>) oldSoList;
            for (et4ae5__IndividualEmailResult__c res : resList) {
                oldMap.put(res.Id, res);
            }

            resList = new List<et4ae5__IndividualEmailResult__c>();
            for (et4ae5__IndividualEmailResult__c res : (List<et4ae5__IndividualEmailResult__c>) soList) {
                if (oldMap.containsKey(res.Id)
                        && !oldMap.get(res.Id).et4ae5__HardBounce__c
                        && !String.isEmpty(res.et4ae5__Contact__c)) {
                    resList.add(res);
                }
            }

            System.debug('===> Sending communicaiton bounce events: ' + resList);
            IndividualEmailResultManagement.createCommunicationBounceEvents(resList);

            resList = new List<et4ae5__IndividualEmailResult__c>();
            for (et4ae5__IndividualEmailResult__c res : (List<et4ae5__IndividualEmailResult__c>) soList) {
                if (oldMap.containsKey(res.Id)
                        && oldMap.get(res.Id).et4ae5__DateUnsubscribed__c == null) {
                    resList.add(res);
                }
            }

            System.debug('===> Sending email unsubscribing events: ' + resList);
            IndividualEmailResultManagement.createEmailUnsubscribingEvents(resList);

            Map<Id, sObject> mapSObjContact = new Map<Id, sObject>();
            List<et4ae5__IndividualEmailResult__c> leadEmailsList = new list<et4ae5__IndividualEmailResult__c>();

            for (SObject sObj : soList) {
                system.debug('sObj: ' + sObj);
                if (!String.isEmpty((String) sObj.get('et4ae5__Contact__c'))) {
                    system.debug('et4ae5__Contact__c: ' + '' + sObj.get('et4ae5__Contact__c'));
                    mapSObjContact.put(sObj.id, sObj);
                } else if (!String.isEmpty((String) sObj.get('et4ae5__Lead__c'))) {
                    leadEmailsList.add((et4ae5__IndividualEmailResult__c) sObj);
                }

            }
            if (!mapSObjContact.isEmpty())
                RecordSharing.shareRecordBasedOnField(mapSObjContact, objectShare, parentId, rawCause, accessLevelName, accessLevelvalue, fieldNameOfGroup, separatorOfGroups);
            if (leadEmailsList.size() > 0)
                IndividualEmailResultManagement.ShareWithFullAgency(leadEmailsList);

            UtilityClass.isFirstRun = false;
        }

    }

    public void afterDelete(SObject so) {

    }

    public void afterUndelete(SObject so) {

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

    public void andFinally()

    {


    }

}