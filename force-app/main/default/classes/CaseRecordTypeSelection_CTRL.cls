public with sharing class CaseRecordTypeSelection_CTRL 
{
	@AuraEnabled
	public static Map<String,String> getSelectableTypes()
	{
		Map<String,String> MapNameToId = new Map<String,String>();

		String CurrentUsrProfile = [Select Name from Profile where id=:Userinfo.getProfileId()].Name;

		CurrentUsrProfile = CurrentUsrProfile.replace(' ', '_');
        
		//OAVERSANO 17/06/2019 : fix scelta RT -- START
		//String sQuery='Select Key__c,Value__c from MPS_Code_Utils__mdt where DeveloperName like \''+CurrentUsrProfile+'_RecordTypeOptions%\'';
		String sQuery='Select DeveloperName,Key__c,Value__c from MPS_Code_Utils__mdt where DeveloperName like \''+CurrentUsrProfile+'_RecordTypeOptions%\' ORDER BY DeveloperName asc';
		//OAVERSANO 17/06/2019 : fix scelta RT -- END
        
		system.debug('sQuery: '+sQuery);
		
		for(MPS_Code_Utils__mdt MCu: Database.query(sQuery))
		{
			MapNameToId.put(MCu.Key__c,MCu.Value__c);
		}

	/*	for(RecordTypeInfo info: Case.SObjectType.getDescribe().getRecordTypeInfos()) 
		{
		    if(info.isAvailable()) 
		    {
		    	MapNameToId.put(info.getName(),info.getRecordTypeId());
		    }
		}*/

		return MapNameToId;
	}
}