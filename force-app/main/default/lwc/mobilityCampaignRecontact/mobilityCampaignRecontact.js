import {
	track,
	api
} from 'lwc';

import {
	MobilitySObject
} from 'c/mobilitySObject';

import proccessRecontact from '@salesforce/apex/MobilityCampaignMemberController.proccessRecontact';

export default class MobilityCampaignRecontact extends MobilitySObject {
	componentView = 'mobilityCampaignRecontact';

	@track createTask = false;

	@api campaignMemberId;
	@api closeCallbackReload;

	@track dateTime;

	connectedCallback() {
		super.connectedCallback();
		this.hideSpinner();
	}

	onChangeSelect = (e) => {
		let target = e.target || e.currentTarget;
		let value = target.value;
		let name = target.name;
		let type = target.type;
		let checked = target.checked;

		if (type === 'checkbox') value = checked;

		this[name] = value;
	}

	onProccessRecontact = () => {
		this.showSpinner();
		proccessRecontact({
			campaignMemberId: this.campaignMemberId,
			isReminder: this.createTask,
			dateReminder: this.dateTime
		}).then((response) => {
			if (!response.isSuccess) throw new Error(response.errorMessage);

			console.log('onProccessRecontact', response);
			this.successMessage('Success', 'Processo eseguito con successo.');
		}).catch((err) => {
			console.log("errChangeStatus: ", err);
			this.alertMessage('Error', '' + err.message);
		}).finally(() => {
			this.hideSpinner();
		})
	}

	onSave = () => {
		this.onProccessRecontact();
	}

	changeData = (e) => {
		if (!e.target && !e.currentTarget) return;

		let target = e.target || e.currentTarget;
		this.dateTime = target.value;
	}

}