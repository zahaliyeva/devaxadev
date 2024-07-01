/*------------------------------------------------------------------------
Author:        Dario Bovolenta
Company:       Deloitte
Class:         deleteCampaignMembersBatch
Description:   Batch used to delete campaign members still in "to be deleted" status
			   at campaign start. Manually invoked.
History

09/04/2017     Created - D.B.

----------------------------------------------------------------------------*/

global without sharing class deleteCampaignMembersBatch implements Database.Batchable<sObject>,Database.Stateful {
	
	private String query;
	public String campaignId;
	public list<String> errorList;
	private Long successCount;
	private Long failCount;
	
	global deleteCampaignMembersBatch(String Id) {
		campaignId = Id;
		errorList = new list<String>();
		successCount = 0;
		failCount = 0;
		query = 'SELECT Id FROM CampaignMember WHERE CampaignId = \''+campaignId+'\' AND Status = \'In preparazione\'';
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		system.debug ('the current query is: '+query);
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		this.runJob(scope);
	}
	
	global void finish(Database.BatchableContext BC) {
		sendEmail(); //NOTIFY USER OF THE RESULTS
		
	}

	private void runJob (List<SObject> scope){
		Database.DeleteResult[] drList = Database.delete(scope,false);

		for(Database.DeleteResult dr : drList) {
		    if (dr.isSuccess()) {
		        // Operation was successful, so get the ID of the record that was processed
		        successCount++;
		    }
		    else {
		    	failCount++;
		        // Operation failed, so get all errors                
		        for(Database.Error err : dr.getErrors()) {
		        	errorList.add('Si è verificato il seguente errore ' + err.getStatusCode()+ ': ' + err.getMessage()+' sui seguenti campi: '+ err.getFields());
		        }
		    }
		}	
	}

	private void sendEmail(){
	        List<Messaging.SingleEmailMessage> allMails = new List<Messaging.SingleEmailMessage>();
	        //now do your loop
	        List<EmailTemplate> template = new List<EmailTemplate>();
	        template = [select id, Subject, HtmlValue, Body from EmailTemplate where developername = : 'Campaign_delete_members_in_base_status'];  
	        Campaign theCampaign = [SELECT Id,Name FROM Campaign WHERE Id = :campaignId limit 1];        
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String mailName ='Utente';

            system.debug('+++++++thisemailtemplate'+template.get(0));
            mail.setUseSignature(false);
            map<String,String> mapFieldToValue = new Map<String,String>();
            mapFieldToValue.put('{!User.FirstName}',mailName);
            mapFieldToValue.put('{!Campaign.Name}',theCampaign.Name ); 
            mapFieldToValue.put('{!successCount}',''+successCount ); 
            mapFieldToValue.put('{!failCount}',''+failCount ); 
            mapFieldToValue.put('{!errorList}',''+errorList );
            
            String errorsString = '';
            for (String s :errorList)
            {
            	errorsString = errorsString+s+'<br/>';
            }
         //   mapFieldToValue.put('{!Link}','https://'+System.URL.getSalesforceBaseUrl().getHost()+'/00Q/o' );
            String tempURL = System.URL.getSalesforceBaseUrl().toExternalForm();
            //String tempURL= System.URL.getCurrentRequestUrl().toExternalForm();
           // mapFieldToValue.put('{!Link}',tempURL.SPLIT('/apex/',-1).get(0)+'/agenzie/00Q/o' );        
            mail = UtilityClass.prepareEmailTemplate(template.get(0),mapFieldToValue );
            list<String> destinations = new list<String>();

            String UserId=UserInfo.GetUserId();
            list<User> AdminUser = new List<User>();
            AdminUser=[SELECT Id FROM User WHERE Username LIKE 'deloitte.admin@italy%' limit 1];
            destinations.add(''+UserId);

            if (AdminUser.size()>0) 
            {
            	destinations.add(''+AdminUser.get(0).Id);
            }

            mail.setToAddresses( destinations);
        
            mail.setSaveAsActivity(false);
        
            system.debug('+++++++++mail prepared'+mail);
          //  Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            if (destinations!= null && destinations.size()>0){
                allMails.add(mail);
            }
        

	        //Finished your loop? Now you have an array of mails to send.
	        //This uses 1 of your 10 calls to sendEmail that you are allowed
	        try{ 
	            if (allMails.size()>0){
	                Messaging.sendEmail(allMails);
	            }
	        } catch (Exception e)
	        {
	            system.debug('Email Sending Exception');   
	        }
	        system.debug('+++++EMAIL limit (calls/limit)='+Limits.getEmailInvocations()+'/'+Limits.getLimitEmailInvocations());    
	    }	

	
}