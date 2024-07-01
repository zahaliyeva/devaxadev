import { LightningElement,track,api } from 'lwc';
import getPickListValues from '@salesforce/apex/lghtIniziativeMarketingCustomViewCTRL.getPickListValues';
import getIniziativeMarketing from '@salesforce/apex/lghtIniziativeMarketingCustomViewCTRL.getIniziativeMarketing';
import getIniziativeMarketingFilterAll from '@salesforce/apex/lghtIniziativeMarketingCustomViewCTRL.getIniziativeMarketingFilterAll';
import setIniziativeMarketingAttiveDesattive from '@salesforce/apex/lghtIniziativeMarketingCustomViewCTRL.setIniziativeMarketingAttiveDesattive';
import Search from '@salesforce/apex/lghtIniziativeMarketingCustomViewCTRL.Search';

const listaCol = [
    { label: 'Code', fieldName: 'CodeComunication',type: 'text' ,sortable: "true"},
    { label: 'Nome Template', fieldName: 'Url',sortable: "true",type: 'url', typeAttributes: { label: { fieldName: 'Name' },target: '_self' } },
    { label: 'Versione', fieldName: 'Versione',type: 'text',sortable: "true" },
    { label: 'Attiva', fieldName: 'Attiva',type: 'boolean' ,sortable: "true"},
    { label: 'Invio Push', fieldName: 'InvioPush',type: 'boolean' ,sortable: "true"},
    { label: 'Visibilità nel centro notifiche', fieldName: 'visibilitaCentroNotif',type: 'boolean' ,sortable: "true"},
    { label: 'Eleggibile per Compagnia', fieldName: 'PerCompany',type: 'text',sortable: "true" }
];

export default class LghtIniziativeMarketingCustomView extends LightningElement {

    @track optionsTipologia;
    @track optionsCanale;
	@track objectName = 'Iniziative_Marketing__c' ;
    @track iniziative = [];
    @track spinner = true;

    @track optionsTipologiaSelected;
    @track optionsReferimentoSelected; 
    @track HeadingError = 'Informazione Iniziativa Marketing';
    @track Error = '';

    @track sortBy;
    @track sortDirection;

    @api temporalvalue

    showModalCreate = false ;
    ShowError = false ;
    columns = listaCol;
    totaleRecords;
    requiredInvioPush = false;
    requiredVisibilitaCentroN = false;

    async connectedCallback() {
            getPickListValues({
                objApiName: this.objectName,
                fieldName: 'Tipologia_Campagna__c'
            })
            .then(data => {
                this.optionsTipologia = data;
            })
            .catch(error => {
                this.displayError(error);
            });
            //call other picklist
            getPickListValues({
                objApiName: this.objectName,
                fieldName: 'Canale__c'
            })
            .then(data => {
                this.optionsCanale = data;
            })
            .catch(error => {
                this.displayError(error);
            });
            //da
            let response = await getIniziativeMarketing().catch(error => {
                this.displayError(error);
            });
            if(response.length > 0)
                this.iniziative.data = response;
            else {
                this.displayError('Lista Iniziativa Marketing vuota');
            }
            this.spinner = false;
    }
    displayError(error) {
        this.ShowError = true;
        this.Error = error ;
	}
    async loadDataFilter (){

        this.spinner = true;

        var attivaCheck = this.template.querySelector('[data-id="Attiva__c"]').checked;
        var tipologiaSelect = this.template.querySelector('[data-id="Tipologia_di_campagna__c"]').value;
        var perCanaleSelect = this.template.querySelector('[data-id="Eligibile_per_Canale__c"]').value;

        let data = await getIniziativeMarketingFilterAll({
            tipologiaSelect: tipologiaSelect,
            perCanale: perCanaleSelect,
            attivaCheck: attivaCheck
        })
        .catch(error => {
            this.displayError(error);
        });

        this.iniziative.data = data;

        this.totaleRecords=data.length;
        this.spinner = false ;
    }

