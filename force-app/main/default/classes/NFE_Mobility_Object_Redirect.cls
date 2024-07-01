public class NFE_Mobility_Object_Redirect {
    
    private static String homePageUrl;
    private static String accountPath;
    private static String contactPath;
    private static String campaignPath;
    private static String leadPath;
    public static NFE_PassPortal_Utils passPortalUtils;
    
    public NFE_Mobility_Object_Redirect() {}

    public static void initConfig(){
        passPortalUtils = new NFE_PassPortal_Utils();

        homePageUrl = passPortalUtils.getPassPortalConfiguration() != null && !passPortalUtils.getPassPortalConfiguration().isEmpty() ? 
            passPortalUtils.getPassPortalConfiguration()[0].Home_Url__c : NFE_PassPortal_Utils.HomePageUrl_Fallback;
    }
    
    public static String getHomePageUrl() {
        initConfig();

        return homePageUrl;
    }
    
    @AuraEnabled
    public static String getAccountPath() {
        initConfig();

        accountPath = passPortalUtils.getPassPortalConfiguration() != null && !passPortalUtils.getPassPortalConfiguration().isEmpty() ? 
            passPortalUtils.getPassPortalConfiguration()[0].Account_Path__c : NFE_PassPortal_Utils.AccountPath_Fallback;
        return homePageUrl + accountPath;
    }
    
    @AuraEnabled
    public static String getContactPath() {
        initConfig();
            
        contactPath = passPortalUtils.getPassPortalConfiguration() != null && !passPortalUtils.getPassPortalConfiguration().isEmpty() ? 
            passPortalUtils.getPassPortalConfiguration()[0].Contact_Path__c : NFE_PassPortal_Utils.ContactPath_Fallback;
        return homePageUrl + contactPath;
    }
    
    @AuraEnabled
    public static String getCampaignPath() {
        initConfig();
            
        campaignPath = passPortalUtils.getPassPortalConfiguration() != null && !passPortalUtils.getPassPortalConfiguration().isEmpty() ? 
            passPortalUtils.getPassPortalConfiguration()[0].Campaign_Path__c : NFE_PassPortal_Utils.CampaignPath_Fallback;
        return homePageUrl + campaignPath;
    }
    
    @AuraEnabled
    public static String getLeadPath() {
        initConfig();
            
        leadPath = passPortalUtils.getPassPortalConfiguration() != null && !passPortalUtils.getPassPortalConfiguration().isEmpty() ? 
            passPortalUtils.getPassPortalConfiguration()[0].Lead_Path__c : NFE_PassPortal_Utils.LeadPath_Fallback;
        return homePageUrl + leadPath;
    }
    
}