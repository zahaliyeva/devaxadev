public  class CaseToMySelfCommunityCTL {
    
    
    @AuraEnabled
    public static Case UpdateCase(String CaseId) { 
        system.debug('GetCaseInfo');
        
        Case CasetoReturn;
        
        if (String.isNotBlank(CaseId)) {            
            List<Case> listaCase = [SELECT Id, OwnerId, QueueNameOwner__c, Recordtype.Name, Status FROM Case WHERE Id =:CaseId LIMIT 1];
            
            CasetoReturn = (listaCase != null && !listaCase.isEmpty()) ?  listaCase[0] : null;
            if (CasetoReturn != null) {
                String profileName =  CasetoReturn.QueueNameOwner__c;
                List<User> listUsers = [SELECT Id, Profile.Name, Abilitazione_CTL__c, Abilitazione_IVASS41__c FROM User WHERE id =: userInfo.getUserId() LIMIT 1];
                if (listUsers != null && !listUsers.isEmpty() && profileName != null && profileName.contains('Coda_Agenzia_Case')) {
                    if((AP_Constants.rtCaseAAIName.equals(caseToReturn.Recordtype.Name) && listUsers[0].Abilitazione_IVASS41__c) ||
                       AP_Constants.rtCaseCloseTheLoop.equals(CaseToReturn.Recordtype.Name) && listUsers[0].Abilitazione_CTL__c){
                    CasetoReturn.OwnerId = listUsers[0].Id;
                    casetoReturn.Status = 'In gestione all’Agenzia';
                    update CasetoReturn;
                       }
                    else{
                        String m = 'Attenzione ! Non hai l\'abilitazione per lavorare questo tipo di case';
                    	AuraHandledException e = new AuraHandledException(m);
                    	e.setMessage(m);
                    	throw e;
                    }
                } else {
                    String m = 'Attenzione ! É possibile prendere in carico il case solo se è in carico alla propria agenzia';
                    AuraHandledException e = new AuraHandledException(m);
                    e.setMessage(m);
                    throw e;
                }
            } else {
                String m = 'Attenzione! Non è possibile prendere in carico il case. Identificativo non corretto.';
                AuraHandledException e = new AuraHandledException(m);
                e.setMessage(m);
                throw e;
         	}
    	} 
        
        return CasetoReturn;
		
    }
}