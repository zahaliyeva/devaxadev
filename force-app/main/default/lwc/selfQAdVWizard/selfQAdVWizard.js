import { api, track, wire } from 'lwc';
import { LghtAbstract } from 'c/lghtAbstract';
import Init from '@salesforce/apex/SelfQAdVWizardController.init';
import UpdateCaseInfo from '@salesforce/apex/SelfQAdVWizardController.UpdateCaseInfo';
import UpdateDocumentAccountInfo from '@salesforce/apex/SelfQAdVWizardController.UpdateDocumentAccountInfo';
import ConfirmQAdV from '@salesforce/apex/SelfQAdVWizardController.confirmQAdV';

import SetRecordUpdatedByDocumentAccount from '@salesforce/apex/SelfQAdVWizardController.setRecordUpdatedByDocumentAccount';

export default class SelfQAdVWizard extends LghtAbstract {

    @api recordId;
    @api closeCallback;
    
    

    @track confirmHelpText;
    @track saveHelpText;
    @track richiedenteId;
    @track subject;
    @track data = [];
    @track ready = false;
    @track context = {Case:{}, DocumentAccount__c:{}} ;


    currentCase;

    richiedenteIsSoggetto = false;
    changesMade = false;
    recordTypeId;
    caseOK = false;
    richiedenteOK = false;
    validatePolizza = false;

    integrationDone;
    caseForm;
    richiedenteForm;

    canSwitch = true;
    manageSubject = false;
    OperationType ;
    selectedSubject;
    handlerDataGrid;
    //isDisabledSalva = true;
    isDisabledConferma = true;
    formNameRichiedente = 'wizard-qadv-richiedente-view';

    disableInputsWFCL = false;
   

    showConfirmationModal;
    confirmationText;
    confirmationCallback;
    resetPolicy = false;

    connectedCallback(){
        this.initComponent();
    }

    hookDataGrid = (target) => {
        this.handlerDataGrid = target;
    }

    onColumnsDefinition = (columns) => {
        columns.push({ cellAttributes: { iconName: { fieldName: 'dynamicIcon' }, alignment:'center' }});
        columns.push({ 
            type: 'button-icon',
            typeAttributes:
            {
                iconName: 'utility:edit',
                name: 'edit',
                disabled: this.changesMade
            }
        });

        for(var col of columns){
            col.hideDefaultActions = true;
        }
        /*columns.push({ type: 'action', typeAttributes: { rowActions: [{'label': 'Modifica',
        'iconName': 'utility:edit',
        'name': 'edit',
        'disabled':this.changesMade}] } });*/
    }

    get disableAddSubject(){
        if(this.disableInputsWFCL) return true;
        if(this.changesMade) return true;
        if(!this.context) return true;
        
        var richiedente = this.context.DocumentAccount__c;
        
        if(!richiedente) return true;
        return !richiedente.Delegate__c;
        
    }

    get showTable(){
        return this.data.length != 0;
    }

    

    async initComponent(){
        this.showSpinner();
        this.ready = false;
        var result = await Init({caseId : this.recordId});
        console.log("result: ", result)
        if(result != null){
            this.data = result.subjects;
            this.richiedenteId = result.richiedenteId;
            this.disableInputsWFCL = result.disableInputs;
            this.integrationDone = result.integrationDone;
            this.recordTypeId = result.recordTypeId;
        }
        this.ready = true;
        this.hideSpinner();
    }

    get disableInputs(){
        return this.disableInputsWFCL || this.integrationDone;
    }

