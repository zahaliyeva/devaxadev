public without sharing class LeadMPSManagement {

    
    public class ResponseWrapper{
        
        private String status = 'ERROR';

        private String errorMessage;

        @AuraEnabled
        public String getStatus(){
            return status;
        }
        public void setStatus(String status){
            this.status = status;
        }
        @AuraEnabled
        public String getErrorMessage(){
            return errorMessage;
        }
        public void setErrorMessage(String errorMessage){
            this.errorMessage = errorMessage;
        }
    }

    @AuraEnabled
    public static List<ResponseWrapper> leadMPSToAgency(List<Lead> leadList){
        List<ResponseWrapper> resList = new List<ResponseWrapper>();
        String prefix = 'Coda_Agenzia_';
        list<Group> groupList = [Select Id, DeveloperName from Group where DeveloperName like :(Prefix+'%')];
        Map<String, Id> groupDevNameToId = new Map<String,Id>();
        Map<String, Id> AgencyCodeToAccId = new Map<String, Id>();
        Set<String> AgencyCodeSet = new Set<String>();

        for(Lead l : leadList){
            AgencyCodeSet.add(l.Agency_Code__c);
        }

        List<Account> agencyList = [Select id, Agency_Code__c from account where RecordType.name = 'Agency' AND Agency_Code__c in :AgencyCodeSet];

        for(Account a : agencyList){
            AgencyCodeToAccId.put(a.Agency_Code__c, a.Id);
        }

        for(Group g : groupList){
            groupDevNameToId.put(g.DeveloperName, g.id);
        } 
        for(Lead l : LeadList){
            ResponseWrapper res = new ResponseWrapper();
            if(l.Agency_Code__c != null && String.isNotBlank(l.Agency_Code__c)){
                String code = l.Agency_Code__c;
                if(groupDevNameToId.containsKey(prefix + code) && groupDevNameToId.get(prefix + code) != null){
                    l.OwnerId = groupDevNameToId.get(prefix + code);
                    l.Status = 'To be processed';
                    res.setStatus('SUCCESS');
                }
                else{
                    res.setStatus('ERROR');
                    res.setErrorMessage('Coda Agenzia non trovata!');
                }
                if(AgencyCodeToAccId.containsKey(code)){
                    l.Agency__c = AgencyCodeToAccId.get(code);
                }
            }
            else{
                res.setStatus('ERROR');
                res.setErrorMessage('Codice Agenzia non valorizzato');
            }
            resList.add(res);
        }
        
        return resList;

    }

    public static void AssociaAgenzia(List<Lead> leadList){
        
        
        Map<String, Id> AgencyCodeToAccId = new Map<String, Id>();
        Set<String> AgencyCodeSet = new Set<String>();

        for(Lead l : leadList){
            AgencyCodeSet.add(l.Agency_Code__c);
        }

        List<Account> agencyList = [Select id, Agency_Code__c from account where RecordType.name = 'Agency' AND Agency_Code__c in :AgencyCodeSet];

        for(Account a : agencyList){
            AgencyCodeToAccId.put(a.Agency_Code__c, a.Id);
        }

        

        for(Lead l : LeadList){
            if(l.Agency_Code__c != null && String.isNotBlank(l.Agency_Code__c)){
                String code = l.Agency_Code__c;
                
                if(AgencyCodeToAccId.containsKey(code)){
                    l.Agency__c = AgencyCodeToAccId.get(code);
                }
            }
        }

    }

    @AuraEnabled
    public static ResponseWrapper SendToAgency(ID LeadID){
        List<Lead> l = [Select id, ownerid, Agency_Code__c, status from Lead where id = :LeadID];
        ResponseWrapper res =  leadMPSToAgency(l).get(0);
        if(res.getStatus() == 'ERROR'){
            return res;
        }
        
        try{
            update l;
        }
        catch(Exception e){
            res.setStatus('KO');
            res.setErrorMessage('Errore inaspettato, contattare l\'amministratore!');
        }
        return res;
    }
    
    @AuraEnabled
    public static ResponseWrapper RejectLead(ID LeadID){
        Lead l = [Select id, ownerid, Agency_Code__c, status from Lead where id = :LeadID];
        ResponseWrapper res = new ResponseWrapper();
        l.status = 'Rejected';
        try{
            update l;
            res.setStatus('SUCCESS');
        }
        catch(Exception e){
            res.setStatus('ERROR');
            res.setErrorMessage('Errore inaspettato, contattare l\'amministratore!');
        }
        return res;
    }
}