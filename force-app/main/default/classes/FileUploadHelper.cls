public with sharing class FileUploadHelper {
  
    private static final List<String> WEB_FORM_ORIGINS = new List<String>{
        'Webform privato',
        'Webform pubblico',
        'My AXA',
        'PCC',
        'BranchMain',
        'Portale Assistenza MPS'
    };
    private static final List<String> EMAIL_ORIGINS = new List<String>{
        'Email', 
        'PEC'
    };

    public static FileUploadSetting__c getSetting(){
         return FileUploadSetting__c.getInstance();
    }

    public static Boolean isEnabledOnTriggerClassic(){
        return FileUploadSetting__c.getInstance().TriggerClassic__c;
    }

    public static Boolean isEnabledOnTriggerLightning(){
        return FileUploadSetting__c.getInstance().TriggerLightning__c;
    }

    public static Boolean isEnabledSendEmail(){
        return FileUploadSetting__c.getInstance().SendEmail__c;
    }

    public static List<String> getBadExtensions(){
        String badExtensions = FileUploadSetting__c.getInstance().BadExtensions__c;
        if(String.isNotBlank(badExtensions)){
            return badExtensions.split(';');
        }
        return new List<String>();
    }

    public static List<String> getAllowedExtensions(){
        String allowedExtensions = FileUploadSetting__c.getInstance().AllowedExtensions__c;
        if(String.isNotBlank(allowedExtensions)){
            return allowedExtensions.split(';');
        }
        return new List<String>();
    }

    public static List<String> getBadExtensionsEmailToCase(){
        String badExtensions = FileUploadSetting__c.getInstance().BadExtensionsEmailToCase__c;
        if(String.isNotBlank(badExtensions)){
            return badExtensions.split(';');
        }
        return new List<String>();
    }

    public static List<String> getBadExtensionsWebForms(){
        String badExtensions = FileUploadSetting__c.getInstance().BadExtensionsWebForms__c;
        if(String.isNotBlank(badExtensions)){
            return badExtensions.split(';');
        }
        return new List<String>();
    }

    public static Boolean isFromEmailToCase(String origin){
        return EMAIL_ORIGINS.contains(origin);
    }

    public static Boolean isFromWebForm(String origin){
        return WEB_FORM_ORIGINS.contains(origin);
    }

    public static Boolean isExtensionAllowed(String extension){
        for(String allowedExtension: FileUploadHelper.getAllowedExtensions()){
            if(allowedExtension.equalsIgnoreCase(extension)){
                return true;
            }
       }
       return false;
    }

    public static Boolean isFilePathAllowed(String filePath){
        try{
            String extension = filePath.split('\\.')[filePath.split('\\.').size() - 1];
            return FileUploadHelper.isExtensionAllowed(extension);
        } catch(Exception ex){
            System.debug('FileUploadHelper.isFilePathAllowed: ' + ex.getStackTraceString());
            return false;
        }       
    }
    
}