import {
	MobilityAbstract
} from 'c/mobilityAbstract';

export default class MobilityCampaignEdit extends MobilityAbstract {
	componentView = 'MobilityCampaignEdit';

	customLayout = {};

	connectedCallback() {
		super.connectedCallback();

		this.hideSpinner();

		this.bindCampaignUpdate = {
			bind: this
		}
	}

	readyCallback = (target) => {
		this.customLayout = target;
	}

	save = () => {
		if (this.customLayout.saveData) this.customLayout.saveData();
	}

	saveCallback(result) {
		this.navigateTo({
			name: 'MobilityCampaignDetail',
			params: {
				recordId: result.record.Id
			}
		})
	}
}