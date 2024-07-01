public with sharing class AP10SendTaskOwnerEmail {
/* 
----------------------------------------------------------------------
-- - Name          : AP10SendTaskOwnerEmail
-- - Author        : Spoon Consulting
-- - Description   : Send task owner email
--
-- Maintenance History: 
--
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  ---------------------------------------
-- 13-MAY-2015  DMT    1.0     Initial version
----------------------------------------------------------------------
***********************************************************************/
 
	public static void sendEmail(list<Task> taskList, set<id> caseIdSet){
		system.debug('## Start AP10SendTaskOwnerEmail - sendEmail');
		map<id, case> mapCase = new map<id, case>();
		map<id, task> mapTask = new map<id, task>();
 		
		for(Case cas:[select id, ownerid, owner.name,CaseNumber
  						from case 
  						where id IN : caseIdSet]){
  			if(string.valueof(cas.ownerid).startswith(AP_constants.UserKeyPrefix)){
	  			mapCase.put(cas.id,cas); 
  			}
  		}
  		
  		for(Task tsk: [select id, owner.name 
  							from task 
  							where id in :taskList])
  		{
  			mapTask.put(tsk.id, tsk);
  		}
  			
		EmailTemplate etem = [Select e.Markup,Subject, e.HtmlValue, body From EmailTemplate e where DeveloperName = 'TaskReopenEmailCase'];
		list<Messaging.SingleEmailMessage> listEmail = new list<Messaging.SingleEmailMessage>();
        
        
        for(Task tsk:tasklist){
        	if(mapCase.containsKey(tsk.whatId)){
	            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
	            String htmlBody = etem.HtmlValue;
	            Case cas = mapCase.get(tsk.whatId);   
	            htmlBody = htmlBody.replace('{!current_user}',UserInfo.getName());
	            htmlBody = htmlBody.replace('{!Task.Owner}',mapTask.get(tsk.id).owner.name);
	            htmlBody = htmlBody.replace('{!Case.CaseNumber}',cas.CaseNumber);
	            htmlBody = htmlBody.replace('{!Task.Subject}',((tsk.Subject==null)?'':tsk.Subject));
	            htmlBody = htmlBody.replace('{!Task.Description}',((tsk.Description==null)?'':tsk.Description));

	            //MMOSCATELLI 20/04/2018: Fix per accesso tramite SAML -- START
	            //htmlBody = htmlBody.replace('{!Task.Link}',URL.getSalesforceBaseUrl().toExternalForm() + '/' +tsk.Id );
	            htmlBody = htmlBody.replace('{!Task.Link}','https://login.salesforce.com'+ '/' +tsk.Id );
	            //MMOSCATELLI 20/04/2018: Fix per accesso tramite SAML -- END

	            htmlBody = htmlBody.replace('{!current_user}',UserInfo.getName());
	            email.setSubject(etem.Subject);
	            email.emailPriority='High';
	            email.setTargetObjectId(tsk.ownerid);
	            email.setHtmlBody(htmlBody);
	            email.saveAsActivity = false;

	            listEmail.add(email);
        	}
        }
        Messaging.SendEmailResult [] r = Messaging.sendEmail(listEmail);
   			
		system.debug('## End AP10SendTaskOwnerEmail - sendEmail');
	}//end sendEmail
}