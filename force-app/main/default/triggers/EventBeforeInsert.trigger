trigger EventBeforeInsert on Event (before insert) {

	System.Debug('## >>> Start of TaskBeforeInsert <<< run by ' + UserInfo.getName());

    Id profileId = UserInfo.getProfileId();
    String profileName = [SELECT Name FROM Profile WHERE Id =: profileId LIMIT 1].Name;
    Boolean isAdmin = false;

    if(profileName=='System Administrator' || profileName=='Amministratore del sistema')
    {
        isAdmin = true;
    }

    if(!isAdmin)
    {
    	String leadKeyPrefix = Schema.SObjectType.Lead.getKeyPrefix();
        String errorMessage = '';
        AAI_Code_Variables__c aaiCS = AAI_Code_Variables__c.getValues('LeadStatusActivityError');
        if(aaiCS != null)
        {
            errorMessage = aaiCS.Value__c;
        }

        Set<Id> idLeads = new Set<Id>();
        for (Integer il=0;il<trigger.size;il++)
        {
            if(trigger.new[il].whoId != null 
            && String.ValueOf(trigger.new[il].whoId).startsWith(leadKeyPrefix))
            {
                idLeads.add(trigger.new[il].whoId);
            }
        }
        List<Lead> leadList = [select Id, Status from Lead where id in :idLeads];
        Map<Id,Lead> mapLead = new Map<Id,Lead>(leadList);

        for (Integer i=0;i < trigger.size ;i++)
        {       
            if(trigger.new[i].whoId != null
                && idLeads.contains(trigger.new[i].whoId))
            {
                if((mapLead.get(trigger.new[i].whoId).Status == 'To be processed')
                 ||(mapLead.get(trigger.new[i].whoId).Status == 'Da lavorare'))
                {
                	if(String.isNotBlank(errorMessage))
                	{
                    	trigger.new[i].addError(errorMessage);
                	}
                }
            }
        }
    }
}