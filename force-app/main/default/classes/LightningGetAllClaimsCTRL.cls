/*------------------------------------------------------------------------------------------
Author:        Orlando Aversano
Company:       Deloitte
Class:         LightningGetAllClaimsCTRL
Description:   Apex class used to execute all the logics internal to the 
VISUALFORCE PAGE LightningGetAllClaims related to Caring Angel

History

3/10/2018     Created 
-------------------------------------------------------------------------------------------*/
public class LightningGetAllClaimsCTRL {
	
	//OAVERSANO 14/03/2019 : AXA Assistance -- START
	public Boolean showTraceMonitoringCase 	{get; set;} 
	public Boolean showNewCreaCase 	{get; set;} 
	public String caseId					{get; set;}
    //MDANTONIO 20/05/2019 : AXA Assistance enh. US-1018-- START
    public String caseRT {get; set;}
    public String urlSFDC {get; set;}
    //MDANTONIO 20/05/2019 : AXA Assistance enh. US-1018-- END
    
    public LightningGetAllClaimsCTRL(){
    	system.debug(' -- LightningGetAllClaimsCTRL constructor start -- ');
        
        showTraceMonitoringCase = false;
        caseId = ApexPages.currentPage().getParameters().get('id');
        urlSFDC = URL.getSalesforceBaseUrl().toExternalForm();
        String CaseType = ApexPages.currentPage().getParameters().get('CaseType');
        system.debug('CaseType: '+CaseType);
        showHideTraceMonitoringCase(caseId, CaseType);
    }
    
	public LightningGetAllClaimsCTRL(String caseId, String caseType){
    	system.debug(' -- LightningGetAllClaimsCTRL constructor start -- ');
        
        showTraceMonitoringCase = false;
        showNewCreaCase=false;
        this.caseId = caseId;        
        showHideTraceMonitoringCase(caseId, CaseType);
    }
    
    public void showHideTraceMonitoringCase(String caseId, String CaseType){
    	
        List<String> profilesEnabled = new List<String>();
        List<String> recordTypesEnabled = new List<String>();
        List<MPS_Code_Utils__mdt> MPSCodeUtilsList = [SELECT Id, DeveloperName, Key__c,Value__c // NOPMD  Fix CRUD violation
							                            FROM MPS_Code_Utils__mdt 
							                            WHERE DeveloperName IN ('LightningGetAllClaimsCTRL_Profiles','LightningGetAllClaimsCTRL_RecordtypesDev') ];
            
        for(MPS_Code_Utils__mdt MPS : MPSCodeUtilsList)
        {
        	if(MPS.DeveloperName == 'LightningGetAllClaimsCTRL_Profiles')
      		{
          		if(String.isNotBlank(MPS.Value__c))
          		{
                  	for(String s:MPS.Value__c.split(';'))
                  	{
                      	profilesEnabled.add(s);
                  	}   
          		}
      		}
      		if(MPS.DeveloperName == 'LightningGetAllClaimsCTRL_RecordtypesDev')
      		{
          		if(String.isNotBlank(MPS.Value__c))
          		{
                  	for(String s:MPS.Value__c.split(';'))
                  	{
                      	recordTypesEnabled.add(s);
                  	}   
          		}
      		}
        }
        if(String.isNotBlank(caseId) && caseId.startsWithIgnoreCase('500'))
        {
	        List<Case> caseList = [SELECT Id, RecordType.DeveloperName, Owner.Profile.Name FROM Case WHERE Id =:caseId ]; // NOPMD  Fix CRUD violation
	        if(!caseList.isEmpty())
	        {
	        	Case cs = caseList[0];
                caseRT = cs.RecordType.DeveloperName;
	        	if(recordTypesEnabled.contains(cs.RecordType.DeveloperName))
	        	{
	        		showTraceMonitoringCase = true;
	        		showNewCreaCase = true;
	        	}
	        }
        }
        else
    	{
    		if(String.isNotBlank(CaseType))
    		{
    			 caseRT = Schema.SObjectType.Case.getRecordTypeInfosById().get(CaseType).getDeveloperName();
    		}
    		String userLogged = UserInfo.getUserId();
    		List<User> userList = [SELECT Id, Profile.Name FROM User WHERE Id =:userLogged ]; // NOPMD  Fix CRUD violation
    		if(!userList.isEmpty())
	        {
	        	User us = userList[0];
	        	if(profilesEnabled.contains(us.Profile.Name))
	        	{
	        		showTraceMonitoringCase = true;
	        	}
				 if(us.Profile.Name.contains('Caring Salute') || us.Profile.Name.contains('AXA Assistance'))
	        	{
	        		showNewCreaCase = true;
	        	}
	        }
    	}
    }
    //OAVERSANO 14/03/2019 : AXA Assistance -- END        
    
