@isTest
private class VFC07_CaseRequiredDocuments_TEST {
/*
----------------------------------------------------------------------
-- - Name          : VFC07_CaseRequiredDocuments_TEST
-- - Author        : Spoon Consulting 
-- - Description   : Test class of VFC07_CaseRequiredDocuments
--                   
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 12-01-2014   NJA    1.0    Intitial version
----------------------------------------------------------------------
**********************************************************************
*/
  static user userAdmin;
  static list <Case> caseList;
  static list <Account> accList;
  static list <RequiredDocuments__c> csDocsList;
  static id profileId;
  static map<String,Id> developerIdMap;
  static string accDeveloperId; 
  
    static{
      //MDANTONIO 09/04/2019 popolamento custom settings per classi di test - start
        ServiceUtilsClass.populateCustomSettingsForTests();
        //MDANTONIO 09/04/2019 popolamento custom settings per classi di test - end
      profileId =([Select Id From Profile 
                  Where name = 'Administrateur système' 
                      OR name = 'System Administrator'
                      OR name = 'Amministratore del sistema'
                      OR name = 'Systemadministrator'
                      OR name = 'Systemadministratör'
                      OR name = 'Administrador do sistema'
                      OR name = 'Systeembeheerder'
                      OR name = 'Systemadministrator'].Id);
                    
      //User
      userAdmin = new User(Username = 'testclassAP01@test.com',
                          LastName = 'testuser',
                          LanguageLocaleKey = 'en_US',
                          FirstName = 'test',
                          Email = 'test@test.com',
                          Alias = 'test',
                          TimeZoneSidKey = 'Europe/Dublin',
                          LocaleSidKey = 'en_US',
                          EmailEncodingKey = 'UTF-8',
                          ProfileId = profileId);
                      
      insert userAdmin; 
      
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
       test.startTest();
            PageReference pg = Page.VFP07_CaseRequiredDocuments;
          
          Test.setCurrentPage( pg );

          ApexPages.StandardController sc1 = new ApexPages.StandardController(caseList[0]);
      
          VFC07_CaseRequiredDocuments controller = new VFC07_CaseRequiredDocuments(sc1);
          
          system.debug('## controller: '+controller);
          controller.allowUpdate();

          system.debug('## controller.docResults: '+controller.docResults);
          for(VFC07_CaseRequiredDocuments.retrieveDocW r: controller.docResults){
            r.selected = true;
          }
          controller.save();
       test.stopTest();
       c = [Select RequiredDocumentList__c from Case where Id = :caseList[0].Id];
       system.debug('## c: '+c);
       system.assertNotEquals('',c.RequiredDocumentList__c);
       
    }

    static testMethod void test_requiredDoc2() {
       Case c;
       test.startTest();
            PageReference pg = Page.VFP07_CaseRequiredDocuments;
          
          Test.setCurrentPage( pg );

          ApexPages.StandardController sc1 = new ApexPages.StandardController(caseList[1]);
      
          VFC07_CaseRequiredDocuments controller = new VFC07_CaseRequiredDocuments(sc1);
          
          system.debug('## controller: '+controller);
          controller.allowUpdate();
          for(VFC07_CaseRequiredDocuments.retrieveDocW r: controller.docResults){
            r.selected = true;
          }
          controller.save();
          
       test.stopTest();
       c = [Select RequiredDocumentList__c from Case where Id = :caseList[1].Id];
       system.debug('## c: '+c);
       system.assertNotEquals('',c.RequiredDocumentList__c);       
    }   
 
     static testMethod void test_requiredDoc3() {
       Case c;
       test.startTest();
            PageReference pg = Page.VFP07_CaseRequiredDocuments;
          
          Test.setCurrentPage( pg );

          ApexPages.StandardController sc1 = new ApexPages.StandardController(caseList[2]);
      
          VFC07_CaseRequiredDocuments controller = new VFC07_CaseRequiredDocuments(sc1);
          
          system.debug('## controller: '+controller);
          controller.allowUpdate();
          for(VFC07_CaseRequiredDocuments.retrieveDocW r: controller.docResults){
            r.selected = true;
          }
          controller.save();
          
       test.stopTest();
        c = [Select RequiredDocumentList__c from Case where Id = :caseList[2].Id];
       system.debug('## c: '+c);
       system.assertNotEquals('',c.RequiredDocumentList__c);      
    }

      static testMethod void test_requiredDoc4() {
       Case c;
       test.startTest();
            PageReference pg = Page.VFP07_CaseRequiredDocuments;
          
          Test.setCurrentPage( pg );

          ApexPages.StandardController sc1 = new ApexPages.StandardController(caseList[3]);
      
          VFC07_CaseRequiredDocuments controller = new VFC07_CaseRequiredDocuments(sc1);
          
          system.debug('## controller: '+controller);
          controller.allowUpdate();
          controller.save();
          
       test.stopTest();
       c = [Select RequiredDocumentList__c from Case where Id = :caseList[3].Id];
       system.debug('## c: '+c);
    } 

     static testMethod void test_requiredDoc5() {
       Case c;
       test.startTest();
            PageReference pg = Page.VFP07_CaseRequiredDocuments;
          
          Test.setCurrentPage( pg );

          ApexPages.StandardController sc1 = new ApexPages.StandardController(caseList[4]);
      
          VFC07_CaseRequiredDocuments controller = new VFC07_CaseRequiredDocuments(sc1);
          
          system.debug('## controller: '+controller);
          controller.allowUpdate();
          controller.save();
          
       test.stopTest();
       c = [Select RequiredDocumentList__c from Case where Id = :caseList[4].Id];
       system.debug('## c: '+c);
    }  

     static testMethod void test_noAccCase() {
       Case c;
       test.startTest();
            PageReference pg = Page.VFP07_CaseRequiredDocuments;
          
          Test.setCurrentPage( pg );

          ApexPages.StandardController sc1 = new ApexPages.StandardController(caseList[5]);
      
          VFC07_CaseRequiredDocuments controller = new VFC07_CaseRequiredDocuments(sc1);
          
          system.debug('## controller: '+controller);
          controller.allowUpdate();
          controller.save();
       c = [Select RequiredDocumentList__c from Case where Id = :caseList[5].Id];
       system.debug('## c: '+c);
       system.assertNotEquals('',c.RequiredDocumentList__c);
          
       test.stopTest();
    }  
}