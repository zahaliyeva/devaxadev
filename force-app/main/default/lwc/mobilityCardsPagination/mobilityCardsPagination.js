import { api, track, wire } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import MobilityEngine from '@salesforce/resourceUrl/mobilityEngine';
import SObjectDataGrid from 'c/sObjectDataGrid';

import {
	DataGridModel
} from 'c/dataGridModel';
import { MobilityCardCollection } from 'c/mobilityCardModel';
import getPagination from '@salesforce/apex/mobilityDashboardPaginationController.getPagination';
import getConfiguration from '@salesforce/apex/mobilityDashboardPaginationController.getConfiguration';
import { MessageService } from 'c/messageService';


export default class MobilityCardsPagination extends SObjectDataGrid {
    
    @api results;

    @api metadata;
    @api getState;
    @api setState;
    @api selection;
    //per single push
    @api backNavigateSingle;
    @api backOpenModalSingle;
    
    @api setSelection;
    @api dashboardName;
    @api targetPageName;
    @api pageName;
    @api stepName;

    dettaglioTarget;

    showModal = false;
    showIniziativaDetail;
    showTargetDetail;

    title;
    description;
    iframeUrl;
    previewEmail;
    previewShortMessage;
    previewMessage;
    iniziativaSelect;
    
    type = 'messaggio'
    


    navigation;

    results_temp;
    pagination;
    ready = false;
    cols = 3;
    config;
    cssLoaded = false;

    getResults = async(config) => {
        ////console.log(this.results);
        var toRet;
        if(!this.ready){
            var els = JSON.parse(JSON.stringify(this.results));
            toRet = await getPagination({
                page: config.page,
                perPage:config.perPage,
                total:els.length
            });

            //console.log("ret: ", toRet);
            toRet.elementsCached = els;
            toRet.elements = els.slice(toRet.startPage, toRet.endPage);
            toRet.length = toRet.elements.length;
            this.showNoData(els.length === 0);
        }
        else{
            toRet = this.pagination;
            toRet.elements = els.slice(toRet.startPage, toRet.endPage);
            toRet.length = toRet.elements.length;
        }
        
        //toRet.elements = els.slice(0,perPage);
        //this.ready = true;
        this.pagination = toRet;
        return toRet;
    }

    openModal (event){
        var data = JSON.parse(event.target.dataset.value);
        console.log("data: ", this.proxyData(data));

        this.showModal = true;
        if(data.IniziativaId){
            console.log("iniziativa popolata")
            this.showIniziativaDetail = true
            this.title = data.IniziativaName;
            this.description = data.IniziativaDescription?.replace(/\n/gm, '<br>');
            this.iframeUrl = data.TECH_URL_template_MC__c;
            this.previewEmail = 'Preview Email';
            this.previewShortMessage = data.Short_Message__c;
            this.previewMessage = data.Message__c;
            this.iniziativaSelect = data.IniziativaId;
        }

        if(data.TargetName){
            console.log("target popolato")
            this.showTargetDetail = true;
            this.dettaglioTarget = {
                'sections': [{
        
                    "name": `<h1>${data.TargetName}</h1>`,
                    "subName" : data.Categoria_Prodotto__c,
                    "underSubName": data.TargetDescription?.replace(/\n/gm, '<br>')
                }] 
            }
        }

    }

    closeModal = () => {
        this.showModal = false;
    }

    connectedCallback(){

        
        /*let currentUrl = window.location.href;
        if(!currentUrl.includes('javascriptIntegration') && !this.cssLoaded){
            this.cssLoaded = true;
            Promise.all([
                loadStyle(this, MobilityEngine + '/main.css')
            ]);
        }*/

        

        if(!this.stepName){
            this.stepName = 'messaggio';
        }
        this.showSpinner();
        super.connectedCallback();
        this.results_temp = this.results; 
        //console.log(this.proxyData(this.metadata));
        this.init();

        
    }

    proxyData(data){
        return JSON.parse(JSON.stringify(data));
    }

