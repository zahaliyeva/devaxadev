/**
 * @description classe di utility inerente alla gestione delle dashboard
 * @author      Reply
 * @since       05/2023
 */
public without sharing class MobilityDashboardUtility {
    
    /**
     * @description classe wrapper per la response dei metodi
     */
    public class responseWrapper{
        /**
         * @description nome del profilo
         */
        @AuraEnabled
        public String ProfileName{get;set;}

        /**
         * @description le informazioni della pagina esistono sul custom settings
         */
        @AuraEnabled
        public Boolean currentPageExists {get;set;}

        /**
         * @description id della pagina target
         */
        @AuraEnabled
        public String targetPageId {get;set;}
        /**
         * @description id della pagina target
         */
        @AuraEnabled
        public Target__c targetScelta {get;set;}    
        /**
         * @description id della pagina target
         */
        @AuraEnabled
        public Iniziative_Marketing__c iniziativaScelta {get;set;}
        /**
         * @description id della pagina target
         */
        @AuraEnabled
        public String dashboardId {get;set;}
        /**
         * @description profilo unico per Ecollab NFE - AAI - Vendite Avanzato scritto nel mtd Profilo_NFE_Abilitati_Invio_Sing_Ecollab
         */
        @AuraEnabled
        public boolean isAllowedEcollab {get;set;}
        /**
         * @description constr
         */
        responseWrapper(){
            this.currentPageExists = false;
        }

    }

    /**
     * @description  metodo per creare le configurazioni di navigazione
     * @param params parametro contenente le informazioni sulla pagina attuale
     */
    @AuraEnabled
    public static void createNavigationConfiguration(Map<String, String> params){
        
        if(params != null){
            integer num = [Select Page_Name__c, Page_Id__c, Dashboard_Name__c, Contains_Dashboard__c from Mobility_Dashboard_Pages__c].size();
            String name = 'MDP'+ ('' + num).leftPad(2,'0');
            if(params.containsKey('dashboardName') && params.containsKey('currentPageName') && params.containsKey('currentPageId')){
                insert new Mobility_Dashboard_Pages__c(Name = name, Dashboard_Name__c = params.get('dashboardName'), Page_Name__c = params.get('currentPageName'), Page_Id__c = params.get('currentPageId'));
            }
        }

    }

    /**
     * @description controlla se il profilo  abilitato
     * @return      `Boolean`
     */
    @AuraEnabled
    public static Boolean isAllowed(){
            return ! ([Select Name from Profile where Id =:UserInfo.getProfileId() WITH SYSTEM_MODE].get(0).Name == 'NFE - AAI - Vendite solo Assistenza');   
    }
    /**
     * @description controlla se il profilo  abilitato per Ecollab sia Singolo che Massivo
     * @return      `Boolean`
     */
    public static Boolean isAllowedEcollab(){
        return mobilitySinglePushController.profileNFEAccess('Profilo_NFE_Abilitati_Invio_Sing_Ecollab').isSuccess;    
    }
    /**
     * @description  recupera dal custom settings le impostazioni di navigazione
     * @param params 
     * @return       `responseWrapper`
     */
    @AuraEnabled
    public static responseWrapper getNavigationConfiguration(Map<String, String> params){
         
        responseWrapper toRet = new responseWrapper();

        if(params != null){
            if(params.containsKey('dashboardName')){
                String dName = params.get('dashboardName');
                Map<String, String> nameToIdMap = new Map<String, String>();
                List<Mobility_Dashboard_Pages__c > configs = [Select Page_Name__c, Page_Id__c, Dashboard_Name__c, Contains_Dashboard__c from Mobility_Dashboard_Pages__c WHERE Dashboard_Name__c =: dName WITH SYSTEM_MODE];
                for(Mobility_Dashboard_Pages__c c : configs){
                    nameToIdMap.put(c.Page_Name__c, c.Page_Id__c);
                }
                
                toRet.currentPageExists = nameToIdMap.containsKey(params.get('currentPageName'));
                toRet.targetPageId = nameToIdMap.get(params.get('targetPageName'));
                
                toRet.ProfileName = [Select Name from Profile where Id =:UserInfo.getProfileId() ].get(0).Name;
            }  
        }

        return toRet;
    }

    /**
     * @description utilizzo nel Ecollab - mobilityEcollabCruscotto
     * @return      `responseWrapper`
     */
    @AuraEnabled
    public static responseWrapper InitRecords(){
        responseWrapper response = new responseWrapper();
        MPS_Code_Utils__mdt ecollab_dashboard = MPS_Code_Utils__mdt.getInstance('PushFase2_Ecollab_DashboardId');
        try {
            List<Target__c> targetScelta = [select id,Name,Dashboard_ID__c,  Descrizione__c from Target__c where Dashboard_ID__c =:ecollab_dashboard.Value__c  and Active__c = true limit 1];

            if(!targetScelta.isEmpty()){
                response.targetScelta = targetScelta[0];
                response.dashboardId = targetScelta[0].Dashboard_ID__c;
            }
            else  {
                response.iniziativaScelta = null;
                response.targetScelta = null;
                response.dashboardId = ecollab_dashboard!=null ? String.valueOf(ecollab_dashboard.Value__c):'Dashboard_ID__c non esiste nella ORG';
            } 
            // response.isAllowedEcollab = isAllowedEcollab(); non interesa al inizio capire se puo vedere o no ecollab
            return response;
        } catch (Exception Ex) {
            ApplicationLogHelper.ERROR('MobilityDashboardUtility.InitRecords', ex.getmessage(), ex.getStackTraceString());
            return response;
        }
    }

    /**
     * @description             in base al CMcode si carica una iniziativa mkt diversa per Ecollab
     * @param communicationCode codice popolato nel parametro della dashboard Ecollab
     * @return                  `responseWrapper`
     */
    @AuraEnabled
    public static responseWrapper InitRecordIniziativaMkt(String communicationCode){
        responseWrapper response = new responseWrapper();
        try {
            List<Iniziative_Marketing__c> iniziativaScelta = [
                    Select id,Name, URL_Immagine__c, URL_CTA__c, Titolo__c, Sottotitolo__c, Short_Message__c,
                    Message__c,TECH_URL_template_MC__c, Testo_CTA__c, Communication_code__c, Versione__c, Eligibile_per_Compagnia__c,
                    Nome_Messaggio__c,Categoria_Prodotto__c,Sottotipologia_Campagna__c,Tipologia_Campagna__c,
                    Contenuto__c,Visibilita_nel_centro_notifiche__c,Invio_push__c,Tipo_notifica_su_Centro_Notifiche__c,  
                    Canale__c, Descrizione_dell_iniziativa__c,Descrizione_Messaggio__c,is_scheduled_type__c,is_closure_type__c,Tipologia_di_iniziative__c   
                    from Iniziative_Marketing__c 
                    where Communication_code__c =:communicationCode and Attiva__c = true WITH SYSTEM_MODE limit 1 
            ];//ZA aggiunto Descrizione_Messaggio__c

            if(!iniziativaScelta.isEmpty()){     
                response.iniziativaScelta = iniziativaScelta[0];
            }else {
                response.iniziativaScelta = null;
            }
            response.isAllowedEcollab = isAllowedEcollab();
            return response;
        } catch (Exception Ex) {
            ApplicationLogHelper.ERROR('MobilityDashboardUtility.InitRecordIniziativaMkt', ex.getmessage(), ex.getStackTraceString());
            return response;
        }
    }
}