    //recupero dei sinistri direttamente su SOL
    @AuraEnabled
    public static IE_GetAllClaimsSOL.ResponseDto getAllClaimsSOLCTRL(String fiscalCode, String policyNumber, String identifiedId,Boolean incompleteReports, String accountId, String rtId, String rtDevName ) { 
    
        system.debug(' -- getAllClaimsSOL start method-- ');
        String kpi;
        String rtDeveloperName ;
        
        if (String.isBlank(rtDevName) && String.isBlank(rtId))
             kpi = [ Select Value__c from KPIGetAllClaimsSOL__mdt WHERE Default__c = true limit 1 ].Value__c;
        else
			{
				if(String.isNotBlank(rtDevName))
					rtDeveloperName= rtDevName;
			else 
				if(String.isNotBlank(rtId))
					rtDeveloperName = [SELECT DeveloperName FROM RECORDTYPE WHERE ID =: rtId LIMIT 1].DeveloperName;

			List <KPIGetAllClaimsSOL__mdt> kpiList = [ Select Id,Default__c,  DeveloperName , RecordTypesDevName__c, Value__c from KPIGetAllClaimsSOL__mdt ]; // NOPMD  Fix CRUD violation

			if(!kpiList.isEmpty()){
				for(KPIGetAllClaimsSOL__mdt k  : kpiList )
				{
					if(String.isNotBlank(k.RecordTypesDevName__c) )
					{
						List<String> devNameRTList = k.RecordTypesDevName__c.split(';'); 
						Set<String> devNameRTSet = new Set<String>();
						devNameRTSet.addAll(devNameRTList);
						
						if(devNameRTSet.contains(rtDeveloperName)){
							kpi=k.Value__c;
							break;
						}
						
					}
				} 
				if( kpi == null ) 
					kpi = [ Select Value__c from KPIGetAllClaimsSOL__mdt WHERE Default__c = true limit 1 ].Value__c;         
			}
            
        }
        
               
        List<String> accountWithPI = new List<String>{'B2B Client', 'Corporate'};
        List<String> accountWithCF = new List<String>{'AAF_B2C', 'B2C Client', 'Individual'};        
        if(String.isBlank(fiscalCode) && String.isNotBlank(accountId))
        {
        	List<Account> accounts = [SELECT Id, Partita_IVA__c, AAI_Partita_IVA__c, Codice_fiscale_ListView__c, Recordtype.Name FROM Account WHERE Id =:accountId];
        	if(!accounts.isEmpty())
        	{
        		Account acc = accounts[0];
        		if(accountWithCF.contains(acc.Recordtype.Name))
        		{
        			fiscalCode = acc.Codice_fiscale_ListView__c;
        		}
        		else if(acc.Recordtype.Name == 'Corporate')
    			{
    				if(String.isNotBlank(acc.Partita_IVA__c))
    				{
    					fiscalCode = acc.Partita_IVA__c;
    				}
    			}
    			else if(acc.Recordtype.Name == 'B2B Client')
    			{
    				if(String.isNotBlank(acc.AAI_Partita_IVA__c))
    				{
    					fiscalCode = acc.AAI_Partita_IVA__c;
    				}
    			}
        	}
        }
   
        IE_GetAllClaimsSOL.ResponseDto response = new IE_GetAllClaimsSOL.ResponseDto();
        response = IE_GetAllClaimsSOL.sendRequest( fiscalCode, policyNumber, kpi, identifiedId, incompleteReports );
        if(response!=null)
        {
        	if(response.deserializedResult !=null)
        	{
       
	        		String hyperlinkToSOL = '';
			        if(MPS_Code_Variables__c.getValues('Caringangel_LinkToSOL')!=null)
					{
						if(String.isNotBlank(MPS_Code_Variables__c.getValues('Caringangel_LinkToSOL').value__c))
						{
							hyperlinkToSOL = MPS_Code_Variables__c.getValues('Caringangel_LinkToSOL').value__c;
						}
					}
	        		for(GetAllClaimsSOLResponse.Claims claim : response.deserializedResult.Claims)
	        		{
                                       
	        			claim.linkToSOL = hyperlinkToSOL+claim.claimId;
	        			claim.linkToSFDC = URL.getSalesforceBaseUrl().toExternalForm()+'/'+claim.idCase;	        			       			
                        claim.policyId = claim.policy.policyNumber;
                        claim.Id = claim.claimNumber;
                        claim.lossNotificationDate = claim.claimNotificationDate;
                        claim.closureDate = claim.claimClosingDate;
                        claim.openIndicator = claim.claimState.isOpen;
                        claim.lossTypeName = claim.claimType.description;        				
	        			
					}
					
					if(response.deserializedResult.IncompleteReports != null){
						for(GetAllClaimsSOLResponse.Claims incompleteReport : response.deserializedResult.IncompleteReports){
							incompleteReport.linkToSOL = hyperlinkToSOL+incompleteReport.claimId;
							incompleteReport.linkToSFDC = URL.getSalesforceBaseUrl().toExternalForm()+'/'+incompleteReport.idCase;	        			       			
							incompleteReport.policyId = incompleteReport.policy.policyNumber;
							incompleteReport.Id = incompleteReport.claimNumber;
							incompleteReport.lossNotificationDate = incompleteReport.claimNotificationDate;
							incompleteReport.closureDate = incompleteReport.claimClosingDate;
							incompleteReport.openIndicator = incompleteReport.claimState.isOpen;
							incompleteReport.lossTypeName = incompleteReport.claimType.description; 
						}
					}
	        	
        	}
        }
        system.debug('getAllClaimsSOLCTRL  --> response: '+response);
        return response;
        
    }
 
  
 

