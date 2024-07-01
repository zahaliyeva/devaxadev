/** 
* @description mobilitySinglePushWrapper class
*/
public without sharing class mobilitySinglePushWrapper {

    /** 
    * @description mobilitySinglePushWrapper constructor
    */
    public mobilitySinglePushWrapper(){

    }

    /** WrapperChisura
    * @description mobilitySinglePushWrapper.privacyDetailWrapper class
    */
    public class privacyDetailWrapper {

        /** 
         * @description mobilitySinglePushWrapper.privacyDetailWrapper.id field 
         */
        public Integer id;
        /** 
         * @description mobilitySinglePushWrapper.privacyDetailWrapper.privacyType field  
         */
		public String privacyType;
        /** 
         * @description mobilitySinglePushWrapper.privacyDetailWrapper.privacyStatus field  
         */
		public String privacyStatus;
        /** 
         * @description mobilitySinglePushWrapper.privacyDetailWrapper.certificationStatus field  
         */
		public String certificationStatus;

    }

    /** 
    * @description mobilitySinglePushWrapper.emailContactDetailWrapper class
    */
    public class emailContactDetailWrapper {

        /**
         *  @description mobilitySinglePushWrapper.emailContactDetailWrapper.text field  
         */
        public String text;
        /** 
         * @description mobilitySinglePushWrapper.emailContactDetailWrapper.emailContactType field  
         */
		public String emailContactType;
        /** 
         * @description mobilitySinglePushWrapper.emailContactDetailWrapper.emailContactValidation field  
         */
		public String emailContactValidation;

    }

    //defining attributes
    /**
     * @description privacyDetails field  
     */
    public List<privacyDetailWrapper> privacyDetails;
    /**
     *  @description emailContactDetails field  
     */
    public emailContactDetailWrapper emailContactDetails;
    /** 
     * @description fiscalCode field  
     */
    public String fiscalCode;
    /**
     *  @description ndg field  
     */
    public String ndg;
    /** 
     * @description validDocumentUploaded field  
     */
    public String validDocumentUploaded;

    /** 
     * @description getPrivacy_Promoziona method  
     * @return 'String'
     */
    public String getPrivacy_Promoziona(){
        for(privacyDetailWrapper item:this.privacyDetails){
            if(item.privacyType==getType()){
                if(item.certificationStatus=='Y')
                return item.privacyStatus=='Y'? getSi(): getNo();
            }
        }
        return getNo();
    }

    /** 
     * @description getEmail_Validation method  
     * @return 'String'
     */
    public String getEmail_Validation(){
        String value= this.emailContactDetails.emailContactValidation;
        return value=='Y'? getSi(): getNo();
    }

    /** 
     * @description getNo method  
     * @return 'String'
     */
    public String getNo(){
        return '(\'' + 'No' + '\'';
    }

    /** 
     * @description getSi method  
     * @return 'String'
     */
    public String getSi(){
        return '(\'' + 'Si' + '\'';
    }

    /** 
     * @description getType method
     * @return 'String'
     */
    public String getType(){
        return 'PROMOTIONAL_SALES_ACTIVITIES';
    }
    /** 
     * @description getType method
     * @return 'String'
     */
    public String getDocStatus(){
        return this.validDocumentUploaded == 'Y' ? getSi() : getNo();
    }
	/** 
     * @description checkEmail method
     * @return 'boolean'
     */
    public boolean checkEmail(){
        if(this.emailContactDetails == null) return false;
        if(this.emailContactDetails.text == null) return false;
        return true;
    }
    /**
     * @description                per fitro scheda invio singolo , filtro No.6 su stop carta
     * @param cifPrivacy5          campo Account 
     * @param certificaCifPrivacy5 campo Account
     * @return                     `String`
     */
    public String getSiOrNoCertificato (String cifPrivacy5,String certificaCifPrivacy5){
        if(cifPrivacy5=='Sì'){ 
            if(certificaCifPrivacy5=='Sì'){
                return getSi();
            }else{
                return '(\''+'NULLA'+'\''; // il si non certificato è blank o value non essitente 
            }
        }else 
            return getNo();
    }
}