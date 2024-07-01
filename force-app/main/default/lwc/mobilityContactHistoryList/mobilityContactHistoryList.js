import {
    MobilityAbstract
} from "c/mobilityAbstract";

import {
    track,
    api
} from "lwc";

import { MobilityLib } from 'c/mobilityLib';
import getContactHistory from "@salesforce/apex/MobilityAccountController.getContactHistory";
import getFilteredContactHistory from "@salesforce/apex/MobilityAccountController.getFilteredContactHistory";
import getContactHistoryLead from "@salesforce/apex/MobilityAccountController.getContactHistoryPage";

import {
    MobilityContactHistoryCollection
} from "c/mobilityContactHistoryModel";

export default class MobilityContactHistoryList extends MobilityAbstract {
    @track records = {};
    componentView = 'mobilityContactHistoryList';

    @api leadId = null;
    @api invokeCollout = false;
    @api
    get inputRecords() {
        return this.records;
    }
    set inputRecords(value) {
        this.records = new MobilityContactHistoryCollection({
            collection: this.proxyData(value)
        }, true);
        this.showNoData(this.records.length === 0);
    }

    baseUrl;
    flying = "row customerContactHistoryRow  flying bgw_zind ";
    @api filterCallback;

    filters = [

        { label : '-', value: ''}, 
        { label : 'Feedback', value: 'Feedback'},
        { label : 'Comunicazioni Feedback', value: 'Comunicazioni Feedback'},
        { label : 'Eventi da MyAXA e PCC', value: 'Eventi da MyAXA e PCC'},
        { label : 'Comunicazioni su Campagne', value: 'Comunicazioni su Campagne'},
        { label : 'Comunicazioni Informative', value: 'Comunicazioni Informative'},
        { label : 'Comunicazioni Contrattuali', value: 'Comunicazioni Contrattuali'},
        { label : 'Comunicazioni di Processo', value: 'Comunicazioni di Processo'},
        { label : 'Acquisti via WEB', value: 'Acquisti via WEB'},
        { label : 'Richieste Digitali', value: 'Richieste Digitali'},

    ]

    chosenFilter;

    filterChange(event){

        this.chosenFilter = event.target.value;
        this.showSpinner();
        this.records = null;
        this.spinnerOverlay = true;
        this.applyFilter().catch((result) => {
            console.log(result);
            this.criticalMessage();
        }).finally(() => {
            this.hideSpinner();
            this.spinnerOverlay = false;
        });
        

    }

    applyFilter(){

        
        if(this.filterCallback){
            return this.filterCallback(this.chosenFilter);
        }
        
        return this.loadFilteredContactHistoryAccount(this.chosenFilter);
        
    }

    connectedCallback() {
        super.connectedCallback();
        
        if (this.invokeCollout) { this.flying += 'top35'; this.hideSpinner(); return; }

        this.loadData().catch((result) => {
            console.log(result);
            this.criticalMessage();
        }).finally(() => {
            
                
            
                this.flying += 'top0';
            
            console.log(this.flying);
            this.hideSpinner();
        });
    }

    loadData() {
        var res;
        if (this.leadId || this.params.leadId) res = this.loadContactHistoryLead();
        else
            res = this.loadContactHistoryAccount();

        
        return res;
    }

    loadFilteredContactHistoryAccount() {
        console.log("chosen filter: ", this.chosenFilter);
        return getFilteredContactHistory({
            limitRows: this.params.limit,
            ndgId: this.params.ndgId,
            Filter: this.chosenFilter
        }).then((result) => {
            if(result.CRMUrl){
                MobilityLib.setBaseUrl(result.CRMUrl);
                console.log(MobilityLib.baseUrl);
            }
            if (result.values && result.values.ContactHistoryList) {
                this.records = new MobilityContactHistoryCollection({
                    collection: this.proxyData(result.values.ContactHistoryList)
                }, true);
                for(var rec of this.records.getAll()){
                    rec.redirectCallback = this.openCustom;
                    
                }
                console.log(this.records);
                this.showNoData(this.records.length === 0);
            } else {
                this.showNoData(true);
            }
        })
    }

    loadContactHistoryAccount() {
        return getContactHistory({
            limitRows: this.params.limit,
            ndgId: this.params.ndgId
        }).then((result) => {
            if(result.CRMUrl){
                MobilityLib.setBaseUrl(result.CRMUrl);
                console.log(MobilityLib.baseUrl);
            }
            if (result.values && result.values.ContactHistoryList) {
                this.records = new MobilityContactHistoryCollection({
                    collection: this.proxyData(result.values.ContactHistoryList)
                }, true);
                for(var rec of this.records.getAll()){
                    rec.redirectCallback = this.openCustom;
                }
                console.log(this.records);
                this.showNoData(this.records.length === 0);
            } else {
                this.showNoData(true);
            }
        })
    }

    loadContactHistoryLead() {
        return getContactHistoryLead({
            limitRows: this.params.limit,
            leadId: this.leadId || this.params.leadId
        }).then((result) => {
            if (result.values && result.values.ContactHistoryList) {
                this.records = new MobilityContactHistoryCollection({
                    collection: this.proxyData(result.values.ContactHistoryList)
                }, true);
                this.showNoData(this.records.length === 0);
            } else {
                this.showNoData(true);
            }
        })
    }

    get allData() {
        if (!this.records) return [];
        if (!this.records.collection) return [];

        return this.records.allByDate();
    }
}