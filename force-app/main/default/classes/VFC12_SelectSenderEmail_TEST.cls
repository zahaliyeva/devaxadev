/*
**********************************************************************************************
----------------------------------------------------------------------------------------------
-- - Name          : VFC12_SelectSenderEmail_TEST
-- - Author        : Marco Moscatelli
-- - Description   : Test Methods for VFC12_SelectSenderEmail
--
-- Maintenance History:
--
-- Date          Version  Remarks
-- -----------  -------  ---------------------------------------------------------------------
-- 26-05-2016   1.0     
----------------------------------------------------------------------------------------------
**********************************************************************************************
*/

@isTest
private class VFC12_SelectSenderEmail_TEST
{
	static list<Record_Type_Email__c> Rules;
    static user userAdmin;
    static user userAdmin2;
    
    static
    {
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
        
        userAdmin2 = new User(Username = 'testclass2@test.com',
                             LastName = 'testuser2',
                             LanguageLocaleKey = 'it',
                             FirstName = 'tes2t',
                             Email = 'test2@test2.com',
                             Alias = 'test',
                             TimeZoneSidKey = 'Europe/Dublin',
                             LocaleSidKey = 'it',
                             EmailEncodingKey = 'UTF-8',
                             ProfileId = AP_Constants.getProfileAdminId()
                            );
        
        insert userAdmin2;

        system.runas(userAdmin)
        {
            Rules = new list<Record_Type_Email__c>
            {
                new Record_Type_Email__c(Caller__c='Customer',Record_Type__c='Motor',Email__c='testcust@test.it'),
                new Record_Type_Email__c(Caller__c='Bank Agent',Record_Type__c='Motor',Email__c='testag@test.it'),
                new Record_Type_Email__c(Caller__c='Techincal Office',Record_Type__c='Quadra',Email__c='testTECH@test.it')    
            };
            
            insert Rules;
        }        
    }
    
    static testMethod void createrule_Test1()
    {
        system.debug('#### Start of method createrule_Test1');
        
        system.runAs(userAdmin)
        {
            test.starttest();
            
            Record_Type_Email__c rec = new Record_Type_Email__c();
            
            PageReference pageRef = Page.VFP12_SelectSenderEmail;
            Test.setCurrentPage(pageRef);
            
            ApexPages.StandardController sc = new ApexPages.StandardController(rec);
            VFC12_SelectSenderEmail RuleCreation = new VFC12_SelectSenderEmail(sc);
            
            RuleCreation.RecEmail.Caller__c = 'Customer';
            RuleCreation.RecEmail.Record_Type__c = 'Quadra';
            RuleCreation.RecEmail.Email__c = 'testcust@test.it';
            
            RuleCreation.save();
            
            test.stoptest();
    	}
        system.debug('test :'+[select caller__c from Record_Type_Email__c]);
	}
    
    static testMethod void createrule_Test2()
    {
        system.debug('#### Start of method createrule_Test2');
        
        system.runAs(userAdmin)
        {
            test.starttest();
            
            Record_Type_Email__c rec = new Record_Type_Email__c();
            
            PageReference pageRef = Page.VFP12_SelectSenderEmail;
            Test.setCurrentPage(pageRef);
            
            ApexPages.StandardController sc = new ApexPages.StandardController(rec);
            VFC12_SelectSenderEmail RuleCreation = new VFC12_SelectSenderEmail(sc);
            
            RuleCreation.RecEmail.Caller__c = 'Customer';
            RuleCreation.RecEmail.Record_Type__c = 'Quadra';
            RuleCreation.RecEmail.Additional_Email__c = 'testcust2@test.it';
            
            RuleCreation.save();
            
            test.stoptest();
    	}
        system.debug('test :'+[select caller__c from Record_Type_Email__c]);
	}
    static testMethod void createrule_Test3()
    {
        system.debug('#### Start of method createrule_Test3');
        
        system.runAs(userAdmin)
        {
            test.starttest();
            
            Record_Type_Email__c rec = new Record_Type_Email__c();
            
            PageReference pageRef = Page.VFP12_SelectSenderEmail;
            Test.setCurrentPage(pageRef);
            
            ApexPages.StandardController sc = new ApexPages.StandardController(rec);
            VFC12_SelectSenderEmail RuleCreation = new VFC12_SelectSenderEmail(sc);
            
            RuleCreation.RecEmail.Caller__c = 'Customer;Bank Agent';
            RuleCreation.RecEmail.Record_Type__c = 'Motor';
            RuleCreation.RecEmail.Additional_Email__c = 'testcust3@test.it';
            
            RuleCreation.save();
            
            test.stoptest();
    	}
        system.debug('test :'+[select caller__c from Record_Type_Email__c]);
	}
    
