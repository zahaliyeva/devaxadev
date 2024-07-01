public with sharing class AnagraficaAssuntoreAgenziaHandler implements ITrigger {
    public void Evaluate(List<AnagraficaAssuntoreAgenzia__c> SoList){
        List<String> NewExternals = new List<String>();
    	for( AnagraficaAssuntoreAgenzia__c a : SoList){
    	    NewExternals.add(a.codice_Agenzia__c + '' +a.Nome_Assuntore__c);
    	}
        Set<String> AgencyId = new Set<String>();
        Set<String>	AssuntoreId = new Set<String>();
        
        for (AnagraficaAssuntoreAgenzia__c a : SoList){
            system.debug(a.Agency_Code__c + ' ' + a.Nome_Assuntore__c);
            AgencyId.add(a.Codice_Agenzia__c);
            AssuntoreId.add(a.Nome_Assuntore__c);
        }
        system.debug(AgencyID);
        system.debug(AssuntoreID);
       	Map <Id,Account> MapAgencyID = new Map<Id,Account>([Select id, Agency_Code__c, Name from Account where id in :AgencyId]);
        Map <Id,Anagrafica_Assuntore__c> MapAssuntoreID = new Map<Id,Anagrafica_Assuntore__c>([Select id, Name from Anagrafica_Assuntore__c where id in :AssuntoreId]);
    	List <AnagraficaAssuntoreAgenzia__c> Existing = [Select id, TECH_ExternalId__c, RecordTypeId, RecordType.Name, Codice_Agenzia__c,Codice_Agenzia__r.Agency_Code__c, Codice_Agenzia__r.Name, Nome_Assuntore__r.Name From AnagraficaAssuntoreAgenzia__c where id not in :SoList];
        //List <AnagraficaAssuntoreAgenzia__c> ExistingFromAgency = [Select id, RecordTypeId, Codice_Agenzia__c from AnagraficaAssuntoreAgenzia__c where id not in:SoList];
        system.debug(Existing);
    	Map <String, String> OldExternals = new Map<String, String>();
        Map <String,String> ExistingFromAgency = new Map<String,String>();
    	for(AnagraficaAssuntoreAgenzia__c temp : Existing){
       		OldExternals.put(temp.TECH_ExternalID__c, temp.Codice_Agenzia__r.Name+' e '+temp.Nome_Assuntore__r.Name);
            ExistingFromAgency.put(temp.Codice_Agenzia__c + '' + temp.RecordTypeId, temp.RecordType.Name);
    	}
    	for(AnagraficaAssuntoreAgenzia__c a : SoList){
        	system.debug(a.codice_Agenzia__c + '' +a.Nome_Assuntore__c);
            if(ExistingFromAgency.containsKey(a.Codice_Agenzia__c + '' + a.RecordTypeId) && !OldExternals.containsKey(a.Codice_Agenzia__c + '' + a.Nome_Assuntore__c)){
                a.addError('L\'agenzia ha già un assuntore di tipo ' + ExistingFromAgency.get(a.Codice_Agenzia__c + '' + a.RecordTypeId));
            }
        	else if(OldExternals.containsKey(a.Codice_Agenzia__c + '' + a.Nome_Assuntore__c)){
            	a.addError('È già presente un\'associazione tra '+ OldExternals.get(a.Codice_Agenzia__c + '' + a.Nome_Assuntore__c));
        	}
        	else{
            	a.TECH_ExternalID__c = a.codice_Agenzia__c + '' +a.Nome_Assuntore__c;
                if(MapAgencyID.containsKey(a.Codice_Agenzia__c) && MapAssuntoreID.containsKey(a.Nome_Assuntore__c)){
                    a.Codice_Agenzia_ListView__c = MapAgencyId.get(a.Codice_Agenzia__c).Agency_Code__c;
                    a.Nome_Agenzia_listView__c = MapAgencyId.get(a.Codice_Agenzia__c).Name;
                    a.Nome_Assuntore_ListView__c = MapAssuntoreID.get(a.Nome_Assuntore__c).Name;
                }
        	}
    	}
    }
    public void bulkBefore(){
        
    }
    public void bulkAfter(){
        
    }
    public void beforeInsert(SObject SO){
        
    }
    public void beforeUpdate(SObject OldObj,SObject NewObj){
        
    }
    public void beforeDelete(Sobject SO){
        
    }
    public void beforeInsert(List<SObject> SoList){
        Evaluate((List<AnagraficaAssuntoreAgenzia__c>) SoList);
    }
    public void beforeUpdate(List<SObject> OldSoList, List<SObject> NewSoList){
        Evaluate((List<AnagraficaAssuntoreAgenzia__c>) NewSoList);
    }
    public void beforeDelete(List<Sobject> SoList){
        
    }
    public void afterInsert(SObject SO){
        
    }
    public void afterUpdate(SObject OldObj, SObject NewObj){
        
    }
    public void afterDelete(SObject SO){
        
    }
    public void afterUndelete(SObject SO){
        
    }
    public void afterInsert(List<SObject> SoList){
        
    }
    public void afterUpdate(List<SObject> OldSoList, List<SObject> NewSoList){
        
    }
    public void afterDelete(List<SObject> SoList){
        
    }
    public void afterUndelete(List<SObject> SoList){
        
    }
    public void andFinally(){
        
    }
}