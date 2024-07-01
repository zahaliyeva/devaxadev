import { api,track } from "lwc";

import { loadStyle } from 'lightning/platformResourceLoader';
import MobilityEngine from '@salesforce/resourceUrl/mobilityDashboardAnalytics';
import createCampaign from '@salesforce/apex/MobilityCampaignsByPushNotification.createCampaign';
import createCampaignMembers from '@salesforce/apex/MobilityCampaignsByPushNotification.createCampaignMembers';
import getDisponibilitaFromNode from '@salesforce/apex/MobilityCampaignsByPushNotification.getDisponibilitaFromNode';
import updateCampagnaFinale from '@salesforce/apex/MobilityCampaignsByPushNotification.updateCampagnaFinale';
import getMessageStatusFromNode from '@salesforce/apex/MobilityCampaignsByPushNotification.getMessageStatusFromNode';
import InitRecordIniziativaMkt from '@salesforce/apex/MobilityDashboardUtility.InitRecordIniziativaMkt';


import { DataGridModel } from "c/dataGridModel";
import getPagination from "@salesforce/apex/mobilityDashboardPaginationController.getPagination";
import {
	MobilityAbstract
} from 'c/mobilityAbstract';

export default class TcrmModaleConTabella  extends MobilityAbstract {


  @track tabledata = {}
  @track tabledataNoSelect = {}
  selectedRecordId = null;
  campaignName;
  @api params;
  campaignId;

  @api DynamicLabels;
  @api DynamicColumns;
  @api CallerType;
  @api CommunicationCode;

  dataLimite = new Date();
  messaggiRimanenti;

  showResultModal = false
  showOrariModal = false
  showChiusuraModal = false
  //preview Iniziativa
  showIniziativaDetail = false 
  title;
  description;
  iframeUrl;
  previewEmail;
  previewShortMessage;
  previewMessage;
  //modale risultato
  modalType
  //bread
  componentView = 'mobilityPushHomepage';
  requestChiusura
  requestCambiOrari

  primary
  back
  replaceVariables

  close;

  validoDal=new Date()
  validoAl=new Date()
  fullSelection;
  selectionCompleted = false;
  campaignName='';
  campaignDescription='';
  data;
  root;
  disableDescription = false;
  showDeleteModal = false;
  loaded = false;

  results_temp;

