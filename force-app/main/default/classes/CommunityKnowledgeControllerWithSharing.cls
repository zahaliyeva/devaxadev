public with sharing class CommunityKnowledgeControllerWithSharing {


	@AuraEnabled
	public static List<Account> searchClient(String clientName){
		List<List<SObject>> searchList = [ FIND :clientName	IN Name Fields	RETURNING Account(Id, Name WHERE RecordType.DeveloperName in ('B2B_Client', 'B2C_Client'))];		
		return (Account[])searchList[0];
	}

	@AuraEnabled
	public static List<InsurancePolicy__c> searchInsurancePolicy(String searchString){
		List<List<SObject>> searchList = [ FIND :searchString	IN Name Fields	RETURNING InsurancePolicy__c(Id, Name)];	
		return (InsurancePolicy__c[])searchList[0];
	}

	@AuraEnabled
	public static List<Account> searchClientByNDG(String ndg){	
		return [Select Id , Name from Account WHERE NDG__c = :ndg LIMIT 1];
	}

	@AuraEnabled
	public static List<InsurancePolicy__c> searchPolicyByName(String name){	
		return [Select Id , Name from InsurancePolicy__c WHERE Name = :name LIMIT 1];
	}



}