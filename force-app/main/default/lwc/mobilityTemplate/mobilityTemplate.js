import {
	track
} from 'lwc';

import {
	MobilityAbstract
} from 'c/mobilityAbstract';

export default class MobilityTemplate extends MobilityAbstract {
	componentView = 'mobilityTemplate';

	connectedCallback() {
		super.connectedCallback();

		this.loadData();
	}

	loadData(){
		setTimeout(()=>{
			this.hideSpinner();
		}, 1000);
	}
}