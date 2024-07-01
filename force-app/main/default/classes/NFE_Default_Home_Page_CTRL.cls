public class NFE_Default_Home_Page_CTRL {
	
    private static String homePageUrl;
    private static String blackListPath;
    private static String knowledgePath;
    private static String reportisticaPath;
    private static String monitoraggioPath;
    private static String chiudiCasePath;
    private static String newChiudiCasePath;
    private static String prendiInCaricoPath;
    private static String accettaSoluzionePath;
    private static String annullaRichiestaPath;
    private static String inserisciCommentoPath;
    private static String rifiutaSoluzionePath;
    public static NFE_PassPortal_Utils passPortalUtils;
	// id. 261 btn feeback 
    private static String CaseFeebaclkRelated;
    private static String CaseSelf;

    // id 278 26-01-2022 *-+
    public String caseStatus				{get;set;}
    public String ownerID				{get;set;}
    public Boolean OwnerIsQueue             {get;set;}  
    public Boolean isOwnerAdvisor             {get;set;}    

    
    
    private final Case caseObj;
    
    public NFE_Default_Home_Page_CTRL (ApexPages.StandardController stdController) {

       this.caseObj = (Case)stdController.getRecord();


       ID cas=ApexPages.currentPage().getParameters().get('id');
        if(cas!=null){
        	Case c = [SELECT Id, Status, CaseNumber, Details_of_Solution__c,isClosed,OwnerId FROM Case WHERE ID =:cas LIMIT 1];
        	//solution = (c.Details_of_Solution__c!=null)?c.Details_of_Solution__c:'';
        	//caseNumber = (c.CaseNumber!=null)?c.CaseNumber:'';
        	caseStatus = (c.Status!=null)?c.Status:'';
            //caseisClosed = c.isClosed;

            ownerID = c.OwnerId;
            OwnerIsQueue = (ownerID.startsWith('00G'))?true:false;
        }
    }
    public NFE_Default_Home_Page_CTRL() {}
    
    public static String getHomePageUrl() {
        passPortalUtils = new NFE_PassPortal_Utils();
        homePageUrl = passPortalUtils.getPassPortalConfiguration() != null && !passPortalUtils.getPassPortalConfiguration().isEmpty() ? 
            passPortalUtils.getPassPortalConfiguration()[0].Home_Url__c : NFE_PassPortal_Utils.HomePageUrl_Fallback;
        return homePageUrl;
    }
    
    @AuraEnabled
	public static String getBlackListPath() {
        passPortalUtils = new NFE_PassPortal_Utils();
        blackListPath = passPortalUtils.getPassPortalConfiguration() != null && !passPortalUtils.getPassPortalConfiguration().isEmpty() ? 
            passPortalUtils.getPassPortalConfiguration()[0].Black_List_Path__c : NFE_PassPortal_Utils.BlackListPath_Fallback;
        return blackListPath;
    }
    
    @AuraEnabled
    public static String getKnowledgePath() {
        passPortalUtils = new NFE_PassPortal_Utils();
        knowledgePath = passPortalUtils.getPassPortalConfiguration() != null && !passPortalUtils.getPassPortalConfiguration().isEmpty() ? 
            passPortalUtils.getPassPortalConfiguration()[0].Knowledge_Path__c : NFE_PassPortal_Utils.KnowledgePath_Fallback;
        return knowledgePath;
    }
    
        
    @AuraEnabled
    public static String getReportisticaPath() {
        passPortalUtils = new NFE_PassPortal_Utils();
        reportisticaPath = passPortalUtils.getPassPortalConfiguration() != null && !passPortalUtils.getPassPortalConfiguration().isEmpty() ? 
            passPortalUtils.getPassPortalConfiguration()[0].Reportistica_Path__c : NFE_PassPortal_Utils.ReportisticaPath_Fallback;
        return reportisticaPath;
    }
    
    
    @AuraEnabled
	public static String getMonitoraggioPath() {
        passPortalUtils = new NFE_PassPortal_Utils();
        monitoraggioPath = passPortalUtils.getPassPortalConfiguration() != null && !passPortalUtils.getPassPortalConfiguration().isEmpty() ? 
            passPortalUtils.getPassPortalConfiguration()[0].Monitoraggio_Path__c : NFE_PassPortal_Utils.MonitoraggioPath_Fallback;
        return monitoraggioPath;
    }

    public String getChiudiCasePath() {
        passPortalUtils = new NFE_PassPortal_Utils();
        chiudiCasePath = passPortalUtils.getPassPortalConfiguration() != null && !passPortalUtils.getPassPortalConfiguration().isEmpty() ?
                passPortalUtils.getPassPortalConfiguration()[0].Chiudi_Case_Path__c : NFE_PassPortal_Utils.ChiudiCasePath_Fallback;
        return chiudiCasePath + this.caseObj.Id;
    }

    public String getNewChiudiCasePath() {
        system.debug('Sono qui!');
        passPortalUtils = new NFE_PassPortal_Utils();
        newChiudiCasePath = passPortalUtils.getPassPortalConfiguration() != null && !passPortalUtils.getPassPortalConfiguration().isEmpty() ?
                passPortalUtils.getPassPortalConfiguration()[0].New_Chiudi_Case_Path__c : NFE_PassPortal_Utils.ChiudiCasePath_Fallback;
        return newChiudiCasePath + this.caseObj.Id;
    }

    public String getPrendiInCaricoPath() {
        passPortalUtils = new NFE_PassPortal_Utils();
        prendiInCaricoPath = passPortalUtils.getPassPortalConfiguration() != null && !passPortalUtils.getPassPortalConfiguration().isEmpty() ?
                passPortalUtils.getPassPortalConfiguration()[0].Prendi_In_Carico_Path__c : NFE_PassPortal_Utils.PrendiInCaricoPath_Fallback;
        return prendiInCaricoPath + this.caseObj.Id;
    }
    
       public String getAccettaSoluzionePath() {
        passPortalUtils = new NFE_PassPortal_Utils();
        accettaSoluzionePath = passPortalUtils.getPassPortalConfiguration() != null && !passPortalUtils.getPassPortalConfiguration().isEmpty() ?
                passPortalUtils.getPassPortalConfiguration()[0].Accetta_Soluzione_Path__c : NFE_PassPortal_Utils.AccettaSoluzionePath_Fallback;
        return accettaSoluzionePath + this.caseObj.Id;
    }
    
    
      public String getAnnullaRichiestaPath() {
        passPortalUtils = new NFE_PassPortal_Utils();
        annullaRichiestaPath = passPortalUtils.getPassPortalConfiguration() != null && !passPortalUtils.getPassPortalConfiguration().isEmpty() ?
                passPortalUtils.getPassPortalConfiguration()[0].Annulla_Richiesta_Path__c : NFE_PassPortal_Utils.AnnullaRichiestaPath_Fallback;
        return annullaRichiestaPath + this.caseObj.Id;
    }
    
      public String getInserisciCommentoPath() {
        passPortalUtils = new NFE_PassPortal_Utils();
        inserisciCommentoPath = passPortalUtils.getPassPortalConfiguration() != null && !passPortalUtils.getPassPortalConfiguration().isEmpty() ?
                passPortalUtils.getPassPortalConfiguration()[0].Inserisci_Commento_Path__c : NFE_PassPortal_Utils.InserisciCommentoPath_Fallback;
        return inserisciCommentoPath + this.caseObj.Id;
    }

        
       public String getRifiutaSoluzionePath() {
        passPortalUtils = new NFE_PassPortal_Utils();
        rifiutaSoluzionePath = passPortalUtils.getPassPortalConfiguration() != null && !passPortalUtils.getPassPortalConfiguration().isEmpty() ?
                passPortalUtils.getPassPortalConfiguration()[0].Rifiuta_Soluzione_Path__c : NFE_PassPortal_Utils.RifiutaSoluzionePath_Fallback;
        return rifiutaSoluzionePath + this.caseObj.Id;
    }

    public String getCaseFeebaclkRelated (){

                String NonFeedbackFound = 'Non è possibile trovare un Feedback per Case -' ;
        feedback__C Feedback_id = null;
        try {
            Feedback_id = [select id from feedback__C where CTL_Case__c =:this.caseObj.Id ];
               
            return '../apex/javascriptIntegration?component=mobilityCustomDetailPage&id=mobilityCustomDetailPage&showContain=true&recordId='+ Feedback_id.Id +'&recordType=Feedback__c&title=Feedback';
        }catch (QueryException NonList){
            return null ;
        }   
    } 
    
    public String getCaseSelf (){
        return '/crm/s/case/'+this.caseObj.Id+'/detail';
    } 
    
        
    public String getChiudiCaseMobility() {
        return '/crm/s/chiudi-case?recordId=' + this.caseObj.Id;
    }

    public String getPrintableViewMobility() {
        return '/crm/s/stampa-case?recordId=' + this.caseObj.Id;
    }
}