    @AuraEnabled
    public static IE_GetAllClaims.ResponseDto getAllClaimsCTRL(String fiscalCode, String policyNumber, Boolean showPreDenunciations, String accountId, Boolean showIncompleteReports) { 

        system.debug(' -- getAllClaims start method-- ');
        //OAVERSANO 13/03/2019 : AXA Assistance -- START
        List<String> accountWithPI = new List<String>{'B2B Client', 'Corporate'};
        List<String> accountWithCF = new List<String>{'AAF_B2C', 'B2C Client', 'Individual'};        
        if(String.isBlank(fiscalCode) && String.isNotBlank(accountId))
        {
        	List<Account> accounts = [SELECT Id, Partita_IVA__c, AAI_Partita_IVA__c, Codice_fiscale_ListView__c, Recordtype.Name FROM Account WHERE Id =:accountId];
        	if(!accounts.isEmpty())
        	{
        		Account acc = accounts[0];
        		if(accountWithCF.contains(acc.Recordtype.Name))
        		{
        			fiscalCode = acc.Codice_fiscale_ListView__c;
        		}
        		else if(acc.Recordtype.Name == 'Corporate')
    			{
    				if(String.isNotBlank(acc.Partita_IVA__c))
    				{
    					fiscalCode = acc.Partita_IVA__c;
    				}
    			}
    			else if(acc.Recordtype.Name == 'B2B Client')
    			{
    				if(String.isNotBlank(acc.AAI_Partita_IVA__c))
    				{
    					fiscalCode = acc.AAI_Partita_IVA__c;
    				}
    			}
        	}
        }
        //OAVERSANO 13/03/2019 : AXA Assistance -- END
        IE_GetAllClaims.ResponseDto response = new IE_GetAllClaims.ResponseDto();
        response = IE_GetAllClaims.sendRequest(fiscalCode, policyNumber, showPreDenunciations, accountId, showIncompleteReports);
        if(response!=null)
        {
        	if(response.deserializedResults!=null)
        	{
	        	if(!(response.deserializedResults).isempty())
	        	{
	        		String hyperlinkToSOL = '';
			        if(MPS_Code_Variables__c.getValues('Caringangel_LinkToSOL')!=null)
					{
						if(String.isNotBlank(MPS_Code_Variables__c.getValues('Caringangel_LinkToSOL').value__c))
						{
							hyperlinkToSOL = MPS_Code_Variables__c.getValues('Caringangel_LinkToSOL').value__c;
						}
					}
	        		for(GetAllClaimsResponse claim : response.deserializedResults)
	        		{
	        			claim.linkToSOL = hyperlinkToSOL+claim.claimNumber;
	        			claim.linkToSFDC = URL.getSalesforceBaseUrl().toExternalForm()+'/'+claim.idCase;
	        			if(String.isNotBlank(claim.policyId))
	        			{
	        				if(claim.policyId.indexOf('.')!=-1)
	        				{
	                            if(claim.policyId.indexOf('-')!=-1)
	                                claim.policyId = (claim.policyId).substring((claim.policyId).lastIndexOf('.')+1,(claim.policyId).indexOf('-'));
								else
	        						claim.policyId = (claim.policyId).substring((claim.policyId).lastIndexOf('.')+1,claim.policyId.length());
	        				}
	        				
	        			}
	        		}
	        	}
        	}
        }
        system.debug('getAllClaimsCTRL  --> response: '+response);
        return response;
        
    }
    