    onChangeRichiedente = (e, child) => {
        if(child.formLoaded){
            this.isDisabledConferma = true;
            this.changesMade = true;
        }
        else{
            if(this.integrationDone && !this.disableInputsWFCL){
                //inserire qui il richiamo al metodo child.setDisableSingle() passando i campi da riattivare e il parametro disable a false

                //e.g. child.setDisableSingle("Role__c", false);
            }
            this.isDisabledConferma = false;
        }
		//console.log('CAMBIOS-- onChange-- context abajo');	
		this.context = {...this.context, ...e};
        //console.log(this.proxyData(this.context));
        this.canSwitch = false;
        let richiedente = this.context.DocumentAccount__c;
        //console.log(this.proxyData(richiedente));
        /*if(richiedente){
            let isDisabledSalva = this.validateRichiedenteInputData(richiedente);
            this.isDisabledSalva = isDisabledSalva;
        }*/
        this.richiedenteForm = child;

        if(!this.integrationDone && !this.disableInputs ){

            if(!child.formLoaded && richiedente.Role__c.includes("Soggetto") && this.richiedenteId != null){
                this.richiedenteIsSoggetto = true;
            }

            if(child.formLoaded && this.richiedenteId != null && !this.richiedenteIsSoggetto && richiedente.Role__c.includes("Soggetto")){
                richiedente.isActive__c = true
                richiedente.TECH_RequiredFieldsMissing__c = true;
            }

            if(richiedente.SubjectType__c === 'PF'){
                child.setDisableSingle("FirstName__c", false, false);
            }
            else{
                child.setDisableSingle("FirstName__c", true, true);
                richiedente.FirstName__c = "";
            }

            if(!child.formLoaded && richiedente.Delegate__c){
                child.setDisableSingle("DelegateType__c", false, false);
                //Commentato da Dario 05/07/2023
                //child.setDisableSingle("FiscalIdentifier__c", true, false);
                //richiedente.FiscalIdentifier__c = "";
            }
            else if (child.formLoaded && richiedente.Delegate__c){
                child.setDisableSingle("DelegateType__c", false, false);
                //Commentato da Dario 05/07/2023
                //child.setDisableSingle("FiscalIdentifier__c", true, true);
                //Commentato da Dario 05/07/2023
                //richiedente.FiscalIdentifier__c = "";
            }
            else{
                child.setDisableSingle("DelegateType__c", true, true);
                //child.setDisableSingle("FiscalIdentifier__c", false, false);                
                
                richiedente.DelegateType__c = "";
            }

            if(richiedente.DelegateType__c === 'I'){
                child.setDisableSingle("Intermediario__c", false, false);
            }
            else{
                child.setDisableSingle("Intermediario__c", true, true);
                richiedente.Intermediario__c = "";
            }
        }
        
        this.richiedenteOK = child.isFormComplete;
        console.log("richiedenteOK ", this.richiedenteOK)

        /*let fieldMap = {DelegateType__c : !richiedente.Delegate__c};
        console.log(fieldMap);
        child.setDisable(false, fieldMap);*/
        
        

        

	}

    onConfirmValidatePolicy = (e) => {
        console.log("entrato nel confirm");
		this.context.Case = {...this.context.Case, ...e.Case};
        
        this.isDisabledConferma = true
        this.changesMade = true;
        this.resetPolicy = false;
        this.closeValidatePolizza();
    }

    onChange = (e, child) => {
        if(child.formLoaded){
                    
                    console.log(this.proxyData(e.Case));
                    var Case = this.currentCase;
                    var contextCase = this.context.Case;
                    for(var temp in e.Case){

                        console.log(temp);
                        if(e.Case[temp] !== this.currentCase[temp]){
                            if(temp === 'Tipo_Operazione__c' || temp==='CodiceFiscale_PIVA_Contraente__c'){
                                console.log("entrato");
                                e.Case["Compagnia__c"] = null;
                                e.Case["CategoriaPolizza__c"] = null;
                                e.Case["NumeroPolizza__c"] = null;
                                e.Case["NumeroPolizzaFiglia__c"] = null;
                                e.Case["CodiceTariffa__c"] = null;
                                e.Case["DescrizioneTariffa__c"] = null;
                                e.Case["PolicyID__c"] = null;
                                this.resetPolicy = true;
                                
                            }
                        }
                    }
                }
        if(child.formLoaded){
            this.isDisabledConferma = true;
            this.changesMade = true;
        }
        else{
            this.isDisabledConferma = false;
        }

        
            
		console.log('CAMBIOS-- onChange-- context abajo');
		this.context.Case = {...this.context.Case, ...e.Case};
        //console.log(this.proxyData(this.context));
        this.canSwitch = false;
        //console.log(this.proxyData(richiedente));
        /*if(richiedente){
            let isDisabledSalva = this.validateRichiedenteInputData(richiedente);
            this.isDisabledSalva = isDisabledSalva;
        }*/

        this.caseForm = child;
        
        
        /*let fieldMap = {DelegateType__c : !richiedente.Delegate__c};
        console.log(fieldMap);
        child.setDisable(false, fieldMap);*/
        
        this.caseOK = child.isFormComplete;
        console.log("caseOK ", this.caseOK)
        this.currentCase = this.proxyData(this.context.Case);

	}

