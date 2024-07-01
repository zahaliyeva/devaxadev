public without sharing class UnsubMainCTRL {
        
    private static final Set<String> resultDeveloperMessageToIgnore = new Set<String>{
        'Errore di integrazione con CIF - Esistono Fascicoli aperti, salvataggio soggetto interrotto.'.toLowerCase(),
        'Errore di integrazione con CIF - Esistono Fascicoli aperti, salvataggio soggetto interroto.'.toLowerCase(),
        'Errore di integrazione con CIF - I consensi profilazione/OTP/grafo non certificati e DAC aperti'.toLowerCase()
    };
    
    private static final Map<String, String> labelToFieldMap = new Map<String, String>{
        'Privacy1'=>'Comunicazioni_informative__c',
        'Privacy2'=>'CIF_Privacy_2__c',
        'Privacy3'=>'CIF_Privacy_3__c', 
        'Privacy7'=>'CIF_Privacy_7__c',
        'Privacy5'=>'CIF_Privacy_5__c',
        'Privacy4'=>'CIF_Privacy_4__c'
        
    };

    private static final Map<String, String> frontEndValuesToFieldMap = new Map<String, String>{
        'Comunicazioni informative'=>'Comunicazioni_informative__c',
        'Comunicazioni promozionali'=>'CIF_Privacy_2__c',
        'Ricerche di Mercato'=>'CIF_Privacy_3__c'
    };

    private static final List<String> uselessPrivacyFields = new List<String>{
        //'CIF_PersonEmail__c',
        'CIF_Mail_Contact__c',
        //'CIF_PersonalEmail__c',
        'CIF_Propaga_OMNIA_PersonEmail__c',
        'Flag_Opposizione_Email_Pers_B2C__c',
        'Motivo_opposizione_Email_Pers_B2C__c',
        'CIF_Propaga_OMNIA_Personal_Email__c',
        'Flag_Opposizione_Email_Pers_B2B__c',
        'Motivo_opposizione_Email_Pers_B2B__c',
        'CIF_Privacy_7__c',
        'CIF_Privacy_5__c',
        'CIF_Privacy_4__c',
        'CIF_Privacy_1__c',
        'CIF_Privacy_2__c',
        'CIF_Privacy_3__c',
        'Comunicazioni_informative__c',
        'CIF_Mail_contact__c'};

    public static IE_Integration_Record__c MC_Login(Map<String, IE_configuration__c> confMap){

        IE_configuration__c reqConf = confMap.get(MKT_Auth_Request.getConfName());
        MKT_Auth_Request req = new MKT_Auth_Request(reqConf);
        IE_Integration_Record__c rec;
        return  MKT_Utility.getAuthTokenUnsub(reqConf, req);
        
    }

    
    public static getValueWrapper getValuesFromMC(String tokenToReq){
        List<IE_Integration_Record__c> recToIns = new List<IE_Integration_Record__c>();
        getValueWrapper resp = new getValueWrapper();
        MKT_Unsuscribed_Wrapper resp1;
        try {
            
            Map<String, IE_configuration__c> confMap = new Map<String, IE_configuration__c>();
            for(IE_configuration__c conf : [SELECT id, Name, Endpoint__c, HTTPMethod__c, ClientID__c, Client_Secret__c FROM IE_configuration__c where name like 'MC_Unsub%' ]){ // NOPMD  Fix CRUD violation
                confMap.put(conf.Name, conf);
            }
            
            IE_Integration_Record__c recLogin = MC_Login(confMap);
            if(recLogin != null){
                recToIns.add(recLogin);
                Map<string, Object> response = (Map<string, Object>) JSON.deserializeUntyped(recLogin.ResponseBody__c);
                System.debug(recLogin.ResponseBody__c);
                String token = (String) response.get('access_token');
                if(token != null){
                    IE_Integration_Record__c recGetValue = MC_getUnsubValues(confMap, token, tokenToReq);
                    
                    if(recGetValue != null){
                        recToIns.add(recGetValue);
                        resp1 = (MKT_Unsuscribed_Wrapper) JSON.deserialize(recGetValue.ResponseBody__c, MKT_Unsuscribed_Wrapper.Class);
                        for(Integer i = 0; i < resp1.count; i++){
                            system.debug(resp1.items.get(i));
                        }
                    }
                }
            }
            
            
        } catch (Exception ex) {

            try{
                ApplicationLogHelper.ERROR('UnsubMainCTRL', ex.getmessage(), ex.getStackTraceString());
            }catch(Exception e){
                System.debug(System.LoggingLevel.ERROR,'Exception: ' + e.getmessage() + '\tStackTrace: '+e.getStackTraceString());
            }

        }
        if(!recToIns.isEmpty()){
            resp.recToIns = recToIns;
            resp.respWrapper = resp1;
        }
        return resp;
    }

    @AuraEnabled
    public static UnsubscribeInitWrapper Init(String tokenToReq, Boolean isUnsub){
        //inserire logica di ricerce oggetto con token
        UnsubscribeInitWrapper toRet;
        try{
            toRet = new UnsubscribeInitWrapper();
            toRet.errors.isTokenNew = true;
            List<IE_Integration_Record__c> recToIns;
            getValueWrapper m = getValuesFromMC(tokenToReq);
            //reference tu null object on Else if (m.respWrapper.count == 1) *-+ 03-11-2021
            //if (m == null || (m != null && m.respWrapper!=null && m.respWrapper.count != 1)){
            if (m == null || (m != null && m.respWrapper==null  )){
                toRet.errors.isMCRespOK = false;
            }else if (m.respWrapper.count == 1){
                toRet.Token = tokenToReq;
                toRet.valuesFromMC = m.respWrapper.items.get(0).values;
                
                Datetime rn = DateTime.now();
                if(rn <= MKT_Utility.parseDateTimeFromString(toRet.valuesFromMC.expirationdate)){
                    String ndg = toRet.valuesFromMC.ndg;
                    List<Account> accList = [Select id, Comunicazioni_Informative__c, RecordTypeId, (select id from Customer_Events__r where Token__c =:tokenToReq) FROM Account WHERE ndg__c =: ndg];
                    if(!accList.isEmpty()){
                        if(accList.get(0).Customer_Events__r != null && accList.get(0).Customer_Events__r.size()!=0){
                            if(isUnsub)
                                toRet.errors.isTokenNew = false;
                            else{
                                toRet.errors.wrongRecipient = false;
                            }
                        }
                        else{
                            if(isUnsub){
                                toRet.setAccId(accList.get(0).ID);
                                AccountSearchCtrl.ResponseDto CIF_Resp;
                                try{
                                        
                                    CIF_Resp = AccountSearchCtrl.sendRequest_fullsearch(ndg);

                                    if(CIF_Resp == null ||(CIF_Resp != null && !CIF_Resp.isSuccess) ){
                                        toRet.errors.isCIFRespOK = false;
                                        Id recTypeId = Schema.SObjectType.Customer_Event__c.getRecordTypeInfosByDeveloperName().get('Digital_Event').getRecordTypeId();
                                        SObject cusEv = new Customer_Event__c(Account__c = accList.get(0).ID, Servizio__c = 'Unsubscribe', PreferencesModifiedDate__c=System.Now().format('ddMMyyyy'), DACSource__c='Unsubscribe', DACType__c='Batch', RecordtypeId = recTypeId, Timestamp__c=DateTime.now(), result__c = 'KO INTEGRAZIONE');
                                        insert cusEv; // NOPMD  Fix CRUD violation
                                    }
                                    else{
    
                                        Map<String, Boolean> privacyTempMap = new Map<String, Boolean>();
                                        /*
                                        for(String s : labelToFieldMap.keySet()){
                                            privacyTempMap.put(s,(Boolean)CIF_Resp.values.get(s));
                                        }
                                        */
                                        Account a = new Account();
                                        SObject accFromCRM = accList.get(0);
                                        SObject accToRet = a, accFromCIF;
                                        Object key = 'returnedCIFAccount';
                                        if(CIF_Resp.values.containsKey(key)){
                                            accFromCIF = (SObject) CIF_Resp.values.get(key);
    
                                        }
    
                                        System.debug(accFromCIF);
                                        for(String s: labelToFieldMap.keySet()){
                                            if(accFromCIF.get(labelToFieldMap.get(s)) != null){
                                                Boolean value = ((String) accFromCIF.get(labelToFieldMap.get(s))) == 'Sì';
                                                privacyTempMap.put(s, value);
                                            }
                                            
                                            //accToRet.put(s, accFromCIF.get(s));
                                        }
                                        if(accFromCRM.get(labelToFieldMap.get('Privacy1')) != null){
                                            accFromCIF.put(labelToFieldMap.get('Privacy1'), (String) accFromCRM.get(labelToFieldMap.get('Privacy1')));
                                            Boolean value = ((String) accFromCRM.get(labelToFieldMap.get('Privacy1'))) == 'Sì';
                                            privacyTempMap.put('Privacy1', value);
                                        }
                                        String serializedMap = JSON.serialize(privacyTempMap);
                                        accFromCIF.put('Id', accFromCRM.Id);
                                        accFromCIF.put('RecordTypeId', accFromCRM.get('RecordTypeId'));
                                        system.debug(accFromCIF);
                                        toRet.CIFResponse = (Account) accFromCIF;
                                        toRet.valuesFromCIF = (UnsubscribeInitWrapper.CIF_Privacy) JSON.deserialize(serializedMap, UnsubscribeInitWrapper.CIF_Privacy.Class);
                                        //toRet.editedFieldsMap = accountEditLightningCTRL.findModifiedFieldsGrouped((Account) accFromCIF);
                                    }
                                } catch(Exception e){

                                    toRet.errors.isCIFRespOK = false;
                                    Id recTypeId = Schema.SObjectType.Customer_Event__c.getRecordTypeInfosByDeveloperName().get('Digital_Event').getRecordTypeId();
                                    SObject cusEv = new Customer_Event__c(Account__c = accList.get(0).ID, Servizio__c = 'Unsubscribe', PreferencesModifiedDate__c=System.Now().format('ddMMyyyy'), DACSource__c='Unsubscribe', DACType__c='Batch', RecordtypeId = recTypeId, Timestamp__c=DateTime.now(), DACError__c=e.getMessage(), result__c = 'KO INTEGRAZIONE');
                                    insert cusEv; // NOPMD  Fix CRUD violation
                                    ApplicationLogHelper.ERROR('UnsubMainCTRL', 'Error on account: ' + accList.get(0).ID + '\n' + e.getMessage(), e.getStackTraceString());
                                }
                                
                                
                            }
                        }
                    }
                    else{
                        toRet.errors.isInCRM = false;
                    }
                }
                else{
                    toRet.errors.isDateValid = false;
                }
            }
            else {
                // aggiornato 03-11-2021 *-+
                toRet.errors.isMCRespOK = false;
            }

             if(m != null && m.recToIns!= null ){
                recToIns = m.recToIns;
            }
            if(!recToIns.isEmpty()){
                insert recToIns; // NOPMD  Fix CRUD violation
            }
        }
        catch(Exception ex){
            toRet.errors.isInCRM = false;
            try{
                ApplicationLogHelper.ERROR('UnsubMainCTRL', ex.getmessage(), ex.getStackTraceString());
            }catch(Exception e){
                System.debug(System.LoggingLevel.ERROR,'Exception: ' + e.getmessage() + '\tStackTrace: '+e.getStackTraceString());
            }

        }
        return toRet;
    }
    
    
    
    @AuraEnabled
    public static String save(String i){
        
        try{
            UnsubscribeInitWrapper input = (UnsubscribeInitWrapper) JSON.deserialize(i, UnsubscribeInitWrapper.class);
            
            Id recTypeId = Schema.SObjectType.Customer_Event__c.getRecordTypeInfosByDeveloperName().get('Digital_Event').getRecordTypeId();
            if(input.valuesFromMC.ndg!=null){
                String ndg = input.valuesFromMC.ndg;
                String modifiedConsents='';
                Boolean onlyInformative = false;
                SObject modifiedAcc = [Select id, isPersonAccount, recordtypeid, ndg__c, AAI_Agency__r.Agency_Email__c from account where ndg__c =: ndg limit 1];
                
                
                map<String, Boolean> editedFieldMap =new Map<String, Boolean>();
                Set<String> accFieldSet = new Set<String>(Account.sObjectType.getDescribe().fields.getMap().keySet());

                for(String s : input.editedFieldsMap.keySet()) {
                    if(String.isNotBlank(s) && accFieldSet.contains(s.toLowerCase()) && input.CIFResponse.get(s) != null) {
                        editedFieldMap.put(s, true);
                        modifiedAcc.put(s, input.CIFResponse.get(s));
                    }
                }

                
                SObject cusEv = new Customer_Event__c(Account__c = modifiedAcc.Id, Servizio__c = 'Unsubscribe', PreferencesModifiedDate__c=System.Now().format('ddMMyyyy'), DACSource__c='Unsubscribe', DACType__c='Batch', RecordtypeId = recTypeId, Timestamp__c=DateTime.now());
                Boolean privacy2IsFalse=false;

                if(input.editedFieldsMap.isEmpty()){
                    for(String frontEndFieldName: frontEndValuesToFieldMap.values()){
                        modifiedConsents=handleModifiedConsents(frontEndFieldName,modifiedConsents,privacy2IsFalse);
                    	if(input.CIFResponse.get(frontEndFieldName)=='Sì'){
                        	cusEv.put(frontEndFieldName, 'True');
                        }
                        else if(input.CIFResponse.get(frontEndFieldName)=='No'){
                           	cusEv.put(frontEndFieldName, 'False');
                       	}
                    }
                }
                else{
                    for(String s : input.editedFieldsMap.keySet()){
                        if(frontEndValuesToFieldMap.containsKey(s)){
                            String fieldname = frontEndValuesToFieldMap.get(s);
                            String value = input.editedFieldsMap.get(s) ? 'Sì':'No';
                            cusEv.put(fieldname, String.valueOf(input.editedFieldsMap.get(s)).capitalize());                          
                            modifiedAcc.put(fieldName, value);
                            if('CIF_Privacy_2__c'.equals(fieldName) && value == 'No'){
                                privacy2IsFalse=true;
                            }
                            modifiedConsents=handleModifiedConsents(fieldName,modifiedConsents,Privacy2IsFalse);
                            editedFieldMap.put(fieldname, true);
                        }
                    }
                }
                if(privacy2IsFalse){
                    modifiedConsents+=', 4';
                    modifiedAcc.put('CIF_Privacy_4__c', 'No');
                    cusEv.put('CIF_Privacy_4__c', 'False');
                    editedFieldMap.put('CIF_Privacy_4__c', true);
                }
                cusEv.put('ModifiedConsents__c',modifiedConsents);
                onlyInformative = containsOnly(editedFieldMap, 'Comunicazioni_informative__c');

                system.debug(input.CIFResponse);
                for(String s : uselessPrivacyFields){
                    if(!editedFieldMap.containsKey(s)){
                        editedFieldMap.put(s, true);
                        if(input.CIFResponse.get(s)!=null) modifiedAcc.put(s, input.CIFResponse.get(s));
                    }
                }

                
                if(((Boolean)modifiedAcc.get('isPersonAccount'))){
                    modifiedAcc.put('CIF_PersonEmail__c',  input.CIFResponse.get('CIF_Mail_contact__c'));
                    modifiedAcc.put('CIF_Work_email__c' ,  input.CIFResponse.get('CIF_Mail_contact__c'));
                    editedFieldMap.put('CIF_PersonEmail__c', true);

                }
                
                if(!((Boolean)modifiedAcc.get('isPersonAccount'))){
                    
                    modifiedAcc.put('CIF_PersonalEmail__c',  input.CIFResponse.get('CIF_Mail_contact__c'));
                    modifiedAcc.put('CIF_Work_email__c' ,  input.CIFResponse.get('CIF_Mail_contact__c'));
                    editedFieldMap.put('CIF_PersonalEmail__c', true);

                }

                editedFieldMap.put('isFromUnsub', true);
                system.debug('The Acc: ' + modifiedAcc);
                
            
                Map<String,String> userinfo = getUserInfos();

                //removing PartyServiceEdit request temporarily
                accountEditLightningCTRL.ResponseDto resp;
                if(!onlyInformative){
                    resp = accountEditLightningCTRL.sendRequest((Account) modifiedAcc, editedFieldMap, new Map<String, TelephoneWithPrefix>());
                }
                else{
                    resp = new accountEditLightningCTRL.ResponseDto(true, '');
                }
                    
                System.debug(modifiedAcc);
                system.debug(resp);
                if(!resp.isSuccess) cusEv.put('DACError__c',resp.message);
                if(resp != null && resp.isSuccess || (!resp.isSuccess && resultDeveloperMessageToIgnore.contains(resp.message.toLowerCase()))){
                    editedFieldMap.remove('isFromUnsub');
                    
                    Account temp = (Account) modifiedAcc;
                    String agencyEmail = '';
                    if(temp.AAI_Agency__r != null && temp.AAI_Agency__r.Agency_Email__c != null){
                        agencyEmail = temp.AAI_Agency__r.Agency_Email__c;
                    }
                    
                    if(!editedFieldMap.containsKey('Comunicazioni_informative__c')){
                        editedFieldMap.put('Comunicazioni_informative__c', true);
                    }
                    
                    cusEv.put('Token__c', input.Token);
                    cusEv.put('Agency_Email__c',agencyEmail);
                    update modifiedAcc;
                    insert cusEv; // NOPMD  Fix CRUD violation
                    return 'Success';
                }
            cusEv.put('result__c', 'KO INTEGRAZIONE');
            insert cusEv; // NOPMD  Fix CRUD violation
            }
            return 'Error Response';
        }
        catch(Exception e){
            
            ApplicationLogHelper.ERROR('UnsubMainCTRL', e.getMessage(), e.getStackTraceString());
            
            return 'Exception';
        }

    }
    
    public static String handleModifiedConsents(String fieldName, String modifiedConsents, Boolean Privacy2IsFalse){
        for(Integer i=1;i<=8;i++){
            if(('CIF_Privacy_'+String.valueOf(i)+'__c').equals(fieldName)){
                if(i!=4 || (i==4 && !privacy2IsFalse)){
                    if(modifiedConsents!='') modifiedConsents+=', ';
                    modifiedConsents+=i;
                }
            }
        }
        return modifiedConsents;
    }

    public static boolean containsOnly(Map<String, Object> inputMap, String key){
        if(!inputMap.containsKey(key)){
            return false;
        }
        for(String s : inputMap.keySet()){
            if(s != key){
                return false;
            }
        }
        return true;
    }

    @AuraEnabled
    public static String createCase(String i){

        try{
            String ErrorMessage;
            UnsubscribeInitWrapper input = (UnsubscribeInitWrapper) JSON.deserialize(i, UnsubscribeInitWrapper.class);
            List<Account> accList = [select id, AAI_Agency_Reference_Code__c, AAI_Agency__r.Agency_Email__c from account where ndg__c = :input.valuesFromMC.ndg limit 1];
            if(accList != null && !accList.isEmpty()){
                String channel = input.valuesFromMC.channel;
                Account a = accList[0];
                if(a.AAI_Agency_Reference_Code__c != null && a.AAI_Agency_Reference_Code__c != ''){
                    String agencyToSend = 'Coda_Agenzia_Case_'+ a.AAI_Agency_Reference_Code__c;
                    Case c = new Case();
                    List<Group> agencyGroup = [Select id from Group where developername = :agencyToSend ]; // NOPMD  Fix CRUD violation
                    if(agencyGroup != null && !agencyGroup.isEmpty()){
                        
                      	Decimal PrimoSollecitoAgente = 0;
                        Decimal SecondoSollecitoAgente = 0;
                        Decimal TerzoSollecitoAgente = 0;
                        Decimal PrimoSollecitoAgenzia = 0;
                        Decimal SecondoSollecitoAgenzia = 0;
                        String defaultHoursId;
                        List<String> remindersListAgente = new List<String>();
                        if(MPS_Code_Variables__c.getValues('BusinessHours_Default')!= null)
                			defaultHoursId = MPS_Code_Variables__c.getValues('BusinessHours_Default').Value__c;
                        if(MPS_Code_Variables__c.getValues('Ivass41Solleciti')!=null)
                        {
                            if(String.isNotBlank(MPS_Code_Variables__c.getValues('Ivass41Solleciti').value__c))
                            {
                                for(String s:(MPS_Code_Variables__c.getValues('Ivass41Solleciti').value__c).split(';'))
                                {
                                    remindersListAgente.add(s);                
                                }
                            }
                        }
                        if(!remindersListAgente.isEmpty())
                        {
                            PrimoSollecitoAgenzia = Decimal.valueOf(remindersListAgente[0]);
                            SecondoSollecitoAgenzia = Decimal.valueOf(remindersListAgente[1]);
                            primoSollecitoAgente = Decimal.valueOf(remindersListAgente[2]);
                            secondoSollecitoAgente = Decimal.valueOf(remindersListAgente[3]);
                            terzoSollecitoAgente = Decimal.valueOf(remindersListAgente[4]);
                        }
                        
                        Id caseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Axa_Assicurazioni').getRecordTypeId();
                        
                        c.OwnerId = agencyGroup.get(0).Id;
                        c.Status = AP_Constants.caseStatusOpen;
                        c.Origin = 'Contatto Marketing Cloud';
                        c.recordTypeid = caseRecTypeId;
                        if('Email'.equals(channel)){
                            c.SuppliedEmail = input.valuesFromMC.emailaddress;
                        }
                        else{
                            c.SuppliedPhone = input.valuesFromMC.mobilephone;
                        }
                        c.Complainant__c = 'Customer';
                        c.Description = 'Richiesta di cancellazione del contatto per destinatario errato: '+ (channel.equals('Email') ? c.SuppliedEmail : c.SuppliedPhone);
                        c.Agency_Email__c = a.AAI_Agency__r.Agency_Email__c;
                        c.Oggetto_Apertura_Case__c = 'Richiesta di cancellazione contatto per destinatario errato';
                        system.debug(c.Agency_Email__c);
                        c.LOB__c = 'Privacy';
                        c.Category__c = 'GDPR (Regolamento generale sulla Protezione dei Dati)';
                        c.SubCategory__c = 'Richiesta di cancellazione';
                        c.AccountId = a.id;
                        if(defaultHoursId != null && PrimoSollecitoAgenzia != null && SecondoSollecitoAgenzia != null){
                            c.TECH_Primo_Sollecito_Agenti__c = BusinessHours.addGMT(defaultHoursId,System.now(),((PrimoSollecitoAgenzia)*60 * 60 * 1000L).longValue());
                            c.TECH_Secondo_Sollecito_Agenti__c = BusinessHours.addGMT(defaultHoursId,System.now(),((SecondoSollecitoAgenzia)*60 * 60 * 1000L).longValue());
                        }
                        
                        insert c;
                        Id recTypeId = Schema.SObjectType.Customer_Event__c.getRecordTypeInfosByDeveloperName().get('Digital_Event').getRecordTypeId();
                        Customer_Event__c cusEv = new Customer_Event__c(Account__c = a.Id, Token__c = input.Token, Servizio__c = 'Destinatario errato', RecordtypeId = recTypeId, Timestamp__c=DateTime.now());
                        //insert cusEv;
                        return 'SUCCESS';
                    }
                    else
                        ErrorMessage = 'Agenzia non trovata: ' + a.AAI_Agency_Reference_Code__c;
                }
                else
                    ErrorMessage = 'Codice Agenzia non popolato su Account con id: '+ a.id;
                    
                
            }
            else
                ErrorMessage = 'Account non trovato con ndg: '+input.valuesFromMC.ndg;
            
            ApplicationLogHelper.ERROR('UnsubMainCTRL', ErrorMessage, 'Destinatario errato');
            return 'Error';
        }
        catch(Exception e){
            try{
                ApplicationLogHelper.ERROR('UnsubMainCTRL', e.getMessage(), e.getStackTraceString());
            }
            catch(Exception ex){
                system.debug(ex.getStackTraceString());
            }
            return 'Exception';
        }
    }


    public static IE_Integration_Record__c MC_getUnsubValues(Map<String, IE_configuration__c> confMap,String authToken, String tokenToReq){
        MKT_Unsuscribed_Wrapper resp = new MKT_Unsuscribed_Wrapper();
        IE_configuration__c reqConf = confMap.get(resp.getConfName());
        IE_Integration_Record__c rec;
        
        return MKT_Utility.getDataFromMC(reqConf, authToken, tokenToReq);
        
        
    }

    private class getValueWrapper{
        public List<IE_Integration_Record__c> recToIns;
        public MKT_Unsuscribed_Wrapper respWrapper;
    }
    
    public static Map<String, String>  getUserInfos() { 
        //String UserId = UserInfo.GetUserId();
        User CurrentUser = new User();
        Boolean isDAOLAgency = true; 
        CurrentUser = [SELECT CommunityNickname, Agency_code__c, Profile.Name, Username FROM User WHERE Username like 'technical_user@italy.axa.com%' Limit 1];
        AAI_Code_Variables__c linkdaol = [SELECT Value__c FROM AAI_Code_Variables__c WHERE Name='AccountEdit_Folderlink' LIMIT 1].get(0);  
        if(CurrentUser.Profile.Name == 'AAI - Vendite Avanzato' || CurrentUser.Profile.Name == 'AAI - Vendite Base'){
            Account AgencyAccount = [SELECT DAOL_2_0__c FROM Account WHERE Recordtype.Developername = 'Agency' AND Agency_Code__c =: CurrentUser.Agency_code__c AND Active__c=true  LIMIT 1].get(0); // NOPMD  Fix CRUD violation
            isDAOLAgency = AgencyAccount.DAOL_2_0__c;
        }     
        Map<String, String> userinfomap = new Map<String,String>();
            
            string nickname = CurrentUser.CommunityNickname;
            string agency_code = CurrentUser.Agency_code__c;
            string link_daol = String.valueOf(linkdaol.Value__c);
            string username = CurrentUser.Username;
            String profile = CurrentUser.Profile.Name;

            userinfomap.put('nickname', nickname);
            userinfomap.put('agency_code', agency_code); 
            userinfomap.put('link_daol', link_daol);
            userinfomap.put('isDAOLAgency',String.valueOf(isDAOLAgency));
            userinfomap.put('username',username);
            userinfomap.put('profile',profile);

            system.debug('userinfomap'+userinfomap);

        return userinfomap;
    }
    
}