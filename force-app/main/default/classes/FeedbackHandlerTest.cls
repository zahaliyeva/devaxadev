@isTest
public class FeedbackHandlerTest{
    static testmethod void TestFeedbackHandler(){
        
       
        Map<string,Map<string,string>> rtypes = UtilityClass.fetchAllRTypes();
        id account_B2C = UtilityClass.getRTid(rtypes, 'Account', 'B2C_Client');
        //id Feedback_AAI = UtilityClass.getRTid(rtypes, 'Feedback__c', 'AAI_Feedback');
        id ClaimSurvey = UtilityClass.getRTid(rtypes, 'Feedback__c', 'ClaimSurvey');
        id PhoneSurvey= UtilityClass.getRTid(rtypes, 'Feedback__c', 'PhoneSurvey');
        id chatSurvey= UtilityClass.getRTid(rtypes, 'Feedback__c', 'ChatSurvey');
        id ACQRINSurvey= UtilityClass.getRTid(rtypes, 'Feedback__c', 'Acquisto_Rinnovo');
        
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        
        Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
        User portalAccountOwner1 = new User(
            UserRoleId = portalRole.Id,
            ProfileId = profile1.Id,
            Username = System.now().millisecond() + 'test2@test.com' + System.now().millisecond(), //CAPOBIANCO_A Aggiunto il 2° System.now
            Alias = 'batman',
            Email='bruce.wayne@wayneenterprises.com',
            EmailEncodingKey='UTF-8',
            Firstname='Bruce',
            Lastname='Wayne',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago'
        );
        insert portalAccountOwner1; 
        
        //OAVERSANO 27/11/2018 : ICF Close The Loop -- START
        Group grp = new Group();
        	grp.name = 'Coda Agenzia Case 00828';
        	grp.Type = 'Queue'; 
        	Insert grp; 
 
            //Create Group Member
            GroupMember grpMem1 = new GroupMember();
            grpMem1.UserOrGroupId = portalAccountOwner1.Id;
            grpMem1.GroupId = grp.Id;
            Insert grpMem1;
        //OAVERSANO 27/11/2018 : ICF Close The Loop -- END
        
        
        System.runAs ( portalAccountOwner1 ) {
            
            AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
            insert acv;
			//OAVERSANO 27/11/2018 : ICF Close The Loop -- START
			String orgWideId;
			for(OrgWideEmailAddress owa : [select id, Address, DisplayName from OrgWideEmailAddress]) 
            {
				orgWideId = owa.id; 
            } 
             //MDANTONIO 09/04/2019 popolamento custom settings per classi di test - start
            ServiceUtilsClass.populateCustomSettingsForTests();
            //MDANTONIO 09/04/2019 popolamento custom settings per classi di test - end
            //OAVERSANO 27/11/2018 : ICF Close The Loop -- END
            List<MPS_Code_Variables__c> MCV = new List<MPS_Code_Variables__c>{
                                              new MPS_Code_Variables__c (Name='SendSurveyClaimToAgency',Value__c='false'),
                                              new MPS_Code_Variables__c (Name='SendSurveyAcquistoToAgency',Value__c='true'),
                                              new MPS_Code_Variables__c (Name='CTL_Template_Positive_Feedback_Email',Value__c=orgWideId),
                                              new MPS_Code_Variables__c (Name='CTL_Template_Positive_Feedback',Value__c='Ricezione_feedback_positivo'),
                                              new MPS_Code_Variables__c (Name='CloseTheLoop_AgenciesAvailable',Value__c='000828;'),
                                                  new MPS_Code_Variables__c (Name='ICF_Agent_Alert_1',Key__c='1'),
                                                  new MPS_Code_Variables__c (Name='ICF_Agent_Alert_2',Key__c='2')
                                            };
            insert MCV;
            
            // Create B2C Account
            Account b2cClient1 = new Account(FirstName = 'Test',
                                             LastName = 'B2C Account',
                                             RecordTypeId = account_B2C,
                                             Nodes__c = '5014'
                                            );
            
            Database.insert(b2cClient1);
            
            //OAVERSANO 09/07/2018 Close The Loop ICF -- START
            // Create B2C Account
            Account b2cClient2 = new Account(FirstName = 'Test',
                                             LastName = 'B2C Account2',
                                             RecordTypeId = account_B2C,
                                             Nodes__c = '5014',
                                             Fiscal_ID__c = '0099887'
                                            );
            Database.insert(b2cClient2);
            Account b2cClient3 = new Account(FirstName = 'Test',
                                             LastName = 'B2C Account2',
                                             RecordTypeId = account_B2C,
                                             Nodes__c = '5014',
                                             NDG__c = '009988766544332'
                                            );
            Database.insert(b2cClient3);
            // create case
            Case caseDB = new Case(Complainant__c = 'Agente',
                                  Distribution_Network__c = 'MPS',
                                  accountId = b2cClient3.Id);
            Database.insert(caseDB);
            // Create Lead
            Test.startTest();
            Lead leadDB = new Lead(LastName = 'cognome',
                                   ASA__c = '1 - Auto',  
                                   Phone = '0032543535',
                                   MobilePhone = '0032543535',
                                   Email = 'email@email.it',
                                   Fiscal_ID__c = '004567');
            Database.insert(leadDB);
            
            //OAVERSANO 09/07/2018 Close The Loop ICF -- END
            
            
            /*
                //Create Interazione__c   
                
                Interazione__c interazione = new Interazione__c (Account__c = b2cClient1.Id,
                Stato__c = 'Questionario inviato',
                TECH_Da_inviare__c =false,
                Tipologia__c = 'Altro',
                Tipologia_prodotto__c= 'AUTO'
                );
                insert interazione;
                
      */
            
            // Create Feedback__c Records
            Feedback__c feedback = new Feedback__c(Account__c =  b2cClient1.Id,
                                                   RecordTypeId = ClaimSurvey,
                                                   NDG__c = '0032543535',
                                                   Fiscal_ID__c = 'TSTUSER89D081M'
                                                  );
            Database.insert(feedback);
            feedback.Company__c = 'AAI';
            update feedback;
            delete feedback;
            
            // Create Feedback__c Records
            Feedback__c feedback2 = new Feedback__c(Account__c =  b2cClient1.Id,
                                                    
                                                    RecordTypeId = PhoneSurvey
                                                   );
            Database.insert(feedback2);
            
            /*
                // Update Feedback
                feedback.AAI_Commenti__c = 'Ottima esperienza';
                update feedback;
                
                
                //Delete and Undelete Feedback
                delete feedback;
                undelete feedback;
            */
            //OAVERSANO 09/07/2018 Close The Loop ICF -- START
            Feedback__c feedback3 = new Feedback__c(Account__c =  b2cClient1.Id,
                                                    RecordTypeId = ClaimSurvey,
                                                    Mobile_Phone__c = '0032543535',
                                                    Fiscal_ID__c = '0099887',
                                                    Email__c = 'email@email.it'
                                                   );
            Database.insert(feedback3);
            Feedback__c feedback4 = new Feedback__c(Account__c =  b2cClient1.Id,
                                                    RecordTypeId = ClaimSurvey,
                                                    Mobile_Phone__c = '0032543535',
                                                    NDG__c = '009988766544332',
                                                    Email__c = 'email@email.it',
                                                    Company__c = 'AAI'
                                                   );
            Database.insert(feedback4);
            Feedback__c feedback5 = new Feedback__c(Account__c =  b2cClient1.Id,
                                                    RecordTypeId = ClaimSurvey,
                                                    Mobile_Phone__c = '0032543535',
                                                    Fiscal_ID__c = '004567',
                                                    //OAVERSANO 27/11/2018 : ICF Close The Loop -- START
                                                    Agency_Code__c = '00828',
                                                    Survey_Origin__c = 'Survey Acquisto P&C AAI',
                                                    NPS__c = 9,
                                                    //OAVERSANO 27/11/2018 : ICF Close The Loop -- END
                                                    Email__c = 'email@email.it'
                                                   );
            Database.insert(feedback5);
            Feedback__c feedback6 = new Feedback__c(Account__c =  b2cClient1.Id,
                                                    RecordTypeId = chatSurvey,
                                                    Mobile_Phone__c = '0032543343',
                                                    Fiscal_ID__c = '004534',
                                                    Email__c = 'prova@email.it',
                                                    FeedbackComments__c = 'ciaone',
                                                    Rating1__c = 1,
                                                    Rating2__c = 0,
                                                    Rating3__c = 0,
                                                    Rating4__c = 1,
                                                    Complaint__c =caseDB.Id
                                                   );
            Database.insert(feedback6);
            Feedback__c feedback7 = new Feedback__c(Account__c =  b2cClient1.Id,
                                                    RecordTypeId = ACQRINSurvey,
                                                    Mobile_Phone__c = '0032543343',
                                                    Fiscal_ID__c = '004534',
                                                    Email__c = 'prova@email.it',
                                                    FeedbackComments__c = 'ciaone',
                                                    Rating1__c = 1,
                                                    Rating2__c = 0,
                                                    Rating3__c = 0,
                                                    Rating4__c = 1,
                                                    Agency_Code__c = '00828',
                                                    Survey_Origin__c = 'Survey Acquisto P&C AAI',
                                                    NPS__c = 9,
                                                    CDL_needed__c = false,
                                                    Complaint__c =caseDB.Id
                                                   );
            Database.insert(feedback7);
            Feedback__c feedback8 = new Feedback__c(Account__c =  b2cClient1.Id,
                                                    RecordTypeId = ACQRINSurvey,
                                                    Mobile_Phone__c = '0032543343',
                                                    Fiscal_ID__c = '004534',
                                                    Email__c = 'prova@email.it',
                                                    FeedbackComments__c = 'ciaone',
                                                    Rating1__c = 1,
                                                    Rating2__c = 0,
                                                    Rating3__c = 0,
                                                    Rating4__c = 1,
                                                    Agency_Code__c = '00828',
                                                    Survey_Origin__c = 'Survey Acquisto P&C AAI',
                                                    NPS__c = 9,
                                                    CDL_needed__c = true,
                                                    Complaint__c =caseDB.Id
                                                   );
            Database.insert(feedback8);
            Test.stopTest();
            //OAVERSANO 09/07/2018 Close The Loop ICF -- END
        }   
    }   
}