public class LeadCSVLoaderCtr {
    private List<MappingProvince__c> province;
    private static final Integer rigaInizioLetturaFile = 2;
    private static final Integer MAX_FILE_SIZE= 4000;
    public static final String TIPI_AUTO = 
    
    'Nome;Cognome;Telefono;Email;Codice Fiscale;Codice Agenzia;Origine  lista esterna;Note;Data di nascita intestatario;Consenso alle attivita commerciali;'+
    'Tipologia di polizza;Prezzo RC auto;Prezzo furto;Prezzo incendio;Prezzo infortuni conducente;Prezzo assistenza;Scoperti/Franchigie RC auto;'+
    'Scoperti/Franchigie furto;Scoperti/Franchigie incendio;Scoperti/Franchigie infortuni conducente;Massimale/Capitale RC auto;Massimale/Capitale furto;'+
    'Massimale/Capitale incendio;Massimale/Capitale infortuni conducente;N. di sinistri con colpa ultimi 5 anni;N. di sinistri con colpa ultimi 2 anni;'+
    'Data scadenza polizza c/o concorrente;Classe universale;Modello autovettura;Targa;Alimentazione autovettura;Origine lead;Partita IVA;Ragione sociale;Data richiesta quotazione;Dettaglio fonte lead;Codice Sub-Agenzia;CAP';

    public static final String TIPI_RAMI_ELEMENTARI = 
    
    'Nome;Cognome;Telefono;Email;Codice fiscale;Sesso;Codice agenzia;Origine lista esterna;Note;Data di nascita lead;Orario di contatto;'+
    'Consenso alle attivita commerciali;Presa visione privacy;Tipologia di polizza;Citta;Stato/Provincia;CAP;Via;Origine lead;Partita IVA;Ragione sociale;Data richiesta quotazione;Dettaglio fonte lead;Codice Sub-Agenzia';
    
    public static final String TIPI_RAMI_ELEMENTARI_AGGIUNTA =
    
    'Nome;Cognome;Telefono;Email;Codice fiscale;Sesso;Codice agenzia;Origine lista esterna;Note;Data di nascita lead;Orario di contatto;'+
    'Consenso alle attivita commerciali;Presa visione privacy;Tipologia di polizza;Citta;Stato/Provincia;CAP;Via;Origine lead;Partita IVA;Ragione sociale;Data richiesta quotazione;Dettaglio fonte lead;Prezzo annuo Confido;Premio in promozione;Ammontare sconto;Nome animale;Tipologia animale;Età animale;Razza pericolosa;RC cani e gatti plus;Massimale Tutela medica e sanitaria;Tutela legale;Assistenza H24;Stato/Provincia-bene da assicurare;Comune-bene da assicurare;CAP-bene da assicurare;Codice Sub-Agenzia';
    
    
    public static final String DESCRIZIONE_AUTO =
    
    'Obbligatorio;Obbligatorio;Obbligatorio;Obbligatorio - Formato e-mail valido;Facoltativo - Inserire un valore di 16 caratteri alfanumerici;'+
    'Facoltativo - Inserire un codice agenzia valido di 6 cifre (es. 004610);Facoltativo - Descrizione fonte lista Lead;'+
    'Facoltativo - Inserire eventuali note legate al Lead;Facoltativo - Formato data atteso: GG/MM/AAAA;Facoltativo - Valori ammessi: VERO o FALSO;'+
    'Facoltativo - Valore ammesso: AUTO;Facoltativo - Valore numerico senza simbolo valuta;Facoltativo - Valore numerico senza simbolo valuta;'+
    'Facoltativo - Valore numerico senza simbolo valuta;Facoltativo - Valore numerico senza simbolo valuta;'+
    'Facoltativo - Valore numerico senza simbolo valuta;Facoltativo - Valore numerico senza simbolo valuta;'+
    'Facoltativo - Valore scoperti / franchigie furto (es. 10% - 150);Facoltativo - Valore numerico senza simbolo valuta;'+
    'Facoltativo - Valore numerico senza simbolo valuta;Facoltativo - Valore numerico senza simbolo valuta;Facoltativo - Valore numerico senza simbolo valuta;'+
    'Facoltativo - Valore numerico senza simbolo valuta;Facoltativo - Valore numerico senza simbolo valuta;'+
    'Facoltativo - Valore numerico;Facoltativo - Valore numerico;Facoltativo - Formato data atteso: GG/MM/AAAA;'+
    'Facoltativo - Formato atteso: CU seguito da uno spazio e un numero di 2 cifre (es. CU 12);Facoltativo - Modello autovettura esistente;'+
    'Facoltativo - Inserire un codice targa valido di 7 caratteri alfanumerici;Facoltativo - Tipologia alimentazione esistente;'+
    'Facoltativo - Compilare il campo col nome della landing page di origine (es. Preventivo Veloce);Facoltativo - Inserire un valore di 11 caratteri alfanumerici;Facoltativo -  formato testo;'+
    'Facoltativo - Formato data atteso: GG/MM/AAAA ORA.MINUTI;' +
    'Facoltativo - Valori ammessi Salva quotazione, Visualizza quotazione o campo bianco;' +
    'Facoltativo - Inserire un codice sub-agenzia valido di 12 cifre (es. 000828000012);'+'Facoltativo - Codice numerico di 5 cifre (es. 20100)';
     
