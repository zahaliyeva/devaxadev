/**
 * @description DH Response Wrapper
 * @author Reply
 * @since 04/2023
 */
public class IE_DH_ResponseWrapper {
    /**
     * @description common data object wrapper
     */
    public class commonDataWrapper {
        public String productId;
        public String productNameSmall;
    }
    
    public commonDataWrapper commonData;
    /**
     * @description code : 500 Internal Server Error , T300 The requested item does not exist
     */
    public String code ; 
    /**
     * @description developerMessage messagio piccolo del errore 'Internal Server Error' or 'The requested item does not exist'
     */
    public String developerMessage ;
    /**
     * @description userMessage messagio meno tecnico sul errore - CODICE FISCALE is invalid
     */
    public String userMessage; 
    
}