    //OAVERSANO 14/03/2019 : AXA Assistance -- START
    @AuraEnabled
    public static ResponseDto createCaseMonitoraggio(String originalCase, String selectedCase, String source, String linkToSol, String rtCaseId, String CallerType, String phoneCallId, String phoneCallIDB, String CallDateTime, String claimNumber, Boolean noClaim) { // FOZDEN 26/06/2019: AXA Assistance Enhancement Fase II

        system.debug(' -- createCaseMonitoraggio start method-- ');
		ResponseDto response = new ResponseDto();
        Boolean switchRecordTypeSelection = false;
        String CurrentUserProfile = [SELECT Name FROM Profile WHERE id=:Userinfo.getProfileId()].Name;
        List<MPS_Code_Utils__mdt> MPSCodeUtilsList = [SELECT Id, DeveloperName, Key__c,Value__c // NOPMD  Fix CRUD violation
							                            FROM MPS_Code_Utils__mdt 
							                            WHERE DeveloperName IN ('QuestionarioRecordTypeSelection') ];
            
        for(MPS_Code_Utils__mdt MPS : MPSCodeUtilsList)
        {
        	if(MPS.DeveloperName == 'QuestionarioRecordTypeSelection')
      		{
          		if(String.isNotBlank(MPS.Value__c) && MPS.Value__c == 'true' && String.isNotBlank(MPS.Key__c) && MPS.Key__c.contains(CurrentUserProfile))
          		{
                    switchRecordTypeSelection = true;
          		}
      		}
        }
        response.values.put('switchRecordTypeSelection', switchRecordTypeSelection);
		Case caseToUpsert;
		String method;
		//Case opened by phone
		if(String.isNotBlank(source) && source.equalsIgnoreCase('Phone'))
		{
			//OAVERSANO 17/05/2019 : AXA Assistance Enhancement Fase I -- START
            String LOBSinitri = '';
			String CategoryMonitoring = '';

			// FOZDEN 27/06/2019: Axa Assistance Enhancement Fase II -- START
			if (noClaim) {

				if (MPS_Code_Variables__c.getValues('prepopulatedLOBSenzaSinistro') != null &&
						String.isNotBlank(MPS_Code_Variables__c.getValues('prepopulatedLOBSenzaSinistro').Value__c)) {
					LOBSinitri = MPS_Code_Variables__c.getValues('prepopulatedLOBSenzaSinistro').Value__c;
				}

				if (MPS_Code_Variables__c.getValues('prepopulatedCategorySenzaSinistro') != null &&
						String.isNotBlank(MPS_Code_Variables__c.getValues('prepopulatedCategorySenzaSinistro').Value__c)) {
					CategoryMonitoring = MPS_Code_Variables__c.getValues('prepopulatedCategorySenzaSinistro').Value__c;
				}

			} else { // FOZDEN 27/06/2019: Axa Assistance Enhancement Fase II -- END

				if (MPS_Code_Variables__c.getValues('prepopulatedLOBSinistri') != null) {
					if (String.isNotBlank(MPS_Code_Variables__c.getValues('prepopulatedLOBSinistri').Value__c)) {
						LOBSinitri = MPS_Code_Variables__c.getValues('prepopulatedLOBSinistri').Value__c;
					}
				}
				if (MPS_Code_Variables__c.getValues('prepopulatedCategoryMonitoring') != null) {
					if (String.isNotBlank(MPS_Code_Variables__c.getValues('prepopulatedCategoryMonitoring').Value__c)) {
						CategoryMonitoring = MPS_Code_Variables__c.getValues('prepopulatedCategoryMonitoring').Value__c;
					}
				}
			}
            
            String caseRT ='';
            List<Case> caseList = [SELECT Id, RecordType.DeveloperName, Owner.Profile.Name FROM Case WHERE Id =:selectedCase ]; // NOPMD  Fix CRUD violation
            if(!caseList.isEmpty())
            {
                Case cs = caseList[0];
                caseRT = cs.RecordType.DeveloperName;
                
            }
         

		    //OAVERSANO 17/05/2019 : AXA Assistance Enhancement Fase I -- END
			//There isn't a case associated to the claim
			if(String.isBlank(selectedCase) || caseRT.equals('Caring_Angel'))
			{
                system.debug('redirectToNewCase');
                //OAVERSANO 17/05/2019 : AXA Assistance Enhancement Fase I -- START
			    response.values.put('lobValue', LOBSinitri);
			    response.values.put('categoryValue', CategoryMonitoring);
			    //OAVERSANO 17/05/2019 : AXA Assistance Enhancement Fase I -- END
                response.isSuccess = true;
                response.values.put('switchRecordTypeSelection', switchRecordTypeSelection);
                response.values.put('CallerType', CallerType);
                response.values.put('rtCaseId', rtCaseId);
                if(String.isNotBlank(phoneCallId))
        		{
            		if(String.isblank(CallDateTime))
                		response.values.put('phone_callIds', phoneCallId);
            		else
        			{
                		if(String.isNotBlank(phoneCallIDB))
                			response.values.put('phone_callIds', phoneCallId+'_'+CallDateTime+'_'+phoneCallIDB);
                		else
                			response.values.put('phone_callIds', phoneCallId+'_'+CallDateTime);
            		}
        		}
                if(!switchRecordTypeSelection)
                {
                    if(rtCaseId == Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('AXA_Caring_Salute').getRecordTypeId())
                       response.values.put('SinistriDanniBancaRecordTypeId', rtCaseId);
                    else
					{
                       Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Sinistri_Danni_Banca').getRecordTypeId();
                       response.values.put('SinistriDanniBancaRecordTypeId', devRecordTypeId);   
                    }   
                }                
                response.values.put('caseType', 'Monitoraggio');
                if(String.isNotBlank(linkToSol)) response.values.put('linkToSOL','<a href="'+linkToSol+'" >Visualizza su SOL</a>');
                if(String.isNotblank(claimNumber)) response.values.put('claimNumber', claimNumber);
				response.values.put('redirectToNewCase', 'true');
			}
			//There is a case associated to the claim
			else if(String.isNotBlank(selectedCase) && selectedCase.startsWithIgnoreCase('500')) 
			{
				List<Case> selectedCaseList = [SELECT Id, RecordTypeId, AccountId FROM Case WHERE Id=:selectedCase];
				if(!selectedCaseList.isEmpty())
				{
					Case cs = selectedCaseList[0];
					caseToUpsert = new Case();
					caseToUpsert.Origin = AP_Constants.caseOriginPhone;
					caseToUpsert.AccountId = (cs.AccountId!=null)?cs.AccountId:null;
					caseToUpsert.RecordTypeId = cs.RecordTypeId;
                    caseToUpsert.Complainant__c = (String.isNotBlank(CallerType))?CallerType:'';
                    caseToUpsert.ParentId = selectedCase;
                    //OAVERSANO 17/05/2019 : AXA Assistance Enhancement Fase I -- START
                    caseToUpsert.LOB__c = LOBSinitri;
                    caseToUpsert.Category__c = CategoryMonitoring;
                    //OAVERSANO 17/05/2019 : AXA Assistance Enhancement Fase I -- END
                    if(String.isNotBlank(phoneCallId))
            		{
                		if(String.isblank(CallDateTime))
                    		caseToUpsert.Phone_Call_Ids__c = phoneCallId;
                		else
            			{
                    		if(String.isNotBlank(phoneCallIDB))
                        		caseToUpsert.Phone_Call_Ids__c = phoneCallId+'_'+CallDateTime+'_'+phoneCallIDB;
                    		else
                        		caseToUpsert.Phone_Call_Ids__c = phoneCallId+'_'+CallDateTime;
                		}
            		}
					method = 'insert';
				}
				else
				{
					response.isSuccess = false;
					response.message = 'Attenzione ! Non è al momento possibile tracciare il case di monitoraggio, ti chiediamo di riprovare più tardi. Di seguito il dettaglio dell\'errore: \n Il case selezionato non risulta presente nel CRM.\n Se il problema persiste contatta il tuo referente AXA.';
				}
			}
            else
            {
                response.isSuccess = false;
                response.message = 'Attenzione ! Non è al momento possibile tracciare il case di monitoraggio, ti chiediamo di riprovare più tardi. Di seguito il dettaglio dell\'errore: \n Il case selezionato non risulta presente nel CRM.\n Se il problema persiste contatta il tuo referente AXA.';
            }
        }
		//Case opened by other channels
		else if(String.isNotBlank(originalCase) && originalCase.startsWithIgnoreCase('500'))
		{
			caseToUpsert = [SELECT Id, CaseNumber FROM Case WHERE Id=:originalCase];
			caseToUpsert.Id = originalCase;
			if(String.isNotBlank(selectedCase) && selectedCase.startsWithIgnoreCase('500'))
			{
				caseToUpsert.ParentId = selectedCase;
			}
			method = 'update';
		}
		else
		{
			response.isSuccess = false;
			response.message = 'Attenzione ! Non è al momento possibile tracciare il case di monitoraggio, ti chiediamo di riprovare più tardi. Di seguito il dettaglio dell\'errore: \n Il case selezionato non è stato trovato nel CRM.\n Se il problema persiste contatta il tuo referente AXA.';
		}
		if(caseToUpsert!=null)
		{
            caseToUpsert.Numero_Sinistro__c = (String.isNotBlank(claimNumber))?(String)claimNumber:'';
			caseToUpsert.Visualizza_sinistro__c = '<a href="'+linkToSol+'" >Visualizza su SOL</a>';
            caseToUpsert.Type = 'Monitoraggio';
			try{
				upsert caseToUpsert;
				if(method == 'insert')
				{
					Case cs = [SELECT id, Casenumber FROM Case WHERE Id=:caseToUpsert.Id];
					if(cs!=null)
						response.values.put('casenumber', cs.Casenumber);
				}
				else if(method == 'update')
				{
					response.values.put('casenumber', caseToUpsert.Casenumber);
				}
				response.isSuccess = true;
				response.values.put('method', method);
				response.values.put('caseIdUpserted', caseToUpsert.Id);
			}
			catch(Exception ex)
			{
				response.isSuccess = false;
				response.message = 'Attenzione ! Non è al momento possibile tracciare il case di monitoraggio, ti chiediamo di riprovare più tardi. Di seguito il dettaglio dell\'errore: \n '+ex.getMessage()+'.\n Se il problema persiste contatta il tuo referente AXA.';
			}
		}
		
        return response;
        
    }

