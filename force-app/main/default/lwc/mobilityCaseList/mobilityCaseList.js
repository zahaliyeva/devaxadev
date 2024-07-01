import {
    track
} from 'lwc';

import {
    MobilityAbstract
} from 'c/mobilityAbstract';

import {
    MobilityCaseCollection
} from 'c/mobilityCaseModel';

import getCase from '@salesforce/apex/MobilityCaseListController.getCase';

export default class MobilityCaseListWidget extends MobilityAbstract {

    @track records = {};
    componentView = 'mobilityCaseList';

    connectedCallback() {
        super.connectedCallback();
        this.loadData().catch((result) => {
            this.criticalMessage();
        }).finally(() => {
            this.hideSpinner();
        })
    }

    loadData() {
        return getCase({
            limitRows: this.params.limit
        }).then((result) => {
            this.records = new MobilityCaseCollection({
                collection: this.proxyData(result)
            }, true);
            this.showNoData(this.records.length === 0);
        }).catch((err) => {
            console.log("err", err);
        });
    }

    get allData() {
        if (!this.records) return [];
        if (!this.records.collection) return [];

        return this.records.getAll();
    }


}