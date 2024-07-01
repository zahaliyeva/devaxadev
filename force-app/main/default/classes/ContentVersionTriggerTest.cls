@isTest
private class ContentVersionTriggerTest {

    @TestSetup
    static void makeData(){
        FileUploadHelperTest.setConfig();
    }
    
    @isTest
    public static void testInsertContentVersion(){
        try{
            Test.startTest();
            ContentVersion cv=new Contentversion();
            cv.title='ABC';
            cv.PathOnClient ='test.yyy';
            Blob b=Blob.valueOf('Unit Test Attachment Body');
            cv.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
            insert cv;
            Test.stopTest();
        } catch(Exception e){
            System.debug(System.LoggingLevel.ERROR,'Exception: ' + e.getmessage() + '\tStackTrace: '+e.getStackTraceString());
            //System.AssertEquals(true, e.getMessage().contains('Estensione del file non valida') ? true : false);
        } 
    }
}