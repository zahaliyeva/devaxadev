public with sharing class AP05Task {
	
/* 
----------------------------------------------------------------------
-- - Name          : AP05Task
-- - Author        : Spoon Consulting
-- - Description   : Class to send Email when checkbox Send email to case owner is checked  
--
-- Maintenance History: 
--
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  ---------------------------------------
-- 29-JAN-2015	DMU	   1.0     Initial version
----------------------------------------------------------------------
***********************************************************************/	
	
 	public static void sendTaskMails(list <Task> tasklist,set<id> setCaseId){

 		map<id, case> mapCase = new map<id, case>();
 		
		for(Case cas:[select id, ownerid, owner.name,CaseNumber
  						from case 
  						where id IN : setCaseId]){
  			if(string.valueof(cas.ownerid).startswith(AP_constants.UserKeyPrefix)){
	  			mapCase.put(cas.id,cas); 
  			}
  		}
  		
  			
   			 EmailTemplate etem = [Select e.Markup,Subject, e.HtmlValue, body From EmailTemplate e where DeveloperName = 'TaskEmailCase'];
   			 list<Messaging.SingleEmailMessage> listEmail = new list<Messaging.SingleEmailMessage>();
        
        
        for(Task tsk:tasklist){
        	if(mapCase.containsKey(tsk.whatId)){
	            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
	            String htmlBody = etem.HtmlValue;
	            Case cas = mapCase.get(tsk.whatId);   
	            htmlBody = htmlBody.replace('{!Case.CaseNumber}',cas.CaseNumber);
	            htmlBody = htmlBody.replace('{!Case.Owner}',cas.owner.name);
	            htmlBody = htmlBody.replace('{!Task.Subject}',((tsk.Subject==null)?'':tsk.Subject));
	            htmlBody = htmlBody.replace('{!Task.Description}',((tsk.Description==null)?'':tsk.Description));
	            htmlBody = htmlBody.replace('{!Task.ActivityDate}',((tsk.ActivityDate==null)?'':string.valueof(tsk.ActivityDate)));
	            //MMOSCATELLI 20/04/2018: Fix per accesso tramite SAML -- START
	            //htmlBody = htmlBody.replace('{!Task.Link}',URL.getSalesforceBaseUrl().toExternalForm() + '/' +tsk.Id );
	            htmlBody = htmlBody.replace('{!Task.Link}','https://login.salesforce.com'+ '/' +tsk.Id );
	            //MMOSCATELLI 20/04/2018: Fix per accesso tramite SAML -- END

	            htmlBody = htmlBody.replace('{!User.Name}',userinfo.getName());
	            //htmlBody = htmlBody.replaceAll('\n','<br/>');
	           // email.setWhatId(cas.id);
	            //email.setWhatId(comp.id);
	            email.setSubject(etem.Subject);
	            email.emailPriority='High';
	            email.setTargetObjectId(cas.ownerid);
	            //email.setTemplateId(etem.Id);
	            email.setHtmlBody(htmlBody);
	            //email.setHtmlBody(etem.HtmlValue.replace('{!Task.Link}','aaaaa'));
	            email.saveAsActivity = false;
	            //email.setFileAttachments(attachmentList);
	            listEmail.add(email);
        	}
        }
        Messaging.SendEmailResult [] r = Messaging.sendEmail(listEmail);
   			
  		}
 			
 			//for (user u:[select Id, email from user where Id :setOwners]){
 
 				
  
 			//}
}