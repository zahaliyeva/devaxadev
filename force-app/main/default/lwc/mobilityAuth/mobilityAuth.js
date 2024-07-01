import {
	MobilityAbstract
} from "c/mobilityAbstract";

import {
	api,
	track
} from "lwc";

import {
	PostMessage
} from 'c/postMessage';

import getCounters from '@salesforce/apex/MobilityWidgetsHomepage.getCounters';

export default class MobilityAuth extends MobilityAbstract {
	
	componentView = 'mobilityAuth';

	connectedCallback() {
		super.connectedCallback();
	}

	authRefresh = (params) => {
		PostMessage.authRefresh(this.params.id, params);
	}

	refreshCallback(){
		this.loadData();
	}
	
	async loadData(){
		const counters = this.params.counters.split(',');
		const result = await getCounters({counters});

		this.authRefresh(result);
	}
}