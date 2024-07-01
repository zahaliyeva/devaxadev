import { MobilityAbstract } from 'c/mobilityAbstract';
import { api, track, wire } from 'lwc';
import { MobilityCardCollection } from 'c/mobilityCardModel';
import { PostMessage } from 'c/postMessage';

import initSingle from '@salesforce/apex/mobilitySinglePushController.init';
import getPickListValues from '@salesforce/apex/lghtIniziativeMarketingCustomViewCTRL.getPickListValues';
import createCommunicationsingle from '@salesforce/apex/mobilitySinglePushController.createCommunicationsingle';
import filterByBlacklist from '@salesforce/apex/mobilitySinglePushController.filterByBlacklist';
import filterByFatique from '@salesforce/apex/mobilitySinglePushController.filterByFatique';


export default class MobilitySinglePush extends MobilityAbstract {
    
    @api results;
    ready = false;
    //private vars
    accountCliente;
    iniziativaSelect;
    previewMessage;
    previewShortMessage;
    previewEmail;
    iframeUrl;
    description;
    title;
    caricaFiltri;

    //filters
    objectName = 'Iniziative_Marketing__c';
    //optionsObiettivi;
    //optionsCategoriaProd;
    //optionsCanale;
    //filtersseectd
    @track filterObjec;
    @track filterCateProd;
    @track filterCanale;
    @track filterTipologia;//ZA CR PUSH 179

    @track filterValues = {
        filterObj: [],
        filterTip: [],
        filterCategory: [],
        filterCanale: [],
    }

    completeIniziativa;
    showDetailsMain;
    showDetailsTemplate;
    showMessaggeSended;
    showProfileAgenteNonAbilitato;
    //ECLEMENTE - 26/02/2024 - Start: Add boolean for modal error logic
    showCommunicated;
    //ECLEMENTE - 26/02/2024 - End:
    clienteNonAbilitato;
    erroreTecnico;
    erroreCommunicated;
    showOrariModal;
    showChiusuraModal;

    requestChiusura;
    requestCambiOrari;

    connectedCallback(){
        super.connectedCallback();
        this.showSpinner();
        //this.loadFilters();
        this.init();

    }

    generateFilterList(field){
        var filterSet = new Set();
      
        if(field === 'Canale__c'){
            this.results.forEach(
                
                (element) => {
                    if(element[field] === 'Email' && element['Invio_push__c'] == true){
                        filterSet.add('Email + Push');
                    }
                    else if(element[field] === 'Email'){
                        filterSet.add('Solo Email');
                    }
                    else if(element[field] === 'SMS'){
                        filterSet.add(element[field]);
                    }
                }

            );
        }
        else{
            this.results.forEach(

                (element) => {
            if(element[field]){
              filterSet.add(element[field]);
            }
          }

        );
        }
        
      
        let list = [... filterSet];
        
        
        return list.toSorted(
        (a, b) => {
            if(a>b) return 1;
            else if (a<b) return -1;
            return 0;
        }
        )
      
      }
      get optionsObiettivi() {
        return this.generateFilterList('Sottotipologia_Campagna__c');
      }
      //ZA CR PUSH 179
      get optionsTipologiaCamp() {
        return this.generateFilterList('Tipologia_Campagna__c');
      }
      
      get optionsCategoriaProd() {
        return this.generateFilterList('Categoria_Prodotto__c');
      }
      get optionsCanale(){
        return this.generateFilterList('Canale__c');
      }

