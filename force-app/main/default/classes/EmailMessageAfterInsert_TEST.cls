@isTest
public class EmailMessageAfterInsert_TEST {

	static User AdminUser;
    static List<User> UserList;
    static List<Case> CaseList;
    static List<Case> RelatedCaseList;
    static List<Account> AccountList;
    static List<Configurazione_SLA_Uffici_Tecnici__c> SLAConfigTaskList;
    static List<Definizione_Modelli_di_Servizio__c> DefModServList;
    static List<Apertura_automatica_Task__c> AutoTaskOpeningList;
    static Id AdvisorProfileId;
	static Id TechnicalOfficeProfileId;
    static String [] ProfileNames = new String []{'SmartCenter Motor Advisor','AMPS HD2 BIZ'};    
    static Map<String,Id> Acc_DeveloperIdMap;
  	static Map<String,Id> Case_DeveloperIdMap;  
    static list<ExternalPartnersInvolvement__c> CustomSettingList;//MOSCATELLI_M 28/10/2016: Evo71-ConnectedHome
    
    static
    {
        //MDANTONIO 09/04/2019 popolamento custom settings per classi di test - start
        ServiceUtilsClass.populateCustomSettingsForTests();
        //MDANTONIO 09/04/2019 popolamento custom settings per classi di test - end
        for(Profile p :[Select Id,Name from Profile where Name in:ProfileNames])
        {
            if(p.Name =='SmartCenter Motor Advisor')
                AdvisorProfileId = p.Id;
            else
                TechnicalOfficeProfileId = p.Id;
        }        
        
        Acc_DeveloperIdMap = AP_Constants.getDeveloperIdMap(AP_Constants.sobjectAcc);
        Case_DeveloperIdMap = AP_Constants.getDeveloperIdMap(AP_Constants.sobjectCas);
        
        AdminUser = new User(
                            Email ='TestAdm1@Test.com',
                            Username = 'TestAdm1@username.test',
                            FirstName='Test',
                            LastName='User',
                            Alias='tstusr',
                            TimeZoneSidKey = 'Europe/Dublin',
                            LocaleSidKey = 'en_US',
                            EmailEncodingKey = 'UTF-8',
                            LanguageLocaleKey = 'en_US',
                            ProfileId = AP_Constants.getProfileAdminId()
                        	);
		insert AdminUser;
        
        UserList 	= new list<User>{
            						 new User(FirstName='Test',
                                              LastName='One',
                                              Username='Tstone@username.test',
                                              Alias='Tstone',
                                              CommunityNickName='Tstone',
                                              TimeZoneSidKey = 'Europe/Dublin',
                                              LocaleSidKey = 'en_US',
                                              EmailEncodingKey = 'UTF-8',
                                              LanguageLocaleKey = 'en_US',
                                              phone='0324243421',
                                              Email='test@one.te',
                                              ProfileId=AdvisorProfileId,
                                              isActive=true
                                             ),
                                     new User(FirstName='Test',
                                              LastName='Two',                                              
                                              Username='Tsttwo@username.test',
                                              Alias='Tsttwo',
                                              CommunityNickName='Tsttwo',
                                              TimeZoneSidKey = 'Europe/Dublin',
                                              LocaleSidKey = 'en_US',
                                              EmailEncodingKey = 'UTF-8',
                                              LanguageLocaleKey = 'en_US',
                                              HierarchyLevel1__c='PORTFOLIO MANAGEMENT',
                                              HierarchyLevel2__c='Quietanzamento',
                                              HierarchyLevel3__c='MANCATO QUIETANZAMENTO',
                                              phone='0324243422',
                                              Email='test@two.te',
                                              ProfileId=TechnicalOfficeProfileId,
                                              isActive=true
                                             ),
                                     new User(FirstName='Test',
                                              LastName='Three',
                                              Username='Tstthree@username.test',
                                              Alias='Tsthree',
                                              CommunityNickName='Tstthree',
                                              TimeZoneSidKey = 'Europe/Dublin',
                                              LocaleSidKey = 'en_US',
                                              EmailEncodingKey = 'UTF-8',
                                              LanguageLocaleKey = 'en_US',
                                              HierarchyLevel1__c='BANCASSURANCE SAVINGS CLAIMS, BENEFITS & SURRENDERS',
                                              HierarchyLevel2__c='BANCASS. SAVINGS BENEFITS&SURRENDERS',
                                              HierarchyLevel3__c='RISCATTI E SCADENZE',
                                              phone='0324243423',
                                              Email='test@three.te',
                                              ProfileId=TechnicalOfficeProfileId,
                                              isActive=true
                                             ),
                                     new User(FirstName='Test',
                                              LastName='Four',
                                              Username='Tstfour@username.test',
                                              Alias='Tstfour',
                                              CommunityNickName='Tstfour',
                                              TimeZoneSidKey = 'Europe/Dublin',
                                              LocaleSidKey = 'en_US',
                                              EmailEncodingKey = 'UTF-8',
                                              LanguageLocaleKey = 'en_US',
                                              HierarchyLevel1__c='BANCASSURANCE SAVINGS CLAIMS, BENEFITS & SURRENDERS',
                                              HierarchyLevel2__c='BANCASS. SAVINGS BENEFITS&SURRENDERS',
                                              HierarchyLevel3__c='RISCATTI E SCADENZE',
                                              phone='0324243424',
                                              Email='test@four.te',
                                              ProfileId=TechnicalOfficeProfileId,
                                              isActive=true
                                             ),
                                     new User(FirstName='Test',
                                              LastName='Five',
                                              Username='Tstfive@username.test',
                                              Alias='Tstfive',
                                              CommunityNickName='Tstfive',
                                              TimeZoneSidKey = 'Europe/Dublin',
                                              LocaleSidKey = 'en_US',
                                              EmailEncodingKey = 'UTF-8',
                                              LanguageLocaleKey = 'en_US',
                                              HierarchyLevel1__c='Underwriting & Portfolio monitoring',
                                              HierarchyLevel2__c='COMMERCIAL LINE',
                                              HierarchyLevel3__c='PROC.RISERVATO DIR. PROTEZIONE BUS',
                                              phone='0324243425',
                                              Email='test@five.te',
                                              ProfileId=TechnicalOfficeProfileId
                                             ),
                                     new User(FirstName='Test',
                                              LastName='Six',
                                              Username='Tstsix@username.test',
                                              Alias='Tstsix',
                                              CommunityNickName='Tstsix',
                                              TimeZoneSidKey = 'Europe/Dublin',
                                              LocaleSidKey = 'en_US',
                                              EmailEncodingKey = 'UTF-8',
                                              LanguageLocaleKey = 'en_US',
                                              HierarchyLevel1__c='Supporto HI',
                                              HierarchyLevel2__c='Supporto_HI_BZ',
                                              HierarchyLevel3__c='Tariffe non in scope',
                                              phone='0324243426',
                                              Email='test@six.te',
                                              ProfileId=TechnicalOfficeProfileId
                                             ),
                                     new User(FirstName='Test',
                                              LastName='Sev',
                                              Username='Tstsev@username.test',
                                              Alias='Tstsev',
                                              CommunityNickName='Tstsev',
                                              TimeZoneSidKey = 'Europe/Dublin',
                                              LocaleSidKey = 'en_US',
                                              EmailEncodingKey = 'UTF-8',
                                              LanguageLocaleKey = 'en_US',
                                              HierarchyLevel1__c='SAVINGS',
                                              HierarchyLevel2__c='Variazioni contrattuali',
                                              HierarchyLevel3__c='Variazioni contrattuali',
                                              phone='0324243427',
                                              Email='test@sev.te',
                                              ProfileId=TechnicalOfficeProfileId
                                             ),
                                     new User(FirstName='Test',
                                              LastName='Eigh',
                                              Username='TstEigh@username.test',
                                              Alias='TstEigh',
                                              CommunityNickName='TstEigh',
                                              TimeZoneSidKey = 'Europe/Dublin',
                                              LocaleSidKey = 'en_US',
                                              EmailEncodingKey = 'UTF-8',
                                              LanguageLocaleKey = 'en_US',
                                              HierarchyLevel1__c='BANCASSURANCE SAVINGS CLAIMS, BENEFITS & SURRENDERS',
                                              HierarchyLevel2__c='BANCASSURANCE SAVINGS CLAIMS',
                                              HierarchyLevel3__c='SINISTRI',
                                              phone='0324243428',
                                              Email='test@Eigh.te',
                                              ProfileId=TechnicalOfficeProfileId
                                             ),
                                     new User(FirstName='Test',
                                              LastName='Nine',                                              
                                              Username='Tstnine@username.test',
                                              Alias='Tstnine',
                                              CommunityNickName='Tstnine',
                                              TimeZoneSidKey = 'Europe/Dublin',
                                              LocaleSidKey = 'en_US',
                                              EmailEncodingKey = 'UTF-8',
                                              LanguageLocaleKey = 'en_US',
                                              HierarchyLevel1__c='PORTFOLIO MANAGEMENT',
                                              HierarchyLevel2__c='Quietanzamento',
                                              HierarchyLevel3__c='MANCATO QUIETANZAMENTO',
                                              phone='0324243429',
                                              Email='test@nine.te',
                                              IsActive= false,
                                              ProfileId=TechnicalOfficeProfileId
                                             ),
                                     new User(FirstName='Test',
                                              LastName='Ten',                                              
                                              Username='Tstten@username.test',
                                              Alias='Tstten',
                                              CommunityNickName='Tstten',
                                              TimeZoneSidKey = 'Europe/Dublin',
                                              LocaleSidKey = 'en_US',
                                              EmailEncodingKey = 'UTF-8',
                                              LanguageLocaleKey = 'en_US',
                                              HierarchyLevel1__c='PORTFOLIO MANAGEMENT',
                                              HierarchyLevel2__c='Quietanzamento',
                                              HierarchyLevel3__c='MANCATO QUIETANZAMENTO',
                                              phone='03242434210',
                                              Email='test@ten.te',
                                              IsActive= false,
                                              ProfileId=TechnicalOfficeProfileId
                                             )                                       
       							     };
        insert UserList; 
        
        AccountList = new list<Account>{
                                        new Account(FirstName ='John',
                                                    LastName= 'Smith',
                                                    PersonEmail = 'john.smith@axa-italy-devtest.com',
                                                    RecordTypeId = Acc_DeveloperIdMap.get(AP_Constants.rtAccIntermediary),
                                                    Matricola__c='TestST'
                                                   ),
                                        new Account(FirstName ='Jamie',
                                                    LastName= 'Smith',
                                                    PersonEmail = 'Jamie.smith@axa-italy-devtest.com',
                                                    RecordTypeId = Acc_DeveloperIdMap.get(AP_Constants.rtAccIntermediary),
                                                    Matricola__c='456',
                                                    Bank_Service_Model__c = 'TestPVT'
                                                   ),
                                        new Account(FirstName ='Matt',
                                                    LastName= 'Smith',
                                                    PersonEmail = 'matt.smith@axa-italy-devtest.com',
                                                    RecordTypeId = Acc_DeveloperIdMap.get(AP_Constants.rtAccIndividualClient)
                                                   )                                          
                						};
        insert AccountList;
        
        DefModServList = new list<Definizione_Modelli_di_Servizio__c>{
                                                                      new Definizione_Modelli_di_Servizio__c(Customer_Typology__c='Standard',
                                                                                                             Modello_di_Servizio__c='TestST'),
                                                                      new Definizione_Modelli_di_Servizio__c(Customer_Typology__c='Private',
                                                                                                             Modello_di_Servizio__c='TestPVT')
                                                                     };
        insert DefModServList;
        

        SLAConfigTaskList = new list<Configurazione_SLA_Uffici_Tecnici__c>{
                                                                            new Configurazione_SLA_Uffici_Tecnici__c(Hierarchy_Level_1__c='PORTFOLIO MANAGEMENT',
                                                                                                                     Hierarchy_Level_2__c='Quietanzamento',
                                                                                                                     Hierarchy_Level_3__c='MANCATO QUIETANZAMENTO',
                                                                                                                     Rule_Active__c=true,
                                                                                                                     SLA__c=100,
                                                                                                                     Task_Record_Type__c='All',
                                                                                                                     Customer_Service_Type__c='All',
                                                                                                                     SLA_for_Private_Customers__c=200),
                                                                            new Configurazione_SLA_Uffici_Tecnici__c(Hierarchy_Level_1__c='BANCASSURANCE SAVINGS CLAIMS, BENEFITS & SURRENDERS',
                                                                                                                     Hierarchy_Level_2__c='BANCASS. SAVINGS BENEFITS&SURRENDERS',
                                                                                                                     Hierarchy_Level_3__c='RISCATTI E SCADENZE',
                                                                                                                     Rule_Active__c=true,
                                                                                                                     SLA__c=100,
                                                                                                                     Task_Record_Type__c='NonMotor',
                                                                                                                     Customer_Service_Type__c='All',
                                                                                                                     SLA_for_Private_Customers__c=200),
                                                                            new Configurazione_SLA_Uffici_Tecnici__c(Hierarchy_Level_1__c='Underwriting & Portfolio monitoring',
                                                                                                                     Hierarchy_Level_2__c='COMMERCIAL LINE',
                                                                                                                     Hierarchy_Level_3__c='PROC.RISERVATO DIR. PROTEZIONE BUS',
                                                                                                                     Rule_Active__c=true,
                                                                                                                     SLA__c=100,
                                                                                                                     Task_Record_Type__c='Motor',
                                                                                                                     Customer_Service_Type__c='TestST',
                                                                                                                     SLA_for_Private_Customers__c=200),
                                                                            new Configurazione_SLA_Uffici_Tecnici__c(Hierarchy_Level_1__c='Supporto HI',
                                                                                                                     Hierarchy_Level_2__c='Supporto_HI_BZ',
                                                                                                                     Hierarchy_Level_3__c='Tariffe non in scope',
                                                                                                                     Rule_Active__c=true,
                                                                                                                     SLA__c=100,
                                                                                                                     Task_Record_Type__c='All',
                                                                                                                     Customer_Service_Type__c='TestST',
                                                                                                                     SLA_for_Private_Customers__c=200),
                                                                            new Configurazione_SLA_Uffici_Tecnici__c(Hierarchy_Level_1__c='All',
                                                                                                                     Hierarchy_Level_2__c=null,
                                                                                                                     Hierarchy_Level_3__c=null,
                                                                                                                     Rule_Active__c=true,
                                                                                                                     SLA__c=100,
                                                                                                                     Task_Record_Type__c='Quadra',
                                                                                                                     Customer_Service_Type__c='TestPVT',
                                                                                                                     SLA_for_Private_Customers__c=200),
                                                                            new Configurazione_SLA_Uffici_Tecnici__c(Hierarchy_Level_1__c='All',
                                                                                                                     Hierarchy_Level_2__c=null,
                                                                                                                     Hierarchy_Level_3__c=null,
                                                                                                                     Rule_Active__c=true,
                                                                                                                     SLA__c=100,
                                                                                                                     Task_Record_Type__c='Axa_Assicurazioni',
                                                                                                                     Customer_Service_Type__c='All',
                                                                                                                     SLA_for_Private_Customers__c=200)                                                                                
                                                                    };
         insert SLAConfigTaskList;

        CaseList = new list<Case>{
                                 new Case(Origin='Email',
                                          RecordTypeId=Case_DeveloperIdMap.get(AP_Constants.rtCaseMotor),
                                          Category__c = 'Operatività sulla polizza - Polizze auto',
                                          SubCategory__c = 'Sostituzione per cambio targa',
                                          Distribution_Network__c ='MPS',
                                          OwnerId = UserList[0].id,
                                          Complainant__c = 'Customer',
                                          AgentName__c = AccountList[1].Id                                          
                                         ),
                                 new Case(Origin='Email',
                                          RecordTypeId=Case_DeveloperIdMap.get(AP_Constants.rtCaseMotor),
                                          Category__c = 'Operatività sulla polizza - Polizze auto',
                                          SubCategory__c = 'Sostituzione per cambio targa',
                                          Distribution_Network__c ='MPS',
                                          OwnerId = UserList[0].id,
                                          Complainant__c = 'Customer',
                                          AgentName__c = AccountList[1].Id                                          
                                         ),
                                 new Case(Origin='Email',
                                          RecordTypeId=Case_DeveloperIdMap.get(AP_Constants.rtCaseMotor),
                                          Category__c = 'Operatività sulla polizza - Polizze auto',
                                          SubCategory__c = 'Storno per furto',
                                          Distribution_Network__c ='MPS',
                                          OwnerId = UserList[0].id,
                                          Complainant__c = 'Customer',
                                          AgentName__c = AccountList[0].Id                                          
                                         ),
                                 new Case(Origin='Phone',
                                          RecordTypeId=Case_DeveloperIdMap.get(AP_Constants.rtCaseNonMotor),
                                          Category__c = 'Operatività sulla polizza di Protezione',
                                          SubCategory__c = 'Variazioni anagrafiche/garanzie/figure contrattuale',
                                          Distribution_Network__c ='BNL',
                                          OwnerId = UserList[0].id,
                                          Complainant__c = 'Bank Agent',
                                          AccountId = AccountList[2].Id,
										  AgentName__c = AccountList[0].Id                                          
                                         ),
                                 new Case(Origin='Email',
                                          RecordTypeId=Case_DeveloperIdMap.get(AP_Constants.rtCaseMotor),
                                          Category__c = 'Operatività sulla polizza - Polizze auto',
                                          SubCategory__c = 'Sostituzione per cambio targa',
                                          Distribution_Network__c ='MPS',
                                          OwnerId = UserList[0].id,
                                          Complainant__c = 'Bank Agent',
                                          AgentName__c = AccountList[0].Id                                          
                                         ),
                                 new Case(Origin='Email',
                                          RecordTypeId=Case_DeveloperIdMap.get(AP_Constants.rtCaseQuadra),
                                          Category__c = 'Duplicati polizza di risparmio',
                                          SubCategory__c = 'Contratto di Polizza',
                                          Distribution_Network__c ='MPS',
                                          OwnerId = UserList[0].id,
                                          Complainant__c = 'Bank Agent',
                                          AgentName__c = AccountList[0].Id                                          
                                         ),
                                 new Case(Origin='Email',
                                          RecordTypeId=Case_DeveloperIdMap.get(AP_Constants.rtCaseQuadra),
                                          Category__c = 'Duplicati polizza di risparmio',
                                          SubCategory__c = 'Estratto conto',
                                          Distribution_Network__c ='MPS',
                                          OwnerId = UserList[0].id,
                                          Complainant__c = 'Bank Agent',
                                          AgentName__c = AccountList[1].Id                                          
                                         ),
                                 new Case(Origin='Email',
                                          RecordTypeId=Case_DeveloperIdMap.get(AP_Constants.rtCaseAAI),
                                          Category__c = 'Problemi di Login',
                                          SubCategory__c = 'Autometrica',
                                          Distribution_Network__c ='MPS',
                                          OwnerId = UserList[0].id,
                                          Complainant__c = 'Bank Agent',
                                          AgentName__c = AccountList[1].Id                                          
                                         ),
                                 new Case(Origin='Chat',
                                          RecordTypeId=Case_DeveloperIdMap.get(AP_Constants.rtCaseMotor),
                                          Category__c = 'Operatività sulla polizza - Polizze auto',
                                          SubCategory__c = 'Sostituzione per cambio targa',
                                          Distribution_Network__c ='MPS',
                                          OwnerId = UserList[0].id,
                                          Complainant__c = 'Customer',
                                          AgentName__c = AccountList[1].Id                                          
                                         ),
                                 new Case(Origin='Fax',
                                          RecordTypeId=Case_DeveloperIdMap.get(AP_Constants.rtCaseMotor),
                                          Category__c = 'Operatività sulla polizza - Polizze auto',
                                          SubCategory__c = 'Sostituzione per cambio targa',
                                          Distribution_Network__c ='MPS',
                                          OwnerId = UserList[0].id,
                                          Complainant__c = 'Customer',
                                          AgentName__c = AccountList[1].Id                                          
                                         ),  
                                 new Case(Origin='Phone',
                                          RecordTypeId=Case_DeveloperIdMap.get(AP_Constants.rtCaseNonMotor),
                                          Category__c = 'Operatività sulla polizza di Protezione',
                                          SubCategory__c = 'Variazioni anagrafiche/garanzie/figure contrattuale',
                                          Distribution_Network__c ='BNL',
                                          Status = 'Closed',
                                          OwnerId = UserList[0].id,
                                          Complainant__c = 'Customer',
                                          AgentName__c = AccountList[1].Id                                          
                                         )    
        						 };
        
        AutoTaskOpeningList = new list<Apertura_automatica_Task__c>{
                                                                   new Apertura_automatica_Task__c(Case_Record_Type__c='NonMotor',
                                                                                                   Case_Origin__c='Phone',
                                                                                                   Category__c ='Operatività sulla polizza di Protezione',
                                                                                                   Sub_Category__c = 'Variazioni anagrafiche/garanzie/figure contrattuale',
                                                                                                   Distribution_Network__c ='BNL',
                                                                                                   Rule_Active__c = true,
                                                                                                   Hierarchy_Level_1__c = 'BANCASSURANCE SAVINGS CLAIMS, BENEFITS & SURRENDERS',
                                                                                                   Hierarchy_Level_2__c = 'BANCASS. SAVINGS BENEFITS&SURRENDERS',
                                                                                                   Hierarchy_Level_3__c = 'RISCATTI E SCADENZE',
                                                                                                   Task_Subject__c = 'Task1',
                                                                                                   Technical_Office_Users_Ids__c = UserList[2].Id+';'+UserList[3].Id,
                                                                                                   Technical_Office_Users_Name__c = UserList[2].Name+';'+UserList[3].Name                                                                               
                                                                                                  ),
                                                                    new Apertura_automatica_Task__c(Case_Record_Type__c='Motor',
                                                                                                   Case_Origin__c='Email',
                                                                                                   Category__c ='Operatività sulla polizza - Polizze auto',
                                                                                                   Sub_Category__c = 'Sostituzione per cambio targa',
                                                                                                   Distribution_Network__c ='MPS',
                                                                                                   Rule_Active__c = true,
                                                                                                   Hierarchy_Level_1__c = 'PORTFOLIO MANAGEMENT',
                                                                                                   Hierarchy_Level_2__c = 'Quietanzamento',
                                                                                                   Hierarchy_Level_3__c = 'MANCATO QUIETANZAMENTO',
                                                                                                   Task_Subject__c = 'Task2',
                                                                                                   Technical_Office_Users_Ids__c = UserList[8].Id+';'+UserList[1].Id+';'+UserList[9].Id,
                                                                                                   Technical_Office_Users_Name__c = UserList[8].Name+';'+UserList[1].Name+';'+UserList[9].Name                                                                               
                                                                                                  ),
                                                                    new Apertura_automatica_Task__c(Case_Record_Type__c='Quadra',
                                                                                                   Case_Origin__c='Email',
                                                                                                   Category__c ='Duplicati polizza di risparmio',
                                                                                                   Sub_Category__c = 'Estratto conto',
                                                                                                   Distribution_Network__c ='MPS',
                                                                                                   Rule_Active__c = true,
                                                                                                   Hierarchy_Level_1__c = 'Supporto HI',
                                                                                                   Hierarchy_Level_2__c = 'Supporto_HI_BZ',
                                                                                                   Hierarchy_Level_3__c = 'Tariffe non in scope',
                                                                                                   Task_Subject__c = 'Task3',
                                                                                                   Technical_Office_Users_Ids__c = UserList[5].Id,
                                                                                                   Technical_Office_Users_Name__c = UserList[5].Name                                                                               
                                                                                                  ),
                                                                    new Apertura_automatica_Task__c(Case_Record_Type__c='Quadra',
                                                                                                   Case_Origin__c='Email',
                                                                                                   Category__c ='Duplicati polizza di risparmio',
                                                                                                   Sub_Category__c = 'Contratto di polizza',
                                                                                                   Distribution_Network__c ='MPS',
                                                                                                   Rule_Active__c = true,
                                                                                                   Hierarchy_Level_1__c = 'Supporto HI',
                                                                                                   Hierarchy_Level_2__c = 'Supporto_HI_BZ',
                                                                                                   Hierarchy_Level_3__c = 'Tariffe non in scope',
                                                                                                   Task_Subject__c = 'Task3',
                                                                                                   Technical_Office_Users_Ids__c = UserList[5].Id,
                                                                                                   Technical_Office_Users_Name__c = UserList[5].Name                                                                               
                                                                                                  ),
                                                                    new Apertura_automatica_Task__c(Case_Record_Type__c='Motor',
                                                                                                   Case_Origin__c='Email',
                                                                                                   Category__c ='Operatività sulla polizza - Polizze auto',
                                                                                                   Sub_Category__c = 'Storno per furto',
                                                                                                   Distribution_Network__c ='MPS',
                                                                                                   Rule_Active__c = true,
                                                                                                   Hierarchy_Level_1__c = 'Underwriting & Portfolio monitoring',
                                                                                                   Hierarchy_Level_2__c = 'COMMERCIAL LINE',
                                                                                                   Hierarchy_Level_3__c = 'PROC.RISERVATO DIR. PROTEZIONE BUS',
                                                                                                   Task_Subject__c = 'Task4',
                                                                                                   Technical_Office_Users_Ids__c = UserList[4].Id,
                                                                                                   Technical_Office_Users_Name__c = UserList[4].Name                                                                               
                                                                                                  ),
                                                                    new Apertura_automatica_Task__c(Case_Record_Type__c='Axa_Assicurazioni',
                                                                                                   Case_Origin__c='Email',
                                                                                                   Category__c ='Problemi di Login',
                                                                                                   Sub_Category__c = 'Autometrica',
                                                                                                   Distribution_Network__c ='MPS',
                                                                                                   Rule_Active__c = true,
                                                                                                   Hierarchy_Level_1__c = 'SAVINGS',
                                                                                                   Hierarchy_Level_2__c = 'Variazioni contrattuali',
                                                                                                   Hierarchy_Level_3__c = 'Variazioni contrattuali',
                                                                                                   Task_Subject__c = 'Task5',
                                                                                                   Technical_Office_Users_Ids__c = UserList[5].Id,
                                                                                                   Technical_Office_Users_Name__c = UserList[5].Name                                                                               
                                                                                                  ),
                                                                    new Apertura_automatica_Task__c(Case_Record_Type__c='Motor',
                                                                                                   Case_Origin__c='Fax',
                                                                                                   Category__c ='Operatività sulla polizza - Polizze auto',
                                                                                                   Sub_Category__c = 'Sostituzione per cambio targa',
                                                                                                   Distribution_Network__c ='MPS',
                                                                                                   Rule_Active__c = true,
                                                                                                   Hierarchy_Level_1__c = 'PORTFOLIO MANAGEMENT',
                                                                                                   Hierarchy_Level_2__c = 'Quietanzamento',
                                                                                                   Hierarchy_Level_3__c = 'MANCATO QUIETANZAMENTO',
                                                                                                   Task_Subject__c = 'Task2',
                                                                                                   Technical_Office_Users_Ids__c = UserList[8].Id+';'+UserList[9].Id,
                                                                                                   Technical_Office_Users_Name__c = UserList[8].Name+';'+UserList[9].Name                                                                               
                                                                                                  )
                                                                       
            
        														   };
                                                                       
        insert AutoTaskOpeningList;
        
        //MOSCATELLI_M 28/10/2016: Evo71-ConnectedHome--START        
        CustomSettingList = new List<ExternalPartnersInvolvement__c>{
            														new ExternalPartnersInvolvement__c(Email__c='custom1@test.it',
                                                                                                      Email_Template_AAI__c='TemplateAAI',
                                                                                                      Email_Template_Quadra__c='TemplateQuadra',
                                                                                                      Email_Template_AXA_MPS__c='TemplateMPS',
                                                                                                      Hierarchy_Level_1__c='Custom1Level1',
                                                                                                      Hierarchy_Level_2__c='Custom1Level2',
                                                                                                      Hierarchy_Level_3__c='Custom1Level3',
                                                                                                      Task_Subject__c='custom1',
                                                                                                      Name='custom1')
            
        };
        insert CustomSettingList;  
        //MOSCATELLI_M 28/10/2016: Evo71-ConnectedHome--END
       
        
        //OAVERSANO 14/01/2019 : Agenzia diretta -- START
        List<CaseRTtoTaskRT__c> csrttsrtList = new List<CaseRTtoTaskRT__c>{
            										new CaseRTtoTaskRT__c(name='Agenzia_dipendenti',
                                                                      Task_RT_developername__c='Agenzia_dipendenti_Task'),
                									new CaseRTtoTaskRT__c(name='AMPS_Financial',
                                                                      Task_RT_developername__c='AMPS_Financial_Task'),
                                                    new CaseRTtoTaskRT__c(name='Assistenza_Agenti',
                                                                      Task_RT_developername__c='Assistenza_Agenti_Task'),
                                                    new CaseRTtoTaskRT__c(name='Axa_Assicurazioni',
                                                                      Task_RT_developername__c='AXA_Assicurazioni_Task'),
                                                    new CaseRTtoTaskRT__c(name='Buon_Lavoro',
                                                                      Task_RT_developername__c='Buon_Lavoro_Task'),
                                                    new CaseRTtoTaskRT__c(name='Caring_Angel',
                                                                      Task_RT_developername__c='Caring_Angel_Task'),
                                                        new CaseRTtoTaskRT__c(name='Close_the_loop',
                                                                      Task_RT_developername__c='Close_the_loop_Task'),
                                                        new CaseRTtoTaskRT__c(name='Motor',
                                                                      Task_RT_developername__c='Motor_Task'),
                                                        new CaseRTtoTaskRT__c(name='NonMotor',
                                                                      Task_RT_developername__c='Non_Motor_Task'),
                                                        new CaseRTtoTaskRT__c(name='Quadra',
                                                                      Task_RT_developername__c='Quadra_Task'),
                                                        new CaseRTtoTaskRT__c(name='Sinistri_Danni_Banca',
                                                                      Task_RT_developername__c='Sinistri_Danni_Task')
                
                
                };
                    insert csrttsrtList;  
                    System.assertEquals(11,csrttsrtList.size());
        //OAVERSANO 14/01/2019 : Agenzia diretta -- START                         
                                     
        RelatedCaseList = new list<Case>{
                                 new Case(Origin='Email',
                                          RecordTypeId=Case_DeveloperIdMap.get(AP_Constants.rtCaseMotor),
                                          Category__c = 'Operatività sulla polizza - Polizze auto',
                                          SubCategory__c = 'Sostituzione per cambio targa',
                                          Distribution_Network__c ='MPS',
                                          OwnerId = UserList[0].id,
                                          Complainant__c = 'Customer',
                                          AgentName__c = AccountList[1].Id,
                                          ParentId = CaseList[0].Id
                                         ),
                                 new Case(Origin='Email',
                                          RecordTypeId=Case_DeveloperIdMap.get(AP_Constants.rtCaseMotor),
                                          Category__c = 'Operatività sulla polizza - Polizze auto',
                                          SubCategory__c = 'Sostituzione per cambio targa',
                                          Distribution_Network__c ='MPS',
                                          OwnerId = UserList[0].id,
                                          Complainant__c = 'Customer',
                                          AgentName__c = AccountList[1].Id,
                                          ParentId = CaseList[1].Id,
                                          Status = 'Closed'
                                         ),
                                 new Case(Origin='Email',
                                          RecordTypeId=Case_DeveloperIdMap.get(AP_Constants.rtCaseMotor),
                                          Category__c = 'Operatività sulla polizza - Polizze auto',
                                          SubCategory__c = 'Storno per furto',
                                          Distribution_Network__c ='MPS',
                                          OwnerId = UserList[0].id,
                                          Complainant__c = 'Customer',
                                          AgentName__c = AccountList[0].Id,
                                          ParentId = CaseList[3].Id
                                         ),
                                 new Case(Origin='Phone',
                                          RecordTypeId=Case_DeveloperIdMap.get(AP_Constants.rtCaseNonMotor),
                                          Category__c = 'Operatività sulla polizza di Protezione',
                                          SubCategory__c = 'Variazioni anagrafiche/garanzie/figure contrattuale',
                                          Distribution_Network__c ='BNL',
                                          OwnerId = UserList[0].id,
                                          Complainant__c = 'Bank Agent',
                                          AccountId = AccountList[2].Id,
										  AgentName__c = AccountList[0].Id,
                                          ParentId = CaseList[4].Id
                                         ),
                                 new Case(Origin='Email',
                                          RecordTypeId=Case_DeveloperIdMap.get(AP_Constants.rtCaseMotor),
                                          Category__c = 'Operatività sulla polizza - Polizze auto',
                                          SubCategory__c = 'Sostituzione per cambio targa',
                                          Distribution_Network__c ='MPS',
                                          OwnerId = UserList[0].id,
                                          Complainant__c = 'Bank Agent',
                                          AgentName__c = AccountList[0].Id,
                                          ParentId = CaseList[5].Id
                                         ),
                                 new Case(Origin='Email',
                                          RecordTypeId=Case_DeveloperIdMap.get(AP_Constants.rtCaseQuadra),
                                          Category__c = 'Duplicati polizza di risparmio',
                                          SubCategory__c = 'Contratto di Polizza',
                                          Distribution_Network__c ='MPS',
                                          OwnerId = UserList[0].id,
                                          Complainant__c = 'Bank Agent',
                                          AgentName__c = AccountList[0].Id,
                                          ParentId = CaseList[6].Id
                                         ),
                                 new Case(Origin='Email',
                                          RecordTypeId=Case_DeveloperIdMap.get(AP_Constants.rtCaseQuadra),
                                          Category__c = 'Duplicati polizza di risparmio',
                                          SubCategory__c = 'Estratto conto',
                                          Distribution_Network__c ='MPS',
                                          OwnerId = UserList[0].id,
                                          Complainant__c = 'Bank Agent',
                                          AgentName__c = AccountList[1].Id,
                                          ParentId = CaseList[6].Id
                                         ),
                                 new Case(Origin='Email',
                                          RecordTypeId=Case_DeveloperIdMap.get(AP_Constants.rtCaseAAI),
                                          Category__c = 'Problemi di Login',
                                          SubCategory__c = 'Autometrica',
                                          Distribution_Network__c ='MPS',
                                          OwnerId = UserList[0].id,
                                          Complainant__c = 'Bank Agent',
                                          AgentName__c = AccountList[1].Id,
                                          ParentId = CaseList[7].Id
                                         ),
                                 new Case(Origin='Chat',
                                          RecordTypeId=Case_DeveloperIdMap.get(AP_Constants.rtCaseMotor),
                                          Category__c = 'Operatività sulla polizza - Polizze auto',
                                          SubCategory__c = 'Sostituzione per cambio targa',
                                          Distribution_Network__c ='MPS',
                                          OwnerId = UserList[0].id,
                                          Complainant__c = 'Customer',
                                          AgentName__c = AccountList[1].Id,
                                          ParentId = CaseList[8].Id                                          
                                         ),
                                 new Case(Origin='Fax',
                                          RecordTypeId=Case_DeveloperIdMap.get(AP_Constants.rtCaseMotor),
                                          Category__c = 'Operatività sulla polizza - Polizze auto',
                                          SubCategory__c = 'Sostituzione per cambio targa',
                                          Distribution_Network__c ='MPS',
                                          OwnerId = UserList[0].id,
                                          Complainant__c = 'Customer',
                                          AgentName__c = AccountList[1].Id,
                                          ParentId = CaseList[9].Id                                          
                                         ),  
                                 new Case(Origin='Phone',
                                          RecordTypeId=Case_DeveloperIdMap.get(AP_Constants.rtCaseNonMotor),
                                          Category__c = 'Operatività sulla polizza di Protezione',
                                          SubCategory__c = 'Variazioni anagrafiche/garanzie/figure contrattuale',
                                          Distribution_Network__c ='BNL',
                                          Status = 'Closed',
                                          OwnerId = UserList[0].id,
                                          Complainant__c = 'Customer',
                                          AgentName__c = AccountList[1].Id,
                                          ParentId = CaseList[10].Id
                                         )    
        						 };
            insert RelatedCaseList;                         
            }
    