    async init(){
        if(this.stepName){
            let name = this.proxyData(this.stepName);
            console.log("Name: ", name)
            let res = await getConfiguration({cardType: name});
            this.config = res;
            //console.log(this.proxyData(res))
            //console.log(this.proxyData(this.config))
            if(res){
                let table = {};

                table.perPage = 3;
                table.encodes = {
                    IniziativaName : value => (value.IniziativaName),
                    TargetName : value => (value.TargetName),
                    IniziativaId : value => (value.IniziativaId),
                    TargetId: value => (value.TargetId),
                    TargetDescription: value => (value.TargetDescription),
                    Nome_Messaggio__c: value => (value.Nome_Messaggio__c),
                    Descrizione_Messaggio__c: value => (value.Descrizione_Messaggio__c),
                    IniziativaDescription: value => (value.IniziativaDescription),
                    Descrizione_dell_iniziativa__c: value => (value.Descrizione_dell_iniziativa__c),
                    Categoria_Prodotto__c : value => (value.Categoria_Prodotto__c),
                    Titolo__c:  value => (value.Titolo__c),
                    Sottotitolo__c:  value => (value.Sottotitolo__c),
                    Short_Message__c:  value => (value.Short_Message__c),
                    Message__c:  value => (value.Message__c),
                    TECH_URL_template_MC__c:  value => (value.TECH_URL_template_MC__c),
                    flagStyle:  value => (value.flagStyle),
                    flagText:  value => (value.flagText)
                }
                
                table.simpleMode = true;

                table.bind = {
                        origin: this,
                        target: 'tabledata',
                        load: this.getResults
                }

                if(res.actions){
                    for(let ac of res.actions){
                        
                        ac.isTypeSelectNavigate = ac.Type === 'SELECT_NAVIGATE'
                        
                        ac.isTypeOpenModal = ac.Type === 'OPEN_MODAL'
                        
                        ac.isTypeOpenDashboard = ac.Type === 'OPEN_DASHBOARD'

                        ac.isTypeSelectNavigateSingle = ac.Type === 'SELECT_NAVIGATE_SINGLE'

                        ac.isTypeOpenModalSingle = ac.Type === 'OPEN_MODAL_SINGLE'
                    }
                }

                this.tabledata = new DataGridModel(table);
                this.tabledata.preLoadCallback = () => {
                    this.showSpinner(true);
                };
                this.tabledata.loadCallback = (instance, result) => {
                    this.hideSpinner();
                    //console.log("pagerdata",this.tabledata);
                    this.ready=true;
                }
                this.tabledata.load();
            }
        }
    }

    get elements(){
        const processData = [];
        
        if(this.results_temp != this.results){
            this.ready = false;
            this.connectedCallback();
        }
        //console.log(this.tabledata);
        //console.log(this.tabledata.data);

        for(let row of this.tabledata.data){
            //console.log(row);
            processData.push({
                ...row.element
            });
        }
        const collection = new MobilityCardCollection({
            collection: processData,
            config: JSON.parse(JSON.stringify(this.config))
        }
        );
        
        let allData = collection.getAll();
        //console.log('all data: ', allData);
        return allData;
    }

    handleNavigateSingle(event){
        if(event.target && event.target.dataset){
            var recordId = event.target.dataset.value;
            if(recordId && this.backNavigateSingle){

                var record = this.results.filter( (element) => {
                    return element.Id === recordId;
                } );
                
                this.backNavigateSingle( (record && record.length == 1)? record[0] : {} );
            }
        }
            
    }
    
    handleBackSingle(event){
        if(event.target && event.target.dataset){
            var recordId = event.target.dataset.value;
            if(recordId && this.backOpenModalSingle){

                var record = this.results.filter( (element) => {
                    return element.Id === recordId;
                } );
                
                this.backOpenModalSingle( (record && record.length == 1)? record[0] : {} );
            }
        }
            
    
    }

    selectionCallback = (param) => {

        //console.log(param.index, param.pageId);
        ////console.log("getState: ", this.proxyData(this.getState()));
        let table = this.tabledata;
        let selection = param.index + (table.page * table.perPage);
        
        var row = this.proxyData(this.results[selection])
        //console.log(row);
        
        this.setSelection([row]);
        this.setState({pageId: param.pageId});
    }

    openDashboardCallback = (param) => {

        var state = this.getState();
        let table = this.tabledata;
        let selection = param.index + (table.page * table.perPage);
        
        var row = this.proxyData(this.results[selection]);
        //MessageService.openDashboard(row['DashboardId'], state.pageId);
        this.setSelection([row]);
        this.setState({pageId: param.pageId});

    }


	onNavigate(e){
		const { recordId } = e.currentTarget.dataset;

		if(this.navigateCallback){
			this.navigateCallback(recordId)
		}
	}
}