  selectedList = []
  // All existing rows
  allData = []
  // All selected Id values
  allSelectedRows = new Set()
	// Number of Selected Rows
	nSelected = 0;
  // Data length
  count;
  // Current page index
  pageNumber = 0
  // Current page selected Id values
  selectedRows = {}
  // Current page data rows
  pageData = []
  // Column display
  columns = [
		
    { label: 'NDG', fieldName: 'NDG'},
    { label: 'Nome Cognome', fieldName: 'Name'},
		{ label: 'CF/PIVA', fieldName: 'CF_PIVA'},
    { label: 'Sottonodo visibilità', fieldName: 'Nodes'},
    { label: 'Nodo Omnia', fieldName: 'CodiceOmnia'},
		{ label: 'Contatto email', fieldName: 'EmailMasterAAI'}, 
		{ label: 'Data ultimo invio', fieldName: 'DataUltimoInvio'},
    { label: 'Prossima scadenza', fieldName: 'Scadenza prossima'}
];

pagination;
filtered = false;

changeCallback = () =>{



}

filterName = [];
filterNode = [];

generateFilterList(field){
  var filterSet = new Set();

  this.results.forEach( (element) => {
      if(element[field]){
        filterSet.add(element[field]);
      }
    }
  );

    return [... filterSet].toSorted(
      (a, b) => {
        if(a>b) return 1;
        else if (a<b) return -1;
        return 0;
      }
    )

}
get optionsName() {
  return this.generateFilterList('Name');
}

get optionsNode() {
  return this.generateFilterList('Nodes');
}

handleFilterName(filter) {
  this.filterName = filter.detail;
  this.filtered = false;
  //console.log()
  this.tabledata.setFilterDirect('Name', [...filter.detail]);
}

handleFilterNode(filter) {
  this.filterNode = filter.detail;
  this.filtered = false;
  this.tabledata.setFilterDirect('Nodes', [...filter.detail]);
}

reloadTableData(){
  
  let table = this.StartingTableData;

  this.tabledata = new DataGridModel(table);
  //this.tabledata.isVisibleFilter = true;
  //this.tabledataNoSelect.isVisibleFilter = true;
  this.tabledata.preLoadCallback = (instance) => {
    
    console.log('preLoad');
    instance.cleanSelect = () => {};
    instance.updateSelect = () => {};
    if(this.loaded){
      this.selection = instance.selectData;
    }
    
    
  };
  this.tabledata.loadCallback = (instance, result) => {
      if(!this.loaded){
        this.selectAll();
        instance.filters = null;
      }
      else{

        instance.selectData = this.selection;
      }
      this.loaded = true;
      this.showModal = true;
      this.showNoData(result.length === 0);
      
      this.hideSpinner();
  }
  this.tabledata.load();
  
}

reloadTableDataNoSelect(){
  let tableNoSelect = this.StartingTableDataNoSelect;
  this.tabledataNoSelect = new DataGridModel(tableNoSelect);
  this.tabledataNoSelect.loadCallback = (instance, result) => {
    //console.log("pagerdata",this.tabledata);
    this.hideSpinner();
    console.log("result no select: ", result)
    this.showNoData(result.length === 0);
  }
  this.tabledataNoSelect.load();

}

get selectedNum (){
  if(!this.tabledata) return 0;
  if(!this.tabledata.listSelected) return 0;
  return this.tabledata.listSelected.length.toLocaleString();
}

get messagesToBeSent (){
  if(!this.tabledata) return 0;
  if(!this.data) return 0;
  if(!this.tabledata.listSelected) return 0;

  if(!this.data.iniziativaScelta) return 0;

  return (this.tabledata.listSelected.length * (this.data.iniziativaScelta.Invio_push__c=='true' ? 2 : 1));
}

get messagesToBeSentLocal (){
  return this.messagesToBeSent.toLocaleString()
}

get showCounters(){
  if(!this.data) return false;
  if(!this.data.iniziativaScelta) return false;
  return true;
}



get shouldUpdate () {
  if(this.results_temp !== this.results && this.tabledataNoSelect) {
    this.reloadTableDataNoSelect();
    this.results_temp = this.results;
    
   }
   return this.results !== this.results_temp;
}

get updateTable(){
  console.log(this.results.length)
}

renderedCallback(){
  this.root= this.template.querySelector('.datePicker')
}

changeCampaign(evt){
  this.campaignName = evt.target.value;
}

changeCampaignDescription(evt){
  this.campaignDescription = evt.target.value;
}

get buttonLabel(){
  if(!this.data) return "Invia Comunicazione"
  if(!this.data.tipologiaScelta) return "Invia Comunicazione"
  return this.data.tipologiaScelta.With_Message__c ? "Invia Comunicazione" : "Crea Campagna"
}

getResults = async(config) => {
  var toRet;
      var els = [...this.results];
      //console.log(els)
      //console.log(JSON.parse(JSON.stringify(config)));
      if(config.filters){
              let filtersNames = Object.keys(config.filters);
        let filters = {};
        for(let item of filtersNames){
          filters[item] = [...config.filters[item]];
        }
              els = els.filter( (element) => {
                for(let item of filtersNames){
                  //let filter = [... config.filters[item]]
                  if(!filters[item].includes(element[item])) return false
                }
                return true;
              })
            }
            

      toRet = await getPagination({
          page: config.page,
          perPage:config.perPage,
          total:els.length
      });

      var cols = [];
      var labels = {};
      for(var i of this.columns){
        cols.push(i.fieldName);
        labels[i.fieldName] = i.label;
      }
      
      
      if(config.orderName && config.orderField){
        if(config.orderName === 'ASC'){
          els = els.toSorted((a,b) => {
            
            if(!a[config.orderField]) return -1;
            if(!b[config.orderField]) return 1;
           if(a[config.orderField] > b[config.orderField]){  return 1; }
           else if(a[config.orderField] < b[config.orderField]) { return -1; }
           return 0;
          })
        }
        else{
          els = els.toSorted((a,b) => {
            if(!a[config.orderField]) return 1;
            if(!b[config.orderField]) return -1;
            if(a[config.orderField] < b[config.orderField]) return 1;
            else if(a[config.orderField] > b[config.orderField]) return -1;
            return 0;
           })
        }
      }
      
      toRet.columns = cols;
      toRet.labels = labels;
      toRet.elementsCached = els;
      toRet.elements = els.slice(toRet.startPage, toRet.endPage);
      if(!toRet.selectData){

        toRet.selectData = {}
        
      }
      if(this.tabledata && this.tabledata.selectData){
        toRet.selectData = this.tabledata.selectData;
      }
      if(this.selectionCompleted){
        toRet.selectData = this.fullSelection
      }

      
      
      /*for(let el of this.results){
        
        toRet.selectData[el.Id] = true;
      }*/
      
      toRet.length = toRet.elements.length;     
  
  return toRet;
}

getResultsModal = async(config) => {
  var toRet;
      var els = [...this.results];
      //console.log(els)
      //console.log(JSON.parse(JSON.stringify(config)));
      if(config.filters){
        let filtersNames = Object.keys(config.filters);
        let filters = {};
        for(let item of filtersNames){
          filters[item] = [...config.filters[item]];
        }
        els = els.filter( (element) => {
          for(let item of filtersNames){
            //let filter = [... config.filters[item]]
            if(!filters[item].includes(element[item])) return false
          }
          return true;
        })
      }

      if(this.tabledata?.selectData){
        els = els.filter( (element) => {
          
            return !(this.tabledata.selectData[element.Id] == false);
          
        })

        if( Math.ceil(els.length / config.perPage) < (config.page + 1)){
          config.page -= 1;
        }
      }
            
      

      toRet = await getPagination({
          page: config.page,
          perPage:config.perPage,
          total:els.length
      });

      var cols = [];
      var labels = {};
      for(var i of this.columns){
        cols.push(i.fieldName);
        labels[i.fieldName] = i.label;
      }
      
      
      if(config.orderName && config.orderField){
        if(config.orderName === 'ASC'){
          els = els.toSorted((a,b) => {
            
            if(!a[config.orderField]) return -1;
            if(!b[config.orderField]) return 1;
           if(a[config.orderField] > b[config.orderField]){  return 1; }
           else if(a[config.orderField] < b[config.orderField]) { return -1; }
           return 0;
          })
        }
        else{
          els = els.toSorted((a,b) => {
            if(!a[config.orderField]) return 1;
            if(!b[config.orderField]) return -1;
            if(a[config.orderField] < b[config.orderField]) return 1;
            else if(a[config.orderField] > b[config.orderField]) return -1;
            return 0;
           })
        }
      }
      
      toRet.columns = cols;
      toRet.labels = labels;
      toRet.elementsCached = els;
      toRet.elements = els.slice(toRet.startPage, toRet.endPage);
      if(!toRet.selectData){

        toRet.selectData = {}
        
      }
      if(this.tabledata && this.tabledata.selectData){
        toRet.selectData = this.tabledata.selectData;
      }
      if(this.selectionCompleted){
        toRet.selectData = this.fullSelection
      }

      
      
      /*for(let el of this.results){
        
        toRet.selectData[el.Id] = true;
      }*/
      
      toRet.length = toRet.elements.length;     
  
  return toRet;
}

get showButton(){
  return (this.isPush || this.CallerType === 'ECollaborationFinale');
}

get isPush(){

  return (!this.CallerType ||  this.CallerType == 'Push')
    
    }

get titleLabel(){
  if(this.isListaCampagne) return '';
  return 'Clienti in target';

  }

get isListaCampagne(){
  return this.CallerType === 'Lista Campagne';
}
		
