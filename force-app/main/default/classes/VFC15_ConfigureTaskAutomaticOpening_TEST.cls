/*
**********************************************************************************************
----------------------------------------------------------------------------------------------
-- - Name          : VFC15_ConfigureTaskAutomaticOpening_TEST
-- - Author        : Marco Moscatelli
-- - Description   : Test Methods for VFC15_ConfigureTaskAutomaticOpening
--
-- Maintenance History:
--
-- Date          Version  Remarks
-- -----------  -------  ---------------------------------------------------------------------
-- 01-09-2016   1.0     
----------------------------------------------------------------------------------------------
**********************************************************************************************
*/

@isTest
private class VFC15_ConfigureTaskAutomaticOpening_TEST
{
	static List<User> ListAdminUser;
    static Apertura_automatica_Task__c ExistentRule;
    static List<User> ListEmployee;
    static List<Uffici_Tecnici_Record_Type__c> ListRecTypOfficesRules;
    static Id AdvisorProfileId;
    
    static
    {
        AdvisorProfileId = [Select Id from Profile where Name ='SmartCenter Motor Advisor'].Id;
        
        ListAdminUser = new list<User>{
            						  	 new User(
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
                                         	 ),
            						  	 new User(
                                             Email ='TestAdm2@Test.com',
                                             Username = 'TestAdm2@username.test',
                                             FirstName='Test',
                                             LastName='User2',
                                             Alias='tstusr2',
                                             TimeZoneSidKey = 'Europe/Dublin',
                                             LocaleSidKey = 'it',
                                             EmailEncodingKey = 'UTF-8',
                                             LanguageLocaleKey = 'it',
                                             ProfileId = AP_Constants.getProfileAdminId()
                                         	 )                                           
            						};
        insert ListAdminUser;
        
        ListEmployee = new list<User>{
            						 new User(FirstName='Test',
                                              LastName='One',
                                              Username='Tstone@username.test',
                                              Alias='Tstone',
                                              CommunityNickName='Tstone',
                                              TimeZoneSidKey = 'Europe/Dublin',
                                              LocaleSidKey = 'en_US',
                                              EmailEncodingKey = 'UTF-8',
                                              LanguageLocaleKey = 'en_US',
                                              HierarchyLevel1__c='PORTFOLIO MANAGEMENT',
                                              HierarchyLevel2MP__c='Portfolio Management Portafoglio',
                                              HierarchyLevel3MP__c='SVINCOLO POLIZZA',
                                              phone='0324243421',
                                              Email='test@one.te',
                                              ProfileId=AdvisorProfileId
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
                                              HierarchyLevel2MP__c='Portfolio Management Portafoglio',
                                              HierarchyLevel3MP__c='SVINCOLO POLIZZA',
                                              phone='0324243422',
                                              Email='test@two.te',
                                              ProfileId=AdvisorProfileId
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
                                              HierarchyLevel2MP__c='BANCASS. SAVINGS BENEFITS&SURRENDERS',
                                              HierarchyLevel3MP__c='RISCATTI E SCADENZE',
                                              phone='0324243423',
                                              Email='test@three.te',
                                              ProfileId=AdvisorProfileId
                                             ),
                                     new User(FirstName='Test',
                                              LastName='Four',
                                              Username='TstFour@username.test',
                                              Alias='TstFour',
                                              CommunityNickName='TstFour',
                                              TimeZoneSidKey = 'Europe/Dublin',
                                              LocaleSidKey = 'en_US',
                                              EmailEncodingKey = 'UTF-8',
                                              LanguageLocaleKey = 'en_US',
                                              HierarchyLevel1__c='SAVINGS',
                                              HierarchyLevel2MP__c='Variazioni contrattuali',
                                              HierarchyLevel3MP__c='Variazioni contrattuali',
                                              phone='0324243424',
                                              Email='test@four.te',
                                              ProfileId=AdvisorProfileId
                                             )                                         
       							     };
        insert ListEmployee;
        
        ListRecTypOfficesRules = new list<Uffici_Tecnici_Record_Type__c>{
                                                                         new Uffici_Tecnici_Record_Type__c(Hierarchy_Level_1__c='PORTFOLIO MANAGEMENT',
                                                                                                           Task_Record_Type__c='Motor'
                                                                                                          ),
                                                                         new Uffici_Tecnici_Record_Type__c(Hierarchy_Level_1__c='BANCASSURANCE SAVINGS CLAIMS',
                                                                                                           Task_Record_Type__c='NonMotor'
                                                                                                          ),
                                                                         new Uffici_Tecnici_Record_Type__c(Hierarchy_Level_1__c='SAVINGS',
                                                                                                           Task_Record_Type__c='NonMotor'
                                                                                                          )    
        																};
        insert ListRecTypOfficesRules;
        
        
        ExistentRule = new Apertura_automatica_Task__c(Case_Origin__c='Email',
                                                            Case_Record_Type__c='NonMotor',
                                                       		Lob__c='Altro',
                                                            Category__c='Operatività sulla polizza di Protezione',
                                                            Sub_Category__c='Variazioni anagrafiche/garanzie/figure contrattuale',
                                                            Hierarchy_Level_1__c='BANCASSURANCE SAVINGS CLAIMS, BENEFITS & SURRENDERS',
                                                            Hierarchy_Level_2__c='BANCASS. SAVINGS BENEFITS&SURRENDERS',
                                                            Hierarchy_Level_3__c='RISCATTI E SCADENZE',
                                                            Distribution_Network__c='MPS',
                                                            Rule_Active__c=true,
                                                            Technical_Office_Users_Ids__c=ListEmployee[2].id,
                                                            Technical_Office_Users_Name__c=ListEmployee[2].Name); 
        insert ExistentRule;                                   
    }
    
