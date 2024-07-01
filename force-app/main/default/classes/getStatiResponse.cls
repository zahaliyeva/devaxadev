public with sharing class getStatiResponse {
    
    public getStatiResponse() {}
    
    public EsitoClass Esito;
    public list<TabStatoClass> TabStato;
    

    public with sharing class EsitoClass {
        public String CodiceEsito;
        //public String DescrizioneEsito;
 
        public EsitoClass() {}
    }
    public with sharing class TabStatoClass {
        
        public String NumOccorrenza;
        public String CodeStato;
        public String DesStato;
        public String SiglaStato2;
        public String SiglaStato3;
        public String CodiceStato;
 
        public TabStatoClass() {}
    }
    

    public static getStatiResponse parse(String json) {
        return (getStatiResponse) System.JSON.deserialize(json, getStatiResponse.class);
    }

}