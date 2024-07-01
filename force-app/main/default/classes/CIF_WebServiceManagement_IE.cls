/*------------------------------------------------------------------------
Author:        Davide Fabris
Company:       Deloitte
Class:         CIF_WebServiceManagement_IE
Description:   Class that supports the CRM logics on the CIF webservice with IE approach
History
 -14/01/2015   Davide Fabris - Created from CIF_WebServiceManagement
 -28/10/2016   Davide Fabris - bugFix per gestione nodi di sub-agenzia-->method getNodesList()
----------------------------------------------------------------------------*/
public without sharing class CIF_WebServiceManagement_IE {
    public static List<ApplicationLogHelper.ErrorWrapper> Errors = new List<ApplicationLogHelper.ErrorWrapper>();
    //Class Attributes 
    public Map<string,string> codificaProvince; //map from custom setting externalkey-->SFDC value (eg MI-->Milano);
    public User CurrentUser; //can be modified in order to check different users (e.g. from batch)
    // public static IE_Configuration__c IE_config =[SELECT Id, Request_compiler__c,Response_parser__c,Type__c,Certificate__c,EndPoint__c from IE_Configuration__c where Name='CIF_Integration' limit 1];
    public static IE_Configuration__c IE_config ;
    //public esitoCheckSetInfo thisLeadCheck;
    
    public CIF_WebServiceManagement_IE(string ConfigName) {
        //Public constructor
        Map<String,String> codificaProvince = new Map<String,string>();
        List<MappingProvince__c> myMappingprovince = SharingUtility.transferQuery('SELECT ProvinciaExternalKey__c,SFDCexpected__c from MappingProvince__c');
        for (MappingProvince__c thismapping : myMappingprovince) {
        //system.debug('++++this.codificaProvince'+codificaProvince);
            codificaProvince.put(thismapping.ProvinciaExternalKey__c,thismapping.SFDCexpected__c);
        }
        List<User> myUser = [SELECT id, Agency_Code__c,Nodes__c,UserCurrentSetup__c,ProfileId,Profile.Name, UserRoleId, UserRole.DeveloperName, TECH_Email__c from User WHERE ID = :UserInfo.getuserID() ]; // NOPMD  Fix CRUD violation
        CurrentUser = myUser[0];
        
        //setting the configuration ID;
        IE_config =[SELECT Id, Request_compiler__c,Response_parser__c,Type__c,Certificate__c,EndPoint__c from IE_Configuration__c where Name=:ConfigName limit 1];
        system.debug('+++++++++@ constructor'+IE_config);
    }
    ////////////////START SUPPORT CLASSES////////////////
    //Class to support the check on the minimum info required to Call the WS
    public class esitoCheckSetInfo{ 
        public boolean isSetComplete; // TRUE if the set is complete, FALSE otherwise
        public map<String,String> missing_Fields; //map with Field-->error message 
        public Lead LeadChecked;
    }
    
    //Class to handle the WS response 
    public class CIF_Response{
        public string raw_response; //the full resposnse of the WS as JSON string
        public String EsitoLavorazione; //can be the same as the one in the raw_response, or be modified
        public Integer N_Occorrenze; //the same number as provided by the WS
        public String Error; //can be the same as in raw error or can be modified
        public List<CIF_record> returnedRecords;//the list of records formatted for efficient management in the CRM
    }
    
    //Class to handle the single line of the returned records
    public class CIF_record {
        public String type;
        // used to categorize the returned record. So far the categories can be
        //--> "NEW":the record has been created on CIF
        //--> "NOACCESS": the current user has no visibility on the record;
        //--> "EXISTING": the current user has visibility on the record and it is present on the CRM
        //--> "CIFONLY": the current user has visibility but the record is not on the CRM
        
        public string NDG;
        public string LastEdit;
        public string tipoSoggetto; //FISICO-GIURIDICO
        public set<string>Nodes;
        public string Name;
        public Account CorrespondingAccount; //an account object corresponding o the CIF record. Retrieved, if possible with a query on the NDG
        public Lead UpdatedLead ;//new lead object populated with the information retrieved from CIF. 
        public object rawCIFrecord;//the raw record information returned from CIF
        
    }
    ////////////////END SUPPORT CLASSES////////////////

    ////////////////START of METHODS////////////////

    //Given a single lead perform the controls on the minimum set of info <-- TO DO, manage a list of leads
    public esitoCheckSetInfo checkSetInfoPhysical(Lead thisLead) { 
        system.debug('+++++++START esitoCheckSetInfo METHOD+++++++');
        system.debug('+++++Lead to check'+thisLead);
        
        esitoCheckSetInfo esitoCheck= new esitoCheckSetInfo();
        esitoCheck.isSetComplete = true;
        esitoCheck.missing_Fields = new map<String,string>();
        //Common fields
        if(String.isempty(thisLead.FirstName)){
            esitoCheck.missing_fields.put('FirstName','Il nome deve essere specificato');
            system.debug('++++MISSING required field for call');
            esitoCheck.isSetComplete = false;
            }
        if(String.isempty(thisLead.LastName)){
            esitoCheck.missing_fields.put('LastName','Il cognome deve essere specificato');
            system.debug('++++MISSING required field for call');
            esitoCheck.isSetComplete = false;
            }
        if(String.isempty(thisLead.Fiscal_ID__c)){
            esitoCheck.missing_fields.put('Fiscal_ID__c','Il codice fiscale deve essere specificato');
            system.debug('++++MISSING required field for call');
            esitoCheck.isSetComplete = false;
            }
     /*   if(String.isempty(thisLead.Agency_Code__c)){
            esitoCheck.missing_fields.put('AgencyCode','Il codice agenzia deve essere specificato');
            system.debug('++++MISSING required field for call');
            esitoCheck.isSetComplete = false;
        } */
    /*    if(String.isempty(thisLead.Provincia_di_nascita__c)){
            esitoCheck.missing_fields.put('ProvinciaDiNascita','La provincia di nascita deve essere specificata');
            system.debug('++++MISSING required field for call');
            esitoCheck.isSetComplete = false;
        } */
    /*    if(String.isempty(thisLead.Birth_Place__c )){
            esitoCheck.missing_fields.put('BirthPlace','Il luogo di nascita deve essere specificato');
            system.debug('++++MISSING required field for call');
            esitoCheck.isSetComplete = false;
        } */
   /*     if(String.isempty(thisLead.Gender__c)){
            esitoCheck.missing_fields.put('Gender','Il sesso deve essere specificato');
            system.debug('++++MISSING required field for call');
            esitoCheck.isSetComplete = false;
        }   */         
    /*    if(String.isempty(thisLead.Street)){
            esitoCheck.missing_fields.put('Street','L\' indirizzo (Via) deve essere specificato');
            system.debug('++++MISSING required field for call');
            esitoCheck.isSetComplete = false;
        } */
    /*    if(String.isempty(thisLead.City)){
            esitoCheck.missing_fields.put('City','L\' indirizzo (Città) deve essere specificato');
            system.debug('++++MISSING required field for call');
            esitoCheck.isSetComplete = false;
        } */
  /*      if(String.isempty(thisLead.State)){
            esitoCheck.missing_fields.put('State','L\' indirizzo (Provincia) deve essere specificato');
            system.debug('++++MISSING required field for call');
            esitoCheck.isSetComplete = false;
        }  */
        // NoAuto's fields  
     /*   if((thisLead.RecordType.DeveloperName == 'No_Motor')||(thisLead.RecordType.DeveloperName == 'Previdenza')||(thisLead.RecordType.DeveloperName == 'Protezione')){
            if(thisLead.Lead_Birthdate__c == null){
                esitoCheck.missing_fields.put('LeadBirthdate','La data di nascita deve essere specificata');
                system.debug('++++MISSING required field for call');
                esitoCheck.isSetComplete = false;
            }
        } */
        //Auto's fields
  /*      if(thisLead.RecordType.DeveloperName == 'Motor'){
            if(thisLead.Nominee_Birthdate__c == null){
                esitoCheck.missing_fields.put('NomineeBirthdate','La data di nascita dell\'intestatario deve essere specificata');
                system.debug('++++MISSING required field for call');
                esitoCheck.isSetComplete = false;
            }               
        }  */
        esitoCheck.LeadChecked = thisLead;
        //
        system.debug('+++++++END esitoCheckSetInfo METHOD+++++++');
        return esitoCheck;
    }
    public esitoCheckSetInfo checkSetInfoCompany(Lead thisLead) { 
        system.debug('+++++++START esitoCheckSetInfo METHOD+++++++');
        system.debug('+++++Lead to check'+thisLead);
        
        esitoCheckSetInfo esitoCheck= new esitoCheckSetInfo();
        esitoCheck.isSetComplete = true;
        esitoCheck.missing_Fields = new map<String,string>();
        //Common fields
        /*  if(String.isempty(thisLead.Street)){
            esitoCheck.missing_fields.put('Street','L\' indirizzo (Via) deve essere specificato');
            system.debug('++++MISSING required field for call');
            esitoCheck.isSetComplete = false;
        } */
      /*  if(String.isempty(thisLead.City)){
            esitoCheck.missing_fields.put('City','L\' indirizzo (Città) deve essere specificato');
            system.debug('++++MISSING required field for call');
            esitoCheck.isSetComplete = false;
        } */
     /*   if(String.isempty(thisLead.State)){
            esitoCheck.missing_fields.put('State','L\' indirizzo (Provincia) deve essere specificato');
            system.debug('++++MISSING required field for call');
            esitoCheck.isSetComplete = false;
        }  */         
        if(String.isempty(thisLead.Company)){ //useless for now
            esitoCheck.missing_fields.put('Company','La ragione sociale deve essere specificata');
            system.debug('++++MISSING required field for call');
            esitoCheck.isSetComplete = false;
        }
        if(String.isempty(thisLead.AAI_Partita_IVA__c)){ //useless for now
            esitoCheck.missing_fields.put('AAI_Partita_IVA__c','La partita IVA deve essere specificata');
            system.debug('++++MISSING required field for call');
            esitoCheck.isSetComplete = false;
        } 
        esitoCheck.LeadChecked = thisLead;
        //
        system.debug('+++++++END esitoCheckSetInfo METHOD+++++++');
        return esitoCheck;
    }    
    //Given a single lead checked (use previous method) it makes a CIF call. In this way I enforce that a check on the lead is performed.
    //return  the corresponding  CIF_response
    public CIF_Response MakeCIFcall(esitoCheckSetInfo thisLeadChecked) { 
        system.debug('+++++++START MakeCIFcall METHOD+++++++');
        CIF_Response ResponseReturned= new CIF_Response();
        ResponseReturned.raw_response='';
        ResponseReturned.EsitoLavorazione='Stopped at IE instance initialisation';
        ResponseReturned.N_Occorrenze=null; //the same number as provided by the WS
        ResponseReturned.Error='Stopped at IE instance initialisation';
        ResponseReturned.returnedRecords = new List<CIF_record> ();
        
        system.debug('+++++++Initialising IE integ record+++++++');
        IE_Integration_Record__c myIE_Record =  new IE_Integration_Record__c();
        string ScopeID=String.ValueOf(thisLeadChecked.LeadChecked.Id);//the lead ids
        ScopeID = ScopeID + ';' + String.ValueOf(UserInfo.getUserId());//the User id (for nodes)
        myIE_Record.ScopeID__c=ScopeID;
        system.debug('+++++set this scopeids'+ScopeID);
        
        try {
            system.debug('++++++++++++++@initialisation of engine'+IE_config);
            myIE_Record.IE_Configuration__c= IE_config.Id; //computed on the constructor
        } catch ( exception e ) {
            ResponseReturned.EsitoLavorazione='ERRORE';
            ResponseReturned.Error='Al momento il non è possibile completare l\'operazione richiesta.';
            myIE_Record.ErrorMessage__c='Error at line '+ e.getLineNumber() + 'Configuration not specified'+ e.getStackTraceString();
            myIE_Record.Status__c='KO';
            upsert myIE_Record; // NOPMD  Fix CRUD violation            
            return ResponseReturned;
        }
        
        system.debug('+++++++Initialising IE ENGINE for CIF integration+++++++');
        IE_Engine myIE_instance = new IE_Engine(myIE_Record);
        
        /*try {
            myIE_instance = new IE_Engine(myIE_Record);
        } catch ( exception e ) {
            ResponseReturned.EsitoLavorazione='INTERNAL-ERROR';
            ResponseReturned.Error='Error at line '+ e.getLineNumber() + 'IE could not be initialised'+ e.getStackTraceString();
            return ResponseReturned;
        }TODO sort out error handling for constructor */
        
        system.debug('++++++++++compiling request+++++++++');
        try {
            myIE_instance.compilerequest();
            system.debug('+++THE compiled request'+myIE_instance.compiledXML);
        } catch ( exception e ) {
            ResponseReturned.EsitoLavorazione='ERRORE';
            ResponseReturned.Error='Al momento il non è possibile completare l\'operazione richiesta.';
            myIE_Record.ErrorMessage__c='Error at line '+ e.getLineNumber() + 'IE could not compile a request'+ e.getStackTraceString();
            myIE_Record.Status__c='KO';
            upsert myIE_Record; // NOPMD  Fix CRUD violation            
            return ResponseReturned;
        }

        try {
            system.debug('++++++++++sending request+++++++++');
            myIE_instance.sendRequest();
        } catch ( exception e ) {
            system.debug('++++++++++sending request FAILED+++++++++');
            if (false) {//set to TRUE to make the CALL, to fals to get fake response
                ResponseReturned.EsitoLavorazione='ERRORE';
                ResponseReturned.Error='Al momento il non è possibile completare l\'operazione richiesta.';
                myIE_Record.ErrorMessage__c='Error at line '+ e.getLineNumber() + ' Request not sent '+ e.getStackTraceString();       
                myIE_Record.Status__c='KO';            
                upsert myIE_Record; // NOPMD  Fix CRUD violation          
                return ResponseReturned;
            } else {
            system.debug('++++++++++inserting fake response+++++++++');
            //HERE I COULD INSERT FAKE RESPONSES
            string sampleresponse =saveLocalObject('A000Agent');
            system.debug('++++fake response'+sampleresponse);
            myIE_instance.Rawresponse = new HTTPResponse();
            myIE_instance.Rawresponse.setbody(sampleresponse);  
            system.debug('++++++++++++++++++the engine'+myIE_instance);

            }
        }

        
        system.debug('++++++++++parsing response with Engine+++++++++');
        system.debug('+++++the engine'+myIE_instance);
        try {
            myIE_instance.interpretResponse();
        } catch ( exception e ) {
            ResponseReturned.EsitoLavorazione='ERRORE';
            ResponseReturned.Error='Al momento il non è possibile completare l\'operazione richiesta.';
            myIE_Record.ErrorMessage__c='Error at line '+ e.getLineNumber() + 'Response not parsed'+ e.getStackTraceString();
            myIE_Record.Status__c='KO';
            upsert myIE_Record; // NOPMD  Fix CRUD violation          
            return ResponseReturned;
        }
        // here everything should be OK so i start actually compiling the response accrding to the JSON response
        //FIRST  i  set the rawResposne as the JSON string
        ResponseReturned.raw_response=myIE_instance.JSONresponse;
        
        //now I perform the mapping JSON-->Class
        system.debug('++++++++++parsing response Json-->class +++++++++');
        try {
          //  Map<String, Object> rawMap= (Map<String, Object>) JSON.deserializeUntyped(ResponseReturned.raw_response);
    
            ResponseReturned.EsitoLavorazione=JSONUtility.getField(ResponseReturned.raw_response,'esitoElaborazione').get(0);//(string) rawMap.get('esitoElaborazione');//<--TO DO, dedicated method for mapping CIF result
            system.debug('+++++++++++++esitoElaborazione'+ResponseReturned.EsitoLavorazione);

            ResponseReturned.Error=JSONUtility.getField(ResponseReturned.raw_response,'messaggioErrore').get(0);//(string) rawMap.get('messaggioErrore');//<--TO DO, dedicated method for mapping CIF result
            system.debug('+++++++++++++Error'+ResponseReturned.Error);
            
            ResponseReturned.N_Occorrenze=integer.valueof(JSONUtility.getField(ResponseReturned.raw_response,'totaleOccorrenze').get(0));//(integer.valueof(rawMap.get('totaleOccorrenze')));//no parsing required here
            system.debug('+++++++++++++N_Occorrenze'+ResponseReturned.N_Occorrenze);            
        } catch ( exception e ) {
            ResponseReturned.EsitoLavorazione='ERRORE';
            ResponseReturned.Error='Al momento il non è possibile completare l\'operazione richiesta.';
            myIE_Record.ErrorMessage__c='Error at line '+ e.getLineNumber() + 'Could not deserializeUntyped RESPONSE'+ e.getStackTraceString();
            myIE_Record.Status__c='KO';
            upsert myIE_Record; // NOPMD  Fix CRUD violation
            // ResponseReturned.Error='Error at line '+ e.getLineNumber() + 'Could not deserializeUntyped RESPONSE'+ e.getStackTraceString();

            return ResponseReturned;
        }
        
        //now I just need to parse the list of record returned
        ResponseReturned.returnedRecords = new List<CIF_record> ();
        try {
            system.debug('++++currentUser'+CurrentUser);
            ResponseReturned.returnedRecords=formatCIFRecordResponse(ResponseReturned.raw_response, CurrentUser);
        } catch ( exception e ) {
            ResponseReturned.EsitoLavorazione='ERRORE';
            ResponseReturned.Error='Al momento il non è possibile completare l\'operazione richiesta.';
            myIE_Record.ErrorMessage__c='Error at line '+ e.getLineNumber() + 'Could not deserializeUntyped ONE or MORE single records'+ e.getStackTraceString();
            myIE_Record.Status__c='KO';
            upsert myIE_Record; // NOPMD  Fix CRUD violation
            // ResponseReturned.Error='Error at line '+ e.getLineNumber() + 'Could not deserializeUntyped ONE or MORE single records'+ e.getStackTraceString();
            return ResponseReturned;
        }
        return ResponseReturned;
    }
    
    //Given a RAW response from CIF WS returns a more usable RESPONSE -->See Decorated_esitoSalvaSoggettoCrm class details

    
        //Given a RAW RESPONSE from CIF in JSON string format , returns a list of more usable objects corresponding to CIF/CRM records--> See Decorated_soggettoCRM class for details
    //if the raw response is a succesfull one it returns the single record
    //if the raw response is a negative one with records (A001) it returns a list of decorated objects
    //if the raw response is a negative one without records (W or E) and empty list is returned
    public List<CIF_record> formatCIFRecordResponse(string raw_response, User thisUser) {

        
        system.debug('+++++++START formatRecordResponse METHOD+++++++');
        List<CIF_record> Resulting_CIF_records = new List<CIF_record>();
        
       // Map<String, Object> rawMap = (Map<String, Object>) JSON.deserializeUntyped(raw_response);

        //this map uses as key a NDG (string) and return an account if found on the DB, or null;
        Map<string,Account> Map_CIF_NDGtoAccount = new Map<string,Account>();
        
        List<Object> rawRecordList = new List<Object>();
        
        //string esito = (string) rawMap.get('esitoElaborazione');
        list<String> esitoList = JSONUtility.getField(raw_response,'esitoElaborazione');
        String esito=esitoList.get(0);
         system.debug('++++++esito'+esito);
        if (esito.left(1)=='W') {
            //Formatting Error handling. Should not happen
        } else if (esito.left(1)=='E') {
            //general error, may be connection or address, can happen
        } else if (esito.left(1)=='A') {
            //record found on CIF
          //  system.debug('++++++rawMap.soggettoEsistente'+rawMap.get('soggettoEsistente'));
            try {//shoulde have one or more records
               // List<Object> soggetti =(List<Object>)rawMap.get('soggettoEsistente');
                List<Object> soggetti = JSONUtility.getObjectList(raw_response,'soggettoEsistente');
                rawRecordList.addAll(soggetti);
            } catch (exception e) {
                    ApplicationLogHelper.ERROR('CIF_WebServiceManagement_IE', e.getMessage(), e.getStackTraceString());
               // Object soggetti =(Object)rawMap.get('soggettoEsistente');
               // rawRecordList.add(soggetti);
            }
            
            Map_CIF_NDGtoAccount = getExistingAccounts(rawRecordList);//queries on the NDG and maps NDG to account
            // running through the returned objects
            for (Object this_raw_soggetto: rawRecordList ) {
                system.debug('+++++++this_raw_soggetto from CIF'+this_raw_soggetto);
                //for each object I need the map
                map<string, object> this_raw_soggettoMAP = (map<string, object>) this_raw_soggetto;
                //initialise the record to return
                CIF_record thisrecord = new CIF_record();
                //thisrecord.tipoSoggetto = (string) this_raw_soggettoMAP.get('tipoSoggetto');
                String tipoSoggettoStr = JSONUtility.getField(this_raw_soggetto,'tipoSoggetto').get(0);
                thisrecord.tipoSoggetto = tipoSoggettoStr;
                //thisrecord.NDG = (string) this_raw_soggettoMAP.get('Ndg');
                thisrecord.NDG = JSONUtility.getField(this_raw_soggetto,'Ndg').get(0);
                //thisrecord.LastEdit = (string) this_raw_soggettoMAP.get('timestampCif');
                thisrecord.LastEdit = JSONUtility.getField(this_raw_soggetto,'timestampCif').get(0);
                //Sorting out nodes
                thisrecord.nodes=new set<String>();
                //list<string> nodes = getNodesList(this_raw_soggettoMAP);
                list<string> nodes = getNodesList(this_raw_soggetto);
                 thisrecord.nodes.addAll(nodes);
                 system.debug('********thisrecord'+thisrecord);
                /*list<string> nodes = (list<String>)this_raw_soggettoMAP.get('codiceSubagenzia');
                if (nodes!=null) {
                    for (string thisnode : nodes) {
                        thisrecord.nodes.add(thisnode);
                    }
                }
                thisrecord.nodes.add(''+this_raw_soggettoMAP.get('codiceAgenzia'));
                */
                //Tracing the account name
                if (tipoSoggettoStr=='FISICO') {
                   // map<string,object> rawSoggettoFisico = (map<string,object>) this_raw_soggettoMAP.get('soggettoFisico');
                    Object rawSoggettoFisicoObj = JSONUtility.getObject(this_raw_soggetto,'soggettoFisico').get(0); 
                    system.debug('+++++rawSoggettoFisicoObj '+rawSoggettoFisicoObj);
                    string FN = '';
                    
                    if ((JSONUtility.getField(rawSoggettoFisicoObj,'nome').get(0)) !=null){ //rawSoggettoFisico.get('nome')
                        FN= JSONUtility.getField(rawSoggettoFisicoObj,'nome').get(0) ; //''+rawSoggettoFisico.get('nome')
                    } else {
                        FN = '';
                    }
                    
                    string LN = '';
                    if ((JSONUtility.getField(rawSoggettoFisicoObj,'cognome').get(0)) !=null){ //rawSoggettoFisico.get('cognome'
                        LN= JSONUtility.getField(rawSoggettoFisicoObj,'cognome').get(0) ; //''+rawSoggettoFisico.get('cognome') 
                    } else {
                        FN = '**Cognome non presente**';
                    }
                    //thisrecord.Name = ''+rawSoggettoFisico.get('nome') +  ' ' + rawSoggettoFisico.get('cognome') ;
                    thisrecord.Name = FN + ' ' + LN;
                } else if (tipoSoggettoStr=='GIURIDICO') {
                   // map<string,object> rawSoggettoGiuridico = (map<string,object>) this_raw_soggettoMAP.get('soggettoGiuridico');
                    Object rawSoggettoGiuridicoObj = JSONUtility.getObject(this_raw_soggetto,'soggettoGiuridico').get(0);
                    system.debug('+++++rawSoggettoGiuridicoObj '+rawSoggettoGiuridicoObj );
                    thisrecord.Name = JSONUtility.getField(rawSoggettoGiuridicoObj,'denominazione').get(0);// ''+rawSoggettoGiuridico.get('denominazione') ;
                }
            
                thisrecord.CorrespondingAccount=Map_CIF_NDGtoAccount.get(thisrecord.NDG);
                thisrecord.UpdatedLead=generateLeadInstance(this_raw_soggetto,tipoSoggettoStr);
                for (string thisnode : thisrecord.nodes) {
                    thisnode=thisnode.trim();
                    thisrecord.UpdatedLead.TECH_Nodes__c=thisrecord.UpdatedLead.TECH_Nodes__c+thisnode+';';
                }
                thisrecord.UpdatedLead.TECH_Nodes__c = thisrecord.UpdatedLead.TECH_Nodes__c.removeEnd(';');
                thisrecord.UpdatedLead.TECH_NDG__c= thisrecord.NDG;
                system.debug('++++thisrecord.UpdatedLead.TECH_Nodes__c '+thisrecord.UpdatedLead.TECH_Nodes__c);
                system.debug('++++thisrecord.UpdatedLead.FirstName '+thisrecord.UpdatedLead.FirstName);
                thisrecord.rawCIFrecord=this_raw_soggetto;
                if (esito=='A000'){
                    thisrecord.type='NEW';
                } else {  //check the list of records returned
                    if (Map_CIF_NDGtoAccount.containskey( thisrecord.NDG)) {
                        thisrecord.type='EXISTING';
                    } else {
                        //check visibility
                        system.debug('+++++++currentUser'+thisUser.nodes__c);
                        if (checkVisibility(this_raw_soggetto,thisUser.nodes__c)){
                            thisrecord.type='CIFONLY';
                        } else {
                            thisrecord.type='NOACCESS';
                        }
                    }
                }
                Resulting_CIF_records.add(thisrecord);
            }
            if(!Errors.isEmpty()) {
                ApplicationLogHelper.LogErrors('CIF_WebServiceManagement_IE', Errors);
                Errors.clear();
            }
        } else {
            //unknown error present on the raw_response
        }
        system.debug('+++++++ END formatRecordResponse METHOD+++++++');
        return Resulting_CIF_records;
    }
    
    //given a list of RAW records from CIF returns the existing Accounts *****************DO NOT USE ON A FOR LOOP*****************
    public Map<String, Account> getExistingAccounts(List<Object> rawRecordList) {
    system.debug('++++entering getExistingAccounts');
    system.debug('++++the rawRecordList'+rawRecordList);
    system.debug('++++list size'+rawRecordList.size());
        Set<String> all_NDG=new set<String>();
        Map<String, Account> thisresult = new Map<String, Account>();
        system.debug('++++++thisresult='+thisresult );
        for (object this_raw_soggetto: rawRecordList ) {//these are object
        system.debug('+++thei current soggetto obj'+this_raw_soggetto);
           // map<string, object> this_raw_soggettoMAP = (map<string, object>) this_raw_soggetto;
          //  system.debug('+++this this_raw_soggettoMAP '+this_raw_soggettoMAP );
            string tempNdg = JSONUtility.getField(this_raw_soggetto,'Ndg').get(0);
            all_NDG.add(tempNdg);//''+this_raw_soggettoMAP.get('Ndg')
            system.debug('+++ndg found'+all_NDG);
        }
        List<Account> all_Account = new list<Account>();
        all_Account = [SELECT id,PersonContactId, NDG__c, FirstName, LastName, Name, Salutation, RecordTypeId from account WHERE NDG__c in:all_NDG];
        system.debug('+++++the corresponding accounts'+all_Account);
        for (account thisaccount: all_Account) {
            thisresult.put(thisaccount.NDG__c,thisaccount);
        }
        return thisresult;
    }

 //Given a raw record returned from CIF I create the corresponding lead instance
    public Lead generateLeadInstance(object raw_record, string clientType) {
        //the object corresponds to "soggettoEsistente"
        //HERE I PERFORM THE MAPPING CIF->SFDC
        Lead l = new Lead();
        
    //HERE I PERFORM THE MAPPING SFDC-->CIF
    system.debug('++++rawRecordto map to lead'+raw_record);
    map<string,object> raw_recordMAP = (map<String,Object>) raw_record;
    
    string theAgency = (JSONUtility.getField(raw_record,'codiceAgenzia').get(0));//''+raw_recordMAP.get('codiceAgenzia')
            l.Agency_Code__c = theAgency.trim();
            l.TECH_NDG__c=(JSONUtility.getField(raw_record,'Ndg').get(0));//''+raw_recordMAP.get('NDG')

    
        //String.isempty(raw_record.SoggettoFisico.nome) ? 'Nome non disponibile' : raw_record.SoggettoFisico.nome;
      //  map<string,object> soggettoFisico = (map<string,object>) raw_recordMAP.get('soggettoFisico');
        Object soggettoFisicoObj = JSONUtility.getObject(raw_record,'soggettoFisico').get(0); 
        system.debug('++++++++++++soggettoFisicoObj '+soggettoFisicoObj);
        if (soggettoFisicoObj!=null) {
            /*
            string FN = '';
            if (SoggettoFisico.get('nome') !=null){
                FN= ''+SoggettoFisico.get('nome') ;
            } else {
                FN ='';
            }
            
            string LN = '';
            if (SoggettoFisico.get('cognome') !=null){
                LN= ''+SoggettoFisico.get('cognome') ;
            } else {
                LN ='';
            }
             */       

            string FN = '';
            
            if ((JSONUtility.getField(soggettoFisicoObj,'nome').get(0)) !=null){ 
                FN= JSONUtility.getField(soggettoFisicoObj,'nome').get(0) ;
            } else {
                FN = '';
            }
            
            string LN = '';
            if ((JSONUtility.getField(soggettoFisicoObj,'cognome').get(0)) !=null){ 
                LN= JSONUtility.getField(soggettoFisicoObj,'cognome').get(0) ;
            } else {
                FN = '';
            }
            
            l.FirstName=FN;
            l.LastName=LN;

            l.Fiscal_ID__c=JSONUtility.getField(soggettoFisicoObj,'codiceFiscale').get(0) ;//''+SoggettoFisico.get('codiceFiscale');
            system.debug('++++++++++++l.Fiscal_ID__c '+l.Fiscal_ID__c);
            if (JSONUtility.getField(soggettoFisicoObj,'sesso').get(0)=='M'){//''+SoggettoFisico.get('sesso')
                l.Gender__c='Male';
            } else {
                l.Gender__c='Female';
            }
            
            if (JSONUtility.getField(soggettoFisicoObj,'dataNascita').get(0)!=null) { //SoggettoFisico.get('dataNascita')
                l.Lead_Birthdate__c=   date.valueOf(JSONUtility.getField(soggettoFisicoObj,'dataNascita').get(0));//''+SoggettoFisico.get('dataNascita')
                l.Nominee_Birthdate__c=date.valueOf(JSONUtility.getField(soggettoFisicoObj,'dataNascita').get(0));//''+SoggettoFisico.get('dataNascita')
            }
            
            l.Birth_Place__c=JSONUtility.getField(soggettoFisicoObj,'localitaNascita').get(0);//''+SoggettoFisico.get('localitaNascita');
            l.Provincia_di_nascita__c=JSONUtility.getField(soggettoFisicoObj,'provinciaNascita').get(0);//''+SoggettoFisico.get('provinciaNascita');
            
           // system.debug('++++++dati indirizzo'+raw_recordMAP.get('datiIndirizzo'));
           // map<string,object> datiIndirizzo = (map<string,object>) raw_recordMAP.get('datiIndirizzo');
        }

        Object datiIndirizzoObj = JSONUtility.getObject(raw_record,'datiIndirizzo').get(0);  //mandatory
        system.debug('++++++++++++datiIndirizzoObj '+datiIndirizzoObj );
        if (datiIndirizzoObj!=null) {
          //  l.street = String.isempty(''+datiIndirizzo.get('indirizzo')) ? '' : ''+datiIndirizzo.get('indirizzo');
            l.street = String.isempty(JSONUtility.getField(datiIndirizzoObj ,'indirizzo').get(0)) ? '' : JSONUtility.getField(datiIndirizzoObj ,'indirizzo').get(0);
            
          //  l.city = String.isempty(''+datiIndirizzo.get('localita')) ? '' : ''+datiIndirizzo.get('localita');
            l.city = String.isempty(JSONUtility.getField(datiIndirizzoObj ,'localita').get(0)) ? '' : JSONUtility.getField(datiIndirizzoObj ,'localita').get(0);
            
         //   String codiceProvincia = String.isempty(''+datiIndirizzo.get('provincia')) ? '' : ''+datiIndirizzo.get('provincia');
            String codiceProvincia = String.isempty(JSONUtility.getField(datiIndirizzoObj ,'provincia').get(0)) ? '' : JSONUtility.getField(datiIndirizzoObj ,'provincia').get(0);
             
            String nomeProvincia= checkProvince(codiceProvincia);
            system.debug('++++++nomeProvincia '+nomeProvincia);
            if (nomeProvincia==null)
            {
                 nomeProvincia= '';
                 l.city=l.city+' ('+codiceProvincia+')';
            }
            else
            {
                l.stateCode = codiceProvincia;
            }
            system.debug('++++++l.stateCode '+l.stateCode);
            system.debug('++++++l.city '+l.city);
        }
        l.TECH_Nodes__c ='';
            
        
        Object soggettoGiuridicoObj = JSONUtility.getObject(raw_record,'soggettoGiuridico').get(0); 
        system.debug('++++++++++++soggettoGiuridicoObj '+soggettoGiuridicoObj);
        if (soggettoGiuridicoObj!=null) { 
            l.AAI_Partita_IVA__c=JSONUtility.getField(soggettoGiuridicoObj,'partitaIva').get(0) ;
            system.debug('++++++++++++l.AAI_Partita_IVA__c '+l.AAI_Partita_IVA__c);
            l.Company=JSONUtility.getField(soggettoGiuridicoObj,'denominazione').get(0) ;

        }
        if (clientType=='FISICO'){
            l.Company = '';
        }
        return l;
    }
    
    
  //given a RAW record from CIF returns
    //"true" if the nodes of the records do NOT contain the nodes on the string separated by ";" (DIF_ is removed if present)
    //"false" if the nodes of the records do not match any of the nodes of the string 
    
    public boolean checkVisibility(object raw_record, string nodes_string) {
        //the object corresponds to "soggettoEsistente"
        map<string,object> raw_recordMAP = (map<string,object>) raw_record;
        system.debug('+++++raw_recordMAP'+raw_recordMAP);
        
        
        if(String.isempty(nodes_string)){
        return false;
        } else {
            set<String> userNodes = new set<String>();
            set<String> recordNodes = new set<String>();
            system.debug('+++++++++++++++++++usernodes'+nodes_string.remove('DIF_').split(';'));
            userNodes.addAll(nodes_string.remove('DIF_').split(';'));
            system.debug('+++++++++++++++++++usernodes'+userNodes);
           // string theAgency ='' +raw_recordMAP.get('codiceAgenzia');
            string theAgency =JSONUtility.getField(raw_record,'codiceAgenzia').get(0);
            theAgency=theAgency.trim();
            system.debug('+++++theAgency'+theAgency);
            system.debug('+++thecheck'+userNodes.contains(theAgency)  );
            
            if (userNodes.contains(theAgency)){
                //the user is profiled for the agency node of the current record
                return true;
            }
           // system.debug('+++++codiceSubAgenzia'+raw_recordMAP.get('codiceSubAgenzia'));
            list<string> nodes = new list<String>();

           //nodes = getNodesList(raw_recordMAP);
           nodes = getNodesList(raw_record);
            
            
            //list<string> nodes = (list<String>)raw_recordMAP.get('codiceSubAgenzia');
            system.debug('++++++nodes'+nodes);
            if (nodes!=null) {
                for(string thisnode: nodes ) {
                    system.debug('+++++thisnode'+thisnode);
                    if (userNodes.contains(thisnode)){
                        recordNodes.add(thisnode);
                        return true;
                    }
                }
            } else {//no subnodes specified
                return false;
            }
            system.debug('++++++CIFrecordNodes'+recordNodes);
            return false;
        }   
    }
    //given a string-obj map obtained from JSON casting it returns the nodes list with agency code and subagency nodes
    public list<string> getNodesList(Object theObject) {
            List<Object> nodesObj = new List<Object>();
            set<string> nodes = new set<String>();

            try {//shoulde have one or more records
               // List<Object> temp =(List<Object>)ObjMap.get('codiceSubAgenzia');
                // List<Object> temp = JSONUtility.getField(theObject,'codiceSubAgenzia');//old and dismissed method
                // nodesObj.addAll(temp);
                List<String> temp = JSONUtility.getFieldList(JSON.serialize(theObject),'codiceSubAgenzia');//new version
                nodes.addAll(temp);
                system.debug('++++temp'+temp);
                system.debug('+++nodes'+nodes);
            } catch (exception e) {
                Errors.add(new ApplicationLogHelper.ErrorWrapper(e.getMessage(), e.getStackTraceString()));
                
              //  Object temp =(Object)ObjMap.get('codiceSubAgenzia');
              //  nodesObj.add(temp);
            }
            
            //refers to old version where obj were handled
            // for (Object thisnodeObj: nodesObj) {
                // if (thisnodeObj!=null){
                    // system.debug('+++++thisnodeOnj'+thisnodeObj);
                    // string thisnode = thisnodeObj+'';
                    // nodes.add(thisnode);
                // }
            // }
            List<Node__c> nodesParentList  = [SELECT Node_unique_code__c,Parent_node_unique_code__c FROM Node__c WHERE  Node_unique_code__c in : nodes and  Node_level__c >=9 order by Node_unique_code__c  ASC]; // NOPMD  Fix CRUD violation
            for (Node__c thisnodesList: nodesParentList) {
                if (thisnodesList!=null){
                    system.debug('+++++thisnodesList'+thisnodesList);        
                    nodes.add(thisnodesList.Parent_node_unique_code__c);
                }
            }
            string agcode = JSONUtility.getField(theObject,'codiceAgenzia').get(0);
          //  string agcode = ''+ObjMap.get('codiceAgenzia');
            nodes.add(agcode);
            list<string> nodeslist= new list<String>(nodes);
            system.debug('++++++allnodes'+nodeslist);
            return nodeslist;
                
    }

        /* not necessary as the request is sorted out by the Engine

    public string padSingleNode(string singleNode) {
        if (singleNode.length()>12) {
            return ''; //something went wrong, the node should not be longer than 12 characters
        } else if (singleNode.length()>6) {//this should be the case of a sub node 5(subnode) + AgencyNode (4?)
            string subnode = '0'+singleNode.right(5);
            string AgencyNode = singleNode.removeEnd(singleNode.right(5));
            while (AgencyNode.length()<6) {
                AgencyNode='0'+AgencyNode;
            }
            system.debug('++++++++++subnode'+subnode);
            system.debug('++++++++++AgencyNode'+AgencyNode);
            return AgencyNode+subnode;
            
        } else {//should be an agency node
            while (singleNode.length()<6) {
                singleNode='0'+singleNode;
            }
            system.debug('+++++inputNodePadded'+singleNode);
            return singleNode;
        }
    }
    
    public string PadUserCurrentNodes(string UserCurrentSetup) {
        /*
        EXAMPLE OF INPUT STRING
        /apex/UserCurrentSetup?AOL_profile=005014;TemplateAOL;funzionalitàAOL;flag&VOL_profile=005014;TemplateVOL;funzionalitàVOL;flag&REOL_profile=005014;TemplateREOL;funzionalitàREOL;flag&CIF_profile=005014;TemplateCIF;funzionalitàCIF;flag&
        The nodes should be formatted as follow
        AGENCY NODE length <= 6;
        SUB-NODE length 5 subnode
        *//*
        if (String.isempty(UserCurrentSetup)){
            return '';
        } else {
            String inputInfo = UserCurrentSetup.remove('/apex/UserCurrentSetup?');
            system.debug('+++++inputInfo'+inputInfo);
            
            List<String> EXT_Profiles= inputInfo.split('&');
            String AOL_Profile = EXT_Profiles[0]; //picking the first
            system.debug('+++++AOL_Profile'+AOL_Profile);
    
            String inputNode = AOL_Profile.remove('AOL_profile=').split(';').get(0);
            system.debug('+++++inputNode'+inputNode);
            
            /*if (inputNode.length()>12) {
                return ''; //something went wrong, the node should not be longer than 12 characters
            } else if (inputNode.length()>6) {//this should be the case of a sub node 5(subnode) + AgencyNode (4?)
                string subnode = '0'+inputNode.right(5);
                string AgencyNode = inputNode.removeEnd(inputNode.right(5));
                while (AgencyNode.length()<6) {
                    AgencyNode='0'+AgencyNode;
                }
                system.debug('++++++++++subnode'+subnode);
                system.debug('++++++++++AgencyNode'+AgencyNode);
                return AgencyNode+subnode;
                
            } else {//should be an agency node
                while (inputNode.length()<6) {
                    inputNode='0'+inputNode;
                }
                system.debug('+++++inputNodePadded'+inputNode);
                return inputNode;
            }*//*
            return padSingleNode(inputNode);
        }    
    }*/
    
    
    
    
     public static string saveLocalObject (String x){
        system.debug('------ START: saveLocalObject ');
         
        
        if(x == 'A000Agent'){
            string result='';
            result='<S:Envelope xmlns:S="http://schemas.xmlsoap.org/soap/envelope/"><S:Body><ns2:salvaSoggettoCrmResponse xmlns:ns2="http://crm.service.rgi.it/">'+
                                    '<return>'+
                                        '<esitoElaborazione>A000</esitoElaborazione>'+
                                        '<totaleOccorrenze>1</totaleOccorrenze>'+
                                        '<soggettoEsistente>'+
                                            '<tipoSoggetto>FISICO</tipoSoggetto>'+
                                            '<soggettoEstero>false</soggettoEstero>'+
                                            '<soggettoFisico>'+
                                                '<codiceFiscale>RMGNLT87A41F205V</codiceFiscale>'+
                                                '<cognome>Romagnoli</cognome>'+
                                                ' <nome>Nicoletta</nome> '+
                                                '<sesso>F</sesso>'+
                                                '<localitaNascita>MILANO</localitaNascita>'+
                                                '<provinciaNascita>MI</provinciaNascita> '+
                                                '<dataNascita>1987-01-01</dataNascita>'+
                                            '</soggettoFisico> '+
                                            '<datiDocumento> '+
                                                '<tipoDoc>PortoArmi</tipoDoc> '+
                                                '<numeroDoc>P88668</numeroDoc> '+
                                                '<dataRilascio>2007-02-07</dataRilascio>'+
                                                '<dataScadenza>2015-05-30</dataScadenza>'+
                                                '<autoritaRilascio>Questura</autoritaRilascio>'+
                                                '<siglaNazione/> '+
                                                '<provincia>MI</provincia>'+
                                                '<localita>MILANO</localita>'+
                                            '</datiDocumento> '+
                                            '<datiIndirizzo>'+
                                                '<indirizzo>VIALE BLIGNY 22</indirizzo>'+
                                                '<localita>MILANO</localita>'+
                                                ' <provincia>MI</provincia> '+
                                                '<siglaNazione/>'+
                                                '<frazione/>'+
                                            '</datiIndirizzo>'+
                                            '<codiceProfessione>P00018</codiceProfessione>'+
                                           // '<codiceAgenzia>000828</codiceAgenzia>'+
                                            '<codiceAgenzia>004610</codiceAgenzia>'+
                                            ' <Ndg>Esempio NDG778</Ndg> '+
//                                          ' <Ndg>0010010000115466</Ndg> '+
                                            ' <timestampCif>2015-11-23T15:39:44+01:00</timestampCif> '+
                                        ' </soggettoEsistente>'+
                                        '<messaggioErrore>Elaborazione terminata correttamente, soggetto inserito</messaggioErrore>'+
                                    '</return>'+
                                '</ns2:salvaSoggettoCrmResponse>   </S:Body></S:Envelope> ';
            //result = '<S:Envelope xmlns:S="http://schemas.xmlsoap.org/soap/envelope/">   <S:Body>      <ns2:salvaSoggettoCrmResponse xmlns:ns2="http://crm.service.rgi.it/">         <return>            <esitoElaborazione>A001</esitoElaborazione>            <totaleOccorrenze>2</totaleOccorrenze>            <soggettoEsistente>               <tipoSoggetto>FISICO</tipoSoggetto>               <soggettoEstero>false</soggettoEstero>               <soggettoFisico>                  <codiceFiscale>MSNGMR74C02I690F</codiceFiscale>                  <cognome>LLAURADO</cognome>                  <nome>RICARD</nome>                  <sesso>M</sesso>                  <localitaNascita>SESTO SAN GIOVANNI</localitaNascita>                  <provinciaNascita>MI</provinciaNascita>                  <dataNascita>1974-03-02</dataNascita>               </soggettoFisico>               <datiDocumento>                  <tipoDoc>PortoArmi</tipoDoc>                  <numeroDoc>P88668</numeroDoc>                  <dataRilascio>2007-02-07</dataRilascio>                  <dataScadenza>2015-05-30</dataScadenza>                  <autoritaRilascio>Questura</autoritaRilascio>                  <siglaNazione/>                  <provincia>MI</provincia>                  <localita>MILANO</localita>               </datiDocumento>               <datiIndirizzo>                  <indirizzo>VIA SARDEGNA 80</indirizzo>                  <localita>VIA SARDEGNA 80</localita>                  <provincia>SESTO SAN GIOVANNI</provincia>                  <siglaNazione/>                  <frazione/>               </datiIndirizzo>               <codiceProfessione>P00018</codiceProfessione>               <codiceAgenzia>001001</codiceAgenzia>               <Ndg>0010010000115466</Ndg>               <timestampCif>2015-11-23</timestampCif>            </soggettoEsistente>            <soggettoEsistente>               <tipoSoggetto>FISICO</tipoSoggetto>               <soggettoEstero>false</soggettoEstero>               <soggettoFisico>                  <codiceFiscale>MSNGMR74C02I690F</codiceFiscale>                  <cognome>MASONI</cognome>                  <nome>GIANMARCO</nome>                  <sesso>M</sesso>                  <localitaNascita>SESTO SAN GIOVANNI</localitaNascita>                  <provinciaNascita>MI</provinciaNascita>                  <dataNascita>1970-03-02</dataNascita>               </soggettoFisico>               <datiIndirizzo>                  <indirizzo>SAN GREGORIO</indirizzo>                  <localita>SAN GREGORIO</localita>                  <provincia>MILANO</provincia>                  <siglaNazione/>                  <frazione/>               </datiIndirizzo>               <codiceProfessione>P00019</codiceProfessione>               <codiceAgenzia>001001</codiceAgenzia>               <codiceSubAgenzia>001001000001</codiceSubAgenzia>               <codiceSubAgenzia>001001000005</codiceSubAgenzia>               <codiceSubAgenzia>001001000007</codiceSubAgenzia>               <Ndg>0010010000111492</Ndg>               <timestampCif>2015-04-01</timestampCif>            </soggettoEsistente>            <messaggioErrore>Elaborazione terminata correttamente, soggetto non inserito in quanto già presente</messaggioErrore>         </return>      </ns2:salvaSoggettoCrmResponse>   </S:Body></S:Envelope>';
           result=result.normalizespace();
            return result;
        }
        else if (x == 'debug') {
            string result=''            
                             +'<?xml version="1.0" encoding="UTF-8"?>'
                             +'<S:Envelope xmlns:S="http://schemas.xmlsoap.org/soap/envelope/">'
                             +'    <S:Body>'
                             +'        <ns2:salvaSoggettoCrmResponse xmlns:ns2="http://crm.service.rgi.it/">'
                             +'            <return>'
                             +'                <esitoElaborazione>A001</esitoElaborazione>'
                             +'                <totaleOccorrenze>1</totaleOccorrenze>'
                             +'                <soggettoEsistente>'
                             +'                    <codiceAgenzia>008011 </codiceAgenzia>'
                             +'                    <codiceSubAgenzia>008011000100</codiceSubAgenzia>'
                             +'                    <codiceSubAgenzia>008011000230</codiceSubAgenzia>'
                             +'                    <codiceSubAgenzia>000828</codiceSubAgenzia>'
                             +'                    <tipoSoggetto>FISICO</tipoSoggetto>'
                             +'                    <codiceProfessione>P00018</codiceProfessione>'
                             +'                    <soggettoEstero>false</soggettoEstero>'
                             +'                    <soggettoFisico>'
                             +'                        <codiceFiscale>SLLNDR86A03D086U</codiceFiscale>'
                             +'                        <cognome>SAULLO </cognome>'
                             +'                        <nome>ANDREA </nome>'
                             +'                        <sesso>M</sesso>'
                             +'                        <localitaNascita>COSENZA</localitaNascita>'
                             +'                        <provinciaNascita>CS </provinciaNascita>'
                             +'                        <dataNascita>1986-01-03</dataNascita>'
                             +'                    </soggettoFisico>'
                             +'                    <datiDocumento>'
                             +'                        <tipoDoc>Patente</tipoDoc>'
                             +'                        <numeroDoc>U1J023057B</numeroDoc>'
                             +'                        <dataRilascio>2015-03-17</dataRilascio>'
                             +'                        <dataScadenza>2026-01-03</dataScadenza>'
                             +'                        <autoritaRilascio>Prefettura</autoritaRilascio>'
                             +'                        <siglaNazione>ITA</siglaNazione>'
                             +'                        <provincia>CS</provincia>'
                             +'                        <localita>COSENZA</localita>'
                             +'                    </datiDocumento>'
                             +'                    <datiIndirizzo>'
                             +'                        <indirizzo>IEGLIARELLA 9</indirizzo>'
                             +'                        <localita>MONTALTO UFFUGO</localita>'
                             +'                        <frazione></frazione>'
                             +'                        <provincia>CS </provincia>'
                             +'                        <siglaNazione>ITA</siglaNazione>'
                             +'                    </datiIndirizzo>'
                             +'                    <Ndg>0080110000007195</Ndg>'
                             +'                    <timestampCif>2016-05-11T10:55:32+02:00</timestampCif>'
                             +'                </soggettoEsistente>'
                             +'                <messaggioErrore>Elaborazione terminata correttamente, soggetto non inserito in quanto già presente</messaggioErrore>'
                             +'            </return>'
                             +'        </ns2:salvaSoggettoCrmResponse>'
                             +'    </S:Body>'
                             +'</S:Envelope>';
            result=result.normalizespace();
            return result;
        }
        
        else if(x == 'A000SubAgent'){
            string result='';
            result='<S:Envelope xmlns:S="http://schemas.xmlsoap.org/soap/envelope/"><S:Body><ns2:salvaSoggettoCrmResponse xmlns:ns2="http://crm.service.rgi.it/">'+
                                    '<return>'+
                                        '<esitoElaborazione>A000</esitoElaborazione>'+
                                        '<totaleOccorrenze>1</totaleOccorrenze>'+
                                        '<soggettoEsistente>'+
                                            '<tipoSoggetto>FISICO</tipoSoggetto>'+
                                            '<soggettoEstero>false</soggettoEstero>'+
                                            '<soggettoFisico>'+
                                                '<codiceFiscale>BROLCA74C02I690F</codiceFiscale>'+
                                                '<cognome>BIRO US-0204</cognome>'+
                                                ' <nome>LUCA</nome> '+
                                                '<sesso>M</sesso>'+
                                                '<localitaNascita>SESTO SAN GIOVANNI</localitaNascita>'+
                                                '<provinciaNascita>MI</provinciaNascita> '+
                                                '<dataNascita>1974-03-02</dataNascita>'+
                                            '</soggettoFisico> '+
                                            '<datiDocumento> '+
                                                '<tipoDoc>PortoArmi</tipoDoc> '+
                                                '<numeroDoc>P88668</numeroDoc> '+
                                                '<dataRilascio>2007-02-07</dataRilascio>'+
                                                '<dataScadenza>2015-05-30</dataScadenza>'+
                                                '<autoritaRilascio>Questura</autoritaRilascio>'+
                                                '<siglaNazione/> '+
                                                '<provincia>MI</provincia>'+
                                                '<localita>MILANO</localita>'+
                                            '</datiDocumento> '+
                                            '<datiIndirizzo>'+
                                                '<indirizzo>VIA SARDEGNA 80</indirizzo>'+
                                                '<localita>SESTO SAN GIOVANNI</localita>'+
                                                ' <provincia>MI</provincia> '+
                                                '<siglaNazione/>'+
                                                '<frazione/>'+
                                            '</datiIndirizzo>'+
                                            '<codiceProfessione>P00018</codiceProfessione>'+
                                            '<codiceAgenzia>000828</codiceAgenzia>'+
                                            '<codiceSubAgenzia>000828000028</codiceSubAgenzia>'+
 //                                           '<codiceAgenzia>004610</codiceAgenzia>'+
                                            ' <Ndg>0010010000115466</Ndg> '+
                                            ' <timestampCif>2015-11-23T15:39:44+01:00</timestampCif> '+
                                        ' </soggettoEsistente>'+
                                        '<messaggioErrore>Elaborazione terminata correttamente, soggetto inserito</messaggioErrore>'+
                                    '</return>'+
                                '</ns2:salvaSoggettoCrmResponse>   </S:Body></S:Envelope> ';
            //result = '<S:Envelope xmlns:S="http://schemas.xmlsoap.org/soap/envelope/">   <S:Body>      <ns2:salvaSoggettoCrmResponse xmlns:ns2="http://crm.service.rgi.it/">         <return>            <esitoElaborazione>A001</esitoElaborazione>            <totaleOccorrenze>2</totaleOccorrenze>            <soggettoEsistente>               <tipoSoggetto>FISICO</tipoSoggetto>               <soggettoEstero>false</soggettoEstero>               <soggettoFisico>                  <codiceFiscale>MSNGMR74C02I690F</codiceFiscale>                  <cognome>LLAURADO</cognome>                  <nome>RICARD</nome>                  <sesso>M</sesso>                  <localitaNascita>SESTO SAN GIOVANNI</localitaNascita>                  <provinciaNascita>MI</provinciaNascita>                  <dataNascita>1974-03-02</dataNascita>               </soggettoFisico>               <datiDocumento>                  <tipoDoc>PortoArmi</tipoDoc>                  <numeroDoc>P88668</numeroDoc>                  <dataRilascio>2007-02-07</dataRilascio>                  <dataScadenza>2015-05-30</dataScadenza>                  <autoritaRilascio>Questura</autoritaRilascio>                  <siglaNazione/>                  <provincia>MI</provincia>                  <localita>MILANO</localita>               </datiDocumento>               <datiIndirizzo>                  <indirizzo>VIA SARDEGNA 80</indirizzo>                  <localita>VIA SARDEGNA 80</localita>                  <provincia>SESTO SAN GIOVANNI</provincia>                  <siglaNazione/>                  <frazione/>               </datiIndirizzo>               <codiceProfessione>P00018</codiceProfessione>               <codiceAgenzia>001001</codiceAgenzia>               <Ndg>0010010000115466</Ndg>               <timestampCif>2015-11-23</timestampCif>            </soggettoEsistente>            <soggettoEsistente>               <tipoSoggetto>FISICO</tipoSoggetto>               <soggettoEstero>false</soggettoEstero>               <soggettoFisico>                  <codiceFiscale>MSNGMR74C02I690F</codiceFiscale>                  <cognome>MASONI</cognome>                  <nome>GIANMARCO</nome>                  <sesso>M</sesso>                  <localitaNascita>SESTO SAN GIOVANNI</localitaNascita>                  <provinciaNascita>MI</provinciaNascita>                  <dataNascita>1970-03-02</dataNascita>               </soggettoFisico>               <datiIndirizzo>                  <indirizzo>SAN GREGORIO</indirizzo>                  <localita>SAN GREGORIO</localita>                  <provincia>MILANO</provincia>                  <siglaNazione/>                  <frazione/>               </datiIndirizzo>               <codiceProfessione>P00019</codiceProfessione>               <codiceAgenzia>001001</codiceAgenzia>               <codiceSubAgenzia>001001000001</codiceSubAgenzia>               <codiceSubAgenzia>001001000005</codiceSubAgenzia>               <codiceSubAgenzia>001001000007</codiceSubAgenzia>               <Ndg>0010010000111492</Ndg>               <timestampCif>2015-04-01</timestampCif>            </soggettoEsistente>            <messaggioErrore>Elaborazione terminata correttamente, soggetto non inserito in quanto già presente</messaggioErrore>         </return>      </ns2:salvaSoggettoCrmResponse>   </S:Body></S:Envelope>';
           result=result.normalizespace();
            return result;
        }

        else if(x == 'A001'){
                        string result='';
            result='<S:Envelope xmlns:S="http://schemas.xmlsoap.org/soap/envelope/"><S:Body><ns2:salvaSoggettoCrmResponse xmlns:ns2="http://crm.service.rgi.it/">'+
                                    '<return>'+
                                        '<esitoElaborazione>A001</esitoElaborazione>'+
                                        '<totaleOccorrenze>4</totaleOccorrenze>'+
                                        '<soggettoEsistente>'+
                                            '<tipoSoggetto>FISICO</tipoSoggetto>'+
                                            '<soggettoEstero>false</soggettoEstero>'+
                                            '<soggettoFisico>'+
                                                '<codiceFiscale>A123456789012345</codiceFiscale>'+
                                                '<cognome>SODINI</cognome>'+
                                                '<nome>SANDRO</nome>'+
                                                '<sesso>M</sesso>'+
                                                '<localitaNascita>TORINO</localitaNascita>'+
                                                '<provinciaNascita>TO</provinciaNascita> '+
                                                '<dataNascita>1987-01-04T00:00:00+01:00</dataNascita>'+
                                            '</soggettoFisico> '+
                                            '<datiDocumento> '+
                                                '<tipoDoc>PortoArmi</tipoDoc> '+
                                                '<numeroDoc>P88668</numeroDoc> '+
                                                '<dataRilascio>2007-02-07</dataRilascio>'+
                                                '<dataScadenza>2015-05-30</dataScadenza>'+
                                                '<autoritaRilascio>Questura</autoritaRilascio>'+
                                                '<siglaNazione>ITA</siglaNazione>'+
                                                '<provincia>MI</provincia>'+
                                                '<localita>MILANO</localita>'+
                                            '</datiDocumento> '+
                                            '<datiIndirizzo>'+
                                                '<indirizzo>VIA GARIBALDI 80</indirizzo>'+
                                                '<localita>LAMBRATE</localita>'+
                                                ' <provincia>MI</provincia> '+
                                                '<siglaNazione>ITA</siglaNazione>'+
                                                '<frazione/>'+
                                            '</datiIndirizzo>'+
                                            '<codiceProfessione>41O0011</codiceProfessione>'+
                                            '<codiceAgenzia>004610</codiceAgenzia>'+
                                            //'<codiceAgenzia>000828</codiceAgenzia>'+
                                            //'<codiceSubAgenzia>000828000028</codiceSubAgenzia>'+
                                            //'<codiceSubAgenzia>000828000029</codiceSubAgenzia>'+
                                           // '<codiceSubAgenzia>004610000030</codiceSubAgenzia>'+
                                           // ' <Ndg>0046100000000137</Ndg> '+
                                            '<Ndg>0008280000000001</Ndg>'+
                                            ' <timestampCif>2015-11-23T15:39:44+01:00</timestampCif> '+
                                        ' </soggettoEsistente>'+
                                        '<soggettoEsistente>'+
                                            '<tipoSoggetto>FISICO</tipoSoggetto>'+
                                            '<soggettoEstero>false</soggettoEstero>'+
                                            '<soggettoFisico>'+
                                                '<codiceFiscale>B123456789012345</codiceFiscale>'+
                                                '<cognome>Bastoni</cognome>'+
                                                '<nome>Luca</nome>'+
                                                '<sesso>M</sesso>'+
                                                '<localitaNascita>Treviglio</localitaNascita>'+
                                                '<provinciaNascita>BG</provinciaNascita> '+
                                                '<dataNascita>1993-11-09T00:00:00+01:00</dataNascita>'+
                                            '</soggettoFisico> '+
                                            '<datiDocumento> '+
                                                '<tipoDoc>PortoArmi</tipoDoc> '+
                                                '<numeroDoc>P88668</numeroDoc> '+
                                                '<dataRilascio>2007-02-07</dataRilascio>'+
                                                '<dataScadenza>2015-05-30</dataScadenza>'+
                                                '<autoritaRilascio>Questura</autoritaRilascio>'+
                                                '<siglaNazione>ITA</siglaNazione>'+
                                                '<provincia>MI</provincia>'+
                                                '<localita>MILANO</localita>'+
                                            '</datiDocumento> '+
                                            '<datiIndirizzo>'+
                                                '<indirizzo>via Aldo Moro</indirizzo>'+
                                                '<localita>Linate</localita>'+
                                                ' <provincia>MI</provincia> '+
                                                '<siglaNazione>ITA</siglaNazione>'+
                                                '<frazione/>'+
                                            '</datiIndirizzo>'+
                                            '<codiceProfessione>12V0185</codiceProfessione>'+
                                            '<codiceAgenzia>000828</codiceAgenzia>'+
                                            //'<codiceAgenzia>004610</codiceAgenzia>'+
                                            '<codiceSubAgenzia>000828000028</codiceSubAgenzia>'+
                                            //'<codiceSubAgenzia>004610000030</codiceSubAgenzia>'+
                                            ' <Ndg>Esempio NDG2</Ndg> '+
                                            ' <timestampCif>2015-11-23T15:39:44+01:00</timestampCif> '+
                                        ' </soggettoEsistente>'+
                                        '<soggettoEsistente>'+
                                            '<tipoSoggetto>FISICO</tipoSoggetto>'+
                                            '<soggettoEstero>false</soggettoEstero>'+
                                            '<soggettoFisico>'+
                                                '<codiceFiscale>C123456789012345</codiceFiscale>'+
                                                '<cognome>Barbieri</cognome>'+
                                                '<nome>Antonino</nome>'+
                                                '<sesso>M</sesso>'+
                                                '<localitaNascita>Napoli</localitaNascita>'+
                                                '<provinciaNascita>NA</provinciaNascita> '+
                                                '<dataNascita>1970-03-04T00:00:00+01:00</dataNascita>'+
                                            '</soggettoFisico> '+
                                            '<datiDocumento> '+
                                                '<tipoDoc>PortoArmi</tipoDoc> '+
                                                '<numeroDoc>P88668</numeroDoc> '+
                                                '<dataRilascio>2007-02-07</dataRilascio>'+
                                                '<dataScadenza>2015-05-30</dataScadenza>'+
                                                '<autoritaRilascio>Questura</autoritaRilascio>'+
                                                '<siglaNazione>ITA</siglaNazione>'+
                                                '<provincia>MI</provincia>'+
                                                '<localita>MILANO</localita>'+
                                            '</datiDocumento> '+
                                            '<datiIndirizzo>'+
                                                '<indirizzo>via Mazzini</indirizzo>'+
                                                '<localita>Seriate</localita>'+
                                                ' <provincia>MI</provincia> '+
                                                '<siglaNazione>ITA</siglaNazione>'+
                                                '<frazione/>'+
                                            '</datiIndirizzo>'+
                                            '<codiceProfessione>21V0015</codiceProfessione>'+
                                           // '<codiceAgenzia>004610</codiceAgenzia>'+
                                            '<codiceAgenzia>000828</codiceAgenzia>'+
                                            //'<codiceSubAgenzia>004610000031</codiceSubAgenzia>'+
                                            '<codiceSubAgenzia>000828000029</codiceSubAgenzia>'+
                                            ' <Ndg>Esempio NDG3</Ndg> '+
                                            ' <timestampCif>2015-11-23T15:39:44+01:00</timestampCif> '+
                                        ' </soggettoEsistente>'+
                                        '<soggettoEsistente>'+
                                            '<tipoSoggetto>GIURIDICO</tipoSoggetto>'+
                                            '<soggettoEstero>false</soggettoEstero>'+
                                            '<soggettoGiuridico>'+
                                                '<partitaIva>ESPARTITAIV</partitaIva>'+
                                                '<denominazione>es_denominazione</denominazione>'+
                                            '</soggettoGiuridico> '+
                                            '<datiDocumento> '+
                                                '<tipoDoc>PortoArmi</tipoDoc> '+
                                                '<numeroDoc>P88668</numeroDoc> '+
                                                '<dataRilascio>2007-02-07</dataRilascio>'+
                                                '<dataScadenza>2015-05-30</dataScadenza>'+
                                                '<autoritaRilascio>Questura</autoritaRilascio>'+
                                                '<siglaNazione>ITA</siglaNazione>'+
                                                '<provincia>MI</provincia>'+
                                                '<localita>MILANO</localita>'+
                                            '</datiDocumento> '+
                                            '<datiIndirizzo>'+
                                                '<indirizzo>via Mazzini</indirizzo>'+
                                                '<localita>Seriate</localita>'+
                                                ' <provincia>MI</provincia> '+
                                                '<siglaNazione>ITA</siglaNazione>'+
                                                '<frazione/>'+
                                            '</datiIndirizzo>'+
                                            '<codiceProfessione>21V0015</codiceProfessione>'+
                                          //  '<codiceAgenzia>004610</codiceAgenzia>'+
                                            '<codiceAgenzia>000828</codiceAgenzia>'+
                                           // '<codiceSubAgenzia>004610000031</codiceSubAgenzia>'+
                                            '<codiceSubAgenzia>000828000028</codiceSubAgenzia>'+
                                            ' <Ndg>0046100000999988</Ndg> '+
                                            ' <timestampCif>2015-11-23T15:39:44+01:00</timestampCif> '+
                                        ' </soggettoEsistente>'+                                        
                                        '<messaggioErrore>Elaborazione terminata correttamente, soggetto non inserito in quanto già presente</messaggioErrore>'+
                                    '</return>'+
                                '</ns2:salvaSoggettoCrmResponse>   </S:Body></S:Envelope> ';
            //result = '<S:Envelope xmlns:S="http://schemas.xmlsoap.org/soap/envelope/">   <S:Body>      <ns2:salvaSoggettoCrmResponse xmlns:ns2="http://crm.service.rgi.it/">         <return>            <esitoElaborazione>A001</esitoElaborazione>            <totaleOccorrenze>2</totaleOccorrenze>            <soggettoEsistente>               <tipoSoggetto>FISICO</tipoSoggetto>               <soggettoEstero>false</soggettoEstero>               <soggettoFisico>                  <codiceFiscale>MSNGMR74C02I690F</codiceFiscale>                  <cognome>LLAURADO</cognome>                  <nome>RICARD</nome>                  <sesso>M</sesso>                  <localitaNascita>SESTO SAN GIOVANNI</localitaNascita>                  <provinciaNascita>MI</provinciaNascita>                  <dataNascita>1974-03-02</dataNascita>               </soggettoFisico>               <datiDocumento>                  <tipoDoc>PortoArmi</tipoDoc>                  <numeroDoc>P88668</numeroDoc>                  <dataRilascio>2007-02-07</dataRilascio>                  <dataScadenza>2015-05-30</dataScadenza>                  <autoritaRilascio>Questura</autoritaRilascio>                  <siglaNazione/>                  <provincia>MI</provincia>                  <localita>MILANO</localita>               </datiDocumento>               <datiIndirizzo>                  <indirizzo>VIA SARDEGNA 80</indirizzo>                  <localita>VIA SARDEGNA 80</localita>                  <provincia>SESTO SAN GIOVANNI</provincia>                  <siglaNazione/>                  <frazione/>               </datiIndirizzo>               <codiceProfessione>P00018</codiceProfessione>               <codiceAgenzia>001001</codiceAgenzia>               <Ndg>0010010000115466</Ndg>               <timestampCif>2015-11-23</timestampCif>            </soggettoEsistente>            <soggettoEsistente>               <tipoSoggetto>FISICO</tipoSoggetto>               <soggettoEstero>false</soggettoEstero>               <soggettoFisico>                  <codiceFiscale>MSNGMR74C02I690F</codiceFiscale>                  <cognome>MASONI</cognome>                  <nome>GIANMARCO</nome>                  <sesso>M</sesso>                  <localitaNascita>SESTO SAN GIOVANNI</localitaNascita>                  <provinciaNascita>MI</provinciaNascita>                  <dataNascita>1970-03-02</dataNascita>               </soggettoFisico>               <datiIndirizzo>                  <indirizzo>SAN GREGORIO</indirizzo>                  <localita>SAN GREGORIO</localita>                  <provincia>MILANO</provincia>                  <siglaNazione/>                  <frazione/>               </datiIndirizzo>               <codiceProfessione>P00019</codiceProfessione>               <codiceAgenzia>001001</codiceAgenzia>               <codiceSubAgenzia>001001000001</codiceSubAgenzia>               <codiceSubAgenzia>001001000005</codiceSubAgenzia>               <codiceSubAgenzia>001001000007</codiceSubAgenzia>               <Ndg>0010010000111492</Ndg>               <timestampCif>2015-04-01</timestampCif>            </soggettoEsistente>            <messaggioErrore>Elaborazione terminata correttamente, soggetto non inserito in quanto già presente</messaggioErrore>         </return>      </ns2:salvaSoggettoCrmResponse>   </S:Body></S:Envelope>';
           result=result.normalizespace();
            return result;
        }
        else if(x=='A001Single'){
            string result='';
            result='<S:Envelope xmlns:S="http://schemas.xmlsoap.org/soap/envelope/"><S:Body><ns2:salvaSoggettoCrmResponse xmlns:ns2="http://crm.service.rgi.it/">'+
                                    '<return>'+
                                        '<esitoElaborazione>A001</esitoElaborazione>'+
                                        '<totaleOccorrenze>1</totaleOccorrenze>'+
                                        '<soggettoEsistente>'+
                                            '<tipoSoggetto>FISICO</tipoSoggetto>'+
                                            '<soggettoEstero>false</soggettoEstero>'+
                                            '<soggettoFisico>'+
                                                '<codiceFiscale>A123456789012345</codiceFiscale>'+
                                                '<cognome>Carta</cognome>'+
                                                '<nome>Tania</nome>'+
                                                '<sesso>F</sesso>'+
                                                '<localitaNascita>Milano</localitaNascita>'+
                                                '<provinciaNascita>MI</provinciaNascita> '+
                                                '<dataNascita>1987-01-04T00:00:00+01:00</dataNascita>'+
                                            '</soggettoFisico> '+
                                            '<datiDocumento> '+
                                                '<tipoDoc>PortoArmi</tipoDoc> '+
                                                '<numeroDoc>P88668</numeroDoc> '+
                                                '<dataRilascio>2007-02-07</dataRilascio>'+
                                                '<dataScadenza>2015-05-30</dataScadenza>'+
                                                '<autoritaRilascio>Questura</autoritaRilascio>'+
                                                '<siglaNazione>ITA</siglaNazione>'+
                                                '<provincia>MI</provincia>'+
                                                '<localita>MILANO</localita>'+
                                            '</datiDocumento> '+
                                            '<datiIndirizzo>'+
                                                '<indirizzo>VIA GARIBALDI 80</indirizzo>'+
                                                '<localita>LAMBRATE</localita>'+
                                                ' <provincia>MI</provincia> '+
                                                '<siglaNazione>ITA</siglaNazione>'+
                                                '<frazione/>'+
                                            '</datiIndirizzo>'+
                                            '<codiceProfessione>41O0011</codiceProfessione>'+
                                           // '<codiceAgenzia>004610</codiceAgenzia>'+
                                            '<codiceAgenzia>000828</codiceAgenzia>'+
                                           // '<codiceSubAgenzia>004610000021</codiceSubAgenzia>'+
                                           // '<codiceSubAgenzia>000828000028</codiceSubAgenzia>'+
                                            ' <Ndg>0046100000011111</Ndg> '+
                                            ' <timestampCif>2015-11-23T15:39:44+01:00</timestampCif> '+
                                        ' </soggettoEsistente>'+                                    
                                        '<messaggioErrore>Elaborazione terminata correttamente, soggetto non inserito in quanto già presente</messaggioErrore>'+
                                    '</return>'+
                                '</ns2:salvaSoggettoCrmResponse>   </S:Body></S:Envelope> ';
           result=result.normalizespace();
            return result;
        
        }
        else if(x=='A001SinglePG'){
            string result='';
            result='<S:Envelope xmlns:S="http://schemas.xmlsoap.org/soap/envelope/"><S:Body><ns2:salvaSoggettoCrmResponse xmlns:ns2="http://crm.service.rgi.it/">'+
                                    '<return>'+
                                        '<esitoElaborazione>A001</esitoElaborazione>'+
                                        '<totaleOccorrenze>1</totaleOccorrenze>'+
                                        '<soggettoEsistente>'+
                                            '<tipoSoggetto>GIURIDICO</tipoSoggetto>'+
                                            '<soggettoEstero>false</soggettoEstero>'+
                                            '<soggettoGiuridico>'+
                                                '<partitaIva>01234567890</partitaIva>'+
                                                '<denominazione>Berti</denominazione>'+
                                            '</soggettoGiuridico> '+
                                            '<datiDocumento> '+
                                                '<tipoDoc>PortoArmi</tipoDoc> '+
                                                '<numeroDoc>P88668</numeroDoc> '+
                                                '<dataRilascio>2007-02-07</dataRilascio>'+
                                                '<dataScadenza>2015-05-30</dataScadenza>'+
                                                '<autoritaRilascio>Questura</autoritaRilascio>'+
                                                '<siglaNazione>ITA</siglaNazione>'+
                                                '<provincia>MI</provincia>'+
                                                '<localita>MILANO</localita>'+
                                            '</datiDocumento> '+
                                            '<datiIndirizzo>'+
                                                '<indirizzo>VIA GARIBALDI 80</indirizzo>'+
                                                '<localita>LAMBRATE</localita>'+
                                                ' <provincia>MI</provincia> '+
                                                '<siglaNazione>ITA</siglaNazione>'+
                                                '<frazione/>'+
                                            '</datiIndirizzo>'+
                                            '<codiceProfessione>21V0015</codiceProfessione>'+
                                            '<codiceAgenzia>004610</codiceAgenzia>'+
                                          //  '<codiceAgenzia>000828</codiceAgenzia>'+
                                         //   '<codiceSubAgenzia>004610000030</codiceSubAgenzia>'+
                                         //   '<codiceSubAgenzia>000828000028</codiceSubAgenzia>'+
                                            ' <Ndg>0046100000000252</Ndg> '+
                                            ' <timestampCif>2015-11-23T15:39:44+01:00</timestampCif> '+
                                        ' </soggettoEsistente>'+                                    
                                        '<messaggioErrore>Elaborazione terminata correttamente, soggetto non inserito in quanto già presente</messaggioErrore>'+
                                    '</return>'+
                                '</ns2:salvaSoggettoCrmResponse>   </S:Body></S:Envelope> ';
                       result=result.normalizespace();
            return result;
        
        }
        else if(x=='A001SingleExisting'){
            string result='';
            result='<S:Envelope xmlns:S="http://schemas.xmlsoap.org/soap/envelope/"><S:Body><ns2:salvaSoggettoCrmResponse xmlns:ns2="http://crm.service.rgi.it/">'+
                                    '<return>'+
                                        '<esitoElaborazione>A001</esitoElaborazione>'+
                                        '<totaleOccorrenze>1</totaleOccorrenze>'+
                                        '<soggettoEsistente>'+
                                            '<tipoSoggetto>FISICO</tipoSoggetto>'+
                                            '<soggettoEstero>false</soggettoEstero>'+
                                            '<soggettoFisico>'+
                                                '<codiceFiscale>A123456789012345</codiceFiscale>'+
                                                '<cognome>Berti</cognome>'+
                                                '<nome>Piera</nome>'+
                                                '<sesso>F</sesso>'+
                                                '<localitaNascita>Milano</localitaNascita>'+
                                                '<provinciaNascita>MI</provinciaNascita> '+
                                                '<dataNascita>1987-01-04T00:00:00+01:00</dataNascita>'+
                                            '</soggettoFisico> '+
                                            '<datiDocumento> '+
                                                '<tipoDoc>PortoArmi</tipoDoc> '+
                                                '<numeroDoc>P88668</numeroDoc> '+
                                                '<dataRilascio>2007-02-07</dataRilascio>'+
                                                '<dataScadenza>2015-05-30</dataScadenza>'+
                                                '<autoritaRilascio>Questura</autoritaRilascio>'+
                                                '<siglaNazione>ITA</siglaNazione>'+
                                                '<provincia>MI</provincia>'+
                                                '<localita>MILANO</localita>'+
                                            '</datiDocumento> '+
                                            '<datiIndirizzo>'+
                                                '<indirizzo>VIA GARIBALDI 80</indirizzo>'+
                                                '<localita>LAMBRATE</localita>'+
                                                ' <provincia>MI</provincia> '+
                                                '<siglaNazione>ITA</siglaNazione>'+
                                                '<frazione/>'+
                                            '</datiIndirizzo>'+
                                            '<codiceProfessione>41O0011</codiceProfessione>'+
                                           // '<codiceAgenzia>004610</codiceAgenzia>'+
                                            '<codiceAgenzia>000828</codiceAgenzia>'+
                                          //  '<codiceSubAgenzia>004610000030</codiceSubAgenzia>'+
                                          //  '<codiceSubAgenzia>000828000028</codiceSubAgenzia>'+
                                            ' <Ndg>0046100000000252</Ndg> '+
                                            ' <timestampCif>2015-11-23T15:39:44+01:00</timestampCif> '+
                                        ' </soggettoEsistente>'+                                    
                                        '<messaggioErrore>Elaborazione terminata correttamente, soggetto non inserito in quanto già presente</messaggioErrore>'+
                                    '</return>'+
                                '</ns2:salvaSoggettoCrmResponse>   </S:Body></S:Envelope> ';
            //result = '<S:Envelope xmlns:S="http://schemas.xmlsoap.org/soap/envelope/">   <S:Body>      <ns2:salvaSoggettoCrmResponse xmlns:ns2="http://crm.service.rgi.it/">         <return>            <esitoElaborazione>A001</esitoElaborazione>            <totaleOccorrenze>2</totaleOccorrenze>            <soggettoEsistente>               <tipoSoggetto>FISICO</tipoSoggetto>               <soggettoEstero>false</soggettoEstero>               <soggettoFisico>                  <codiceFiscale>MSNGMR74C02I690F</codiceFiscale>                  <cognome>LLAURADO</cognome>                  <nome>RICARD</nome>                  <sesso>M</sesso>                  <localitaNascita>SESTO SAN GIOVANNI</localitaNascita>                  <provinciaNascita>MI</provinciaNascita>                  <dataNascita>1974-03-02</dataNascita>               </soggettoFisico>               <datiDocumento>                  <tipoDoc>PortoArmi</tipoDoc>                  <numeroDoc>P88668</numeroDoc>                  <dataRilascio>2007-02-07</dataRilascio>                  <dataScadenza>2015-05-30</dataScadenza>                  <autoritaRilascio>Questura</autoritaRilascio>                  <siglaNazione/>                  <provincia>MI</provincia>                  <localita>MILANO</localita>               </datiDocumento>               <datiIndirizzo>                  <indirizzo>VIA SARDEGNA 80</indirizzo>                  <localita>VIA SARDEGNA 80</localita>                  <provincia>SESTO SAN GIOVANNI</provincia>                  <siglaNazione/>                  <frazione/>               </datiIndirizzo>               <codiceProfessione>P00018</codiceProfessione>               <codiceAgenzia>001001</codiceAgenzia>               <Ndg>0010010000115466</Ndg>               <timestampCif>2015-11-23</timestampCif>            </soggettoEsistente>            <soggettoEsistente>               <tipoSoggetto>FISICO</tipoSoggetto>               <soggettoEstero>false</soggettoEstero>               <soggettoFisico>                  <codiceFiscale>MSNGMR74C02I690F</codiceFiscale>                  <cognome>MASONI</cognome>                  <nome>GIANMARCO</nome>                  <sesso>M</sesso>                  <localitaNascita>SESTO SAN GIOVANNI</localitaNascita>                  <provinciaNascita>MI</provinciaNascita>                  <dataNascita>1970-03-02</dataNascita>               </soggettoFisico>               <datiIndirizzo>                  <indirizzo>SAN GREGORIO</indirizzo>                  <localita>SAN GREGORIO</localita>                  <provincia>MILANO</provincia>                  <siglaNazione/>                  <frazione/>               </datiIndirizzo>               <codiceProfessione>P00019</codiceProfessione>               <codiceAgenzia>001001</codiceAgenzia>               <codiceSubAgenzia>001001000001</codiceSubAgenzia>               <codiceSubAgenzia>001001000005</codiceSubAgenzia>               <codiceSubAgenzia>001001000007</codiceSubAgenzia>               <Ndg>0010010000111492</Ndg>               <timestampCif>2015-04-01</timestampCif>            </soggettoEsistente>            <messaggioErrore>Elaborazione terminata correttamente, soggetto non inserito in quanto già presente</messaggioErrore>         </return>      </ns2:salvaSoggettoCrmResponse>   </S:Body></S:Envelope>';
           result=result.normalizespace();
            return result;
        
        }else if(x=='A001SingleImport'){
            system.debug('----- CASE: Elaborazione terminata correttamente, soggetto non inserito in quanto già presente');
            string result='';
            result='<S:Envelope xmlns:S="http://schemas.xmlsoap.org/soap/envelope/"><S:Body><ns2:salvaSoggettoCrmResponse xmlns:ns2="http://crm.service.rgi.it/">'+
                                    '<return>'+
                                        '<esitoElaborazione>A001</esitoElaborazione>'+
                                        '<totaleOccorrenze>1</totaleOccorrenze>'+
                                        '<soggettoEsistente>'+
                                            '<tipoSoggetto>FISICO</tipoSoggetto>'+
                                            '<soggettoEstero>false</soggettoEstero>'+
                                            '<soggettoFisico>'+
                                                '<codiceFiscale>C23456789012345</codiceFiscale>'+
                                                '<cognome>Barbieri</cognome>'+
                                                '<nome>Antonino</nome>'+
                                                '<sesso>M</sesso>'+
                                                '<localitaNascita>Napoli</localitaNascita>'+
                                                '<provinciaNascita>NA</provinciaNascita> '+
                                                '<dataNascita>1970-03-04T00:00:00+01:00</dataNascita>'+
                                            '</soggettoFisico> '+
                                            '<datiDocumento> '+
                                                '<tipoDoc>PortoArmi</tipoDoc> '+
                                                '<numeroDoc>P88668</numeroDoc> '+
                                                '<dataRilascio>2007-02-07</dataRilascio>'+
                                                '<dataScadenza>2015-05-30</dataScadenza>'+
                                                '<autoritaRilascio>Questura</autoritaRilascio>'+
                                                '<siglaNazione>ITA</siglaNazione>'+
                                                '<provincia>MI</provincia>'+
                                                '<localita>MILANO</localita>'+
                                            '</datiDocumento> '+
                                            '<datiIndirizzo>'+
                                                '<indirizzo>via Mazzini</indirizzo>'+
                                                '<localita>Seriate</localita>'+
                                                ' <provincia>MI</provincia> '+
                                                '<siglaNazione>ITA</siglaNazione>'+
                                                '<frazione/>'+
                                            '</datiIndirizzo>'+
                                            '<codiceProfessione>21V0015</codiceProfessione>'+
                                            '<codiceAgenzia>004610</codiceAgenzia>'+
                                           // '<codiceAgenzia>000828</codiceAgenzia>'+
                                           '<codiceSubAgenzia>004610000031</codiceSubAgenzia>'+
                                           // '<codiceSubAgenzia>000828000028</codiceSubAgenzia>'+
                                            ' <Ndg>Esempio NDG676</Ndg> '+
                                            ' <timestampCif>2015-11-23T15:39:44+01:00</timestampCif> '+
                                        ' </soggettoEsistente>'+                                    
                                        '<messaggioErrore>Elaborazione terminata correttamente, soggetto non inserito in quanto già presente</messaggioErrore>'+
                                    '</return>'+
                                '</ns2:salvaSoggettoCrmResponse>   </S:Body></S:Envelope> ';
            result=result.normalizespace();
            return result;
        }        
        else if(x == 'W103'){
            string result='';
            result='<S:Envelope xmlns:S="http://schemas.xmlsoap.org/soap/envelope/"><S:Body><ns2:salvaSoggettoCrmResponse xmlns:ns2="http://crm.service.rgi.it/">'+
                                    '<return>'+
                                        '<esitoElaborazione>W103</esitoElaborazione>'+
                                        '<totaleOccorrenze>0</totaleOccorrenze>'+                                
                                        '<messaggioErrore>Codice fiscale non congruente con dati soggetto</messaggioErrore>'+
                                    '</return>'+
                                '</ns2:salvaSoggettoCrmResponse>   </S:Body></S:Envelope> ';
           result=result.normalizespace();
            return result;
        }
        else if(x == 'E401'){
            string result='';
            result='<S:Envelope xmlns:S="http://schemas.xmlsoap.org/soap/envelope/"><S:Body><ns2:salvaSoggettoCrmResponse xmlns:ns2="http://crm.service.rgi.it/">'+
                                    '<return>'+
                                        '<esitoElaborazione>E401</esitoElaborazione>'+
                                        '<totaleOccorrenze>0</totaleOccorrenze>'+                                
                                        '<messaggioErrore>Errore generico</messaggioErrore>'+
                                    '</return>'+
                                '</ns2:salvaSoggettoCrmResponse>   </S:Body></S:Envelope> ';
           result=result.normalizespace();
           return result;
        }
        else if(x == 'E402'){
            system.debug('----- CASE: Impossibile normalizzare l\'indirizzo (servizio non disponibile)');
            string result='';
            result='<S:Envelope xmlns:S="http://schemas.xmlsoap.org/soap/envelope/"><S:Body><ns2:salvaSoggettoCrmResponse xmlns:ns2="http://crm.service.rgi.it/">'+
                                    '<return>'+
                                        '<esitoElaborazione>E402</esitoElaborazione>'+
                                        '<totaleOccorrenze>0</totaleOccorrenze>'+                                
                                        '<messaggioErrore>Impossibile normalizzare l\'indirizzo (servizio non disponibile)</messaggioErrore>'+
                                    '</return>'+
                                '</ns2:salvaSoggettoCrmResponse>   </S:Body></S:Envelope> ';
           result=result.normalizespace();
           return result;
        }
        else if(x == 'E403'){
            system.debug('----- CASE: Impossibile normalizzare l\'indirizzo (errore di normalizzazione) ');
            string result='';
            result='<S:Envelope xmlns:S="http://schemas.xmlsoap.org/soap/envelope/"><S:Body><ns2:salvaSoggettoCrmResponse xmlns:ns2="http://crm.service.rgi.it/">'+
                                    '<return>'+
                                        '<esitoElaborazione>E403</esitoElaborazione>'+
                                        '<totaleOccorrenze>0</totaleOccorrenze>'+                                
                                        '<messaggioErrore>Impossibile normalizzare l\'indirizzo (errore di normalizzazione) </messaggioErrore>'+
                                    '</return>'+
                                '</ns2:salvaSoggettoCrmResponse>   </S:Body></S:Envelope> ';
           result=result.normalizespace();
           return result;
        }
        else if(x == 'debug'){
            system.debug('----- CASE: for debug purpose');
            string result='';
            result='<?xml version="1.0" encoding="UTF-8"?><S:Envelope xmlns:S="http://schemas.xmlsoap.org/soap/envelope/"><S:Body><ns2:salvaSoggettoCrmResponse xmlns:ns2="http://crm.service.rgi.it/"><return><esitoElaborazione>A001</esitoElaborazione><totaleOccorrenze>1</totaleOccorrenze><soggettoEsistente><tipoSoggetto>FISICO</tipoSoggetto><soggettoEstero>false</soggettoEstero><soggettoFisico><codiceFiscale>RCCDLA93R45M059G</codiceFiscale><cognome>ROCCATO </cognome><nome>ADELE </nome><sesso>F</sesso><localitaNascita>VINCI</localitaNascita><provinciaNascita>FI </provinciaNascita><dataNascita>1993-10-05T00:00:00+01:00</dataNascita></soggettoFisico><datiDocumento><tipoDoc>CI</tipoDoc><numeroDoc>AX2450355</numeroDoc><dataRilascio>2015-12-23T00:00:00+01:00</dataRilascio><dataScadenza>2026-10-05T00:00:00+02:00</dataScadenza><autoritaRilascio>Comune</autoritaRilascio><siglaNazione>ITA</siglaNazione><provincia>FI</provincia><localita>VINCI</localita></datiDocumento><datiIndirizzo><indirizzo>FALTOGNANO</indirizzo><localita>VINCI</localita><provincia>FI </provincia><siglaNazione>ITA</siglaNazione><frazione></frazione></datiIndirizzo><codiceProfessione>P00011</codiceProfessione><codiceAgenzia>004206 </codiceAgenzia><Ndg>0042060000129106</Ndg><timestampCif>2016-03-15T15:05:59+01:00</timestampCif></soggettoEsistente><messaggioErrore>Elaborazione terminata correttamente, soggetto non inserito in quanto già presente</messaggioErrore></return></ns2:salvaSoggettoCrmResponse></S:Body></S:Envelope>';
           result=result.normalizespace();
           return result;
        }
        
        else {
            system.debug('----- Invalid input');
            return '';
        }
    system.debug('------ END: saveLocalObject ');
    return '';
    }
    public String checkProvince (String CodiceProvincia){
            Map<String,String> codificaProvince = new Map<String,string>();
            List<MappingProvince__c> myMappingprovince = SharingUtility.transferQuery('SELECT ProvinciaExternalKey__c,SFDCexpected__c from MappingProvince__c');
            for (MappingProvince__c thismapping : myMappingprovince) {
            
            codificaProvince.put(thismapping.ProvinciaExternalKey__c,thismapping.SFDCexpected__c);
            //system.debug('++++this.codificaProvince'+codificaProvince);
            
            }
    
            String nomeProvincia = codificaProvince.get (CodiceProvincia);

            return nomeProvincia;
    }    
    
}