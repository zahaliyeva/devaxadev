/** 
 * @author	reply
 * @date	30/03/2023 4xx
 * @description Class controller del LWC dhValidatePolicy
 */
public with sharing class DhValidatePolicyController {


    /** 
    * @return	risposta configurazione totale nel MTDs
    * @description metodo per MTDs utilizati nel lwc field validation
    */
    @AuraEnabled
    public static List<DhValidatePolicyConfiguration__mdt> getConfigurationList (){
        return [Select CategoriaPolizza__c, CodiceCompagnia__c, lpadPolizzaFiglio__c, lpadPolizza__c from DhValidatePolicyConfiguration__mdt WITH SYSTEM_MODE]; // NOPMD  Fix CRUD
    }

    /**
     * @description exception class
     */
    public class IntegrationException extends Exception {}


    /** 
    * @param	caseInput Case condiviso per il recordId del LWC chiamante
    * @return	risposta del aggiornamento sul case andato OK 
    * @example	case con campi popolati tutti 4, response true se policyID sul 
    * @description metodo per creare il policyID nel formato richiesto per la integrazione con servizi DIH
    */
    @AuraEnabled
    public static responseWrapper validatePolicy (Case caseInput){

            
            responseWrapper rw  = new responseWrapper();
        try {
            
                rw = policyIdFormat(caseInput);

                IE_DH_ResponseWrapper res = IE_DH_Execute.executeDH(rw.result, caseInput.CodiceFiscale_PIVA_Contraente__c);
                if(res != null){
                    if(res.commonData != null){                        
                        Integer substringEnd = caseInput.Compagnia__c == '95' ? 5 : 4;
                        String codTariffa;
                        if(res.commonData.productId.length() > substringEnd){
                            codTariffa = res.commonData.productId.substring(0,substringEnd);
                        } else {
                            codTariffa = res.commonData.productId;
                        }
                        String descrizione = res.commonData.productNameSmall;
                        rw.codTariffa = codTariffa;
                        rw.descrizione = descrizione;


                    }
                    else {
                        //la integrazione tecnicamente è andato in OK pero ce un errore nella risposta
                        responseCodeToAnalyze(res, rw);
                    }
                }
                else{
                    throw new IntegrationException('Errore integrazione');
                }

        } catch (Exception errorEx) {
            ApplicationLogHelper.ERROR('DhValidatePolicyController', errorEx.getMessage(), errorEx.getStackTraceString());
                rw.isSuccess = false;
                rw.errorMessage = 'S02 - La polizza non  e\' al momento ricercabile per un problema tecnico. Riprova piu\' tardi';
                
            }
            return rw;
        }



    /** 
    * @param	caseInput Case condiviso per il recordId del LWC chiamante
    * @return	risposta del aggiornamento sul case andato OK 
    * @example	case con campi popolati tutti 4, response true se policyID sul 
    * @description metodo per creare il policyID nel formato richiesto per la integrazione con servizi DIH
    */
    @AuraEnabled
    public static responseWrapper policyIdFormat (Case caseInput){

            Map<String,String> mapParams = new Map<String,String>();
            PolicyId polizzaTemp = null;
            responseWrapper rw  = new responseWrapper();
            try {
                mapParams.put('compagnia',caseInput.Compagnia__c);
                mapParams.put('categoriaPolizza',caseInput.CategoriaPolizza__c);
                mapParams.put('polizzaNum',caseInput.NumeroPolizza__c);
                mapParams.put('polizzaNumFiglia',caseInput.NumeroPolizzaFiglia__c);
                
                polizzaTemp = new PolicyId(mapParams);
                rw = polizzaTemp.getConfig();

            } catch (Exception errorEx) {
                ApplicationLogHelper.ERROR('DhValidatePolicyController', errorEx.getMessage(), errorEx.getStackTraceString());
                rw.isSuccess = false;
                rw.errorMessage = 'Errore conferma polizza! Riprova piu\' tardi';
                
            }
            return rw;
        }

        /**
         * @description wrapper risposta
         */
        public class responseWrapper{
            /**
             * @description risposta in OK
             */
            @AuraEnabled
            public boolean isSuccess {get; set;}

            /**
             * @description messaggio di errore
             */
            @AuraEnabled
            public String errorMessage {get; set;}

            /**
             * @description PolicyId risultante
             */
            @AuraEnabled
            public String result {get; set;}

            /**
             * @description codTariffa risultante
             */
            @AuraEnabled
            public String codTariffa {get; set;}

            /**
             * @description descrizione tariffa risultante
             */
            @AuraEnabled
            public String descrizione {get; set;}

            /**
             * @description costruttore
             */
            public responseWrapper(){
                this.isSuccess = true;
            }

        }

    /**
    *@description Classe per la creazione del policyID nel Formato: <fonte>-<Compagnia>-<Categoria polizza>-<numero polizza>-<numero testa>
    */ 
    private  with sharing class PolicyId {
        private String formatedPolicyId ;
        private Map<String,String> mapInputsByNumber = new Map<String,String>();        

        /**
         * @description costructor
         * @param mapParams 
         */
        public PolicyId(Map<String,String> mapParams){
            this.mapInputsByNumber = mapParams;
            //this.formatedPolicyId = getConfig(mapParams.get('compagnia'),mapParams.get('categoriaPolizza'),mapParams.get('polizzaNum'));
        }

        /**
         * @description getter
         * @return  `String`
         */
        public String getFormatedPolicyId(){
            return this.formatedPolicyId;
        }
        
        /** 
        * @return	policyID che aspetta come parametro il it-sb-digital-integration-hub-api-vs/v1/policies/<policyId> -formato per scenario - DhValidatePolicyConfiguration__mdt
        * @example	case ( Compagnia__c = '05', CategoriaPolizza__c='21 - Collettiva',NumeroPolizza__c='599999',NumeroPolizzaFiglia__c='333')
        *  ouput PASSLIFE-05-21-050599999
        * @description crea il policyID con il formato accettato dal servicio servizi DIH regolato per DhValidatePolicyConfiguration__mdt
        */
        public responseWrapper getConfig(){
            String compagnia = this.mapInputsByNumber.get('compagnia');
            String categoriaPolizza = this.mapInputsByNumber.get('categoriaPolizza');
            String polizzaNum = this.mapInputsByNumber.get('polizzaNum');

            responseWrapper toRet = new responseWrapper();
            
                String eccezioneRegolaGenerale = '';// per default prende tutti 
                
                String formato = '' ;
                String fonte = '';
                
            try {
                if(polizzaNum.startsWith('9') || polizzaNum.startsWith('5')){
                    eccezioneRegolaGenerale = polizzaNum.substring(0,1) ;
                }

                List<DhValidatePolicyConfiguration__mdt> configList = [select id,Fonte__c,FormatoPolicyId__c,lpadPolizza__c,lpadPolizzaFiglio__c, minimum_lpad_Polizza__c // NOPMD  Fix CRUD
                                                        from DhValidatePolicyConfiguration__mdt 
                                                        where CategoriaPolizza__c =:categoriaPolizza and
                                                        CodiceCompagnia__c =:compagnia 
                                                        and 
                                                        (
                                                            eccezioneRegola__c =: eccezioneRegolaGenerale

                                                        )
                                                        WITH SYSTEM_MODE order by eccezioneRegola__c limit 1];

                

                if(configList.isEmpty()){
                    configList = [select id,Fonte__c,FormatoPolicyId__c,lpadPolizza__c,lpadPolizzaFiglio__c, minimum_lpad_Polizza__c // NOPMD  Fix CRUD
                                                        from DhValidatePolicyConfiguration__mdt 
                                                        where CategoriaPolizza__c =:categoriaPolizza and
                                                        CodiceCompagnia__c =:compagnia 
                                                        and 
                                                        (
                                                            eccezioneRegola__c = null

                                                        )
                                                        WITH SYSTEM_MODE order by eccezioneRegola__c limit 1];
                }

                if(configList.isEmpty()){
                    toRet.isSuccess = false;
                    toRet.errorMessage = 'Errore! Valori polizza non validi!';
                }

                else{
                    DhValidatePolicyConfiguration__mdt  configTemp = configList.get(0);

                formato = configTemp.FormatoPolicyId__c ;
                fonte = configTemp.Fonte__c;
                
                for(String indexKey: this.mapInputsByNumber.keySet()){
                    if(formato.containsIgnoreCase('X'+indexKey+'X')){                  
                        String value = this.mapInputsByNumber.get(indexKey);
                        if(String.isNotBlank(value)){
                            if(indexKey.equalsIgnoreCase('polizzaNum')){
                                if(configTemp.minimum_lpad_Polizza__c !=null && value.length() <= configTemp.minimum_lpad_Polizza__c){
                                    value = value.leftPad((Integer)configTemp.minimum_lpad_Polizza__c,'0');
                                }
                                else if(configTemp.lpadPolizza__c !=null)
                            		value = value.leftPad((Integer)configTemp.lpadPolizza__c,'0');
                            }
                            if(configTemp.lpadPolizzaFiglio__c !=null && indexKey.equalsIgnoreCase('polizzaNumFiglia')){
                                value = value.leftPad((Integer)configTemp.lpadPolizzaFiglio__c,'0');
                            }
                            if(indexKey.equalsIgnoreCase('categoriaPolizza')){
                                value = value.substring(0, 2);
                            }
                
                        	formato = formato.replaceAll('X'+indexKey+'X',value);        
                        }
                        else{
                            formato = formato.replaceAll('X'+indexKey+'X',''); 
                        }       
                    }
                }
                    formato = formato.removeEnd('-');
                    toRet.result = fonte + formato;
                }

            } 
            catch (Exception errorEx) {
                ApplicationLogHelper.ERROR('DhValidatePolicyController', errorEx.getMessage(), errorEx.getStackTraceString());

                toRet.isSuccess = false;
                toRet.errorMessage = 'Errore! Riprova piu\' tardi!';
            } 

            return toRet;
        
        }
    }
   
    /**
     * @description Metodo per rispondere specificamente a un CODE di errore nella risposta di DHPolicy serve.          
     * @param responseWrapper 
     * @param responseInError 
     */
    private static void responseCodeToAnalyze(IE_DH_ResponseWrapper responseWrapper, responseWrapper responseInError){
        //responseWrapper responseInError = new responseWrapper();
        if(responseWrapper.code == 'T300'){
            responseInError.isSuccess = true;
            responseInError.errorMessage = 'La polizza inserita non è stata trovata. Puoi comunque procedere inserendo solamente il Codice Tariffa';
        } else if (responseWrapper.code == '500'){
            responseInError.isSuccess = true;
            responseInError.errorMessage = 'Server Error ' + responseWrapper.userMessage != null ? responseWrapper.userMessage : 'DHPolicy' ;
        } else if(responseWrapper.code != null && responseWrapper.commonData == null){
            responseInError.isSuccess = true;
            responseInError.errorMessage = 'Server Error '+ responseWrapper.code + responseWrapper.userMessage != null ? responseWrapper.userMessage : 'DHPolicy'  ;
        }
        //return responseInError;
    }
}