    openmodal() {
        this.showModalCreate = true
    }
    closeModal() {
        this.showModalCreate = false
    } 
    closeError() {
        this.ShowError = false
    } 
    saveMethod() {
        alert('Aqui se crea el nuevo');
    }
    handleSuccess(){
        this.spinner = true;
        this.showModalCreate = false
        this.HeadingError = 'Creazione Iniziativa Marketing';
        this.displayError('L\'Iniziativa Marketing è stata creata correttamente');
        this.spinner = false;  
    }
    handlePushMessageValidation(event){
        console.log(event.target);
        if(event.target.value==true){
            this.requiredInvioPush = true;
        }
        else {
            this.requiredInvioPush = false;
        }
    }
    handleVisibilitaTitoliSottoT(event){
        console.log(event.target);
        if(event.target.value==true){
            this.requiredVisibilitaCentroN = true;
        }
        else {
            this.requiredVisibilitaCentroN = false;
        }
    }
    async handleChange(event){
        this.loadDataFilter();
    }
    handleMessageInput(event){
       var temp = event.target.value.length;
       if(temp >= 255){
        this.template.querySelector('[data-id="error-message"]').setAttribute('style', 'display: block');
        this.template.querySelector('[data-id="error-message"]').setAttribute('style', 'color: red');
        this.template.querySelector('[data-id="save-bottone"]').disabled = true;
       }
       else {
        this.template.querySelector('[data-id="error-message"]').setAttribute('style', 'display: none');
        this.template.querySelector('[data-id="save-bottone"]').disabled = false;
       }

    }
    handleUrlInput(){
        //metodo per nascondere il botone salva in caso il formato URL non serve, logica per 2 campi url non obligatori
        var urlCta = this.template.querySelector('[data-id="url-immagine-value"]').value;
        var urlImmagine = this.template.querySelector('[data-id="url-cta-value"]').value;
        let url = null,url1 = null;
        
        try {
            if (urlCta != null && urlCta != '')
            url = new URL(urlCta);
            if (urlImmagine != null && urlImmagine != '')
            url1 = new URL(urlImmagine);
        } catch (_) {
            //return false;   malformed URL non protocol http :)
            if (urlImmagine != null && urlImmagine != '' && url1 == null){
                this.template.querySelector('[data-id="url-cta"]').setAttribute('style', 'display: block');
                this.template.querySelector('[data-id="url-cta"]').setAttribute('style', 'color: red');
                this.template.querySelector('[data-id="url-immagine"]').setAttribute('style', 'display: none');
            }
            if (urlCta != null && urlCta != ''&& url == null){
                this.template.querySelector('[data-id="url-immagine"]').setAttribute('style', 'display: block');
                this.template.querySelector('[data-id="url-immagine"]').setAttribute('style', 'color: red');
                this.template.querySelector('[data-id="url-cta"]').setAttribute('style', 'display: none');
            }

            this.template.querySelector('[data-id="save-bottone"]').disabled = true;

            return false;
        }
        // if not badformat means is OK
        this.template.querySelector('[data-id="url-cta"]').setAttribute('style', 'display: none');
        this.template.querySelector('[data-id="url-immagine"]').setAttribute('style', 'display: none');
        this.template.querySelector('[data-id="save-bottone"]').disabled = false;

     }
    async attiva_disattiva(){
        this.spinner = true;
        var tableIniziative = this.template.querySelector('[data-id="table-iniziative"]').getSelectedRows();
        let ids = '';
        if(tableIniziative.length > 0 ){
            tableIniziative.forEach(currentItem => {
                ids = ids + ';' + currentItem.id;
              });
            let data = await setIniziativeMarketingAttiveDesattive({
            idsSelect: ids
            })
            .catch(error => {
                this.displayError(error);
            });
            if(data) { 
                this.displayError(data);         
                await this.loadDataFilter();   
            }
        } 
        else {
            this.displayError('Seleziona al meno una iniziativa');
        }
        this.spinner = false;  
    } 
    handleKeyUp(evt) {

        const isEnterKey = evt.keyCode === 13;

        if (isEnterKey ) {
            var stringSearch = evt.target.value;
            var attivaCheck = this.template.querySelector('[data-id="Attiva__c"]').checked;
            var tipologiaSelect = this.template.querySelector('[data-id="Tipologia_di_campagna__c"]').value;
            var perCanaleSelect = this.template.querySelector('[data-id="Eligibile_per_Canale__c"]').value;
            
            Search({
                stringSearch : stringSearch,
                tipologiaSelect: tipologiaSelect,
                perCanale: perCanaleSelect,
                attivaCheck: attivaCheck
            })
            .then(data => {   
                this.iniziative.data = data;
                console.debug('data iniziative filtrata'+JSON.stringify(this.iniziative.data));
            })
            .catch(error => {
                this.displayError(error);
            });

        }
    }
    refreshComponent(event){
        this.spinner = true;
        eval("$A.get('e.force:refreshView').fire();");
        this.spinner = false;
    }
    doSorting(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(this.sortBy, this.sortDirection);
    }
    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.iniziative.data));
        // Return the value stored in the field
        let keyValue = (a) => {
            return a[fieldname];
        };
        // cheking reverse direction
        let isReverse = direction === 'asc' ? 1: -1;
        // sorting data
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';
            // sorting values based on direction
            return isReverse * ((x > y) - (y > x));
        });
        this.iniziative.data = parseData;
    }    
}