    @AuraEnabled
    public static ResponseDto getClaimRelatedCases(String claimNumber, String caseId){
        system.debug('===> getClaimRelatedCases start');
        system.debug('===> claimNumber: ' + claimNumber);
        system.debug('===> caseId: ' + caseId);
        ResponseDto response = new ResponseDto();
        List<Case> cases = [SELECT Id, CaseNumber, Oggetto_Apertura_Case__c, Description, Recordtype.DeveloperName FROM Case WHERE (Recordtype.DeveloperName = 'Sinistri_AAI' OR Recordtype.DeveloperName = 'Sinistri_Danni_Banca' OR Recordtype.DeveloperName='AXA_Caring_Salute') AND ((Numero_Sinistro__c != null AND Numero_Sinistro__c = :claimNumber) OR Id = :caseId)];
        system.debug('===> casesList: ' + cases);
        if(cases.size() > 0){
            response.values.put('caseList', cases);
            response.isSuccess = true;
        }
        else{
            response.isSuccess = false;
            response.message = 'Non sono presenti case associati al sinistro selezionato';
        }
        return response;
    }
    
	@AuraEnabled
	public static ResponseDto getNewCase(Map<String, String> params, String accountId){
        system.debug('===> getNewCase start');    
        ResponseDto response = new ResponseDto();
        try{
            String lobToCase 			= params.get('LOB');
            String callerToCase 		= params.get('Caller');
            
            Case caseData 				= new Case();
            
            caseData.Origin 			= AP_Constants.caseOriginPhone;
            caseData.RecordTypeId 		= Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(params.get('RecordType')).getRecordTypeId(); 
            caseData.Complainant__c 	= callerToCase;
            caseData.Lob__c				= lobToCase; 
            
            caseData.Status = AP_Constants.caseStatusAssigned;
            
            
            Database.SaveResult resultInsert = Database.insert(caseData);   
            if (resultInsert.isSuccess())
                response.values.put('CaseId', resultInsert.getId());           
            
            response.isSuccess = true;
        }catch(Exception ex){
            response.isSuccess = false;
            response.message =  ex.getMessage();	
        }
        
	    system.debug('===> getNewCase end '+ response);    
        return response;
    }
    