    async init(){

        var myParam = location.search.split('parameters=')[1];
        console.log('location: '+location);
        console.log('myParam: '+myParam);
        if(myParam && myParam != 'undefined'){
            let respSingle = await initSingle({
                inputParameter: myParam
                }).catch( (ex) => {
                    this.seterroreTecnico();
                    console.log("exception")
                });
                if(respSingle){
                
                console.log(respSingle)
                if(respSingle.isSuccess){
                    this.results = respSingle.iniziative;
                    this.accountCliente = respSingle.AccountCliente;
                    this.handleFilterAdvanced();
                    //ECLEMENTE - 26/02/2024 - Start: Add if/else condition for modal toast error
                    if(respSingle.communicated){
                        this.setshowCommunicated();
                        this.erroreCommunicated = respSingle.errorMessage;
                    }else{
                        this.setShowDetailsMain();
                    }
                    //ECLEMENTE - 26/02/2024 - End
                }else{
                    if(respSingle.visibility){
                        console.log('ERROR CRM TECH-'+respSingle.errorMessage);
                        this.setclienteNonAbilitato();
                    }else{
                        console.log('ERROR PROFILE');
                        
                       this.setshowProfileAgenteNonAbilitato();
                        
                    
                    }
                }
            }
        }else{
            console.log('parameters from RGI');
            console.log(location.search.split('parameters=')[1]);
        }
        this.hideSpinner();
    }
    setShowDetailsMain = () =>{
        this.showDetailsMain=true;
        this.showDetailsTemplate=false;
        this.showMessaggeSended=false;
        this.showProfileAgenteNonAbilitato=false;
        this.clienteNonAbilitato = false;
        this.erroreTecnico = false;
        this.showChiusuraModal = false;
        this.showOrariModal = false;
        this.showConfirmation = false;
    }
    setshowDetailsTemplate(){
        this.showDetailsMain=false;
        this.showDetailsTemplate=true;
        this.showMessaggeSended=false;
        this.showProfileAgenteNonAbilitato=false;
        this.clienteNonAbilitato = false;
        this.erroreTecnico = false;
        this.showChiusuraModal = false;
        this.showOrariModal = false;
        this.showConfirmation = false;
    }
    setshowMessaggeSended(){
        this.showDetailsMain=false;
        this.showDetailsTemplate=false;
        this.showMessaggeSended=true;
        this.showProfileAgenteNonAbilitato=false;
        this.clienteNonAbilitato = false;
        this.erroreTecnico = false;
        this.showChiusuraModal = false;
        this.showOrariModal = false;
        this.showConfirmation = false;
    }
    setclienteNonAbilitato(){
        this.showDetailsMain=false;
        this.showDetailsTemplate=false;
        this.showMessaggeSended=false;
        this.showProfileAgenteNonAbilitato=false;
        this.clienteNonAbilitato = false;
        this.erroreTecnico = false;
        this.clienteNonAbilitato = true;
        this.erroreTecnico = false;
        this.ready = true;
        this.showChiusuraModal = false;
        this.showOrariModal = false;
        this.showConfirmation = false;
    }
    seterroreTecnico(){
        this.showDetailsMain=false;
        this.showDetailsTemplate=false;
        this.showMessaggeSended=false;
        this.showProfileAgenteNonAbilitato=false;
        this.clienteNonAbilitato = false;
        this.erroreTecnico = false;
        this.clienteNonAbilitato = false;
        this.erroreTecnico = true;
        this.ready = true;
        this.showChiusuraModal = false;
        this.showOrariModal = false;
        this.showConfirmation = false;
    }
    setshowProfileAgenteNonAbilitato(){
        this.showDetailsMain=false;
        this.showDetailsTemplate=false;
        this.showMessaggeSended=false;
        this.showProfileAgenteNonAbilitato=true;
        this.clienteNonAbilitato = false;
        this.erroreTecnico = false;
        this.ready = true;
        this.showChiusuraModal = false;
        this.showOrariModal = false;
        this.showConfirmation = false;
    }
    //ECLEMENTE - 26/02/2024 - Start: Add logic for modal toast error
    setshowCommunicated(){
        this.showDetailsMain=true;
        this.showDetailsTemplate=false;
        this.showMessaggeSended=false;
        this.showProfileAgenteNonAbilitato=false;
        this.showCommunicated = true;
        this.clienteNonAbilitato = false;
        this.erroreTecnico = false;
        //this.ready = true;
        this.showChiusuraModal = false;
        this.showOrariModal = false;
        this.showConfirmation = false;
    }
    //ECLEMENTE - 26/02/2024 - End
    openOrariAgenzia(){
        this.showDetailsMain=false;
        this.showDetailsTemplate=false;
        this.showMessaggeSended=false;
        this.showProfileAgenteNonAbilitato=false;
        this.clienteNonAbilitato = false;
        this.erroreTecnico = false;
        this.ready = true;
        this.showChiusuraModal = false;
        this.showOrariModal = true;
        this.showConfirmation = false;
    }
    openChiusuraAgenzia(){
        this.showDetailsMain=false;
        this.showDetailsTemplate=false;
        this.showMessaggeSended=false;
        this.showProfileAgenteNonAbilitato=false;
        this.clienteNonAbilitato = false;
        this.erroreTecnico = false;
        this.ready = true;
        this.showChiusuraModal = true;
        this.showOrariModal = false;
        this.showConfirmation = false;

    }
    
