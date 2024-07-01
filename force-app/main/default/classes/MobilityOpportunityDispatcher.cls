public class MobilityOpportunityDispatcher {
    
    
    private static String creaPropostaPath;
    private static String associaPropostaPath;
    private static String eliminaTrattativaPath;
    public  static String creaPropostaDaolUrl;
    
    
    public static NFE_PassPortal_Utils passPortalUtils;
    
    private final Opportunity oppObj;
    
    public MobilityOpportunityDispatcher (ApexPages.StandardController stdController) {
        this.oppObj = (Opportunity)stdController.getRecord();
    }
    public MobilityOpportunityDispatcher() {}
    
    
    
    public String getCreaPropostaPath() {
        passPortalUtils = new NFE_PassPortal_Utils();
        creaPropostaPath = passPortalUtils.getPassPortalConfiguration() != null && !passPortalUtils.getPassPortalConfiguration().isEmpty() ?
            passPortalUtils.getPassPortalConfiguration()[0].Crea_Proposta_Path__c : NFE_PassPortal_Utils.CreaPropostaPath_Fallback;
        return creaPropostaPath + this.oppObj.Id;
    }
      @AuraEnabled
      public static String getCreaPropostaDaolUrl() {
         passPortalUtils = new NFE_PassPortal_Utils();
         creaPropostaDaolUrl = passPortalUtils.getPassPortalConfiguration() != null && !passPortalUtils.getPassPortalConfiguration().isEmpty() ?
             passPortalUtils.getPassPortalConfiguration()[0].Crea_Proposta_Daol_Url__c : NFE_PassPortal_Utils.CreaPropostaUrl_Fallback;
         return creaPropostaDaolUrl;
     }

    
    public String getAssociaPropostaPath() {
        passPortalUtils = new NFE_PassPortal_Utils();
        associaPropostaPath = passPortalUtils.getPassPortalConfiguration() != null && !passPortalUtils.getPassPortalConfiguration().isEmpty() ?
            passPortalUtils.getPassPortalConfiguration()[0].Associa_Proposta_Path__c : NFE_PassPortal_Utils.AssociaPropostaPath_Fallback;
        return associaPropostaPath + this.oppObj.Id;
    }
    
    public String getEliminaTrattativaPath() {
        passPortalUtils = new NFE_PassPortal_Utils();
        eliminaTrattativaPath = passPortalUtils.getPassPortalConfiguration() != null && !passPortalUtils.getPassPortalConfiguration().isEmpty() ?
            passPortalUtils.getPassPortalConfiguration()[0].Elimina_Trattativa_Path__c : NFE_PassPortal_Utils.EliminaTrattivaPath_Fallback;
        return eliminaTrattativaPath + this.oppObj.Id;
    }
    
}