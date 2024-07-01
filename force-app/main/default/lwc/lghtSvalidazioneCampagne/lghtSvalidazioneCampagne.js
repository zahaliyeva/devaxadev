import { LightningElement,track } from 'lwc';
import modificaAdessione_Incl_or_esclude from "@salesforce/apex/SvalidazioneCampagneCTRL.modificaAdessione_Incl_or_esclude";
import validaPagina from "@salesforce/apex/SvalidazioneCampagneCTRL.validaPagina";
import getCampaignMembersFilterAll from "@salesforce/apex/SvalidazioneCampagneCTRL.getCampaignMembersFilterAll";
import getListCampaignForRT from "@salesforce/apex/SvalidazioneCampagneCTRL.getListCampaignForRT";
import getListNodesByUser from "@salesforce/apex/SvalidazioneCampagneCTRL.getListNodesByUser";
import getListNodoOmniaByCampaign from "@salesforce/apex/SvalidazioneCampagneCTRL.getListNodoOmniaByCampaign";

const listaCol = [
    { label: 'CLIENTE', fieldName: 'Name',type: 'text',sortable: "true" },
    { label: 'DATA CREAZIONE CRM', fieldName: 'dataCreazione',type: 'date',sortable: "true" },
    { label: 'NODO', fieldName: 'Nodes',type: 'text',sortable: "true" },
    { label: 'CODICE OMNIA', fieldName: 'CodiceOmnia',type: 'text',sortable: "true" },
    { label: 'NOMINATIVO OMNIA', fieldName: 'NominativoOmnia',type: 'text',sortable: "true" },
    { label: 'STATO ADESIONE', fieldName: 'Status',type: 'text' ,sortable: "true" },
    { label: 'CAMPAGNA ESCLUSA', fieldName: 'CampagnaEsclusa',type: 'text' ,sortable: "true" },
    { label: 'DATA ULTIMA LAVORAZIONE', fieldName: 'dataUltimaModifica',type: 'date',sortable: "true" }
];

export default class LghtSvalidazioneCampagne extends LightningElement {


    
	@track campagnaName = 'Campaign_init' ;
    @track spinner = false; // per caricamento 
    @track spinnerTable = false;// rimane in secondo piano in previw della tabella
    @track idCampagna= 'null';
    @track isOperation_save_or_validate = null;//per utilizare lo stesso modal di risposta null = nessuna x default

    @track HeadingText = 'Informazione Campagne';
    @track Error = '';
    //picklist options
    @track optionsCampagneComerciali;
    @track optionsCampagneinformative;
    @track optionsNodiVisibilita;
    @track optionsNodoOmnia;
    @track optionsPrivacy;

    @track showPopL = false;
    @track showPopR = false;

    // JS Properties 
    pageSizeOptions = [10, 25, 50, 75, 100,200]; //Page size options
    @track records = []; //All records available in the data table
    totalRecords = 0; //Total no.of records
    pageSize; //No.of records to be displayed per page
    totalPages; //Total no.of pages
    pageNumber = 1; //Page number    
    @track recordsToDisplay = []; //Records to be displayed on the page
    

    @track sortBy;
    @track sortDirection;

    showModalCreate = false ;
    ShowError = false ;
    Showinfo = false ;
    Nondata = false ;
    columns = listaCol;
    selectedIds = null;
    selectedIdsAfter = [];
    