    public static final String DESCRIZIONE_RE_PREVIDENZA = 
    
    'Obbligatorio;Obbligatorio;Obbligatorio;Obbligatorio, formato e-mail valido;Facoltativo - Inserire un valore di 16 caratteri alfanumerici;'+
    'Facoltativo - Valori ammessi: Maschio o Femmina;Facoltativo - Inserire un codice agenzia valido di 6 cifre (es. 004610);'+
    'Facoltativo - Descrizione fonte lista Lead;Facoltativo - Inserire eventuali note legate al Lead;Facoltativo - Formato data atteso: GG/MM/AAAA;'+
    'Facoltativo - Valori ammessi: 9 - 11, 11 - 13, 13 - 15, 15 - 17, 17 - 19;Facoltativo - Valori ammessi: VERO o FALSO;'+
    'Facoltativo - Valori ammessi: VERO o FALSO;Facoltativo - Valori ammessi: Altro, Famiglia, Investimento, Previdenza, Protezione, Risparmio, Salute;'+
    'Facoltativo - Nome citta esistente;Facoltativo - Sigla provincia esistente (es. MI);Facoltativo - Codice numerico di 5 cifre (es. 20100);'+
    'Facoltativo - Indirizzo esistente (es. Via Capponi, 2);Facoltativo -Compilare il campo col nome della landing page di origine (es. Previsio);'+
    'Facoltativo - Inserire un valore di 11 caratteri alfanumerici;Facoltativo -  formato testo;Facoltativo - Formato data atteso: GG/MM/AAAA ORA.MINUTI;Facoltativo - Valori ammessi Salva quotazione, Visualizza quotazione o campo bianco;'+
    'Facoltativo - Inserire un codice sub-agenzia valido di 12 cifre (es. 000828000012)';
    
    
     public static final String DESCRIZIONE_RE_PROTEZIONE = 
    
    'Obbligatorio;Obbligatorio;Obbligatorio;Obbligatorio, formato e-mail valido;Facoltativo - Inserire un valore di 16 caratteri alfanumerici;'+
    'Facoltativo - Valori ammessi: Maschio o Femmina;Facoltativo - Inserire un codice agenzia valido di 6 cifre (es. 004610);'+
    'Facoltativo - Descrizione fonte lista Lead;Facoltativo - Inserire eventuali note legate al Lead;Facoltativo - Formato data atteso: GG/MM/AAAA;'+
    'Facoltativo - Valori ammessi: 9 - 11, 11 - 13, 13 - 15, 15 - 17, 17 - 19;Facoltativo - Valori ammessi: VERO o FALSO;'+
    'Facoltativo - Valori ammessi: VERO o FALSO;Facoltativo - Valori ammessi: Altro, Famiglia, Investimento, Previdenza, Protezione, Risparmio, Salute;'+
    'Facoltativo - Nome citta esistente;Facoltativo - Sigla provincia esistente (es. MI);Facoltativo - Codice numerico di 5 cifre (es. 20100);'+
    'Facoltativo - Indirizzo esistente (es. Via Capponi, 2);Facoltativo -Compilare il campo col nome della landing page di origine (es. Tutta la vita);'+
    'Facoltativo - Inserire un valore di 11 caratteri alfanumerici;Facoltativo -  formato testo;Facoltativo - Formato data atteso: GG/MM/AAAA ORA.MINUTI;Facoltativo - Valori ammessi Salva quotazione, Visualizza quotazione o campo bianco;'+
    'Facoltativo - Inserire un codice sub-agenzia valido di 12 cifre (es. 000828000012)';
    
