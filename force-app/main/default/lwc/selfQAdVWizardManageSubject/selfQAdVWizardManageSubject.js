import { LightningElement,track, api } from 'lwc';
import { LghtAbstract } from 'c/lghtAbstract';
import Init from '@salesforce/apex/selfQAdVWizardManageSubjectController.init';
import UpdateDocumentAccountInfo from '@salesforce/apex/SelfQAdVWizardController.UpdateDocumentAccountInfo';
import deleteOldFiles from '@salesforce/apex/selfQAdVWizardManageSubjectController.deleteOldFiles'

export default class SelfQAdVWizardManageSubject extends LghtAbstract {

    @api recordId;
    @api caseRecordId;
    @api closeCallback;
    @api operationType;
    @api disableInputsWFCL;
    @api integrationDone;

    @track context ;
    @track allDocuments = [];
    

    currentAccount;
    filesToDelete = []
    Available_Client_Statuses;
    Client_Statuses_Kyc_Cancel;
    Client_Statuses_Document_Deletion;
    Enable_Doc_visualization_Statuses;

    selectedStatusNotAvailable = false;
    selectedStatusDeleteFile = false;

    saved = false;
    confirmHelpText = '';
    docForms = [];
    soggettoOK = false;
    fileData;
    ready = false;
    showUploadDoc = false;
    selectedDocument;
    showConfirmationModal = false;
    confirmationText;
    confirmationModalCallback;
    startingDocument;

    connectedCallback(){
        this.initComponent();
    }
    async initComponent(){
        console.log('InitCompoManaSubject');
        
        this.ready = false;
        this.filesToDelete = [];
        this.showSpinner();
        var result = await Init({
            subjectSelected : this.recordId,
            OperationType: this.operationType,
            caseId : this.caseRecordId
        }).catch((err)=>{
            this.alertMessage('Error Server Init ',err.body.message);
            if(err.body.message.includes('List has no rows'))
                this.warningMessage('DEMO','Tipo di Operazione acettato per DEMO-> A or B ');		
        });
        if(result != null){
            this.allDocuments = result.documents;
            this.Available_Client_Statuses = result.Available_Client_Statuses;
            this.Client_Statuses_Document_Deletion = result.Client_Statuses_Document_Deletion;
            this.Client_Statuses_Kyc_Cancel = result.Client_Statuses_Kyc_Cancel;
            this.Enable_Doc_visualization_Statuses = result.Enable_Doc_visualization_Statuses;

            for(var doc of result.documents){
                this.docForms.push({});
            }
        }
        this.ready = true;
        console.log(result);
        this.hideSpinner();

    }

    onChange = (e, child) => {
		console.log('onChange');	
        if(child.formLoaded){

           
            //Commentato da Dario 05/07/2023
            /*if(e.DocumentAccount__c && e.DocumentAccount__c.Survey_Type__c && this.currentAccount.Survey_Type__c != e.DocumentAccount__c.Survey_Type__c){
                if( e.DocumentAccount__c.Survey_Type__c === "BEN"){
                    console.log('test');
                    this.context.DocumentAccount__c.FiscalIdentifier__c = e.DocumentAccount__c.FiscalIdentifier__c = "";
                    child.data['FiscalIdentifier__c'] = "";
                    //child.render();
                
                    
                    
                }
            }*/
        }
		this.context = {...this.context, ...e};
        
        let soggetto = this.context.DocumentAccount__c;
        if(!this.disableInputsWFCL && this.integrationDone){

            child.setDisableSingle("isActive__c", false, false);

        }
        if(soggetto){
            //Commentato da Dario 05/07/2023
            /*if(soggetto.Delegate__c == false && soggetto.Role__c != null && soggetto.Role__c.includes('Richiedente')){
                child.setDisableSingle("FiscalIdentifier__c", true, false);
            }*/
            
        }
        
        if(child.formLoaded){
            this.saved = false;
        }

        

        if(!this.integrationDone && !this.disableInputs ){
            if(soggetto.SubjectType__c === 'PF'){
                child.setDisableSingle("FirstName__c", false, false);
            }
            else{
                child.setDisableSingle("FirstName__c", true, true);
                soggetto.FirstName__c = "";
            }
        }
        
        
        this.soggettoOK =  child.isFormComplete;
        this.currentAccount = this.proxyData(this.context.DocumentAccount__c);
        //console.log(this.proxyData(this.documents));

       // console.log(this.documents[0].Override__c);
	}

