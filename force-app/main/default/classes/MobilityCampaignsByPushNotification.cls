/**
 * @description IDCRM078 Push Notification – Fase 2
 * @author      Reply
 * @since       23/06/2023
 */
@SuppressWarnings('PMD.StdCyclomaticComplexity')//complexita del process alta -dinamicFieldsTemplate-
public without sharing class MobilityCampaignsByPushNotification {

    public static final ID standarComRecordTypeId = Schema.SObjectType.Communications_to_customer__c.getRecordTypeInfosByDeveloperName().get('Standard_Communication').getRecordTypeId();
 
    /**
     * @description wrapper class
     */
    public class WrapperRequest  {
        /**
        * @description Account field
         */
        @AuraEnabled 
        public String AccountId{get;set;}
        /**
        * @description Account field
         */
        @AuraEnabled 
        public String ContactId{get;set;}
        /**
        * @description Account field
         */
        @AuraEnabled 
        public String ContactMasterId{get;set;}
        /**
        * @description Account field
         */
        @AuraEnabled 
        public String Name{get;set;}
        /**
        * @description Account field
         */
        @AuraEnabled 
        public String MobileMasterAAI{get;set;}   
        /**
        * @description Account field
         */
        @AuraEnabled 
        public String Telefono{get;set;}   
        /**
        * @description Account field
         */
        @AuraEnabled 
        public String EmailMasterAAI{get;set;} 
        /**
        * @description Account field
         */
        @AuraEnabled 
        public String CIFNumber{get;set;}
        /**
        * @description Account field
         */
        @AuraEnabled 
        public String CIFDocumenttype{get;set;}
        /**
        * @description Account field
         */
        @AuraEnabled 
        public String AgencyHolder{get;set;}
        /**
        * @description Account field
         */
        @AuraEnabled 
        public String AgencyCode{get;set;}
        /**
        * @description Account field
         */
        @AuraEnabled 
        public String AgencyName{get;set;}
        /**
        * @description Account field
         */
        @AuraEnabled 
        public String AgencyEmail{get;set;}
        /**
        * @description Account field
         */
        @AuraEnabled 
        public String AgencyMobilePhone{get;set;}
        /**
        * @description Account field
         */
        @AuraEnabled 
        public String Ccod_Produttore{get;set;}
        /**
        * @description Account field
         */
        @AuraEnabled 
        public String NDG{get;set;}
    }
    /**
     *@description oggetto Apoggio per organizare la info FIRMA 
      NON utilizato perche la firma è stata spostata a MC 
      creata per la posibili gestione del Insert Ctc async
    */
    public class WrapperRequestFirmaAgenzia  {
        public String ruiAgenzia;
        public String registroImprese;
        public String pecAgenzia;
        public String capitalSociale;
        public String NumInsRea;
        public String pivaAgente;
        public String fcodeAgente;

    }
    /**
     * @description
     */
    public class WrapperCambiOrari{
        /**
         * @description
         */
        @AuraEnabled 
        public String validoAl{get;set;}
        /**
         * @description
         */        
        @AuraEnabled 
        public String validoDal{get;set;}
        /**
         * @description
         */  
        public List<MobilityCampaignsByPushNotification.WrapperDay> listDays;
        /**
         * @description 
         * @return      `List<MobilityCampaignsByPushNotification.WrapperDay>`
         */
        public List<MobilityCampaignsByPushNotification.WrapperDay> getlistDays(){
            this.listDays = new List<MobilityCampaignsByPushNotification.WrapperDay>();
            listDays.add(this.lunedi);listDays.add(this.martedi);listDays.add(this.mercoledi);
            listDays.add(this.giovedi);listDays.add(this.venerdi);listDays.add(this.sabato);
            return listDays;
        }
        /**
         * @description
         */   
        @AuraEnabled 
        public WrapperDay lunedi {get;set;}
        /**
         * @description
         */  
        @AuraEnabled 
        public WrapperDay martedi {get;set;}
        /**
         * @description
         */  
        @AuraEnabled 
        public WrapperDay mercoledi {get;set;}
        /**
         * @description
         */  
        @AuraEnabled 
        public WrapperDay giovedi {get;set;}
        /**
         * @description
         */  
        @AuraEnabled 
        public WrapperDay venerdi {get;set;}
        /**
         * @description
         */  
        @AuraEnabled 
        public WrapperDay sabato {get;set;}  

    }
    /**
     * @description
     */
    public class WrapperDay{
        /**
         *  @description
         */
        @AuraEnabled 
        public String dal1{get;set;}
        @AuraEnabled 
        /**
         *  @description
         */
        public String al1{get;set;}
        /**
         *  @description
         */
        @AuraEnabled 
        public String dal2{get;set;}
        /**
         *  @description
         */
        @AuraEnabled 
        public String al2{get;set;}
        /**
         *  @description
         */
        @AuraEnabled 
        public String name{get;set;}
        /**
         *  @description
         */
        @AuraEnabled 
        public Boolean isClosed{get;set;}
    }
    /**
     * @description
     */
    public class WrapperChisura{
        /**
         * @description
         */
        @AuraEnabled 
        public String chiusoDal{get;set;}
        /**
         * @description
         */
        @AuraEnabled 
        public String chiusoAl{get;set;}
    }
    /**
     * @description class wrapper for response all 
     */
    public class WrapperReponse extends MobilityResponse{
        /**
        * @description SuccessMessage field
         */
        @AuraEnabled 
        public String SuccessMessage{get;set;}
        /**
        * @description campaignId field
         */
        @AuraEnabled 
        public String campaignId{get;set;}
        /**
        * @description CommunicationsCreated field
         */
        @AuraEnabled 
        public boolean CommunicationsCreated{get;set;}
        /**
        * @description MessageCommunicationsCreated field
         */
        @AuraEnabled 
        public String MessageCommunicationsCreated{get;set;}
        /**
        * @description iniziativaSelected field
         */
        @AuraEnabled 
        public Iniziative_Marketing__c iniziativaSelected{get;set;}
        /**
        * @description MessagesRimanenti field
         */
        @AuraEnabled 
        public Integer MessagesRimanenti{get;set;}
        /**
        * @description MessagesTotali field
         */
        @AuraEnabled 
        public Integer MessagesTotali{get;set;}
    }
    /**
     * @description CONST
     */
    public MobilityCampaignsByPushNotification() {
    }

    /**
     * @description                   
     * @param campagnaToCreate                    
     * @param tipologiaCampagna       
     * @param SizetotaleClient        
     * @param isSendingCommunications 
     * @param iniziativaId            
     * @return                        `WrapperReponse`
     */
    @AuraEnabled
    public static WrapperReponse createCampaign(Campaign campagnaToCreate,String tipologiaCampagna,Integer SizetotaleClient,
                                                Boolean isSendingCommunications,String iniziativaId){
       
        WrapperReponse response = new WrapperReponse();
        WrapperReponse responseDisponibilitaFromNode = new WrapperReponse();
        try {
        List<Iniziative_Marketing__c> iniziativaSelected = [Select id,Name, URL_Immagine__c, URL_CTA__c, Titolo__c, Sottotitolo__c, Short_Message__c,  //NOPMD system mode on bug
        Message__c, Testo_CTA__c, Communication_code__c, Versione__c, Eligibile_per_Compagnia__c,TECH_URL_template_MC__c, 
        Nome_Messaggio__c,Categoria_Prodotto__c,Sottotipologia_Campagna__c,Tipologia_Campagna__c,
        Contenuto__c,Visibilita_nel_centro_notifiche__c,Invio_push__c,Tipo_notifica_su_Centro_Notifiche__c,  
        Canale__c,TAG__c, Descrizione_dell_iniziativa__c,is_scheduled_type__c,is_closure_type__c,Tipologia_di_iniziative__c   
        from Iniziative_Marketing__c 
        where id =:iniziativaId WITH SYSTEM_MODE limit 1 ];
       

        if(isSendingCommunications){
            responseDisponibilitaFromNode = getDisponibilitaFromNode(SizetotaleClient);// true PRENOTA messagi subito
            //se include invio pero non ho disponibilita return NON puoi creare la CAMPGNA
            if(!responseDisponibilitaFromNode.isSuccess){
                response.isSuccess = false ;
                response.errorMessage = responseDisponibilitaFromNode.errorMessage;
                response.campaignId = null;
                return response;
            }
        }
        String responseDB = null;
        //include invio o no cmq si crea la campgna
        if (!iniziativaSelected.isEmpty()) {
            response.iniziativaSelected = iniziativaSelected[0];
            responseDB = insertCampaign(campagnaToCreate,tipologiaCampagna,iniziativaSelected[0]);
        }else{
            responseDB = insertCampaign(campagnaToCreate,tipologiaCampagna,null);
        } 
        if(responseDB != null){
            response.isSuccess = true;
            response.SuccessMessage = 'OK01 - Campagna' ;
            response.campaignId = responseDB;
        }else{
            response.isSuccess = false;
            response.errorMessage = 'E001 - Campaign in Errore - insertCampaign CRM' ;
            response.campaignId = null;
        }
        } catch (Exception ex ) {
            ApplicationLogHelper.ERROR('MobilityCampaignsByPushNotification.createCampaign', ex.getmessage(), ex.getStackTraceString());
            response.isSuccess = false;
            response.errorMessage = 'E001 - Campaign in Errore - Verifica AppLOG MobilityCampaignsByPushNotification.createCampaign' ;
            response.campaignId = null;
        }

        return response;
    }
    /**
     * @description             
     * @param campagna              
     * @param tipologiaCampagna 
     * @param iniziativa      
     * @return                  `String`
     */
    private static String insertCampaign(Campaign campagna,String tipologiaCampagna,Iniziative_Marketing__c iniziativa){
 
        try { 
                List<Lista_Campagne_NFE_filtro__mdt> mcs = Lista_Campagne_NFE_filtro__mdt.getAll().values();
                Map<String,String> recordtypeCampaingByIniziativa = new Map<String,String>();
                String statusInizialeCampagnaMTD ;
                for(Lista_Campagne_NFE_filtro__mdt mtdTemp: mcs){
                    recordtypeCampaingByIniziativa.put(mtdTemp.Label__c, mtdTemp.RecordType_DeveloperName__c);
                    statusInizialeCampagnaMTD = String.isNotBlank(mtdTemp.Status_di_creazione__c) ? mtdTemp.Status_di_creazione__c:'Planned';
                }
                /*//blindare le creazioni delle campagne da Agente sempre con record type “Marketing Campaign” e tipologia campagna “Commerciale”.
                //FW: [Customer Physitization - Push 2023] - SAL -- mail di giovanni modif temporanea
                campagna.Tipologia_Campagna__c = 'Commerciale';//mail di giovanni modif temporanea
                tipologiaCampagna = 'Commerciale';//mail di giovanni modif temporanea*/
                campagna.Tipologia_Campagna__c = tipologiaCampagna;

                String recordtypeCampaign = recordtypeCampaingByIniziativa.get(tipologiaCampagna);
                String recordtypeCampaignRecordTypeID = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get(recordtypeCampaign).getRecordTypeId();
                //verificare il RT

                Campaign campaignToCreate = insertCampaignSingle(campagna,iniziativa, statusInizialeCampagnaMTD ,System.UserInfo.getUserId(),recordtypeCampaignRecordTypeID,recordtypeCampaign);

                if(campaignToCreate.id != null){
                    return campaignToCreate.id;
                }
                return null;

            } catch (Exception ex ) {
                ApplicationLogHelper.ERROR('MobilityCampaignsByPushNotification.insertCampaign', ex.getmessage(), ex.getStackTraceString());
                return null ;
            }
    }
    /**
     * @description         
     * @param campagna      
     * @param iniziativa    
     * @param status        
     * @param createdBy     
     * @param recordType    
     * @param developerName 
     * @return              `Campaign`
     */
    private static Campaign insertCampaignSingle(Campaign campagna,Iniziative_Marketing__c iniziativa,String status,Id createdBy,Id recordType,String developerName){

        list<CampaignMembStatus__c> csList = new list<CampaignMembStatus__c>(); //custom settings table
        csList = CampaignMembStatus__c.getAll().Values(); //get all values from the table
        Date dataInizio = String.isBlank(String.valueOf(campagna.StartDate))? System.now().date():campagna.StartDate;//fissa a today se non arriva da nFE
        String tagCampagna = '';
        //ZA CR PUSH
        String agencyCode = '';
        string agdirif='';
        String UserId = UserInfo.GetUserId();
        User currentUser = [SELECT id, Agency_code__c,  Username FROM User WHERE Id=:UserId Limit 1];
        if(currentUser.Agency_code__c!= null && currentUser.Agency_code__c!= '') {
            agencyCode = currentUser.Agency_code__c;
         Node__c node= [SELECT id,Email__c,  Node_unique_code__c FROM Node__c WHERE  Node_unique_code__c LIKE :agencyCode];
         agdirif =node.Email__c;  
        }
        if(iniziativa!= null)
            tagCampagna = String.isNotBlank(iniziativa.TAG__c) ? iniziativa.TAG__c : '' ;

        Campaign toInsert = new  Campaign (
            Name = tagCampagna + campagna.name ,
            Description = campagna.Description,
            Agenzia_di_riferimento__c=agdirif,
            Status = status,
            StartDate = dataInizio,
            EndDate = campagna.EndDate,
            RecordTypeId = recordType,
            Campagna_creata_da_Direzione_Agente__c = true,
            ownerid = createdBy,
            Tipologia_Campagna__c = campagna.Tipologia_Campagna__c,
            Sotto_tipologia_campagna__c = campagna.Sotto_tipologia_campagna__c
            //Target__c = campagna.Target__c
        );
        //ZA CR PUSH
        //modifica in prod dell campo target da 255 a 31500
        String fieldTarg = 'Target__c';
        toInsert.put(fieldTarg,campagna.get(fieldTarg));

        if(iniziativa!=null){
            toInsert.Iniziative_Marketing__c = iniziativa.Id;
            if(iniziativa.Canale__c=='Email + Push'){
                toInsert.Canale__c = 'Email;Push';
            }
            else {
                toInsert.Canale__c = iniziativa.Canale__c;
            }
            //toInsert.Tipologia_Campagna__c =iniziativa.Tipologia_Campagna__c;
            if(String.isNotBlank(iniziativa.Sottotipologia_Campagna__c))
            toInsert.Sotto_tipologia_campagna__c = iniziativa.Sottotipologia_Campagna__c;
            toInsert.Categoria_Prodotto__c = iniziativa.Categoria_Prodotto__c;
            toInsert.Nome_Messaggio__c=  iniziativa.Nome_Messaggio__c;
        }

        //CampaignHandler.DeactivateTrigger = true;// spegnere i trigger per CPU time limit
        Database.insert(toInsert,AccessLevel.SYSTEM_MODE); //NOPMD system mode on bug

        return toInsert;
    }
    /**
     * @description                   
     * @param request                 
     * @param campaignId              
     * @param isSendingCommunications 
     * @param iniziativa              
     * @param requestCambiOrari       
     * @param requestChiusura         
     * @return                        `WrapperReponse`
     */
    @AuraEnabled
    public static WrapperReponse createCampaignMembers(List<WrapperRequest> request,String campaignId,Boolean isSendingCommunications,
        Iniziative_Marketing__c iniziativa,WrapperCambiOrari requestCambiOrari,WrapperChisura requestChiusura){

        WrapperReponse response = new WrapperReponse();
        WrapperReponse responseCommunicationsDB = new WrapperReponse();
        Map<String,String> campaignMembersIdByAcc = new  Map<String,String> ();
        BlockCountersFromNode();

        try {
        campaignMembersIdByAcc = insertCampaignMembers(request, CampaignId,isSendingCommunications);//ZA CR PUSH Maggio

        if(String.isNotBlank(campaignId) && !request.isEmpty()){
            if(campaignMembersIdByAcc != null && !campaignMembersIdByAcc.keySet().isEmpty()){
                response.isSuccess = true ;
                response.SuccessMessage = 'OK02 - Campaign Members - '+request.size()+'' ;
            }
            else {
                response.isSuccess = false;
                response.errorMessage = 'E02 - Campaign Members in Errore - Verifica AppLOG-MobilityCampaignsByPushNotification.insertCampaignMembers';
                return response;
            }
        }
        else {
            response.isSuccess = false;
            response.errorMessage = 'E01 - Lista clienti o Campagna ID non popolati dal JS';
            return response;
        }
        if(isSendingCommunications && String.isNotBlank(campaignId) && !request.isEmpty()){
            if(iniziativa.id != null){
                responseCommunicationsDB = insertNotificationsOnComunicationsToCustomer(request,campaignId, iniziativa,requestChiusura,requestCambiOrari);
                response.CommunicationsCreated = responseCommunicationsDB.isSuccess;
                response.MessageCommunicationsCreated = responseCommunicationsDB.MessageCommunicationsCreated;
            }
            else {
                response.CommunicationsCreated = false;
                response.MessageCommunicationsCreated = 'E03 - Iniziativa MKT non popolata dal JS';
            }
        }
        } catch (Exception ex ) {
            ApplicationLogHelper.ERROR('MobilityCampaignsByPushNotification.createCampaignMembers', ex.getmessage(), ex.getStackTraceString());
            response.isSuccess = false;
            response.errorMessage = 'E02 - Campaign Members in Errore - Verifica AppLOG-MobilityCampaignsByPushNotification.insertCampaignMembers';
            return response;
        }

        return response;
    }
    /**
     * @description              
     * @param requestInfoClients 
     * @param CampaignId         
     * @return                   `Map<String,String>`
     */
    private static  Map<String,String> insertCampaignMembers(List<WrapperRequest> requestInfoClients,String  CampaignId, boolean comm){//ZA CR PUSH Maggio
        /*ZA CR PUSH Maggio start*/
        String sottostato = '';
        if(comm)
           sottostato='Inviata Email'; 
         /*ZA CR PUSH Maggio end*/
        List<CampaignMember> ListCampaignMembersToInsert = new List<CampaignMember> ();
        Map<String,String> campaignMembersIdByAcc = new  Map<String,String> ();
        try { 
            for (WrapperRequest client_pivot : requestInfoClients) {
                CampaignMember temp = new CampaignMember(
                    CampaignId = CampaignId,
                    ContactId =  client_pivot.ContactId, 
                    Status = 'Da assegnare',
                    Sottostato__c=sottostato, //ZA CR PUSH Maggio
                    NeedAsyncBatchExecution__c=true, // il batch BatchRunCampaignMember deve prendere questa campgna
                    Stato_Adesione__c = 'Incluso'//il processo svalidazione deve funzionare anche
                );
                ListCampaignMembersToInsert.add(temp);
            }
            //CampaignMemberHandler.DeactivateTrigger = true;

            Database.insert(ListCampaignMembersToInsert,true,AccessLevel.SYSTEM_MODE); //NOPMD SYSTEM_MODE mode on bug

        } catch (Exception ex ) {
            ApplicationLogHelper.ERROR('MobilityCampaignsByPushNotification.insertCampaignMembers', ex.getmessage(), ex.getStackTraceString());
            return null ;
        }

        for(CampaignMember insertedCM :ListCampaignMembersToInsert){
            campaignMembersIdByAcc.put(insertedCM.ContactId, insertedCM.id);
        }

        return campaignMembersIdByAcc;
    }
    /**
     * @description             
     * @param request           
     * @param campaignId        
     * @param iniziativa        
     * @param requestChiusura   
     * @param requestCambiOrari 
     * @return                  `WrapperReponse`
     */
    private static WrapperReponse insertNotificationsOnComunicationsToCustomer( List<WrapperRequest> request,String campaignId,Iniziative_Marketing__c iniziativa,
        WrapperChisura requestChiusura  ,WrapperCambiOrari requestCambiOrari  ){

        List <Communications_to_customer__c> comunicationsToInsert = new List <Communications_to_customer__c> ();
        WrapperReponse response = new WrapperReponse();

        for (WrapperRequest request_pivot : request) {
            comunicationsToInsert.add(createComunicationToCustomerSingle(false,request_pivot, campaignId,iniziativa,requestChiusura,requestCambiOrari));
        }
        Map<String,boolean> AgencyOrSubagency = Agenzia_OR_Subagenzia(request);
        for (Communications_to_customer__c comm_pivot : comunicationsToInsert) {
            if(AgencyOrSubagency.containsKey(comm_pivot.AccountId__c)){
                comm_pivot.TECH_invio_da_Agenzia_Sottonodo__c = AgencyOrSubagency.get(comm_pivot.AccountId__c);
            }
        }
        
        CommunicationToCustomerHandler.DeactivateTrigger=true;
        
        Database.SaveResult[] srList =  Database.insert(comunicationsToInsert);
        Integer comunicationsOK = 0, comunicationsKO=0;
        String errorsAdds ='';
        for ( Database.SaveResult  srtemp : srList) {
            if (srtemp.isSuccess()) {
                comunicationsOK++;
            }else {
                comunicationsKO++;
                errorsAdds =+ String.valueOf(srtemp.getErrors())+ '\n';
                break;
            }
        }
        if(srList.size()==comunicationsOK && !srList.isEmpty() ){
            response.isSuccess=true;
            response.MessageCommunicationsCreated='OK06 - Comunicazioni create -'+srList.size();
        }else if(comunicationsKO==srList.size()){
            response.isSuccess=false;
            response.MessageCommunicationsCreated='E062 - Tutte Comunicazioni al clienti in errori -'+comunicationsKO +' Verifica AppLOG';
            ApplicationLogHelper.ERROR('insertNotificationsOnComunicationsToCustomer','E062',errorsAdds); 
        }else {
            response.isSuccess=false;
            response.MessageCommunicationsCreated='E061 - Comunicazioni al clienti in errori -'+comunicationsKO +' Verifica AppLOG';
            ApplicationLogHelper.ERROR('insertNotificationsOnComunicationsToCustomer','E061', errorsAdds);
        }

        return response;
    }
    /**
     * @description             crea e modifica una comunicazione singola, NON DataBase DML
     * @param singleInsert      se true, va utilizato in Invio Singolo, senza campgna. diretamente della scheda cliente
     * @param accountInfo       Account
     * @param campaignId        se popolato, lo scrive dentro la comunication
     * @param iniziativa        iniziativa Mkt scelta 
     * @param requestChiusura   se popolato la iniziativa e di chiusura
     * @param requestCambiOrari se popolato la iniziativa e di cambio Orario 
     * @return                  `Communications_to_customer__c`
     */
    public static Communications_to_customer__c createComunicationToCustomerSingle(boolean singleInsert,WrapperRequest accountInfo,String campaignId,Iniziative_Marketing__c  iniziativa,
        WrapperChisura requestChiusura, WrapperCambiOrari requestCambiOrari) {

        Communications_to_customer__c communication = new Communications_to_customer__c();  
        editCommunicationsByIniziativaFields(singleInsert,campaignId, iniziativa, communication, accountInfo,requestChiusura,requestCambiOrari);

        return communication ;
    }
    /**
     * @description            metodo per capire se ci sono ancora messagi diponibili nel NODE
     * @param SizetotaleClient totale da prenotare/capire se ci sono suficienti
     * @return                 `WrapperReponse` true se si puo mandare tutti
     */
    @AuraEnabled
    public static WrapperReponse getDisponibilitaFromNode(Integer SizetotaleClient){
        WrapperReponse response = new WrapperReponse();
        List<User> userNFE = [Select id,Name,ProfileId, Agency_Code__c,Main_Node__c from user where id =:System.UserInfo.getUserId() WITH SYSTEM_MODE limit 1]; //NOPMD system mode on bug
        if (!userNFE.isEmpty() && userNFE[0].Agency_Code__c != null) {
            Node__c AgencyNode = [Select id,superMessagesPrenotati__c, superMessagesRimanenti__c, superMessagesTotali__c, superMessagesUtilizzati__c //NOPMD
            from Node__c 
            where Node_unique_code__c =:userNFE[0].Agency_Code__c WITH SYSTEM_MODE limit 1]; 

            if(String.isNotBlank(String.valueOf(AgencyNode.superMessagesTotali__c)) && String.isNotBlank(String.valueOf(AgencyNode.superMessagesRimanenti__c)) ){
                if(SizetotaleClient <= AgencyNode.superMessagesRimanenti__c){
                    response.isSuccess=true;
                    response.MessagesRimanenti = Integer.valueOf(AgencyNode.superMessagesRimanenti__c);
                    response.SuccessMessage='OK03 - Messaggi utilizzati '+SizetotaleClient;
                }
                else {
                    response.isSuccess=false;
                    response.MessagesRimanenti = Integer.valueOf(AgencyNode.superMessagesRimanenti__c);
                    response.errorMessage='E04 - Messaggi NON disponibili NODO-'+userNFE[0].Agency_Code__c +' per invio di '+SizetotaleClient+' messagi';
                }
            }
            else{
                response.isSuccess=false;
                response.MessagesRimanenti = null;
                response.errorMessage='E041 - No.Messaggi NON popolata NODO-'+userNFE[0].Agency_Code__c;
            }
        } else {
            response.isSuccess=false;
            response.MessagesRimanenti = null;
            response.errorMessage='E05 - Agency Code NON popolata nel USER - '+System.UserInfo.getUserId();
        }

        return response;
    }
    /**
     * @description per prendere tutti contatori nel Node
     * @return      `WrapperReponse`
     */
    @AuraEnabled
    public static WrapperReponse getMessageStatusFromNode (){
        WrapperReponse response = new WrapperReponse();
        List<Node__c> AgencyNode = new List<Node__c> ();
        List<User> userNFE = [Select id,Name,ProfileId, Agency_Code__c,Main_Node__c from user where id =:System.UserInfo.getUserId() WITH SYSTEM_MODE limit 1]; //NOPMD system mode on bug
       
        try {
 
        if (!userNFE.isEmpty() && userNFE[0].Agency_Code__c != null) {
           AgencyNode = [Select id,superMessagesPrenotati__c, superMessagesRimanenti__c, superMessagesTotali__c, superMessagesUtilizzati__c //NOPMD
            from Node__c 
            where Node_unique_code__c =:userNFE[0].Agency_Code__c WITH SYSTEM_MODE limit 1]; 
        }
        if(!AgencyNode.isEmpty()){
            response.isSuccess = true;
            response.MessagesTotali = Integer.valueOf(AgencyNode[0].superMessagesTotali__c);
            response.MessagesRimanenti = Integer.valueOf(AgencyNode[0].superMessagesRimanenti__c);
        }else {
            response.isSuccess = false;
            response.MessagesTotali = null;
            response.MessagesRimanenti = null;
            response.errorMessage = 'E051 - Agency Non trovato per - Agency CODE'+userNFE[0].Agency_Code__c;
        }
        } catch (Exception ex) {
            ApplicationLogHelper.ERROR('MobilityCampaignsByPushNotification.getMessageStatusFromNode', ex.getmessage(), ex.getStackTraceString());
            response.isSuccess = false;
            response.MessagesTotali = null;
            response.MessagesRimanenti = null;
            response.errorMessage = 'E080 - Errore Tecnico. Verifica AppLOG'+'-MobilityCampaignsByPushNotification.getMessageStatusFromNode';
        }
        return response;
    }
    /**
     * @description            Prenotare messagi dopo la creazione dei messagi, per aggiornare il NODE prenotati
     * @param SizeCommunicationsInOK totali gia prenotati, quindi comunications in CREATED
     * @return                 `boolean` true se prenota nel NODE
     */
    private static boolean setCountersFromNode(Integer SizeCommunicationsInOK ){
        try {  
                List<User> userNFE = [Select id,Name,ProfileId, Agency_Code__c,Main_Node__c from user where id =:System.UserInfo.getUserId() WITH SYSTEM_MODE limit 1]; //NOPMD system mode on bug
                if (!userNFE.isEmpty() && userNFE[0].Agency_Code__c != null) {
                    List<Node__c> NodoAgenzia = [Select id,superMessagesPrenotati__c from node__c //NOPMD system mode on bug
                    where Node_unique_code__c =:userNFE[0].Agency_Code__c WITH SYSTEM_MODE limit 1 FOR UPDATE]; 

                    if (!NodoAgenzia.isEmpty()) {
                        NodoAgenzia[0].superMessagesPrenotati__c += SizeCommunicationsInOK;
                        NodeHandler.setDeactivateTrigger(true);
                        Database.SaveResult[] saveResult = Database.update(NodoAgenzia,false,AccessLevel.SYSTEM_MODE);
                        if(saveResult[0].isSuccess()){
                            return true;
                        }
                    }
                }else {
                    return false;
                }    
                    return false;
            } catch (Exception ex ) {
                ApplicationLogHelper.ERROR('MobilityCampaignsByPushNotification.setCountersFromNode', ex.getmessage(), ex.getStackTraceString());
                return false ;
            }
    }
    /**
     * @description blocco del nodo con FOR UPDATE x controllare il paralelismo di scrittura ssu node
     * @return      `boolean` sempre OK solo se trova il NODE
     */
    private static boolean BlockCountersFromNode(){
        try {   
            List<User> userNFE = [Select id,Name,ProfileId, Agency_Code__c,Main_Node__c from user where id =:System.UserInfo.getUserId() WITH SYSTEM_MODE limit 1]; //NOPMD system mode on bug
            if (!userNFE.isEmpty() && userNFE[0].Agency_Code__c != null) {
                List<Node__c> NodoAgenzia = [Select id,superMessagesPrenotati__c from node__c  //NOPMD system mode on bug
                where Node_unique_code__c =:userNFE[0].Agency_Code__c  WITH SYSTEM_MODE limit 1 FOR UPDATE]; 
                if (!NodoAgenzia.isEmpty()) {
                        return true;
                }
            }  
            return false;
            } catch (Exception ex ) {
                ApplicationLogHelper.ERROR('MobilityCampaignsByPushNotification.BlockCountersFromNode', ex.getmessage(), ex.getStackTraceString());
                return false ;
            }
    }
    /**
     * @description                 update finale che aggiorna la campgna a on goin per aggiornare tutti comunitcat in ready         
     * @param campaignId           campgna in lavorazione x agente per IDCRM078 Push Notification – Fase 2          
     * @param isSendingCommunicationsAndPush 
     * @param isSendingCommunications        
     * @param SizetotaleClient 
     * @param nodes               
     * @return                               `WrapperReponse`
     */
    @AuraEnabled
    public static WrapperReponse updateCampagnaFinale(String campaignId,boolean isSendingCommunicationsAndPush,Boolean isSendingCommunications ,Integer SizetotaleClient, String nodes){
        
        Integer prenotatiReali = 0;Boolean prenotatiSuNode = false;
        WrapperReponse response = new WrapperReponse();
        try {
        Campaign campagnaToUpdate = [select id,status from Campaign where id=:campaignId  WITH SYSTEM_MODE ]; //NOPMD system mode on bug
        campagnaToUpdate.status = 'On-going';
        campagnaToUpdate.IsActive = true;
        campagnaToUpdate.Agencies_in_Target__c = nodes;

        if(isSendingCommunications && isSendingCommunicationsAndPush){
            prenotatiReali = SizetotaleClient*2; // conteggarie x 2 le comunicazioni 
            prenotatiSuNode = setCountersFromNode(prenotatiReali);
        }else 
        if(isSendingCommunications && !isSendingCommunicationsAndPush){
            prenotatiReali = SizetotaleClient*1; //contegiare x 1 la comunicazione senza push, solo mail 
            prenotatiSuNode = setCountersFromNode(prenotatiReali);
        }
        WrapperReponse responseDisp = getMessageStatusFromNode();
        Integer disposizioneNode = responseDisp.MessagesRimanenti;
        campagnaToUpdate.Messaggi_disposizione__c = disposizioneNode;
        campagnaToUpdate.Messaggi_spesi__c = prenotatiReali;
        campagnaToUpdate.Stato_Assegnazione_membri_campagna__c =  'Da Lavorare';// per far partire il batch PRE asegna
        
        Database.SaveResult saveResultUpdate = Database.update(campagnaToUpdate);

        //Aggiornare  tutte comunicazioni  to READY
        if(saveResultUpdate.isSuccess() && isSendingCommunications && prenotatiSuNode){
            QueueableUpdateCommunicationsOnCampaign QueueableJob = new QueueableUpdateCommunicationsOnCampaign(campaignId);
            System.enqueueJob(QueueableJob);
        }
        else{
            //ritornare un errore generico e provare a prenotare piu tardi forse ? verificare con Nino
        }  

        return response;
        } catch (Exception ex ) {
            ApplicationLogHelper.ERROR('MobilityCampaignsByPushNotification.updateCampagnaFinale', ex.getmessage()+' campagna-'+campaignId, ex.getStackTraceString());
            return response;
        }
    }
    /**
     * @description IDCRM078 Push Notification – Fase 2. Classe per Aggiornamento del CTCustomers records 
     * in status 'created', finche non si aggiorna la campagna e finisce il flusso non si mandano le ctcustomers
     * @author      Reply
     * @since       08/07/2023
     */
    public class QueueableUpdateCommunicationsOnCampaign  implements Queueable{
        private string query;
        private Integer scopeLimitTech;
        private String limite;
        private boolean needInfoLogWrite ;
        private String CampaignId_input;
        private boolean is_Testing_only;
        private boolean isUpdateTechBatch;
        private Datetime dateLastRun;

        /**
         * @description      
         * @param campaignId 
         */
        public QueueableUpdateCommunicationsOnCampaign(String campaignId){

            BatchSetting__mdt batchSettings = [select DeveloperName,IsAutoSchedulable__c,MinutesRange__c,
            ScopeSize__c,Query__c,Need_Information_Log__c,is_Testing_only__c 
            from BatchSetting__mdt
            where DeveloperName = 'Queueable_UpdateCommunicationsOnCampaign'];

            this.query = batchSettings.Query__c + ' AND Campaign__c =\''+campaignId+'\'' ;
            this.limite =' limit '+ Integer.valueOf(batchSettings.ScopeSize__c) ;
            this.needInfoLogWrite = batchSettings.Need_Information_Log__c ;
            this.CampaignId_input=campaignId;
            this.is_Testing_only = batchSettings.is_Testing_only__c;
            this.isUpdateTechBatch = false;

        }
        /**
         * @description  
         * @param query  
         * @param limite 
         */
        public QueueableUpdateCommunicationsOnCampaign(String query,String limite){
            this.query = query ;
            this.limite = ' limit '+ limite;
            this.scopeLimitTech = Integer.valueOf(limite);
            this.needInfoLogWrite = false ;
            this.CampaignId_input=null;
            this.is_Testing_only = false;
            this.isUpdateTechBatch = true;
        }
        /**
         * @description   
         * @param queCont 
         */
        public void execute(QueueableContext queCont) {
            
            List<Communications_to_customer__c> listToUpdate = Database.query(query+limite);

            for(Communications_to_customer__c comToCustomer_pivot: listToUpdate){
                if(!isUpdateTechBatch){
                    comToCustomer_pivot.Status__c = 'Ready';
                }else{
                    comToCustomer_pivot.TECH_NeedBatchUpdateSuperMessage__c = false;
                }
            }
            CommunicationToCustomerHandler.DeactivateTrigger = false;
            if(!this.is_Testing_only){
                Database.update(listToUpdate, true);
            }else {
                ApplicationLogHelper.INFO('MobilityCampaignsByPushNotification.updateCampagnaFinale','TESTING MODE', 'BatchSetting__mdt Queueable_UpdateCommunicationsOnCampaign is_Testing_only=true');
            }


            List<Communications_to_customer__c> listToUpdateNextQueueable = Database.query(query+limite);
            
            if(!Test.isRunningTest() && !listToUpdateNextQueueable.isEmpty()&& !this.is_Testing_only){
                if(!isUpdateTechBatch){
                    QueueableUpdateCommunicationsOnCampaign QueueableJob = new QueueableUpdateCommunicationsOnCampaign(CampaignId_input);
                    System.enqueueJob(QueueableJob);
                }else {
                    QueueableUpdateCommunicationsOnCampaign QueueableJob = new QueueableUpdateCommunicationsOnCampaign(this.query,String.valueOf(this.scopeLimitTech));
                    System.enqueueJob(QueueableJob);   
                }

            }
        }
    }
    /**
     * @description IDCRM078 Push Notification – Fase 2. Classe NON UTILIZZATA. 
     * creata per la posibile gestione asincrona del INSERT di list di communicationsToCustomer 
     * @author      Reply
     * @since       23/06/2023
     * @deprecated  23/06/2023 lasciata solo in caso di futuro utilizzo 
     */
    public class QueueableInsertCommunicationsFromCampaignMembers  implements Queueable{

        private string query;
        private String limite;
        private boolean needInfoLogWrite ;
        private String CampaignId_input;
        private String codiceAgenzia;
        private String communicationCode;
        private WrapperRequestFirmaAgenzia firma;
        private Integer numberOfContacts;
        /**
         * @description      
         * @param campaignId 
         * @exception        
         */
        public QueueableInsertCommunicationsFromCampaignMembers (String campaignId){

            try {
                
            BatchSetting__mdt batchSettings = [select DeveloperName,IsAutoSchedulable__c,MinutesRange__c,
            ScopeSize__c,Query__c,Need_Information_Log__c 
            from BatchSetting__mdt
            where DeveloperName = 'Queueable_InsertComm_CampaignMembers'];

            this.codiceAgenzia='';this.communicationCode='';
            this.firma = new WrapperRequestFirmaAgenzia();

            list<Campaign> campagnaToCreateCom = [select id,NumberOfContacts,Iniziative_Marketing__r.Communication_code__c, Codice_agenzia__c from Campaign where id =:campaignId];
            
            if(!campagnaToCreateCom.isEmpty()){
                this.codiceAgenzia = campagnaToCreateCom[0].Codice_agenzia__c;
                this.communicationCode = campagnaToCreateCom[0].Iniziative_Marketing__r.Communication_code__c;
                this.numberOfContacts = campagnaToCreateCom[0].numberOfContacts;
            }else {
                //non essite la campagna?
            }

            if(String.isNotBlank(codiceAgenzia)){
                List<Node__c> AgenziaFirma = [select id, Mail_PEC_Agenzia__c,RUI_Agenzia__c,Capitale_Sociale__c,Registro_delle_Imprese__c,Numero_Iscrizione_REA__c,Codice_Fiscale_Agente__c,P_IVA_Agente__c 
                    from Node__c where Node_unique_code__c  =:codiceAgenzia];
                if(!AgenziaFirma.isEmpty()){
                    this.firma.pecAgenzia=AgenziaFirma[0].Mail_PEC_Agenzia__c;
                    this.firma.registroImprese = AgenziaFirma[0].Registro_delle_Imprese__c;
                    this.firma.ruiAgenzia = AgenziaFirma[0].RUI_Agenzia__c ;
                    this.firma.fcodeAgente = AgenziaFirma[0].Codice_Fiscale_Agente__c ;
                    this.firma.pivaAgente = AgenziaFirma[0].P_IVA_Agente__c ;
                    this.firma.NumInsRea = AgenziaFirma[0].Numero_Iscrizione_REA__c ;
                    this.firma.capitalSociale = AgenziaFirma[0].Capitale_Sociale__c ;
                }else {
                    throw new DmlException('E051 - Agency Non trovato per -'+codiceAgenzia);
                }
            }

            this.query = batchSettings.Query__c + ' AND CampaignId =\''+campaignId+'\'' ;
            this.limite =' limit '+ batchSettings.ScopeSize__c ;
            this.needInfoLogWrite = batchSettings.Need_Information_Log__c ;
            this.CampaignId_input=campaignId;

            } catch (Exception ex ) {
                ApplicationLogHelper.ERROR('QueueableInsertCommunicationsFromCampaignMembers', ex.getmessage(), ex.getStackTraceString());
            }
        }
        /**
         * @description   
         * @param queCont 
         */
        public void execute(QueueableContext queCont) {

        try{
            
            List<CampaignMember> listCMToCreateCommunications = Database.Query(query+limite);
            List<Communications_to_customer__c> listCommToInsert = new List<Communications_to_customer__c>();

            if(!listCMToCreateCommunications.isEmpty()){
                for(CampaignMember cm_pivot: listCMToCreateCommunications){
                    cm_pivot.status='Da Assegnare';
                }
                Database.insert(listCommToInsert);

                Database.update(listCMToCreateCommunications);
     
                String queryToCommunicationsInserted = 'select count() from Communications_to_customer__c where Campaign__c =\''+this.CampaignId_input +'\'' ;
                Integer totaleInserted = Database.countQuery(queryToCommunicationsInserted, AccessLevel.SYSTEM_MODE);
                
                if(!Test.isRunningTest() && (this.numberOfContacts != totaleInserted)){
                    QueueableInsertCommunicationsFromCampaignMembers QueueableJob = new QueueableInsertCommunicationsFromCampaignMembers(CampaignId_input);
                    System.enqueueJob(QueueableJob);
                }
            }else {
                if(needInfoLogWrite){
                    ApplicationLogHelper.INFO('QueueableInsertCommunicationsFromCampaignMembers', 'QueueableInsertCommunicationsFromCampaignMembers finish at: '+System.now(), 
                    'Relativo a campagna - '+ this.CampaignId_input);
                } 
            }
        } catch (Exception ex ) {
            ApplicationLogHelper.ERROR('QueueableInsertCommunicationsFromCampaignMembers.execute', ex.getmessage(), ex.getStackTraceString());
        }

        }
    }
    /**
     * @description  metodo per popolare la ctcustomer con dati della iniziativa mkt, il trigger è troppo lento per fare il 
     * lavoro di trovare la iniziativa per il CODE.            
     * @param singleInsert    il metodo si utilizza per due processi, questo è il parametro che le diferenza   
     * @param campaignId      non utilizato se la ctcustm(CTC) è singola   
     * @param iniMarketingTemp   record template con dati da leggere e popolare nell record CTC
     * @param communicationTemp  CTC
     * @param accForNotification Account con dati , wrapper perche utilizato tanto di LWC come d APEX
     * @param requestChiusura description
     * @param requestCambiOrari description
     */
    public static void editCommunicationsByIniziativaFields(boolean singleInsert,String campaignId, Iniziative_Marketing__c iniMarketingTemp,Communications_to_customer__c communicationTemp,WrapperRequest accForNotification,
    WrapperChisura requestChiusura, WrapperCambiOrari requestCambiOrari){

        WrapperInfoDinamicIniziativaMkt utilityDinamicFields= new WrapperInfoDinamicIniziativaMkt(accForNotification,requestChiusura,requestCambiOrari);

        communicationTemp.Titolo__c = utilityDinamicFields.dinamicFieldsTemplate(iniMarketingTemp.Titolo__c);
        communicationTemp.Sottotitolo__c = utilityDinamicFields.dinamicFieldsTemplate(iniMarketingTemp.Sottotitolo__c);
        communicationTemp.Message_Push_Notification__c = utilityDinamicFields.dinamicFieldsTemplate(iniMarketingTemp.Contenuto__c);
        communicationTemp.Short_Message__c = utilityDinamicFields.dinamicFieldsTemplate(iniMarketingTemp.Short_Message__c);                 
        communicationTemp.Message__c = utilityDinamicFields.dinamicFieldsTemplate(iniMarketingTemp.Message__c);                 
        
        //campo obligatorio
        //accForNotification.NDG__c
        //Insurance_Contract_Number__c

        communicationTemp.AccountId__c = accForNotification.AccountId;
        communicationTemp.NDG__c = accForNotification.NDG;

        communicationTemp.Contact__c = accForNotification.ContactId;
        communicationTemp.Contact_Master_Id__c = accForNotification.ContactMasterId;
        
        
        communicationTemp.Email__c = accForNotification.EmailMasterAAI;
        communicationTemp.Mobile_Phone__c = String.isNotBlank(accForNotification.MobileMasterAAI)?accForNotification.MobileMasterAAI:accForNotification.Telefono;
        communicationTemp.Agency_Code__c = accForNotification.AgencyCode;
        communicationTemp.AgencyEmail__c= accForNotification.AgencyEmail;
        communicationTemp.Process__c = 'AGENTE';
        communicationTemp.Caller__c = 'CRM';
        communicationTemp.RecordTypeId = standarComRecordTypeId;
        //single insert modf
        if(!singleInsert)
            communicationTemp.Campaign__c = campaignId;
        communicationTemp.status__c = singleInsert ? 'Ready':'Created';
        //iniziativa campi fissi
        communicationTemp.Iniziativa_Marketing_Id__c = iniMarketingTemp.id ;
        communicationTemp.Communication_Code__c = iniMarketingTemp.Communication_Code__c;
        communicationTemp.Testo_CTA__c = iniMarketingTemp.Testo_CTA__c;
        communicationTemp.URL_CTA__c = iniMarketingTemp.URL_CTA__c;
        communicationTemp.URL_Immagine__c = iniMarketingTemp.URL_Immagine__c;
        communicationTemp.Visibilita_nel_centro_notifiche__c = iniMarketingTemp.Visibilita_nel_centro_notifiche__c;
        communicationTemp.Invio_push__c = iniMarketingTemp.Invio_push__c;
        communicationTemp.Tipo_notifica_su_Centro_Notifiche__c = iniMarketingTemp.Tipo_notifica_su_Centro_Notifiche__c;
        if(iniMarketingTemp.Canale__c=='Email + Push'){
            communicationTemp.Notification_Typology__c = 'Email';
            communicationTemp.Invio_push__c = true;
        }else{
            communicationTemp.Notification_Typology__c = iniMarketingTemp.Canale__c;
        }
        String descrip = String.valueOf(iniMarketingTemp.Descrizione_dell_iniziativa__c);
        //communicationTemp.Communication_Description__c = descrip.length()>254 ? descrip.abbreviate(255): descrip;
        communicationTemp.put('Communication_Description__c',descrip.abbreviate(255));
        communicationTemp.TECH_URL_template_MC__c = iniMarketingTemp.TECH_URL_template_MC__c ;
        //communicationTemp.Communication_Description__c = iniMarketingTemp.Descrizione_dell_iniziativa__c;

        WrapperInfoDinamicIniziativaMkt utilityDinamicFieldsModals ;
        String contenutoFinale = communicationTemp.Message_Push_Notification__c;
        String contenutoFinaleMC =communicationTemp.Additional_Details__c;
        //campi dinamici nel template iniziativa
        if(requestChiusura != null || requestCambiOrari!= null ){
            utilityDinamicFieldsModals = new WrapperInfoDinamicIniziativaMkt(accForNotification,requestChiusura,requestCambiOrari);
            //WrapperInfoDinamicIniziativaMkt.substringBetweenMarketingCloud(communicationTemp.Message_Push_Notification__c);
            List<String> responseText = WrapperInfoDinamicIniziativaMkt.substringBetweenMarketingCloud(communicationTemp.Message_Push_Notification__c);
            if(!responseText.isEmpty()){
                contenutoFinaleMC =responseText[0];
                contenutoFinale =  responseText[1];
            }
            communicationTemp.Message_Push_Notification__c = contenutoFinale;
            communicationTemp.Additional_Details__c = contenutoFinaleMC;
        }
    }
    /**
     * @description NASTARI Giovanni mail -  Nome campi tabella Noovle -> Contact History
     * Il primo controllo per la verifica di inserimento di box subagente, fa riferimento al campo ccod_produttore__c sull’Account. 
        Scenario 1
        Il campo “ccod_produttore__c” non è valorizzato – Qui, ci troveremo nel caso di un’agenzia e verrà mostrato di conseguenza il box di agenzia. 
        Scenario 2
        Il campo “ccod_produttore__c” è valorizzato – Da qui partiranno ulteriori controlli che si tradurranno in altri sottoscenari
        I.	Il campo “ccod_produttore__c” è valorizzato ed i campi (dalla tabella Node__c):
        a.	“Intermediary_Type__c” = NODO PRODUZIONE o SEDE SECONDARIA
        b.	“Relation_End_Date__c” è maggiore/uguale alla data di oggi (si tratta quindi di un nodo aperto)
        c.	“Agency_holder__c” non è vuoto.
        In questo sottoscenario esponiamo il box della subagenzia, con l’Agency holder e i relativi dati se presenti; se mancanti non verranno mostrati.
        
        II.	Il campo “ccod_produttore__c” è valorizzato ed una delle tre condizioni al sottoscenario I. sopra non è verificata. 
        In questo sottoscenario viene effettuato un’ulteriore controllo sul campo presente alla tabella dei Nodi Parent_node_unique_code__c, che si tradurrà nel “nuovo” Node_unique_code__c. 
        Da qui controlliamo che il Parent_Node_Unique_code__c relativo al “nuovo” Node_Unique_Code__c appena citato inizi con “Z”. Nel caso inizi con “Z” mostreremo il box di Agenzia, 
        in caso contrario, si ritorna al controllo sul primo sottoscenario e si sale di “livello”.
        Sia nel caso di subagenzia che nel caso di agenzia vengono mostrati solo i campi che risultano valorizzati.

     * @param accForNotification Account in scheda cliente
     * @return      `Map<String,boolean>`
     */
    public static Map<String,boolean> Agenzia_OR_Subagenzia (list <WrapperRequest> accForNotification){
        List<String> listAgency = new List<String> ();
        Map<String,Node__c> MapAgencyInfo = new Map<String,Node__c> ();
        Map<String,boolean> response = new Map<String,Boolean> ();
        for (WrapperRequest accPivot : accForNotification) {
            listAgency.add(accPivot.AgencyCode);
        }

        List<Node__c> nodeAgenzia = [select id,Parent_node_unique_code__c,Node_unique_code__c,Relation_End_Date__c, Intermediary_type__c, Agency_holder__c  from Node__c where Node_unique_code__c in:listAgency WITH SYSTEM_MODE ];
        for(Node__c nodePivot:nodeAgenzia){
            if(!MapAgencyInfo.containsKey(nodePivot.Node_unique_code__c))
                MapAgencyInfo.put(nodePivot.Node_unique_code__c,nodePivot);
        }

        for(WrapperRequest accPivot : accForNotification){
            if(accPivot.Ccod_Produttore==null || String.isBlank(accPivot.Ccod_Produttore) || accPivot.Ccod_Produttore.equalsIgnoreCase('0')){
                response.put(accPivot.AccountId,true);
            }else if(MapAgencyInfo.containsKey(accPivot.AgencyCode)){ 
                if(MapAgencyInfo.get(accPivot.AgencyCode).Intermediary_type__c == 'NODO PRODUZIONE' || MapAgencyInfo.get(accPivot.AgencyCode).Intermediary_type__c == 'SEDE SECONDARIA' 
                &&
                MapAgencyInfo.get(accPivot.AgencyCode).Relation_End_Date__c >= System.now().date() 
                && 
                String.isNotBlank(MapAgencyInfo.get(accPivot.AgencyCode).Agency_holder__c)){
                    response.put(accPivot.AccountId,false); 
                }else if(String.valueOf(MapAgencyInfo.get(accPivot.AgencyCode).Parent_node_unique_code__c).startsWith('Z')) {
                    response.put(accPivot.AccountId,true);  
                }
                else {
                    response.put(accPivot.AccountId,false);
                }      
            }
        }
        return response;
    }
}