public class CommunicationBounceEventManagement {
	public static void sendBounceAlertEmails(List<Customer_Communication_Bounce__e> bouncesList){
		List<Id> contactIds = new List<Id>();
		for(Customer_Communication_Bounce__e ev : bouncesList){
			contactIds.add(ev.Bounce_Contact__c);
		}

		Map<Id, Contact> ctList = new Map<Id,Contact>([SELECT Id, Name, Account.AAI_Agency_Reference_Code__c 
														FROM Contact 
														WHERE Id IN :contactIds]);
		System.debug('===> Contacts list for bounce ' + ctList);

		Map<Id, String> queueMap = new Map<Id, String>();
		for(Contact c : ctList.values()){
			queueMap.put(c.Id, 'Coda_Agenzia_' + c.Account.AAI_Agency_Reference_Code__c);
		}

		System.debug('===> Queue map: ' + queueMap);
		Set<Group> queues = new Set<Group>([SELECT Id, Name, DeveloperName 
								FROM Group 
								WHERE Type = 'Queue' and DeveloperName IN :queueMap.values()]);
		System.debug('===> Queues involved in bounce email alerts ' + queues);

		Set<String> queuesName = new Set<String>();
		for(Group g : queues){
			queuesName.add(g.DeveloperName);
		}
		
		Map<String,Set<String>> groupNametoEmails = UtilityClass.prepareQueueRecipientsMap(queuesName);
		System.debug('===> groupNametoEmails ' + groupNametoEmails);

		sendEmailsForBounce(bouncesList, contactIds, ctList, queueMap, groupNametoEmails);
	}

	public static void sendEmailsForBounce(List<Customer_Communication_Bounce__e> bouncesList, List<Id> contactIds, 
		Map<Id, Contact> ctList, Map<Id, String> queueMap, Map<String,Set<String>> groupNametoEmails){

		List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();

		EmailTemplate etMail = [SELECT id,Subject,HtmlValue,Body FROM emailtemplate 
								WHERE developername = 'AAI_Segnalazione_Email_Communication_Bounce'];
		EmailTemplate etSMS = [SELECT id,Subject,HtmlValue,Body FROM emailtemplate 
								WHERE developername = 'AAI_Segnalazione_SMS_Communication_Bounce'];
		OrgWideEmailAddress owa = [SELECT id, DisplayName, Address FROM OrgWideEmailAddress 
									WHERE DisplayName = 'Assistenza Agenti Axa Assicurazioni']; 

		Domain dom = [SELECT Domain,DomainType FROM Domain LIMIT 1];
        Network net = [SELECT Name,UrlPathPrefix FROM Network WHERE Name ='agenzie' LIMIT 1];
		
		System.debug('===> owa: ' + owa);

		for(Integer i=0; i<contactIds.size(); i++){
			String cId = contactIds.get(i);
			Customer_Communication_Bounce__e ev = bouncesList.get(i);
			System.debug('===> Communication Bounce event: ' + ev);
			Contact ct = ctList.get(cId);
			System.debug('===> Contact: ' + ct);
			String groupId = queueMap.get(cId);
			System.debug('===> GroupId: ' + groupId);
			Set<String> emails = groupNametoEmails.get(groupId);
			System.debug('===> emails: ' + emails);
	    	List<String> toAddresses = new List<String>();
	    	if(emails != null){
				toAddresses.addAll(emails);
				System.debug('===> Email ' + i + ' recipients: ' + toAddresses);

				Map<String,String> mapFieldToValue = new Map<String,String>();
				String url = '<a href=\'' + dom.Domain + '/' + net.UrlPathPrefix + '/' + ct.Id + '\'>' + ct.Name + '</a>';
		        mapFieldToValue.put('{!Contact.Name}', url);
		        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
		        if(ev.Type__c.equals('Email')){
		        	url = '<a href=\'' + dom.Domain + '/' + net.UrlPathPrefix + '/' + ev.Source_Process_ID__c + '\'>' 
		        		+ ev.Source_Process__c + '</a>';
	        		mapFieldToValue.put('{!et4ae5__IndividualEmailResult__c.Name}', ev.Source_Process__c);
		    		mapFieldToValue.put('{!et4ae5__IndividualEmailResult__c.Link}', url);
		        	email = UtilityClass.prepareEmailTemplate(etMail,mapFieldToValue);
		    	}
		    	else{
		    		mapFieldToValue.put('{!CampaignMember.Campaign}', ev.Source_Process__c);
		    		email = UtilityClass.prepareEmailTemplate(etSMS,mapFieldToValue);
		    	}
		        email.setToAddresses(toAddresses);
		        email.setSenderDisplayName(owa.DisplayName);
		        //email.setOrgWideEmailAddressId(owa.Id);
		        email.setReplyTo(owa.Address);
		        mails.add(email);
			}
		}
		if(mails.size() > 0){
        	Messaging.SendEmailResult [] r = Messaging.sendEmail(mails);      
        	EmailDelivery.notifyDeliveryErrors(r);
    	}
	}
}