    get disableInputs(){
        return this.recordId && (this.integrationDone || this.disableInputsWFCL);
    }
    
    get disableDocInputs(){
        return this.recordId && this.disableInputsWFCL;
    }
    
    get disableConfirm(){

        if(!this.soggettoOK){
            this.confirmHelpText = 'Compilare i campi richiesti!';
            return true;
        }
        for(var doc of this.allDocuments){
            if(doc.selectedStatusNotAvailable){
                this.confirmHelpText = 'Stato cliente selezionato non valido!';
                return true;
            }
        }
        this.confirmHelpText = '';
        return false;
    }

    handleConfirmFile = (fileData) => {
        var selectedDCI = this.allDocuments[this.selectedDocument];
        this.saved = false;
        //console.log(this.proxyData(fileData));
        if(fileData){
            console.log(fileData)
            selectedDCI.fileData = fileData;
            if(fileData.fileType === 'ContentDocumentNew'){
                this.filesToDelete.push(fileData.fileId);
            }
        }
        //console.log(this.proxyData(this.allDocuments))
        this.docForms[this.selectedDocument].updateData({SelfStatus__c : 'C7'});
        this.docForms[this.selectedDocument].updateData({Nome_File__c : fileData.fileName});
        this.docForms[this.selectedDocument].setDisableSingle("SelfStatus__c", true, false);
        this.docForms[this.selectedDocument].setDisableSingle("Override__c", true, false);
        selectedDCI.document.Nome_File__c = fileData.fileName;
        selectedDCI.document.SelfStatus__c = "C7";
        selectedDCI.document.Detica_Id__c = null;
        selectedDCI.document.FilenetId__c = null;
        this.showUploadDoc = false;
    }


    onChangeDocument = (e, child) =>{

        var identifier = child.internalIdentifier;
        this.docForms[identifier] = child;
        let formLoaded = child.formLoaded;
        let doc = this.allDocuments[identifier];
        //let statusChanged = false;

        //check if the status changed;

        if(formLoaded){
            this.saved = false;
        }

        if(formLoaded && doc.document.SelfStatus__c !== e.DocumentChecklistItem__c.SelfStatus__c ){
            doc.selectedStatusNotAvailable = !this.Available_Client_Statuses.includes(e.DocumentChecklistItem__c.SelfStatus__c);
            
            doc.deleteFile = this.Client_Statuses_Document_Deletion && this.Client_Statuses_Document_Deletion.includes(e.DocumentChecklistItem__c.SelfStatus__c);

            doc.callKyc = this.Client_Statuses_Kyc_Cancel && this.Client_Statuses_Kyc_Cancel.includes(e.DocumentChecklistItem__c.SelfStatus__c);
        }


        console.log(identifier);
        doc.document = {...doc.document, ...this.proxyData(e.DocumentChecklistItem__c)};
        var currentDocument = doc.document;
        if(!formLoaded){
            let firstCheck = true;
            if(this.Enable_Doc_visualization_Statuses){
                firstCheck = this.Enable_Doc_visualization_Statuses.includes(currentDocument.SelfStatus__c);
            }

            doc.disableVisualizza = firstCheck && (doc.ContentDocumentId) ? false: true;
            if(currentDocument.SelfStatus__c === 'C7'){
            this.docForms[identifier].setDisableSingle("SelfStatus__c", true, false);
            this.docForms[identifier].setDisableSingle("Override__c", true, false);
            //doc.disableOverrideDocument = true;
        }
        }
        if(e.DocumentChecklistItem__c.Override__c != null){
            doc.disableOverrideDocument = !e.DocumentChecklistItem__c.Override__c;
        }

        

        if(formLoaded && currentDocument.SelfStatus__c === 'C9'){
            this.docForms[identifier].setDisableSingle("Status__c", true, true);
        }
        
        
    }

    handleConfirm(){
        if(this.saved) 
            this.closeCallback({refresh: true});
        else{
        for(var doc of this.allDocuments){
            if(doc.deleteFile){
                this.confirmationText = 'Stai per eliminare un documento. Continuare?';
                this.confirmationModalCallback = this.onConfirm;
                this.showConfirmation();
                return;
            }
        }

            this.onConfirm(false);

        }
        
        
    }

