@isTest
public class SelfQaDVCleanFilesTest {
    
    @testSetup
    static void testSetup(){
        
        /*ContentWorkspace cw = new ContentWorkspace(Name = 'SelfQADV Override');
        insert cw;
        ContentWorkspace cww = [SELECT id, RootContentFolderId FROM ContentWorkspace WHERE Name = 'SelfQADV Override'];
        List<ContentFolder> cwList = new List<ContentFolder>();
        cwList.add(New ContentFolder(Name = 'Staging', ParentContentFolderId = cww.RootContentFolderId));
        cwList.add(New ContentFolder(Name = 'Completed', ParentContentFolderId = cww.RootContentFolderId));
		insert cwList;*/
        
        ID BusinessHoursDefault = [SELECT id FROM businesshours WHERE isDefault = TRUE LIMIT 1].id;
        List<AAI_Code_Variables__c> listCustomSetting = new List<AAI_Code_Variables__c>();
        List<MPS_Code_Variables__c> listCustomSetting2 = new List<MPS_Code_Variables__c>();
        listCustomSetting.add(new AAI_Code_Variables__c(Name = 'QaDVDeleteLimitDays', Value__c = '-1'));
        listCustomSetting2.add(new MPS_Code_Variables__c(Name = 'BusinessHours_Default', Value__c = BusinessHoursDefault));
        insert listCustomSetting;
        insert listCustomSetting2;
        
        Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDevelopername().get('Axa_Assicurazioni').getRecordTypeId();
        
        Case c = new Case (
            RecordtypeId = devRecordTypeId,
            Pratica_Documentale__c = true,
            Origine_Pratica_Documentale__c = 'WFCL',
            Category__c = 'Duplicati polizza di protezione'
        );
        insert c;        
        c.status = 'Closed';
        update c;
        
        List<DocumentAccount__c> dAtoInsert = new List<DocumentAccount__c>();
        DocumentAccount__c dA1 = new DocumentAccount__c(
            CaseId__c = c.Id,
            FirstName__c = 'DocumentAccount1',
            Role__c = 'Soggetto;Richiedente',
            Delegate__c = true,
            TECH_RequiredFieldsMissing__c = true
        );
        dAtoInsert.add(dA1);
        
        DocumentAccount__c dA2 = new DocumentAccount__c(
            CaseId__c = c.Id,
            FirstName__c = 'DocumentAccount2',
            Role__c = 'Soggetto',
            TECH_RequiredFieldsMissing__c = true
        );
        dAtoInsert.add(dA2);
        insert dAtoInsert;
        
        List<DocumentChecklistItem__c> dCtoInsert = new List<DocumentChecklistItem__c>();
        DocumentChecklistItem__c dC1 = new DocumentChecklistItem__c(
            Override__c = false,
            FilenetId__c = '1234',
            TECH_RecordUpdated__c = false,
            CaseID__c = c.Id,
            DocumentAccountId__c = dA1.Id
        );
        dCtoInsert.add(dC1);
        
        DocumentChecklistItem__c dC2 = new DocumentChecklistItem__c(
            Override__c = false,
            FilenetId__c = '1234',
            TECH_RecordUpdated__c = true,
            CaseID__c = c.Id,
            DocumentAccountId__c = dA2.Id
        );
        dCtoInsert.add(dC2);
        insert dCtoInsert;
        
        ContentVersion contentVersion = new ContentVersion(
                    Title          = 'a picture',
                    PathOnClient   = 'Pic.jpg',
                    VersionData    = Blob.valueOf('Test Content'),
                    IsMajorVersion = true);
        insert contentVersion;
        String ContentDocumentId = [Select id from ContentDocument limit 1].Id;
        String CaseId = [Select id from Case limit 1].Id;
        contentDocumentLink cdl = new ContentDocumentLink(LinkedEntityId = Dc1.id, contentDocumentId = ContentDocumentId);
        insert cdl;
        Attachment attach=new Attachment();   	
    	attach.Name='Unit Test Attachment';
    	Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
    	attach.body=bodyBlob;
        attach.parentId=CaseId;
        insert attach;
        
        
    }
    
    static testMethod void executeTest(){        
        
        Test.startTest();
        SelfQaDVCleanFiles obj = new SelfQaDVCleanFiles(1);
        DataBase.executeBatch(obj); 
        Test.stopTest();
        
    }    
    
    /*static testMethod void executeTest2(){   
        
        ContentVersion contentVersion = new ContentVersion(
                    Title          = 'a picture',
                    PathOnClient   = 'Pic.jpg',
                    VersionData    = Blob.valueOf('Test Content'),
                    IsMajorVersion = true);
        insert contentVersion;
        String ContentDocumentId = [Select id from ContentDocument limit 1].Id;
        selfQAdVWizardManageSubjectController.moveToWorkspace(ContentDocumentId); 
        Test.startTest();
        SelfQaDVCleanFiles obj2 = new SelfQaDVCleanFiles(2);
        DataBase.executeBatch(obj2); 
        Test.stopTest();
        
    }*/

    
}