/** 
 * @author	Reply
 * @date	01/04/2023 4xx
 * @description Class controller del LWC SelfQAdVWizardManageSubject
 */
public without sharing class selfQAdVWizardManageSubjectController {
    /**
    *@description Classe per filemodel
    */
    public class fileModel{
        /**
         * @description Base64 of the file
         */
        @AuraEnabled
        public String base64 {get; set;}

        /**
         * @description Name of the file
         */
        @AuraEnabled
        public String filename {get; set;}

        /**
         * @description Id of the file
         */
        @AuraEnabled
        public String fileId {get;set;}

        /**
         * @description Type of the file
         */
        @AuraEnabled
        public String fileType {get;set;}
        
    
    }
    /**
     * @description move file to workspace           
     * @param ContentDocumentId 
     * @exception               
     */
    @AuraEnabled
    public static void moveToWorkspace( String ContentDocumentId ){
        try {

            List<ContentFolder> folders = [Select id from ContentFolder where name = 'Staging' WITH SYSTEM_MODE]; // NOPMD  Fix CRUD

            
            List<ContentWorkspace> workSpace = [Select id from ContentWorkspace where Name = 'SelfQADV Override' WITH SYSTEM_MODE]; // NOPMD  Fix CRUD
            Id workSpaceId;
            if(workSpace.isEmpty()){
                ContentWorkspace cw = new ContentWorkspace(Name = 'SelfQADV Override');
                insert cw; // NOPMD  Fix CRUD
                workSpaceId = cw.Id;
            }
            else{
                workSpaceId = workSpace.get(0).Id;
            }

            if(workSpaceId != null){
                ContentDocumentLink cwd = new ContentDocumentLink(
                    LinkedEntityId = workSpaceId,
                    ContentDocumentId = contentDocumentId
                );
                insert cwd; // NOPMD  Fix CRUD

                List<ContentFolderMember> cfmList = [select id from ContentFolderMember where ChildRecordId =: contentDocumentId and ParentContentFolder.Name =: workSpaceId WITH SYSTEM_MODE]; // NOPMD  Fix CRUD
                for(contentFolderMember cfm : cfmList){
                    cfm.ParentContentFolderId = folders.get(0).Id;
                }
                update cfmList; // NOPMD  Fix CRUD
            }

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description   delete old files
     * @param fileIds 
     * @exception     
     */
    @AuraEnabled
    public static void deleteOldFiles(List<String> fileIds){
        try {
            List<ContentDocument> listToDelete = new List<ContentDocument>();
            for(String id : fileIds){
                listToDelete.add(new ContentDocument(Id = id));
            }
            delete listToDelete; // NOPMD  Fix CRUD
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    *@description Classe per responseWrapper
    */
    public class DocumentWrapper{
        /**
         * @description input document
         */
        @AuraEnabled
        public DocumentChecklistItem__c document {get;set;}

        /**
         * @description input contentDocumentId
         */
        @AuraEnabled
        public String ContentDocumentId {get;set;}

        /**
         * @description document Id
         */
        @AuraEnabled
        public String documentId {get; set;}

        /**
         * @description disableOverrideDocument
         */
        @AuraEnabled
        public Boolean disableOverrideDocument {get; set;}

        /**
         * @description document type
         */
        @AuraEnabled
        public String documentType {get; set;}

        /**
         * @description document list identifier
         */
        @AuraEnabled
        public Integer documentListNumber {get;set;}

        /**
         * @description fileData
         */
        @AuraEnabled
        public fileModel fileData {get;set;}

        /**
         * @description specifica se il file deve essere cancellato
         */
        @AuraEnabled
        public Boolean deleteFile{get;set;}

        /**
         * @description specifica se deve essere chiamato il kyc cancel
         */
        @AuraEnabled
        public Boolean callKyc{get;set;}

    }

    /**
    *@description Classe per responseWrapper
    */
    public class InitWrapper extends LghtResponse {
        /**
        * @description id soggetto input
        */
        @AuraEnabled
        public String subjectId {get;set;}// DocumentAccountId__c 

        /**
        * @description lista stati per kyc cancel
        */
        @AuraEnabled
        public String Client_Statuses_Kyc_Cancel {get;set;}

        /**
        * @description lista stati cliente da poter selezionare
        */
        @AuraEnabled
        public String Available_Client_Statuses {get;set;}

        /**
        * @description lista stati cliente che definiscono se il documento si pu� visualizzare o meno
        */
        @AuraEnabled
        public String Enable_Doc_visualization_Statuses {get;set;}
        
        /**
        * @description lista stati per la cancellazione dei documenti
        */
        @AuraEnabled
        public String Client_Statuses_Document_Deletion {get;set;}

        /**
        * @description lista documenti 
        */
        @AuraEnabled
        public List<DocumentWrapper> documents {get;set;}

        /**
         * @description costruttore
         */
        public InitWrapper(){
            this.documents = new List<DocumentWrapper>();
        }
    }

    /**
     * 
     * @param subjectSelected 
     * @param OperationType 
     * @param caseId 
     * @return  `InitWrapper`
     * @description metodo di init della pagina di manage soggetti del wizard
     */
    @AuraEnabled
    public static InitWrapper init(String subjectSelected,String OperationType,String caseId){
        InitWrapper toRet = new InitWrapper();
     try {
        Map<String,String> DocumentTypeMapping = getPicklistValues('DocumentChecklistItem__c', 'Document_Type__c');

        String filterID = String.escapeSingleQuotes(subjectSelected) ;
        String QUERY_START = 'Select id, ToLabel(Document_Type__c), Override__c, (Select ContentDocumentId from ContentDocumentLinks order by contentDocument.createdDate desc limit 1)';
        String QUERY_END = ' from DocumentChecklistItem__c where DocumentAccountId__c = \''+filterID + '\' order by Document_Type__c' ;  
        List <DocumentChecklistItem__c>  listDocs = new List <DocumentChecklistItem__c> ();
        //List<String> documentsTypes = new List<String>();
        List<DocumentWrapper> documentWrapperList = new List<DocumentWrapper>();
        // query sul MTD per scegliere i campi dinamici .OCCHIO non possono essere duplicati o si in caso ..cambiare il filtro query
        List<FormConfig__mdt> listFieldsToupdate = [select Field__c,Default__c  from FormConfig__mdt where Form__c = 'wizard-qadv-document-item' WITH SYSTEM_MODE]; // NOPMD  Fix CRUD
        /*for(FormConfig__mdt fieldTemp:listFieldsToupdate){
            if(isPicklistField('DocumentChecklistItem__c', fieldTemp.Field__c))
                QUERY_START += ',TOLABEL('+fieldTemp.Field__c +')';
            else
                QUERY_START += ','+fieldTemp.Field__c;
        }*/

        for(SelfQAdV_Metadata__mdt meta : [Select Id, DeveloperName, Value__c from SelfQAdV_Metadata__mdt WITH SYSTEM_MODE]){ // NOPMD  Fix CRUD
            if('Client_Statuses_Kyc_Cancel'.equals(meta.DeveloperName)){
                toRet.Client_Statuses_Kyc_Cancel = meta.Value__c;
            }
            else if('Available_Client_Statuses'.equals(meta.DeveloperName)){
                toRet.Available_Client_Statuses = meta.Value__c;
            }
            else if('Client_Statuses_Document_Deletion'.equals(meta.DeveloperName)){
                toRet.Client_Statuses_Document_Deletion = meta.Value__c;
            }
                else if('Enable_Doc_visualization_Statuses'.equals(meta.DeveloperName)){
                    toRet.Enable_Doc_visualization_Statuses = meta.Value__c;
                }
        }
        
            String query = (QUERY_START + QUERY_END).escapeJava() ;
            //system.debug(System.LoggingLevel.INFO,'query ->'+query);
        listDocs = Database.query(query);
        
        //metadata per prendere i documenti disponibile obligatoriamente per tipo operazione
            List<SelfQadv_Documento_Tipo_Operazione__mdt> DocForOperations = [select Document_Type__c, DefaultStatus__c  from SelfQadv_Documento_Tipo_Operazione__mdt where Tipo_Operazione__c=: OperationType OR Tipo_Operazione__c='*' WITH SYSTEM_MODE order by Document_Type__c]; // NOPMD  Fix CRUD
    
        /*if(DocForOperations!= null && String.isNotBlank(DocForOperations.Document_Type__c)){
            documentsTypes = String.valueOf(DocForOperations.Document_Type__c).split(';');
        }
        else {// non ce il MTD ancora x questa configurazione :!
            toRet.isSuccess = false;
            toRet.errorMessage =  'Non esiste SelfQadv_Documento_Tipo_Operazione__mdt per operazione '+OperationType ;
            return toRet;
        }*/
        // una idea per creare mappa x Type Operation, PERO OCCHIO -> un record per TYPE DOCUMENT 
        //solo posso avere 1 documento per tipo documento ok
        Map<String,String> OperationTypeByRecords = new Map<String,String>();
        Integer i = 0;
        if(!listDocs.isEmpty()){
            
            for(DocumentChecklistItem__c temp_pivot: listDocs){
                DocumentWrapper temp = new DocumentWrapper();
                //temp.document = temp_pivot;
                temp.documentId = temp_pivot.Id;
                temp.documentType = temp_pivot.Document_Type__c;
                temp.disableOverrideDocument = !temp_pivot.Override__c;
                temp.documentListNumber = i;
                if(temp_pivot.ContentDocumentLinks != null){
                    for(ContentDocumentLink cl : temp_pivot.ContentDocumentLinks){
                        temp.ContentDocumentId = cl.ContentDocumentId;
                    }
                }
                i =+ 1;
                documentWrapperList.add(
                    temp
                );
                OperationTypeByRecords.put(temp_pivot.Document_Type__c,temp_pivot.id);
            }
                

            //creare i records mancati x type
        }
        else {// crea al meno 1 record per ogni configurazione obligatoria
            for(SelfQadv_Documento_Tipo_Operazione__mdt DocToCreate : DocForOperations){
                DocumentChecklistItem__c temp  = createNonCommitRecord(DocToCreate,listFieldsToupdate);
                //temp.DocumentAccountId__c = subjectSelected ;
                temp.CaseId__c = caseId ;
                DocumentWrapper tempWrapper = new DocumentWrapper();
                tempWrapper.document = temp;
                tempWrapper.documentType = DocumentTypeMapping.get(temp.Document_Type__c);
                tempWrapper.disableOverrideDocument = !temp.Override__c;
                tempWrapper.documentListNumber = i;
                i =+ 1;
                documentWrapperList.add(
                    tempWrapper
                );
                listDocs.add(temp);
            }
            //System.debug(system.LoggingLevel.INFO,'***lista records-'+listDocs);
            //insert listDocs ;
        }
        toRet.isSuccess = true;
        toRet.errorMessage = 'docs creati o aggiornati';
        toRet.documents.addAll(documentWrapperList);

         } catch (Exception errorEx) {
        ApplicationLogHelper.ERROR('selfQAdVWizardManageSubjectController', errorEx.getMessage(), errorEx.getStackTraceString());
        toRet.isSuccess = false ;
        toRet.errorMessage = 'Exception Error, controllare il ApplicationLogHelper selfQAdVWizardManageSubjectController ora-'+System.now();   
        }
        
        return toRet;
    }

    private static DocumentChecklistItem__c createNonCommitRecord(SelfQadv_Documento_Tipo_Operazione__mdt DocumentType,List<FormConfig__mdt> listFieldsToupdate){
        DocumentChecklistItem__c response = new DocumentChecklistItem__c();

        for(FormConfig__mdt temp_config:listFieldsToupdate ){
            if('Document_Type__c'.equalsIgnoreCase(temp_config.Field__c) || temp_config.Default__c == null)
                continue;
            if(temp_config.Default__c=='true' || temp_config.Default__c=='false')
                response.put(temp_config.Field__c, Boolean.valueOf(temp_config.Default__c));
            else
                response.put(temp_config.Field__c, temp_config.Default__c);
        }

        if(String.isNotBlank(DocumentType.DefaultStatus__c)){
            response.put('SelfStatus__c', DocumentType.DefaultStatus__c);
        }
        
        response.put('Document_Type__c', DocumentType.Document_Type__c);
        response.put('Name', 'Documento-'+DocumentType.Document_Type__c);

        return response;
    }

    private static boolean isPicklistField(String objectInput,String field){

        Schema.DisplayType f = Schema.getGlobalDescribe() // or Schema.SOAPType
        .get(objectInput)
        .getDescribe()
        .fields
        .getMap()
        .get(field)
        .getDescribe()
        .getType(); // or getSOAPType()

        if('PICKLIST'.equalsIgnoreCase(String.valueOf(f)))
            return true;
        else 
            return false;
    }

    private static Map<String, String> getPicklistValues(String objectInput,String field){
        Map<String, String> toRet = new Map<String, String>();
        Schema.DescribeFieldResult f = Schema.getGlobalDescribe() // or Schema.SOAPType
        .get(objectInput)
        .getDescribe()
        .fields
        .getMap()
        .get(field)
        .getDescribe();

        List<Schema.PicklistEntry> ple = f.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
			toRet.put(pickListVal.getValue(), pickListVal.getLabel());
		}     
        return toRet;
    }
    
}