		//To get the query Json Result from CRM Analytics
		@api results;
    get stringResults() {
      this.count = this.results.length;
        return JSON.stringify(this.results)
    }
          
  

  // Just for demo purposes
  get selectedIds() {
    return [...this.allSelectedRows].join(',')
  }

	// Show Number of Selected Rows	
	get numero() {
			return this.nSelected;
	}	

  async startingSelection(){
    this.fullSelection = {};
    for (let i = 0; i < this.results.length; i++) {
      const item = this.results[i];
      this.fullSelection[item.Id] = true;
    }
    this.selectionCompleted = true;

  }
		
  // Show Page Number
  get pageDisplay() {
    return this.pageNumber +1;
  }

 
  get showDynamicModal (){
    return this.showResultModal || this.showChiusuraModal || this.showOrariModal || this.showIniziativaDetail;
  }
  
		
  get StartingTableDataNoSelect(){
      var tableNoSelect = {}
      tableNoSelect.perPage = 6;
      
      
      tableNoSelect.simpleMode = false;
      tableNoSelect.showFilter = true;
      tableNoSelect.showSearch = false;
      tableNoSelect.viewSelectRow = false;
      tableNoSelect.fixedFirst = false;
      tableNoSelect.fixedLast = false;
      tableNoSelect.bind = {
        origin: this,
        target: 'tabledataNoSelect',
        load: this.getResults
      }

      if(this.isListaCampagne){
        tableNoSelect.actions = [
        {
          label: '',
          icon: 'icon-arrow-right-blue',
          callback: (value) => {
            this.navigateTo({
              name: 'MobilityCampaignDetail',
              params: {
                recordId: value.Id
              }
            })
          }
        }
        ]
      }
      return tableNoSelect;
  }
  get StartingTableData(){
      var table = this.StartingTableDataNoSelect;
      table.fixedLast = true;
      table.bind = {
              origin: this,
              target: 'tabledata',
              load: this.getResultsModal
      }
      table.actions = [{
        label: '',
        icon: 'delete',
        callback: (value) => {
          this.selectedRecordId = value.Id;
          console.log(JSON.stringify(value));
          this.openDeleteModal({'NDG': value.NDG,'Name':value.Name});

          /*this.tabledata.selectData[value.Id] = false;
          this.tabledata.load();*/
      }
      }]

      return table;
  }
		
