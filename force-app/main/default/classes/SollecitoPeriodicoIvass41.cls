public without sharing class SollecitoPeriodicoIvass41 {
  
    
	@InvocableMethod(label = 'Sollecito Periodico')
    public static void updateRecord(List<Case> CaseToUpdate){
        List<ID> l = new List<ID>();
        for(Case c : CaseToUpdate){
            l.add(c.ID);
        }
        UpdateCase(l);
    }
    
    
    public static boolean UpdateUsers(List<User> userToUpdate){
        try{
            Update userToUpdate;
        }
        catch(DMLException e){
            system.debug('Exception: '+ e.getCause() + '\nMessage: '+e.getMessage()+ '\nStack: '+e.getStackTraceString());
            return false;
        }
        return true;
    }
    @future
    public static void UpdateCase(List<ID> CaseList){
        
        List<Case> CaseToUpdateList = [Select ID,ContatoreIvass41__c from case where ID in:CaseList];
        String defaultHoursId = MPS_Code_variables__c.getValues('BusinessHours_Default').value__c;
        List<String> Hours = MPS_Code_Variables__c.getValues('Ivass41Solleciti').value__c.split(';');
        List<Case> FinalList = new List<Case>();
        Double hoursToAdd = 0;
		
      	if(Hours != null){ //codice gabri
            hoursToAdd = Double.valueOf(Hours[2]);
            
            
        }
        for(Case CaseToUpdate: CaseToUpdateList){
            
            if(CaseToUpdate.ContatoreIvass41__c == null || CaseToUpdate.ContatoreIvass41__c < 5){
        	CaseToUpdate.ContatoreIvass41__c = CaseToUpdate.ContatoreIvass41__c == null? 1 : CaseToUpdate.ContatoreIvass41__c + 1;
            CaseToUpdate.SollecitoPeriodico20ore__c = BusinessHours.addGMT(defaultHoursId,System.now(),((hoursToAdd)*60 * 60 * 1000L).longValue());
                FinalList.add(CaseToUpdate);
            }
            else if(CaseToUpdate.ContatoreIvass41__c == 5){
                CaseToUpdate.ContatoreIvass41__c += 1;
                CaseToUpdate.SollecitoPeriodico20ore__c = null;
            CaseToUpdate.status = AP_Constants.caseStatusChiusoInAutonomia;
                FinalList.add(CaseToUpdate);
            }
        }
        
        if(FinalList.size()!=0)
            update FinalList;
            
        
        
        
    }
}