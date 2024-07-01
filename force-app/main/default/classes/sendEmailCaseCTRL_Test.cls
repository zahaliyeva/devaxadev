@isTest
private class sendEmailCaseCTRL_Test {
  @testSetup static void setup()
    {
      //Retrieving informations about profiles and roles
        list<Profile> profiles = [SELECT Id,Name FROM Profile WHERE Name in ('NFE - AAI - Vendite Avanzato','System Administrator','NFE - AAI - Vendite Base') ]; 
        Profile pvenditeA;
        Profile sadmin;
        Profile pvenditeB;

        for (Profile p :profiles){
            if (p.Name=='NFE - AAI - Vendite Avanzato')
            {
                pvenditeA=p;
            }
            else if (p.Name=='System Administrator')
            {
                sadmin=p;
            }
            else if (p.Name=='NFE - AAI - Vendite Base')
            {
                pvenditeB=p;
            }
        }
        Id pVenA = pvenditeA.Id;
        Id pVenB = pvenditeB.Id; 
        Id pSadmin =  sadmin.Id;

        String caseStatusClosed = AP_Constants.caseStatusClosed;
        String caseStatusOpen = AP_Constants.caseStatusOpen;
        map<String,Id> case_developerIdMap = AP_Constants.getDeveloperIdMap(AP_Constants.sobjectCas);//MOSCATELLI_M 16072015: CR-15 
        //User
        User userAdmin = new User(Username = 'sendEmailCaseCTRL_Test@test.axa.com',
                            LastName = 'testuser',
                            LanguageLocaleKey = 'en_US',
                            FirstName = 'test',
                            Email = 'test@test.com',
                            Alias = 'test',
                            TimeZoneSidKey = 'Europe/Dublin',
                            LocaleSidKey = 'en_US',
                            EmailEncodingKey = 'UTF-8',
                            ProfileId = pSadmin,
                            ByPassVR__c = true);
        insert userAdmin; 
        
        system.runas(userAdmin){


            Map<string,Map<string,string>> rtypes = UtilityClass.fetchAllRTypes();
            id contact_agency = UtilityClass.getRTid(rtypes, 'Contact', 'Agency_Contact');
            id account_agency = UtilityClass.getRTid(rtypes, 'Account', 'Agency');

            //Creating the Agency Accounts with the relative Contacts
            List<Account> agencyList = new List<Account>
            {
              new Account(
                          RecordTypeId = account_agency,
                          Agency_Code__c = '999999',
                          Active__c = true,
                          Accordo_Digitale__c = true,
                          Name = 'AGENZIA PROVA'
                          )  
            };

            insert agencyList;
            agencyList[0].isPartner =true;
            update agencyList;
              
            List<Contact> contactList = new List<Contact> 
            {          
              
               new Contact(LastName = 'Agency Test Contact 1',
                           RecordtypeId = contact_agency,
                           AccountId = agencyList[0].Id
                           ),

               new Contact(LastName = 'Agency Test Contact 2',
                           RecordtypeId = contact_agency,
                           AccountId = agencyList[0].Id
                           )
            };

            insert contactList;
            RecordType accRT = [SELECT Id,IsPersonType FROM RecordType WHERE SObjectType = 'Account' and DeveloperName = 'B2C_Client' ];
            List<Account> accountz = new List<Account>{
                 new Account(
                FirstName = 'AccountTest99',
                LastName = 'AccountTest00',
                PersonEmail = 'account@mail.test',
                Phone = '0333333333',
                PersonMobilePhone = '3333333333',
                Nodes__c = '999999',
                AAI_Agency_Reference_Code__c = '999999',
                RecordTypeID = accRT.id
            ),new Account(
                FirstName = 'AccountTest11',
                LastName = 'AccountTest22',
                PersonEmail = 'account@mail.test',
                Phone = '03333333331111',
                PersonMobilePhone = '3333333333111',
                Nodes__c = '999999',
                AAI_Agency_Reference_Code__c = '999999',
                RecordTypeID = accRT.id
            )};
            insert accountz;


            //case
           list<Case> listCases = new list <Case>{
    
                new Case(Status = 'Assigned',
                            RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseMotor),
                            AccountId= accountz[0].Id,
                            Category__c ='Preventivi ed emissioni - polizze di auto',
                            SubCategory__c = 'Emissioni polizze off line',
                            SubCategoryDetail__c = 'Figure contrattuali',
                            Subject='su1'
                           )
            };
            insert listCases;
            system.debug('listCases:'+listCases);                     
         }


    }


    
    @isTest static void openPage() {
        Test.startTest();
        PageReference pageRef = Page.sendEmailCase;       
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('pgType', 'GestioneCampagna');
        Case cp = [select id, Status,Subject, RecordTypeID FROM Case  limit 1];
        sendEmailCaseCTRL controller = new sendEmailCaseCTRL(new ApexPages.StandardController(cp));
        Map<String,String> emailFolders = sendEmailCaseCTRL.getEmailFolders();
        Set<String> idSetFolders = emailFolders.keySet();
        Map<String,String> emailTemplates = sendEmailCaseCTRL.getEmailTemplates(new list<string>(idSetFolders) [0]);
        Set<String> idSetTemplates = emailTemplates.keySet();
        List<String> idListTemplates = new list<string>(idSetTemplates);
        String firstTemplate;
        list<Case_Email_Agency_Notification__mdt> templateSettings = new List<Case_Email_Agency_Notification__mdt>();
        String templateDevName = '';
        templateSettings = [SELECT Notify_Agency__c,Template_Developer_Name__c FROM Case_Email_Agency_Notification__mdt  limit 1];
        if(templateSettings.size()>0)
        {
            templateDevName = templateSettings[0].Template_Developer_Name__c;
            try{
            firstTemplate= [SELECT Id,DeveloperName FROM EmailTemplate WHERE DeveloperName = :templateDevName].Id;
            }catch (Exception e)
            {
                firstTemplate = idListTemplates[0];
            }
        }
        sendEmailCaseCTRL.FromObject FrmObj = new sendEmailCaseCTRL.FromObject();

        FrmObj = sendEmailCaseCTRL.getFromList();
        Set<String> idSetOwa = FrmObj.OrgWideAddrMap.keySet();
        String recordId = ''+cp.id;
        List<String> emailList = new  list<string>();
        emailList.add('spam@email.com');
        sendEmailCaseCTRL.ResponseDto response =  sendEmailCaseCTRL.populateTemplate(firstTemplate,cp.id);
        sendEmailCaseCTRL.ResponseDto response2 = sendEmailCaseCTRL.sendMailMethod(recordId, emailList, emailList, emailList,
                                      new list<string>(idSetOwa) [0], 'SOI', 'OOOOOOOO' ,new list<string>());
        sendEmailCaseCTRL.ResponseDto response3 =  sendEmailCaseCTRL.deleteAttachments (new list<String>(),recordId);
        //System.assertEquals(outcome.message, 'Unauthorized user');
        Test.stopTest();
    }
        
}