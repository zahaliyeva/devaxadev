@RestResource(urlMapping='/leads/convert/*')
global with sharing class MobilityRestLeadConvert extends RLY_Behaviour{

	public class MobilityLeadFieldException extends Exception {}
	public class MobilityLeadAccountNotFoundException extends Exception {}
	public class MobilityLeadNotFoundException extends Exception {}
	public class MobilityLeadConvertException extends Exception {}

	global class RequestConvertLead extends RestRequestAbstract{
		global String accountId;
		global String leadId;

    	public override String getMethod(){
    		return 'Mobility_Convert_Lead';
    	}

    	public override String getBaseUrl(){
    		return '/leads/convert/*';
    	}

	}

	global class ResponseConvertLead extends MobilityRestResponse{
		public ResponseConvertLead(IRestRequest inRequest){
			super(inRequest);
		}
	}
	
	@HttpPost
	global static List<ResponseConvertLead> leadConvert(RequestConvertLead request){
		DebugStart('MobilityRestLeadConvert', 'leadConvert');
		Debug('request', request);

		ResponseConvertLead response = new ResponseConvertLead(request);

		try{

			if(String.isBlank(request.accountId)) throw new MobilityLeadFieldException('Field accountId empty');
			if(String.isBlank(request.leadId)) throw new MobilityLeadFieldException('Field leadId empty');

			/**
			 * Retrieve Account Details
			 */
			List<Account> accounts = [
				SELECT Id, Salutation
				FROM Account
				WHERE Id = :request.accountId
				LIMIT 1
			];

			if(accounts.size() == 0) throw new MobilityLeadAccountNotFoundException('Account not found');

			Account account = accounts.get(0);
			Debug('account', account);

			/**
			 * Retrieve Lead Details
			 */
			List<Lead> listLead = [
				SELECT Id, FirstName, LastName, Email, Phone, TECH_Lead_Processed__c
				FROM Lead
				WHERE Id = :request.leadId
				LIMIT 1
			];

			if(listLead.size() == 0) throw new MobilityLeadNotFoundException('Lead not found'); 

			Lead leadToConvert = listLead.get(0);
			Debug('leadToConvert', leadToConvert);

			/**
			 * Retrieve Settings Lead Status
			 */
			AAI_Code_Variables__c leadstatus = [SELECT Value__c FROM AAI_Code_Variables__c WHERE Name='LeadStatus' LIMIT 1];   
			Debug('leadstatus', leadstatus);

			/**
			 * Start Convertion
			 */
			Database.LeadConvertResult resultConvertion = MobilityRestLeadConvert.convertLeadProcess(account, leadToConvert, leadstatus.Value__c);
			Debug('resultConvertion', resultConvertion);

			if(!resultConvertion.isSuccess()){
				Database.Error[] convertErrors = resultConvertion.getErrors();
				Database.Error firstError = convertErrors[0];

				throw new MobilityLeadConvertException(firstError.getMessage());
			}
			/**
			 * Create Quotation
			 */
			//QuotationManagement.createQuotationFromConversion(leadToConvert.Id, account.Id);

			/**
			 * Lead Convertion Case 
			 */
			LeadConversionManagement.handleLeadConversionOnCase(leadToConvert, account);

			response.success();
		}catch(MobilityLeadFieldException ex){
			Debug('MobilityLeadFieldException', ex);
			response.failed(403, ex.getMessage(), ex.getStackTraceString());
		}catch(MobilityLeadAccountNotFoundException ex){
			Debug('MobilityLeadAccountNotFoundException', ex);
			response.failed(404, ex.getMessage(), ex.getStackTraceString());
		}catch(MobilityLeadNotFoundException ex){
			Debug('MobilityLeadNotFoundException', ex);
			response.failed(404, ex.getMessage(), ex.getStackTraceString());
		}catch(MobilityLeadConvertException ex){
			Debug('MobilityLeadConvertException', ex);
			response.failed(403, ex.getMessage(), ex.getStackTraceString());
		}catch(DmlException ex){
			Debug('DmlException', ex);
			response.failed(ex.getMessage(), ex.getStackTraceString());
		}
		
		Debug('response', response);
		DebugEnd();
		return new List<ResponseConvertLead>{response};
	}

	public static Database.LeadConvertResult convertLeadProcess(Account targetAccount, Lead inputLead, String convertedLeadStatus){
		DebugStart('MobilityRestLeadConvert', 'convertLeadProcess');

		Database.LeadConvert leadToConvert = new Database.LeadConvert();
		
		inputLead.Salutation = null;
		inputLead.TECH_Lead_Processed__c=true;
		update inputLead;

		//Set Lead ID
		leadToConvert.setLeadId(inputLead.Id);  

		//Set Converted Lead Status
		leadToConvert.setConvertedStatus(convertedLeadStatus);
		    
		//Set Account on which the lead shall be converted
		leadToConvert.setAccountId(targetAccount.Id); 

		//Retrieve contact
		List<Contact> targetContacts = [
			SELECT Id 
			FROM Contact 
			WHERE AccountId = :targetAccount.Id 
			//AND (FirstName = :inputLead.FirstName AND LastName = :inputLead.LastName) 
			//AND (Email =:inputLead.Email OR Phone =:inputLead.Phone) 
			LIMIT 1
		];

		if (!targetContacts.isEmpty()){
			Contact targetContact = targetContacts[0];

			//Set Contact ID
		    leadToConvert.setContactId(targetContact.Id); 
		}

		//Start Convert
		Debug('leadToConvert', leadToConvert);
		DebugEnd();
		return Database.convertLead(leadToConvert);
	}
}