    showConfirmationModal(){
        this.showDetailsMain=false;
        this.showDetailsTemplate=false;
        this.showMessaggeSended=false;
        this.showProfileAgenteNonAbilitato=false;
        this.clienteNonAbilitato = false;
        this.erroreTecnico = false;
        this.ready = true;
        this.showChiusuraModal = false;
        this.showOrariModal = false;
        this.showConfirmation = true;
    }

    backOrariModal = () => {
    this.showOrariModal = false;
    this.showDetailsMain = true;
    }

    backChiusuraModal = () => {
    this.showChiusuraModal = false;
    this.showDetailsMain = true;
    }

    primaryChiusura = (param) => {
        this.requestChiusura =JSON.stringify(param);
        this.showConfirmationModal();
    }

    primaryOrari = (param) => {
        this.requestCambiOrari = JSON.stringify(param.orari);
        this.showConfirmationModal();
    }

    OpenModalVisualTemplate = (event) =>{
        this.setshowDetailsTemplate();
        var data = event;
        this.completeIniziativa = event;
        console.log("data: ", JSON.parse(JSON.stringify(data)));
        if(data.Id){
            this.title = data.Nome_Messaggio__c;
            this.description = data.Descrizione_Messaggio__c?.replace(/\n/gm, '<br>');
            this.iframeUrl = data.TECH_URL_template_MC__c;
            this.previewEmail = 'Preview Email';
            this.previewShortMessage = data.Short_Message__c;
            this.previewMessage = data.Message__c;
            this.iniziativaSelect = data.Id;
        }
    }

    navigateSingleSumit = (event) =>{

        var data;
        if(!this.showDetailsTemplate){
            data = event; //JSON.parse(event.target.dataset.value);
       		console.log(data);
       		this.iniziativaSelect = data.Id;
        }
        else{
            data = this.completeIniziativa;
        }

       if(data.is_closure_type__c){
            this.openChiusuraAgenzia();
       }

       else if(data.is_scheduled_type__c){
            this.openOrariAgenzia();
       }
       else{
            this.showConfirmationModal();
    }
       
    }
    submit = async () => {
        this.showSpinner();
        this.ready = false;
        let response = await createCommunicationsingle({
            AccountCliente: this.accountCliente ,
            iniziativaId: this.iniziativaSelect,
            requestChiusura: this.requestChiusura!= null && this.requestChiusura != 'undefined'     ? JSON.parse(this.requestChiusura) : null,
            requestCambiOrari: this.requestCambiOrari!= null && this.requestCambiOrari !='undefined'? JSON.parse(this.requestCambiOrari) : null
        }).catch((err) => {
            console.log('err', this.proxyData(err));
            this.seterroreTecnico();
            this.warningMessage('Errore',err);
        }).finally(() => {
            this.hideSpinner(); 
        });
        if(response.isSuccess){
            this.setshowMessaggeSended();
        }else{
            console.log('err', this.proxyData(response));
            this.warningMessage('Errore',response.errorMessage);
            this.seterroreTecnico();
        }
        this.hideSpinner();
        this.ready = true;
    }
    closePostMessage(){
        PostMessage.close_Modal();
    }
    async handleFilter(event){
        var value = event.detail;
        var filterSelected = event.target.dataset.id;
        
        //this.setFiltersValues(filterSelected,"ALL");
        this.setFiltersValues(filterSelected,value);
        
    }
    async handleFilterAdvanced(){

        var maxLength = this.results.length;
        console.log('maxlentgh'+maxLength);
        for(var i = maxLength-1 ; i>=0 ; i--){
           // versione2 richiesta del bussines di non avere blacklist filters
            /* var isFilterBlackList = await filterByBlacklist({
                iniziativa: this.results[i],
                AccountCliente: this.accountCliente
            }).catch((err) => {
                this.warningMessage('Errore',err);
                this.seterroreTecnico();
            });*/

            var isFilterFatique = await filterByFatique({
                iniziativa: this.results[i],
                AccountCliente: this.accountCliente
            }).catch((err) => {
                this.warningMessage('Errore',err);
                this.seterroreTecnico();
            });
            if(isFilterFatique.isSuccess){
            //if(isFilterBlackList.isSuccess || isFilterFatique.isSuccess){
                const indexIniz = this.results.findIndex((x) => x.Id === this.results[i].Id);
                this.results.splice(indexIniz,1);
            }
            this.caricaFiltri = parseInt(100-(i+1/maxLength));
        }   
        this.ready=true;
        return true;
    }

