@isTest 
public with sharing class MobilityDashboardUtilityTEST {
    
    @isTest 
    public static void createNavigationConfigurationTest() {
        Map<String, String> params = new Map<String, String> ();
        params.put('dashboardName','TestDash');
        params.put('currentPageName','TestPage');
        params.put('currentPageId','fakeid');
        Test.startTest();
        MobilityDashboardUtility.createNavigationConfiguration(params);
        MobilityDashboardUtility.isAllowedEcollab();
        MobilityDashboardUtility.isAllowed();
        MobilityDashboardUtility.InitRecordIniziativaMkt('test');
        Test.stopTest();
        Mobility_Dashboard_Pages__c res = [select id, Dashboard_Name__c from Mobility_Dashboard_Pages__c limit 1];
        Assert.areEqual('TestDash', res.Dashboard_Name__c);
    }

    @isTest 
    public static void getNavigationConfigurationTest() {
        insert new Mobility_Dashboard_Pages__c(Name = 'TestName', Dashboard_Name__c = 'TestDash', Page_Name__c = 'TestPage', Page_Id__c = 'fakeid');
        Map<String, String> params = new Map<String, String> ();
        params.put('dashboardName','TestDash');
        params.put('currentPageName','TestPage');
        params.put('targetPageName','TargetTestPage');
        Test.startTest();
        MobilityDashboardUtility.responseWrapper res = MobilityDashboardUtility.getNavigationConfiguration(params);
        Test.stopTest();

        Assert.areEqual(true, res.currentPageExists);
        Assert.areEqual(null, res.targetPageId);
    }

    @isTest 
    public static void getInitmobilityEcollabCruscotto(){
        CommunicationToCustomerHandlerTest.setup() ;
        MPS_Code_Utils__mdt codeCom_dinamic = MPS_Code_Utils__mdt.getInstance('PushFase2_Ecollab_CodeCom');
        list<Iniziative_Marketing__c> iniziativaUpdate = [Select id,Name, URL_Immagine__c, URL_CTA__c, Titolo__c, Sottotitolo__c, Short_Message__c,
            Message__c, Testo_CTA__c, Communication_code__c, Versione__c, Eligibile_per_Compagnia__c,
            Nome_Messaggio__c,Categoria_Prodotto__c,Sottotipologia_Campagna__c,Tipologia_Campagna__c,
            Contenuto__c,Visibilita_nel_centro_notifiche__c,Invio_push__c,Tipo_notifica_su_Centro_Notifiche__c,  
            Canale__c, Descrizione_dell_iniziativa__c,is_scheduled_type__c,is_closure_type__c,Tipologia_di_iniziative__c   
            from Iniziative_Marketing__c limit 1];
        MobilityDashboardUtility.InitRecords();
        if(!iniziativaUpdate.isEmpty()){
            iniziativaUpdate[0].Communication_code__c =codeCom_dinamic.Value__c ;
            update iniziativaUpdate;
        }
        MobilityDashboardUtility.InitRecords();
    }
}