    get isDisabledSalva(){

        if(!(this.caseOK && this.richiedenteOK)){
            this.saveHelpText = 'Completare i campi richiesti!';
            return true;
        }

        if(!this.context) return true;

        if(this.integrationDone || this.disableInputsWFCL){
            this.saveHelpText = '';
            return true;
        } 

        if(this.context && this.context.Case && this.context.Case.SuppliedEmail){
            if(!this.context.Case.SuppliedEmail.match(/[^\s@]+@[^\s@]+\.[^\s@]+/gi)){
                this.saveHelpText = 'Indirizzo email non valido';
                return true;
            }
        }
        let richiedente = this.context.DocumentAccount__c;
        if(!richiedente) return true;
        
        if(!richiedente.Role__c.includes('Richiedente')){
            this.saveHelpText = 'Non è possibile rimuovere il ruolo Richiedente'
            return true;

        }
        if(this.richiedenteIsSoggetto && !richiedente.Role__c.includes('Soggetto')){
            this.saveHelpText = 'Non è possibile rimuovere il ruolo Soggetto una volta salvato!';
            return true;
        }
        if(!richiedente.Role__c.includes('Soggetto') && !richiedente.Delegate__c){
            this.saveHelpText = 'Un Richiedente non soggetto deve essere Delegato!';
            return true;
        }

        if(!this.policynum){
            this.saveHelpText = 'Inserire i dati della polizza!';
            return true;
        }

        
    }

    handleRowAction = (event) => {
        /*if(!this.canSwitch){
            this.warningMessage('ATTENZIONE','SALVA LE MODIFICHE PRIMA DI ANDARE AVANTI!');
            return;
        }*/
        const action = event.detail.action;
        const row = event.detail.row;
        console.log(action.name);
        switch (action.name) {
            case 'edit':
                console.log(row['Id']);
                this.selectedSubject = row['Id'];
                this.updateDocumentCheckbox(row['Id']);
                this.manageSubject = true;
                break;
        } 
        //aggiornare il componente tabella solamente la tabella ??

    }

    handleCloseSubject = () => {
        this.manageSubject = false;
        this.connectedCallback();
    }

    async updateDocumentCheckbox(docAccountId){

        let result = await SetRecordUpdatedByDocumentAccount({DocAccId: docAccountId}).catch((error) => {
            this.alertMessage('Errore Apertura Modifica Soggetto', error);
        });

    }

    loadOnlySubjectTable(){
        Init({caseId : this.recordId}).then((result)=>{
            if(result != null){
                this.data = result.subjects;
                this.richiedenteId = result.richiedenteId;
                if(result.subjects)
                    this.handlerDataGrid.applyData(result.subjects);
            }
		}).catch((err)=>{
            //this.alertMessage('Error Aggiornamento UI',err.message);	
            console.log(err.message)	
        })
    }



    get showSubjects(){
        return this.richiedenteId != null;
    }

    

    getRowActions = (row, doneCallback) => {
        const actions = [];
        var disable = this.changesMade;
        actions.push({
            'label': 'Modifica',
            'iconName': 'utility:edit',
            'name': 'edit',
            'disabled':disable
        })
        
        // simulate a trip to the server
        setTimeout(() => {
            doneCallback(actions);
        }, 200);
    }

    onLoadDataGrid = (context) => {
        this.data = [...context.data];//this.data = result.subjects;
    }

    addSubject(){
        
        this.showSpinner();
        
        this.manageSubject = true;
        this.selectedSubject = '';
        
        this.hideSpinner();
    }

    

    onValidate = () => {
        
		console.log(this.proxyData(this.context));
		this.showSpinner(false);
		UpdateCaseInfo({
            caseInput:this.context.Case
        }).then((response)=>{

            if(response.isSuccess){
                this.successMessage(response.errorMessage);
                //Commentato da Dario 05/07/2023
                /*if(this.context.DocumentAccount__c.Role__c.includes('Soggetto') && !this.context.DocumentAccount__c.Delegate__c && this.context.DocumentAccount__c.Survey_Type__c != 'BEN'){
                    this.context.DocumentAccount__c.FiscalIdentifier__c = this.context.Case.CodiceFiscale_PIVA_Contraente__c;
                }*/
                UpdateDocumentAccountInfo({
                    param:{
                    subjectInput:this.context.DocumentAccount__c,
                    caseId:this.recordId,
                    RuoloInput:'Richiedente',
                    richiedenteId:this.richiedenteId
                    }
                }).then((response1)=>{
                    if(!response1.isSuccess){
                        this.warningMessage('Error Aggiornamento ',response1.errorMessage);
                    }      
                    else if(response1.isSuccess){
                        this.successMessage(response1.errorMessage);
                        this.richiedenteId = response1.richiedenteId;
                        this.isDisabledConferma = false;
                        this.changesMade = false;
                        console.log('Prueba-'+ response1.richiedenteId)
                    }
                }).catch((err)=>{
                    this.alertMessage('Error Aggiornamento Server ',err.message);		
                }).finally(()=>{
                    this.connectedCallback();
                })
            }
                
			if(!response.isSuccess) 
                this.warningMessage('Error Aggiornamento Pratica Documentale sul Case',err.message);
                
		}).catch((err)=>{
				this.alertMessage('Error Aggiornamento Pratica Documentale sul Case',err.message);
                this.hideSpinner();		
		}).finally(()=>{
			//dopo aggiornare case aggiorno subito il Richiedente nel object DocumentAccount__c 
                
            
		})
	}

