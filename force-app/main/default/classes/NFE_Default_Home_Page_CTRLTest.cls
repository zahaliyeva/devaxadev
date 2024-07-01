@isTest
public class NFE_Default_Home_Page_CTRLTest {
    @testSetup private static void createData(){
        ID BusinessHoursDefault = [SELECT id FROM businesshours WHERE isDefault = TRUE LIMIT 1].id;
        List<MPS_Code_Variables__c> listCustomSetting = new List<MPS_Code_Variables__c>();
        listCustomSetting.add(new MPS_Code_Variables__c(Name = 'BusinessHours_Default', Value__c = BusinessHoursDefault));
        insert listCustomSetting;
        Account a = new Account(Name = 'Test');
        insert a;
        Case c = new Case(AccountId = a.Id);
        insert c; 
    }
    
    @isTest static void test() {
        Test.startTest();
        Case c = [SELECT id FROM Case LIMIT 1];
        
        
        PageReference pageRef = Page.NFE_Default_Home_Page;
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('Id', c.id);
        ApexPages.StandardController sc = new ApexPages.StandardController(c);
        
        NFE_Default_Home_Page_CTRL nfe = new NFE_Default_Home_Page_CTRL(sc);
        NFE_Default_Home_Page_CTRL.getHomePageUrl();
        NFE_Default_Home_Page_CTRL.getBlackListPath();
        NFE_Default_Home_Page_CTRL.getKnowledgePath();
        NFE_Default_Home_Page_CTRL.getReportisticaPath();
        NFE_Default_Home_Page_CTRL.getMonitoraggioPath();
        nfe.getChiudiCasePath();
        nfe.getNewChiudiCasePath();
        nfe.getPrendiInCaricoPath();
        nfe.getAccettaSoluzionePath();
        nfe.getAnnullaRichiestaPath();
        nfe.getInserisciCommentoPath();
        nfe.getRifiutaSoluzionePath();
        nfe.getCaseFeebaclkRelated();
        nfe.getCaseSelf();
        nfe.getChiudiCaseMobility();
        nfe.getPrintableViewMobility();
        Test.stopTest();          
    }

    @isTest 
    public static void NFE_Mobility_Object_RedirectCoverage() {
        Test.startTest();
        NFE_Mobility_Object_Redirect o = new NFE_Mobility_Object_Redirect();
        NFE_Mobility_Object_Redirect.getHomePageUrl();
        NFE_Mobility_Object_Redirect.getAccountPath();
        NFE_Mobility_Object_Redirect.getCampaignPath();
        NFE_Mobility_Object_Redirect.getContactPath();
        NFE_Mobility_Object_Redirect.getLeadPath();
        Test.stopTest();
    }
}