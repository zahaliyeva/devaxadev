public with sharing class GoodFactorsCtrl {

	public String apexQuotazioneId{get;set;}

	public GoodFactorsCtrl(ApexPages.StandardController stdController) {
		apexQuotazioneId = ApexPages.currentPage().getParameters().get('id');
	}
	
	@AuraEnabled
	public static List<Map<String, String>> getDataComplete(String recordId){

		System.debug(' ===> input: ' + recordId);

		List<Map<String, String>> ret = new List<Map<String, String>>();
		String apexGoodFactorsStr = [SELECT Good_Factors__c FROM Quotazione__c WHERE Id = :recordId LIMIT 1].Good_Factors__c;
		List<GoodFactorsWrapper> apexGoodFactors = (List<GoodFactorsWrapper>)JSON.deserialize(apexGoodFactorsStr,List<GoodFactorsWrapper>.class);

		for(GoodFactorsWrapper gf : apexGoodFactors){
			System.debug(' ===> input gf: ' + gf);
			Map<String, String> mapFactors = new Map<String, String>();
			mapFactors.put('Name', gf.Name);
			mapFactors.put('Value', gf.Value);
			ret.add(mapFactors);
		}

		System.debug(' ===> output: ' + ret);

		return ret;
	}

	public class GoodFactorsWrapper{
		@AuraEnabled
		public String Name;

		@AuraEnabled
		public String Value;
	}
}