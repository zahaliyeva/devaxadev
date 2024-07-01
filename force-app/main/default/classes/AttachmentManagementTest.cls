@isTest class AttachmentManagementTest {

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
        Case aCase = new Case(
            AccountId = account.Id,
            Status    = 'Open',
            Origin    = 'Email');
        insert aCase;
        Case otherCase = new Case(
            AccountId = account.Id,
            Status    = 'Open',
            Origin    = 'PCC');
        insert otherCase;
    }
    
    @isTest
    public static void testCheckExtension(){
        try{
            Contact c = [SELECT Id from Contact LIMIT 1];
            Test.startTest();
            Attachment attachment = new Attachment();
            attachment.Body       = Blob.valueOf('CiAgICAgPHhzZDpwYXR0ZXJuIHZhbHVlPSJbYS16QS1aMC05XXsxOH0iLz4KICAgIDwveHNkOnJlc3RyaWN0aW9uPgogICA8L3hzZDpzaW1wbGVUeXBlPgogICA8eHNkOmNvbXBsZXhUeXBlIG5hbWU9IlNlcnZpY2VSZXN1bHQiPgogICAgPHhzZDpzZXF1ZW5jZT4KICAgICA8eHNkOmVsZW1lbnQgbmFtZT0iTWVzc2FnZSIgbWluT2NjdXJzPSIwIiB0eXBlPSJ4c2Q6c3RyaW5nIiBuaWxsYWJsZT0idHJ1ZSIvPgogICAgIDx4c2Q6ZWxlbWVudCBuYW1lPSJSZXN1bHQiIG1pbk9jY3Vycz0iMCIgdHlwZT0ieHNkOnN0cmluZyIgbmlsbGFibGU9InRydWUiLz4KICAgICA8eHNkOmVsZW1lbnQgbmFtZT0iVXNlckQiIG1pbk9jY3Vycz0iMCIgdHlwZT0idG5zOlVzZXJEZXRhaWxzSW5wdXQiIG5pbGxhYmxlPSJ0cnVlIi8');
            attachment.Name       = String.valueOf('test.xxx');
            attachment.ParentId   = c.Id; 
            insert attachment;
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
            Attachment attachment = new Attachment();
            attachment.Body       = Blob.valueOf('CiAgICAgPHhzZDpwYXR0ZXJuIHZhbHVlPSJbYS16QS1aMC05XXsxOH0iLz4KICAgIDwveHNkOnJlc3RyaWN0aW9uPgogICA8L3hzZDpzaW1wbGVUeXBlPgogICA8eHNkOmNvbXBsZXhUeXBlIG5hbWU9IlNlcnZpY2VSZXN1bHQiPgogICAgPHhzZDpzZXF1ZW5jZT4KICAgICA8eHNkOmVsZW1lbnQgbmFtZT0iTWVzc2FnZSIgbWluT2NjdXJzPSIwIiB0eXBlPSJ4c2Q6c3RyaW5nIiBuaWxsYWJsZT0idHJ1ZSIvPgogICAgIDx4c2Q6ZWxlbWVudCBuYW1lPSJSZXN1bHQiIG1pbk9jY3Vycz0iMCIgdHlwZT0ieHNkOnN0cmluZyIgbmlsbGFibGU9InRydWUiLz4KICAgICA8eHNkOmVsZW1lbnQgbmFtZT0iVXNlckQiIG1pbk9jY3Vycz0iMCIgdHlwZT0idG5zOlVzZXJEZXRhaWxzSW5wdXQiIG5pbGxhYmxlPSJ0cnVlIi8');
            attachment.Name       = String.valueOf('test.xxx');
            attachment.ParentId   = c.Id; 
            insert attachment;
            Test.stopTest();
        } catch(Exception e){
            System.assertEquals(true, [SELECT Id from Attachment].isEmpty(), 'File Extension is not valid');
        } 
    }

    @isTest
    public static void testCheckExtensionWebForm(){
        try{
            Case c = [SELECT Id from Case where Origin = 'PCC' LIMIT 1];
            Test.startTest();
            Attachment attachment = new Attachment();
            attachment.Body       = Blob.valueOf('CiAgICAgPHhzZDpwYXR0ZXJuIHZhbHVlPSJbYS16QS1aMC05XXsxOH0iLz4KICAgIDwveHNkOnJlc3RyaWN0aW9uPgogICA8L3hzZDpzaW1wbGVUeXBlPgogICA8eHNkOmNvbXBsZXhUeXBlIG5hbWU9IlNlcnZpY2VSZXN1bHQiPgogICAgPHhzZDpzZXF1ZW5jZT4KICAgICA8eHNkOmVsZW1lbnQgbmFtZT0iTWVzc2FnZSIgbWluT2NjdXJzPSIwIiB0eXBlPSJ4c2Q6c3RyaW5nIiBuaWxsYWJsZT0idHJ1ZSIvPgogICAgIDx4c2Q6ZWxlbWVudCBuYW1lPSJSZXN1bHQiIG1pbk9jY3Vycz0iMCIgdHlwZT0ieHNkOnN0cmluZyIgbmlsbGFibGU9InRydWUiLz4KICAgICA8eHNkOmVsZW1lbnQgbmFtZT0iVXNlckQiIG1pbk9jY3Vycz0iMCIgdHlwZT0idG5zOlVzZXJEZXRhaWxzSW5wdXQiIG5pbGxhYmxlPSJ0cnVlIi8');
            attachment.Name       = String.valueOf('test.xxx');
            attachment.ParentId   = c.Id; 
            insert attachment;
            Test.stopTest();
        } catch(Exception e){
            System.assertEquals(true, [SELECT Id from Attachment].isEmpty(), 'File Extension is not valid');
        } 
    }
}