/**
 * @description controller per invio singola push da NFE
 * @author    Reply  
 * @since     07/2023  
 */
public without sharing class mobilitySinglePushController {
    /**
     * @description
     */
    public class responseWrapper extends MobilityResponse{

        @AuraEnabled
        public mobilitySinglePushWrapper inputParams;
        @AuraEnabled
        public List<Iniziative_Marketing__c> iniziative;
        @AuraEnabled
        public Account AccountCliente;
        @AuraEnabled 
        public String SuccessMessage;
        @AuraEnabled 
        public boolean visibility = true;
        //EClemente - 26/02/2024 - Boolean to check if the iniziative is communicated
        @AuraEnabled 
        public boolean communicated = false;
        //per reutilizare il wrapper dentro il filtro fatique
        public Integer maxCommunicationsFilter;
    }
    /**
     * @description          per caricare i dati account e la lista posibile di iniziative senza fatique.
     * @param inputParameter il input è una string codificata da RGI 
     * @return               `responseWrapper`
     */
    @AuraEnabled
    public static responseWrapper init(String inputParameter){
        responseWrapper res = new responseWrapper(); 
        responseWrapper responseProfili = new responseWrapper(); 
        Account AccountCliente = new Account(); 
        mobilitySinglePushWrapper paramsTemp = new mobilitySinglePushWrapper();
        res.visibility = true;
        res.communicated=false;
        responseProfili = profileNFEAccess('Profilo_NFE_Abilitati_Invio_Sing_Push2');

        MobilitySinglePush_Utils__mdt mobCstMtd = [SELECT Notification_Typology__c, Error_Message_Comunicazioni__c, StatusQuery__c FROM MobilitySinglePush_Utils__mdt WHERE DeveloperName = 'InitValues'];

        if(responseProfili.isSuccess){
            paramsTemp = decryptoJsonFromNFE(inputParameter);
            if(paramsTemp != null && paramsTemp.ndg != null && paramsTemp.checkEmail()){
                AccountCliente =  searchAccount(paramsTemp.ndg);
                if(AccountCliente == null){
                    res.errorMessage='Account con NDG (fornito come parametro) non presente su SFDC';
                    res.isSuccess = false;
                    return res;
                }
            }else {
                res.errorMessage='Errore Formato JSON controllare APP log mobilitySinglePushController ';
                res.isSuccess = false;
                return res;
            }
            String queryFilter = createFilterDinamicQuery(AccountCliente,paramsTemp);
            //String queryFilter = ' where Attiva__c = true '; 

            String queryIni = 'Select id,Name, URL_Immagine__c, URL_CTA__c, Titolo__c, Sottotitolo__c, Short_Message__c,Nome_Messaggio__c,Descrizione_Messaggio__c,'+
            'Message__c,is_scheduled_type__c,is_closure_type__c, Testo_CTA__c, Communication_code__c, Versione__c, Eligibile_per_Compagnia__c,Base_Giuridica__c, TECH_URL_template_MC__c,'+
            'Contenuto__c,Visibilita_nel_centro_notifiche__c,Invio_push__c,Tipologia_Campagna__c,Tipo_notifica_su_Centro_Notifiche__c,'+
            'Canale__c, Descrizione_dell_iniziativa__c,Entita_SFDC_di_riferimento__c,Categoria_Prodotto__c, Sottotipologia_Campagna__c '
            +' from Iniziative_Marketing__c  ';
            String orderby= ' ORDER BY LastModifiedDate desc';

            List<Iniziative_Marketing__c> listIniziativa = Database.query(queryIni+queryFilter+orderby,AccessLevel.SYSTEM_MODE); // NOPMD  Fix CRUD violation
              
            Set<String> statusToInclude = new Set<String>();

            if(mobCstMtd.StatusQuery__c.contains(';')){
                statusToInclude.addAll(mobCstMtd.StatusQuery__c.split(';'));
            }else{
                statusToInclude.add(mobCstMtd.StatusQuery__c);
            }
           
            //ECLEMENTE - 26/02/2024 - Start: cmToCst contains all communications active
            List<Communications_to_customer__c> cmToCst = [Select Id, AccountId__c, Status__c,Notification_Typology__c from Communications_to_customer__c WHERE AccountId__c =: AccountCliente.Id AND Notification_Typology__c =: mobCstMtd.Notification_Typology__c AND Status__c IN: statusToInclude ];

            system.debug('init - cmToCst: '+cmToCst);
            //ECLEMENTE - 26/02/2024 - Start: Add if/else ternary condition for modal toast error
            res.iniziative =listIniziativa;    //se vuota i filtri hanno tolto tutte le iniziative, il messagio deve avere i codes       
            res.AccountCliente=AccountCliente;
            res.isSuccess = true;
            res.communicated=cmToCst == null || cmToCst.isEmpty() ? false : true;
            res.errorMessage =cmToCst == null || cmToCst.isEmpty() ? '' : mobCstMtd.Error_Message_Comunicazioni__c;
        }else {
            res.isSuccess = responseProfili.isSuccess;
            res.visibility=false;
            res.errorMessage = responseProfili.errorMessage;
            return res;
        }

            
            //ECLEMENTE - 26/02/2024 - End
      
        return res;
    }
    /**
     * @description    
     * @param codeJson 
     * @return         `mobilitySinglePushWrapper`
     */
    public static mobilitySinglePushWrapper decryptoJsonFromNFE(String codeJson){
        mobilitySinglePushWrapper responseW = new mobilitySinglePushWrapper();
        try {
            
            Crypto_Values__mdt val = [Select Init_Vector__c, Key__c from Crypto_Values__mdt where developerName = 'Wizard_CL']; // NOPMD  Fix CRUD violation
            Blob passPhrase = Blob.valueOf(val.Key__c);
            Blob IV = Blob.valueOf(val.Init_Vector__c);
            Blob privateKey = Crypto.generateDigest('SHA-256',passPhrase);
            Blob b = EncodingUtil.base64Decode(codeJson);
            Blob decrypted = Crypto.decrypt('AES256', privateKey, IV, b);
            responseW = (mobilitySinglePushWrapper) JSON.deserialize(decrypted.toString(), mobilitySinglePushWrapper.class);
            
        } catch (Exception ex ) {
            ApplicationLogHelper.ERROR('mobilitySinglePushController.decryptoJsonFromNFE', ex.getmessage(), ex.getStackTraceString());
            return null;
        }
        return responseW;
    }
    /**
     * @description 
     * @param NDG   
     * @return      `Account`
     */
    private static Account searchAccount(String NDG){
        try {        
        List<Account> resultsAcc = [Select id,Ccod_Produttore__c,NDG__c,PersonContactId,Name,Email_ListView__c,Codice_fiscale_ListView__c,Agency_Code__c, AAI_Agency__r.Agency_Holder__c,     // NOPMD  Fix CRUD violation
        AAI_Agency__r.Name,AAI_Agency__r.Phone,AAI_Agency__r.Agency_email__c,AAI_Agency__r.MobilePhone__c,Contact_Master_Id__c,AAI_Agency__r.Agency_Code__c,
        Additional_Phone__c ,MobilePhone__c,Mobile_Master_AAI__c,Email_Master_AAI__c,CIF_Number__c,CIF_Document_type__c,RecordType.DeveloperName,
        Flag_registrazione_area_privata__c,Comunicazioni_informative__c,Bcert_Privacy_Email_Ndg_AAI__c,CIF_Privacy_5__c, 
        BlackList_Abitazione__c,BlackList_Auto__c,BlackList_Aziende__c,BlackList_Broker__c,BlackList_Commerciale__c,
        BlackList_Infortuni__c,BlackList_Malattia__c,Blacklist_Processi__c,BlackList_Protection__c,BlackList_Rinnovo__c,
        BlackList_Saving__c,BlackList_Servizio__c, (Select id from Contacts order by createdDate desc limit 1)
        from Account where NDG__c =:NDG WITH SYSTEM_MODE limit 1 ];

        if(!resultsAcc.isEmpty()){
            return resultsAcc[0];
        }
        else {
            return null;
        }
        } catch (Exception ex) {
            ApplicationLogHelper.ERROR('mobilitySinglePushController searchAcc', ex.getmessage()+'NDG-'+NDG, ex.getStackTraceString());
            return null;
        }
    }
    /**
     * @description      return true se il profilo del user puo accedere al Push o Ecollab dipende dal devName MDTs
     * @param mtdDevName devName del metadata che salva i profili che possono vedere Push o Ecollab  
     * @return           `responseWrapper`
     */
    public static responseWrapper profileNFEAccess(String mtdDevName){
        String userId = System.UserInfo.getUserId();
        List<String> profili = new List<String>();
        responseWrapper response = new responseWrapper();
        User usernfe = [select id,Profile.Name from user where id =:userId];// NOPMD  Fix CRUD violation
        list<MPS_Code_Utils__mdt > profilesOK= [select Key__c, Value__c from MPS_Code_Utils__mdt where Key__c =: mtdDevName];// NOPMD  Fix CRUD violation

        if(!profilesOK.isEmpty()){
            profili = profilesOK[0].Value__c.split(';');
        }else {
            response.isSuccess= false;
            response.errorMessage= 'E00 - Non esiste la config MTDs -  MPS_Code_Utils__mdt';
        }
        for(String profilo_pivot :profili){
            if(profilo_pivot == usernfe.Profile.Name){
                response.isSuccess= true;
                response.errorMessage= '';
                return response;
            }else {
                continue;
            }
        }
        response.isSuccess= false;
        response.errorMessage= 'Profilo Operatore non abilitato';
        return response;
    }
    /**
     * @description          
     * @param AccountCliente 
     * @param iniziativaId   
     * @return               `responseWrapper`
     */
    @AuraEnabled
    public static responseWrapper createCommunicationsingle(Account AccountCliente,String iniziativaId,
    MobilityCampaignsByPushNotification.WrapperChisura requestChiusura, MobilityCampaignsByPushNotification.WrapperCambiOrari requestCambiOrari){
        responseWrapper response = new responseWrapper();
        Communications_to_customer__c comunicationTemp = new Communications_to_customer__c();        
        List<Iniziative_Marketing__c> iniziativaSelected = [Select id,Name, URL_Immagine__c, URL_CTA__c, Titolo__c, Sottotitolo__c, Short_Message__c, // NOPMD  Fix CRUD violation
        Message__c,is_scheduled_type__c,is_closure_type__c, Testo_CTA__c, Communication_code__c, Versione__c, Eligibile_per_Compagnia__c,
        Contenuto__c,Visibilita_nel_centro_notifiche__c,Invio_push__c,Tipo_notifica_su_Centro_Notifiche__c,  
        Canale__c, Descrizione_dell_iniziativa__c,TECH_URL_template_MC__c 
        from Iniziative_Marketing__c 
        where id =:iniziativaId limit 1];

        try {

        if (!iniziativaSelected.isEmpty()) {

            MobilityCampaignsByPushNotification.WrapperRequest tempWrap = mappingAccountOnWrapper(AccountCliente);//mapping campi che servono alla comunicazione dinamica
            comunicationTemp = MobilityCampaignsByPushNotification.createComunicationToCustomerSingle(true,tempWrap,'',iniziativaSelected[0],
            requestChiusura,requestCambiOrari);
            // aggiornare il flag per il contact history, per capire se Agenzia o Collaboratore nel titolo della comunication_t_c
            Map<String,boolean> AgencyOrSubagency = MobilityCampaignsByPushNotification.Agenzia_OR_Subagenzia(new List<MobilityCampaignsByPushNotification.WrapperRequest>{tempWrap});
            //regole per diferenzare Agenzia da sottoNodo 
            if(AgencyOrSubagency.containsKey(comunicationTemp.AccountId__c)){
                comunicationTemp.TECH_invio_da_Agenzia_Sottonodo__c = AgencyOrSubagency.get(comunicationTemp.AccountId__c);
            }

            CommunicationToCustomerHandler.DeactivateTrigger=true;
            Database.SaveResult sresult = Database.insert(comunicationTemp);
            if(sresult.isSuccess()){
                response.isSuccess = true;
                response.SuccessMessage = 'OK06 - Comunicazioni create - 1';
            }else {
                response.isSuccess = false;
                response.errorMessage = 'E061 - Comunicazioni al clienti in errori';
            }
        }else {
            response.isSuccess = false;
            response.errorMessage = 'E03 - Iniziativa MKT non popolata dal JS';
        }
        } catch (Exception ex) {
            ApplicationLogHelper.ERROR('mobilitySinglePushController.createCommunicationsingle', ex.getmessage(), ex.getStackTraceString());
            response.isSuccess = false;
            response.errorMessage = 'E061 - Comunicazioni al clienti in errori';
            return response;
        }

        return response;
    }
    /**
     * @description 
     * @param acc   
     * @return      `MobilityCampaignsByPushNotification.WrapperRequest`
     */
    private static MobilityCampaignsByPushNotification.WrapperRequest mappingAccountOnWrapper(Account acc){
        MobilityCampaignsByPushNotification.WrapperRequest AccountWrapp = new MobilityCampaignsByPushNotification.WrapperRequest();
        AccountWrapp.Name = acc.Name;
        AccountWrapp.NDG = acc.NDG__c;
        AccountWrapp.AccountId = acc.id;
        AccountWrapp.CIFDocumenttype = acc.CIF_Document_type__c;
        AccountWrapp.CIFNumber = acc.CIF_Number__c;

        if(String.isNotBlank(acc.Contact_Master_Id__c)){
            AccountWrapp.ContactId = acc.Contact_Master_Id__c;
            AccountWrapp.ContactMasterId = acc.Contact_Master_Id__c;
        }
        else if(acc.Contacts != null && !acc.Contacts.isEmpty()){
            AccountWrapp.ContactId = acc.Contacts[0].Id;
        }
        else if(acc.PersonContactId != null){
            AccountWrapp.ContactId = acc.PersonContactId;
        }
        else{
            List<Contact> cList = [Select id from contact where accountId =: acc.Id order by createdDate desc limit 1];
            if(!cList.isEmpty()){
                AccountWrapp.ContactId = cList[0].Id;
            }
        }

        
        AccountWrapp.EmailMasterAAI = acc.Email_Master_AAI__c;
        AccountWrapp.MobileMasterAAI = acc.Mobile_Master_AAI__c;
        //dati agenzia
        AccountWrapp.Ccod_Produttore = acc.Ccod_Produttore__c;
        AccountWrapp.AgencyCode = acc.AAI_Agency__r.Agency_Code__c;
        AccountWrapp.AgencyName = acc.AAI_Agency__r.Name;
        AccountWrapp.AgencyMobilePhone = acc.AAI_Agency__r.MobilePhone__c;
        AccountWrapp.AgencyEmail = acc.AAI_Agency__r.Agency_email__c;
        AccountWrapp.AgencyHolder = acc.AAI_Agency__r.Agency_Holder__c;
        return AccountWrapp;
    }
    /**
     * @description      filtrare in base a mail, privacy registrato ...altri,vedere excel di consensi 
     * @param acc        
     * @param jsonParams 
     * @return           `String`
     */
    private static String createFilterDinamicQuery (Account acc,mobilitySinglePushWrapper jsonParams) {
        List<String> tipologieAgenti = ('\'' + 'Manuali da Agente' + '\'' +';'+ '\'' + 'Automatici da Agente' + '\'').split(';');
        //[EDIT] EClemente - IDCRM149 Mappatura comunicazioni eCollab - 28/03/2024: Added filter to exclude IM already comunicated.
        String filtroFinale = ' where id != null and Attiva__c = true and EscludiComunicaCliente__c = false and Tipologia_di_iniziative__c in '+tipologieAgenti;
        String nonNeccesario = '\'' + 'Non Necessario' + '\')';
        String PrivacyPromotialAct = jsonParams.getPrivacy_Promoziona() + ',' + nonNeccesario;
        String EmailValidation = jsonParams.getEmail_Validation() + ',' + nonNeccesario;
        String DocumentStatus = jsonParams.getDocStatus() + ',' + nonNeccesario;
        String Comunicazioni_informative = acc.Comunicazioni_informative__c=='Sì'? jsonParams.getSi():jsonParams.getNo() ;
        String Comunicazioni_informativeEnd = Comunicazioni_informative + ',' + nonNeccesario;
        String Flag_Registrazione = acc.Flag_registrazione_area_privata__c==true ? jsonParams.getSi() : jsonParams.getNo();
        String Flag_RegistrazioneEnd = Flag_Registrazione + ',' + nonNeccesario;
        String StopCarta = jsonParams.getSiOrNoCertificato(acc.CIF_Privacy_5__c, acc.Bcert_Privacy_Email_Ndg_AAI__c);
        String StopCartaEnd = StopCarta + ',' + nonNeccesario;
         
        if(String.isNotBlank(PrivacyPromotialAct)){
            filtroFinale+= ' AND Necessario_Consenso_Privacy_Promoziona__c in ' + PrivacyPromotialAct;
        }
        if(String.isNotBlank(EmailValidation)){
            filtroFinale+= ' AND Mail_Validata__c in ' + EmailValidation;
        }
        if(Flag_Registrazione != null){
            filtroFinale+= ' AND Necessaria_Registrazione__c in ' + Flag_RegistrazioneEnd;
        }
        if(Comunicazioni_informative!=null){
            filtroFinale+= ' AND Adesione_Invio_Delle_Comunicazioni_Info__c in ' + Comunicazioni_informativeEnd;
        }
        if(DocumentStatus !=null ){
            filtroFinale+= ' AND Stato_Documento__c in' + DocumentStatus;
        }
        if(StopCartaEnd !=null ){
            filtroFinale+= ' AND RichiestoConsensoStopCarta__c in' + StopCartaEnd;
        }
        return filtroFinale ;
    }
    /**
     * @description          se true almeno una regola essite per la iniziativa deve essere tolta o nascosta si chiama nel JS
     * @param iniziativa     iniziativa da capire se mostrare o nascondere nella lista 
     * @param AccountCliente cliente
     * @return               `Boolean` se true, va tolto della lista da mostrare
     */
    @AuraEnabled
    public static responseWrapper filterByFatique(Iniziative_Marketing__c iniziativa,Account AccountCliente){
        responseWrapper response = new responseWrapper();
        response.isSuccess=false;  
        Boolean isNeedFatique = true;      
        try {
            if(AccountCliente.RecordType.DeveloperName == 'B2B_Client'){// fix il tempo di carica del b2b 
            isNeedFatique = isNeededSearchOnRecordsByFatique(iniziativa,AccountCliente);
            }

        if(isNeedFatique){
        List <Logiche_di_Fatique__mdt> listFatiqueActive = [select TypeBaseGiuridica__c,where_condition_used__c,Type_IER_Text_toDelete__c,usedByIndividualEmailR__c,Type_Base_Giuridica_toDelete__c,AllYear__c, LastDays__c, MaxCommunicationCreated__c, Active__c, LastDaysLiteral__c from Logiche_di_Fatique__mdt where Active__c = true and typeFilter__c='Fatique']; // NOPMD  Fix CRUD violation
        for (Logiche_di_Fatique__mdt regola : listFatiqueActive) {
            if(iniziativa.Base_Giuridica__c == regola.TypeBaseGiuridica__c){
                response = searchOnCommunications_IsFatique(regola.where_condition_used__c,iniziativa,regola.Type_Base_Giuridica_toDelete__c,(Integer) regola.LastDays__c, regola.AllYear__c,(Integer) regola.MaxCommunicationCreated__c, AccountCliente.Id);
                if(response.isSuccess){
                    response.SuccessMessage = 'searchOnCommunications_IsFatique'+iniziativa.Communication_code__c;
                    return response;
                }else if(regola.usedByIndividualEmailR__c){
                    response.isSuccess =  searchOnSendEmail_MC_IsFatique(regola.Type_IER_Text_toDelete__c,(Integer) regola.LastDays__c, regola.AllYear__c,(Integer)regola.MaxCommunicationCreated__c-response.maxCommunicationsFilter, AccountCliente.PersonContactId);
                    response.SuccessMessage = 'searchOnSendEmail_MC_IsFatique'+iniziativa.Communication_code__c;
                }
            if(response.isSuccess)
                return response;  
            }else 
            if (String.isBlank(iniziativa.Base_Giuridica__c)|| iniziativa.Base_Giuridica__c ==null) {
                response.errorMessage = 'Base_Giuridica non popolata iniziativa mkt '+iniziativa.id;
                response.isSuccess = true;
                return response;
            }

        }
        return response;
        }else{
            response.errorMessage = 'Cliente non ha nessuna comunicazione Iniziativa mostrata';
            response.isSuccess = false ;
            return response;
        }
        } catch (Exception ex) {
            ApplicationLogHelper.ERROR('mobilitySinglePushController.filterByFatique', ex.getmessage()+'iniz_ID-'+iniziativa.id, ex.getStackTraceString());
            response.isSuccess=true;
            response.errorMessage='E080 - Errore Tecnico. Verifica AppLOG ';
            return response;
        }
    }
    /**
     * @description          se true almeno una regola essite per la iniziativa deve essere tolta o nascosta
     * @param iniziativa     iniziativa da capire se mostrare o nascondere nella lista 
     * @param AccountCliente cliente
     * @return               `Boolean` se true, va tolto della lista da mostrare
     */
    @AuraEnabled
    public static responseWrapper filterByBlacklist(Iniziative_Marketing__c iniziativa, Account AccountCliente){
        responseWrapper response = new responseWrapper();
        response.isSuccess=false;
        try {
        List <Logiche_di_Fatique__mdt> listBlackListActive = [select DeveloperName , Key__c, ApiName_fieldToFound__c from Logiche_di_Fatique__mdt where Active__c = true and typeFilter__c = 'Blacklist' ]; // NOPMD  Fix CRUD violation
        
        for (Logiche_di_Fatique__mdt regola : listBlackListActive) {

            if(String.valueOf(regola.DeveloperName).containsIgnoreCase('TipologiaCampagna')){
                if(iniziativa.Tipologia_Campagna__c == regola.Key__c ){
                    response.isSuccess = searchFieldOnAccount(AccountCliente,regola.ApiName_fieldToFound__c);
                }
            }else 
            if (String.valueOf(regola.DeveloperName).containsIgnoreCase('CategoriaProdotto')){
                if(iniziativa.Categoria_Prodotto__c == regola.Key__c ){
                    response.isSuccess = searchFieldOnAccount(AccountCliente,regola.ApiName_fieldToFound__c);
                }
            }
            if(response.isSuccess){
                return response;
            }
        }
        //se arriva fino a qua il template *iniziativa non entra nelle regole di blacklist x il cliente *AccountCliente
        return response;
        } catch (Exception ex) {
            ApplicationLogHelper.ERROR('mobilitySinglePushController.filterByBlacklist', ex.getmessage()+'iniz_ID-'+iniziativa.id, ex.getStackTraceString());
            response.isSuccess=true;
            response.errorMessage='E080 - Errore Tecnico. Verifica AppLOG ';
            return response;
        }
    }
    /**
     * @description          
     * @param AccountCliente Account con blacklist values
     * @param fieldBlacklist api name del flied in Account correspondente al black nel MTD
     * @return               `Boolean` se true il cliente non deve ricevere questa iniziativa
     */
    private static Boolean searchFieldOnAccount(Account AccountCliente,String fieldBlacklist){
        try { 
        List<String> fieldsApinames = fieldBlacklist.split(';');
        for(String field:fieldsApinames){
            Boolean getvalue =(Boolean) AccountCliente.get(field);
            if(getvalue)
            return getvalue;
        }
        return false;
        } catch (Exception ex) {
            ApplicationLogHelper.ERROR('mobilitySinglePushController.searchFieldOnAccount', ex.getmessage(), ex.getStackTraceString());
            return true;
        }
    }
    /**
     * @description                     
     * @param TypeBaseGiuridicatoSEARCH 
     * @param lastDays                  
     * @param AllYear                   
     * @param maxCommunications         
     * @param AccountId                 
     * @return                          `Boolean`
     */
    private static responseWrapper searchOnCommunications_IsFatique(String whereSelected,Iniziative_Marketing__c iniziativa,String TypeBaseGiuridicatoSEARCH, Integer lastDays,Boolean AllYear, Integer maxCommunications,String AccountId){
        responseWrapper response = new responseWrapper();
        try {
        Datetime todayIs = System.now();
        Datetime lastNdays = todayIs.addDays(-lastDays);
        Datetime DateTimeThisYear = Datetime.newInstance(System.now().year(),1,1);
        List<String> typeBasesTosearch = TypeBaseGiuridicatoSEARCH.split(';');
        String prodottoIniziativaToAnalyze = String.isNotBlank(iniziativa.Categoria_Prodotto__c)?iniziativa.Categoria_Prodotto__c : 'NON PRODOTTO' ;
        String commuCode = String.isNotBlank(iniziativa.Communication_code__c ) ? iniziativa.Communication_code__c : 'NON CODE' ;

        String queryMain = 'select count( id ) suma from Communications_to_customer__c ';
        String whereCondVar = '';
        if(AllYear){
            whereCondVar= 'and Send_Date__c >=:DateTimeThisYear ';
        }else {
            whereCondVar= 'and Send_Date__c >=:lastNdays ';
        }
        // ci sono diverse regole del WHERE 
        String whereFinale = '';
        switch on whereSelected {
            when 'Base_Giuridica' {
                whereFinale = 'where AccountId__c =:AccountId and Iniziativa_Marketing_Id__r.Base_Giuridica__c IN :typeBasesTosearch AND Status__c != \'KO digital sending\' ';
            }	
            when 'Categoria_Prodotto' {
                whereFinale = 'where AccountId__c =:AccountId and Iniziativa_Marketing_Id__r.Categoria_Prodotto__c =:prodottoIniziativaToAnalyze AND Iniziativa_Marketing_Id__r.Base_Giuridica__c = \'Commerciale\' AND Status__c != \'KO digital sending\' ';
            }
            when 'Base_Giuridica_Ecollab' {
                whereFinale = 'where AccountId__c =:AccountId AND Iniziativa_Marketing_Id__r.Base_Giuridica__c IN :typeBasesTosearch AND Iniziativa_Marketing_Id__r.Communication_code__c =:commuCode AND Status__c != \'KO digital sending\' ';
            }
            when else { //per adesso il default e base giuridica
                whereFinale = 'where AccountId__c =:AccountId and Iniziativa_Marketing_Id__r.Base_Giuridica__c IN :typeBasesTosearch AND Status__c != \'KO digital sending\' ';
            }
        }

        AggregateResult resultsFromDB = Database.query(queryMain+whereFinale+whereCondVar, AccessLevel.SYSTEM_MODE);
        Integer countSum = (Integer) resultsFromDB.get('suma');
        if(countSum >= maxCommunications){
            response.isSuccess = true;
            response.maxCommunicationsFilter = countSum;
            return response;
        }
        response.isSuccess = false;
        response.maxCommunicationsFilter = countSum;
        return response ;
        } catch (Exception ex) {
            response.isSuccess=false;
            response.errorMessage='E080 - Errore Tecnico. Verifica AppLOG ';
            return response;
        }
    }
    /**
     * @description       mtds configuration for fatique               
     * @param TypeBaseGiuridicatoSEARCH 
     * @param lastDays                  
     * @param AllYear                   
     * @param maxCommunications         
     * @param contactId                 
     * @return                          `Boolean`
     */
    private static Boolean searchOnSendEmail_MC_IsFatique(String TypeBaseGiuridicatoSEARCH, Integer lastDays,Boolean AllYear, Integer maxCommunications,String contactId){
        try {
        Datetime todayIs = System.now();
        Datetime lastNdays = todayIs.addDays(-lastDays);
        Datetime DateTimeThisYear = Datetime.newInstance(System.now().year(),1,1);
        List<String> typeBasesTosearch = TypeBaseGiuridicatoSEARCH.split(';');
        String NameLikeTypes = '';//(Name LIKE '%v5%' or Name LIKE '%v1%')
        for(String placeholderEmail:typeBasesTosearch){
            NameLikeTypes = NameLikeTypes+ 'Name LIKE \''+ String.escapeSingleQuotes(placeholderEmail) + '\' OR ';
        }
        NameLikeTypes = NameLikeTypes.substringBeforeLast(' OR ');
        String queryMain = 'select count( id ) suma from et4ae5__IndividualEmailResult__c ';
        String whereCondiStatics = 'where et4ae5__Contact__c =:contactId and ('+NameLikeTypes+') ';
        String whereCondVar = '';
        if(AllYear){
            whereCondVar= 'and et4ae5__DateSent__c >=:DateTimeThisYear ';
        }else {
            whereCondVar= 'and et4ae5__DateSent__c >=:lastNdays ';
        }

        AggregateResult resultsFromDB = Database.query(queryMain+whereCondiStatics+whereCondVar, AccessLevel.SYSTEM_MODE); // NOPMD ApexSOQLInjection falso positivo
        Integer countSum = (Integer) resultsFromDB.get('suma');
        if(countSum >= maxCommunications){
            return true;
        }
        return false;
        } catch (Exception ex) {
        return false;
        }
    }

    /**
     * @description          Metodo del init del LWC certificaDac
     * @param inputParameter Json codificato inviato da RGI con dei parametri di privacy
     * @return               `responseWrapper`
     */
    @AuraEnabled
    public static responseWrapper InitSingoloEcollaboration(String ndgid){

        responseWrapper res = new responseWrapper(); 
        responseWrapper responseProfili = new responseWrapper(); 
        Account AccountCliente = new Account(); 
        mobilitySinglePushWrapper paramsTemp = new mobilitySinglePushWrapper();
        List<Iniziative_Marketing__c> listIniziativa = new List<Iniziative_Marketing__c> ();
        MPS_Code_Utils__mdt codeCom_dinamic = MPS_Code_Utils__mdt.getInstance('PushFase2_Ecollab_CodeCom');
        String comunicationCodeDAC = codeCom_dinamic.Value__c;

        try {   
        responseProfili = profileNFEAccess('Profilo_NFE_Abilitati_Invio_Sing_Ecollab');
        if(responseProfili.isSuccess){
            //paramsTemp = decryptoJsonFromNFE(inputParameter);
            if(ndgid != null && String.isNotBlank(ndgid)){
                AccountCliente =  searchAccount(ndgid);
                if(AccountCliente == null){
                    res.errorMessage='Account con NDG (fornito come parametro) non presente su SFDC';
                    res.isSuccess = false;
                    return res;
                }
            }else {
                res.errorMessage='Errore ndgid controllare parametri RGI ';
                res.isSuccess = false;
                return res;
            }
            String queryIni = 'Select id,Name, URL_Immagine__c, URL_CTA__c, Titolo__c, Sottotitolo__c, Short_Message__c,Nome_Messaggio__c,Descrizione_Messaggio__c,'+
            'Message__c, Testo_CTA__c, Communication_code__c, Versione__c, Eligibile_per_Compagnia__c,Base_Giuridica__c, TECH_URL_template_MC__c,'+
            'Contenuto__c,Visibilita_nel_centro_notifiche__c,Invio_push__c,Tipologia_Campagna__c,Tipo_notifica_su_Centro_Notifiche__c,'+
            'Canale__c, Descrizione_dell_iniziativa__c,Entita_SFDC_di_riferimento__c,Categoria_Prodotto__c, Sottotipologia_Campagna__c '
            +' from Iniziative_Marketing__c where Communication_code__c =:comunicationCodeDAC and Attiva__c = true ';
            String orderby= ' ORDER BY LastModifiedDate desc';

            listIniziativa = Database.query(queryIni+orderby,AccessLevel.SYSTEM_MODE); // NOPMD  Fix CRUD violation
                
            res.iniziative = listIniziativa;    //se vuota i filtri hanno tolto tutte le iniziative, il messagio deve avere i codes       
            res.AccountCliente = AccountCliente;
            res.isSuccess = true;
        }else {
            res.isSuccess = responseProfili.isSuccess;
            res.visibility = false;
            res.errorMessage = responseProfili.errorMessage;
            return res;
        }
        return res;
        } catch (Exception ex) {
            ApplicationLogHelper.ERROR('mobilitySinglePushController.InitSingoloEcollaboration', ex.getmessage()+'listIniziativa-'+listIniziativa, ex.getStackTraceString());
            res.isSuccess=false;
            res.errorMessage='E080 - Errore Tecnico. Verifica AppLOG ';
            return res;
        }
    }
    /**
     * @description          per il b2b nel invio singolo caricare i template in meno tempo 
     * @param iniziativa     iniziativa da analizare
     * @param AccountCliente cliente b2b
     * @return               `Boolean` se false non ce bisogno di aplicare regole di fatique perche non ha comunicazioni 
     */
    private static Boolean isNeededSearchOnRecordsByFatique(Iniziative_Marketing__c iniziativa,Account AccountCliente){
        try {
            
        String iniziativaID = String.isNotBlank(iniziativa.id)? iniziativa.id : '';
        String contactID = String.isNotBlank(AccountCliente.Contact_Master_Id__c) ? AccountCliente.Contact_Master_Id__c: 
                            !AccountCliente.Contacts.isEmpty() ? AccountCliente.Contacts[0].Id:'';
        String accountID = String.isNotBlank(AccountCliente.id)? AccountCliente.id : '';
        AggregateResult resultsFromDB_Communications = [select count( id ) suma from Communications_to_customer__c where Iniziativa_Marketing_Id__c =:iniziativaID and AccountId__c =:accountID ];
        AggregateResult resultsFromDB_EmailResults = [select count( id ) suma from et4ae5__IndividualEmailResult__c where et4ae5__Contact__c =:contactID ];

        Integer countSumComm = (Integer) resultsFromDB_Communications.get('suma');
        Integer countSumER = (Integer) resultsFromDB_EmailResults.get('suma');

        if(countSumComm+countSumER == 0) 
            return false;
            //altri casi è sempre bisogno di fare partire le regole
        return true;
        } catch (Exception ex) {
            return true;
        }
    }
}