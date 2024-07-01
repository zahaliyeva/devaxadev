import { api, track, wire } from 'lwc';
import { LghtAbstract } from 'c/lghtAbstract';
import GetConfigurationList from  '@salesforce/apex/DhValidatePolicyController.getConfigurationList';
import policyIdFormat from '@salesforce/apex/DhValidatePolicyController.policyIdFormat';
import validatePolicy from '@salesforce/apex/DhValidatePolicyController.validatePolicy';

export default class DhValidatePolicy extends LghtAbstract {

    @api caseId;
    @api tipoOperazione;
    @track context;

    @api closeCallback;
    @api confirmCallback;
    @api recordTypeId;

    @api caseData = {}
    @api disableInputs = false
    //formCompleted = false;
    @api reset = false;

    disableValida = true;
    
    formObject;
    integrationDone = false;
    ready = false;
    validationList = [];
    numeroPolizzaOk = true;
    numeroPolizzaFigliaOk = true;
    disableValidaHelpText;
    disableCodiceTariffa = true;

    get isDisabledConferma(){
        if(this.disableInputs) return true;
        if(!this.context) return true;
        if(!this.formObject) return true;
        if(!this.context.Case) return true;
        if(!this.context.Case.CodiceTariffa__c) return true;
        if(!this.formObject.isFormComplete) return true;
        return false;
    }

    get isDisabledValida(){
        if(this.disableInputs) return true;
        if(this.integrationDone) {
            this.disableValidaHelpText = "";
            return true
        }
        if(!this.numeroPolizzaOk){
            
            return true;
        }
        if(!this.numeroPolizzaFigliaOk){
            return true;
        }
        
        if(this.caseData.Tipo_Operazione__c === 'G'){ //Sinistro/Prestazione Pensionistica
            this.disableValidaHelpText = "";
            this.disableCodiceTariffa = this.disableInputs;
            return true;
        }
        if(this.disableValida)
            this.disableValidaHelpText = "Compilare i campi richiesti!";
        return this.disableValida;
    }

    async getValidationList(){
        var result = await GetConfigurationList();
        if(result){
            console.log(result);
            this.validationList = result;
        }
        else{
            this.validationList = [];
        }
        this.ready = true;
        this.hideSpinner();
    }

    connectedCallback(){

        this.context = {};
        this.getValidationList();
        this.context.Case = { ...this.proxyData(this.caseData)};
        
    }

    onChange = (e, child) => {
        this.context = {... this.context, ...e};
        this.formObject = child;
        var Case = this.context.Case;
        console.log("reset policy: ", this.reset)
        if(child.formLoaded){
            if(this.caseData.Tipo_Operazione__c != 'G'){
                Case.CodiceTariffa__c = null;
                Case.DescrizioneTariffa__c = null;
                Case.DIH_Policy_Id__c = null;
            }
            
            this.integrationDone = false;
        }
        else if(this.reset){
            this.formObject.updateData({
                Compagnia__c: null,
                CategoriaPolizza__c: null,
                NumeroPolizzaFiglia__c: null,
                NumeroPolizza__c: null,
                CodiceTariffa__c: null,
                DescrizioneTariffa__c: null,
            });
        }
        if(Case.CategoriaPolizza__c === '21 - Collettiva'){
            child.setDisableSingle('NumeroPolizzaFiglia__c', false, false);
        }
        else{
            child.setDisableSingle('NumeroPolizzaFiglia__c', true, true);
            Case.NumeroPolizzaFiglia__c = null;
        }
        console.log(this.proxyData(Case));
        this.validationList.forEach( (temp) => {
            
                if(Case.CategoriaPolizza__c === temp.CategoriaPolizza__c && Case.Compagnia__c === temp.CodiceCompagnia__c){
                    console.log("trovatoo! temp: ", temp);
                    if(temp.lpadPolizza__c !== null){
                        if(Case.NumeroPolizza__c){
                            
                            this.numeroPolizzaOk = Case.NumeroPolizza__c.length <= temp.lpadPolizza__c;
                            if(!this.numeroPolizzaOk){
                                this.disableValidaHelpText = 'Il numero Polizza non può superare la lunghezza di ' + temp.lpadPolizza__c + ' caratteri';
                            }
                        }
                    }
                    if(temp.lpadPolizzaFiglio__c !== null){
                        if(Case.NumeroPolizzaFiglia__c){

                            this.numeroPolizzaFigliaOk = Case.NumeroPolizzaFiglia__c.length <= temp.lpadPolizzaFiglio__c;
                            if(!this.numeroPolizzaFigliaOk){
                                this.disableValidaHelpText = 'Il numero Polizza figlia non può superare la lunghezza di ' + temp.lpadPolizzaFiglio__c + ' caratteri';
                            }
                        }
                    }
                    return;
                }
            
        } );
        

        this.disableValida = !child.isFormComplete;
    }

    
    

    handleClose(){
        if(this.closeCallback){ this.closeCallback() };
    }

    async handleConfirm(){
        //call DH service

        if(!this.integrationDone){
            this.showSpinner();
            var result = await policyIdFormat({caseInput : this.context.Case});
            this.integrationDone = true;
            if(result.isSuccess){
                var tempCase = {
                DIH_Policy_Id__c : result.result
                };

                this.context.Case = {...this.context.Case, ...tempCase}
                
            }
            
            else{
                if(result.result){
                    var tempCase = {
                        DIH_Policy_Id__c : result.result
                    };
        
                    this.context.Case = {...this.context.Case, ...tempCase}
                    
                }
                this.alertMessage("Errore!", result.errorMessage);
                this.disableCodiceTariffa = false;
            }
        }

        this.hideSpinner();
        if(this.confirmCallback) {
            console.log("callback defined");
            this.confirmCallback(this.context);
            
        }
    }

    async handleValidate(){
        //richiamo servizio esterno
        this.showSpinner();
        var result = await validatePolicy({caseInput : this.context.Case});
        this.integrationDone = true;
        if(result.isSuccess){
            if(result.codTariffa != null){
                var tempCase = {
                    CodiceTariffa__c: result.codTariffa,
                    DescrizioneTariffa__c: result.descrizione,
                    DIH_Policy_Id__c : result.result,
                    };
            }else {
                var tempCase = {
                    DIH_Policy_Id__c : result.result
                };
                this.successMessage("Errore di validazione!", result.errorMessage);
                this.disableCodiceTariffa = false;
            }

            this.context.Case = {...this.context.Case, ...tempCase}

        }
        else{
            if(result.result){
                var tempCase = {
                    DIH_Policy_Id__c : result.result
                };
    
                this.context.Case = {...this.context.Case, ...tempCase}
                
            }    
            this.alertMessage("Errore!", result.errorMessage);
            this.disableCodiceTariffa = false;
        }
        
        this.hideSpinner();
        
    }

    handleChangeCodice(e){
        this.context.Case.CodiceTariffa__c = e.target.value;
    }

}