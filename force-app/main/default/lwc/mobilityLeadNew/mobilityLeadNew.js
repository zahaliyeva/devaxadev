import {
	track
} from 'lwc';

import {
	MobilityAbstract
} from 'c/mobilityAbstract';

export default class MobilityLeadNew extends MobilityAbstract {
	componentView = 'mobilityLeadNew';

	customLayout = {};

	connectedCallback() {
		super.connectedCallback();

		this.hideSpinner();

		this.bindLeadUpdate = {
			bind: this
		}
	}

	readyCallback = (target) => {
		this.customLayout = target;
	}

	save = () => {
	if (this.customLayout.saveData){
		this.customLayout.saveData().then().catch((err) => {
            console.log("Error to save: ", err);
        });
	}}


	saveCallback(result) {
		this.navigateTo({
			name: 'MobilityLeadDetail',
			params: {
				recordId: result.record.Id
			}
		})
	}
}