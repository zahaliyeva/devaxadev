/**
 * @description Iniziativa Marketing IDCRM020 - Push Notification (2022)
 * @author      Reply
 * @since       06-2022
 */
public without sharing class lghtIniziativeMarketingCustomViewCTRL {
    /**
     * @description CONST
     */
    public lghtIniziativeMarketingCustomViewCTRL() {
    }
    /**
     * @description wrapper iniziativa
     */
    public class wrapperIniziativeMarketing {
        @AuraEnabled public String id;
        @AuraEnabled public String Name;
        @AuraEnabled public String Versione;
        @AuraEnabled public boolean Attiva;
        @AuraEnabled public String CodeComunication ;
        @AuraEnabled public String Url;
        @AuraEnabled public String PerCompany;
        @AuraEnabled public String EntitaRef;
        @AuraEnabled public String TipologiaIniz;
        @AuraEnabled public boolean InvioPush;
        @AuraEnabled public boolean visibilitaCentroNotif;
        @AuraEnabled public String Messagio;
        //IDCRM 078 push notification Fase 2 nuovi campi nel wrapper
        @AuraEnabled public String PerCanale;
        @AuraEnabled public String TipologiaCampagna;

    }
    /**
     * @description      ritorna values di una picklist formato label-value
     * @param objApiName Sobject d CRM
     * @param fieldName  Api name d picklist
     * @return           `List < Map < String, String >>`
     */
    @AuraEnabled
    public static List < Map < String, String >> getPickListValues(String objApiName, String fieldName) {
        List < Map < String, String >> options = new List < Map < String, String >> ();
        Map < String, Schema.SObjectType > objGlobalMap = Schema.getGlobalDescribe();
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objApiName);
        if (objType == null) {
            return options;
        }
        Schema.DescribeSObjectResult sobjectDescribe = objType.getDescribe();
        Map < String, Schema.SObjectField > fieldMap = sobjectDescribe.fields.getMap();
        if (fieldMap.get(fieldName) == null) {
            return options;
        }
        List < Schema.PicklistEntry > pickListValues = fieldMap.get(fieldName).getDescribe().getPickListValues();
        for (Schema.PicklistEntry f: pickListValues) {
            Map < String, String > values = new Map < String, String > {
                'label' => f.getLabel(),
                'value' => f.getValue()
            };
            options.add(values);
        }
        return options;
    }
    /**
     * @description view iniziale con 200 records, dopo di che si utiliza il FILTERALL
     * @return      `List<wrapperIniziativeMarketing>`
     */
    @AuraEnabled 
    public static List<wrapperIniziativeMarketing> getIniziativeMarketing() {
        List<wrapperIniziativeMarketing> response = new List<wrapperIniziativeMarketing>();
       try {
			List<Iniziative_Marketing__c> listaIniziative = [select id,Name,Versione__c,Attiva__c,Tipologia_di_iniziative__c, Visibilita_nel_centro_notifiche__c,
            Invio_push__c,Communication_code__c,Entita_SFDC_di_riferimento__c,Canale__c, Titolo__c, Message__c,Eligibile_per_Compagnia__c,
            Tipologia_Campagna__c                                                             
            from Iniziative_Marketing__c 
            where Attiva__c=true 
            order by LastModifiedDate desc limit 200 ];

            for(Iniziative_Marketing__c temp : listaIniziative){
            response.add(popolaWrapper(temp));
            }
            return response;
        } catch (Exception error) {

            wrapperIniziativeMarketing ErrorWrapper = new wrapperIniziativeMarketing();
            ErrorWrapper.Messagio = 'ERRORE custom view '+error.getStackTraceString();
            response.add(ErrorWrapper);
            return response;
        }
    }
    /**
     * @description    attivare o deactivare templates, il trigger-flow si incarica di non avere 2 stesso code
     * @param idsSelect  String con tutti ids selezionati in FrontEnd
     * @return          `String`
     */
    @AuraEnabled
    public static String setIniziativeMarketingAttiveDesattive(String idsSelect){

        List<String> listaIds = new List<String>();
        listaIds.addAll(idsSelect.split(';'));
   
        List<Iniziative_Marketing__c> listaIniziative = [select id,Name,Versione__c,Attiva__c,Tipologia_di_iniziative__c, Visibilita_nel_centro_notifiche__c,
            Invio_push__c,Communication_code__c,Entita_SFDC_di_riferimento__c,Canale__c, Titolo__c, Message__c, Tipologia_Campagna__c                                                        
            from Iniziative_Marketing__c where id in :listaIds    ];

        for(Iniziative_Marketing__c iniziatiTemp : listaIniziative){
            if(iniziatiTemp.Attiva__c){
                iniziatiTemp.Attiva__c = false;
            }else {
                iniziatiTemp.Attiva__c = true ;
            }
        }

        Database.SaveResult[] drList = Database.update(listaIniziative,false);
        String messaggio = '';
        integer contadorAggiornati=0,contadorNonAggiornati=0;
        for(Database.SaveResult result : drList) {
            if(result.isSuccess()){
                contadorAggiornati++;
            }       
            else {
               system.debug('Error Updating for --'+System.UserInfo.getName()+'-Profilo-'+System.UserInfo.getProfileId());
               contadorNonAggiornati++;
            }
        }
        if(contadorAggiornati>0 && contadorNonAggiornati==0)
        messaggio = 'L\'Iniziativa Marketing è stata modificata correttamente';
        else if (contadorAggiornati>0 && contadorNonAggiornati>0)
        messaggio = 'Sono state modificate correctamente '+contadorAggiornati + ', non modificate '+contadorNonAggiornati;
        else if (contadorAggiornati==0 && contadorNonAggiornati > 0)
        messaggio = 'ERRORE custom view, nessuna modificata correttamente ';
        
        return messaggio;
    }
    /**
     * @description             metodo principale per popolare il view dopo un filtro X    
     * @param tipologiaSelect 
     * @param perCanale       
     * @param attivaCheck     
     * @return                `List<wrapperIniziativeMarketing>`
     */
    @AuraEnabled
    public static List<wrapperIniziativeMarketing> getIniziativeMarketingFilterAll(String tipologiaSelect, String perCanale ,String attivaCheck){
       
        List<wrapperIniziativeMarketing> response = new List<wrapperIniziativeMarketing>();
        String whereCondition = ' where id != null';
        String filtroTipologia= '',filtroPerCanale= '',filtroCheckBoxs= '';

        Boolean attivaBoolean = Boolean.valueOf(attivaCheck);

        try {
        
            if(tipologiaSelect!= 'None')
                filtroTipologia = ' and Tipologia_Campagna__c =:tipologiaSelect  ';

            if(perCanale != 'None')
                filtroPerCanale= ' and Canale__c =:perCanale  ';

            filtroCheckBoxs = ' and Attiva__c =:attivaBoolean ';

            String query = 'Select id,Name,Versione__c,Attiva__c,Tipologia_di_iniziative__c, Visibilita_nel_centro_notifiche__c, Invio_push__c,Communication_code__c,Entita_SFDC_di_riferimento__c,Canale__c, Titolo__c, Message__c,Eligibile_per_Compagnia__c,'
            +'Tipologia_Campagna__c '
            +' from Iniziative_Marketing__c';

            String orderby = ' order by LastModifiedDate desc';
           
            List<Iniziative_Marketing__c> listaIniziative  = Database.query( query +  whereCondition + filtroTipologia +filtroPerCanale+filtroCheckBoxs+orderby ); // NOPMD false positive ApexSOQLInjection


            for(Iniziative_Marketing__c temp : listaIniziative){
            response.add(popolaWrapper(temp));
            }
            return response;

        } catch (Exception error) {
 
             wrapperIniziativeMarketing ErrorWrapper = new wrapperIniziativeMarketing();
             ErrorWrapper.Messagio = 'ERRORE custom view '+error.getStackTraceString();
             response.add(ErrorWrapper);
             return response;
         }
    }
    /**
     * @description wrapper per il campo specifico ID ed altri campi 
     * @param temp  
     * @return      `wrapperIniziativeMarketing`
     */       
    private static wrapperIniziativeMarketing popolaWrapper (Iniziative_Marketing__c temp){
        wrapperIniziativeMarketing nuovoWrapper = new wrapperIniziativeMarketing();
        nuovoWrapper.id = temp.id;
        nuovoWrapper.Name = temp.Name ;
        nuovoWrapper.Versione = String.valueOf(temp.Versione__c);
        nuovoWrapper.Attiva = temp.Attiva__c ;
        nuovoWrapper.CodeComunication = temp.Communication_code__c ;
        nuovoWrapper.TipologiaIniz = temp.Tipologia_di_iniziative__c ;
        nuovoWrapper.PerCompany = temp.Eligibile_per_Compagnia__c ;
        nuovoWrapper.EntitaRef = temp.Entita_SFDC_di_riferimento__c ;
        nuovoWrapper.InvioPush = temp.Invio_push__c ;
        nuovoWrapper.visibilitaCentroNotif = temp.Visibilita_nel_centro_notifiche__c ;
        nuovoWrapper.Url ='/lightning/r/Iniziative_Marketing__c/'+temp.id+'/view' ;
        //IDCRM 078 push notification Fase 2 nuovi campi nel wrapper
        nuovoWrapper.TipologiaCampagna = temp.Tipologia_Campagna__c;

        return nuovoWrapper;
    }
    /**
     * @description           ricerca in base ad una parola inserita per il campo CODE ella versione 2.0 fatta in PUSH 2
     * @param stringSearch    
     * @param tipologiaSelect 
     * @param perCanale       
     * @param attivaCheck     
     * @return                `List<wrapperIniziativeMarketing>`
     */    
    @AuraEnabled
    public static List<wrapperIniziativeMarketing> Search (String stringSearch,String tipologiaSelect, String perCanale ,String attivaCheck){

        List<wrapperIniziativeMarketing> response = new List<wrapperIniziativeMarketing>();
        String wildcardName = '%'+stringSearch+'%';
        String whereCondition = ' where id != null';
        String filtroTipologia= '',filtroPerCanale= '',filtroCheckBoxs= '',filtroName='';

        Boolean attivaBoolean = Boolean.valueOf(attivaCheck);

        try {
        
            if(tipologiaSelect!= 'None')
                filtroTipologia = ' and Tipologia_di_iniziative__c =:tipologiaSelect  ';

            if(perCanale != 'None')
                filtroPerCanale= ' and Eligibile_per_Compagnia__c =:perCanale  ';

            filtroCheckBoxs = ' and Attiva__c =:attivaBoolean ';

            filtroName = ' and Communication_code__c like:wildcardName ';

            String query = 'Select id,Name,Versione__c,Attiva__c,Tipologia_di_iniziative__c, Visibilita_nel_centro_notifiche__c, Invio_push__c,Communication_code__c,Entita_SFDC_di_riferimento__c,Canale__c, Titolo__c, Message__c,Eligibile_per_Compagnia__c,'
            +'Tipologia_Campagna__c '
            +' from Iniziative_Marketing__c ';

            String orderby = ' order by LastModifiedDate desc';

            List<Iniziative_Marketing__c> listaIniziative  = Database.query( query +  whereCondition + filtroTipologia +filtroPerCanale+filtroCheckBoxs+filtroName+orderby ); // NOPMD false positive ApexSOQLInjection

            for(Iniziative_Marketing__c temp : listaIniziative){
                response.add(popolaWrapper(temp));
            }
            return response;

        } catch (Exception error) {
 
             wrapperIniziativeMarketing ErrorWrapper = new wrapperIniziativeMarketing();
             ErrorWrapper.Messagio = 'ERRORE custom view '+error.getStackTraceString();
             response.add(ErrorWrapper);
             return response;
         }
    }


}