    public class ResponseDto { // Object to better handle errors from http://blog.terrasky.com/blog/how-to-handle-apex-errors-for-lightning-component-implementations
        @AuraEnabled public Boolean isSuccess { get; set; }
        @AuraEnabled public String message { get; set; }
        @AuraEnabled public Map<Object, Object> values { get; set; }
        public ResponseDto(Boolean isSuccess, String msg){
            this.isSuccess = isSuccess;
            this.message = msg;
            this.values = new Map<Object, Object>();
        }   
        
        public ResponseDto(){
            this.isSuccess = False;
            this.message = '';
            this.values = new Map<Object, Object>();
        }       
    }
    //OAVERSANO 14/03/2019 : AXA Assistance -- END
	    @AuraEnabled  
    public static LghtInitComponentResponse initComponent (String caseId, String CaseType){
        LghtInitComponentResponse response = new LghtInitComponentResponse();
        LightningGetAllClaimsCTRL instance = new LightningGetAllClaimsCTRL(caseId, CaseType);
        response.showNewCreaCase= instance.showNewCreaCase;
        response.showTraceMonitoringCase = instance.showTraceMonitoringCase;   

      return response;        
        
    }
    
    	public class LghtInitComponentResponse{
		@AuraEnabled public Boolean showNewCreaCase ;
		@AuraEnabled public Boolean showTraceMonitoringCase;

	}

