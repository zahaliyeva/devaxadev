import {
	MobilityAbstract
} from 'c/mobilityAbstract';

export default class MobilityCampaignNew extends MobilityAbstract {
	componentView = 'MobilityCampaignNew';

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
		if (result.isSuccess) {
			this.navigateTo({
				name: 'MobilityCampaignDetail',
				params: {
					recordId: result.record.Id
				}
			})
		} else {
			this.warningMessage('Error'.result.errorMessage)
		}
	}
}