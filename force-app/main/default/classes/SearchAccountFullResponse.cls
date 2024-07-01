public with sharing class SearchAccountFullResponse {
    
    public SearchAccountFullResponse() {}
       
    public String codiceEsito;  
    public String msgRisposta;  
    public String occorrenzeTrovate;
    public list<cls_aSoggetto> aSoggetto;
    
    public class cls_aSoggetto {
        public cls_soggetto soggetto;
        public list<cls_lstDocumenti> lstDocumenti;
        public list<cls_lstTelefoni> lstTelefoni;
        public list<cls_lstIndirizzi> lstIndirizzi;
        public list<cls_lstContTelem> lstContTelem;
        public list<cls_lstVisibilita> lstVisibilita;
        public cls_soggettoFiscale soggettoFiscale;
        
        public cls_aSoggetto() {}
    }
    public class cls_soggetto {
        public cls_soggetto() {}
        
        public String sistemaFonte; 
        public String cointestazione;   
        public String codiceTitoloOnorifico;    
        public String tipoSoggetto; 
        public String denominazione;    
        public String cognome;  
        public String nome; 
        public String soggettoEstero;   
        public String codiceFiscale;    
        public String partitaIva;   
        public String codiceSottotipoSocieta;   
        public String codiceFormaGiuridica; 
        public String societaQuotata;   
        public String localitaNascita;  
        public String provinciaNascita; 
        public String sesso;    
        public String dataNascita;  
        public String collegatoPA;  
        public String tipoIndirizzo;    
        public String pressoIndirizzo;  
        public String paese;    
        public String locEsteraIndirizzo;   
        public String provincia;    
        public String localita; 
        public String frazione; 
        public String indirizzo;    
        public String omniaIndirizzo;   
        public String toponimoIndirizzo;    
        public String numCivicoIndirizzo;   
        public String cadCivicoIndirizzo;   
        public String cap;  
        public String codIstatIndirizzo;    
        public String codiceProfessione;    
        public String codiceScolarita;  
        public String codiceStatoCivile;    
        public String codiceHobby;  
        public String capoFamilia;  
        public String numeroFigli;  
        public String codiceTipoAbitazione; 
        public String fasciaReddito;    
        public String codiceTipoAvviso; 
        public String Ndg;  
        public String idSoggetto;   
        public String cittadinanza; 
        public String cittadinanzaSeconda;  
        public String fasciaFatturato;  
        public String codiceSettoreAttivita;    
        public String numeroDipendenti; 
        public String sedeLegale;   
        public String sedeLegaleDirittoEstero;  
        public String dataRilascioPatente;  
        public String codiceTipoPatente;    
        public String numVeicoliFamiglia;   
        public String numPatentiFamiglia;   
        public String giovaniPatentatiFamiglia; 
        public String Pep;  
        public String tipologiaPEP; 
        public String caricaPEP;    
        public String ramoAttivita; 
        public String codiceAttivita;   
        public String codiceAteco;  
        public String cMifid;   
        public String tipoTelefono; 
        public String prefissoTelefono; 
        public String numeroTelefono;   
        public String noteTelefono; 
        public String omniaTelefono;    
        public String tipoEmail;    
        public String testoEmail;   
        public String noteEmail;    
        public String omniaEmail;   
        public String codiceFormaPago;  
        public String iban; 
        public String ibanPreferito;    
        public String omniaIban;    
        public String ibanSistemaFonte; 
        public String tipoDocumento;    
        public String numeroDocumento;  
        public String dataInizioValidita;   
        public String dataFineValidita; 
        public String autoritaRilascioDocumento;    
        public String localitaRilascioDocumento;    
        public String provinciaRilascioDocumento;   
        public String nazioneRilascioDocumento; 
        public String omniaDocumento;   
        public String tipoDocumentoDue; 
        public String numeroDocumentoDue;   
        public String dataInizioValiditaDue;    
        public String dataFineValiditaDue;  
        public String autoritaRilascioDocumentoDue; 
        public String localitaRilascioDocumentoDue; 
        public String provinciaRilascioDocumentoDue;    
        public String ramiCollegati;    
        public String codiceAgenzia;    
        public String agenziaLight; 
        public String codiceSubAgenzia; 
        public String presenzaAlert;    
        public String NdgLife;  
        public String tipoRelazione;    
        public String ndgLifeSoggettoRelazionado;   
        public String bSalvaPrivacy;    
        public String privacy1; 
        public String privacy2; 
        public String privacy3; 
        public String privacy4; 
        public String privacy5; 
        public String privacyEmail; 
        public String privacyFirma; 
        public String privacyOTP;
        public String telefonoOTP;
        public String userAggPrivacyComm;
        public String userAggPrivacyMail;
        public String userAggPrivacyFirma;
        public String userAggPrivacyOTP;
        public String aggPrivacy1;  
        public String aggPrivacy2;  
        public String aggPrivacy3;  
        public String aggPrivacy4;  
        public String aggPrivacy5;  
        public String aggPrivacyEmail;  
        public String aggPrivacyFirma;  
        public String aggPrivacyOTP;
        public String aggByEmailPrivacyEmail;   
        public String aggIndEmail;  
        public String aggDocumentoPrivacyFirma; 
        public String gestFin;
        public String firsDAC;
        public String daggPrivacy1;
        public String daggPrivacy2;
        public String daggPrivacy3;
        public String daggPrivacy4;
        public String daggPrivacyEmail;
        public String daggPrivacyFirma;
        public String daggPrivacyOTP;
        public String eTipoAggPrivacy1;
        public String eTipoAggPrivacy2;
        public String eTipoAggPrivacy3;
        public String eTipoAggPrivacy4;
        public String eTipoAggPrivacyMail;
        public String eTipoAggPrivacyFirma;
        public String eTipoAggPrivacyOtp;
        public String sorgenteEst;
        public String utenteEst;
        public String daggEst; 
        public String timestampCif; 
    }
    public class cls_lstDocumenti {
        public String tipoDoc;  
        public String siglaNazione; 
        public String provincia;    
        public String localita; 
        public String numeroDoc;    
        public String autoritaRilascio; 
        public String dataRilascio; 
        public String dataScadenza; 
        public String idDocumento;  
      
    }
    public class cls_lstTelefoni {
        public String numero;   
        public cls_objectId objectId;
        public String prefissoInternazionale;   
        public String prefissoLocale;   
        public cls_soggettoEstensione soggettoEstensione;
        public String tipoTelefono; 
        public String note; 
        public String idContatto;   
        public String timeStamp; 
        public String propagaOmnia;   
        public String opposizione; 
        public String motivoOpposizione;
        
        public cls_lstTelefoni() {}
    }
    public class cls_objectId {
        public String v_long; 
        
        public cls_objectId() {}
    }
    public class cls_soggettoEstensione {
        
        public list<cls_properties> properties;

        public cls_soggettoEstensione() {}
    }
    public class cls_properties {
        
        public String chiave;   
        public String valore;    
        
        public cls_properties() {}
    }
    public class cls_lstIndirizzi {
        public String cap;  
        public String indirizzo;    
        public String localita; 
        public String ndg;  
        public String paese;    
        public String provincia;    
        public String tipoIndirizzo;    
        
        public cls_lstIndirizzi() {}
    }
    public class cls_lstContTelem {
        public String tipoContatto; 
        public String testo;    
        public String note; 
        public String idContatto;   
        public String timeStamp;
        public String propagaOmnia;    
        public String opposizione;
        public String motivoOpposizione;
        
        public cls_lstContTelem() {}
    }
    public class cls_lstVisibilita {
        public String subagenzia;
        
        public cls_lstVisibilita() {}
    }
    public class cls_soggettoFiscale {
        public String cognomeSF;    
        public String nomeSF;   
        public String codicefiscaleSF;  
        public String localitaNascitaSF;    
        public String provNascitaSF;    
        public String sessoSF;  
        public String dataNascitaSF;
        
        public cls_soggettoFiscale() {}
    }
    public static SearchAccountFullResponse parse(String json){
        return (SearchAccountFullResponse) System.JSON.deserialize(json, SearchAccountFullResponse.class);
    }
    
}