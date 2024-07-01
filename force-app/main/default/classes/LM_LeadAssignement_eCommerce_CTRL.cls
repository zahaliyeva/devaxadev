public with sharing class LM_LeadAssignement_eCommerce_CTRL {
    
    public String relatedToLeadSessionId {get;set;}
    public Id relatedToLeadId {get;set;}

    public LM_LeadAssignement_eCommerce_CTRL() {}

    public String getPolicyNumber(){        
    
        List<Quotazione__c> quotations = [SELECT Id, Proposal_Code__c FROM Quotazione__c WHERE ID_Session__c = :relatedToLeadSessionId LIMIT 1];
        String policyCode = '';
 
        if (quotations.size() >0){
            Quotazione__c quotation = quotations[0];
            
            if (quotation.Proposal_Code__c != '' && quotation.Proposal_Code__c != null){                
                policyCode = quotation.Proposal_Code__c;                
            }
            
            return ' ' + policyCode;

        } else {            
            String ErrorInfo = '';
            ErrorInfo = 'Nessun Lead di riferimento trovato';           
            return ErrorInfo;
        }
    
    }

    public String getPremium(){
    
        List<Quotazione__c> quotations = [SELECT Id, Premium__c FROM Quotazione__c WHERE ID_Session__c = :relatedToLeadSessionId LIMIT 1];
        Decimal premium = 0;
 
        if (quotations.size() >0){
            Quotazione__c quotation = quotations[0];
            
            if (quotation.Premium__c != null){                
                premium = quotation.Premium__c;                
            }
            
            return ' ' + premium;

        } else {
            
            String ErrorInfo = '';
            ErrorInfo = 'Nessun Lead di riferimento trovato';           
            return ErrorInfo;
        }
    
    }

    public String getLeadDataCreation(){
    
        List<Lead> leads = [SELECT Id, Creation_date_and_time__c FROM Lead WHERE Id = :relatedToLeadId LIMIT 1];
        String leadDataCreation = '';
 
        if (leads.size() >0){
            Lead lead = leads[0];
            
            if (lead.Creation_date_and_time__c != null){    
                Datetime dt = lead.Creation_date_and_time__c;
                leadDataCreation = dt.format('EEEE dd MMMM, ', 'Europe/London').toLowerCase() + 'ore ' + dt.format('HH:mm');   
                // Traduco il giorno
                if(leadDataCreation.containsIgnoreCase('sunday')){
                    leadDataCreation = leadDataCreation.replace('sunday', 'Domenica');
                }
                if(leadDataCreation.containsIgnoreCase('monday')){
                    leadDataCreation = leadDataCreation.replace('monday', 'Lunedì');
                }
                if(leadDataCreation.containsIgnoreCase('tuesday')){
                    leadDataCreation = leadDataCreation.replace('tuesday', 'Martedì');
                }
                if(leadDataCreation.containsIgnoreCase('wednesday')){
                    leadDataCreation = leadDataCreation.replace('wednesday', 'Mercoledì');
                }
                if(leadDataCreation.containsIgnoreCase('thursday')){
                    leadDataCreation = leadDataCreation.replace('thursday', 'Giovedì');
                }
                if(leadDataCreation.containsIgnoreCase('friday')){
                    leadDataCreation = leadDataCreation.replace('friday', 'Venerdì');
                }
                if(leadDataCreation.containsIgnoreCase('saturday')){
                    leadDataCreation = leadDataCreation.replace('saturday', 'Sabato');
                }
                // Traduco il mese
                if(leadDataCreation.containsIgnoreCase('january')){
                    leadDataCreation = leadDataCreation.replace('january', 'Gennaio');
                }
                if(leadDataCreation.containsIgnoreCase('february')){
                    leadDataCreation = leadDataCreation.replace('february', 'Febbraio');
                }
                if(leadDataCreation.containsIgnoreCase('march')){
                    leadDataCreation = leadDataCreation.replace('march', 'Marzo');
                }
                if(leadDataCreation.containsIgnoreCase('april')){
                    leadDataCreation = leadDataCreation.replace('april', 'Aprile');
                }
                if(leadDataCreation.containsIgnoreCase('may')){
                    leadDataCreation = leadDataCreation.replace('may', 'Maggio');
                }
                if(leadDataCreation.containsIgnoreCase('june')){
                    leadDataCreation = leadDataCreation.replace('june', 'Giugno');
                }
                if(leadDataCreation.containsIgnoreCase('july')){
                    leadDataCreation = leadDataCreation.replace('july', 'Luglio');
                }
                if(leadDataCreation.containsIgnoreCase('august')){
                    leadDataCreation = leadDataCreation.replace('august', 'Agosto');
                }
                if(leadDataCreation.containsIgnoreCase('september')){
                    leadDataCreation = leadDataCreation.replace('september', 'Settembre');
                }
                if(leadDataCreation.containsIgnoreCase('october')){
                    leadDataCreation = leadDataCreation.replace('october', 'Ottobre');
                }
                if(leadDataCreation.containsIgnoreCase('november')){
                    leadDataCreation = leadDataCreation.replace('november', 'Novembre');
                }
                if(leadDataCreation.containsIgnoreCase('december')){
                    leadDataCreation = leadDataCreation.replace('december', 'Dicembre');
                }
            }
            
            return ' ' + leadDataCreation;

        } else {
            
            String ErrorInfo = '';
            ErrorInfo = 'Nessun Lead di riferimento trovato';           
            return ErrorInfo;
        }
    
    }

}