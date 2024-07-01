import {
	LightningElement,
	track,
	api,
	wire
} from 'lwc';

import {
	MobilityAbstract
} from 'c/mobilityAbstract';
import {
	MobilityEventCollection
} from 'c/mobilityEventModel';

import getEvents from '@salesforce/apex/MobilityEventController.getEvents';

export default class MobilityEventList extends MobilityAbstract {

	@track records = {};
	componentView = 'mobilityEventList';

	connectedCallback() {
		super.connectedCallback();
		this.loadData().catch((result) => {
			this.criticalMessage();
		}).finally(() => {
			this.hideSpinner();
		})
	}

	loadData() {
		return getEvents({
			limitRows: this.params.limit
		}).then((result) => {
			this.records = new MobilityEventCollection({
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