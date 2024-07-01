public class GetAllClaimsSOLResponse {
    
    @AuraEnabled public List<Claims> Claims;
	@AuraEnabled public List<Claims> IncompleteReports;
    

    
	 public class Policy {
		@AuraEnabled public String policyAgencyCode;
		@AuraEnabled public String policyNumber;
		@AuraEnabled public String branchCode;
		@AuraEnabled public String policyProgressive;
	}

	 public class PolicyHolder {
		@AuraEnabled public Integer policyHolderId;
		@AuraEnabled public ClaimCategory status;
		@AuraEnabled public String name;
		@AuraEnabled public String surnname;
	}

	 public class Claims {
        @AuraEnabled public String linkToSOL;				//link per visualizzare il sinistro su SOL
        @AuraEnabled public String linkToSFDC;				//link per visualizzare il case su SFDC
        @AuraEnabled public String policyId; 	
        @AuraEnabled public String lossNotificationDate;	//La data di notifica del sinistro da parte del cliente
        @AuraEnabled public String closureDate;		     	//La data di chiusura del sinistro (dal punto di vista del cliente)
        @AuraEnabled public Boolean openIndicator;			//Indica se il sinistro è aperto, dal punto di vista del cliente
        @AuraEnabled public String lossTypeName;
        @AuraEnabled public String Id;
         
		@AuraEnabled public String channel;
		@AuraEnabled public String claimNumber;
		@AuraEnabled public Integer claimId;
		@AuraEnabled public String claimNumberEfnol;
		@AuraEnabled public String fiscalYear;
		@AuraEnabled public Boolean isIncompleteClaim;
		@AuraEnabled public String idCase;
		@AuraEnabled public Policy policy;
		@AuraEnabled public String companyCode;
		@AuraEnabled public String companyDescription;
		@AuraEnabled public String agencyCode;
		@AuraEnabled public String agencySubCode;
		@AuraEnabled public String producerCode;
		@AuraEnabled public String productCode;
		@AuraEnabled public String productDescription;
		@AuraEnabled public String commercialTypeCode;
		@AuraEnabled public String plateNumber;
		@AuraEnabled public ClaimCategory claimCategory;
		@AuraEnabled public ClaimType claimType;
		@AuraEnabled public ClaimCategory claimDamageType;
		@AuraEnabled public String insuredAsset;
		@AuraEnabled public String claimEventDate;
		@AuraEnabled public String claimTimeEvent;
		@AuraEnabled public String claimNotificationDate;
		@AuraEnabled public String claimClosingDate;
		@AuraEnabled public ClaimEventPlace claimEventPlace;
		@AuraEnabled public ClaimState claimState;
		@AuraEnabled public ClaimType claimBaseCoverage;
		@AuraEnabled public ClaimType claimEvent;
		@AuraEnabled public ClaimType claimEventCategories;
		@AuraEnabled public PolicyHolder policyHolder;
		@AuraEnabled public List<Links> links;
	}

	public class IncompleteReports {
        @AuraEnabled public String linkToSOL;				//link per visualizzare il sinistro su SOL
        @AuraEnabled public String linkToSFDC;				//link per visualizzare il case su SFDC
        @AuraEnabled public String policyId; 	
        @AuraEnabled public String lossNotificationDate;	//La data di notifica del sinistro da parte del cliente
        @AuraEnabled public String closureDate;		     	//La data di chiusura del sinistro (dal punto di vista del cliente)
        @AuraEnabled public Boolean openIndicator;			//Indica se il sinistro è aperto, dal punto di vista del cliente
        @AuraEnabled public String lossTypeName;
        @AuraEnabled public String Id;
         
		@AuraEnabled public String channel;
		@AuraEnabled public String claimNumber;
		@AuraEnabled public Integer claimId;
		@AuraEnabled public String claimNumberEfnol;
		@AuraEnabled public String fiscalYear;
		@AuraEnabled public Boolean isIncompleteClaim;
		@AuraEnabled public String idCase;
		@AuraEnabled public Policy policy;
		@AuraEnabled public String companyCode;
		@AuraEnabled public String companyDescription;
		@AuraEnabled public String agencyCode;
		@AuraEnabled public String agencySubCode;
		@AuraEnabled public String producerCode;
		@AuraEnabled public String productCode;
		@AuraEnabled public String productDescription;
		@AuraEnabled public String commercialTypeCode;
		@AuraEnabled public String plateNumber;
		@AuraEnabled public ClaimCategory claimCategory;
		@AuraEnabled public ClaimType claimType;
		@AuraEnabled public ClaimCategory claimDamageType;
		@AuraEnabled public String insuredAsset;
		@AuraEnabled public String claimEventDate;
		@AuraEnabled public String claimTimeEvent;
		@AuraEnabled public String claimNotificationDate;
		@AuraEnabled public String claimClosingDate;
		@AuraEnabled public ClaimEventPlace claimEventPlace;
		@AuraEnabled public ClaimState claimState;
		@AuraEnabled public ClaimType claimBaseCoverage;
		@AuraEnabled public ClaimType claimEvent;
		@AuraEnabled public ClaimType claimEventCategories;
		@AuraEnabled public PolicyHolder policyHolder;
		@AuraEnabled public List<Links> links;
	}



   public class ClaimCategory {
		@AuraEnabled public Integer code;
		@AuraEnabled public String description;
	}

	public class Links {
		@AuraEnabled public String rel;
		@AuraEnabled public String self;
		@AuraEnabled public Method method;
	}

	public class ClaimState {
		@AuraEnabled public Integer code;
		@AuraEnabled public String description;
		@AuraEnabled public Boolean isOpen;
		@AuraEnabled public String currentStep;
	}

	public class Method {
		@AuraEnabled public String Method;
	}

    public class ClaimEventPlace {
		@AuraEnabled public String placeAddress;
		@AuraEnabled public String latitude;
		@AuraEnabled public String longitude;
		@AuraEnabled public String nation;
		@AuraEnabled public String province;
		@AuraEnabled public String city;
		@AuraEnabled public String zipCode;
		@AuraEnabled public String address;
	}

	 public class ClaimType {
		@AuraEnabled public String code;
		@AuraEnabled public String description;
	}
    
    public class Errors {
	@AuraEnabled public String status;
	@AuraEnabled	public String code;
	@AuraEnabled	public String title;
	@AuraEnabled	public String detail;
	@AuraEnabled	public String source;
	}

	@AuraEnabled public List<Errors> errors;
	@AuraEnabled public String result;
	@AuraEnabled public String status_response;

     public static GetAllClaimsSOLResponse parse(String json){
        return (GetAllClaimsSOLResponse) System.JSON.deserialize(json, GetAllClaimsSOLResponse.class);
    }
    
    public static List<GetAllClaimsSOLResponse> parseList(String json){
        return (List<GetAllClaimsSOLResponse>) System.JSON.deserialize(json, List<GetAllClaimsSOLResponse>.class);
    }
    
  
}