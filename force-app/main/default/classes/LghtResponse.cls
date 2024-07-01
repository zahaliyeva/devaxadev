public abstract with sharing class LghtResponse {

	@AuraEnabled public Boolean isSuccess = false;
	@AuraEnabled public String errorMessage;

}