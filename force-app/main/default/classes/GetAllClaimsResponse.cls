/*------------------------------------------------------------------------------------------
Author:        Orlando Aversano
Company:       Deloitte
Class:         GetAllClaimsResponse
Description:   Apex class used to execute all the logics internal to the 
rest Callout related to Caring Angel

History

27/9/2018     Created 
-------------------------------------------------------------------------------------------*/
public class GetAllClaimsResponse {
    
    
    @AuraEnabled public String Id;						//Identificativo del sinistro
    @AuraEnabled public List<String> policies;			//Lista degli identificativi delle polizze associate al sinistro 
    @AuraEnabled public String policyId; 				//OBSOLETO: Identificativo della polizza associata al sinistro
    @AuraEnabled public List<String> commercialTypeCodes;//I codici commerciali della polizza associata al sinistro
    @AuraEnabled public Datetime lossNotificationDate;	//La data di notifica del sinistro da parte del cliente
    @AuraEnabled public Datetime closureDate;			//La data di chiusura del sinistro (dal punto di vista del cliente)
    @AuraEnabled public Boolean openIndicator;			//Indica se il sinistro è aperto, dal punto di vista del cliente
    @AuraEnabled public String lossTypeName;			//Il tipo di sinistro
    @AuraEnabled public cls_HypermediaLink[] links;		//risorse Hypermedia
    @AuraEnabled public Boolean isPreDenunciation;		//Indica se si tratta di denuncia o predenuncia
    @AuraEnabled public String idCase;					//Id Case Caring Angel associato al sinistro
    @AuraEnabled public String claimNumber;				//progressivo pratica
    
    @AuraEnabled public String linkToSOL;				//link per visualizzare il sinistro su SOL
    @AuraEnabled public String linkToSFDC;				//link per visualizzare il case su SFDC
    
    /*Gestione errori*/
    @AuraEnabled public String code;					//Codice d’errore
	@AuraEnabled public String developerMessage;		//Messaggio di errore tecnico utile agli sviluppatori. 
    @AuraEnabled public String userMessage;				//Un messaggio user-friendly che dovrebbe essere mostrato direttamente all’utente
    @AuraEnabled public String maintenanceEndDate;		//La data di fine programmata in caso di manutenzione API
    @AuraEnabled public cls_ErrorDetail[] errors;		//Dettaglio sull’errore

    public class cls_ErrorDetail {
    	@AuraEnabled public String location;			//La posizione dell’errore. Ad esempio, in caso di errore di validazione può essere il nome di un campo
    	@AuraEnabled public String message;				//Un messaggio user-friendly che dovrebbe essere mostrato direttamente all’utente
    }
    /*Gestione errori*/
    
    public class cls_HypermediaLink {
        @AuraEnabled public String rel;					//Codice che descrive la risorsa Hypermedia
        @AuraEnabled public String uri;					//L’identificativo univoco della risorsa associata
        @AuraEnabled public String method;				//Il metodo HTTP da utilizzare per collegarsi all’ hypermedia link
    }
    
    public static GetAllClaimsResponse parse(String json){
        return (GetAllClaimsResponse) System.JSON.deserialize(json, GetAllClaimsResponse.class);
    }
    
    public static List<GetAllClaimsResponse> parseList(String json){
        return (List<GetAllClaimsResponse>) System.JSON.deserialize(json, List<GetAllClaimsResponse>.class);
    }
    
}