   public static final String DESCRIZIONE_RE_AGGIUNTA = 
   'Obbligatorio;Obbligatorio;Obbligatorio;Obbligatorio, formato e-mail valido;Facoltativo - Inserire un valore di 16 caratteri alfanumerici;'+
    'Facoltativo - Valori ammessi: Maschio o Femmina;Facoltativo - Inserire un codice agenzia valido di 6 cifre (es. 004610);'+
    'Facoltativo - Descrizione fonte lista Lead;Facoltativo - Inserire eventuali note legate al Lead;Facoltativo - Formato data atteso: GG/MM/AAAA;'+
    'Facoltativo - Valori ammessi: 9 - 11, 11 - 13, 13 - 15, 15 - 17, 17 - 19;Facoltativo - Valori ammessi: VERO o FALSO;'+
    'Facoltativo - Valori ammessi: VERO o FALSO;Facoltativo - Valori ammessi: Altro, Famiglia, Investimento, Previdenza, Protezione, Risparmio, Salute;'+
    'Facoltativo - Nome citta esistente;Facoltativo - Sigla provincia esistente (es. MI);Facoltativo - Codice numerico di 5 cifre (es. 20100);'+
    'Facoltativo - Indirizzo esistente (es. Via Capponi, 2);Facoltativo -Compilare il campo col nome della landing page di origine (es. ConFido);'+
    'Facoltativo - Inserire un valore di 11 caratteri alfanumerici;'+
    'Facoltativo -  formato testo;' +
    'Facoltativo - Formato data atteso: GG/MM/AAAA ORA.MINUTI;' +
    'Facoltativo - Valori ammessi Salva quotazione, Visualizza quotazione o campo bianco;'+
    'Facoltativo - Quotatore ConFido - Inserire un numero decimale es. 120.00;'+
    'Facoltativo - Quotatore ConFido -  Inserire un numero decimale es. 120.00;'+
    'Facoltativo - Quotatore ConFido -  Il vaolre viene calcolato in modo automatico,non inserire;'+
    'Facoltativo - Quotatore ConFido - Inserire Nome;'+
    'Facoltativo - Quotatore ConFido - Inserire tipologia animale;'+
    'Facoltativo - Quotatore ConFido - Meno di 6 mesi - Compreso tra 6 mesi e 10 anni - Più di 10 anni;'+
    'Facoltativo - Quotatore ConFido - Inserire VERO o FALSO;'+
    'Facoltativo - Quotatore ConFido - Inserire VERO o FALSO;'+
    'Facoltativo - Quotatore ConFido - Inserire un numero decimale es. 120.00;'+
    'Facoltativo - Quotatore ConFido - Inserire VERO o FALSO;'+
    'Facoltativo - Quotatore ConFido - Inserire VERO o FALSO;'+
    'Facoltativo - Quotatore Protezione turismo - Sigla provincia esistente (es. MI);'+
    'Facoltativo - Quotatore Protezione turismo - Nome comune esistente;'+
    'Facoltativo - Quotatore Protezione turismo - Codice numerico di 5 cifre (es. 20100);'+
    'Facoltativo - Inserire un codice sub-agenzia valido di 12 cifre (es. 000828000012)';
    
    public Attachment a { get;set; }
    public Attachment b { get;set; }
    public Integer step { get; set; }
    public String urlAmb { get; set; }
    public Integer numErr { get; set; }
    public Integer numVal { get; set; }
    public String file_nome { get; set; }
    public Lead_Upload_History__c cc { get; set; }
    public transient Blob file_contenuto { get; set; }
    public Document d { get;set; }
    private Boolean isAuto;
    public String leadType;
    