	static testMethod void Test_insertNewRule_1()
    {
        system.debug('##Start of Method Test_insertNewRule_1##');
        system.runAs(ListAdminUser[0])
        {
            test.startTest();
            
            Apertura_automatica_Task__c Rule = new Apertura_automatica_Task__c();
            PageReference pageRef = Page.VFP15_ConfigureTaskAutomaticOpening;
            Test.setCurrentPage(pageRef);
            
            ApexPages.StandardController NewRule = new ApexPages.StandardController(Rule);
            VFC15_ConfigureTaskAutomaticOpening InsertNewRule = new VFC15_ConfigureTaskAutomaticOpening(NewRule);
            
            InsertNewRule.InvolvedCase.Case_Record_Type__c='NonMotor';
            InsertNewRule.InvolvedCase.Case_Origin__c='Phone';
            InsertNewRule.InvolvedCase.Lob__c='Altro';
            InsertNewRule.InvolvedCase.Category__c='Operatività sulla polizza di Protezione';
            InsertNewRule.InvolvedCase.Sub_Category__c='Variazioni anagrafiche/garanzie/figure contrattuale';
            InsertNewRule.ExampleCase.Lob__c='Altro';
            InsertNewRule.ExampleCase.Category__c='Operatività sulla polizza di Protezione';
            InsertNewRule.ExampleCase.SubCategory__c='Variazioni anagrafiche/garanzie/figure contrattuale';
            InsertNewRule.InvolvedCase.Distribution_Network__c='MPS';
            InsertNewRule.CheckAllInputs();
            InsertNewRule.TechnicalOfficeUser.HierarchyLevel1__c='BANCASSURANCE SAVINGS CLAIMS, BENEFITS & SURRENDERS';
            InsertNewRule.setflag();
            InsertNewRule.TechnicalOfficeUser.HierarchyLevel2__c='BANCASS. SAVINGS BENEFITS&SURRENDERS';
            InsertNewRule.TechnicalOfficeUser.HierarchyLevel3__c='RISCATTI E SCADENZE';
            InsertNewRule.GetListOfEmployees();
           	InsertNewRule.InvolvedCase.Task_Subject__c='test';
            if(!InsertNewRule.listEmp.isEmpty())
            	InsertNewRule.listEmp[0].Selected=true;
            InsertNewRule.CheckSelected();
            InsertNewRule.changeDisplayedField();
            InsertNewRule.TechnicalOfficeUser.HierarchyLevel1__c='SAVINGS';
            InsertNewRule.setflag();            
            InsertNewRule.TechnicalOfficeUser.HierarchyLevel2__c='Variazioni contrattuali';
            InsertNewRule.TechnicalOfficeUser.HierarchyLevel3__c='Variazioni contrattuali';            
            InsertNewRule.GetListOfEmployees();
           	InsertNewRule.InvolvedCase.Task_Subject__c='test2';
            if(!InsertNewRule.listEmp.isEmpty())
            	InsertNewRule.listEmp[0].Selected=true;
            InsertNewRule.CheckSelected();            
            InsertNewRule.CreateAutomaticTaskRule();
            test.stopTest();    
        }
    }
    
