@isTest 
public class FileUploadHelperTest {
    
    @TestSetup
    public static void setConfig(){
        insert new FileUploadSetting__c(TriggerClassic__c = true, TriggerLightning__c = true, BadExtensions__c = 'xxx;', BadExtensionsEmailToCase__c = 'xxx;', BadExtensionsWebForms__c = 'xxx', AllowedExtensions__c = 'yyy;csv');
    }

    @isTest 
    public static void testGetSetting(){
        System.assertEquals(true, FileUploadHelper.getSetting() != null);
    }
 
    @isTest 
    public static void testIsEnabledOnTriggerClassic(){
        System.assertEquals(true,  FileUploadHelper.isEnabledOnTriggerClassic());
    }

    @isTest 
    public static void testIsEnabledOnTriggerLightning(){
        System.assertEquals(true,  FileUploadHelper.isEnabledOnTriggerLightning());
    }

    @isTest 
    public static void testIsEnabledSendEmail(){
        System.assertEquals(true,  FileUploadHelper.isEnabledSendEmail());
    }

    @isTest 
    public static void testGetBadExtensions(){
        System.assertEquals(true,  !FileUploadHelper.getBadExtensions().isEmpty());
    }

    @isTest 
    public static void testGetAllowedExtensions(){
        System.assertEquals(true,  !FileUploadHelper.getAllowedExtensions().isEmpty());
    }

    @isTest 
    public static void testGetBadExtensionsEmailToCase(){
        System.assertEquals(true,  !FileUploadHelper.getBadExtensionsEmailToCase().isEmpty());
    }

    @isTest 
    public static void testGetBadExtensionsWebForms(){
        System.assertEquals(true,  !FileUploadHelper.getBadExtensionsWebForms().isEmpty());
    }

    
    @isTest 
    public static void testIsFromEmailToCase(){
        System.assertEquals(true, FileUploadHelper.isFromEmailToCase('Email'));
    }

    @isTest 
    public static void testIsFromWebForm(){
        System.assertEquals(true, FileUploadHelper.isFromWebForm('PCC'));
    }

    @isTest 
    public static void testIsFilePathAllowed(){
        System.assertEquals(true, FileUploadHelper.isFilePathAllowed('test.yyy'));
        System.assertEquals(false, FileUploadHelper.isFilePathAllowed('test.zzz'));
    }

}