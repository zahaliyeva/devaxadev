@isTest
private class VFC10_CaseCommentExtension_TEST {

    static testmethod void constructorTest() {
        //MDANTONIO 09/04/2019 popolamento custom settings per classi di test - start
        ServiceUtilsClass.populateCustomSettingsForTests();
        //MDANTONIO 09/04/2019 popolamento custom settings per classi di test - end
        //OAVERSANO 05/02/2019 : NMA Enhancement V -- START
        MPS_Code_Variables__c setting = new MPS_Code_Variables__c();
        setting.Name = 'NotifyCaseCommentToAdvisor';
        setting.Value__c = 'Inserimento_commento_interno';
        setting.Key__c = '0D22500000001YZ';
        insert setting;
        //OAVERSANO 05/02/2019 : NMA Enhancement V -- END
        
        // set up data        
        Case cas = new Case (subject='test');
          insert cas;
    CaseComment com = new CaseComment (CommentBody='test',
                                      parentId=cas.id);
        insert com;
        // start test 
        Test.startTest();

        // set test page to VF page 
        Test.setCurrentPage(Page.VFP10_CaseComment);

        //constructor
        VFC10_CaseCommentExtension controller = new VFC10_CaseCommentExtension(new ApexPages.StandardController(cas));

        // test action methods on controller and assertions
        controller.addcomment();
        System.assertEquals(false, com.Ispublished);
        System.assertEquals(cas.Id, com.parentId);

        // stop test
        Test.stopTest();
    }

}