	static testMethod void Test_insertNewRule_2()
    {
        system.debug('##Start of Method Test_insertNewRule_2##');
        system.runAs(ListAdminUser[1])
        {
            test.startTest();
            
            Apertura_automatica_Task__c Rule = new Apertura_automatica_Task__c();
            PageReference pageRef = Page.VFP15_ConfigureTaskAutomaticOpening;
            Test.setCurrentPage(pageRef);
            
            ApexPages.StandardController NewRule = new ApexPages.StandardController(Rule);
            VFC15_ConfigureTaskAutomaticOpening InsertNewRule = new VFC15_ConfigureTaskAutomaticOpening(NewRule);
            
            InsertNewRule.InvolvedCase.Case_Record_Type__c='Motor';
            InsertNewRule.InvolvedCase.Case_Origin__c='Phone';
            InsertNewRule.InvolvedCase.Lob__c='Altro';

            InsertNewRule.InvolvedCase.Category__c='Operatività sulla polizza - Polizze auto';
            InsertNewRule.InvolvedCase.Sub_Category__c='Sostituzione per cambio targa';         
            InsertNewRule.ExampleCase.Lob__c='Altro';

            InsertNewRule.ExampleCase.Category__c='Operatività sulla polizza - Polizze auto';
            InsertNewRule.ExampleCase.SubCategory__c='Sostituzione per cambio targa';            
            InsertNewRule.InvolvedCase.Distribution_Network__c='MPS';
            InsertNewRule.CheckAllInputs();
            InsertNewRule.InvolvedCase.Distribution_Network__c='BNL';
            InsertNewRule.CheckAllInputs();
            InsertNewRule.TechnicalOfficeUser.HierarchyLevel1__c='PORTFOLIO MANAGEMENT';
            InsertNewRule.setflag();
            InsertNewRule.TechnicalOfficeUser.HierarchyLevel2__c='Portfolio Management Portafoglio';
            InsertNewRule.TechnicalOfficeUser.HierarchyLevel3__c='SVINCOLO POLIZZA';
            InsertNewRule.GetListOfEmployees();
           	InsertNewRule.InvolvedCase.Task_Subject__c='test';
            if(!InsertNewRule.listEmp.isEmpty())
            {
                InsertNewRule.listEmp[0].Selected=true;
                InsertNewRule.listEmp[1].Selected=true;
            }
            InsertNewRule.CheckSelected();
            InsertNewRule.CreateAutomaticTaskRule();
            test.stopTest();    
        }
    }
    
	static testMethod void Test_insertNewRule_3()
    {
        system.debug('##Start of Method Test_insertNewRule_3##');
        system.runAs(ListAdminUser[0])
        {
            test.startTest();
            
            Apertura_automatica_Task__c Rule = new Apertura_automatica_Task__c();
            PageReference pageRef = Page.VFP15_ConfigureTaskAutomaticOpening;
            Test.setCurrentPage(pageRef);
            
            ApexPages.StandardController NewRule = new ApexPages.StandardController(Rule);
            VFC15_ConfigureTaskAutomaticOpening InsertNewRule = new VFC15_ConfigureTaskAutomaticOpening(NewRule);
            
            InsertNewRule.InvolvedCase.Case_Record_Type__c='NonMotor';
            InsertNewRule.InvolvedCase.Case_Origin__c='Email';
            InsertNewRule.InvolvedCase.Lob__c='Altro';
            InsertNewRule.InvolvedCase.Category__c='Operatività sulla polizza di Protezione';
            InsertNewRule.InvolvedCase.Sub_Category__c='Variazioni anagrafiche/garanzie/figure contrattuale';            
            InsertNewRule.ExampleCase.Category__c='Operatività sulla polizza di Protezione';
            InsertNewRule.ExampleCase.SubCategory__c='Variazioni anagrafiche/garanzie/figure contrattuale';            
            InsertNewRule.InvolvedCase.Distribution_Network__c='MPS';
            InsertNewRule.CheckAllInputs();
            test.stopTest();    
        }
    }
    
