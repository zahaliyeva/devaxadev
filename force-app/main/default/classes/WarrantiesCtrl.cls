public with sharing class WarrantiesCtrl {

	public String apexQuotazioneId{get;set;}

	public WarrantiesCtrl(ApexPages.StandardController stdController) {
		apexQuotazioneId = ApexPages.currentPage().getParameters().get('id');
	}

	@AuraEnabled
	public static List<Map<String, String>> getDataComplete(String recordId){

		System.debug(' ===> input: ' + recordId);

		List<Map<String, String>> ret = new List<Map<String, String>>();
		String apexWarrentiesStr = [SELECT Warranties__c FROM Quotazione__c WHERE Id = :recordId LIMIT 1].Warranties__c;
		List<WarrantiesWrapper> apexWarranties = (List<WarrantiesWrapper>)JSON.deserialize(apexWarrentiesStr,List<WarrantiesWrapper>.class);

		for(WarrantiesWrapper w : apexWarranties){
			System.debug(' ===> input w: ' + w);
			Map<String, String> mapWarranties = new Map<String, String>();
			mapWarranties.put('Name', w.Name);
			mapWarranties.put('Limits', w.Limits);
			mapWarranties.put('Exemption', w.Exemption);
			mapWarranties.put('InsuredQuantity', w.InsuredQuantity);
			mapWarranties.put('Price', w.Price);
			mapWarranties.put('OriginalPrice', w.OriginalPrice);
			ret.add(mapWarranties);
		}

		System.debug(' ===> output: ' + ret);

		return ret;
	}

	public class WarrantiesWrapper{
		@AuraEnabled
		public String Name;

		@AuraEnabled
		public String Limits;

		@AuraEnabled
		public String Exemption;

		@AuraEnabled
		public String InsuredQuantity;

		@AuraEnabled
		public String Price;

		@AuraEnabled
		public String OriginalPrice;
	}
}