    handleSave(){
    
        for(var doc of this.allDocuments){
            if(doc.deleteFile){
                this.confirmationText = 'Stai per eliminare un documento. Continuare?';
                this.confirmationModalCallback = this.onConfirm;
                this.showConfirmation();
                return;
            }
        }

        
        this.onConfirm(true);
        
    }

    onConfirm = (refresh) => {
        this.closeConfirmationModal();
        console.log('onConfirm');
        console.log(this.proxyData(this.context));
        this.showSpinner(true);
        console.log(this.proxyData(this.allDocuments));
        
        UpdateDocumentAccountInfo({
            param:{
            subjectInput:this.context.DocumentAccount__c,
            caseId:this.caseRecordId,
            RuoloInput:'Soggetto',
            richiedenteId:'',
            documents: this.allDocuments
            }
        }).then((response)=>{
            if(response.isSuccess){
                this.saved = true;
                this.successMessage(response.errorMessage);
                if(!this.recordId && response.richiedenteId)
                    this.recordId = response.richiedenteId;
                if(!refresh)
                this.closeCallback({refresh: true});
                else{
                    this.initComponent();
                }
                    

                // aggiornare i documenti inserire i Doc in Array o se porta un ID aggiornare
            }else
            if(!response.isSuccess) {
                this.alertMessage('Errore',response.errorMessage);
            }
        }).catch((err)=>{
            this.alertMessage('Errore',err.message);		
        }).finally( () => {
            this.hideSpinner();
        })
	}

    addDocumento(){
        this.warningMessage('DEMO','ANCORA IN SVILUPPO posibile dinamic creation of DOCs :-!');	
		/*const objec1 = {Document_Type__c : "DDI", Name : "Name-Temp",Stato_Compilazione_Doc__c : "stato di comp1 cliente3"};
        this.allDocuments = [...this.allDocuments,objec1];
        console.log(this.proxyData(this.context));
        console.log(this.allDocuments);*/
    }

    onUploadFile(e){
        
        this.selectedDocument = e.target.dataset.selected;
        console.log(this.selectedDocument);
        var selectedDCI = this.allDocuments[this.selectedDocument];
        if(selectedDCI.fileData && selectedDCI.fileData.fileType == 'ContentDocumentNew'){
            this.startingDocument = selectedDCI.fileData.fileId;
        }
        else{
            this.startingDocument = null;
        }
        this.showUploadDoc = true;
        //lasciare il ID del Document cosi se carica lo soprascrivi e se visualizaa lo cerchi con il ID del botone 
        // ID del botone = ID del documentListItems -> like_> a2m0E000000WTaAQAW
        //abilitato solo se il flag «Override» è stato selezionato
        
    }
    
    get acceptedFormats() {
        // modificare per prendere il valore che ce in un custom sett o MTD non ricordo bene!
        return ['.pdf', '.png'];
    }
    handleUploadFinished = (e) => {
                // Get the list of uploaded files
                //copia - ContentDocumentLink aggiungere il id del DocumentChecklistItem__c creato prima nel clic del ADD
                const uploadedFiles = e.detail.files;
                console.log('No. of files uploaded : ' + uploadedFiles.length);
                console.log(uploadedFiles[0].documentId);
                //se di piu da uno dobbiamo LOOP la creazione del ContentDocumentLink
    }
    closeUploadDoc = () => {
        this.showUploadDoc = false;
    }

    closeConfirmationModal = () => {
        this.showConfirmationModal = false;
    }
    showConfirmation = () => {
        this.showConfirmationModal = true;
    }

    handleAnnulla(){
        this.confirmationText = 'I dati non salvati andranno perduti. Continuare?';
        this.confirmationModalCallback = this.executeAnnulla;
        this.showConfirmation();
        return;
    }

    executeAnnulla = () => {
        if(this.filesToDelete.length != 0){
            this.closeConfirmationModal();
            this.showSpinner();
            deleteOldFiles( {fileIds : this.filesToDelete} ).then(
                (result) => {
                    this.hideSpinner();
                    this.closeCallback();
                    
                }
            )
        }
        else{
            this.closeCallback();
        }
    }

    onViewFileNet(e){
        
        var selected = e.target.dataset.selected;
        var ContentId = this.allDocuments[selected].ContentDocumentId;
        if(ContentId)
            this.navigateToRecordPage({
                objectApiName: 'ContentDocument',
                actionName: 'view',
                recordId: ContentId
            });
        else{
            this.alertMessage('Errore', 'Documento non presente su SFDC');
        }
        
    }
}