@isTest
public class ContentDocumentLinkTest {

    @TestSetup
    static void makeData(){
        ServiceUtilsClass.populateCustomSettingsForTests();
        Id recordtypeId = [Select Id from Recordtype Where Name = 'B2B Client' and sObjecttype='Account'].Id;
        Account account = new Account(Name = 'Duplicated',
            RecordtypeId = recordtypeId,
            AAI_Codice_fiscale__c = 'BB176176abcdefgh',
            AAI_Agency_Reference_Code__c = '004610',
            State__c = 'ATTIVO');
        insert account;
        Contact contact = new Contact(LastName = 'test');
        insert contact;
        contact.AccountId = account.Id;
        update contact;
        String caseRecordTypeId = RecordTypeUtility.getRecordTypeIdByDeveloperName('Case', 'Assistenza_Agenti');
        Case aCase = new Case(
            Complainant__c='Customer',
            Status = 'Open',
            AccountId = account.Id,
            Category__c='Duplicati polizza di risparmio',
            RecordTypeId = caseRecordTypeId,
            Origin    = 'Email');
        insert aCase;
        Case otherCase = new Case(
            Complainant__c='Customer',
            Status = 'Open',
            AccountId = account.Id,
            Category__c='Duplicati polizza di risparmio',
            RecordTypeId = caseRecordTypeId,
            Origin    = 'PCC');
        insert otherCase;
        EmailMessage emailMessage = new EmailMessage(parentId = aCase.id, Incoming = true );
        insert emailMessage;
    }
    
    @isTest
    public static void testCheckExtension(){
        try{
            Contact c = [SELECT Id from Contact LIMIT 1];
            Test.startTest();
            Blob beforeblob=Blob.valueOf('Unit Test Attachment Body');
            ContentVersion cv = new ContentVersion();
            cv.title = 'test';           
			cv.PathOnClient = cv.title + '.' + 'xxx';			
            cv.VersionData =beforeblob;          
            insert cv;         
            ContentVersion testContent = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cv.Id];
            ContentDocumentLink contentlink=new ContentDocumentLink();
            contentlink.LinkedEntityId = [SELECT Id from Contact LIMIT 1].Id;
            contentlink.ShareType = 'V';
            contentlink.ContentDocumentId=testcontent.ContentDocumentId;
            insert contentlink;
            Test.stopTest();
        } catch(Exception e){
            System.assertEquals(true, [SELECT Id from Attachment].isEmpty(), 'File Extension is not valid');
        } 
    }

    @isTest
    public static void testCheckExtensionEmailToCase(){
        try{
            Case c = [SELECT Id from Case where Origin = 'Email' LIMIT 1];
            Test.startTest();
            Blob beforeblob=Blob.valueOf('Unit Test Attachment Body');
            ContentVersion cv = new ContentVersion();
            cv.title = 'test';           
			cv.PathOnClient = cv.title + '.' + 'xxx';			
            cv.VersionData =beforeblob;          
            insert cv;         
            ContentVersion testContent = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cv.Id];
            ContentDocumentLink contentlink=new ContentDocumentLink();
            contentlink.LinkedEntityId = [SELECT Id from EmailMessage LIMIT 1].Id;
            contentlink.ShareType = 'V';
            contentlink.ContentDocumentId=testcontent.ContentDocumentId;
            insert contentlink;
            Test.stopTest();
        } catch(Exception e){
            System.assertEquals(true, [SELECT Id from Attachment].isEmpty(), 'File Extension is not valid');
        } 
    }


}