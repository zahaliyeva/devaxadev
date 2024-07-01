@isTest
private class LightningCaseRequiredDocumentsCTRL_TEST {

  static list <Case> caseList;
  static list <Account> accList;
  static list <RequiredDocuments__c> csDocsList;
  static map<String,Id> developerIdMap;
  static string accDeveloperId; 
  
    static{
      //popolamento custom settings per classi di test - start
        ServiceUtilsClass.populateCustomSettingsForTests();
      //popolamento custom settings per classi di test - end
    
  
      
      developerIdMap = AP_Constants.getDeveloperIdMap(AP_Constants.sobjectAcc);
      accDeveloperId = developerIdMap.get(AP_Constants.rtAccIndividualClient);
      
      accList = new list<Account>{new Account(FirstName ='John',LastName= 'Smith', PersonEmail = 'john.smith@axa-italy-devtest.com', RecordTypeId = accDeveloperId ),
                    new Account(FirstName ='Jane',LastName= 'Smith', PersonEmail = '', RecordTypeId = accDeveloperId )};
      insert accList;
      
      csDocsList= new list<RequiredDocuments__c>{
            new RequiredDocuments__c(Name='DOC-001',Motor__c=true, RequiredDocuments1__c='doc1 ref-011, doc1 ref-012, doc1 ref-013' ,RequiredDocuments2__c='', SubCategory__c='Lamentela')
            ,new RequiredDocuments__c(Name='DOC-002',Motor__c=true, RequiredDocuments1__c='Estratto doc1 ref-011,Estratto doc1 ref-012,Estratto doc1 ref-013' ,RequiredDocuments2__c='Estrattodoc2 ref-011,Estratto doc2 ref-012,Estratto doc2 ref-013', SubCategory__c='Estratto conto')
            ,new RequiredDocuments__c(Name='DOC-003',Motor__c=true, RequiredDocuments1__c='' ,RequiredDocuments2__c='Tassazione doc2 ref-011,Tassazione doc2 ref-012,Tassazione doc2 ref-013', SubCategory__c='Tassazione')
            ,new RequiredDocuments__c(Name='DOC-004',Motor__c=true, RequiredDocuments1__c='Contratto doc1 ref-011,Contratto doc1 ref-012,Contratto doc1 ref-013' ,RequiredDocuments2__c='Contratto doc2 ref-011,Contratto doc2 ref-012,Contratto doc2 ref-013', SubCategory__c='Contratto/adesione')
            
            };
      insert csDocsList;
      caseList = new list <Case>{new Case(RequiredDocumentList__c = '',
                        SubCategory__c='Lamentela',
                        AccountId= accList[0].Id),
                                   new Case(RequiredDocumentList__c = '',
                        SubCategory__c='Estratto conto',
                        AccountId= accList[0].Id),
                     new Case(RequiredDocumentList__c = '',
                        SubCategory__c='Tassazione',
                        AccountId= accList[0].Id),
                      new Case(RequiredDocumentList__c = 'Contratto doc1 ref-011\nContratto doc1 ref-012\nContratto doc1 ref-013',
                        SubCategory__c='Contratto/adesione',
                        AccountId= accList[0].Id),
                      new Case(RequiredDocumentList__c = '',
                        SubCategory__c='',
                        AccountId= accList[0].Id),
                      new Case(RequiredDocumentList__c = 'Contratto doc1 ref-011\nContratto doc1 ref-012\nContratto doc1 ref-013',
                        SubCategory__c='Contratto/adesione')
                  };
    insert caseList;
    
    }

    static testMethod void test() {
       Case c;
       Test.startTest();
       c = [Select RequiredDocumentList__c from Case where Id = :caseList[0].Id];
       LightningCaseRequiredDocumentsController.Response result = new  LightningCaseRequiredDocumentsController.Response();
       result = LightningCaseRequiredDocumentsController.initCmp(caseList[0].Id);
        
       List< LightningCaseRequiredDocumentsController.RetrieveDocW> docResults = result.docResults;
        
       LightningCaseRequiredDocumentsController.sendEmail(caseList[0].Id,docResults);
       Test.stopTest();
     
       
    }

  
}