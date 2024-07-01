import { LightningElement, api, track } from 'lwc';
import { LghtAbstract } from 'c/lghtAbstract';
import getDocuments from '@salesforce/apex/SelfQAdVWizardController.getFiles';
import moveToWorkspace from '@salesforce/apex/selfQAdVWizardManageSubjectController.moveToWorkspace'
import deleteOldFiles from '@salesforce/apex/selfQAdVWizardManageSubjectController.deleteOldFiles'

export default class SelfQAdVWizardAttachmentManager extends LghtAbstract {

    @api confirmCallback;
    @api closeCallback;
    @api caseId;
    @api oldFileId;

    @track attachments = [];

    filesToDelete = []
    fileData;
    fileName;
    fileUploaded = false;


    selectedId;
    selectedType;
    selectedName;
    
    handlerDataGrid;

    showCarica = false;
    showAtt = false;
    scelto = false;

    isDisabledConferma = true;

    connectedCallback(){

        this.init();
        
    }

    chooseCarica(){

        this.showCarica = true;
        this.scelto = true;

    }

    chooseAtt(){

        this.showAtt = true;
        this.scelto = true;

    }

    async deleteFiles(){

        try{

            await deleteOldFiles({fileIds : this.filesToDelete});

        }catch( error ){
            this.alertMessage('Errore', 'Errore gestione file, riprova pi� tardi!');
        }

    }

    async init(){

        var result = await getDocuments({caseId: this.caseId});
        if(result){
            console.log(result);
            this.attachments = result;
        }
        this.hideSpinner();

    }

    get showTable(){

        return this.attachments.length != 0;

    }

    hookDataGrid = (target) => {

        this.handlerDataGrid = target;

    }

    onColumnsDefinition = (columns) => {

        //columns.push({ cellAttributes: { iconName: { fieldName: 'dynamicIcon' }, alignment:'center' }});
        columns.push({ 
            fixedWidth:200,
            type: 'button-icon',
            typeAttributes:
            {
                iconName: 'utility:attach',
                name: 'edit',
                disabled: this.changesMade
            },
            cellAttributes: {
                alignment:'right'
            }
        });

    }

    handleClose(){

        if(this.closeCallback) this.closeCallback();

    }

    handleConfirm(){

        this.showSpinner();
        

        if(this.oldFileId){

            this.filesToDelete.push(this.oldFileId);

        }
        
        if(this.filesToDelete.length != 0){
            this.deleteFiles();
        }

        /*if(this.selectedId && this.selectedType == 'ContentDocumentNew'){

            moveToWorkspace({ 
                
                ContentDocumentId: this.selectedId

            }).then( (result) => {

                this.finalizeConfirm();
                this.hideSpinner();
            
            } ).catch( (error) => {

                this.alertMessage('Errore', 'Errore caricamento documento! Riprova pi� tardi!');
            } )
        }
        else{*/

            this.finalizeConfirm();
            this.hideSpinner();

        //}

    }

    handleAnnulla(){

        if(this.selectedId && this.selectedType == 'ContentDocumentNew'){
            this.filesToDelete.push(this.selectedId);
            this.showSpinner();
            this.deleteFiles().then( ()=>{
                this.handleClose();
            } );
        }
        else{
            this.handleClose();
        }
        

    }

    finalizeConfirm(){

        if(this.confirmCallback){
            var confirmData = {
                ...this.fileData,
                fileId : this.selectedId,
                fileType : this.selectedType
            }
            this.confirmCallback(confirmData);
        }

    }

    openfileUpload(event) {

        const file = event.target.files[0];
        var reader = new FileReader();
        reader.onload = () => {
            var base64 = reader.result.split(',')[1];
            this.fileData = {
                'fileName': file.name,
                'base64': base64
            };
            this.fileName = file.name;
            this.fileUploaded = true;
            this.isDisabledConferma = false;
        }
        reader.readAsDataURL(file);

    }

    handleRowAction = (event) => {
        /*if(!this.canSwitch){
            this.warningMessage('ATTENZIONE','SALVA LE MODIFICHE PRIMA DI ANDARE AVANTI!');
            return;
        }*/
        const action = event.detail.action;
        const row = event.detail.row;
        this.selectedId = row['fileId'];
        this.selectedType = row['fileType'];
        this.selectedName = row['fileName'];
        this.fileData = { fileName: row['fileName'] };
        
        this.isDisabledConferma = false;

    }

    handleUpload = (event) => {

        if(this.selectedId && this.selectedType == 'ContentDocumentNew'){
            this.filesToDelete.push(this.selectedId);
        }
        console.log(this.proxyData(event.detail.files));
        var file = event.detail.files[0];
        this.fileName = file.name;
        this.fileData = {fileName: file.name};
        this.selectedId = file.documentId;
        this.selectedType = 'ContentDocumentNew';
        this.isDisabledConferma = false;
        moveToWorkspace({ 
                
            ContentDocumentId: this.selectedId

        }).then( () => {
            return
        })
    }


}