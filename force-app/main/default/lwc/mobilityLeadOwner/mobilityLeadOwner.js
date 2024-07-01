import {
	track,
	api
} from 'lwc';

import {
	MobilityAbstract
} from 'c/mobilityAbstract';

import {
	DataGridModel
} from 'c/dataGridModel';

import getUserPartners from '@salesforce/apex/MobilityUserController.getUserPartners';
import getQueues from '@salesforce/apex/MobilityUserController.getQueues';
import changeOwner from '@salesforce/apex/MobilityLeadController.changeOwner';

export default class MobilityLeadOwner extends MobilityAbstract {
	componentView = 'mobilityLeadOwner';

	@api closeCallback;
	@api changeCallback;
	@api listSelected;

	@track typeOwnerSelected = 'user_partner';
	@track userPartnerData = {};
	@track queueData = {};

	typesOwner = [
		{
			label: 'Utente Partner',
			value: 'user_partner'
		},
		{
			label: 'Area di Attesa',
			value: 'queue'
		}
	];
	connectedCallback() {
		super.connectedCallback();

		this.loadUserPartner().then(()=>{
			return this.loadQueues()
		})
	}

	get isUserPartner(){
		return this.typeOwnerSelected === 'user_partner';
	}

	get isQueue(){
		return this.typeOwnerSelected === 'queue';
	}

	loadUserPartner() {
		return new Promise((resolve, reject)=>{
			let tableData = {};

			tableData.perPage = 10;

			tableData.encodes = {}

			tableData.actions = []

			tableData.fixedFirst = true;
			tableData.fixedLast = false;
			tableData.viewSelectRow = true;
			tableData.singleSelect = true;
			tableData.maxHeight = 300;

			tableData.bind = {
				origin: this,
				target: 'userPartnerData',
				load: getUserPartners
			};

			this.records = new DataGridModel(tableData);

			this.records.preLoadCallback = () => {
				this.showSpinner(true);
			};

			this.records.loadCallback = (instance, result) => {
				this.hideSpinner();
				resolve(result);
			};

			this.records.errorCallback = (instance, result) => {
				reject(result);
			};

			this.records.load();
		})
	}


	loadQueues() {
		return new Promise((resolve, reject)=>{
			let tableData = {};

			tableData.perPage = 10;

			tableData.encodes = {
				Queue: (value) => (value.Name)
			}

			tableData.actions = []

			tableData.fixedFirst = true;
			tableData.fixedLast = false;
			tableData.viewSelectRow = true;
			tableData.singleSelect = true;
			tableData.maxHeight = 300;

			tableData.bind = {
				origin: this,
				target: 'queueData',
				load: getQueues
			};

			this.records = new DataGridModel(tableData);
			this.records.setFilter('SobjectType', ['Lead'])

			this.records.preLoadCallback = () => {
				this.showSpinner(true);
			};

			this.records.loadCallback = (instance, result) => {
				this.hideSpinner();
				resolve(result);
			};
			this.records.errorCallback = (instance, result) => {
				reject(result);
			};

			this.records.load();
		})
	}

	typeChange(e){
		let value = e.target.value;
		
		this.typeOwnerSelected = value;
	}

	onClose(e){
		if(this.closeCallback) this.closeCallback(e);
	}


	get targetData(){
		if(this.isUserPartner) return this.userPartnerData;

		return this.queueData;
	}

	get typeOwner(){
		if(this.isUserPartner) return 'user_partner';

		return 'queue';
	}

	get isDisabledConfirm(){
		return !this.targetData || !this.targetData.listSelected || this.targetData.listSelected.length === 0;
	}

	onSave(){
		this.showSpinner();
		changeOwner({
			entityIds: this.listSelected,
			queueId: this.targetData.listSelected[0],
			typeOwner: this.typeOwner
		}).then((result)=>{
			if(!result.isSuccess) throw new Error(result.errorMessage);

			this.successMessage('Success', 'Owner Cambiato con successo');
			if(this.changeCallback) this.changeCallback(result);
		}).catch((err)=>{
			this.alertMessage('Error', err.message);
		}).finally(()=>{
			this.hideSpinner();
		})
	}

	onConfirmSuccess = (e) => {
		if(this.parent){
			this.parent.onShowLeadOwner();
		}
	}

}