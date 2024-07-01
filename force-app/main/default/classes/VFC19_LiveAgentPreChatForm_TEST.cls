/*
**********************************************************************************************
----------------------------------------------------------------------------------------------
-- - Name          : VFC19_LiveAgentPreChatForm_TEST
-- - Author        : Marco Moscatelli
-- - Description   : Test Methods for VFC19_LiveAgentPreChatForm
--
-- Maintenance History:
--
-- Date          Version  Remarks
-- -----------  -------  ---------------------------------------------------------------------
-- 27-03-2017   1.0     
----------------------------------------------------------------------------------------------
**********************************************************************************************
*/

@isTest
private class VFC19_LiveAgentPreChatForm_TEST
{
    static List<User> UserAdminList;
    static List<Pre_chat_Form_Configuration__c> PreChatList;
    
    static
    {
        UserAdminList = new List<User>  {
            new User(Username = 'testclassVFC19@test.com',
                     LastName = 'testuser',
                     LanguageLocaleKey = 'en_US',
                     FirstName = 'test',
                     Email = 'test@test.com',
                     Alias = 'test',
                     TimeZoneSidKey = 'Europe/Dublin',
                     LocaleSidKey = 'en_US',
                     EmailEncodingKey = 'UTF-8',
                     ProfileId = AP_Constants.getProfileAdminId()
                    ),
                new User(Username = 'testclassitVFC19@test.com',
                         LastName = 'testuserit',
                         LanguageLocaleKey = 'it',
                         FirstName = 'test',
                         Email = 'testit@test.com',
                         Alias = 'testit',
                         TimeZoneSidKey = 'Europe/Dublin',
                         LocaleSidKey = 'en_US',
                         EmailEncodingKey = 'UTF-8',
                         ProfileId = AP_Constants.getProfileAdminId())                                                 
                };
                    
                    insert UserAdminList;
        
        PreChatList = new List<Pre_chat_Form_Configuration__c>  {
            new Pre_chat_Form_Configuration__c(Web_Portal_Type_del__c='Quadra',
                                               Case_Record_Type__c='Quadra',
                                               SFDC_Button_Id__c='57325000000CaRb',
                                               Category__c='Cat1',
                                               SubCategory__c='SubCat1',
                                               Name='C1',
                                               Deployment_id__c='Dep1'),
                new Pre_chat_Form_Configuration__c(Web_Portal_Type_del__c='MPS',
                                                   Case_Record_Type__c='Motor',
                                                   SFDC_Button_Id__c='57325000000CaRc',
                                                   Category__c='Cat2',
                                                   SubCategory__c='',
                                                   Name='C2',
                                                   Deployment_id__c='Dep2')            
                };
                    insert PreChatList;
    }
    
    static testMethod void testMethod1()
    {
        system.runas(UserAdminList[0])
        {
            PageReference pageRef = Page.VFP19_LiveAgentPreChatForm;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('endpoint','deployment_id=Dep1&org_id');
            
            test.startTest();
            
            VFC19_LiveAgentPreChatForm controller = new VFC19_LiveAgentPreChatForm();
            
            controller.getSecondaryPickVals();
            controller.SelectedCategory='Cat1';
            controller.getSecondaryPickVals();
            controller.SelectedSubCategory='SubCat1';
            controller.SelectButton();
            controller.CustomerComment='test';
            controller.setComment();
            
            system.assertEquals('57325000000CaRb', controller.SelectedButton);
            system.assertEquals('test', controller.CustomerComment);
            
            test.stopTest();
        }
    }
    
    static testMethod void testMethod2()
    {
        system.runas(UserAdminList[1])
        {
            PageReference pageRef = Page.VFP19_LiveAgentPreChatForm;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('endpoint','deployment_id=Dep2&org_id');
            
            test.startTest();
            
            VFC19_LiveAgentPreChatForm controller = new VFC19_LiveAgentPreChatForm();
            
            controller.getSecondaryPickVals();
            controller.SelectedCategory='Cat2';
            controller.getSecondaryPickVals();
            controller.SelectButton();
            
            system.assertEquals('', controller.SelectedButton);
            
            test.stopTest();
        }
    }                                                                                                 
}