	@AuraEnabled
    public static String createCaseMonitoringLightning(String originalCase, String selectedCase, String source, String linkToSol, String caseRT, String CallerType, String phoneCallId, String phoneCallIDB, String CallDateTime, String claimNumber, Boolean isAssocia, Boolean noClaim, String accountId) {
	   	System.Debug('isAssocia '+isAssocia);
        String errMessage='Attenzione ! Non è al momento possibile tracciare il case di monitoraggio, ti chiediamo di riprovare più tardi. Se il problema persiste contatta il tuo referente AXA.';
		String rtCaseId = RecordTypeUtility.getRecordTypeIdByDeveloperName('Case', caseRT);
		ResponseDto response = LightningGetAllClaimsCTRL.createCaseMonitoraggio(originalCase, selectedCase, source, linkToSol, rtCaseId, CallerType, phoneCallId, phoneCallIDB, CallDateTime, claimNumber, noClaim);
	  if(!response.isSuccess){ 
		throw new AuraHandledException(errMessage);
	  } 
	  if(String.isNotBlank((String) response.values.get('CaseId'))){
		return (String) response.values.get('CaseId');
	  }
	  System.debug('resp value :'+response.values.get('redirectToNewCase'));
	  if(response.values.get('redirectToNewCase') != null && Boolean.valueOf(response.values.get('redirectToNewCase'))){
			// crea un case come questa url
			Case c = new Case();
			c.Origin = 'Phone';
			c.Type = 'Monitoraggio';
			c.Lob__c = (String) response.values.get('lobValue');
			c.Category__c = (String) response.values.get('categoryValue');
			c.Phone_Call_Ids__c = (String) response.values.get('phone_callIds');
			if(String.isNotBlank(accountId)){
				c.AccountId = accountId;
			}
			c.RecordTypeId = rtCaseId;
			if(noClaim == false) {
				c.Complainant__c = (String) response.values.get('CallerType');
				c.Numero_Sinistro__c = (String) response.values.get('claimNumber');
				c.Visualizza_sinistro__c = (String) response.values.get('linkToSOL');
			} 
			insert c;
			return c.Id;
	  } else {
		  if(isAssocia) return null;
		  else throw new AuraHandledException(errMessage);
	  }
	}
	
