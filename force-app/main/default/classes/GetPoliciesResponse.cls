/*------------------------------------------------------------------------------------------
   Author:        Daniela Pirelli
   Company:       Reply
   Class:         GetPoliciesResponse
   Description:   Apex class used to execute all the logics internal to the
   rest Callout related to Caring Salute

   History

   03/03/2020     Created
   -------------------------------------------------------------------------------------------*/
public class GetPoliciesResponse {


    /* campi a video */
    @AuraEnabled public String policyId;
	@AuraEnabled public String publicId;
	@AuraEnabled public String effectiveDate;
	@AuraEnabled public String expirationDate;
	@AuraEnabled public String productName;
	@AuraEnabled public String statusCode;
	@AuraEnabled public String policyIdSOl;
	@AuraEnabled public String numApplicazione;
	@AuraEnabled public String companyCode;
	@AuraEnabled public String assetDescription;
	@AuraEnabled public String licensePlate;
	/* campi a video */


	@AuraEnabled public cls_assets [] assets;
	@AuraEnabled public cls_commonData commonData;
	@AuraEnabled public String idAdhesion;
    //@AuraEnabled public String number;
    @AuraEnabled public String idPolicy;
	@AuraEnabled public String portfolio;

	public class cls_assets {
		@AuraEnabled public String address;
		@AuraEnabled public String assetDescription;
		@AuraEnabled public String assetKey;
		@AuraEnabled public String country;
		@AuraEnabled public String countryCode;
		@AuraEnabled public cls_coverages[] coverages;
		@AuraEnabled public String idAsset;
		@AuraEnabled public String idSummary;
		@AuraEnabled public String insuredAssetDescription;
		@AuraEnabled public String insuredBirthDate;
		@AuraEnabled public String insuredCountry;
		@AuraEnabled public String insuredFiscalCode;
		@AuraEnabled public String insuredHouseHolder;
		@AuraEnabled public String insuredVatNumber;
		@AuraEnabled public String latitude;
		@AuraEnabled public String licensePlate;
		@AuraEnabled public String longitude;
		@AuraEnabled public String placeAddress;
		@AuraEnabled public String province;
		@AuraEnabled public String town;
		@AuraEnabled public String zipCode;
	}

	public class cls_commonData {
		@AuraEnabled public String branchCode;
		@AuraEnabled public String companyCode;
		@AuraEnabled public String mainPolicy;
		@AuraEnabled public String mattoncinoVersion;
		@AuraEnabled public String name;
		@AuraEnabled public String nodeCode;
		@AuraEnabled public String personId;
		@AuraEnabled public String policyEffectDate;
		@AuraEnabled public String policyEndDate;
		@AuraEnabled public String productCode;
		@AuraEnabled public String productName;
		@AuraEnabled public String productVersion;
		@AuraEnabled public String statusCode;
		@AuraEnabled public String surname;
		@AuraEnabled public String type;
		@AuraEnabled public String ndg;

	}

	public class cls_coverages {
		@AuraEnabled public String baseCoverage;
		@AuraEnabled public String specificCoverage;
		@AuraEnabled public String descAssurance;
	}

	/*Gestione errori*/
	@AuraEnabled public String code;                        //Codice d’errore
	@AuraEnabled public String developerMessage;            //Messaggio di errore tecnico utile agli sviluppatori.
	@AuraEnabled public String userMessage;                     //Un messaggio user-friendly che dovrebbe essere mostrato direttamente all’utente
	@AuraEnabled public String maintenanceEndDate;          //La data di fine programmata in caso di manutenzione API
	@AuraEnabled public cls_ErrorDetail[] errors;           //Dettaglio sull’errore

	public class cls_ErrorDetail {
		@AuraEnabled public String location;                //La posizione dell’errore. Ad esempio, in caso di errore di validazione può essere il nome di un campo
		@AuraEnabled public String message;                     //Un messaggio user-friendly che dovrebbe essere mostrato direttamente all’utente
	}
	/*Gestione errori*/

	public static GetPoliciesResponse parse(String json){
		return (GetPoliciesResponse) System.JSON.deserialize(json, GetPoliciesResponse.class);
	}

	public static List<GetPoliciesResponse> parseList(String json){
		return (List<GetPoliciesResponse>) System.JSON.deserialize(json, List<GetPoliciesResponse>.class);
	}


}