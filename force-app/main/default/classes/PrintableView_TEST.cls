@isTest
public class PrintableView_TEST {
    
    @testSetup static void setup() 
    {
        //MDANTONIO 09/04/2019 popolamento custom settings per classi di test - start
        ServiceUtilsClass.populateCustomSettingsForTests();
        //MDANTONIO 09/04/2019 popolamento custom settings per classi di test - end
        CaseTeamRole role = [select Name from CaseTeamRole where Name = 'HD1' LIMIT 1];

        Case caseObj1 = new Case(Status    = 'Open',
                                 Origin    = 'Portale Assistenza');
        insert caseObj1;
        Storico_conversazioni__c sc = new Storico_conversazioni__c( Description__c = 'test', Connected_case__c = caseObj1.Id, CaseStatus__c = caseObj1.Status, Type__c = 'Supporto' );
        insert sc;
        Attachment attach=new Attachment();   	
    	attach.Name='Unit Test Attachment.CSV';
    	Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
    	attach.body=bodyBlob;
        attach.parentId=caseObj1.id;
        insert attach;
        CaseTeamMember ctM = new CaseTeamMember(TeamRoleId = role.Id, ParentId = caseObj1.Id,MemberId = UserInfo.getUserId() );
        insert ctM;  	
        
    }
    
    static testMethod void testmethod1() 
    {
        test.StartTest();
        List<Case> caseobj = [SELECT Id, Origin FROM Case LIMIT 1];
        
        
        PageReference pageRef = Page.PrintableView;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('id', String.valueOf(caseobj[0].Id));
        pageRef.getParameters().put('plName','Assistenza Agenti_HD2_PrintableView');
        PrintableView printView = new PrintableView();        
        test.stopTest();
    } 
    
}