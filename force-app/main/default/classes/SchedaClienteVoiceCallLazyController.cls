public with sharing class SchedaClienteVoiceCallLazyController {
  
    public class Wrapper {
        @AuraEnabled
        public String Id;
        @AuraEnabled
        public String LOB;
        @AuraEnabled
        public String mittente;
        @AuraEnabled
        public String stato;
        @AuraEnabled
        public String IVR;
        @AuraEnabled
        public Datetime createdDate;
        @AuraEnabled
        public String owner;
    }
   
    @AuraEnabled(cacheable=true)
    public static List<Wrapper> getRecords(String id, Integer limits) {
        List<VoiceCall> records = [SELECT Id, LOB__c, CreatedDate, FromPhoneNumber, Owner.Name, Gestione_Chiamata__c, IVR_Name__c from VoiceCall  where Account__c =:id order by CreatedDate desc LIMIT :Integer.valueof(limits) ];
        List<Wrapper> wrapperList = new List<Wrapper>();
        for(VoiceCall record: records){
            Wrapper wrapper = new Wrapper();
            wrapper.Id = '/' + record.Id; 
            wrapper.LOB = record.LOB__c;
            wrapper.mittente = record.FromPhoneNumber;
            wrapper.stato = record.Gestione_Chiamata__c;
            wrapper.IVR = record.IVR_Name__c;
            wrapper.createdDate = record.CreatedDate;
            wrapper.owner = record.Owner.Name;
            wrapperList.add(wrapper);
        }
        return wrapperList;
    }  

    @AuraEnabled(cacheable=true)
    public static Integer getCount(String id){
        AggregateResult results = [SELECT Count(Id) Counter FROM VoiceCall  where Account__c =:id];
        return ((Integer) results.get('Counter'));
    } 

}