	static testMethod void Test_insertNewRule_4()
    {
        system.debug('##Start of Method Test_insertNewRule_4##');
        system.runAs(ListAdminUser[0])
        {
            test.startTest();
            
            Apertura_automatica_Task__c Rule = new Apertura_automatica_Task__c();
            PageReference pageRef = Page.VFP15_ConfigureTaskAutomaticOpening;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id',ExistentRule.id);
            
            ApexPages.StandardController NewRule = new ApexPages.StandardController(Rule);
            VFC15_ConfigureTaskAutomaticOpening InsertNewRule = new VFC15_ConfigureTaskAutomaticOpening(NewRule);
            
            InsertNewRule.InvolvedCase.Case_Record_Type__c='NonMotor';
            InsertNewRule.InvolvedCase.Case_Origin__c='Email';
            InsertNewRule.InvolvedCase.Lob__c='Altro';
            InsertNewRule.InvolvedCase.Category__c='Operatività sulla polizza di Protezione';
            InsertNewRule.InvolvedCase.Sub_Category__c='Variazioni anagrafiche/garanzie/figure contrattuale';
                        InsertNewRule.ExampleCase.Lob__c='Altro';

            InsertNewRule.ExampleCase.Category__c='Operatività sulla polizza di Protezione';
            InsertNewRule.ExampleCase.SubCategory__c='Variazioni anagrafiche/garanzie/figure contrattuale';                        
            InsertNewRule.InvolvedCase.Distribution_Network__c='MPS';
            InsertNewRule.CheckAllInputs();
            InsertNewRule.InvolvedCase.Case_Record_Type__c='Motor';
            InsertNewRule.ResetValues();
            InsertNewRule.InvolvedCase.Case_Origin__c='Phone';
            InsertNewRule.InvolvedCase.Category__c='Operatività sulla polizza - Polizze auto';
            InsertNewRule.InvolvedCase.Sub_Category__c='Sostituzione per cambio targa';
            InsertNewRule.ExampleCase.Category__c='Operatività sulla polizza - Polizze auto';
            InsertNewRule.ExampleCase.SubCategory__c='Sostituzione per cambio targa';
            InsertNewRule.InvolvedCase.Distribution_Network__c='MPS';
            InsertNewRule.TechnicalOfficeUser.HierarchyLevel1__c='PORTFOLIO MANAGEMENT';
            InsertNewRule.setflag();
            InsertNewRule.TechnicalOfficeUser.HierarchyLevel2__c='Portfolio Management Portafoglio';
            InsertNewRule.TechnicalOfficeUser.HierarchyLevel3__c='SVINCOLO POLIZZA';
            InsertNewRule.GetListOfEmployees();
           	InsertNewRule.InvolvedCase.Task_Subject__c='test';
            if(!InsertNewRule.listEmp.isEmpty())
            	InsertNewRule.listEmp[0].Selected=true;
            InsertNewRule.CheckSelected();
            InsertNewRule.CreateAutomaticTaskRule();
            
            test.stopTest();    
        }
    }
    
	static testMethod void Test_insertNewRule_5()
    {
        system.debug('##Start of Method Test_insertNewRule_5##');
        system.runAs(ListAdminUser[0])
        {
            test.startTest();
            
            Apertura_automatica_Task__c Rule = new Apertura_automatica_Task__c();
            PageReference pageRef = Page.VFP15_ConfigureTaskAutomaticOpening;
            Test.setCurrentPage(pageRef);
            
            ApexPages.StandardController NewRule = new ApexPages.StandardController(Rule);
            VFC15_ConfigureTaskAutomaticOpening InsertNewRule = new VFC15_ConfigureTaskAutomaticOpening(NewRule);
            
            InsertNewRule.InvolvedCase.Case_Record_Type__c='Quadra';
            InsertNewRule.InvolvedCase.Case_Origin__c='Email';
            InsertNewRule.InvolvedCase.Lob__c='Altro';
            InsertNewRule.InvolvedCase.Category__c='Operatività sulla polizza di Protezione';
            InsertNewRule.InvolvedCase.Sub_Category__c='Variazioni anagrafiche/garanzie/figure contrattuale';
                        InsertNewRule.ExampleCase.Lob__c='Altro';

            InsertNewRule.ExampleCase.Category__c='Operatività sulla polizza di Protezione';
            InsertNewRule.ExampleCase.SubCategory__c='Variazioni anagrafiche/garanzie/figure contrattuale';
            InsertNewRule.InvolvedCase.Distribution_Network__c='MPS';
            InsertNewRule.CheckAllInputs();
            
            test.stopTest();    
        }
    }
    
	static testMethod void Test_insertNewRule_6()
    {
        system.debug('##Start of Method Test_insertNewRule_6##');
        system.runAs(ListAdminUser[0])
        {
            test.startTest();
            
            Apertura_automatica_Task__c Rule = new Apertura_automatica_Task__c();
            PageReference pageRef = Page.VFP15_ConfigureTaskAutomaticOpening;
            Test.setCurrentPage(pageRef);
            
            ApexPages.StandardController NewRule = new ApexPages.StandardController(Rule);
            VFC15_ConfigureTaskAutomaticOpening InsertNewRule = new VFC15_ConfigureTaskAutomaticOpening(NewRule);
            
            InsertNewRule.InvolvedCase.Case_Record_Type__c='NonMotor';
            InsertNewRule.InvolvedCase.Case_Origin__c='Email';
            InsertNewRule.InvolvedCase.Lob__c='Altro';
                        InsertNewRule.ExampleCase.Lob__c='Altro';

            InsertNewRule.ExampleCase.Category__c='Operatività sulla polizza di Protezione';
            InsertNewRule.ExampleCase.SubCategory__c='Variazioni anagrafiche/garanzie/figure contrattuale';
            InsertNewRule.InvolvedCase.Category__c='Operatività sulla polizza di Protezione';
            InsertNewRule.InvolvedCase.Sub_Category__c='Variazioni anagrafiche/garanzie/figure contrattuale';
            InsertNewRule.InvolvedCase.Distribution_Network__c='MPS';
            InsertNewRule.CheckAllInputs();
            test.stopTest();
        }
    }
}