    get disabledConferma(){

        if(this.integrationDone && !this.disableInputsWFCL){
            return false;
        }
        if(this.isDisabledSalva){
            this.confirmHelpText = "";
            return true;
        }

        if(!this.context){
            this.confirmHelpText = "É necessario salvare i dati prima di confermare la pratica";
            return true;
        } 
        if(!this.context.DocumentAccount__c) {
            this.confirmHelpText = "É necessario salvare i dati prima di confermare la pratica";
            return true;
        }
        if(this.isDisabledConferma){
            this.confirmHelpText = "É necessario salvare i dati prima di confermare la pratica";
            return true;
        }
        if(this.context.DocumentAccount__c.TECH_RequiredFieldsMissing__c){
            this.confirmHelpText = "I dati del soggetto non sono sufficienti per confermare la pratica";
            return true;
        }
        if(this.data.length == 0){
            this.confirmHelpText = "É necessario inserire almeno un soggetto";
            return true;
        }
        else{
            if(this.context.DocumentAccount__c.Delegate__c){
                if(this.data.filter( (temp)=>{return temp.isActive__c && !temp.Role__c.includes('Richiedente')} ).length == 0){
                    this.confirmHelpText = "Richiedente Delegato: É necessario inserire almeno un altro soggetto attivo";
                    return true;
                }
            }
            else{
                if(!this.context.DocumentAccount__c.Role__c.includes('Soggetto')){
                    this.confirmHelpText = "Richiedente non Delegato: il richiedente deve essere un soggetto";
                    return true;
                }
                if(this.data.filter( (temp)=>{return temp.isActive__c && !temp.Role__c.includes('Richiedente')} ).length > 0){
                    this.confirmHelpText = "Richiedente non Delegato: non può esserci un soggetto attivo diverso dal richiedente";
                    return true;
                }
            }
            for(var d of this.data){
                if(d.isActive__c){
                    this.confirmHelpText = '';
                    return false;
                }
            }
            this.confirmHelpText = "É richiesta la presenza di almeno un soggetto attivo!";
            return true;
        }
        
    }

    get showHelpText(){
        if(this.confirmHelpText) return true;
        return false;
    }


    onValidatePolizza = () => {
        this.warningMessage('DEMO','ANCORA IN SVILUPPO :)');
        console.log(this.proxyData(this.context));	
	}

    async getSoggetti(){
        this.hideSpinner();
        //this.data = [{"SubjectType__c":"Prova"},{"SubjectType__c":"Prova", "isActive__c":true, "dynamicIcon":"utility:announcement"}];
    }

    showValidatePolizza(){
        this.validatePolizza = true;
    }
    
    closeValidatePolizza = () => {
       this.validatePolizza = false; 
    }

    closeConfirmationModal = () =>{
        this.showConfirmationModal = false;
        this.confirmationText = '';
    }

    onCloseClick(){
        
        this.confirmationText = 'Attenzione, stai per uscire dal Wizard. Tutte le modifiche non salvate andranno perse';
        this.confirmationCallback = this.fireCloseEvent;
        this.showConfirmationModal = true;
    }

    onConfirmClick(){
        
        if(this.integrationDone && !this.disableInputsWFCL){
            this.successMessage('Pratica confermata con successo!');
            this.fireCloseEvent();
        }
        else{
        this.confirmationText = 'Attenzione, stai finalizzando la pratica.';
        this.confirmationCallback = this.handleConfirm;
        this.showConfirmationModal = true;
    }

    }

    handleConfirm = () => {
        this.showSpinner();
        this.showConfirmationModal = false;
        
        ConfirmQAdV(
            {
                caseInput: this.context.Case,
                richiedenteInput: this.context.DocumentAccount__c
            }
        ).then( (result) => {
            console.log(result);
            if(result.isSuccess){
                this.successMessage('Pratica confermata con successo!');
                this.fireCloseEvent();
            }
            else{
                this.alertMessage(result.errorMessage);
            }
        }).finally(()=>{
            this.hideSpinner();
        });

    }

    fireCloseEvent = () => {
        //this.showConfirmationModal = false;
        const closeclickedevt = new CustomEvent('closeclicked', {
            detail: {close : true} ,
        });

         // Fire the custom event
         this.dispatchEvent(closeclickedevt);
    }
    
    get policynum(){
        if(!this.context) return ""
        if(!this.context.Case) return ""
        if(this.context.Case.NumeroPolizzaFiglia__c){
            return this.context.Case.NumeroPolizza__c + '' + this.context.Case.NumeroPolizzaFiglia__c;
        }
        else{
            return this.context.Case.NumeroPolizza__c
        }
    }

}