    @isTest
        static void test1() {
        Test.startTest();
        System.runAs(AdminUser){    
        EmailMessage messaggi    = new EmailMessage();
        messaggi.TextBody = 'Testo di test';
        messaggi.FromAddress = 'Emailditest@dominiotest.invalid.it';
        messaggi.FromName = 'Nome Cognome';
        messaggi.Subject = 'Oggetto di prova';
        messaggi.ToAddress = 'noreply@axa.invalid.it';
        messaggi.ParentId =  RelatedCaseList[0].Id;
        messaggi.Id = null;    
        insert messaggi;    
		List<EmailMessage> emailMessages =  [SELECT TextBody, FromAddress, FromName,Subject,ToAddress, ParentId FROM EmailMEssage LIMIT 10];
        EmailMessage emailMessage = emailMessages[0];
        emailMessage.Id = null;    
        insert emailMessages;
        Test.stopTest();    
        System.assertEquals(true, emailMessages[0].Id != null);   
        }
    }
    
    @isTest
        static void test2()
    {
        system.runAs(AdminUser)
        {
            test.startTest();
        	insert CaseList;
        
            EmailMessage SentEmail = new EmailMessage(ToAddress='custom1@test.it',
                                                                   FromAddress='smc@test.it',
                                                                   Incoming=false,
                                                                   Status = '2',
                                                                   TextBody= 'Messaggio test 1: testo messaggio molto lungo..........................................................................................................................................................................................Messaggio test 1: testo messaggio molto lungo..........................................................................................................................................................................................Messaggio test 1: testo messaggio molto lungo..........................................................................................................................................................................................Messaggio test 1: testo messaggio molto lungo..........................................................................................................................................................................................Messaggio test 1: testo messaggio molto lungo..........................................................................................................................................................................................Messaggio test 1: testo messaggio molto lungo..........................................................................................................................................................................................Messaggio test 1: testo messaggio molto lungo..........................................................................................................................................................................................Messaggio test 1: testo messaggio molto lungo..........................................................................................................................................................................................Messaggio test 1: testo messaggio molto lungo..........................................................................................................................................................................................Messaggio test 1: testo messaggio molto lungo..........................................................................................................................................................................................Messaggio test 1: testo messaggio molto lungo..........................................................................................................................................................................................Messaggio test 1: testo messaggio molto lungo..........................................................................................................................................................................................Messaggio test 1: testo messaggio molto lungo..........................................................................................................................................................................................Messaggio test 1: testo messaggio molto lungo..........................................................................................................................................................................................Messaggio test 1: testo messaggio molto lungo..........................................................................................................................................................................................Messaggio test 1: testo messaggio molto lungo..........................................................................................................................................................................................',
                                								   MessageDate= Date.today(),
                                                                   ParentId=RelatedCaseList[1].id
                                                  );	
            insert SentEmail;
            test.stopTest();
        
            EmailMessage ReceivedEmail = new EmailMessage(ToAddress='smc@test.it',
                                                                   FromAddress='custom1@test.it',
                                                                   Incoming=true,
                                                                   Status = '1',
                                                                   TextBody= 'Messaggio test 2',
                                								   MessageDate= Date.today(),
                                                                   ParentId=RelatedCaseList[1].id
                                                  );	
            insert ReceivedEmail;
    	}
    }
}