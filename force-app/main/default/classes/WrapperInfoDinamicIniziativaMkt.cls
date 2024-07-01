/**
 * @description wrapper per info nella iniziativa. tutti campi dinamici devono prendere un valore
 * @author      reply
 * @since       26/07/2023
 */
public with sharing class WrapperInfoDinamicIniziativaMkt {

    public String Nome ;
    public String MobilePhone ;
    public String Email ;
    public String NumeroDocumento ;
    public String TipoDocumento ;
    public String AgencyHolder ;
    public String AgencyCode ;
    public String AgencyName ;
    public String AgencyEmail ;
    public String AgencyPhone ;
    // wrapper chiusura
    public String chiusoAl ;
    public String chiusoDal ;
    // wrapper cambiOrari
    public String validoAl ;
    public String validoDal ;
    // placeHolder x MC
    public static String MC_INIZIO = '%%MC_inizio%%';
    public static String MC_FINE = '%%MC_fine%%';

    public MobilityCampaignsByPushNotification.WrapperCambiOrari cambiOrari;

    public static Map<String,String> MappingPlaceHolders = new  Map<String,String> ();
    /**
     * @description   
     * @param account input per Account on comunication to customer posibile push1
     */
    public WrapperInfoDinamicIniziativaMkt(Account account) {
        this.Nome = account.Name;
        this.MobilePhone =String.isBlank(account.Mobile_Master_AAI__c )? ' ' :account.Mobile_Master_AAI__c ;// controllare altri numeri d telefono
        this.Email  = String.isBlank(account.Email_Master_AAI__c )? ' ' :account.Email_Master_AAI__c ;
        this.NumeroDocumento = String.isBlank(account.CIF_Number__c )? ' ' :account.CIF_Number__c ;
        this.TipoDocumento = String.isBlank(account.CIF_Document_type__c )? ' ' :account.CIF_Document_type__c ;
        this.AgencyHolder = String.isBlank(account.AAI_Agency__r.Agency_Holder__c)? ' ' :account.AAI_Agency__r.Agency_Holder__c; 
        this.AgencyCode  = String.isBlank(account.AAI_Agency__r.Agency_Code__c)? ' ' :account.AAI_Agency__r.Agency_Code__c; 
        this.AgencyName = String.isBlank(account.AAI_Agency__r.Name)? ' ' :account.AAI_Agency__r.Name; 
        this.AgencyEmail = String.isBlank(account.AAI_Agency__r.Agency_email__c)? ' ' :account.AAI_Agency__r.Agency_email__c; 
        this.AgencyPhone = String.isBlank(account.AAI_Agency__r.MobilePhone__c)? ' ' :account.AAI_Agency__r.MobilePhone__c;

        this.popolareMapping();
    }
    /**
     * @description      per push2 per comunication nella creazione da campgna MobilityCampaignsByPushNotification
     * @param account    account input
     * @param chisura    nel caso la iniziativa e di tipo chiusura
     * @param cambiOrari nel caso la iniziativa e di tipo cambioOrari
     */
    public WrapperInfoDinamicIniziativaMkt(MobilityCampaignsByPushNotification.WrapperRequest account,
    MobilityCampaignsByPushNotification.WrapperChisura chisura,
    MobilityCampaignsByPushNotification.WrapperCambiOrari cambiOrari) {
        this.Nome = account.Name;
        this.MobilePhone = String.isBlank(account.MobileMasterAAI)?'':account.MobileMasterAAI;
        this.Email = String.isBlank(account.EmailMasterAAI)?'': account.EmailMasterAAI;
        this.NumeroDocumento = String.isBlank(account.CIFNumber)?'':account.CIFNumber;
        this.TipoDocumento = String.isBlank(account.CIFDocumenttype)?'':account.CIFDocumenttype;
        this.AgencyHolder = String.isBlank(account.AgencyHolder)?'':account.AgencyHolder;
        this.AgencyCode = String.isBlank(account.AgencyCode)?'':account.AgencyCode;
        this.AgencyName = String.isBlank(account.AgencyCode)?'':account.AgencyCode;
        this.AgencyEmail = String.isBlank(account.AgencyEmail)?'':account.AgencyEmail;
        this.AgencyPhone = String.isBlank(account.AgencyMobilePhone)?'': account.AgencyMobilePhone;
        // wrapper chiusura
        if(chisura!=null){      
            this.chiusoAl = chisura.chiusoAl.split('T')[0];
            this.chiusoDal  = chisura.chiusoDal.split('T')[0];
        }
        // wrapper cambiOrari
        if(cambiOrari!=null){
            this.validoAl = cambiOrari.validoAl.split('T')[0];
            this.validoDal  = cambiOrari.validoDal.split('T')[0]; 
            this.cambiOrari = cambiOrari;    
        }
        this.popolareMapping();
    }
    /**
     * @description   per push2 per comunication nella creazione invio singolo da scheda cliente
     * @param account account trovato dal NDG pasato da NFE rgi nel json , passa per un mapping del wrapper
     */
    public WrapperInfoDinamicIniziativaMkt(MobilityCampaignsByPushNotification.WrapperRequest account) {
        this.Nome = account.Name;
        this.MobilePhone = String.isBlank(account.MobileMasterAAI)?'':account.MobileMasterAAI;
        this.Email = String.isBlank(account.EmailMasterAAI)?'': account.EmailMasterAAI;
        this.NumeroDocumento = String.isBlank(account.CIFNumber)?'':account.CIFNumber;
        this.TipoDocumento = String.isBlank(account.CIFDocumenttype)?'':account.CIFDocumenttype;
        this.AgencyHolder = String.isBlank(account.AgencyHolder)?'':account.AgencyHolder;
        this.AgencyCode = String.isBlank(account.AgencyCode)?'':account.AgencyCode;
        this.AgencyName = String.isBlank(account.AgencyCode)?'':account.AgencyCode;
        this.AgencyEmail = String.isBlank(account.AgencyEmail)?'':account.AgencyEmail;
        this.AgencyPhone = String.isBlank(account.AgencyMobilePhone)?'': account.AgencyMobilePhone;
        // wrapper chiusura
        this.chiusoAl =null;
        this.chiusoDal =null;
        // wrapper cambiOrari
        this.validoAl =null;
        this.validoDal =null;
        this.cambiOrari = null;
        //popolamap
        this.popolareMapping();
    }
    /**
     * @description converte una TEXTO con place holder a un texto finale i place holder devono avere lo stesso nome nel mappa
     * @param line  riga di testo con places holders
     * @return      `String`
     */
    public String dinamicFieldsTemplate(String line){
        String wordFill = '';
        for (String key :MappingPlaceHolders.keySet()) {
            if(line!= null && MappingPlaceHolders.get(key)!=null && MappingPlaceHolders.containsKey(key)){
                wordFill = line.replaceAll(key, MappingPlaceHolders.get(key)); 
                line = wordFill;
            }

        }
        return wordFill;
    }
    /**
     * @description popolareMapping
     */
    private void popolareMapping(){

        MappingPlaceHolders.put('%%Nome%%', this.Nome);
        MappingPlaceHolders.put('%%MobilePhone%%', this.MobilePhone);
        MappingPlaceHolders.put('%%Email%%', this.Email);
        MappingPlaceHolders.put('%%NumeroDocumento%%', this.NumeroDocumento);
        MappingPlaceHolders.put('%%TipoDocumento%%', this.TipoDocumento);
        MappingPlaceHolders.put('%%AgencyHolder%%', this.AgencyHolder);
        MappingPlaceHolders.put('%%AgencyCode%%', this.AgencyCode);
        MappingPlaceHolders.put('%%AgencyName%%', this.AgencyName);
        MappingPlaceHolders.put('%%AgencyEmail%%', this.AgencyEmail);
        MappingPlaceHolders.put('%%AgencyPhone%%', this.AgencyPhone);
        //chiusura 
        if(this.chiusoAl!= null && this.chiusoDal!= null){
            MappingPlaceHolders.put('%%chiusoAl%%',converDateFormat(this.chiusoAl));
            MappingPlaceHolders.put('%%chiusoDal%%', converDateFormat(this.chiusoDal));
        }
        //cambi orari
        if(this.cambiOrari!= null){
            for (MobilityCampaignsByPushNotification.WrapperDay day : this.cambiOrari.getlistDays()) {      
                MappingPlaceHolders.put('%%'+day.name+'_inizio1%%', day.dal1);
                MappingPlaceHolders.put('%%'+day.name+'_fine1%%', day.al1);
                MappingPlaceHolders.put('%%'+day.name+'_inizio2%%', day.dal2);
                MappingPlaceHolders.put('%%'+day.name+'_fine2%%', day.al2);
                MappingPlaceHolders.put('%%'+day.name+'_chiuso%%', day.isClosed==true ? 'chiuso':'');
            }
            MappingPlaceHolders.put('%%data_inizio%%',converDateFormat( this.validoDal));
            MappingPlaceHolders.put('%%data_fine%%',converDateFormat( this.validoAl));
        }
    }
    /**
     * @description        converDateFormat
     * @param dateUnformat 
     * @return             `String`
     */
    private String converDateFormat(String dateUnformat){
        try {
            Date tempUnformat =  date.valueOf(dateUnformat);
            return tempUnformat.format();
        } catch (Exception ex) {
            return null;
        }
    }
    /**
     * @description substringBetweenMarketingCloud place holders on template
     * @param line  
     * @return      `List<String>`
     */
    public static List<String> substringBetweenMarketingCloud(String line){
        List<String> response = new List<String>() ;
        if(line.containsIgnoreCase('/ ')){
            line = line.replaceAll('/ ', '');
        }
        String responseTempMC = '';
        //modificare per gestire la n
        if(line!=null && String.isNotBlank(line)){
            if(line.containsIgnoreCase('\r\n')){
                responseTempMC = line.substringBetween(MC_INIZIO, MC_FINE).replaceAll('\r\n', '\\\\r\\\\n');
            }else if(line.containsIgnoreCase('\n')) {
                responseTempMC = line.substringBetween(MC_INIZIO, MC_FINE).replaceAll('\n', '\\\\r\\\\n');
            } else if(line.containsIgnoreCase('\r')) {
                responseTempMC = line.substringBetween(MC_INIZIO, MC_FINE).replaceAll('\r', '\\\\r\\\\n');
            } else {
                responseTempMC = line.substringBetween(MC_INIZIO, MC_FINE);
            }
            String responseTempCRM = line.replaceAll(MC_INIZIO, ' ').replaceAll(MC_FINE, ' ');
            response.add(responseTempMC);
            response.add(responseTempCRM);
        }
        return response;
    }
}