		connectedCallback(){
      this.params = {id:"tcrmModaleConTabella"}
      console.log(localStorage["test"])
      //this.startingSelection();
      if(!this.isPush){
        this.columns = [];
      }
      if(this.DynamicColumns && this.DynamicLabels){
        let cols = this.DynamicColumns.split(';')
        let labels = this.DynamicLabels.split(';')

        cols.forEach( (element, index) => {
          this.columns.push(
            {label: labels[index],
            fieldName: element}
          )
        } );
      }
      if(window.location.href.includes('/crm/') || window.location.href.includes('/tabs/')){
        
        Promise.all([
          loadStyle(this, MobilityEngine)
        ]);



        window.addEventListener("message", event => {
          //console.log('event', JSON.stringify(event));
          // Verifica l'origine
          if (event.origin !== window.location.protocol + "//"+ window.location.hostname) return;
          let data = event.data;
          if(data.Action === 'SEND_VALUES'){
            this.data = data.values;
            if(this.data && this.data['iniziativaScelta']){
              
              this.campaignDescription = this.data['iniziativaScelta']['Descrizione_dell_iniziativa__c']
              this.disableDescription = !!this.data['iniziativaScelta']['Descrizione_dell_iniziativa__c'];
            }
          }
          // Aggiorna il messaggio
          
        }, false);
        var request = {
          "Action": "REQUEST_VALUES"
        };
        window.parent.postMessage(request, window.location.protocol + "//"+ window.location.hostname);


      }

      getMessageStatusFromNode().then(
        (result) => {
          if(result.isSuccess){
          this.messaggiRimanenti = result.MessagesRimanenti.toLocaleString();
          }
        }
      )
	  
      //window.parent.postMessage("Hello from LWC!", "https://axaitalia--develop1.sandbox.my.site.com");

      this.reloadTableDataNoSelect();
      this.results_temp = this.results;

    }
  
		
		
		
		//Boolean tracked variable to indicate if modal is open or not default value is false as modal is closed when page is loaded 
    @track isModalOpen = false;

