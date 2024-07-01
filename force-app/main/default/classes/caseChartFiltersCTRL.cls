public with sharing class caseChartFiltersCTRL {

    @AuraEnabled
    //MOSCATELLI_M 25/10/2018: NMA Business -- START
    //public static ResponseDto getLob(){
    public static List<String> getLob()
    {
        
        /*List<String> pickListValuesList= new List<String>();
		Schema.DescribeFieldResult fieldResult = Case.Lob__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

		ResponseDto result = new ResponseDto();
		if (ple.size()>0){
			for(Schema.PicklistEntry pickListVal : ple){
			    pickListValuesList.add(pickListVal.getLabel());
			}
			Map<Object,Object> valuesMap = new Map<Object,Object>();
			valuesMap.put ('queryResults',pickListValuesList);
	        result.values = valuesMap;
	        result.isSuccess = true;
		} else {
            result.message = 'no results';
        }      
		System.debug('===> Lob__c ' + pickListValuesList);
        
        return result;*/
        
        Set<String> LobSet = new Set<String>();

        for(Modello_di_Assistenza__mdt Ma:[Select Lob__c from Modello_di_Assistenza__mdt where DeveloperName like 'Lob%' and Gestito_con_TTP8__c= false order by Lob__c asc])
        {
            LobSet.add(Ma.Lob__c);
        }

        List<String> ret = new List<String>();
        ret.addAll(LobSet);
        return ret;
        //MOSCATELLI_M 25/10/2018: NMA Business -- END
    }

    @AuraEnabled
    public static List<String> getCategory(String lob){

        List<Modello_di_Assistenza__mdt> results = [SELECT Categoria__c FROM Modello_di_Assistenza__mdt WHERE Lob__c =: lob];
        Set<String> pickListValuesList = new Set<String>();
        for(Modello_di_Assistenza__mdt mda : results){
            pickListValuesList.add(mda.Categoria__c);
        }
		System.debug('===> Category__c ' + pickListValuesList);

        List<String> ret = new List<String>();
        ret.addAll(pickListValuesList);
        
        return ret;
    }

    @AuraEnabled
    //MOSCATELLI_M 25/10/2018: NMA Business -- START
    public static list<String> getSubCategory(String category, String Lob){
        // public static list<String> getSubCategory(String category){
        //List<Modello_di_Assistenza__mdt> results = [SELECT Sotto_Categoria__c FROM Modello_di_Assistenza__mdt WHERE Categoria__c =: category];
        List<Modello_di_Assistenza__mdt> results = [SELECT Sotto_Categoria__c FROM Modello_di_Assistenza__mdt WHERE Categoria__c =: category and Lob__c =:Lob];      
        //MOSCATELLI_M 25/10/2018: NMA Business -- END
        Set<String> pickListValuesList = new Set<String>();
        for(Modello_di_Assistenza__mdt mda : results){
            pickListValuesList.add(mda.Sotto_Categoria__c);
        }
        System.debug('===> SubCategory__c ' + pickListValuesList);

        List<String> ret = new List<String>();
        ret.addAll(pickListValuesList);
        
        return ret;
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
}