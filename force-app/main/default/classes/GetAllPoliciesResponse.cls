/*------------------------------------------------------------------------------------------
Author:        Francesca Marchese
Company:       Deloitte
Class:         IE_GetAllPolicies
Description:   Apex class used to execute all the logics internal to the 
rest Callout related to Caring Angel

History

26/9/2018     Created 
-------------------------------------------------------------------------------------------*/
public class GetAllPoliciesResponse {
		
		/* campi a video */
		/** PURE IT CLASSE COMMENTATA
		@AuraEnabled public String publicId;
		@AuraEnabled public String commercialType;
		@AuraEnabled public String effectiveDate;	
		@AuraEnabled public String expirationDate;
		@AuraEnabled public String productName;
		@AuraEnabled public String dataSource;
		@AuraEnabled public String statusCode;
		@AuraEnabled public String make;
		@AuraEnabled public String model;
		@AuraEnabled public String licensePlate;
		@AuraEnabled public String decodedPolicyId;
		@AuraEnabled public Boolean isCollective;//MOSCATELLI_M 18/03/2019: AXA Assistance
		PURE IT CLASSE COMMENTATA */
		/* campi a video */
/** PURE IT CLASSE COMMENTATA
		@AuraEnabled public String policyId;	//000001-002901-000005-066657087 Compagnia-Agenzia-Ramo-NumeroPolizza
		@AuraEnabled public cls_commercialTypes[] commercialTypes; //The commercial type(s) of the policy, AKA its business line. A policy can have several ones if it is based on a mixed product
		@AuraEnabled public cls_commonData commonData; //Data common to all policy commercial types
		@AuraEnabled public cls_insuredVehicle insuredVehicle; //Data of the insured vehicle
		@AuraEnabled public cls_insuredRealPropertyResume insuredRealPropertyResume; //Resume information on the insured real property
		@AuraEnabled public cls_savingsAccountResume savingsAccountResume; //Resume information on the policy savings account
		@AuraEnabled public cls_links[] links; //Information about the policy referrals 
	
	
	public class cls_commercialTypes {
		@AuraEnabled public String code;	//A global type code for the commercial label
		@AuraEnabled public String name;	//Localized name of the commercial label
	}
	public class cls_commonData {
		@AuraEnabled public String publicId;	//Identifier of an insurance policy communicated to the customer: the one to show on a digital application
		@AuraEnabled public String statusCode; //['IN_FORCE' or 'TERMINATED' or 'CANCELLED' or 'SUSPENDED']: The policy status code
		@AuraEnabled public String statusName; //Status Description: [Polizza valida]
		@AuraEnabled public String effectiveDate; //??? Date of effectiveness in case of renewal?
		@AuraEnabled public String initialEffectiveDate;	//The date on which the policy coverage have taken effect for the first time
		@AuraEnabled public String endCoverageDate; //???
		@AuraEnabled public String expirationDate; //The date on which the policy coverage stops
		@AuraEnabled public String expirationDescription; //Reason the policy expired [DISDETTA DATA DAL CONTRAENTE]
		@AuraEnabled public String productId; //Product code
		@AuraEnabled public String productName;	//Product name
		@AuraEnabled public String accountManagerId;	//Identifier of the customer advisor managing the policy (AgencyCode)
		@AuraEnabled public String formulaName; //Commercial name of a bundle of coverages and coverages restrictions proposed by the product and chosen by the customer on the policy
		@AuraEnabled public cls_policyCommonDataMetadata policyCommonDataMetadata; //The policy metadata information
	}
	public class cls_policyCommonDataMetadata {
		@AuraEnabled public String dataSource; //The system where the data comes from = [‘AAI’, ‘AMPS’,’ICBPI’]
	}
	public class cls_links {
		@AuraEnabled public String rel; //Type of infos
		@AuraEnabled public String uri;	//relative policy 000001-002901-000005-066657087 Compagnia-Agenzia-Ramo-NumeroPolizza
		@AuraEnabled public String method; //HTTP Method
	}
	public class cls_insuredVehicle {
		@AuraEnabled public String make;	//Brand
		@AuraEnabled public String model; //Model
		@AuraEnabled public cls_registration registration; //The vehicle registration information
	}
	public class cls_registration {
		@AuraEnabled public String id; //The registration identifier assigned by the registration authority
		@AuraEnabled public String typeName;	//The localized name of the type of registration
		@AuraEnabled public String typeCode;	//ci sono o no??? 
		@AuraEnabled public String startDate; //ci sono o no??? 	
	}
	public class cls_insuredRealPropertyResume {
		@AuraEnabled public String unstructuredGeographicalAddress;	//Free text describing the insured real estate property address.
	}
	public class cls_savingsAccountResume {
		@AuraEnabled public cls_netAmount netAmount;
	}
	public class cls_netAmount {
		@AuraEnabled public String currencyCode;	//
		@AuraEnabled public Double value; //
		//public Datetime dateTime; //
	}
	PURE IT CLASSE COMMENTATA */
	 /*Gestione errori*/
	 /** PURE IT CLASSE COMMENTATA
    @AuraEnabled public String code;					//Codice d’errore
	@AuraEnabled public String developerMessage;		//Messaggio di errore tecnico utile agli sviluppatori. 
    @AuraEnabled public String userMessage;				//Un messaggio user-friendly che dovrebbe essere mostrato direttamente all’utente
    @AuraEnabled public String maintenanceEndDate;		//La data di fine programmata in caso di manutenzione API
    @AuraEnabled public cls_ErrorDetail[] errors;		//Dettaglio sull’errore

    public class cls_ErrorDetail {
    	@AuraEnabled public String location;			//La posizione dell’errore. Ad esempio, in caso di errore di validazione può essere il nome di un campo
    	@AuraEnabled public String message;				//Un messaggio user-friendly che dovrebbe essere mostrato direttamente all’utente
    }
	 PURE IT CLASSE COMMENTATA */
    /*Gestione errori*/
	/** PURE IT CLASSE COMMENTATA
	public static GetAllPoliciesResponse parse(String json){
		return (GetAllPoliciesResponse) System.JSON.deserialize(json, GetAllPoliciesResponse.class);
	}

	public static List<GetAllPoliciesResponse> parseList(String json){
		return (List<GetAllPoliciesResponse>) System.JSON.deserialize(json, List<GetAllPoliciesResponse>.class);
	}
	PURE IT CLASSE COMMENTATA */
}