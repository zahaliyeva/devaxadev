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
	MobilityCampaignCollection
} from 'c/mobilityCampaignModel';

import getCountersWidget from '@salesforce/apex/MobilityCampaignController.getCountersWidget';

export default class MobilityCampaignList extends MobilityAbstract {

	@track records = [];

	componentView = 'mobilityCampaignList';

	connectedCallback() {
		super.connectedCallback();
		this.loadData().catch((result) => {
			this.criticalMessage();
		}).finally(() => {
			this.hideSpinner();
		})
	}

	loadData() {
		return getCountersWidget({
			limitRows: this.params.limit
		}).then((result) => {
			this.records = new MobilityCampaignCollection({
				collection: this.proxyData(result.campaignsList),
				counterObject: this.proxyData(result.getCampaignsCounters),
				counterObjectClosed: this.proxyData(result.getCampaignClosedMember),
				counterObjectPriority: this.proxyData(result.getCampaignPriority),
			});
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