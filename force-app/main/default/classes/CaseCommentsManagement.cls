public class CaseCommentsManagement 
{
	public static void AfterInsert(Set<CaseComment> CommentList, Set<String> CommentIds) 
	{
		Map<String,String> MapCommentToCaseOwner = new Map<String,String>();
		Map<String,CommentInfos> MapCommToInfo = new Map<String,CommentInfos>();

		for(CaseComment Ccomm :[Select Id,CreatedbyId,Parent.Owner.Id,Parent.Owner.Name,Parent.CaseNumber,CommentBody,ParentId from CaseComment where id in:CommentIds])
		{
			if(Ccomm.CreatedbyId != Ccomm.Parent.Owner.Id)
			{
				MapCommentToCaseOwner.put(Ccomm.Id,Ccomm.Parent.Owner.Id);
				
				CommentInfos Cinfo = new CommentInfos();
				Cinfo.CaseNumber = Ccomm.Parent.CaseNumber;
				Cinfo.CaseOwnerName = Ccomm.Parent.Owner.Name;
				Cinfo.CommentId = Ccomm.Id;
				Cinfo.CaseId = Ccomm.ParentId;
				Cinfo.CommentBody = Ccomm.CommentBody;
				Cinfo.CaseOwnerId = Ccomm.Parent.Owner.Id;

				MapCommToInfo.put(Ccomm.Id,Cinfo);
			}
		}

		system.debug('@@MapCommToInfo: '+MapCommToInfo);

		if(!MapCommentToCaseOwner.isEmpty())
			SendNotification(MapCommentToCaseOwner,MapCommToInfo);
	}

	public class CommentInfos
	{
		String CaseNumber;
		String CaseOwnerName;
		String CommentId;
		String CaseId;
		String CommentBody;
		String CaseOwnerId;

		public CommentInfos()
		{
			this.CaseNumber = '';
			this.CaseOwnerName='';
			this.CommentId = '';
			this.CaseId = '';
			this.CommentBody = '';
			this.CaseOwnerId = '';
		}
	}

	public static void SendNotification(Map<String,String> MapCommentToCaseOwner,Map<String,CommentInfos> CommentList)
	{
		List<Messaging.SingleEmailMessage> listEmail = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
		Map<string,id>  mapOrgWideEmailAddress = new Map<string,id>();
		String OrgWideAddrId = '';
		String EmailTemplateName = '';

		for(MPS_Code_Variables__c MPSCv: MPS_Code_Variables__c.getAll().values())
        {
            if(MPSCv.Name == 'NotifyCaseCommentToAdvisor')
            {
                OrgWideAddrId = MPSCv.Key__c;
                EmailTemplateName = MPSCv.Value__c;
            }
        }

        String sUrl = [SELECT OrgLink__c 
	                   FROM Modello_di_Assistenza__mdt 
	                   WHERE DeveloperName = 'Redirect'
	                   LIMIT 1].OrgLink__c;

	    EmailTemplate etem = [SELECT Markup, Subject, HtmlValue, body 
	                          FROM EmailTemplate 
	                          WHERE DeveloperName =:EmailTemplateName];


	    String htmlBody;
	    String subject;
	    string body;
	    String url;

        try
        {
        	for(String Ccomm : CommentList.keySet())
        	{
        		if(MapCommentToCaseOwner.containsKey(Ccomm))
        		{
			        htmlBody = etem.HtmlValue;
			        subject = etem.Subject;
			        body    = etem.body;
			        url = sUrl+CommentList.get(Ccomm).CaseId;

			        subject  = subject.replace('{!Case.CaseNumber}', CommentList.get(Ccomm).CaseNumber);
			        htmlBody = htmlBody.replace('{!Case.User__c}', CommentList.get(Ccomm).CaseOwnerName);
			        body     = body.replace('{!Case.User__c}', CommentList.get(Ccomm).CaseOwnerName);
			        htmlBody = htmlBody.replace('{!Case.CaseNumber}', CommentList.get(Ccomm).CaseNumber);    
			        body     = body.replace('{!Case.CaseNumber}', CommentList.get(Ccomm).CaseNumber);
			        //htmlBody = htmlBody.replace('{!Case.Description}', CommentList.get(Ccomm).CommentBody);    
			        //body     = body.replace('{!Case.Description}', CommentList.get(Ccomm).CommentBody);	
			        htmlBody = htmlBody.replace('{!Case.Link}', url);    
			        body     = body.replace('{!Case.Link}', url);   
			        
			        email.setHtmlBody(htmlBody);
			        email.setSubject(subject);			        
			        email.setTargetObjectId(CommentList.get(Ccomm).CaseOwnerId);
					email.saveAsActivity = false;
			        email.setOrgWideEmailAddressId(OrgWideAddrId);
			        
			        listEmail.add(email);
		        }
	        }

	        if(!listEmail.isEmpty())
	        {
		        Messaging.SendEmailResult [] results = Messaging.sendEmail(listEmail);
		        
		        if (results[0].success)
		        {
		            System.debug('The email was sent successfully.');
		        } 
		        else
		        {
		            System.debug('The email failed to send: ' + results[0].errors[0].message);
		        }
		    }	        
        }
        catch(exception ex)
        {
            system.debug('@@Error in SendNotificaion: '+ex.getmessage());
        }                    	
	}
}