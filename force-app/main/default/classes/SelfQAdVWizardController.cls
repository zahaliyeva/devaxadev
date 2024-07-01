/** 
 * @author	Reply
 * @date	01/04/2023 4xx
 * @description Class controller del LWC SelfQAdVWizard
 * 
 */
@SuppressWarnings('PMD.ApexCRUDViolation')
public without sharing class SelfQAdVWizardController extends RLY_Behaviour {
    
    private static final String RICHIEDENTE_ROLE = 'Richiedente';
    private static final String SOGGETTO_ROLE = 'Soggetto';
    private static final List<String> ACTION_STATUSES = new List<String>{'C5'};
    public static final String NOME_FILE_KYC = 'QAdV invalidato su richiesta dell\'operatore';

    /**
    * @author   reply
    * @description piccola descrizione della classe e forse il svilupo per quelle e fatta esempio -> IDCRM025
    */
    public class InitWrapper extends LghtResponse {
        /**
         * @description disabilita gli input sul wizard
         */
        @AuraEnabled
        public boolean disableInputs {get;set;}

        /**
         * @description verifica che sia stato chiamato auth0
         */
        @AuraEnabled
        public boolean integrationDone {get;set;}

        /**
         * @description Id del richiedente
         */
        @AuraEnabled
        public String richiedenteId {get;set;}

        /**
         * @description Id del recordType
         */
        @AuraEnabled
        public String recordTypeId {get;set;}

        /**
         * @description lista dei soggetti
         */
        @AuraEnabled
        public List<Map<String,Object>> subjects {get;set;}

        /**
         * @description costruttore
         */
        public InitWrapper(){
            this.subjects = new List<Map<String,Object>>();
        }
        
    }

    /**
    * @author   reply
    * @description classe usata come wrapper di input per il metodo updateDocumentAccount
    */
    public class UpdateDocumentAccountWrapper{

        /**
         * @description soggetto di partenza
         */
        @AuraEnabled
        public DocumentAccount__c subjectInput{get;set;}

        /**
         * @description Id del case
         */
        @AuraEnabled
        public String caseId{get;set;}

        /**
         * @description ruolo di partenza
         */
        @AuraEnabled
        public String RuoloInput{get;set;}

        /**
         * @description Id del richiedente o soggetto da aggiornare
         */
        @AuraEnabled
        public String richiedenteId{get;set;}

        
        /**
         * @description lista dei documenti
         */
        @AuraEnabled
        public List<selfQAdVWizardManageSubjectController.DocumentWrapper> documents{get;set;}

    }
    /**
    * @author   reply
    * @description piccola descrizione della classe e forse il svilupo per quelle e fatta esempio -> IDCRM025
    */
    private class DocumentStructureWrapper{
        public String AttachmentId;
        public String ContentDocumentId;
        public String ContentDocumentIdNew;
        public ContentVersion version;
        public DocumentChecklistItem__c doc;
    }
    
    /**
     * @description aggiorna il document checklist item per rimuovere l'icona di notifica
     * @param DocAccId 
     */
    @AuraEnabled
    public static void setRecordUpdatedByDocumentAccount(string DocAccId){
        
        List<DocumentChecklistItem__c> docList = [SELECT id, TECH_RecordUpdated__c FROM DocumentChecklistItem__c WHERE DocumentAccountId__c =: DocAccId WITH SECURITY_ENFORCED];

        for(DocumentChecklistItem__c doc : docList){
            doc.TECH_RecordUpdated__c = false;
        }

        update docList;

    }
    /**
     * @description aggiorna i campi necessari del case per farlo diventare una pratica documentale
     * @param CaseId 
     * @return  `boolean` true se la pratica si è aggiornata false altrimenti
     */
    @AuraEnabled
    public static boolean  setPraticaDocumentale(String CaseId){
        
        try{
            Case c = new Case(Id = caseId, Pratica_Documentale__c = true, UniqueCode__c = 'SFDC_PA_'+caseId, Origine_Pratica_Documentale__c = 'SFDC');
            update c;
            return true;
        }
        catch(Exception ex){
            return false;
        }

    }

    
    /**
     * @description inizializza il wizard
     * @param caseId 
     * @return  `InitWrapper` wrapper contenente tutte le info di init del wizard
     */
    @AuraEnabled
    public static InitWrapper init(String caseId){
        InitWrapper toRet = new InitWrapper();
        try {		
        
        Case c = [Select SelfQADV_PCC_NewCredentials__c, RecordTypeId, Origine_Pratica_Documentale__c from Case where id=: caseId WITH SECURITY_ENFORCED limit 1];
        
        
        toRet.integrationDone = String.isNotBlank(c.SelfQADV_PCC_NewCredentials__c) && c.SelfQADV_PCC_NewCredentials__c != 'ERRORE';
        toRet.disableInputs = String.isNotBlank(c.Origine_Pratica_Documentale__c) && c.Origine_Pratica_Documentale__c == 'WFCL';
        toRet.recordTypeId = c.RecordTypeId;
        List<DocumentAccount__c> subjects = [Select Id, (select TECH_RecordUpdated__c from Document_Checklist_Items__r), Role__c, CaseId__c, DelegateType__c, Delegate__c, FirstName__c, FiscalIdentifier__c, TOLABEL(SubjectType__c), SurnameCompanyName__c, TOLABEL(Survey_Type__c), UniqueCode__c, isActive__c, TECH_RequiredFieldsMissing__c, Digital_Link__c  from DocumentAccount__c where caseId__c =: caseId WITH SECURITY_ENFORCED order by isActive__c desc, createdDate];
        
        for(DocumentAccount__c da : subjects){
            if(da.Role__c.containsIgnoreCase(RICHIEDENTE_ROLE)){
                Map<String,Object> tempRichiedente = (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(da));
                toRet.richiedenteId = da.Id;
                if(da.TECH_RequiredFieldsMissing__c){
                    tempRichiedente.put('dynamicIcon', 'custom:custom53');
                }
            }
            if(da.Role__c.containsIgnoreCase(SOGGETTO_ROLE)){
                Map<String,Object> tempSubject = (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(da)); 
                if(da.Role__c.containsIgnoreCase(RICHIEDENTE_ROLE)){
                    if(da.TECH_RequiredFieldsMissing__c){
                    	tempSubject.put('dynamicIcon', 'custom:custom53');
                	}
                }
                if(da.Document_Checklist_Items__r != null){
                    for(DocumentChecklistItem__c dci : da.Document_Checklist_Items__r){
                        if(dci.TECH_RecordUpdated__c){
                            tempSubject.put('dynamicIcon', 'utility:announcement'); //aggiunge l'icona da visualizzare in tabella
                            break;
                        }
                    }
                    toRet.subjects.add(tempSubject);
                }

            }
            
        }

        if(!toRet.subjects.isEmpty()){
            toRet.isSuccess = true ;
        }

        } catch (Exception errorEx) {
            ApplicationLogHelper.ERROR('SelfQAdVWizardController', errorEx.getMessage(), errorEx.getStackTraceString());
            toRet.isSuccess = false ;
            toRet.errorMessage = 'Exception Error, controllare il ApplicationLogHelper SelfQAdVWizardController ora-'+System.now();   
        }
        return toRet;
    }

    /** 
    * @param	caseInput Case condiviso per il recordId del LWC chiamante
    * @return	risposta InitWrapper sul case andato OK 
    * @description metodo per creare il policyID nel formato richiesto per la integrazione con servizi DIH
    */
    @AuraEnabled
    public static InitWrapper UpdateCaseInfo(Case caseInput){
        InitWrapper toRet = new InitWrapper(); 
        try {
            String filterID = String.escapeSingleQuotes(caseInput.Id) ;
            String QUERY_START = 'Select id ';
            String QUERY_END = ' from Case where id = \''+filterID+'\''; 

            List<FormConfig__mdt> listFieldsToupdate = [select  Field__c from FormConfig__mdt where Form__c = 'wizard-qadv-case' WITH SYSTEM_MODE];
            for(FormConfig__mdt fieldTemp:listFieldsToupdate)
                QUERY_START += ','+fieldTemp.Field__c;

            String query = (QUERY_START + QUERY_END).escapeJava();
            //system.debug(System.LoggingLevel.INFO, 'case query ->'+query);
            Case CaseOnDataBase = Database.query(query);

            Map<String, Object> caseInputMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(caseInput));
            Map<String, Object> CaseOnDataBaseMAP = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(CaseOnDataBase));
            CaseOnDataBaseMAP.putAll(caseInputMap);//aggiorna tutti campi per MTD 
            caseInput = (Case) JSON.deserialize(JSON.serialize(CaseOnDataBaseMAP), Case.class);

            //forse spegnere i trigger case alla fine solo sono campi non ci sono logiche dopo sti campi 
            CaseHandler.RunTrigger = false; //-- OOOOCHIOOO se ci sono logiche devo togliere sta righa
            Database.SaveResult SR = Database.update(caseInput);

            if(SR.isSuccess()){
                toRet.isSuccess = true ;
                toRet.errorMessage = 'Pratica Documentale aggiornata OK';
            }else{
                toRet.isSuccess = false ;
                toRet.errorMessage = 'Errore nel aggiornamento del case'+sr.getErrors();
            }
        } catch (Exception errorEx) {
            ApplicationLogHelper.ERROR('SelfQAdVWizardController', errorEx.getMessage(), errorEx.getStackTraceString());
            toRet.isSuccess = false ;
            toRet.errorMessage = 'Exception Error, controllare il ApplicationLogHelper SelfQAdVWizardController ora-'+System.now();   
        }

        return toRet;
    }

    /**
     * @description aggiorna le info del document account (richiedente o soggetto)
     * @param param 
     * @return  `InitWrapper`
     */
    @AuraEnabled
    public static InitWrapper UpdateDocumentAccountInfo(UpdateDocumentAccountWrapper param){

        DocumentAccount__c subjectInput = param.subjectInput;

        String caseId = param.caseId;

        String RuoloInput = param.RuoloInput;

        String richiedenteId = param.richiedenteId;

        List<selfQAdVWizardManageSubjectController.DocumentWrapper> documents = param.documents;

        InitWrapper toRet = new InitWrapper();

        if(documents != null){
            for(selfQAdVWizardManageSubjectController.DocumentWrapper doc: documents){
                if(doc.callKyc != null && doc.callKyc){
                    //system.debug(doc);
                    if(String.isNotBlank(doc.document.Detica_Id__c)){
                        IE_FEQ_kyc_cancel.ResponseDto res = IE_FEQ_kyc_cancel.cancelKyc(doc.document.Detica_Id__c, 'A');
                        if(res.statusCode != 200){
                            toRet.isSuccess = false ;
                            toRet.errorMessage = 'S04 - Il QADV associato al soggetto non è stato annullato per un poblema tecnico. Riprovare l\'annullamento in un secondo momento';
                            return toRet;
                        }
                        else if (res.body != null && res.body.errorCode != 0){
                            toRet.isSuccess = false ;
                            toRet.errorMessage = 'S04 - Il QADV associato al soggetto non è stato annullato per un poblema tecnico. Riprovare l\'annullamento in un secondo momento';
                            return toRet;
                        }
                        else{
                            doc.document.Nome_File__c = NOME_FILE_KYC + '_' + doc.document.Nome_File__c;
                        }
                    }
                    else{
                        toRet.isSuccess = false ;
                        toRet.errorMessage = 'S04 - Il QADV associato al soggetto non è stato annullato per un poblema tecnico. Riprovare l\'annullamento in un secondo momento';
                        return toRet;
                    }
                }
            }
        }
        
       
            Boolean isInsert = subjectInput.id == null && String.isBlank(richiedenteId) ? true : false;

            if(isInsert && RuoloInput.equalsIgnoreCase(SelfQAdVWizardController.SOGGETTO_ROLE)){
                subjectInput.caseId__c = caseId ;
                
                insert subjectInput;
                toRet.isSuccess = true ;
                toRet.errorMessage = SelfQAdVWizardController.SOGGETTO_ROLE+' inserito OK';   
                toRet.richiedenteId = subjectInput.Id ;    
            }else if(isInsert && RuoloInput.equalsIgnoreCase(SelfQAdVWizardController.RICHIEDENTE_ROLE)){
                if(subjectInput.Role__c.containsIgnoreCase(SelfQAdVWizardController.SOGGETTO_ROLE)){
                    subjectInput.isActive__c = true;
                    subjectInput.TECH_RequiredFieldsMissing__c = true;
                }
                subjectInput.caseId__c = caseId ;
                
                insert subjectInput;
                toRet.isSuccess = true ;
                toRet.errorMessage =SelfQAdVWizardController.RICHIEDENTE_ROLE+ ' inserito OK';
                toRet.richiedenteId = subjectInput.Id ;
            }else if(String.isNotBlank(richiedenteId) && RuoloInput.equalsIgnoreCase(SelfQAdVWizardController.RICHIEDENTE_ROLE)) {// onUpdate all soggetto o richiedente
                //il ID richiedente deve essere lo stesso cosi non crea altro richiedente
                /*if(subjectInput.Role__c.containsIgnoreCase(SelfQAdVWizardController.SOGGETTO_ROLE) && 
                    String.isBlank(subjectInput.FiscalIdentifier__c) && subjectInput.Delegate__c){
                    //subjectInput.isActive__c = true;
                    subjectInput.TECH_RequiredFieldsMissing__c = true;
                }*/

                subjectInput.id = richiedenteId;
                update subjectInput;
                toRet.isSuccess = true ;
                toRet.errorMessage =RuoloInput.equalsIgnoreCase(SelfQAdVWizardController.SOGGETTO_ROLE)? SelfQAdVWizardController.SOGGETTO_ROLE: SelfQAdVWizardController.RICHIEDENTE_ROLE
                + ' aggiornato OK';  
            }else {
                subjectInput.TECH_RequiredFieldsMissing__c = false;
                update subjectInput;
                toRet.isSuccess = true;
                toRet.errorMessage =SelfQAdVWizardController.SOGGETTO_ROLE  + ' aggiornato OK';  
            }
            // da aggiungere dopo che funziona tutto ..per adesso voglio gli errori in CONSOLE 
            try {
                if(documents != null){
                    List<DocumentStructureWrapper> docList = new List<DocumentStructureWrapper>();
                    List<DocumentChecklistItem__c> docsToUpsert = new List<DocumentChecklistItem__c>();
                    List<ContentDocument> docsToDelete = new List<ContentDocument>();
                    List<DocumentChecklistItem__c> docsToClear = new List<DocumentChecklistItem__c>(); //rimuovere i content document link vecchi
                    List<String> contentDocumentCreated = new List<String>();

                    for(selfQAdVWizardManageSubjectController.DocumentWrapper dw : documents){
                       //system.debug(System.LoggingLevel.INFO,dw);
                        DocumentChecklistItem__c dci = dw.document;
                        if(dci.SelfStatus__c == 'C8'){
                            dci.Nome_File__c = 'INVALIDATO_'+dci.Nome_File__c;
                        }
                        if(dci.DocumentAccountId__c == null){
                            dci.DocumentAccountId__c = subjectInput.id;
                        }
                        if(dw.deleteFile != null && dw.deleteFile && String.isNotBlank(dw.ContentDocumentId)){
                            docsToDelete.add(
                                new contentDocument( Id = dw.ContentDocumentId )
                            );
                        }
                        docsToUpsert.add(dci);
                        if(dw.fileData != null){
                            if(dci.TECH_FileFromCase__c != null && dci.TECH_FileFromCase__c && dci.Id != null){
                                docsToClear.add(dci);
                            }
                            else if(String.isNotBlank(dw.ContentDocumentId))
                                docsToDelete.add(
                                    new contentDocument( Id = dw.ContentDocumentId )
                                );
                            DocumentStructureWrapper temp = new DocumentStructureWrapper();
                            temp.doc = dci;
                                
                            
                            if(dw.fileData.fileType != null){
                                if('ContentDocumentNew'.equalsIgnoreCase(dw.fileData.fileType)){
                                dci.TECH_FileFromCase__c = false;
                                    temp.ContentDocumentIdNew = dw.fileData.fileId;
                                    contentDocumentCreated.add(dw.fileData.fileId);
                            }
                                    if('ContentDocument'.equalsIgnoreCase(dw.fileData.fileType)){
                                        dci.TECH_FileFromCase__c = true;
                                        temp.ContentDocumentId = dw.fileData.fileId;
                                    }
                                    else if('Attachment'.equalsIgnoreCase(dw.fileData.fileType)){
                                        dci.TECH_FileFromCase__c = false;
                                        temp.AttachmentId = dw.fileData.fileId;
                                    }
                                }
                            
                            
                            docList.add(temp);

                        }
                        
                    }
                    upsert docsToUpsert;

                    if(!docsToDelete.isEmpty()){
                        deleteFiles(docsToDelete);
                    }

                    if(!contentDocumentCreated.isEmpty() && !Test.isRunningTest()){
                        removeFromlibrary(contentDocumentCreated);
                    }

                    if(!docsToClear.isEmpty()){
                        deleteLinks(docsToClear);
                    }

                    if(!docList.isEmpty()){
                        handleFiles(docList, caseId);
                    }
                    
                }
                

            } catch (Exception errorEx) {
            ApplicationLogHelper.ERROR('SelfQAdVWizardController', errorEx.getMessage(), errorEx.getStackTraceString());
            toRet.isSuccess = false ;
            toRet.errorMessage = 'Exception Error, controllare il ApplicationLogHelper SelfQAdVWizardController ora-'+System.now();   
        }

        return toRet;
    }

    /**
     * @description cancella i ContentDocumentLink superflui
     * @param docsList 
     */
    private static void deleteLinks(List<DocumentChecklistItem__c> docsList){
        try{
            Set<string> ids = new Set<String>();
            for(DocumentChecklistItem__c dci : docsList){
                ids.add(dci.Id);
            }
            List<ContentDocumentLink> docLinks = [Select id from ContentDocumentLink where LinkedEntityId IN :ids WITH SECURITY_ENFORCED];
            delete docLinks;
        } catch(Exception ex){
            ApplicationLogHelper.ERROR('SelfQAdVWizardController', ex.getMessage(), ex.getStackTraceString());
        }

    }

    /**
     * @description       method used to remove files from the qadv library
     * @param documentsId 
     */
    private static void removeFromlibrary(List<String> documentsId){
        List<ContentFolder> destinationFolder = [Select id from ContentFolder where name = 'Completed'];
        ID destinationFolderId;
        
        destinationFolderId = destinationFolder.get(0).Id;//i want the exception to be thrown.
        

        List<ContentFolderMember> cfmList = [Select id from ContentFolderMember where ChildRecordId in: documentsId and ParentContentFolder.Name = 'Staging'];
        
        for( ContentFolderMember cdl : cfmList){
            cdl.ParentContentFolderId = destinationFolderId;
        }

        update cfmList;

         //i want the exception to be thrown.
        
    }

    /**
     * @description cancella i file
     * @param ContentDocumentIds 
     */
    private static void deleteFiles(List<ContentDocument> ContentDocumentIds){
        try{
            delete ContentDocumentIds;
        } catch(Exception ex){
            ApplicationLogHelper.ERROR('SelfQAdVWizardController-deleteFiles', ex.getMessage(), ex.getStackTraceString());
        }

    }

    /**
     * @description gestisce i file provenienti dal wizard, inserendo quelli nuovi e facendo i collegamenti con i contentDocumentLink
     * @param docList 
     * @param caseId 
     */
    private static void handleFiles(List<DocumentStructureWrapper> docList, String caseId){
        
        List<ContentVersion> cvToInsert = new List<ContentVersion>();
        List<ContentDocumentLink> cdlToInsert = new List<ContentDocumentLink>();
        List<String> DCLI_List = new List<String>();
        List<String> AttachmentIds = new List<String>();
        Map<String, DocumentStructureWrapper> attachIdToDoc = new Map<String, DocumentStructureWrapper>();

        Map<String, String> VersionToDocId = new Map<String,String>();
        for(DocumentStructureWrapper doc : docList){
            if(doc.version != null)
                cvToInsert.add(doc.version);
            if(doc.AttachmentId != null){
                AttachmentIds.add(doc.AttachmentId);
                attachIdToDoc.put(doc.AttachmentId, doc);
            }
            DCLI_List.add(doc.doc.Id);
        }

        if(!AttachmentIds.isEmpty()){
            for(Attachment att : [Select id, Body, Name from Attachment where id in:AttachmentIds WITH SECURITY_ENFORCED]){
                DocumentStructureWrapper dw = attachIdToDoc.get(att.id);
                dw.version = new ContentVersion(
                                    VersionData = att.Body,
                                    Title = att.Name,
                                    PathOnClient = att.Name
                                );
                cvToInsert.add(dw.version);
            }
        }

        
        
        if(!cvToInsert.isEmpty()){
            insert cvToInsert;

            for(ContentVersion cv : [Select id, contentDocumentId from ContentVersion where id in:cvToInsert WITH SECURITY_ENFORCED]){
                VersionToDocId.put(cv.Id, cv.contentDocumentId);
            }

        }

        

        for(DocumentStructureWrapper doc : docList){
            String contentId;
            if(doc.ContentDocumentId != null){
                contentId = doc.ContentDocumentId;
            }
            else if(doc.ContentDocumentIdNew != null){
                contentId = doc.ContentDocumentIdNew;
                cdlToInsert.add(new ContentDocumentLink(
                    LinkedEntityId = caseId,
                    ContentDocumentId = contentId
                ));
            }
            else if(VersionToDocId.containsKey(doc.version.Id)){
                contentId = VersionToDocId.get(doc.version.Id);
                cdlToInsert.add(new ContentDocumentLink(
                    LinkedEntityId = caseId,
                    ContentDocumentId = contentId
                ));
            }
            

            if(String.isNotBlank(contentId)){
                cdlToInsert.add(new ContentDocumentLink(
                    LinkedEntityId = doc.doc.Id,
                    ContentDocumentId = contentId
                ));

                
            }
            
            
        }
        if(!cdlToInsert.isEmpty())
            insert cdlToInsert;
        
    }
    
    /**
    * @author   reply
    * @description piccola descrizione della classe e forse il svilupo per quelle e fatta esempio -> IDCRM025
    */
    public class fileWrapper{
        /**
         * @description tipo file
         */
        @AuraEnabled
        public string fileType {get;set;}
        /**
         * @description nome file
         */
        @AuraEnabled
        public string fileName {get;set;}
        /**
         * @description Id del file
         */
        @AuraEnabled
        public string fileId {get;set;}

        /**
         * @description Costruttore
         * @param fileType 
         * @param fileName 
         * @param fileId 
         */
        public fileWrapper(string fileType, string fileName, string fileId){
            this.fileType = fileType;
            this.fileName = fileName;
            this.fileId = fileId;
        }
        
    }

    /**
     * @description ritorna una lista completa dei file già associati al case
     * @param caseId 
     * @return  `List<fileWrapper>`
     */
    @AuraEnabled
    public static List<fileWrapper> getFiles(String caseId){
        List<fileWrapper> toRet = new List<fileWrapper>();
        List<ContentDocumentLink> docList = [Select ContentDocumentId, ContentDocument.Title from ContentDocumentLink where LinkedEntityId =: caseId WITH SECURITY_ENFORCED];
        for(ContentDocumentLink docLink : docList){
            toRet.add(
                new fileWrapper(
                    'ContentDocument',
                    docLink.ContentDocument.Title,
                    docLink.ContentDocumentId
                )
            );
        }

        List<Attachment> attachmentList = [Select Id, Name, Body from Attachment where ParentId =: caseId WITH SECURITY_ENFORCED];
        for(Attachment att : attachmentList){
            toRet.add(
                new fileWrapper(
                    'Attachment',
                    att.Name,
                    att.Id
                )
            );
        }
    
        return toRet;
    }


    /** 
    * @param	caseInput Case condiviso per il recordId del LWC chiamante
    * @param	richiedenteInput richiedente della pratica documentale
    * @return	risposta InitWrapper sul case andato OK 
    * @description metodo per confermare il QAdV e creare l'utenza di Auth0
    */
    @AuraEnabled
    public static InitWrapper confirmQAdV(Case caseInput, DocumentAccount__c richiedenteInput){
        InitWrapper toRet = new InitWrapper();
        try {

            IE_Auth0_RequestWrapper req = new IE_Auth0_RequestWrapper();
            String regex = '[^a-zA-Z0-9\\s]';
            if(String.isNotBlank(richiedenteInput.FirstName__c)){
            req.name = richiedenteInput.FirstName__c.replaceAll(regex, ' ');
            } else {
                req.name = richiedenteInput.SurnameCompanyName__c.replaceAll(regex, ' ');
            }

            req.surname = richiedenteInput.SurnameCompanyName__c.replaceAll(regex, ' ');
            
            req.email = caseInput.SuppliedEmail;

            IE_Auth0_ResponseWrapper res = IE_Auth0_Execute.executeAuth0(req);
            
            if(res.user_created != null){
                caseInput.SelfQADV_PCC_NewCredentials__c = res.user_created ? 'SI' : 'NO';
                    toRet.isSuccess = true;
                }
            else if (res.message != null){
                caseInput.SelfQADV_PCC_NewCredentials__c = 'ERRORE';
                String messageNoKeys = res.message.replaceAll(regex,' ');
                toRet.errorMessage = 'S01 - Le credenziali non sono state generate per un problema tecnico. '+ messageNoKeys ;
                toRet.isSuccess = false;
            }
                else{
                    caseInput.SelfQADV_PCC_NewCredentials__c = 'ERRORE';
                toRet.errorMessage = 'S01 - Le credenziali non sono state generate per un problema tecnico. Riprovare più tardi a generare le credenziali tramite il tasto "Conferma"';
                    toRet.isSuccess = false;
                }
            
            CaseHandler.RunTrigger = false;
            update caseInput;
            
        } catch(IE_Auth0_Execute.Auth0Exception ex){

            toRet.isSuccess = false;
            ApplicationLogHelper.ERROR('SelfQAdVWizardController', ex.getMessage(), ex.getStackTraceString());
            toRet.errorMessage = 'Errore conferma QAdV, riprova piu\' tardi. Se il problema persiste, contatta l\'amministratore di sistema';

        } catch (Exception e) {
            toRet.isSuccess = false;
            ApplicationLogHelper.ERROR('SelfQAdVWizardController', e.getMessage(), e.getStackTraceString());
            toRet.errorMessage = 'Errore conferma QAdV, riprova piu\' tardi. Se il problema persiste, contatta l\'amministratore di sistema'; 
        } 

        return toRet;
    }

}