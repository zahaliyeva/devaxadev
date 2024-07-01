@isTest
private class UpdateMilestoneTimeTriggerTest {

    static user userAdmin;
    static Account clientAcc;
    static map<String,Id> acc_developerIdMap;
    static map<String, ID> mapRTAcc = AP_Constants.getDeveloperIdMap(AP_Constants.sobjectAcc);
    
    
     static testMethod void testMilestoneTimeCalculator() {
        //MDANTONIO 09/04/2019 popolamento custom settings per classi di test - start
        ServiceUtilsClass.populateCustomSettingsForTests();
        //MDANTONIO 09/04/2019 popolamento custom settings per classi di test - end
     
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
                            ProfileId = AP_Constants.getProfileAdminId()
         );
                        
        insert userAdmin;
        system.runAs(userAdmin){
        
                    acc_developerIdMap = AP_Constants.getDeveloperIdMap(AP_Constants.sobjectAcc);
            clientAcc = new Account(FirstName ='Jane',
                                LastName= 'Smith',
                                PersonEmail = 'jane.smith@axa-italy-devtest.com',
                                RecordTypeId = acc_developerIdMap.get(AP_Constants.rtAccIndividualClient),
                                Matricola__c='123'
                                );
        
           insert clientAcc;
            
        // PETRECCHIA_M 15122016: EVO-24-----START
        id idAccount = [Select Id from Account where PersonEmail = 'jane.smith@axa-italy-devtest.com'].Id;
        
        date mydate = date.today();
        
        Entitlement en = new Entitlement();
        en.Name='TestEntitlement';
        en.AccountId = idAccount;
        en.StartDate = mydate;
        insert en;}
        // PETRECCHIA_M 15122016: EVO-24-----END
     //creazione SLA
    insert new CaseSLA__c(Category__c ='1',SubCategory__c ='2',name='k',PhoneTotalHours__c=100);
     Case cas = new Case (priority='High', category__c='1',SubCategory__c='2');
    insert cas; 
    
                    test.starttest();
                    cas.Category__c='1';
                    cas.SubCategory__c='2';
                    cas.Origin=AP_Constants.caseOriginPhone;
                    cas.SLAHours__c=20;
                    update cas;
                test.stoptest();
     
     
    UpdateMilestoneTimeTrigger calculator = new UpdateMilestoneTimeTrigger();
    Integer actualTriggerTime = calculator.calculateMilestoneTriggerTime(cas.Id,cas.Id);

    system.assertEquals(cas.SLAHours__c,20);
     }
     
     }