    connectedCallback() {

        this.spinner = true;
        this.picklistAsyn();
        this.spinner = false;

    }
    displayError(error) {
        this.HeadingText = 'Attenzione';
        this.ShowError = true;
        this.Textbody = error ;
	}
    displayInfo(text) {
        this.HeadingText = 'Conferma';
        this.Showinfo = true;
        this.Textbody = text ;
	}
    openmodal() {
        this.showModalCreate = true
    }
    closeModal() {
        this.showModalCreate = false
    } 
    closeError() {
        this.ShowError = false;
        this.Showinfo = false;
    } 
    doSorting(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(this.sortBy, this.sortDirection);
    }
    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.records));
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
        this.records = parseData;
        this.totalRecords = this.records.length; // update total records count                 
        this.pageSize = this.pageSizeOptions[0]; //set pageSize with default value as first option
        this.paginationHelper();
    }  
    async handleChange(event){

        this.spinnerTable = true;
        var valueEvent = event.target.value;
        var onlyOnePath = false;
        //campagne
        var campComerciali = this.template.querySelector('[data-id="CampagneCommercialiSelect"]').value;
        var campInformative = this.template.querySelector('[data-id="CampagneInformativeSelect"]').value;

        console.debug('All values on the moment campCom->'+campComerciali +' camInfo - '+campInformative);

        if(valueEvent == campComerciali && valueEvent!= 'None'){
            this.template.querySelector('[data-id="CampagneInformativeSelect"]').value = 'None';
            this.idCampagna = valueEvent;
            onlyOnePath = true;
        }else if (valueEvent == campInformative && valueEvent!= 'None'){
            this.template.querySelector('[data-id="CampagneCommercialiSelect"]').value = 'None';
            this.idCampagna = valueEvent;
            onlyOnePath = true;
        }else if (campComerciali==campInformative && campInformative=='None'){
            this.idCampagna = 'null';
            console.debug('Messagio nel front END per Select una campagna');
            this.spinnerTable = false;
            this.resetAll();
            return;
        }
        if (this.idCampagna != null || onlyOnePath){
            this.picklistNodes();
            this.attivateAll();
            await this.dataLoadFilter();
        }

        this.spinnerTable = false;

    }

    async dataLoadFilter(){
        var NodidiVisibilitaSelect = this.template.querySelector('[data-id="NodidiVisibilitaSelect"]').value;
        var NodoOmniaSelect = this.template.querySelector('[data-id="NodoOmniaSelect"]').value;
        var PrivacySelect = this.template.querySelector('[data-id="privacySelect"]').value;
        var dataInit = this.template.querySelector('[data-id="dataini"]').value;
        var dataEnd = this.template.querySelector('[data-id="dataend"]').value;
        var pageSizeSelected = this.template.querySelector('[data-id="pageSizeOptID"]').value;

        let data = await getCampaignMembersFilterAll({
            idCampagna: this.idCampagna,
            NodoAgency :NodidiVisibilitaSelect ,
            NodoOmnia :NodoOmniaSelect,
            Privacy :PrivacySelect,
            dataIniCliente:dataInit,
            dataEndCliente:dataEnd
        }).catch(error => {
            console.log('Error Filtro' + error);
            this.displayInfo(error);
        });

            // aggiunto perche ritorna sempre 1 pure se non ci sono records :(
            if(data == null || (data.length==1 && data[0].Name == undefined)){
                data = [];
                this.Nondata = true;
                this.records = data;
                this.totalRecords = data.length; // update total records count                 
                this.pageSize = pageSizeSelected; //set pageSize with default value as first option
                this.paginationHelper();
            } else {
                this.records = data;
                this.totalRecords = data.length; // update total records count                 
                this.pageSize = pageSizeSelected; //set pageSize with default value as first option
                this.paginationHelper();
                if(data.length==0)
                    this.Nondata = true;
                else 
                    this.Nondata = false; 
            }
    }

   
    async picklistAsyn(){
        this.optionsCampagneComerciali = await getListCampaignForRT({
            developerNameRT: 'Marketing_campaign'
        }).catch(error => {
            console.log('Error lista Campagne' + error);
            this.displayInfo(error);
        });
        this.optionsCampagneinformative = await getListCampaignForRT({
            developerNameRT: 'Informative_Campaign'
        }).catch(error => {
            console.log('Error lista Campagne' + error);
            this.displayInfo(error);
        });
    }

    async picklistNodes(){
        this.optionsNodiVisibilita = await getListNodesByUser({
        }).catch(error => {
            console.log('Error lista Nodos' + error);
            this.displayInfo(error);
        });
        
        this.optionsNodoOmnia = await getListNodoOmniaByCampaign({
            idCampaign:this.idCampagna
        }).catch(error => {
            console.log('Error Lista Omnia' + error);
            this.displayInfo(error);
        });        
    }

    resetAll(){
        console.debug('Reset ALLLL');
        this.template.querySelector('[data-id="CampagneCommercialiSelect"]').value = 'None';
        this.template.querySelector('[data-id="CampagneInformativeSelect"]').value= 'None';
        //others filters
        this.template.querySelector('[data-id="NodidiVisibilitaSelect"]').value= 'None';
        this.template.querySelector('[data-id="NodidiVisibilitaSelect"]').setAttribute('disabled', '');
        this.template.querySelector('[data-id="NodoOmniaSelect"]').value= 'None';
        this.template.querySelector('[data-id="NodoOmniaSelect"]').setAttribute('disabled', '');
        this.template.querySelector('[data-id="privacySelect"]').value= 'None';
        this.template.querySelector('[data-id="privacySelect"]').setAttribute('disabled', '');
        this.template.querySelector('[data-id="dataini"]').value= '1900-01-01';
        this.template.querySelector('[data-id="dataini"]').disabled=true;     
        this.template.querySelector('[data-id="dataend"]').value= '2100-12-12';
        this.template.querySelector('[data-id="dataend"]').disabled=true;
        //data
        this.records = [];
        this.totalRecords = 0; // update total records count                 
        this.pageSize = this.pageSizeOptions[0]; //set pageSize with default value as first option
        this.paginationHelper();
        this.Nondata = true;
        //this.connectedCallback();

    }

    attivateAll(){
        //others filters
        this.template.querySelector('[data-id="NodidiVisibilitaSelect"]').removeAttribute('disabled');
        this.template.querySelector('[data-id="NodoOmniaSelect"]').removeAttribute('disabled');
        this.template.querySelector('[data-id="privacySelect"]').removeAttribute('disabled');
        this.template.querySelector('[data-id="dataini"]').disabled=false;      
        this.template.querySelector('[data-id="dataend"]').disabled=false;
    }

    async closeOK(){
        if(this.isOperation_save_or_validate==true){
            this.saveRecords();
            this.isOperation_save_or_validate = null;
            this.closeError();
        }
        else if(this.isOperation_save_or_validate==false){
            await this.validaPaginaDataBase();
            this.isOperation_save_or_validate = null;            
            this.closeError();
        }
        else {
            console.debug(this.isOperation_save_or_validate+'normal close operation');
            this.closeError();
        }
        this.selectedIdsAfter = [];
    }

    getSelectedRec() {

        var selectedRecords =  this.template.querySelector('[data-id="table-campagne"]').getSelectedRows();

        if(selectedRecords.length > 0){
            if(selectedRecords.length>10000){
                //flusso con asyncro Apex
                this.displayError('Si possono lavorare solamente 10 000 per volta.');
            } 
            else { //flusso normale

                this.isOperation_save_or_validate = true; // save = true ; validate = false

                let ids = '';
                selectedRecords.forEach(currentItem => {
                    ids = ids + ';' + currentItem.Id;
                });
                this.selectedIds = ids;//   .replace(/^,/, '');

                this.displayInfo('Con la seguente operazione verrà applicata la selezione effettuata a tutti i clienti selezionati. Si desidera procedere con l’operazione?');
            }
        }//seleziona minimo 1->
        else {
            this.displayError('Selezionare almeno un cliente');
        }
    }
    validaPagina(){

    if(this.recordsToDisplay.length==0){
        this.displayError('Non ci sono clienti');
    } 
    else {
        this.isOperation_save_or_validate= false;
        let ids = '';
        this.recordsToDisplay.forEach(currentItem => {
            ids = ids + ';' + currentItem.Id;
        });
        this.selectedIds = ids;//   .replace(/^,/, '');
        this.displayInfo('Con la seguente operazione tutti i clienti (nella pagina) verrano validati. Si desidera procedere con l’operazione?');
    }


    }
    async validaPaginaDataBase(){
        validaPagina({
            IdsCampaignmembersSelected : this.selectedIds
        })
        .then(data => {
            //this.displayInfo(data);
            this.dataLoadFilter();
        })
        .catch(error => {
            console.log('Error Validazione Pag' + error);
            this.displayInfo(error);
        });
    }
    async saveRecords(){
        modificaAdessione_Incl_or_esclude({
            IdsCampaignmembersSelected : this.selectedIds,
            CampaignId : this.idCampagna
        })
        .then(data => {
            //this.displayInfo(data);
            this.dataLoadFilter();
        })
        .catch(error => {
            console.log('Error Save Records' + error);
            this.displayInfo(error);
        });
    }

    get bDisableFirst() {
        return this.pageNumber == 1;
    }
    get bDisableLast() {
        return this.pageNumber == this.totalPages;
    }

    handleRecordsPerPage(event) {
        this.pageSize = event.target.value;
        this.paginationHelper();
    }
    previousPage() {
        this.pageNumber = this.pageNumber - 1;
        this.paginationHelper();
    }
    nextPage() {
        this.pageNumber = this.pageNumber + 1;
        this.paginationHelper();
    }
    firstPage() {
        this.pageNumber = 1;
        this.paginationHelper();
    }
    lastPage() {
        this.pageNumber = this.totalPages;
        this.paginationHelper();
    }
    // JS function to handel pagination logic 
    paginationHelper() {
        this.recordsToDisplay = [];
        // calculate total pages
        this.totalPages = Math.ceil(this.totalRecords / this.pageSize);
        // set page number 
        if (this.pageNumber <= 1) {
            this.pageNumber = 1;
        } else if (this.pageNumber >= this.totalPages) {
            this.pageNumber = this.totalPages;
        }
        // set records to display on current page 
        for (let i = (this.pageNumber - 1) * this.pageSize; i < this.pageNumber * this.pageSize; i++) {
            if (i === this.totalRecords) {
                break;
            }
            this.recordsToDisplay.push(this.records[i]);
        }
        //aggiunto forzando il array Ids ad aggiornasi dopo il next or previous
        this.selectedIdsAfter = {};
    }
    onHoverR()  {
        this.showPopR = true; 
    }
    onHoverL()  {
        this.showPopL = true; 
    }
    onOut()  {
        this.showPopR = false;
        this.showPopL = false;
    }
}