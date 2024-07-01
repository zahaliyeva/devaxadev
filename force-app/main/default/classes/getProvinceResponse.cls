public with sharing class getProvinceResponse {
    
    public getProvinceResponse() {}
    
    public EsitoClass Esito;
    public list<TabProvinClass> TabProvin;
    

    public with sharing class EsitoClass {
        public String CodiceEsito;
        public String DescrizioneEsito;
 
        public EsitoClass() {}
    }
    public with sharing class TabProvinClass {
        
        public String NumOccorrenza;
        public String SigProvin;
        public String DesProvin;
        public String CAP;
        public String CodStatistico1;
        public String CodStatistico2;
        public String CodStatistico3;
 
        public TabProvinClass() {}
    }
    

    public static getProvinceResponse parse(String json) {
        return (getProvinceResponse) System.JSON.deserialize(json, getProvinceResponse.class);
    }

}