public class VFC33_SendDocumentValidationCTRL {

    @AuraEnabled
    public static IE_DocumentValidation.ResponseDto sendDocumentValidationCTRL(String caseId) {

        System.debug(' -- sendDocumentValidationCTRL start method-- ');

        Boolean isSuccess = false;
        Integer statusCode = 0;
        String message = 'Attenzione! Si è verificato un errore. Si prega di riprovare più tardi';
        Case cs;
		Boolean performDML = false;
        List<MPS_Code_Utils__mdt> mpsCodeUtils = [
                SELECT DeveloperName, Key__c, Value__c
                FROM MPS_Code_Utils__mdt
                WHERE DeveloperName LIKE 'ValidazioneVisuraCameraleMessage%'
                AND Key__c != NULL
                AND Value__c != NULL
        ];

        Map<String, String> messageMap = new Map <String, String>();
        for (MPS_Code_Utils__mdt mps : mpsCodeUtils) {
            messageMap.put(mps.Key__c, mps.Value__c);
        }

        try {

            if (String.isNotBlank(caseId) && caseId.startsWith('500')) {

                List<Case> selectedCase = [SELECT Id, Status, Category__c, SubCategory__c, OwnerId, TECH_Visura_Camerale_validata__c FROM Case WHERE Id = :caseId];

                if (!selectedCase.isEmpty()) {

                    List<String> closedStatus = new List<String>();
                    for (MPS_Code_Variables__c MPSCv : MPS_Code_Variables__c.getAll().values()) {
                        if ((MPSCv.Name).equalsIgnoreCase('SitoImpresa_closedStatusCase')) {
                            if (String.isNotBlank(MPSCv.Value__c)) {
                                for (String s : MPSCv.Value__c.split(';')) {
                                    closedStatus.add(s);
                                }
                            }
                        }
                    }

                    cs = selectedCase[0];

                    if(cs.OwnerId != UserInfo.getUserId()){
                    	isSuccess = false;
                        statusCode = 123;

                        if (messageMap.containsKey('OwnerId')) {
                            message = messageMap.get('OwnerId');
                        }
                    } else if (closedStatus.contains(cs.Status)) { // CASE ALREADY CLOSED

                        isSuccess = false;
                        statusCode = 888;

                        if (messageMap.containsKey('Closed')) {
                            message = messageMap.get('Closed');
                        }

                    } else if (String.isEmpty(cs.Category__c) || String.isEmpty(cs.SubCategory__c)) { // EMPTY CATEGORY/SUB-CATEGORY

                        isSuccess = false;
                        statusCode = 777;
                        if (messageMap.containsKey('Category')) {
                            message = messageMap.get('Category');
                        }

                    } else { // SERVICE CALL

                       	/*Savepoint spOK = Database.setSavepoint();
                       	try{
                       		system.debug('Savepoint');
                       		performDML = true;
                       		cs.Status = 'Closed';
                            update cs;
                            Database.rollback(spOK);
                            
                       	} catch(Exception ex){
                   			statusCode = 000;
                   			performDML = false;
			            	if (messageMap.containsKey('ServiceError')) {
			                	message = messageMap.get('ServiceError') + ' ' + ex.getMessage();
			            	}
                   		}
                   		if(performDML){
	   						IE_DocumentValidation.ResponseDto response = IE_DocumentValidation.sendRequest(cs.Id);
	                    	isSuccess = response.isSuccess;
	                    	statusCode = response.statusCode;
	                    	message = response.message;
	
	                    	if (response.isSuccess) { // SUCCESS
	
	                        	if (messageMap.containsKey('Created')) {
	                               		message = messageMap.get('Created');
	                               		cs.Status = 'Closed';
	                               		update cs;
	                            	}
	                   		} else { // FAILURE
								
	                            if (response.statusCode == 999) {
	                                if (messageMap.containsKey('MissingArguments')) {
	                                    message = messageMap.get('MissingArguments');
	                                }
	                            } else {
	                                if (messageMap.containsKey('ServiceError')) {
	                                    message = messageMap.get('ServiceError') + ' ' + response.message;
	                                }
	                            }
	                    	}
	                    	
                   		}*/
                        IE_DocumentValidation.ResponseDto response;
                        system.debug('cs.TECH_Visura_Camerale_validata__c: '+cs.TECH_Visura_Camerale_validata__c);
                        if(cs.TECH_Visura_Camerale_validata__c){
                        	response = new IE_DocumentValidation.ResponseDto();
                        	response.isSuccess = true;
                        	response.statusCode = 456;
                        	response.message = 'Validazione già eseguita su PCC/MyAXA. Necessaria chiusura case su Salesforce.';
                        } else {
                        	response = IE_DocumentValidation.sendRequest(cs.Id);
                        }
						isSuccess = response.isSuccess;
                        statusCode = response.statusCode;
                        message = response.message;
                        if (response.isSuccess) { // SUCCESS

                            if (messageMap.containsKey('Created')) {
                                message = messageMap.get('Created');
                            }
                            cs.Status = 'Closed';
                            cs.TECH_Visura_Camerale_validata__c = true;
                            update cs;

                        } else { // FAILURE

                            if (response.statusCode == 999) {
                                if (messageMap.containsKey('MissingArguments')) {
                                    message = messageMap.get('MissingArguments');
                                }
                            } else if (response.statusCode == 987) {
                                if (messageMap.containsKey('TranscodeParameter')) {
                                    message = messageMap.get('TranscodeParameter');
                                }
                            } 
                            else {
                                if (messageMap.containsKey('ServiceError')) {
                                	if(response.message == 'Divide by 0')
                                		response.message = 'Contattare l\'amministratore del sistema.';
                                    message = messageMap.get('ServiceError') + ' ' + response.message;
                                }
                            }
                        }
                    }

                } else { // CASE NON FOUND

                    isSuccess = false;
                    statusCode = 666;
                    if (messageMap.containsKey('NotFound')) {
                        message = messageMap.get('NotFound');
                    }
                }

            } else { // EMPTY CASE

                isSuccess = false;
                statusCode = 555;
                if (messageMap.containsKey('Empty')) {
                    message = messageMap.get('Empty');
                }
            }
			

        } catch (Exception e) {

            System.debug(e.getMessage());
            if(isSuccess){
            	Case cstoUpdate = new Case(id = cs.Id);
            	cstoUpdate.TECH_Visura_Camerale_validata__c = true;
            	update cstoUpdate;
            }
            isSuccess = false;
            statusCode = 111;
            if (messageMap.containsKey('ServiceError')) {
                message = messageMap.get('ServiceError') + ' ' + e.getMessage();
            }
        }

        IE_DocumentValidation.ResponseDto responseDto = new IE_DocumentValidation.ResponseDto(isSuccess, statusCode, message);
        System.debug('sendDocumentValidationCTRL  --> response: ' + responseDto);
        return responseDto;
    }