    public LeadCSVLoaderCtr(){
        province = [SELECT ProvinciaExternalKey__c, SFDCexpected__c FROM MappingProvince__c ]; // NOPMD  Fix CRUD violation
        step = 0;
        numErr = 0;
        numVal = 0;
        file_nome = '';
        d = new Document();
        cc = new Lead_Upload_History__c();
        urlAmb = URL.getSalesforceBaseUrl().toExternalForm() + '/';
        String retURL = ApexPages.currentPage().getParameters().get('retURL');
        System.debug('****************TIPI_AUTO '+TIPI_AUTO ); 
        System.debug('****************TIPI_RAMI_ELEMENTARI '+TIPI_RAMI_ELEMENTARI );
        System.debug('****************DESCRIZIONE_AUTO '+DESCRIZIONE_AUTO );
        System.debug('****************DESCRIZIONE_RE '+DESCRIZIONE_RE_PREVIDENZA );
        System.debug('****************DESCRIZIONE_RE '+DESCRIZIONE_RE_PROTEZIONE );
        System.debug('****************TIPI_RAMI_ELEMENTARI '+TIPI_RAMI_ELEMENTARI_AGGIUNTA);
        System.debug('****************DESCRIZIONE_RE '+DESCRIZIONE_RE_AGGIUNTA );
    }   
    
