@isTest class ApplicationLogHelperTest {
   
    @isTest 
    public static void testERROR(){
        Test.startTest();
        ApplicationLogHelper.ERROR('ApplicationLogHelperTest', 'exceptionMessage', 'exceptionDetail');
        Test.stopTest();
        System.assertEquals(false, [SELECT Id from ApplicationLog__c limit 1].isEmpty());
    }

    @isTest 
    public static void testINFO(){
        Test.startTest();
        ApplicationLogHelper.INFO('ApplicationLogHelperTest', 'exceptionMessage', 'exceptionDetail');
        Test.stopTest();
        System.assertEquals(false, [SELECT Id from ApplicationLog__c limit 1].isEmpty());
    }

    @isTest 
    public static void testLogErrors(){
        Test.startTest();
        List<ApplicationLogHelper.ErrorWrapper> errors = new List<ApplicationLogHelper.ErrorWrapper>();
        errors.add(new ApplicationLogHelper.ErrorWrapper('exceptionDetail','exceptionMessage'));
        ApplicationLogHelper.LogErrors('ApplicationLogHelperTest', errors);
        Test.stopTest();
        System.assertEquals(false, [SELECT Id from ApplicationLog__c limit 1].isEmpty());
}
}