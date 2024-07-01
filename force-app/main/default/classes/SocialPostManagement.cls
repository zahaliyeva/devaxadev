/*------------------------------------------------------------------------
Author:        Marco Moscatelli
Company:       Deloitte
Class:         SocialPersonaManagement
Description:   Apex class used to execute all the logics internal to the 
			   trigger related to Social Posts

History

14/07/2017     Created - Marco Moscatelli.
----------------------------------------------------------------------------*/
public without sharing class SocialPostManagement 
{
	public Map<String,String> AddAccount(Set<String> PersonasIdSet, Map<String,String> PostToPersonaMap, Map<String,String> PostToCaseMap, Set<Case> CaseSet)
	{
    	Map<String,String> PersonaToAccountMap = new Map<String,String>();
    	String AccountPrefix = Schema.SObjectType.Account.getKeyPrefix();
    	Map<String,String> UpdPostToAccountMap = new Map<String,String>();
    	List<Case> CaseList = new List<Case>();

    	if(PersonasIdSet.size()>0)
    	{
    		for(SocialPersona sp: [Select Id,ParentId from SocialPersona where id in:PersonasIdSet])
    		{
    			System.debug('===> Social Persona: ' + sp);
    			if(String.isNotBlank(sp.ParentId) && String.valueof((sp.ParentId)).startsWith(AccountPrefix))
    				PersonaToAccountMap.put(sp.Id,sp.ParentId);
    		}

    		System.debug('===> PersonaToAccountMap: ' + PersonaToAccountMap);
	    	if(PersonaToAccountMap.size()>0)
	    	{
	    		for(String s:PostToPersonaMap.keySet())
	    		{
	    			if(PersonaToAccountMap.containsKey(PostToPersonaMap.get(s)))
	    			{
	    				UpdPostToAccountMap.put(s,PersonaToAccountMap.get(PostToPersonaMap.get(s)));

	    				if(PostToCaseMap.containsKey(s))
	    				{
	    					Case c = new Case(Id=PostToCaseMap.get(s),AccountId=PersonaToAccountMap.get(PostToPersonaMap.get(s)));
	    					CaseSet.add(c);
	    				}
	    			}
	    		}
    		}
    	}

		if(CaseSet.size()>0)
		{
			CaseList.addAll(CaseSet);
			Database.SaveResult[] srList = Database.update(CaseList, false);
		}

		return UpdPostToAccountMap;		
	}

	public void SendNotification(Map<String,Sobject> CaseToContentMap)
	{
		String SearchTemplate = 'NewPostNotification';
		List<Case> CaseList = new List<Case>();
		List<Case> CaseToUpdateList = new List<Case>();
		List<Messaging.SingleEmailMessage> listEmail = new List<Messaging.SingleEmailMessage>();
		CaseList = [Select Id,Status,Account.Name,OwnerId, Casenumber, Owner.Name from Case where id in:CaseToContentMap.keySet() ];
		EmailTemplate etem = [Select e.Subject,e.Markup,e.HtmlValue, body From EmailTemplate e where DeveloperName =: SearchTemplate];


		for(Case c : CaseList)
		{
			Case UpdCas = new Case(Id = c.Id,Status =AP_Constants.caseStatusInformationReceived);
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            String htmlBody = etem.HtmlValue;
            htmlBody = htmlBody.replace('{!Case.CaseNumber}',c.CaseNumber);
            htmlBody = htmlBody.replace('{!Contact.Name}',c.Owner.Name);
            htmlBody = htmlBody.replace('{!SocialPost.Content}',(String)(CaseToContentMap.get(c.Id)).get('Content'));
            htmlBody = htmlBody.replace('{!SocialPost.PostUrl}',(String)(CaseToContentMap.get(c.Id)).get('PostUrl'));
            htmlBody = htmlBody.replace('{!Case.Account}',(String.isNotBlank(c.Account.Name))?c.Account.Name:'');
            htmlBody = htmlBody.replace('{!SocialPost.Provider}',(String)(CaseToContentMap.get(c.Id)).get('Provider'));                          
            email.setSubject(etem.subject);
            email.emailPriority='High';
            email.setTargetObjectId(c.OwnerId);
            email.setHtmlBody(htmlBody);
            email.saveAsActivity = false;
            listEmail.add(email);

            if(c.Status == AP_Constants.caseStatusPending)
            	CaseToUpdateList.add(UpdCas);
        }

		try
		{
			if(CaseToUpdateList.size()>0)
				Update CaseToUpdateList;
		}
		catch(exception ex)
		{
			System.debug('####ERROR for Update Case: '+ex.getmessage());	
		}

        try
        {
        	Messaging.SendEmailResult [] r = Messaging.sendEmail(listEmail);  
		}
		catch(exception ex)
		{
			System.debug('####ERROR for SendEmail: '+ex.getmessage());	
		}
	}
}