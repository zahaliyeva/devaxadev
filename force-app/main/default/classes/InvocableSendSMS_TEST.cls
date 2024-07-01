@isTest
public with sharing class InvocableSendSMS_TEST {

   
   @isTest
    static  void method_1() {
        MKT_Utility__c utility = new MKT_Utility__c(MKT_SMS_ALERT_URL__c = 'https://mkt.rest.it',MKT_SMS_URL_AUTH__c= 'https://mkt.rest.it');
        insert utility;
        insert new SMSCaringKeyword__c(Keyword__c='INFORMATIVE',Name='SMSKeyword');
        insert new SMSCaringKeyword__c(Keyword__c='TRANSACTIONAL',Name='SMSKeywordSTT');
        Map<String,Id>  case_developerIdMap = AP_Constants.getDeveloperIdMap(AP_Constants.sobjectCas);
        Account a = new Account(Name='Test Padre');
        insert a;
        Contact c = new Contact(FirstName='Cliente', LastName = 'Non Censito',AccountId=a.Id);
        insert c;
        list<Case> caseToIns = new list<case>();
        Case c1 = new Case(Subject='Test1', RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseMotor), SuppliedPhone='3331122333');
        Case c2 = new Case(Subject='Test2', RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseNonMotor), SuppliedPhone='3331122333');
        Case c3 = new Case(Subject='Test3', RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseSinistro), SuppliedPhone='3331122333');
        Case c4 = new Case(Subject='Test4', RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseAMF), SuppliedPhone='3331122333');
        Case c5 = new Case(Subject='Test5', RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseAssistenzaAgenti), SuppliedPhone='3331122333');
        Case c6 = new Case(Subject='Test6', RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseAAI), SuppliedPhone='3331122333');
        Case c7 = new Case(Subject='Test7', RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseSinistriAAI), SuppliedPhone='3331122333');
        Case c8 = new Case(Subject='Test8', RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseAgenziaDipendenti), SuppliedPhone='3331122333');
        caseToIns.add(c1);
        caseToIns.add(c2);
        caseToIns.add(c3);
        caseToIns.add(c4);
        caseToIns.add(c5);
        caseToIns.add(c6);
        caseToIns.add(c7);
        caseToIns.add(c8);
        Case c1p = new Case(Subject='Test1', RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseMotor), SuppliedPhone='3331122333', ContactId=c.Id, AccountId=a.Id);
        Case c2p = new Case(Subject='Test2', RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseNonMotor), SuppliedPhone='3331122333', ContactId=c.Id, AccountId=a.Id);
        Case c3p = new Case(Subject='Test3', RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseSinistro), SuppliedPhone='3331122333', ContactId=c.Id, AccountId=a.Id);
        Case c4p = new Case(Subject='Test4', RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseAMF), SuppliedPhone='3331122333', ContactId=c.Id, AccountId=a.Id);
        Case c5p = new Case(Subject='Test5', RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseAssistenzaAgenti), SuppliedPhone='3331122333', ContactId=c.Id, AccountId=a.Id);
        Case c6p = new Case(Subject='Test6', RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseAAI), SuppliedPhone='3331122333', ContactId=c.Id, AccountId=a.Id);
        Case c7p = new Case(Subject='Test7', RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseSinistriAAI), SuppliedPhone='3331122333', ContactId=c.Id, AccountId=a.Id);
        Case c8p = new Case(Subject='Test8', RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseAgenziaDipendenti), SuppliedPhone='3331122333', ContactId=c.Id, AccountId=a.Id);
        caseToIns.add(c1p);
        caseToIns.add(c2p);
        caseToIns.add(c3p);
        caseToIns.add(c4p);
        caseToIns.add(c5p);
        caseToIns.add(c6p);
        caseToIns.add(c7p);
        caseToIns.add(c8p);
        CaseHandler.RunTrigger = false;
        insert caseToIns;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MKTAuthenticationMock());
        InvocableSendSMS.sendSms(caseToIns);
        system.assertEquals(caseToIns[0].id != null, true,'Il case deve essere inserito OK');
        Test.stopTest();
      
        
    }
    
}