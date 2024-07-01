import {
  track
} from 'lwc';

import {
  MobilityAbstract
} from 'c/mobilityAbstract';

import {
  MobilityLeadCollection
} from 'c/mobilityLeadModel';

import getLead from '@salesforce/apex/MobilityLeadController.getLeads';

export default class MobilityLeadList extends MobilityAbstract {

  @track records = {};

  componentView = 'mobilityLeadList';

  connectedCallback() {
    super.connectedCallback();
    this.loadData().catch((result) => {
      this.criticalMessage();
    }).finally(() => {
      this.hideSpinner();
    });
  }

  loadData() {
    return getLead({
      limitRows: this.params.limit
    }).then((result) => {
      this.records = new MobilityLeadCollection({
        collection: this.proxyData(result)
      }, true);
      this.showNoData(this.records.length === 0);
    }).catch((err) => {
      console.log("err", err);
    });
  }

  get allData() {
    if (!this.records || !this.records.collection) return [];

    return this.records.getAll();
  }

}