/**  http://developer.force.com/cookbook/recipe/trigger-pattern-for-tidy-streamlined-bulkified-triggers

 * Class CampaignHandler

 *

 * Trigger Handler for the Campaign SObject. This class implements the ITrigger

 * interface to help ensure the trigger code is bulkified and all in one place.

 */

public with sharing class CampaignHandler

	implements ITrigger

{

	// Member variable to hold the Id's of Campaigns 'in use'

	private Set<Id> RecordsInUse = new Set<Id>();


	public final String objectShare = 'CampaignShare';
	public final String parentId = 'CampaignId';
	public final String rawCause = 'Manual';
	public final String accessLevelName = 'CampaignAccessLevel';
	public final String accessLevelvalue = 'Read'; //'None','Read','Edit','All'
	public final String separatorOfGroups = ';';
    public final String fieldNameOfGroup ='Main_Node__c';
    public static final String RECORD_TYPE_Informative_Campaign_PCC_MyAXA = 'Informative_Campaign_PCC_MyAXA';
	public final Id Marketing_RecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Marketing_campaign').getRecordTypeId();
	public final Id AXA_TECHNICAL_USER_ID = (AAI_Code_Variables__c.getAll()).get('AXA_TECHNICAL_USER_ID') != null ? (AAI_Code_Variables__c.getAll()).get('AXA_TECHNICAL_USER_ID').Value__c : UserInfo.getUserId();  

	public static boolean DeactivateTrigger = false;

	// Constructor

	public CampaignHandler()
	{

	}



	/**

	 * bulkBefore

	 *

	 * This method is called prior to execution of a BEFORE trigger. Use this to cache

	 * any data required into maps prior execution of the trigger.

	 */

	public void bulkBefore()
	{

	}



	public void bulkAfter()
	{

	}



	public void beforeInsert(SObject so)
	{

	}

	public void beforeInsert(List<SObject> soList)
	{

		List<Campaign> rList = (List<Campaign>) soList;            
        
        for(Campaign a : rList)
        {
            
            
			if(a.Agencies_in_Target__c != null && String.isNotBlank(a.Agencies_in_Target__c)){
				a.ownerid = AXA_TECHNICAL_USER_ID;
				a.TECH_CampagnaLavorata__c = 'Da Lavorare';
			}

		}
	}

	public void beforeUpdate(SObject oldSo, SObject so)
	{

	}


	public void beforeUpdate(List<SObject> oldSoList, List<SObject> soList)
	{

		List<Campaign> rList = (List<Campaign>) soList;       
		Map <id,Campaign> mapaOld = new Map <id,Campaign> ((List<Campaign>) oldSoList);           
        
        for(Campaign a : rList)
        {
            

			if(a.Agencies_in_Target__c != mapaOld.get(a.id).Agencies_in_Target__c && !a.Campagna_creata_da_Direzione_Agente__c){
				if(a.ownerid != AXA_TECHNICAL_USER_ID)
					a.ownerid = AXA_TECHNICAL_USER_ID;
				a.TECH_CampagnaLavorata__c = 'Da Lavorare';
			}
			if(a.Stato_Assegnazione_membri_campagna__c!= null && String.isNotBlank(a.Stato_Assegnazione_membri_campagna__c))   
				if(a.Stato_Assegnazione_membri_campagna__c!= mapaOld.get(a.id).Stato_Assegnazione_membri_campagna__c && a.Stato_Assegnazione_membri_campagna__c.equalsIgnoreCase('Da Lavorare')){
					a.Stato_Assegnazione_membri_campagna__c='In corso';
					Database.executeBatch(new BatchRunCampaignMember(a.id), 2000);
				}
		}

	}

	/**

	 * beforeDelete

	 *

	 * This method is called iteratively for each record to be deleted during a BEFORE

	 * trigger.

	 */

	public void beforeDelete(SObject so)
	{

	}

	public void beforeDelete(List<SObject> soList)
	{

	}

	public void afterInsert(SObject so)
	{

	}



	public void afterInsert(List<SObject> soList)
	{
        List<Campaign> rList = (List<Campaign>) soList;
		CampaignMemberManagement.ChangeDefaultStatus(rList);

		//SHARING
		Map<id,SObject> mapSObj = new Map<id,SObject>();
		for(SObject s : soList)
		 {
             if(!RECORD_TYPE_Informative_Campaign_PCC_MyAXA.equalsIgnoreCase(Campaign.sObjectType.getDescribe().getRecordTypeInfosById().get(((Campaign)s).RecordTypeId).getDeveloperName())){
                mapSObj.put(s.id,s);
             }
		 }
		RecordSharing.shareRecordBasedOnField(mapSObj, objectShare, parentId, rawCause, accessLevelName, accessLevelvalue, fieldNameOfGroup, separatorOfGroups);

		CampaignMemberManagement.ShareWithFullAgency(rList);//the methods compute sharing only for Agency Campaigns
	}


	public void afterUpdate(SObject oldSo, SObject so)
	{

	}

	public void afterUpdate(List<SObject> oldSoList, List<SObject> soList)
	{
        List<Campaign> rList = new List<Campaign>();
		Map <id,Campaign> mapaOld = new Map <id,Campaign> ((List<Campaign>) oldSoList);
		//SHARING
		Map<id,SObject> mapSObj = new Map<id,SObject>();
		for(SObject a : soList)
		 {
            Campaign s = (Campaign) a;
			if(s.Campagna_creata_da_Direzione_Agente__c){
				if(s.Agencies_in_Target__c != mapaOld.get(s.id).Agencies_in_Target__c && s.TECH_CampagnaLavorata__c == null && !s.TECH_Batch_Required__c){
					Database.executeBatch(new CampaignSharing_Batch(s.Id));
					//ApplicationLogHelper.INFO('Test', 'Test', 'Test');
				}
					
			}
			else if (s.OwnerId == UserInfo.getUserId() && !RECORD_TYPE_Informative_Campaign_PCC_MyAXA.equalsIgnoreCase(Campaign.sObjectType.getDescribe().getRecordTypeInfosById().get(s.RecordTypeId).getDeveloperName())) {
				  mapSObj.put(s.id,s);
				rList.add(s);
			  }
		 }
		RecordSharing.shareRecordBasedOnField(mapSObj, objectShare, parentId, rawCause, accessLevelName, accessLevelvalue, fieldNameOfGroup, separatorOfGroups);
		
		CampaignMemberManagement.ShareWithFullAgency(rList);//the methods compute sharing only for Agency Campaigns
	}

	public void afterDelete(SObject so)
	{

	}

	public void afterUndelete(SObject so)
	{

	}

	public void afterDelete(List<SObject> soList)
	{

	}

	public void afterUndelete(List<SObject> soList)
	{
        List<Campaign> rList = (List<Campaign>) soList;
		//SHARING
		Map<id,SObject> mapSObj = new Map<id,SObject>();
		for(SObject s : soList)
		 {
            if(!RECORD_TYPE_Informative_Campaign_PCC_MyAXA.equalsIgnoreCase(Campaign.sObjectType.getDescribe().getRecordTypeInfosById().get(((Campaign)s).RecordTypeId).getDeveloperName())){
                mapSObj.put(s.id,s);
            }
		 }
		RecordSharing.shareRecordBasedOnField(mapSObj, objectShare, parentId, rawCause, accessLevelName, accessLevelvalue, fieldNameOfGroup, separatorOfGroups);

		CampaignMemberManagement.ShareWithFullAgency(rList);//the methods compute sharing only for Agency Campaigns

	}

	/**

	 * andFinally

	 *

	 * This method is called once all records have been processed by the trigger. Use this

	 * method to accomplish any final operations such as creation or updates of other records.

	 */

	public void andFinally()

	{


	}


}