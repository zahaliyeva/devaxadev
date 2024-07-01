public with sharing class AnagraficaAssuntoreHandler implements ITrigger {
    private class Wrapper{
        public String Name;
        public String RecordType;
        public Wrapper(String Name, String RecordType){
            this.Name = Name;
            this.RecordType = RecordType;
        }
        
    }
    
    public void Evaluate(List<Anagrafica_Assuntore__c> SoList){
        List<String> NewExternals = new List<String>();
    	for( Anagrafica_Assuntore__c a : SoList){
    	    NewExternals.add(a.Name+''+a.RecordTypeId);
    	}
    	List <Anagrafica_Assuntore__c> Existing = [Select id, TECH_ExternalId__c, Name, RecordType.Name From Anagrafica_Assuntore__c where TECH_ExternalId__c in: NewExternals and id not in :SoList];
    	system.debug(Existing);
    	Map <String, String> OldExternals = new Map<String, String>();
    	for(Anagrafica_Assuntore__c temp : Existing){
            List<String> tempList = temp.Name.split(' ');
            String capitalizedFully = '';
            for(String word : tempList){
                capitalizedFully += word.toLowerCase().capitalize() + ' ';
            }
            capitalizedFully = capitalizedFully.trim();
       		OldExternals.put(temp.TECH_ExternalID__c, temp.RecordType.Name +' con nome '+ capitalizedFully);
    	}
    	for(Anagrafica_Assuntore__c a : SoList){
            if(OldExternals.containsKey(a.Name.toUpperCase() + '' +a.RecordTypeId)){
            	a.addError('È già presente un assuntore di tipo '+ OldExternals.get(a.Name.toUpperCase() + '' +a.RecordTypeId));
        	}
        	else{
            	a.TECH_ExternalID__c = a.Name.toUpperCase() + '' +a.RecordTypeId;
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
        Evaluate((List<Anagrafica_Assuntore__c>) SoList);
    }
    public void beforeUpdate(List<SObject> OldSoList, List<SObject> NewSoList){
        Evaluate((List<Anagrafica_Assuntore__c>) NewSoList);
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