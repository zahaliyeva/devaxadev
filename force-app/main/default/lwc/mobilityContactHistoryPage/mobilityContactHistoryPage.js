/* eslint-disable no-else-return */
/* eslint-disable no-console */
import {
    MobilityAbstract
} from "c/mobilityAbstract";
import {
    track,
    api
} from "lwc";
import getContactHistoryPage from "@salesforce/apex/MobilityAccountController.getContactHistoryPage";


import getFilteredContactHistory from "@salesforce/apex/MobilityAccountController.getFilteredContactHistoryPage";
import {
    MobilityPaginationModel
} from "c/mobilityPaginationModel";
import {
    MobilityContactHistoryCollection
} from "c/mobilityContactHistoryModel";

import getContactHistoryPageLead from "@salesforce/apex/MobilityLeadController.getContactHistoryPage";
import { MobilityLib } from 'c/mobilityLib';

export default class MobilityContactHistoryPage extends MobilityAbstract {
    componentView = 'mobilityContactHistoryPage';

    @api leadId = null;
    @api perPage = null;
    @api maxPerPage = null;
    @api lengthList = null;

    @track records = {};
    @track pagination = {};

    @track invokeCollout = true;

    filter = null;
    
    connectedCallback() {
        super.connectedCallback();
        this.loadData().catch((result) => {
            this.criticalMessage();
        })
    }

    loadData(page) {
        if (this.leadId || this.params.leadId) {
            return this.loadContactHistoryLead(page);
        } else {
            if(this.filter) return this.loadFilteredContactHistoryAccount(this.filter, page);
            return this.loadContactHistoryAccount(page);
        }
    }

    loadContactHistoryLead(page = 0) {
        return getContactHistoryPageLead({
            leadId: this.leadId || this.params.leadId,
            page: page,
            perPage: this.perPage || this.params.perPage || 5,
            maxPerPage: this.maxPerPage || this.params.maxPerPage || 10,
            lengthList: this.lengthList || this.params.lengthList || 2
        }).then((result) => {
            if(result.baseUrl){
                MobilityLib.setBaseUrl(result.baseUrl);
                console.log(MobilityLib.baseUrl);
            }
            this.pagination = new MobilityPaginationModel(
                this.proxyData(result)
            );
            this.records = new MobilityContactHistoryCollection({
                collection: this.proxyData(this.pagination.elements)
            }, true);
            this.showNoData(this.records.length === 0);
        }).catch((err) => {
            console.log('err', this.proxyData(err));
        }).finally(() => {
            this.hideSpinner();
        })
    }

    loadContactHistoryAccount(page = 0) {
        return getContactHistoryPage({
            ndgId: this.params.ndgId || '12345',
            page: page,
            perPage: this.params.perPage || 5,
            maxPerPage: this.params.maxPerPage || 10,
            lengthList: this.params.lengthList || 2
        }).then((result) => {
            if(result.baseUrl){
                MobilityLib.setBaseUrl(result.baseUrl);
                console.log(MobilityLib.baseUrl);
            }
            this.pagination = new MobilityPaginationModel(
                this.proxyData(result)
            );
            this.records = new MobilityContactHistoryCollection({
                collection: this.proxyData(this.pagination.elements)
            }, true);
            console.log(this.proxyData(this.pagination.elements));
        console.log(this.records.collection);
            this.records.getAll().forEach( (el) => {
                el.redirectCallback = this.redirect;
            } );
            this.showNoData(this.records.length === 0);
        }).catch((err) => {
            console.log('err', this.proxyData(err));
        }).finally(() => {
            this.hideSpinner();
        })
    }

    loadFilteredContactHistoryAccount = (value, page = 0) => {
        this.filter = value;
        return getFilteredContactHistory({
            ndgId: this.params.ndgId || '12345',
            page: page,
            perPage: this.params.perPage || 5,
            maxPerPage: this.params.maxPerPage || 10,
            lengthList: this.params.lengthList || 2,
            Filter: value
        }).then((result) => {
            if(result.baseUrl){
                MobilityLib.setBaseUrl(result.baseUrl);
                console.log(MobilityLib.baseUrl);
            }
            this.pagination = new MobilityPaginationModel(
                this.proxyData(result)
            );
            this.records = new MobilityContactHistoryCollection({
                collection: this.proxyData(this.pagination.elements)
            }, true);
            console.log(this.proxyData(this.pagination.elements));
        console.log(this.records.collection);
            for(var rec of this.records.getAll()){
                
                rec.redirectCallback = this.redirect;
            }
            this.showNoData(this.records.length === 0);
        }).catch((err) => {
            console.log('err', this.proxyData(err));
        }).finally(() => {
            this.hideSpinner();
        })
    }

    onChangePage = (page) => {
        this.records = null;
        this.showSpinner(true);

        this.loadData(page);
        
    }

    get allData() {
        if (!this.records) return [];
        if (!this.records.collection) return [];

        return this.records.allByDate();
        
    }

    redirect  (recordId, recordType, title) {
        
        window.open('/crm/apex/javascriptIntegration?component=mobilityCustomDetailPage&id=mobilityCustomDetailPage&showContain=true&recordId='+recordId+'&recordType='+recordType+'&title='+title, '_blank');
    }
}