    public PageReference auto() {
        isAuto = true;
        leadType = 'Auto';
        step++;
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Utilizzare il Template Auto'));
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'E’ necessario compilare obbligatoriamente le colonne dalla A alla D perchè il Lead sia validato'));
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Inserire i campi seguendo la corrispettiva descrizione'));                                                                              
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Sarà possibile visionare i Lead con errori'));
        
        List<Document> docQuery = [SELECT Body,Id,Name FROM Document WHERE Name like '%Caricamento Massivo Lead AUTO%'];
        d = docQuery[0];
        return null;
    }
    
    public PageReference nonAuto() {
        isAuto = false;
        leadType = 'Rami Elementari';
        step++;
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Utilizzare il Template Rami Elementari'));
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'E’ necessario compilare obbligatoriamente le colonne dalla A alla D perchè il Lead sia validato'));
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Inserire i campi seguendo la corrispettiva descrizione'));                                                                              
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Sarà possibile visionare i Lead con errori'));
        
        List<Document> docQuery = [SELECT Body,Id,Name FROM Document WHERE Name like '%Caricamento Massivo Lead RAMI ELEMENTARI%'];
        d = docQuery[0];                                                                 
        return null;
    } 

    public PageReference previdenza() {
        isAuto = false ;
        leadType = 'Previdenza';
        step++;
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Utilizzare il Template Previdenza'));
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'E’ necessario compilare obbligatoriamente le colonne dalla A alla D perchè il Lead sia validato'));
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Inserire i campi seguendo la corrispettiva descrizione'));                                                                              
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Sarà possibile visionare i Lead con errori'));
        
        List<Document> docQuery = [SELECT Body,Id,Name FROM Document WHERE Name like '%Caricamento Massivo Lead PREVIDENZA%'];
        d = docQuery[0];                                                                 
        return null;
    }

    public PageReference protezione() {
        isAuto = false;
        leadType = 'Protezione';
        step++;
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Utilizzare il Template Protezione'));
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'E’ necessario compilare obbligatoriamente le colonne dalla A alla D perchè il Lead sia validato'));
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Inserire i campi seguendo la corrispettiva descrizione'));                                                                              
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Sarà possibile visionare i Lead con errori'));
        
        List<Document> docQuery = [SELECT Body,Id,Name FROM Document WHERE Name like '%Caricamento Massivo Lead PROTEZIONE%'];
        d = docQuery[0];                                                                 
        return null;
    }  
    
    public PageReference validaFile() {    
        //Validazione Tipo File
        if(file_nome == null || file_nome == ''){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Nessun file'));
            return null;
            }
            
         if(!file_nome.contains('.csv')){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Il file non è nel formato corretto, deve essere di tipo CSV'));
            return null;
            }
       
        //Conversione File
        List<String> righe = new List<String>();
        try{
            righe = file_contenuto.toString().split('\r\n');
            System.debug('****************righe '+righe ); 
        }
        
        catch(Exception e){
             righe = blobToString(file_contenuto,'ISO-8859-1').split('\r\n');
            }
        String lineaOutput = '', validati = '', errori = '', nomeval = '', nomeerr = '';
        
        Set<String> validState = new Set<String>();
        Set<String> validCode = new Set<String>();
        List<Account> agenzie = [SELECT Name, Active__c,Agency_Code__c,Id FROM Account WHERE Recordtype.name ='Agency' AND Active__c = true ]; // NOPMD  Fix CRUD violation
        
        for(MappingProvince__c x : province){
            validState.add(x.ProvinciaExternalKey__c);
            validState.add(x.SFDCexpected__c);
        }
        for(Account x : agenzie)
            validCode.add(x.Agency_Code__c);
             
        if(leadType == 'Auto'){
            //Controllo intestazione
            if(righe[0].trim() != TIPI_AUTO){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Template non valido'));
                return null;
                }
            //Controllo descrizione
            if(righe[1].trim() != DESCRIZIONE_AUTO){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Attenzione la riga delle descrizioni è stata modificata'));
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Qual\'ora fosse stata sostituita con un Lead, questo non verrà nè validato nè inserito'));
                }
            //Controllo singoli campi
            for(Integer k = rigaInizioLetturaFile; k <righe.size(); k++){
                lineaOutput = righe[k];
                String tmp = LeadValidation.auto(lineaOutput, validCode);
                if(lineaOutput == tmp){
                    numVal++;
                    validati += '\r\n' + lineaOutput;
                } 
                else {
                    numErr++;
                    errori += '\r\n' + tmp;
                }
            }
            cc.Status__c='Inserito';
            nomeval = 'fileValidati-'+Date.today().year()+'-'+Date.today().month()+'-'+Date.today().day()+'-'+DateTime.now().hour()+DateTime.now().minute()+'.csv';
            nomeerr =  'fileErrori-'+Date.today().year()+'-'+Date.today().month()+'-'+Date.today().day()+'-'+DateTime.now().hour()+DateTime.now().minute()+'.csv';
             
            insert cc; // NOPMD  Fix CRUD violation
            validati = TIPI_AUTO + '\r\n' + DESCRIZIONE_AUTO + validati;
            errori = TIPI_AUTO + ';Campi non compilati correttamente\r\n' + DESCRIZIONE_AUTO + errori;
        } else 

        if(leadType == 'Rami Elementari'){
            //Controllo intestazione
            if(righe[0].trim() != TIPI_RAMI_ELEMENTARI_AGGIUNTA){
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Template non valido'));
                 return null;
                 }
            //Controllo descrizione
            if(righe[1].trim() != DESCRIZIONE_RE_AGGIUNTA){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Attenzione la riga delle descrizioni è stata modificata'));
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Qual\'ora fosse stata sostituita con un Lead, questo non verrà nè validato nè inserito'));
                }
            //Controllo singoli campi
            for(Integer k = rigaInizioLetturaFile; k <righe.size(); k++)
                {
           
                lineaOutput = righe[k];
                String tmp = LeadValidation.nonAuto(lineaOutput, validCode, validState);
                if(tmp == lineaOutput){
                    numVal++;
                    validati += '\r\n' + lineaOutput;
                    } else {
                    numErr++;
                    errori += '\r\n' + tmp;
                    }
               }
        cc.Status__c='Inserito';
        nomeval = 'fileValidati-'+Date.today().year()+'-'+Date.today().month()+'-'+Date.today().day()+'-'+DateTime.now().hour()+DateTime.now().minute()+'.csv';
        nomeerr =  'fileErrori-'+Date.today().year()+'-'+Date.today().month()+'-'+Date.today().day()+'-'+DateTime.now().hour()+DateTime.now().minute()+'.csv';
        
        insert cc;  // NOPMD  Fix CRUD violation
        validati = TIPI_RAMI_ELEMENTARI_AGGIUNTA + '\r\n' + DESCRIZIONE_RE_AGGIUNTA + validati;
        errori = TIPI_RAMI_ELEMENTARI_AGGIUNTA + ';Campi non compilati correttamente\r\n' + DESCRIZIONE_RE_AGGIUNTA + errori;
        }

        if(leadType == 'Previdenza'){
            //Controllo intestazione
            if(righe[0].trim() != TIPI_RAMI_ELEMENTARI){
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Template non valido'));
                 return null;
                 }
            //Controllo descrizione
            if(righe[1].trim() != DESCRIZIONE_RE_PREVIDENZA){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Attenzione la riga delle descrizioni è stata modificata'));
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Qual\'ora fosse stata sostituita con un Lead, questo non verrà nè validato nè inserito'));
                }
            //Controllo singoli campi
            for(Integer k = rigaInizioLetturaFile; k <righe.size(); k++)
                {
           
                lineaOutput = righe[k];
                String tmp = LeadValidation.previdenza(lineaOutput, validCode, validState);
                if(tmp == lineaOutput){
                    numVal++;
                    validati += '\r\n' + lineaOutput;
                    } else {
                    numErr++;
                    errori += '\r\n' + tmp;
                    }
               }
        cc.Status__c='Inserito';
        nomeval = 'fileValidati-'+Date.today().year()+'-'+Date.today().month()+'-'+Date.today().day()+'-'+DateTime.now().hour()+DateTime.now().minute()+'.csv';
        nomeerr =  'fileErrori-'+Date.today().year()+'-'+Date.today().month()+'-'+Date.today().day()+'-'+DateTime.now().hour()+DateTime.now().minute()+'.csv';
        
        insert cc;  // NOPMD  Fix CRUD violation
        validati = TIPI_RAMI_ELEMENTARI + '\r\n' + DESCRIZIONE_RE_PREVIDENZA + validati;
        errori = TIPI_RAMI_ELEMENTARI + ';Campi non compilati correttamente\r\n' + DESCRIZIONE_RE_PREVIDENZA + errori;
        }

        if(leadType == 'Protezione'){
            //Controllo intestazione
            if(righe[0].trim() != TIPI_RAMI_ELEMENTARI){
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Template non valido'));
                 return null;
                 }
            //Controllo descrizione
            if(righe[1].trim() != DESCRIZIONE_RE_PROTEZIONE){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Attenzione la riga delle descrizioni è stata modificata'));
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Qual\'ora fosse stata sostituita con un Lead, questo non verrà nè validato nè inserito'));
                }
            //Controllo singoli campi
            for(Integer k = rigaInizioLetturaFile; k <righe.size(); k++)
                {
           
                lineaOutput = righe[k];
                String tmp = LeadValidation.protezione(lineaOutput, validCode, validState);
                if(tmp == lineaOutput){
                    numVal++;
                    validati += '\r\n' + lineaOutput;
                    } else {
                    numErr++;
                    errori += '\r\n' + tmp;
                    }
               }
        cc.Status__c='Inserito';
        nomeval = 'fileValidati-'+Date.today().year()+'-'+Date.today().month()+'-'+Date.today().day()+'-'+DateTime.now().hour()+DateTime.now().minute()+'.csv';
        nomeerr =  'fileErrori-'+Date.today().year()+'-'+Date.today().month()+'-'+Date.today().day()+'-'+DateTime.now().hour()+DateTime.now().minute()+'.csv';
        insert cc;  // NOPMD  Fix CRUD violation
        validati = TIPI_RAMI_ELEMENTARI + '\r\n' + DESCRIZIONE_RE_PROTEZIONE + validati;
        errori = TIPI_RAMI_ELEMENTARI + ';Campi non compilati correttamente\r\n' + DESCRIZIONE_RE_PROTEZIONE + errori;
        }

        System.debug('*******validati '+validati);
        System.debug('*******errori '+errori );
        a = new Attachment( Name = nomeval, ContentType = 'text/csv; charset=UTF-8', Body = blob.valueof(validati), ParentId = cc.id);
        insert a;
        a.Body = null;
        b = new Attachment( Name = nomeerr, ContentType = 'text/csv; charset=UTF-8', Body = blob.valueof(errori), ParentId = cc.id);
        insert b;
        b.Body = null;
        step++;
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Prima di ricaricare nuovamente i Lead non validati, ricordarsi di eliminare l\'ultima colonna "Campi non compilati correttamente" dal template'));
        return null;
    }
    
    

    public PageReference importa(){
        Set<String> queuesSet = new Set<String>();
        LeadCSVLoaderBatch newBatch = new LeadCSVLoaderBatch(cc.id, 2, queuesSet, leadType);
        Database.executeBatch(newBatch,50);

      /*  Map<String,String> siglaCitta = new Map<String,String>();
        for(MappingProvince__c x : province)
            siglaCitta.put(x.ProvinciaExternalKey__c,x.SFDCexpected__c );
            
        List<Attachment> validatiFile;
        
        try{
            validatiFile = [SELECT Body,Id,ParentId FROM Attachment WHERE parentId =: cc.id and Name like '%validati%'];
           }
        catch(Exception e){
             Database.DeleteResult MyResult = Database.delete(cc);
            }
        String validati = validatiFile.get(0).body.toString();
        List<String> righe = validati.split('\n');
        List<Lead> leadsToInsert = new List<Lead>();
        System.debug('****************isAuto '+isAuto);
        System.debug('****************righe.size() '+righe.size());
        System.debug('****************righe '+righe);
        if(leadType == 'Auto'){
            for(Integer k = rigaInizioLetturaFile; k < righe.size(); k++){
                System.debug('****************AUTO righe k  '+righe[k]);
                leadsToInsert.add(LeadBuilder.auto(righe[k]));
            }
        }
        if(leadType == 'Rami Elementari'){
            for(Integer k = rigaInizioLetturaFile; k < righe.size(); k++){
                System.debug('****************righe k '+righe[k]);
                leadsToInsert.add(LeadBuilder.nonAuto(righe[k],siglaCitta));
            }
        }
        if(leadType == 'Previdenza'){
            for(Integer k = rigaInizioLetturaFile; k < righe.size(); k++){
                System.debug('****************righe k '+righe[k]);
                leadsToInsert.add(LeadBuilder.Previdenza(righe[k],siglaCitta));
            }
        }
        if(leadType == 'Protezione'){
            for(Integer k = rigaInizioLetturaFile; k < righe.size(); k++){
                System.debug('****************righe k '+righe[k]);
                leadsToInsert.add(LeadBuilder.Protezione(righe[k],siglaCitta));
            }
        }        
        System.debug('****************leadsToInsert '+leadsToInsert);    
        insert leadsToInsert;
        list<String> impactedQueue = new list<String>();
        for (Lead theLead :leadsToInsert)
        {
            impactedQueue.add('Coda_Agenzia_'+theLead.Agency_code__c);
        }
        set<String> setQueue = new Set<String>(impactedQueue);
        system.debug('*******setQueue '+setQueue );
        //list<String> listQueue = new list<String>(setQueue);
        list<GroupMember>  recipientPersonsG=[SELECT  GroupId,Id,SystemModstamp,UserOrGroupId,group.developername FROM GroupMember where group.developername in :setQueue ];
        map<String,Set<Id>> GroupNametoIds=new map<String,Set<Id>>();
        
        //map<String,Map<String,String>> theMap;
        list<Id> userIds = new list<Id>();
        for (GroupMember GM :recipientPersonsG)
        {
            if (String.valueOf(GM.UserOrGroupId).left(3)=='005')
            { 
                userIds.add(GM.UserOrGroupId);
                set<Id> tmpidset = new set<Id>();
                tmpidset = GroupNametoIds.get(GM.group.developername);
                if (tmpidset == null)
                {
                 System.debug('****************GM.UserOrGroupId '+GM.UserOrGroupId);
                    tmpidset  = new set<Id>();
                    tmpidset.add(GM.UserOrGroupId);
                    GroupNametoIds.put(GM.group.developername,tmpidset);
                }else
                {
                    tmpidset.add(GM.UserOrGroupId);
                    GroupNametoIds.put(GM.group.developername,tmpidset);
                }
                //usertoEmail.put(GM.UserOrGroupId,'');
                //theMap.put(GM.group.developername,
            }
        }
        list<User> recipientPersons=[SELECT id,email FROM User where isactive = true and id in :userIds];
        Map<Id, User> mapRecipients = new Map<Id, User>(recipientPersons);
        map<String,Set<String>> GroupNametoEmails = new map<String,Set<String>>();
        for(String currentQueue :setQueue)
        {
            set<Id> tmpidset = new set<Id>();
            tmpidset = GroupNametoIds.get(currentQueue);
            if (tmpidset != null)
            {
                for (Id currentId :tmpidset)
                { 
                    set<String> tmpStringSet = GroupNametoEmails.get(currentQueue);
                    System.debug('****************tmpStringSet  '+tmpStringSet );
                    if (tmpStringSet == null)
                    {
                        tmpStringSet = new set<String>();
                        tmpStringSet.add(mapRecipients.get(currentId).email);
                        GroupNametoEmails.put(currentQueue,tmpStringSet);
                    }else
                    {
                        System.debug('****************mapRecipients.get(currentId) '+mapRecipients.get(currentId));
                        
                        if (mapRecipients.get(currentId) != null )
                        {
                            tmpStringSet.add(mapRecipients.get(currentId).email);
                            GroupNametoEmails.put(currentQueue,tmpStringSet);
                        }
                    }
                }
            }          
        }
         System.debug('****************GroupNametoEmails '+GroupNametoEmails); */
         
         //BatchRunLeadTriggers newBatch = new BatchRunLeadTriggers();
        // Database.executeBatch(newBatch,50);
         
         
        // sendEmails(setQueue,GroupNametoEmails);
        step++;
        return null;
    }