    static testMethod void createrule_Test4()
    {
        system.debug('#### Start of method createrule_Test4');
        
        system.runAs(userAdmin)
        {
            test.starttest();
            
            Record_Type_Email__c rec = new Record_Type_Email__c(id =Rules[0].id );
            
            PageReference pageRef = Page.VFP12_SelectSenderEmail;
            Test.setCurrentPage(pageRef);
            
            ApexPages.StandardController sc = new ApexPages.StandardController(rec);
            VFC12_SelectSenderEmail RuleCreation = new VFC12_SelectSenderEmail(sc);
            
            RuleCreation.RecEmail.Caller__c = 'Customer;Techincal Office';
            RuleCreation.RecEmail.Record_Type__c = 'Quadra';
            RuleCreation.RecEmail.Additional_Email__c = 'testcust3@test.it';
            
            RuleCreation.save();
            
            test.stoptest();
    	}
        system.debug('test :'+[select caller__c from Record_Type_Email__c]);
	}
    
    static testMethod void createrule_Test5()
    {
        system.debug('#### Start of method createrule_Test5');
        
        system.runAs(userAdmin2)
        {
            test.starttest();
            
            Record_Type_Email__c rec = new Record_Type_Email__c(id =Rules[2].id );
            Record_Type_Email__c rec2 = new Record_Type_Email__c();
            
            PageReference pageRef = Page.VFP12_SelectSenderEmail;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id',Rules[2].id);
            
            ApexPages.StandardController sc = new ApexPages.StandardController(rec);
            VFC12_SelectSenderEmail RuleCreation = new VFC12_SelectSenderEmail(sc);
            
            RuleCreation.RecEmail.Caller__c = 'Techincal Office';
            RuleCreation.RecEmail.Record_Type__c = 'Quadra';
            RuleCreation.RecEmail.Additional_Email__c = '';
            RuleCreation.RecEmail.Email__c = '';
            
            RuleCreation.save();
            
            ApexPages.currentPage().getParameters().put('id','');
            ApexPages.StandardController sc2 = new ApexPages.StandardController(rec2);
            VFC12_SelectSenderEmail RuleCreation2 = new VFC12_SelectSenderEmail(sc2);
            
            RuleCreation2.RecEmail.Caller__c = 'Techincal Office';
            RuleCreation2.RecEmail.Record_Type__c = 'Quadra';
            RuleCreation2.RecEmail.Additional_Email__c = '';
            RuleCreation2.RecEmail.Email__c = '';
            
            RuleCreation2.save();
            
            test.stoptest();
    	}
        system.debug('test :'+[select caller__c from Record_Type_Email__c]);
	}

    static testMethod void createrule_Test6()
    {
        system.debug('#### Start of method createrule_Test6');
        
        system.runAs(userAdmin)
        {
            test.starttest();
            
            Record_Type_Email__c rec = new Record_Type_Email__c();
            
            PageReference pageRef = Page.VFP12_SelectSenderEmail;
            Test.setCurrentPage(pageRef);
            
            ApexPages.StandardController sc = new ApexPages.StandardController(rec);
            VFC12_SelectSenderEmail RuleCreation = new VFC12_SelectSenderEmail(sc);
            
            RuleCreation.RecEmail.Caller__c = 'Customer';
            RuleCreation.RecEmail.Record_Type__c = 'Quadra';
            RuleCreation.RecEmail.Email__c = 'testcust@test.it';
            
            RuleCreation.SaveANDNew();
            
            test.stoptest();
    	}
        system.debug('test :'+[select caller__c from Record_Type_Email__c]);
	}
    
