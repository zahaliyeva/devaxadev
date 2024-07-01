public without sharing class AP06CaseUpdate {
/* 
----------------------------------------------------------------------
-- - Name          : AP06CaseUpdate
-- - Author        : Spoon Consulting
-- - Description   : Utility class for case update  
--
-- Maintenance History: 
--
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  ---------------------------------------
-- 09-FEB-2015  DMT     1.0     Initial version
----------------------------------------------------------------------
***********************************************************************/

  public static string CONST_ISNEW = 'ISNEW';
  public static string CONST_ISUPDATE = 'ISUPDATE';
  public static Map<String, Schema.RecordTypeInfo> MapCaseRecordType = new Map<String, Schema.RecordTypeInfo> ();//MOSCATELLI_M 02/08/2018: Nuovo Modello di assistenza
  public static Map<String, Schema.RecordTypeInfo> MapAccountRecordType = new Map<String, Schema.RecordTypeInfo> ();//MOSCATELLI_M 02/08/2018: Nuovo Modello di assistenza

  public static void updateContact(list<Case> triggerList, string operation){
    system.debug('## Start AP06CaseUpdate - updateContact');
    //MOSCATELLI_M 02/08/2018: Nuovo Modello di assistenza -- START
    String[] types = new String[]{'Case'}; 
    List<Schema.DescribeSobjectResult> results = Schema.describeSObjects(types); 

    for (Schema.RecordTypeInfo ri: results[0].getRecordTypeInfos()) 
    { 
        MapCaseRecordType.put(ri.getRecordTypeId(), ri);
    }

    String[] types1 = new String[]{'Account'}; 
    List<Schema.DescribeSobjectResult> results1 = Schema.describeSObjects(types1); 

    for (Schema.RecordTypeInfo ri: results1[0].getRecordTypeInfos()) 
    { 
        MapAccountRecordType.put(ri.getRecordTypeId(), ri);
    }    
    //MOSCATELLI_M 02/08/2018: Nuovo Modello di assistenza -- END

    set<id> accountIdSet = new set<id>();

    list<Case> caseList = new list<Case>();
    boolean flag = false;
    for (Case cs: triggerList){
      if (cs.AccountId != null){
        accountIdSet.add(cs.AccountId);
        flag = true;
      }
      if (cs.AgentName__c != null){
        accountIdSet.add(cs.AgentName__c);
        flag = true;
      }
      if (flag || operation == CONST_ISUPDATE){
        caseList.add(cs);
      }
      flag = false;
    }//end for
    system.debug('## accountIdSet.size(): '+accountIdSet.size());

    map<id, Account> accountContactIdMap = new map<id, Account>();
    for(Account acc: [select id, PersonContactId, PersonEmail, Account_email__c, IsPersonAccount from Account where Id IN :accountIdSet]){
      accountContactIdMap.put(acc.Id, acc);  
    }//end for
    system.debug('## accountContactIdMap.size(): '+accountContactIdMap.size());

    for(Case cs: caseList){
      system.debug('##rectype: '+MapCaseRecordType.get(cs.RecordTypeId).getDeveloperName());
      if(MapCaseRecordType.get(cs.RecordTypeId).getDeveloperName() <> Ap_Constants.rtCaseAssistenzaAgenti)//MOSCATELLI_M 02/08/2018: Nuovo Modello di assistenza
      {
        if (cs.AgentName__c != null){
          cs.ContactId = accountContactIdMap.get(cs.AgentName__c).PersonContactId;
          cs.Case_Contact_Email__c = accountContactIdMap.get(cs.AgentName__c).PersonEmail;
        }
        else {
          if (cs.AccountId != null){
            if (accountContactIdMap.get(cs.AccountId).IsPersonAccount){
              cs.ContactId = accountContactIdMap.get(cs.AccountId).PersonContactId;
              cs.Case_Contact_Email__c = accountContactIdMap.get(cs.AccountId).PersonEmail;
            }
            else{
              cs.Case_Contact_Email__c = accountContactIdMap.get(cs.AccountId).Account_email__c;
              cs.ContactId = null;
            }
          }
        }//end if

        if (cs.AgentName__c == null && cs.AccountId == null){
          cs.ContactId = null;
          system.debug('## case: '+cs);
        }
      }
      //MOSCATELLI_M 02/08/2018: Nuovo Modello di assistenza -- START
      else
      {
          cs.ContactId = null;

          if(String.isNotBlank(cs.Accountid))
          {
            String accid = [Select Recordtypeid from Account where Id=:cs.Accountid limit 1].Recordtypeid;

            if(MapAccountRecordType.get(accid).getDeveloperName()=='Agency')
              cs.Accountid=null;
          }
      } 
      //MOSCATELLI_M 02/08/2018: Nuovo Modello di assistenza -- END              
    }//end for

    system.debug('## End AP06CaseUpdate - updateContact');
  }//end method
}