/**
 * @description PURE IT 23/05 - commentata la classe
 */
public with sharing class NormalizeAddressResponse {
    /** PURE IT
    public NormalizeAddressResponse() {}
    
    public EsitoClass Esito;
    
    public String SigConf;
    public String CodConf;
    public String DesConf;
    public String CodStato;
    public String SigStato2;
    public String SigStato3;
    public String DesStato;
    public String CodRegione;
    public String DesRegione;
    public String SigProvincia;
    public String DesProvincia;
    public String DesLocAmmUff;
    public String DesLocAmmAbb;
    public String DesLocFrazUff;
    public String DesLocFrazAbb;
    public String DesLocEspUff;
    public String DesLocEspAbb;
    public String DesLocPostale;
    public String CodLocalita1;
    public String CodLocalita2;
    public String CodLocalita3;
    public String CodLocalita;
    public String CxStatistico;
    public String CxComplementareLocalita;
    public String TipoLocalita;
    public String FlLocalitaViNaz;
    public String FlLocalitaViZon;
    public String FlLocalitaViSpec;
    public String CxLinguaLocalita;
    public String CxTerr;
    public String NumPesoLoc;
    public String DesViaUff;
    public String DesViaAbb;
    public String DesViaOut;
    public String DesViaCompleta;
    public String CodVia1;
    public String CodVia2;
    public String CodMcVia;
    public String CxLinguaVia;
    public String FlViaOldNew;
    public String FlViaLocSost;
    public String FlViaSost;
    public String FlInfDxVia;
    public String FlViaIntera;
    public String NumPesoVia;
    public String DesDugUff;
    public String DesDugAbb;
    public String CodDug;
    public String CodDugR;
    public String DesCivico;
    public String CodCivico;
    public String ComplCivico1;
    public String ComplCivico2;
    public String DesInfDx;
    public String DesInfPresso;
    
    public CandidatiClass Candidati;
    
    public String McConfederazione;
    public String McStato;
    public String McLocalita;
    public String McVia;
    public String McDugr;
    public String McCivico;
    public String McComplCivico1;
    public String McComplCivico2;
    
    public List<ErroriClass> Errori;
    
    public with sharing class EsitoClass {
        public String Codice;
        public String Descrizione;
 
        public EsitoClass() {}
    }
    
    public with sharing class CandidatiClass {
        public List<TabCandLocClass> TabCandLoc;
        public List<TabCandViaClass> TabCandVia;
 
        public CandidatiClass() {}
    }
    
    public with sharing class TabCandLocClass{
        public String SigProvin;
        public String Localita;
        public String CAP;
        
        public TabCandLocClass() {}
    }
    
    public with sharing class TabCandViaClass{
        public String DesDUG;
        public String DesVia;
        public String Civico;
        public String CAP;
        
        public TabCandViaClass() {}
    }
    
    public with sharing class ErroriClass{
        public String Codice;
        public String Tipo;
        public String Descrizione;
        
        public ErroriClass() {}
    }

    public static NormalizeAddressResponse parse(String json) {
        return (NormalizeAddressResponse) System.JSON.deserialize(json, NormalizeAddressResponse.class);
    }
PURE IT */
}