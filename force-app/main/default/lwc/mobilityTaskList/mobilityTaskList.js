import {LightningElement, track, api, wire} from 'lwc';

import {MobilityAbstract} from 'c/mobilityAbstract';

import {MobilityTaskCollection} from 'c/mobilityTaskModel';

import getTask from '@salesforce/apex/MobilityTaskListController.getTask';

export default class MobilityTaskListWidget extends MobilityAbstract {

    @track records = {};
    componentView = 'mobilityTaskList';

    connectedCallback() {
        super.connectedCallback();
        this.loadData().catch((result) => {
            this.criticalMessage();
        }).finally(() => {
            this.hideSpinner();
        })
    }

    loadData() {
        return getTask({
            limitRows: this.params.limit
        }).then((result) => {
            this.records = new MobilityTaskCollection({
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