/*
    public void sendEmails(Set<String> setQueueNames,map<String,Set<String>> GroupNametoEmails ){
        List<Messaging.SingleEmailMessage> allMails = new List<Messaging.SingleEmailMessage>();
        //now do your loop
        List<EmailTemplate> template = new List<EmailTemplate>();
        template = [select id, Subject, HtmlValue, Body from EmailTemplate where developername = : 'Leads_Massive_new_assignment_notification_External_List'];  
        for (String currentQueue :setQueueNames) {
        
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String mailName ='Utente';
            integer recordNumber = 1000;
            
        
            system.debug('+++++++thisemailtemplate'+template.get(0));
            mail.setUseSignature(false);
            map<String,String> mapFieldToValue = new Map<String,String>();
            mapFieldToValue.put('{!User.FirstName}',mailName);
          //  mapFieldToValue.put('{!recordNumber}','dei' ); 
         //   mapFieldToValue.put('{!Link}','https://'+System.URL.getSalesforceBaseUrl().getHost()+'/00Q/o' );
            String tempURL = System.URL.getSalesforceBaseUrl().toExternalForm();
            //String tempURL= System.URL.getCurrentRequestUrl().toExternalForm();
           // mapFieldToValue.put('{!Link}',tempURL.SPLIT('/apex/',-1).get(0)+'/agenzie/00Q/o' );        
            mail = UtilityClass.prepareEmailTemplate(template.get(0),mapFieldToValue );
            list<String> destinations = new list<String>(GroupNametoEmails.get(currentQueue));
            mail.setToAddresses( destinations);
        
            mail.setSaveAsActivity(false);
        
            system.debug('+++++++++mail prepared'+mail);
          //  Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            if (destinations!= null && destinations.size()>0){
                allMails.add(mail);
            }
        
        }
        //Finished your loop? Now you have an array of mails to send.
        //This uses 1 of your 10 calls to sendEmail that you are allowed
        try{ 
            if (allMails.size()>0){
                Messaging.sendEmail(allMails);
            }
        } catch (Exception e)
        {
            system.debug('Email Sending Exception');   
        }
        system.debug('+++++EMAIL limit (calls/limit)='+Limits.getEmailInvocations()+'/'+Limits.getLimitEmailInvocations());    
    } */      
    public PageReference cancel() {
        file_nome = '';
        numVal = 0;
        numErr = 0;
        try{
            if(cc!=null && cc.Status__c!='Elaborato')
                Database.DeleteResult MyResult = database.delete(cc);
            }
        catch(Exception e){
            System.debug(e);
            }
        cc =  new Lead_Upload_History__c();
        if(step!=0) 
            step--;
        return null;
    }  
    
    public PageReference nuovoCaricamento(){
        step = 0;
        numErr = 0;
        numVal = 0;
        file_nome = '';
        cc = new Lead_Upload_History__c();
        return null;
        }
        
    public pagereference uscita(){
            pagereference pg = new pagereference('/home/home.jsp');
            pg.setredirect(true);
            return pg;
        }
    
    public static String blobToString(Blob input, String inCharset){
        String hex = EncodingUtil.convertToHex(input);
        System.assertEquals(0, hex.length() & 1);
        final Integer bytesCount = hex.length() >> 1;
        String[] bytes = new String[bytesCount];
        for(Integer i = 0; i < bytesCount; ++i)
            bytes[i] =  hex.mid(i << 1, 2);
        return EncodingUtil.urlDecode('%' + String.join(bytes, '%'), inCharset);
    }
}