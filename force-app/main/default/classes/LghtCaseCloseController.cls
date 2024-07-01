public with sharing class LghtCaseCloseController extends RLY_Behaviour{
	
	public class LghtCaseCloseException extends Exception {}

	public class LghtCaseCloseResponse extends LghtResponse{
		@AuraEnabled public Case caseData;
	}

	@AuraEnabled
	public static LghtCaseCloseResponse updateCase(Case caseData){
		DebugStart('LghtCaseCloseController', 'updateCase');
		LghtCaseCloseResponse response = new LghtCaseCloseResponse();
		Case myCase = [SELECT id, Current_Owner_Queue__c, Silva_Id__c, Subject, Application_EAGP__r.External_Id__c, CaseNumber,SuppliedEmail, Description, Tipologia_Ticket_Silva__c, Application_EAGP__c, Stato_Integrazione_Silva__c, Application_EAGP__r.Silva_Integration__c,Application_EAGP__r.Prefix__c, Silva_Assignment_Group__c FROM Case WHERE id =: caseData.ID]; // NOPMD  Fix CRUD
		Map<String, Object> caseDataMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(caseData));
		Map<String, Object> myCaseMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(myCase));
		caseDataMap.putAll(myCaseMap);
		caseData = (Case) JSON.deserialize(JSON.serialize(caseDataMap), Case.class);
		List<MPS_Code_Utils__mdt> mpsList = [SELECT Id, DeveloperName, Value__c, High_Volume_Values__c // NOPMD  Fix CRUD
                            FROM MPS_Code_Utils__mdt 
                            WHERE DeveloperName LIKE 'Tag_Richiesta_Not_Needs_Silva%'
                            ];
        List<String> TagRichiestaNotNeedsSilva = new List<String>();
        for(MPS_Code_Utils__mdt mps : mpsList){
            TagRichiestaNotNeedsSilva.add(mps.Value__c);
        }
		try{
            System.debug('SILVA TEST caseData.Silva_Id__c ' + caseData.Silva_Id__c);
            System.debug('SILVA TEST caseData.Tipologia_Ticket_Silva__c ' + caseData.Tipologia_Ticket_Silva__c);
            System.debug('SILVA TEST caseData.Application_EAGP__c ' + caseData.Application_EAGP__c);
            System.debug('SILVA TEST caseData.Stato_Integrazione_Silva__c ' + caseData.Stato_Integrazione_Silva__c);
            System.debug('SILVA TEST caseData.Application_EAGP__r.Silva_Integration__c ' + caseData.Application_EAGP__r.Silva_Integration__c);
			
			if(caseData.Current_Owner_Queue__c.startsWith('HD2_IT') && !TagRichiestaNotNeedsSilva.contains(caseData.Tag_richiesta__c) && (caseData.Tipologia_Ticket_Silva__c == null || caseData.Application_EAGP__c == null)){
				Debug('Error', 'Compilare i campi Nome Applicazione e Tipologia Ticket Silva attraverso il pulsante Compila Ticket Silva.');
				response.errorMessage = 'Compilare i campi Nome Applicazione e Tipologia Ticket Silva attraverso il pulsante Compila Ticket Silva.';
				return response;
			} 
			if(caseData.Silva_Id__c == null && caseData.Tipologia_Ticket_Silva__c != null && caseData.Application_EAGP__c != null && caseData.Stato_Integrazione_Silva__c != 'Success' && caseData.Application_EAGP__r.Silva_Integration__c == true){
                HttpResponse silvaResponse = CreateSilvaTicket.createRequest(caseData);
            	String respString = silvaResponse.getBody();
				update caseData;
				if(SILVA_Utility.isSilvaSuccess(respString) == true){
					response.isSuccess = true;
				} else {
					Debug('Error', 'Errore in fase di inserimento automatico del Ticket su Silva, si richiede di contattare l’amministratore di sistema Salesforce');
					response.errorMessage = 'Errore in fase di inserimento automatico del Ticket su Silva, si richiede di contattare l’amministratore di sistema Salesforce';
				}				
            } else {
				update caseData;
				response.isSuccess = true;
			}		
		}catch(LghtCaseCloseException ex){
			Debug('Exception', ex.getStackTraceString());
			response.errorMessage = ex.getMessage();
		}catch(Exception ex){
			Debug('Exception', ex.getStackTraceString());
			response.errorMessage = ex.getMessage();
		}

		Debug('response', response);
		DebugEnd();
		return response;
	}
    
}