    @AuraEnabled
    public static Boolean hasAssociatePolicy(String caseId) {
        Case c = [SELECT Id, LinkToPolicy__c from Case where Id = :caseId];
        return String.isNotBlank(c.LinkToPolicy__c);
    }

    @AuraEnabled
    public static list<String> polizzaAndCompany(String caseId) {
        list<String> lista_polizza_compa = new list<string>();
        Case c = [SELECT Id,Compagnia_Polizze__c, Polizza_Registrazione_PG__c from Case where Id = :caseId];
        if(String.isNotBlank(c.Compagnia_Polizze__c) && String.isNotBlank(c.Polizza_Registrazione_PG__c)){
            lista_polizza_compa.add(c.Compagnia_Polizze__c);
            lista_polizza_compa.add(c.Polizza_Registrazione_PG__c);            
        }
        return lista_polizza_compa ;
    }

    @AuraEnabled 
    public static void associatePolicy(String caseId, String policyNumber, String techCompany) {
        if(String.isBlank(caseId)){
            throw new AuraHandledException('L\' Id del Case non è valorizzato');
        }
        if(String.isBlank(policyNumber)){
            throw new AuraHandledException('Numero Polizza non valorizzato');
        }
        if(policyNumber.length() >= 80){
            throw new AuraHandledException('Numero Polizza non deve superare 80 caratteri');
        }
        if(String.isBlank(techCompany)){
            throw new AuraHandledException('Compagnia non valorizzata');
        }
        Case c = [SELECT Id, AccountId from Case where Id = :caseId];
        //InsurancePolicy__c policy = new InsurancePolicy__c(Name = policyNumber, TECH_Company__c = techCompany, CUID__c = c.AccountId);
        //insert policy;
        c.Polizza_Registrazione_PG__c  = policyNumber ;
        c.Compagnia_Polizze__c = techCompany;
        
        update c;
    }
    
}