	@AuraEnabled
	public static String createCaseLightning(Map<String, String> params, String accountId){
		ResponseDto response = LightningGetAllClaimsCTRL.getNewCase(params, accountId);
		if(!response.isSuccess){
			throw new AuraHandledException('Attenzione ! Non è al momento possibile tracciare il case, ti chiediamo di riprovare più tardi. Se il problema persiste contatta il tuo referente AXA.');
		} else {
			return (String) response.values.get('CaseId');
		}
	}

	@AuraEnabled
	public static responseWrapper loadClaims(String accountId,Integer limite){
		FilterValuesService filterValueService = new FilterValuesService('SchedaClienteSinistro');
		responseWrapper response =new responseWrapper ();
		List<Claim__c> listaOut = new List<Claim__c>();
		Set<String> workFlowEtlNew = filterValueService.filterByField('TECH_WorkFlow_ETL__c').getValuesAndReset();

		if(String.isBlank(String.valueOf(limite))){
			limite=5;
		}
		if(accountId!=null){
			listaOut = [select Id,Name,Claim_Type__c,Ramo__c,Status__c, 
			cdesc_esito_sinistro__c,Policy_Code__c,Opening_Date__c, hyperlinkToSOL__c,
			ddenuncia__c,cnum_Claim__c,cdesc_evento__c,
			Closing_Date__c,Reimboursment__c,Reimboursment_Date__c 
			from Claim__c 
			where TECH_WorkFlow_ETL__c in: workFlowEtlNew
			AND Account__c =: accountId 
			AND isHidden__c = false
			WITH SYSTEM_MODE limit:limite]; // lazyCounter +10 fino a Counter (tutti records)
			response.listaOut = listaOut ;
			response.counter = getCount(accountId,workFlowEtlNew);// counter per limitare il lazyLoad
		 }else { 
			response.listaOut = new List<Claim__c>() ;
			response.counter = 0;// not used on front end 
		 }
		return response;
	}
    public static Integer getCount(String accountId,Set<String> workFlowEtlNew){
        AggregateResult results = [SELECT Count(Id) Counter 
		FROM Claim__c
		where  TECH_WorkFlow_ETL__c in: workFlowEtlNew AND Account__c =: accountId AND isHidden__c = false];
        return ((Integer) results.get('Counter'));
    }
	public class responseWrapper {
		@AuraEnabled
		public List<Claim__c> listaOut;
		@AuraEnabled
		public Integer counter;
	} 
}