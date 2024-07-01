public class NFE_PassPortal_Utils {
    
    public static String HomePageUrl_Fallback = Label.NFE_HomePageUrl_Fallback;
    public static String BlackListPath_Fallback = Label.NFE_BlackListPath_Fallback;
    public static String KnowledgePath_Fallback = Label.NFE_KnowledgePath_Fallback;
    public static String MonitoraggioPath_Fallback = Label.NFE_MonitoraggioPath_Fallback;
    public static String ChiudiCasePath_Fallback = Label.NFE_ChiudiCasePath_Fallback;
    public static String PrendiInCaricoPath_Fallback = Label.NFE_PrendiInCaricoPath_Fallback;
    public static String AccettaSoluzionePath_Fallback = Label.NFE_AccettaSoluzionePath_Fallback;
    public static String AnnullaRichiestaPath_Fallback = Label.NFE_AnnullaRichiestaPath_Fallback;
    public static String InserisciCommentoPath_Fallback = Label.NFE_InserisciCommentoPath_Fallback;
    public static String RifiutaSoluzionePath_Fallback = Label.NFE_RifiutaSoluzionePath_Fallback;
    public static String CreaPropostaPath_Fallback = Label.NFE_CreaPropostaPath_Fallback;
    public static String CreaPropostaUrl_Fallback = Label.NFE_CreaPropostaUrl_Fallback;
    public static String AssociaPropostaPath_Fallback = Label.NFE_AssociaPropostaPath_Fallback;
    public static String ReportisticaPath_Fallback = Label.NFE_ReportisticaPath_Fallback;
    public static String EliminaTrattivaPath_Fallback = Label.NFE_EliminaTrattativaPath_Fallback;

    //IDcrm 018 campaign LWC new
    public static String Svalidazione_Campagne_Path_Fallback = Label.NFE_Svalidazione_Campagne_Path_Fallback;
     
    public static String LeadPath_Fallback = Label.NFE_LeadPath_Fallback;
    public static String AccountPath_Fallback = Label.NFE_AccountPath_Fallback;
    public static String ContactPath_Fallback = Label.NFE_ContactPath_Fallback;
    public static String CampaignPath_Fallback = Label.NFE_CampaignPath_Fallback;
    
    public String env = Label.NFE_ENV;
    public List<Pass_Portal_Configuration__mdt> passPortalConfiguration;
    
    public List<Pass_Portal_Configuration__mdt> getPassPortalConfiguration() {
        
        if (this.passPortalConfiguration == null || this.passPortalConfiguration.isEmpty()) {
            this.passPortalConfiguration = [SELECT Home_Url__c, Black_List_Path__c, Knowledge_Path__c, Monitoraggio_Path__c, Lead_Path__c, Account_Path__c, Contact_Path__c, Campaign_Path__c,
                                                Chiudi_Case_Path__c, Prendi_In_Carico_Path__c, Accetta_Soluzione_Path__c, Annulla_Richiesta_Path__c, Inserisci_Commento_Path__c, Rifiuta_Soluzione_Path__c,
                                                Crea_Proposta_Path__c, Associa_Proposta_Path__c , Reportistica_Path__c,Elimina_Trattativa_Path__c, Crea_Proposta_Daol_Url__c, New_Chiudi_Case_Path__c,
                                                Svalidazione_Campagne__c 
                                            FROM Pass_Portal_Configuration__mdt
                                            WHERE Environment__c = :env];
        }
        return this.passPortalConfiguration;
        
    }
    
}