    get resultList(){
        
        var filter = {
            Categoria_Prodotto__c: this.filterCateProd,
            Canale__c: this.filterCanale,
            Tipologia_Campagna__c: this.filterTipologia,//ZA CR PUSH 179
            Sottotipologia_Campagna__c: this.filterObjec
          };
        const elementsToReturn = this.results.filter((item) => {

            for (var key in filter) {

                if(filter[key]){
                    var filterValues = filter[key];
                    if(key === 'Canale__c'){
                        for(var value of filterValues){
                            if(value === 'Email + Push' && item.Canale__c === 'Email' && item.Invio_push__c){
                                return true;
                            }
                            if(value === 'Solo Email' && item.Canale__c === 'Email' && !item.Invio_push__c){
                                return true;
                            }
                            if(value === 'SMS' && item.Canale__c === 'SMS'){
                                return true;
                            }
                        }
                        return false;
                    }
                    else{
                    if(!filterValues.includes(item[key])){
                        return false;
                    }
                    }
                    //console.log(JSON.stringify(filterValues))
                    
                }           
            }
            return true;
          });
          return elementsToReturn;
    }

    setFiltersValues(filterSelected,value){
        this.filterValues[filterSelected] = value;
        if(filterSelected=='filterObj'){
            if(value && value.length == 0)
                this.filterObjec=null;
            else
                this.filterObjec = value;
        }else if(filterSelected=='filterCategory'){
            if(value && value.length == 0)
                this.filterCateProd=null;
            else
                this.filterCateProd = value;
        }else if(filterSelected=='filterTip'){//ZA CR PUSH 179
            if(value && value.length == 0)
                this.filterTipologia=null;
            else
                this.filterTipologia = value;
        }  
        else if (filterSelected=='filterCanale'){
            if(value && value.length == 0)
                this.filterCanale=null;
            else
                this.filterCanale = value;
        }
        
    }

    loadFilters(){     
            getPickListValues({
                objApiName: this.objectName,
                fieldName: 'Sottotipologia_Campagna__c'
            })
            .then(data => {
                this.optionsObiettivi = data;
            })
            .catch(err => {
                console.log(err);
            });
            getPickListValues({
                objApiName: this.objectName,
                fieldName: 'Categoria_Prodotto__c'
            })
            .then(data => {
                this.optionsCategoriaProd = data;
            })
            .catch(err => {
                console.log(err);
            });
            getPickListValues({
                objApiName: this.objectName,
                fieldName: 'Tipologia_Campagna__c'
            })
            .then(data => {
                this.optionsTipologiaCamp = data;
            })
            .catch(err => {
                console.log(err);
            }); //ZA cr push 179
            //call other picklist
            getPickListValues({
                objApiName: this.objectName,
                fieldName: 'Canale__c'
            })
            .then(data => {
                this.optionsCanale = data;
            })
            .catch(err => {
                this.warningMessage('Errore',err);
            });
    }

}