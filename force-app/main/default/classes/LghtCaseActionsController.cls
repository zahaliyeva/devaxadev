public with sharing class LghtCaseActionsController extends RLY_Behaviour { 
	 
	public class LghtVisibilityException extends Exception {}
	public class CaseResponse extends LghtResponse{}
	public class CaseContext extends LghtResponse{
		@AuraEnabled public Case caseData;
		@AuraEnabled public Questionario_CA__c survey;
		@AuraEnabled public String portalRole;
		@AuraEnabled public String profileName;
		@AuraEnabled public Boolean ownerIsQueue;
		@AuraEnabled public Map<String,List<String>> visibities;
        
	}
	
	public class CaseResponseSelectOption extends LghtResponse{
		@AuraEnabled public Map<String,List<SelectOptionWrapper>> values;
	}

	@AuraEnabled
	public static CaseContext getCase(String recordId){
		DebugStart('LghtCaseActionsController', 'getCase');

		CaseContext response = new CaseContext();

		try {
			/**
			* Retrieve Current User
			*/
			User currentUser = LghtCaseManageController.currentUser();

			Debug('currentUser', currentUser);

			/**
			* User Role
			*/
			response.portalRole = currentUser.UserRole.PortalRole;

			/**
			* Profile Name
			*/
			response.profileName = currentUser.Profile.Name;

			/**
			* Case Data
			*/
			Case caseData = LghtCaseManageController.getCase(recordId);
			Debug('caseData', caseData);

			response.caseData = caseData;
			response.ownerIsQueue = (String.valueOf(caseData.OwnerId).startsWith('00G')) ? true : false;

			/**
			* SURVEY (QUESTIONARIO)
			*/
			List<Questionario_CA__c> listSurvey = [
				SELECT Id 
				FROM Questionario_CA__c 
				WHERE Case__c = :recordId
			];

			Debug('listSurvey', listSurvey);

			if(listSurvey.size() > 0){
				response.survey = listSurvey[0];
			}

			/**
			* Check if have visibiity
			*/
			Map<String,List<String>> visibities = LghtCaseManageController.availableAction(currentUser.Profile.Name, caseData.RecordType.DeveloperName);

			Debug('visibities', visibities);
			response.visibities = visibities;

			response.isSuccess = true;
		} catch (LghtVisibilityException ex) {
			response.errorMessage = ex.getMessage();
			Debug('Exception', response.errorMessage);
		} catch (Exception ex){
			response.errorMessage = ex.getMessage();
			Debug('Exception', response.errorMessage);
		}

		Debug('response', response);
		DebugEnd();

		return response;
	}

	@AuraEnabled
	public static CaseResponse takeOver(String recordId){
		DebugStart('LghtCaseActionsController', 'takeOver');
		
		CaseResponse response = new CaseResponse();

		try {
			/**
			* Retrieve Current User
			*/
			User currentUser = LghtCaseManageController.currentUser();
			Debug('currentUser', currentUser);

			/**
			 * Retrieve Case Data
			 */
			Case caseData = LghtCaseManageController.getCase(recordId);
			Debug('caseData', caseData);
            
            

			caseData.OwnerId = currentUser.Id;
			update caseData;
			
			response.isSuccess = true;
		} catch (LghtVisibilityException ex) {
			response.errorMessage = ex.getMessage();
			Debug('Exception', response.errorMessage);
		} catch (Exception ex){
			response.errorMessage = ex.getMessage();
			Debug('Exception', response.errorMessage);
		}

		Debug('response', response);
		DebugEnd();

		return response;

	}

    @AuraEnabled
	public static CaseResponse backToQueue(String recordId){
		DebugStart('LghtCaseActionsController', 'takeOver');
		
		CaseResponse response = new CaseResponse();

		try {
            
            Case caseData = LghtCaseManageController.getCase(recordId);
			Debug('caseData', caseData);
            if(caseData.Status=='Closed' || caseData.Status=='Out of time'){
                response.errorMessage='Non è possibile riaprire un case chiuso.';
                return response;
            }
            String queueDevName = caseData.Current_Owner_Queue__c;
            if(queueDevName != null && queueDevName != ''){
                List<Group> queue = [Select name from Group where developername =: queueDevName and type = 'Queue'];
                if(queue.size() != 0){
                    caseData.OwnerId = queue[0].id;
                    if(queue[0].Name.contains('HD2'))
                        caseData.status = AP_Constants.caseStatusAssIILivello;
                    else
                        caseData.status = AP_Constants.caseStatusOpen;
                    update caseData;
                    response.isSuccess = true;
                }
                else{
                    response.errorMessage = 'Attenzione: questo caso è stato creato manualmente o con contatto telefonico.';
                }
            } 
            else{
                response.errorMessage = 'Attenzione: questo caso è stato creato manualmente o con contatto telefonico.';
            }
		} catch (LghtVisibilityException ex) {
			response.errorMessage = ex.getMessage();
			Debug('Exception', response.errorMessage);
		} catch (Exception ex){
			response.errorMessage = ex.getMessage();
			Debug('Exception', response.errorMessage);
		}

		Debug('response', response);
		DebugEnd();

		return response;

	}

	@AuraEnabled
	public static CaseResponse reopen(String recordId){
		DebugStart('LghtCaseActionsController', 'reopen');
		
		CaseResponse response = new CaseResponse();

		try {

			/**
			 * Retrieve Case Data
			 */
			Case caseData = LghtCaseManageController.getCase(recordId);
			Debug('caseData', caseData);

			List<String> statesBlock = new List<String>{
				'Out of time',
				'Closed',
				'Cancelled'
			};

			if(!statesBlock.contains(caseData.Status)) throw new LghtVisibilityException('La funzionalità di Riapri Case è disponibile solo per i case chiusi');

			if(caseData.NumberOfReopens__c == null) caseData.NumberOfReopens__c = 0;

			caseData.NumberOfReopens__c = caseData.NumberOfReopens__c + 1;
			caseData.StatusReopened_Date__c = Datetime.now();
			caseData.Status = 'Reopened';

			update caseData;
			
			response.isSuccess = true;
		} catch (LghtVisibilityException ex) {
			response.errorMessage = ex.getMessage();
			Debug('Exception', response.errorMessage);
		} catch (Exception ex){
			response.errorMessage = ex.getMessage();
			Debug('Exception', response.errorMessage);
		}

		Debug('response', response);
		DebugEnd();

		return response;

	}


	@AuraEnabled
	public static CaseResponseSelectOption sendSMSInit(Map <String,String> UrlParameterMap){
		DebugStart('LghtCaseActionsController', 'sendSMSInit');
		Debug('UrlParameterMap', UrlParameterMap);
		
		String FolderTemplateManualAccount = 'SMS Manuali - Account';
		String FolderTemplateManualCase = 'SMS Manuali - Case';
		List<EmailTemplate> AvailableTemplateList = new List<EmailTemplate>();
		String CustomerId;
		String CaseId;
        String healthPhone;
		List<Case> CaseList = new List<Case>();
		List<SelectOptionWrapper> ListTemplates = new List<SelectOptionWrapper>() ;
		List<Account> CustomerList = new List<Account>() ;
		Map<Id,String> TemplateMap = new Map<Id, String>();
		List <SelectOptionWrapper> ListMobileNumbers  = new List <SelectOptionWrapper>(); 
	
		
		CaseResponseSelectOption response = new CaseResponseSelectOption();
		response.values = new Map<String,List<SelectOptionWrapper>>();

		try {
		
			if(UrlParameterMap.containsKey('CaseId'))
            {
                if(String.isNotBlank(UrlParameterMap.get('CaseId')))
                {
                    CaseId = UrlParameterMap.get('CaseId');	 
                    CaseList = [Select Id, AccountId, Linktopolicy__c from Case where id=:CaseId];
                    // if Case is related to a Feedback should be true *-+ 02-12-2021
                    //lista per lista[0]
                    healthPhone = gethealthPhoneFromFeedBackIfExist(caseId);                
                    AvailableTemplateList = new List<EmailTemplate>([SELECT Id,Body,Folder.name,IsActive,Name FROM EmailTemplate where folder.name =: FolderTemplateManualCase]);
                }
                else
                    AvailableTemplateList = new List<EmailTemplate>([SELECT Id,Body,Folder.name,IsActive,Name FROM EmailTemplate where folder.name =: FolderTemplateManualAccount]);                    
            }
            
            if(UrlParameterMap.containsKey('AccountId') || UrlParameterMap.containsKey('CustomerId'))
            {
                if(String.isNotBlank(UrlParameterMap.get('AccountId')))
                    CustomerId = UrlParameterMap.get('AccountId');
                else if(String.isNotBlank(UrlParameterMap.get('CustomerId')))        
                    CustomerId = UrlParameterMap.get('CustomerId');
			}
			
			if(UserInfo.getLanguage()=='it')
			ListTemplates.add(new selectOptionWrapper('','--Nessuno--'));
			else
				ListTemplates.add(new selectOptionWrapper('','--None--'));
			
			for(EmailTemplate em:AvailableTemplateList)
			{
				ListTemplates.add(new selectOptionWrapper(em.Id,em.Name));
				TemplateMap.put(em.Id, em.Body);                
			}
		
			response.values.put('ListTemplates', ListTemplates);


			if(String.isNotBlank(CustomerId))
            {
                CustomerList =				([Select Id,
                                              CIF_MobilePhone__c,
                                              CIF_PersonMobilePhone__c,                                                                                       
                                              PersonMobilePhone,
                                              Additional_Phone__c,
                                              MobilePhone__c,
                                              Claim_PersonalMobile__c,
                                              RecordTypeId
                                              from Account
                                              where Id=:CustomerId]);
                
			 ListMobileNumbers = ObtainMobileNumber(CustomerList,healthPhone);
			 response.values.put('ListMobileNumbers', ListMobileNumbers);
             
            }
		
		
		
			
			
			response.isSuccess = true;
		} catch (LghtVisibilityException ex) {
			response.errorMessage = ex.getStackTraceString();
			Debug('Exception', response.errorMessage);
		} catch (Exception ex){
			response.errorMessage = ex.getStackTraceString();
			Debug('Exception', response.errorMessage);
		}

		Debug('response', response);
		DebugEnd();
		
		return response;
	}

   public class SelectOptionWrapper{
	@AuraEnabled  public String key;
	@AuraEnabled  public String value;

	public SelectOptionWrapper(String k, String v) {
	 key= k;
	 value = v;
	}
   }

     public static String formatStringPhone(String input){
      String output = input;

      output = output.deleteWhitespace();
      output = output.remove('(');
      output = output.remove(')');

      return output;
   }

	public static List<SelectOptionWrapper> ObtainMobileNumber (List<Account> CustomerList, String healthPhone)
    {
		List <SelectOptionWrapper> ListMobileNumbers  = new List <SelectOptionWrapper>(); 
		Map<String,Id> acc_developerIdMap = AP_Constants.getDeveloperIdMap(AP_Constants.sobjectAcc);
       
       
        for(Account a:CustomerList){

            if(healthPhone!=null && String.isNotBlank(healthPhone) ){
                healthPhone=CheckMobileFormat(formatStringPhone(healthPhone));
                    ListMobileNumbers.add(new selectOptionWrapper(healthPhone,healthPhone));
            }
            else{
           if(a.RecordTypeId == acc_developerIdMap.get(AP_Constants.rtAccIndividualClient))
           {
               String AdditionalMobile = '';               
               String PersonMobile = '';
               String MobileCTL ='';              		
               
               if(String.isNotBlank(a.Additional_Phone__c))
               {
               		AdditionalMobile = formatStringPhone(a.Additional_Phone__c);
               }
               
               if(String.isNotBlank(a.PersonMobilePhone))
               {
               		PersonMobile = formatStringPhone(a.PersonMobilePhone);
               }
               
               if(String.isNotBlank(a.Claim_PersonalMobile__c))
               {
               		MobileCTL = formatStringPhone(a.Claim_PersonalMobile__c);
               }               
               
               if(String.isNotBlank(AdditionalMobile))
               {
               		if(String.isNotBlank(CheckMobileFormat(AdditionalMobile)))
                    {
                        ListMobileNumbers.add(new selectOptionWrapper(CheckMobileFormat(AdditionalMobile),CheckMobileFormat(AdditionalMobile)));	                    
                    }	                    
               }
               
               if(String.isNotBlank(PersonMobile))
               {
               		if(String.isNotBlank(CheckMobileFormat(PersonMobile)))
                    {
                        ListMobileNumbers.add(new selectOptionWrapper(CheckMobileFormat(PersonMobile),CheckMobileFormat(PersonMobile)));	                    
                    }	                    
               }
               
               if(String.isNotBlank(MobileCTL))
               {
               		if(String.isNotBlank(CheckMobileFormat(MobileCTL)))
                    {
                        ListMobileNumbers.add(new selectOptionWrapper(CheckMobileFormat(MobileCTL),CheckMobileFormat(MobileCTL)));	                    
                    }	                    
               }               
              
           }
           else if(a.RecordTypeId == acc_developerIdMap.get(AP_Constants.rtAccCorporateClient))
           {
               String AdditionalMobile = '';
               String PersonMobile = '';
               String MobileCTL = '';                 
               
               if(String.isNotBlank((a.Additional_Phone__c)))
               {
                   AdditionalMobile = formatStringPhone(a.Additional_Phone__c);           
               }
                                  
               if(String.isNotBlank((a.MobilePhone__c)))
               {
                   PersonMobile = formatStringPhone(a.MobilePhone__c);               
               }
               
               if(String.isNotBlank((a.Claim_PersonalMobile__c)))
               {
                MobileCTL = formatStringPhone(a.Claim_PersonalMobile__c);                 
               }               
               
               if(String.isNotBlank(AdditionalMobile))
               {
               		if(String.isNotBlank(CheckMobileFormat(AdditionalMobile)))  
                    {
                        ListMobileNumbers.add(new selectOptionWrapper(CheckMobileFormat(AdditionalMobile),CheckMobileFormat(AdditionalMobile)));	                    
                    }                  
               }
               
               if(String.isNotBlank(PersonMobile))
               {
               		if(String.isNotBlank(CheckMobileFormat(PersonMobile)))	     
                    {
                   		ListMobileNumbers.add(new selectOptionWrapper(CheckMobileFormat(PersonMobile),CheckMobileFormat(PersonMobile)));	                    
                    }               
               }
               
               if(String.isNotBlank(MobileCTL))
               {
               		if(String.isNotBlank(CheckMobileFormat(MobileCTL)))	     
                    {
                   		ListMobileNumbers.add(new selectOptionWrapper(CheckMobileFormat(MobileCTL),CheckMobileFormat(MobileCTL)));	                    
                    }               
               }                
           }
           else if(a.RecordTypeId == acc_developerIdMap.get(AP_Constants.rtAccAAFB2C))
           {
               String AdditionalMobile = '';
               String PersonMobile = '';
               
               if(String.isNotBlank(a.Additional_Phone__c))
               {
                   AdditionalMobile = formatStringPhone(a.Additional_Phone__c);                 
               }
               
               if(String.isNotBlank(a.MobilePhone__c))
               {
			   	   PersonMobile = formatStringPhone(a.MobilePhone__c);                  
               }
               
			   if(String.isNotBlank(AdditionalMobile))
               {
               		if(String.isNotBlank(CheckMobileFormat(AdditionalMobile))) 
                    {
                        ListMobileNumbers.add(new selectOptionWrapper(CheckMobileFormat(AdditionalMobile),CheckMobileFormat(AdditionalMobile)));	                    
                    }                   
               }
               
               if(String.isNotBlank(PersonMobile))
               {
               		if(String.isNotBlank(CheckMobileFormat(PersonMobile)))
                    {
                        ListMobileNumbers.add(new selectOptionWrapper(CheckMobileFormat(PersonMobile),CheckMobileFormat(PersonMobile)));	                    
                    }	                    
               }           		    
           }
           else if(a.RecordTypeId == acc_developerIdMap.get(AP_Constants.rtAccB2C))
           {
               String AdditionalMobile = '';
               String PersonMobile = '';
               String MobileCTL = '';
               
               if(String.isNotBlank(a.Additional_Phone__c))
               {
                   AdditionalMobile = formatStringPhone(a.Additional_Phone__c);
               }	

               if(String.isNotBlank(a.CIF_PersonMobilePhone__c))
               {
                   PersonMobile = formatStringPhone(a.CIF_PersonMobilePhone__c);
               }
               
               if(String.isNotBlank(a.Claim_PersonalMobile__c))
               {
                   MobileCTL = formatStringPhone(a.Claim_PersonalMobile__c);
               }	               
               
			   if(String.isNotBlank(PersonMobile))
               {
               		if(String.isNotBlank(CheckMobileFormat(PersonMobile)))
                   		ListMobileNumbers.add(new selectOptionWrapper(CheckMobileFormat(PersonMobile),CheckMobileFormat(PersonMobile)));	                    
               }
               
               if(String.isNotBlank(AdditionalMobile))
               {
               		if(String.isNotBlank(CheckMobileFormat(AdditionalMobile)))
                   		ListMobileNumbers.add(new selectOptionWrapper(CheckMobileFormat(AdditionalMobile),CheckMobileFormat(AdditionalMobile)));	                    
               }
               
               if(String.isNotBlank(MobileCTL))
               {
               		if(String.isNotBlank(CheckMobileFormat(MobileCTL)))
                   		ListMobileNumbers.add(new selectOptionWrapper(CheckMobileFormat(MobileCTL),CheckMobileFormat(MobileCTL)));	                    
               }                   
           }             
           else if(a.RecordTypeId == acc_developerIdMap.get(AP_Constants.rtAccB2B))
           {    
               String AdditionalMobile = '';
               String Mobile = '';
               String MobileCTL = '';
               
               if(String.isNotBlank(a.Additional_Phone__c))
               {
                   AdditionalMobile = formatStringPhone(a.Additional_Phone__c);
               }	                   
               
               if(String.isNotBlank(a.CIF_MobilePhone__c))
               {
                   Mobile = formatStringPhone(a.CIF_MobilePhone__c);
               }
               
               if(String.isNotBlank(a.Claim_PersonalMobile__c))
               {
                   MobileCTL = formatStringPhone(a.Claim_PersonalMobile__c);
               }	               
               
			   if(String.isNotBlank(Mobile))
               {
               		if(String.isNotBlank(CheckMobileFormat(Mobile)))
                   		ListMobileNumbers.add(new selectOptionWrapper(CheckMobileFormat(Mobile),CheckMobileFormat(Mobile)));	                    
               }
               
               if(String.isNotBlank(AdditionalMobile))
               {
               		if(String.isNotBlank(CheckMobileFormat(AdditionalMobile)))
                   		ListMobileNumbers.add(new selectOptionWrapper(CheckMobileFormat(AdditionalMobile),CheckMobileFormat(AdditionalMobile)));	                    
               } 
               
               if(String.isNotBlank(MobileCTL))
               {
               		if(String.isNotBlank(CheckMobileFormat(MobileCTL)))
                   		ListMobileNumbers.add(new selectOptionWrapper(CheckMobileFormat(MobileCTL),CheckMobileFormat(MobileCTL)));	                    
               }                
           }
            }
        }
        System.debug('ListMobileNumbers '+ListMobileNumbers);
        return ListMobileNumbers;
    } 

	public static String CheckMobileFormat(String NumberToCheck)
    {
        String NewFormat = '';
        
        if(String.isNotBlank(NumberToCheck))
        {                 
            if((String.valueOf(NumberToCheck)).left(4) == '0039')
            {
                if(((NumberToCheck).substring(4)).isnumeric() && ((NumberToCheck).substring(4)).left(1)=='3')    
                    NewFormat = (NumberToCheck).substring(4);
            }
            else if((String.valueOf(NumberToCheck)).left(3) == '+39')
            {
                if(((NumberToCheck).substring(3)).isnumeric() && ((NumberToCheck).substring(3)).left(1)=='3')
                    NewFormat = (NumberToCheck).substring(3);
            }
            else if((String.valueOf(NumberToCheck)).left(2) == '03')
            {
                if(((NumberToCheck).substring(1)).isnumeric())
                    NewFormat = (NumberToCheck).substring(1);
            }
            else if((String.valueOf(NumberToCheck)).left(1) == '3')
            {
                if(((NumberToCheck).substring(1)).isnumeric())
                    NewFormat = NumberToCheck;
            }
        } 
              
        return NewFormat;
	}
    //*-+ 02-12-2021
    private static String getHealthPhoneFromFeedBackIfExist(String caseId){
        String  healthPhone ;
        List <feedback__c> list_feedbacksRelated ;

        list_feedbacksRelated = [select Health_mobile_phone__c from feedback__c where complaint__c=:CaseId ];

        if(list_feedbacksRelated != null && list_feedbacksRelated.size()>0)
            return list_feedbacksRelated[0].Health_mobile_phone__c ;

        return healthPhone ;
    }

	@AuraEnabled	
	public static CaseResponse sendSMS(String MessageContent, String CaseId, String SelectedTemplateId, String CustomerId, String MobileNumber)
    {
		CaseResponse response = new CaseResponse ();
        Communications_to_customer__c SMS = new Communications_to_customer__c(Notification_Typology__c='SMS',
                                                                                  AccountId__c=CustomerId,
                                                                                  Message__c = MessageContent,
                                                                                  Mobile_Phone__c = MobileNumber,
                                                                                  Request_Date__c = String.valueOf((system.now()).format()));
            
            if(String.isNotBlank(CaseId))
                SMS.CaseId__c = CaseId;
            
            if(String.isNotBlank(SelectedTemplateId))
               	SMS.SMS_Template_Id__c = SelectedTemplateId;
            
            Savepoint sp = Database.setSavepoint();
            
            try
            {
				insert SMS;  
			response.isSuccess=true;
            }
            catch(exception ex)
            {
				response.errorMessage = ex.getMessage();
                Database.rollback(sp);
                system.debug('Error: '+ex.getmessage());
              
            }
        
        
        return response;
    }
    
}