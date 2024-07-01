public abstract  with sharing class MobilityResponse {

	@AuraEnabled public Boolean isSuccess = false;
	@AuraEnabled public String errorMessage;

}