/*------------------------------------------------------------------------
Author:        Marco Moscatelli
Company:       Deloitte
Class:         SocialPersonaManagement
Description:   Apex class used to execute all the logics internal to the 
			   trigger related to Social Personas

History

14/07/2017     Created - Marco Moscatelli.
----------------------------------------------------------------------------*/

public class SocialPersonaManagement 
{
	public void AccountUpdate(Map<Id,sObject> MapAccountToPersona, Map<String,String> MapPersonaToAccount) 
	{
		List<Account> AccToUpdList = new List<Account>();
        Set<Account> AccToUpdSet = new Set<Account>();
        List<SocialPost> SocialPostList = new List<SocialPost>();
        Set<SocialPost> SocialPostSet = new Set<SocialPost>();
        String AccountPrefix = Schema.SObjectType.Account.getKeyPrefix();

		

        for(SocialPost sp: [Select id,WhoId,PersonaId from SocialPost where PersonaId in:MapPersonaToAccount.keyset()])
        {
            if((String.isNotBlank(sp.WhoId) && !((String.valueof(sp.WhoId)).startsWith(AccountPrefix))) || String.isBlank(sp.WhoId))
            {
                SocialPost spo = new SocialPost(Id=sp.Id,WhoId=MapPersonaToAccount.get(sp.PersonaId));
                SocialPostSet.add(spo);
            }
        }
    	

    	if(AccToUpdSet.size()>0)
        {
            AccToUpdList.addAll(AccToUpdSet);
            Database.SaveResult[] srList = Database.update(AccToUpdList, false);
        }

        if(SocialPostSet.size()>0)
        {
            SocialPostList.addAll(SocialPostSet);
            Database.SaveResult[] srList = Database.update(SocialPostList, false);             
        }
	}
}