    static testMethod void createrule_Test7()
    {
        system.debug('#### Start of method createrule_Test7');
        
        system.runAs(userAdmin)
        {
            test.starttest();
            
            Record_Type_Email__c rec = new Record_Type_Email__c();
            
            PageReference pageRef = Page.VFP12_SelectSenderEmail;
            Test.setCurrentPage(pageRef);
            
            ApexPages.StandardController sc = new ApexPages.StandardController(rec);
            VFC12_SelectSenderEmail RuleCreation = new VFC12_SelectSenderEmail(sc);
            
            RuleCreation.RecEmail.Caller__c = 'Customer';
            RuleCreation.RecEmail.Record_Type__c = 'Quadra';
            RuleCreation.RecEmail.Additional_Email__c = 'testcust2@test.it';
            
            RuleCreation.SaveANDNew();
            
            test.stoptest();
    	}
        system.debug('test :'+[select caller__c from Record_Type_Email__c]);
	}
    static testMethod void createrule_Test8()
    {
        system.debug('#### Start of method createrule_Test8');
        
        system.runAs(userAdmin)
        {
            test.starttest();
            
            Record_Type_Email__c rec = new Record_Type_Email__c();
            
            PageReference pageRef = Page.VFP12_SelectSenderEmail;
            Test.setCurrentPage(pageRef);
            
            ApexPages.StandardController sc = new ApexPages.StandardController(rec);
            VFC12_SelectSenderEmail RuleCreation = new VFC12_SelectSenderEmail(sc);
            
            RuleCreation.RecEmail.Caller__c = 'Customer;Bank Agent';
            RuleCreation.RecEmail.Record_Type__c = 'Motor';
            RuleCreation.RecEmail.Additional_Email__c = 'testcust3@test.it';
            
            RuleCreation.SaveANDNew();
            
            test.stoptest();
    	}
        system.debug('test :'+[select caller__c from Record_Type_Email__c]);
	}
    
    static testMethod void createrule_Test9()
    {
        system.debug('#### Start of method createrule_Test9');
        
        system.runAs(userAdmin)
        {
            test.starttest();
            
            Record_Type_Email__c rec = new Record_Type_Email__c(id =Rules[0].id );
            
            PageReference pageRef = Page.VFP12_SelectSenderEmail;
            Test.setCurrentPage(pageRef);
            
            ApexPages.StandardController sc = new ApexPages.StandardController(rec);
            VFC12_SelectSenderEmail RuleCreation = new VFC12_SelectSenderEmail(sc);
            
            RuleCreation.RecEmail.Caller__c = 'Customer;Techincal Office';
            RuleCreation.RecEmail.Record_Type__c = 'Quadra';
            RuleCreation.RecEmail.Additional_Email__c = 'testcust3@test.it';
            
            RuleCreation.SaveANDNew();
            
            test.stoptest();
    	}
        system.debug('test :'+[select caller__c from Record_Type_Email__c]);
	}
    
    static testMethod void createrule_Test10()
    {
        system.debug('#### Start of method createrule_Test10');
        
        system.runAs(userAdmin2)
        {
            test.starttest();
            
            Record_Type_Email__c rec = new Record_Type_Email__c(id =Rules[2].id );
            Record_Type_Email__c rec2 = new Record_Type_Email__c();
            
            PageReference pageRef = Page.VFP12_SelectSenderEmail;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id',Rules[2].id);
            
            ApexPages.StandardController sc = new ApexPages.StandardController(rec);
            VFC12_SelectSenderEmail RuleCreation = new VFC12_SelectSenderEmail(sc);
            
            RuleCreation.RecEmail.Caller__c = 'Techincal Office';
            RuleCreation.RecEmail.Record_Type__c = 'Quadra';
            RuleCreation.RecEmail.Additional_Email__c = '';
            RuleCreation.RecEmail.Email__c = '';
            
            RuleCreation.SaveANDNew();
            
            ApexPages.currentPage().getParameters().put('id','');
            ApexPages.StandardController sc2 = new ApexPages.StandardController(rec2);
            VFC12_SelectSenderEmail RuleCreation2 = new VFC12_SelectSenderEmail(sc2);
            
            RuleCreation2.RecEmail.Caller__c = 'Techincal Office';
            RuleCreation2.RecEmail.Record_Type__c = 'Quadra';
            RuleCreation2.RecEmail.Additional_Email__c = '';
            RuleCreation2.RecEmail.Email__c = '';
            
            RuleCreation2.SaveANDNew();
            
            test.stoptest();
    	}
        system.debug('test :'+[select caller__c from Record_Type_Email__c]);
	}
}