    showModal = false
    query=[];
    
    openModal() {
        // to open modal set isModalOpen tarck value as true
        this.filterName = [];
        this.filterNode = [];
        this.filtered = false;
        this.loaded = false;
        this.reloadTableData();
				//
        if(this.CommunicationCode !== null && this.CommunicationCode!=='' && this.CommunicationCode!=='undefined' && !this.isPush)
          this.LoadInit_IniziativaMkt();//presente solamente dashboards per Ecollab targets finali
    }
    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.showModal = false;
        this.loaded = false;
        this.tabledata.selectData = {};
    }

    onProcedi(){

      this.showModal = false;
      var iniziativaScelta = this.data.iniziativaScelta;
      if(iniziativaScelta && this.messagesToBeSent && this.messaggiRimanenti && this.messagesToBeSent > parseInt(this.messaggiRimanenti.replaceAll('.', '')) ){
        this.openResultModal("ModalMessaggiEsauriti", 
          this.backResultModal,
          null,
          this.backResultModal, 
          {'nomeiniziativa': iniziativaScelta.IniziativaName,'messaggiresidui':this.messaggiRimanenti});
      }
      else if(iniziativaScelta && iniziativaScelta.is_scheduled_type__c=='true'){
        this.showResultModal = false;
        this.showOrariModal = true;
        this.primary = this.primaryCallback;
        this.close = this.backOrariModal;

      }
      else if(iniziativaScelta &&  iniziativaScelta.is_closure_type__c=='true'){
        this.showResultModal = false;
        this.showChiusuraModal = true;
        this.primary = this.primaryCallback;
        this.close = this.backChiusuraModal;
      }
      else{
        
        this.showResultModal = true;
        //console.log(JSON.parse(JSON.stringify(this.data)));
        this.modalType = this.data['tipologiaScelta'].With_Message__c ? "ModalConfermaInvio" : "ModalConfermaCreazioneCampagna"
        
        this.primary = this.submitDetails;
        this.back = this.backResultModal;
        this.close = this.closeResultModal;

      }
      
    }

    closeResultModal = () => {
      
      this.showResultModal = false;
    }

    backResultModal = () => {
      this.showResultModal = false;
      this.showModal = true;
    }

    primaryCallback = ( param ) => {

      if(this.showOrariModal){
        this.showOrariModal = false;
        this.requestCambiOrari = JSON.stringify(param.orari);
      }
      else if(this.showChiusuraModal){
        this.showChiusuraModal = false;
        this.requestChiusura =JSON.stringify(param);
      }
      
      var modalType = this.data['tipologiaScelta'].With_Message__c ? "ModalConfermaInvio" : "ModalConfermaCreazioneCampagna"
    
      this.openResultModal(modalType,this.backResultModal,this.submitDetails, this.backResultModal, null);

    }

    closeAllModal = () => {
      this.closeOrariModal();
      this.closeChiusuraModal();
      this.closeResultModal();
    }

    closeOrariModal = () => {
      this.showOrariModal = false;
    }
    backOrariModal = () => {
      this.showOrariModal = false;
      this.showModal = true;
    }

    closeChiusuraModal = () => {
      this.showChiusuraModal = false;
    }
    backChiusuraModal = () => {
      this.showChiusuraModal = false;
      this.showModal = true;
    }

    openDeleteModal(replaceVariables){
      this.hideSpinner();
      this.showDeleteModal = true;
      this.modalType = "ModalConfermaDeselezione";
      this.primary = this.remove;
      this.back = this.closeDeleteModal;
      this.replaceVariables = replaceVariables;
      this.close = this.closeDeleteModal;
      
    }
    closeDeleteModal = () => {
      this.selectedRecordId = null;
      this.showDeleteModal = false;
    }

    remove = () => {
        
        this.tabledata.selectData[this.selectedRecordId] = false;
        this.tabledata.load();
        this.showDeleteModal = false;
        this.selectedRecordId = null;
        
    }

    openResultModal(type, close, primary, back, replaceVariables){
      this.hideSpinner();
      this.showResultModal = true;
      this.modalType = type;
      this.primary = primary;
      this.back = back;
      this.replaceVariables = replaceVariables;
      this.close = close;
      
    }

    get isDisabledProcedi(){
      return !this.campaignName || !this.validoAl || this.selectedNum === 0 || this.selectedNum === '0' || !this.campaignDescription
    }

    submitDetails = async () => {
        // to close modal set isModalOpen tarck value as false
        //Add your code to call apex method or do some processing
				//this.clickedButtonLabel = window.location.assign("https://axaitalia--develop1.sandbox.my.site.com/crm/apex/javascriptIntegration?id=testDatatablePagination&component=testDatatablePagination")
        //this.isModalOpen = false;
        this.showResultModal = false;
        this.showSpinner();
        let iseAvailabilityOK = false;
        let totaliClienti = parseInt(this.messagesToBeSent);
        let iniziativaScelta = this.data.iniziativaScelta;
        let tipologiaScelta = this.data.tipologiaScelta;
        let targetScelto = this.data.targetScelta;

        let sottoTipologia = targetScelto?.Sottotipologia_Campagna__c;

        let targetSceltaDescription = this.data.targetScelta != null ? this.data.targetScelta.TargetDescription : 'Descrizione assente'  ;
        let campaignId = null;
        // Done Inviare anche campaignDescription
        let campaignToCreate={Name:this.campaignName,StartDate:this.validoDal,EndDate:this.validoAl,Target__c:targetSceltaDescription, Sotto_tipologia_campagna__c:sottoTipologia, Description:this.campaignDescription };
        let iniziativaSelected;
        //console.log(this.data['tipologiaScelta'])
        console.log(JSON.parse(JSON.stringify(this.data)));
        let invioMessagi = this.data['tipologiaScelta'].With_Message__c;
        var responseAvailability;
        if(tipologiaScelta.With_Message__c){
          responseAvailability = await getDisponibilitaFromNode({
            SizetotaleClient: totaliClienti,
          })
          .catch(error => {
            this.hideSpinner();
            this.openResultModal("ModalErroreTecnico",this.navigateToHomepage,this.navigateToList,this.navigateToHomepage,null);
            console.log(error);
          });
          if(responseAvailability){
            if(responseAvailability.isSuccess){
              console.log(responseAvailability.SuccessMessage);
              iseAvailabilityOK = true;
            }
          }
        }
          //se ci sono messagi allora creo la campagn
          if(!tipologiaScelta.With_Message__c || iseAvailabilityOK){
              const responseCreated = await createCampaign({
              campagnaToCreate:campaignToCreate,
              tipologiaCampagna: this.data['tipologiaScelta'].Type__c,
              SizetotaleClient: totaliClienti,
              iniziativaId: iniziativaScelta ? iniziativaScelta['IniziativaId'] ? iniziativaScelta.IniziativaId : iniziativaScelta.Id : '',
              isSendingCommunications: invioMessagi
              })
              .catch(error => {
                this.openResultModal("ModalErroreTecnico",this.navigateToHomepage,this.navigateToList,this.navigateToHomepage,null);
                  console.log(error);
              });
              if(responseCreated.isSuccess){
                console.log('IS OK-'+responseCreated.SuccessMessage);
                campaignId = responseCreated.campaignId;
                iniziativaSelected = responseCreated.iniziativaSelected;
                
              }else{
                console.log('IS NOT OK-'+responseCreated.errorMessage);
                this.openResultModal("ModalErroreTecnico",this.navigateToHomepage,this.navigateToList,this.navigateToHomepage,null);
            }
            }else {
              this.openResultModal("ModalMessaggiEsauriti", this.backResultModal,null,this.backResultModal, {'nomeiniziativa': this.data['iniziativaScelta'].IniziativaName,'messaggiresidui':responseAvailability.MessagesRimanenti});
              iseAvailabilityOK = false;
            }
            if(campaignId != null)
              this.createCampaignMembers(campaignId, iniziativaSelected);
          

    }
    async createCampaignMembers(campaignId, iniziativaSelected){

      
      var arrayListComplete = this.results.filter( (el)=>{
        return this.tabledata.selectData[el.Id];
      } );

      let max = Math.ceil(arrayListComplete.length/500);

      let err = false;
      for(var i = 0; i<max && !err; i++){
        let ending = arrayListComplete.length < i*500 + 500 ? arrayListComplete.length : i*500 + 500;
        let arrayListTemp = arrayListComplete.slice(i*500, ending);
        let responseCreateMembers = await createCampaignMembers({
          request: arrayListTemp,
          campaignId: campaignId,
          isSendingCommunications: this.data['tipologiaScelta'].With_Message__c,
          iniziativa: iniziativaSelected,
          requestChiusura: this.requestChiusura!= null && this.requestChiusura != 'undefined'     ? JSON.parse(this.requestChiusura) : null,
          requestCambiOrari: this.requestCambiOrari!= null && this.requestCambiOrari !='undefined'? JSON.parse(this.requestCambiOrari) : null
          })
          .catch(error => {
              console.log(error);      
              err = true;
          });
          if(responseCreateMembers && responseCreateMembers.isSuccess)
            console.log(responseCreateMembers)
          else{
            console.log(responseCreateMembers)
            err = true;          
          }
      }
      if(err){
        
        this.openResultModal("ModalErroreTecnico",this.navigateToHomepage,this.navigateToList,this.navigateToHomepage,null);
      }
      else{
        let isSendingCommunications = this.data["tipologiaScelta"].With_Message__c;
        let isSendingCommunicationsAndPush = isSendingCommunications ? this.data['iniziativaScelta'].Invio_push__c : false;
        this.openResultModal(isSendingCommunications ? "ModalConcludiCampagna" : "ModalConcludiCampagnaNoInvio" , this.navigateToHomepage, this.navigateToDetail,null, null);
        //this.successMessage("Campagna creata!", "La campagna "+this.campaignName+" è stata creata correttamente!");
        this.showModal = false;

        let nodes = new Set();
        for(var ac of arrayListComplete){
          for( var n of ac.Nodes?.split(';')){
            nodes.add(n);
          }
          
        }
        
        //forse serve un messaggio di errore se non trova la camp??
        updateCampagnaFinale({
          campaignId: campaignId,
          isSendingCommunicationsAndPush: isSendingCommunicationsAndPush,
          isSendingCommunications: isSendingCommunications,
          SizetotaleClient: this.tabledata.listSelected.length,
          nodes: [...nodes].join(';')
        })
        .catch(error => {
            console.log(error);
        });
        this.campaignId = campaignId;
      }

      this.hideSpinner();
         
    }

    selectAll = () => {
      let selectAll = this.tabledata.selectedAll;
      if(selectAll && this.loaded){
        this.tabledata.selectData = {}
      }
      else{
        if(this.tabledata.pagination.elementsCached)
          this.tabledata.pagination.elementsCached.forEach( (element) => {
            this.tabledata.selectData[element.Id] = true;
          } )
        else
        this.results.forEach( (element) => {
          this.tabledata.selectData[element.Id] = true;
        } )
      }
      
  
      this.tabledata.update();
    }

    changeData = (e) => {
      if (!e.target && !e.currentTarget) return;

      let target = e.target || e.currentTarget;
      this.validoDal = target.value;
  }

    changeData2 = (e) => {
      if (!e.target && !e.currentTarget) return;

      let target = e.target || e.currentTarget;
      this.validoAl = target.value;
      
  }

  navigateToHomepage = () =>{
    this.navigateTo({
			name: 'homepage',
      action: 'homepageCallback'
    })
  }

  navigateToDetail = () => {

    this.navigateTo({
      name:'mobilityCampaignDetail',
      params: {
        recordId: this.campaignId
      }
    })

  }

  navigateToList = () => {

    this.navigateTo({
      name:'mobilityCampaignAgencyListView',
      params: {
        recordId: this.campaignId
      }
    })

  }

  createCSV = () => {
		this.showSpinner(true);
        // Prepare a html table
        let doc = '<table>';
        doc += '<style>';
        doc += 'table, th, td {'; doc += ' border: 1px solid black;'; doc += ' border-collapse: collapse;'; doc += '}'; 
        doc += '</style>';      
        // Add all the Table Headers
        doc += '<tr>';
		for(let key in this.tabledata.labels){
			doc += '<th>'+this.tabledata.labels[key]+'</th>' ;
		}
        
        doc += '</tr>';
        // Add the data rows
        this.results.forEach( (el)=>{
       doc += '<tr>';
      if(this.tabledata.selectData[el.Id]){
        
        for(let key of this.tabledata.columns){
          doc += '<th>'+ (el[key] ? el[key]:"") +'</th>';
        }
        
doc += '</tr>'; 
      }

    } );
	
        doc += '</table>';
		this.hideSpinner(true);
        var element = 'data:application/vnd.ms-excel,' + encodeURIComponent(doc);
        
		const downloadElement = document.createElement('a');
        downloadElement.setAttribute('href', element) ;
        downloadElement.setAttribute('download', this.campaignName+'.xls');
        
        document.body.appendChild(downloadElement);
        downloadElement.click();


	}

  openModalPreview(){
      var data = this.data.iniziativaScelta;

      this.showIniziativaDetail = true;
      this.showModal = false;
      if(data != null){
        if(data['IniziativaName'])
        this.title = data.IniziativaName;
        else this.title = data.Nome_Messaggio__c;

        if(data['IniziativaDescription'])
        this.description = data.IniziativaDescription?.replace(/\n/gm, '<br>');
        else this.description = data.Descrizione_Messaggio__c?.replace(/\n/gm, '<br>');

        this.iframeUrl = data.TECH_URL_template_MC__c;
        this.previewEmail = 'Preview Email';
        this.previewShortMessage = data.Short_Message__c;
        this.previewMessage = data.Message__c;

        this.close = this.closeModalPreview;
    }
  }
  closeModalPreview = () =>{
    this.showIniziativaDetail = false;
    this.showModal = true;

  }

  async LoadInit_IniziativaMkt(){
    this.showSpinner();
    let response = await InitRecordIniziativaMkt({
      communicationCode : this.CommunicationCode ,
    })
    .catch(error => {
          console.log(error);
    });
    if(this.data && response['iniziativaScelta']){
      this.data.iniziativaScelta = response.iniziativaScelta;
    }
    if(response['isAllowedEcollab']!=null){
      if(response.isAllowedEcollab==false){
        this.hideSpinner();
        this.showModal = false;
        this.openResultModal("ModalAbilitazioneProfilo",this.navigateToHomepage,this.navigateToList,this.navigateToHomepage,null);
      }
    }
  }
}