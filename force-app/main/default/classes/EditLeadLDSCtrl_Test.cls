@isTest
private class EditLeadLDSCtrl_Test {

//CAPOBIANCO_A 23/06/2017 -- START
    static account accountTest;
    static user userAdmin;
    static map<String,Id> acc_developerIdMap;
    static map<String,Id> case_developerIdMap;
    static map<String,Id> lead_developerIdMap;
    static list<Case> caseList;
    static list<Account> accList;
    static list<Lead> leadList;
    static id idAccount;
    static id idLead;
    static Task newTask;
    static Lead leadInserted;
    //CAPOBIANCO_A 05/01/2018 -- START
    //static id recordtypeAuto {get;set;}
    static id recordtypeAAI {get;set;}
    //CAPOBIANCO_A 05/01/2018 -- END
    
    static{

        //User
        userAdmin = new User(Username = 'testclassNewActivityLead@test.com',
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
        
        system.runas(userAdmin){

            acc_developerIdMap = AP_Constants.getDeveloperIdMap(AP_Constants.sobjectAcc);
            case_developerIdMap = AP_Constants.getDeveloperIdMap(AP_Constants.sobjectCas); 
            lead_developerIdMap = AP_Constants.getDeveloperIdMap('Lead');
            //CAPOBIANCO_A 05/01/2018 -- START
            //recordtypeAuto = [SELECT Id,name FROM RecordType WHERE Name = 'Auto' AND SobjectType = 'Lead'].Id;
            recordtypeAAI = [SELECT Id,name FROM RecordType WHERE Name = 'Lead AXA Assicurazioni' AND SobjectType = 'Lead'].Id; 
            //CAPOBIANCO_A 05/01/2018 -- END

            leadList = new list<Lead>{
                new Lead(FirstName ='John',
                            LastName= 'Smith',
                            Email = 'john.smith@axa-italy-devtest.com',    
                            Phone = '123456',
                            Status = 'To be processed',
                            //CAPOBIANCO_A 05/01/2018 -- START
                            //RecordTypeId = recordtypeAuto,
                            RecordTypeId = recordtypeAAI,
                            //CAPOBIANCO_A 05/01/2018 -- END
                            Ultima_data_di_riassegnazione__c = system.today(),
                            Contact_Date__c = System.today()-1
                ),
                new Lead(FirstName ='Robert',
                            LastName= 'White',
                            Email = 'john.smith@axa-italy-devtest.com',    
                            Phone = '123456',
                            Status = 'To be processed',
                            Fiscal_ID__c = 'BBB111',
                            Agency_Code__c ='000828',
                            RecordTypeId = recordtypeAAI,
                            Ultima_data_di_riassegnazione__c = system.today(),
                            Contact_Date__c = System.today()-1
                )
            //CAPOBIANCO_A 18/01/2018: SPRINT 59 -- START
            };

            insert leadList; 

            //Account
            accountTest = new Account(FirstName ='JohnAxa',
                            LastName= 'Smith',
                            PersonEmail = 'johnaxa.smith@axa-italy-devtest.com',
                            RecordTypeId = acc_developerIdMap.get(AP_Constants.rtAccB2C),
                            AAI_Codice_fiscale__c = '56451',
                            PersonBirthdate = date.today()
            );

            insert accountTest;       
               
        }
    }
    
    //simple update scenario - success
    static testMethod void editLeadScenario1_Test() {
        system.debug('#### Start of method editLeadScenario1_Test');
         system.runAs(userAdmin){
            
            test.starttest();              

                PageReference pageRef = Page.EditLeadLDS;
                Test.setCurrentPage(pageRef);

                ApexPages.StandardController sc = new ApexPages.StandardController(leadList[0]);
                EditLeadLDSCtrl editLeadCtrl = new EditLeadLDSCtrl(sc);

                editLeadCtrl.leadToUpdate.Phone = '1234567';
                editLeadCtrl.leadToUpdate.Status = 'Not interested'; //CAPOBIANCO_A 18/01/2018: SPRINT 59
                List<Account> accountQuery = EditLeadLDSCtrl.queryContacts('JohnAxa Smith');
                editLeadCtrl.LookUpIds = accountTest.Id;
                //CAPOBIANCO_A 18/01/2018: SPRINT 59 -- START
                editLeadCtrl.getSottostatoList();
                editLeadCtrl.selectSubStatus();
                system.assertEquals(editLeadCtrl.showSubStatus, true);
                editLeadCtrl.hideSubStatus();
                //CAPOBIANCO_A 18/01/2018: SPRINT 59 -- END
                editLeadCtrl.savecomplete();
                
            test.stoptest();
            

            list<Lead> leadAsrtList = [Select Phone
                                        From Lead
                                        Where Id =: leadList[0].Id];

            system.assertEquals(leadAsrtList[0].Phone, '1234567');
            system.assertEquals(accountQuery[0].Id, accountTest.Id);
         }
    }

    //wrong contact scenario - success
    static testMethod void editLeadScenario2_Test() {
        system.debug('#### Start of method editLeadScenario2_Test');
         system.runAs(userAdmin){
            
            test.starttest();              

                PageReference pageRef = Page.EditLeadLDS;
                Test.setCurrentPage(pageRef);

                ApexPages.StandardController sc = new ApexPages.StandardController(leadList[0]);
                EditLeadLDSCtrl editLeadCtrl = new EditLeadLDSCtrl(sc);

                editLeadCtrl.leadToUpdate.Status = 'Wrong contact information';
                editLeadCtrl.LeadToUpdate.Phone = '12345';
                editLeadCtrl.LookUpIds = accountTest.Id;
                editLeadCtrl.savecomplete();
                editLeadCtrl.actionOption1();

            test.stoptest();

            list<Lead> leadAsrtList = [Select OwnerId,Phone
                                        From Lead
                                        Where Id =: leadList[0].Id];

            system.assertEquals(editLeadCtrl.ShowAlertStato, true);
            system.assertEquals(editLeadCtrl.valueButton1, 'Conferma');
            system.assertEquals(editLeadCtrl.valueButton2, 'Annulla');
            system.assertEquals(editLeadCtrl.showOption2, true);
            system.assertEquals(leadAsrtList[0].Phone, '12345');
            system.assertEquals(String.valueOf(leadAsrtList[0].OwnerId).left(3),'00G'); //the new owner is a queue
            
         }
    }

    //call again scenario - success
    static testMethod void editLeadScenario3_Test() {
        system.debug('#### Start of method editLeadScenario3_Test');
         system.runAs(userAdmin){
            
            test.starttest();              

                PageReference pageRef = Page.EditLeadLDS;
                Test.setCurrentPage(pageRef);

                ApexPages.StandardController sc = new ApexPages.StandardController(leadList[0]);
                EditLeadLDSCtrl editLeadCtrl = new EditLeadLDSCtrl(sc);

                editLeadCtrl.leadToUpdate.Status = 'Call again';
                editLeadCtrl.leadToUpdate.Phone = '12345678';
                editLeadCtrl.LookUpIds = accountTest.Id;
                editLeadCtrl.savecomplete();
                editLeadCtrl.actionOption1();

            test.stoptest();

            list<Lead> leadAsrtList = [Select Status, Phone
                                        From Lead
                                        Where Id =: leadList[0].Id];

            system.assertEquals(leadAsrtList[0].Phone, '12345678');
            system.assertEquals(leadAsrtList[0].Status, 'To be processed');
            system.assertEquals(editLeadCtrl.taskOrEvent, 'Task');
            
         }
    }

    //appointment scenario - success
    static testMethod void editLeadScenario4_Test() {
        system.debug('#### Start of method editLeadScenario4_Test');
         system.runAs(userAdmin){
            
            test.starttest();              

                PageReference pageRef = Page.EditLeadLDS;
                Test.setCurrentPage(pageRef);

                ApexPages.StandardController sc = new ApexPages.StandardController(leadList[0]);
                EditLeadLDSCtrl editLeadCtrl = new EditLeadLDSCtrl(sc);

                editLeadCtrl.leadToUpdate.Status = 'Appointment';
                editLeadCtrl.leadToUpdate.Phone = '12345678';
                editLeadCtrl.LookUpIds = accountTest.Id;
                editLeadCtrl.savecomplete();
                editLeadCtrl.actionOption1();

            test.stoptest();

            list<Lead> leadAsrtList = [Select Status, Phone
                                        From Lead
                                        Where Id =: leadList[0].Id];

            system.assertEquals(leadAsrtList[0].Phone, '12345678');
            system.assertEquals(leadAsrtList[0].Status, 'To be processed');
            system.assertEquals(editLeadCtrl.taskOrEvent, 'Event');
            
         }
    }

    //simple update scenario - failure
    static testMethod void editLeadScenario5_Test() {
        system.debug('#### Start of method editLeadScenario5_Test');
         system.runAs(userAdmin){
            
            test.starttest();              

                PageReference pageRef = Page.EditLeadLDS;
                Test.setCurrentPage(pageRef);

                ApexPages.StandardController sc = new ApexPages.StandardController(leadList[0]);
                EditLeadLDSCtrl editLeadCtrl = new EditLeadLDSCtrl(sc);

                editLeadCtrl.leadToUpdate.Phone = '1234567';
                editLeadCtrl.leadToUpdate.Status = 'Not interested'; //CAPOBIANCO_A 18/01/2018: SPRINT 59
                editLeadCtrl.leadToUpdate.AAI_Partita_IVA__c = '123';
                editLeadCtrl.savecomplete();
                
            test.stoptest();
            

            list<Lead> leadAsrtList = [Select Phone
                                        From Lead
                                        Where Id =: leadList[0].Id];

            system.assertEquals(leadAsrtList[0].Phone, '123456'); //unchanged
            system.assertEquals(editLeadCtrl.showError, true);
         }
    }

    //wrong contact scenario - failure
    static testMethod void editLeadScenario6_Test() {
        system.debug('#### Start of method editLeadScenario6_Test');
         system.runAs(userAdmin){
            
            test.starttest();              

                PageReference pageRef = Page.EditLeadLDS;
                Test.setCurrentPage(pageRef);

                ApexPages.StandardController sc = new ApexPages.StandardController(leadList[0]);
                EditLeadLDSCtrl editLeadCtrl = new EditLeadLDSCtrl(sc);

                editLeadCtrl.leadToUpdate.Status = 'Wrong contact information';
                editLeadCtrl.LeadToUpdate.Phone = '12345';
                editLeadCtrl.leadToUpdate.AAI_Partita_IVA__c = '123';
                editLeadCtrl.savecomplete();
                editLeadCtrl.actionOption1();

            test.stoptest();

            list<Lead> leadAsrtList = [Select OwnerId,Phone
                                        From Lead
                                        Where Id =: leadList[0].Id];

            system.assertEquals(leadAsrtList[0].OwnerId, userAdmin.Id); //unchanged
            system.assertEquals(leadAsrtList[0].Phone, '123456'); //unchanged
            system.assertEquals(editLeadCtrl.showError, true);
            
         }
    }

    //call again scenario - failure
    static testMethod void editLeadScenario7_Test() {
        system.debug('#### Start of method editLeadScenario7_Test');
         system.runAs(userAdmin){
            
            test.starttest();              

                PageReference pageRef = Page.EditLeadLDS;
                Test.setCurrentPage(pageRef);

                ApexPages.StandardController sc = new ApexPages.StandardController(leadList[0]);
                EditLeadLDSCtrl editLeadCtrl = new EditLeadLDSCtrl(sc);

                editLeadCtrl.leadToUpdate.Status = 'Call again';
                editLeadCtrl.leadToUpdate.Phone = '12345678';
                editLeadCtrl.leadToUpdate.AAI_Partita_IVA__c = '123';
                editLeadCtrl.savecomplete();
                editLeadCtrl.actionOption1();

            test.stoptest();

            list<Lead> leadAsrtList = [Select Status, Phone
                                        From Lead
                                        Where Id =: leadList[0].Id];

            system.assertEquals(leadAsrtList[0].Phone, '123456'); //unchanged
            system.assertEquals(editLeadCtrl.showError, true);
            
         }
    }

    //appointment scenario - failure
    static testMethod void editLeadScenario8_Test() {
        system.debug('#### Start of method editLeadScenario8_Test');
         system.runAs(userAdmin){
            
            test.starttest();              

                PageReference pageRef = Page.EditLeadLDS;
                Test.setCurrentPage(pageRef);

                ApexPages.StandardController sc = new ApexPages.StandardController(leadList[0]);
                EditLeadLDSCtrl editLeadCtrl = new EditLeadLDSCtrl(sc);

                editLeadCtrl.leadToUpdate.Status = 'Appointment';
                editLeadCtrl.leadToUpdate.Phone = '12345678';
                editLeadCtrl.leadToUpdate.AAI_Partita_IVA__c = '123';
                editLeadCtrl.savecomplete();
                editLeadCtrl.actionOption1();

            test.stoptest();

            list<Lead> leadAsrtList = [Select Status, Phone
                                        From Lead
                                        Where Id =: leadList[0].Id];

            system.assertEquals(leadAsrtList[0].Phone, '123456'); //unchanged
            system.assertEquals(editLeadCtrl.showError, true);
            
         }
    }

    static testMethod void editLeadGettersTest(){

        system.debug('#### Start of method editLeadScenario8_Test');
         system.runAs(userAdmin){
            
            test.starttest();              

                PageReference pageRef = Page.EditLeadLDS;
                Test.setCurrentPage(pageRef);

                ApexPages.StandardController sc = new ApexPages.StandardController(leadList[0]);
                EditLeadLDSCtrl editLeadCtrl = new EditLeadLDSCtrl(sc);

                editLeadCtrl.gethourList();
                editLeadCtrl.getorigineList();
                editLeadCtrl.getprovnascitaList();
                editLeadCtrl.getlineList();
                editLeadCtrl.getmotivoList();
                editLeadCtrl.getanimalList();
                editLeadCtrl.getetanimalList();
                editLeadCtrl.getbusinessList();
                editLeadCtrl.getprofessionList();
                editLeadCtrl.getCountryList();
                editLeadCtrl.getStateList();


            test.stoptest();

            system.assertEquals(editLeadCtrl.showMessage, null);

        }
    }

    static testMethod void changeCountry_test(){

        system.debug('#### Start of method changeCountry_test');
         system.runAs(userAdmin){
            
            test.starttest();              

                PageReference pageRef = Page.EditLeadLDS;
                Test.setCurrentPage(pageRef);

                ApexPages.StandardController sc = new ApexPages.StandardController(leadList[0]);
                EditLeadLDSCtrl editLeadCtrl = new EditLeadLDSCtrl(sc);

                editLeadCtrl.leadToUpdate.CountryCode = 'Italy';
                editLeadCtrl.changeCountry();
                system.assertEquals(editLeadCtrl.showForeignAddress, false);

                editLeadCtrl.leadToUpdate.CountryCode = 'France';
                editLeadCtrl.changeCountry();
                system.assertEquals(editLeadCtrl.showForeignAddress, true);

            test.stoptest();

        }
    }

    static testMethod void editLeadActionOption2_Test() {
        system.debug('#### Start of method ActionOption2_Test');
         system.runAs(userAdmin){
            
            test.starttest();              

                PageReference pageRef = Page.EditLeadLDS;
                Test.setCurrentPage(pageRef);

                ApexPages.StandardController sc = new ApexPages.StandardController(leadList[0]);
                EditLeadLDSCtrl editLeadCtrl = new EditLeadLDSCtrl(sc);

                editLeadCtrl.leadToUpdate.Status = 'Appointment';
                editLeadCtrl.leadToUpdate.Phone = '12345678';
                editLeadCtrl.leadToUpdate.AAI_Partita_IVA__c = '123';
                editLeadCtrl.savecomplete();
                editLeadCtrl.actionOption2();

            test.stoptest();

            list<Lead> leadAsrtList = [Select Status, Phone
                                        From Lead
                                        Where Id =: leadList[0].Id];

            system.assertEquals(leadAsrtList[0].Phone, '123456'); //unchanged
            
         }
    }

    static testMethod void editLeadElseInStatusSuccess_Test() {
        system.debug('#### Start of method editLeadElseInStatus_Test');
         system.runAs(userAdmin){
            
            test.starttest();              

                PageReference pageRef = Page.EditLeadLDS;
                Test.setCurrentPage(pageRef);

                ApexPages.StandardController sc = new ApexPages.StandardController(leadList[0]);
                EditLeadLDSCtrl editLeadCtrl = new EditLeadLDSCtrl(sc);

                editLeadCtrl.leadToUpdate.Status = 'Else';
                editLeadCtrl.leadToUpdate.Phone = '12345678';
                editLeadCtrl.actionOption1();

            test.stoptest();

            list<Lead> leadAsrtList = [Select Status, Phone
                                        From Lead
                                        Where Id =: leadList[0].Id];

            system.assertEquals(leadAsrtList[0].Phone, '12345678');
            system.assertEquals(leadAsrtList[0].Status, 'Else');
            
         }
    }

    static testMethod void editLeadElseInStatusFailure_Test() {
        system.debug('#### Start of method editLeadElseInStatus_Test');
         system.runAs(userAdmin){
            
            test.starttest();              

                PageReference pageRef = Page.EditLeadLDS;
                Test.setCurrentPage(pageRef);

                ApexPages.StandardController sc = new ApexPages.StandardController(leadList[0]);
                EditLeadLDSCtrl editLeadCtrl = new EditLeadLDSCtrl(sc);

                editLeadCtrl.leadToUpdate.Status = 'Else';
                editLeadCtrl.leadToUpdate.Phone = '12345678';
                editLeadCtrl.leadToUpdate.AAI_Partita_IVA__c = '123';
                editLeadCtrl.actionOption1();

            test.stoptest();

            list<Lead> leadAsrtList = [Select Status, Phone
                                        From Lead
                                        Where Id =: leadList[0].Id];

            system.assertEquals(leadAsrtList[0].Phone, '123456'); //unchanged
            
         }
    }
    //CAPOBIANCO_A 23/06/2017 -- END
    //CAPOBIANCO_A 18/01/2018: SPRINT 59
    //Status duplicated bu not really duplicated with another Lead
    static testMethod void editLeadLeadDuplicatedScenario1_Test() {
        system.debug('#### Start of method editLeadLeadDuplicatedScenario1_Test');
         system.runAs(userAdmin){
            
            test.starttest();              

                PageReference pageRef = Page.EditLeadLDS;
                Test.setCurrentPage(pageRef);

                ApexPages.StandardController sc = new ApexPages.StandardController(leadList[0]);
                EditLeadLDSCtrl editLeadCtrl = new EditLeadLDSCtrl(sc);

                editLeadCtrl.leadToUpdate.Status = 'Duplicated lead';
                editLeadCtrl.leadToUpdate.Phone = '12345678';
                editLeadCtrl.leadToUpdate.AAI_Partita_IVA__c = '123';
                editLeadCtrl.savecomplete();
                editLeadCtrl.actionOption1();

            test.stoptest();

            system.assertEquals(editLeadCtrl.showAlertStato, false);
            system.assertEquals(editLeadCtrl.showErrorStato, false);
            
         }
    }

    //Status Duplicated and really duplicated with another Lead
    static testMethod void editLeadLeadDuplicatedScenario2_Test() {
        system.debug('#### Start of method editLeadLeadDuplicatedScenario2_Test');
         system.runAs(userAdmin){
            
            test.starttest();              

                PageReference pageRef = Page.EditLeadLDS;
                Test.setCurrentPage(pageRef);

                ApexPages.StandardController sc = new ApexPages.StandardController(leadList[0]);
                EditLeadLDSCtrl editLeadCtrl = new EditLeadLDSCtrl(sc);

                editLeadCtrl.leadToUpdate.Status = 'Duplicated lead';
                editLeadCtrl.leadToUpdate.Phone = '12345678';
                editLeadCtrl.leadToUpdate.FirstName = 'Robert';
                editLeadCtrl.leadToUpdate.LastName = 'White';
                editLeadCtrl.leadToUpdate.Agency_Code__c = '000828';
                editLeadCtrl.leadToUpdate.Fiscal_ID__c = 'BBB111';
                editLeadCtrl.savecomplete();
                editLeadCtrl.actionOption1();

            test.stoptest();

            system.assertEquals(editLeadCtrl.showAlertStato, false);
            system.assertEquals(editLeadCtrl.showErrorStato, false);
            
         }
    }
    //CAPOBIANCO_A 18/01/2018: SPRINT 59 --END
}