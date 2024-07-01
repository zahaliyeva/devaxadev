public class EmailUnsubscribingEventManagement {
	public static void sendUnsubscribeAlertEmails(List<SObject> evList){
		CustomerEventsManagement.sendEmailAlertsForCustomerEvent(evList);
		//List<String> ndgsList = new List<String>();
		//List<String> fiscalCodesList = new List<String>();
		//List<String> VASNumbersList = new List<String>();
		//for(Customer_Email_Unsubscribing__e so :eventsList)
		//{
		//	if(so.Customer_Company__c=='AAI')
		//	{
		//		ndgsList.add(so.NDG__c);
		//	}
		//	else if ( (so.Customer_Company__c == 'AMPS') ||(so.Customer_Company__c=='MPS') )
		//	{
		//		String fiscalInformation = so.Fiscal_Identifier__c;
		//		if (fiscalInformation.length()==16) //Is a fiscal code
		//		{
		//			fiscalCodesList.add(fiscalInformation);
		//		}
		//		else //is a VAS number
		//		{
		//			VASNumbersList.add(fiscalInformation);
		//		}
		//	}
		//}
		//System.debug('===> ndgsList: ' + ndgsList);
		//List<Account> listAccounts = [SELECT Id, Name, NDG__c, Fiscal_ID__c, Partita_IVA__c, AAI_Agency_Reference_Code__c 
		//								FROM Account 
		//								WHERE NDG__c in :ndgsList 
		//									OR Fiscal_ID__c IN :fiscalCodesList 
		//									OR Partita_IVA__c in :VASNumbersList];
		//Map<Id, String> queueMap = new Map<Id, String>();
		//for(Account a : listAccounts){
		//	queueMap.put(a.Id, 'Coda_Agenzia_' + a.AAI_Agency_Reference_Code__c);
		//}

		//System.debug('===> Queue map: ' + queueMap);
		//Set<Group> queues = new Set<Group>([SELECT Id, Name, DeveloperName 
		//						FROM Group 
		//						WHERE Type = 'Queue' and DeveloperName IN :queueMap.values()]);
		//System.debug('===> Queues involved in email unsubscribing alerts ' + queues);

		//Set<String> queuesName = new Set<String>();
		//for(Group g : queues){
		//	queuesName.add(g.DeveloperName);
		//}
		
		//Map<String,Set<String>> groupNametoEmails = UtilityClass.prepareQueueRecipientsMap(queuesName);
		//System.debug('===> groupNametoEmails ' + groupNametoEmails);
	}

	//public static void sendEmailsForDownloadEvent(List<Customer_Document_Download__e> eventsList, List<Account> listAccounts, 
	//	Map<Id, String> queueMap, Map<String,Set<String>> groupNametoEmails){

	//	List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();

	//	EmailTemplate et = [SELECT id,Subject,HtmlValue,Body FROM emailtemplate 
	//							WHERE developername = 'AAI_Segnalazione_Customer_Document_Download'];
	//	OrgWideEmailAddress owa = [SELECT id, DisplayName, Address FROM OrgWideEmailAddress 
	//								WHERE DisplayName = 'AXA Lead Management']; 
	//	System.debug('===> owa: ' + owa);

	//	for(Integer i=0; i<listAccounts.size(); i++){
	//		Customer_Document_Download__e ev = eventsList.get(i);
	//		System.debug('===> Customer Document Download event: ' + ev);
	//		Account act = listAccounts.get(i);
	//		System.debug('===> Account: ' + act);
	//		String groupId = queueMap.get(act.Id);
	//		System.debug('===> GroupId: ' + groupId);
	//		Set<String> emails = groupNametoEmails.get(groupId);
	//		System.debug('===> emails: ' + emails);
	//    	List<String> toAddresses = new List<String>();
	//    	if(emails != null){
	//			toAddresses.addAll(emails);
	//			System.debug('===> Email ' + (i+1) + ' recipients: ' + toAddresses);

	//			Map<String,String> mapFieldToValue = new Map<String,String>();
	//	        mapFieldToValue.put('{!Account.Name}', act.Name);
	//	        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
	//    		mapFieldToValue.put('{!Customer_Event__c.Timestamp__c}', ev.Timestamp__c.format('dd/MM/yyyy'));
 //   			mapFieldToValue.put('{!InsurancePolicy__c.Name}', ev.Policy_Number__c);
	//        	email = UtilityClass.prepareEmailTemplate(et,mapFieldToValue);		    	
	//	        email.setToAddresses(toAddresses);
	//	        //email.setSenderDisplayName(owa.DisplayName);
	//	        email.setOrgWideEmailAddressId(owa.Id);
	//	        email.setReplyTo(owa.Address);
	//	        mails.add(email);
	//		}
	//	}
	//	if(mails.size() > 0){
 //       	Messaging.SendEmailResult [] r = Messaging.sendEmail(mails);      
 //       	EmailDelivery.notifyDeliveryErrors(r);
 //   	}
	//}

}