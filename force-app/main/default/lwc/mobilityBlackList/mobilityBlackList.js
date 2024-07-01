import {
	api,
	track
} from 'lwc';

import {
	MobilityAbstract
} from 'c/mobilityAbstract';

import {
	MobilityAccountModel
} from 'c/mobilityAccountModel';

import getAccount from '@salesforce/apex/MobilityAccountController.getAccountByNdg';
import updateAccountBlackList from '@salesforce/apex/MobilityAccountController.updateAccountBlackList';
import getSobjectFields from '@salesforce/apex/MobilityAccountController.getSobjectFields';

export default class MobilityBlackList extends MobilityAbstract {
	componentView = 'mobilityBlackList';

	@api changeCallback;

	@track account = new MobilityAccountModel();
	@track includeInAllCampaign = false;
	@track blacklistProcessDomain = [];

	showSave = true;

	get processOptions(){
		const valuesSelected = this.account?.Blacklist_Processi__c?.split(';') || [];
		return this.blacklistProcessDomain?.map(({label, value})=>({
			label, value, checked: valuesSelected.includes(value)
		}));
	}

	connectedCallback() {
		super.connectedCallback();
		this.loadData().catch((result) => {
			console.log('catch');
			this.criticalMessage();
		}).finally(() => {
			this.hideSpinner();
		})
	}

	async loadData() {
		const result = await getAccount({
			ndgId: this.params.ndgId || '12345'
		});

		this.account = new MobilityAccountModel(this.proxyData(result));

		const objectDefinition = await getSobjectFields({sObjectName: 'Account'});
		const blacklistProcessDefinition = objectDefinition?.find(e=>e.fieldName === 'Blacklist_Processi__c');
		this.blacklistProcessDomain = blacklistProcessDefinition?.definition?.picklistValues?.filter(e=>e.active)?.map(({label, value})=>({label, value}));
		console.log(this.blacklistProcessDomain);
		console.log(this.account?.Blacklist_Processi__c?.split(';') || []);
	}

	onClick() {
		let blackListValidate = this.account.blackListValidate();

		if (blackListValidate.isSuccess) {
			this.showSpinner(true);

			updateAccountBlackList({
				account: this.account._getData()
			}).then((result) => {
				if (!result.isSuccess) throw new Error(result.errorMessage);
				return this.loadData();
			}).then((result) => {
				this.successMessage('Blacklist', this._label.blacklist_save_success);
			}).catch((err) => {
				this.alertMessage('', this._label.blacklist_save_failed);
				console.log('err', err);
			}).finally(() => {
				this.hideSpinner();
			})
		} else {
			this.alertMessage('', blackListValidate.errorMessage);
		}
	}

	onChangeAccount(e) {
		this.changeData(e, this.account);

		if(this.changeCallback) this.changeCallback(this.account);

		this.setState({
			includeInAllCampaign: false
		})
	}

	onChangeProccess(e){
		const { name, checked, type } = e.target;
		const { value } = e.target.dataset;
		const valuesSelected = this.account?.Blacklist_Processi__c?.split(';') || [];

		const filtered = valuesSelected.filter(e=>e !== value);

		if(checked) filtered.push(value);
		this.account = new MobilityAccountModel({...this.account, Blacklist_Processi__c: filtered.join(';')});
	}

	onChange(e) {
		let name = e.target.name;
		let checked = e.target.checked;

		if (name === 'includeInAllCampaign') {
			if (checked) {
				this.account.blackListReset();
			}
		}

		this.changeData(e, this);
	}
}