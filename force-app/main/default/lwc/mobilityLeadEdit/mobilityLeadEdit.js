/* eslint-disable guard-for-in */
import {
	track
} from 'lwc';

import {
	MobilityAbstract
} from 'c/mobilityAbstract';

import getCountActivities from '@salesforce/apex/MobilityLeadController.getCountActivities';
import getAccountReference from '@salesforce/apex/MobilityLeadController.getAccountReference';
import getQueueAxa from '@salesforce/apex/MobilityLeadController.getQueueAxa';
import getDuplicatedCheck from '@salesforce/apex/MobilityLeadController.getDuplicatedCheck';
import getSubStatusList from '@salesforce/apex/MobilityLeadController.getSubStatusList';
import getCountryCodes from '@salesforce/apex/MobilityLeadController.getCountryCodes';

export default class MobilityLeadEdit extends MobilityAbstract {
	componentView = 'mobilityLeadEdit';

	@track showEvent = false;
	@track showTask = false;
	@track showSubStatus = false;

	@track valuesSubStatus = [];

	@track data = {
		Account_referente__c: null,
		Sottostato_del_Lead__c: null
	}

	@track labelWarningBack;
	@track labelWarningConfirmation;

	queueAxa;
	duplicatedData;
	oldStatus;

	customLayout = {};

	get eventData() {
		return {
			WhoId: this.params.recordId
		}
	}

	get taskData() {
		return {
			WhoId: this.params.recordId,
			Status: 'Open'
		}
	}

	get invokeAccountSearch() {
		return getAccountReference;
	}

	get lead() {
		if (!this.customLayout) return {};
		if (!this.customLayout.sections) return {};

		return this.customLayout.sections.record;
	}

	get isDisabledSubTaskConfirm(){
		return this.lead.Sottostato_del_Lead__c == null || this.lead.Sottostato_del_Lead__c === ''
	}

	get accountReferenteName(){
		if(!this.lead) return '';
		if(!this.lead.Account_referente__r) return '';

		return this.lead.Account_referente__r.Name
	}

	connectedCallback() {
		super.connectedCallback();

		getQueueAxa().then((results) => {
			if (results.length > 0) {
				this.queueAxa = results[0].Id;
			}

			return getCountryCodes();
		}).then((result)=>{
			let countries = [...result.countries].sort();

			let pickListMap = {};
			for(let index in countries){
				let value = countries[index];

				pickListMap[value] = value;
			}

			let rulesClean = {};
			rulesClean.Country = {
			    type: 'PICKLIST',
			    required: false,
			    pickListMap: pickListMap
			}



			console.log(rulesClean);
			this.customLayout.changeFields(rulesClean);
		}).finally(()=>{
			this.hideSpinner();
		})
	}

	loadCallback = (result) => {
		console.log('LoadCallback: ', JSON.parse(JSON.stringify(result)));
		this.oldStatus = result.record.Status;
	}

	readyCallback = (target) => {
		this.customLayout = target;
		console.log('target:', JSON.stringify(target));
	}

	accountSearch = (result) => {
		this.accountReferences = result.searchAccounts;
	}

	accountSelect = (results) => {
		if (results.length > 0) {
			this.lead.Account_referente__c = results[0].Id;
			this.customLayout.update();
		}
	}

	onChange = (e) => {
		let name = e.target.name;
		let value = e.target.value;
		if(name === 'Status'){
			this.oldStatus = this.lead[name];
		}
		this.lead[name] = value;
		this.customLayout.update();
	}

	customLayoutUpdate = (name, value) => {

		let statusList = ["Lavorazione conclusa",
			"Non Lavorato",
			"Non Assegnato\\KOKO"];
		//let requestData = this.customLayout.sections.record;

		if (name === 'Status') {
			
			if (value !== 'Not interested') {
				this.lead.Sottostato_del_Lead__c = null;
				this.customLayout.update();
			}

			

			if (value === 'Not interested' && !(statusList.includes(this.oldStatus)&& this.oldStatus!== value))
			 {
				this.subStatusList().then((result) => {
					let returnArray = [];

					for (let key in result) {
						returnArray.push({
							label: key,
							value: result[key]
						})
					}

					this.valuesSubStatus = returnArray;
					this.confirmWarningCallback();
				}).catch((err) => {
					this.alertMessage('Error', err.message);
				})
			} 
			//and viene dun status bloccato
			//if(statusList.includes(this.oldStatus) && this.oldStatus !== requestData.Status )
			else
				if(value === 'Not interested' && statusList.includes(this.oldStatus) && this.oldStatus !== value )
					this.saveLeadWithComplete();
		}
	}

	confirmWarningCallback = (e) => {
		let requestData = this.customLayout.sections.record;

		if (requestData.Status === 'Wrong contact information') {
			this.saveLeadWithComplete();
		} else if (requestData.Status === 'Duplicated Lead') {
			this.saveLeadWithComplete();
		} else if (requestData.Status === 'Appointment') {
			this.showEvent = !this.showEvent;
		} else if (requestData.Status === 'To be processed') {
			//this.saveComplete();
			//this.showTask = !this.showTask;
		} else if (requestData.Status === 'Not interested') {
			this.showSubStatus = !this.showSubStatus;
		} else if (requestData.Status === 'Call again') {
			this.showTask = !this.showTask;
		}
	}

	cancelAlertCallback = (e) => {
		let requestData = this.customLayout.sections.record;

		if (requestData.Status === 'To be processed') {
			return this.navigateTo({
				name: 'MobilityLeadDetail',
				params: {
					recordId: requestData.Id
				}
			})
		}
	}

	save = () => {
		if(!this.customLayout.checkData()) return;
		 
		let requestData = this.customLayout.sections.record;
		let statusList = ["Lavorazione conclusa",
			"Non Lavorato",
			"Non Assegnato\\KO"];
		if(statusList.includes(this.oldStatus) && this.oldStatus !== requestData.Status )
			this.saveLeadWithComplete();
		else{
			if(requestData.Status != 'Not interested') requestData.Sottostato_del_Lead__c='';

			if (requestData.Status === 'Appointment' || requestData.Status === 'Call again') {
				this.countActivities().then((result) => {
					if (requestData.Status === 'Appointment' && result.listEvent.length === 0) {
						this.warningMessage(this._label.leadEdit_warning_title, this._label.leadEdit_warningAppointment_message);
						this.labelWarningBack = this._label.leadEdit_warningAppointment_back;
						this.labelWarningConfirmation = this._label.leadEdit_warningAppointment_confirmation;
					} else if (requestData.Status === 'Call again' && result.listTask.length === 0) {
						this.warningMessage(this._label.leadEdit_warning_title, this._label.leadEdit_warningCallAgain_message);
						this.labelWarningBack = this._label.leadEdit_warningCallAgain_back;
						this.labelWarningConfirmation = this._label.leadEdit_warningCallAgain_confirmation;
					} else {
						this.saveLeadWithComplete();
					}
				})
			} else if (requestData.Status === 'Duplicated Lead') {
				this.duplicatedCheck().then((result) => {
					this.duplicatedData = result;
					if (!result.isDuplicated) {
						this.alertMessage(this._label.leadEdit_warning_title, this._label.leadEdit_alertDuplicatedLead_message);
						this.labelAlertBack = this._label.leadEdit_alertDuplicatedLead_back;
					} else {
						this.warningMessage(this._label.leadEdit_warning_title, this._label.leadEdit_warningDuplicatedLead_message);
					}
				})
			} else if (requestData.Status === 'To be processed' && requestData.LeadSource === 'Web') {
				this.warningMessage(this._label.leadEdit_warning_title, this._label.leadEdit_warningToBeProcessed_message);
				this.labelWarningBack = this._label.leadEdit_warningToBeProcessed_back;
				this.labelWarningConfirmation = this._label.leadEdit_warningToBeProcessed_confirmation;
			} else if (requestData.Status === 'Wrong contact information') {
				this.warningMessage(this._label.leadEdit_warning_title, this._label.leadEdit_warningWrongContact_message);
				this.labelWarningBack = this._label.leadNew_cancel;
				this.labelWarningConfirmation = this._label.messages_confirmation;
			} else {
				this.saveLeadWithComplete();
			}
		}
	}

	countActivities = () => {
		return getCountActivities({
			leadId: this.params.recordId
		})
	}

	duplicatedCheck = () => {
		return getDuplicatedCheck({
			leadId: this.params.recordId
		})
	}

	subStatusList = () => {
		return getSubStatusList();
	}

	saveLeadWithComplete = () => {
		return this.saveLead().then(this.saveComplete);
	}

	saveLeadPre = () => {
		let lead = this.customLayout.sections.record;
		if (lead.Status === 'Wrong contact information') {
			lead.TECH_Send_Email_Notification__c = false;
			lead.OwnerId = this.queueAxa;
		} else if (lead.Status === 'Duplicated Lead') {
			if (this.duplicatedData && this.duplicatedData.isDuplicatedContext) {
				lead.OwnerId = this.duplicatedData.currentUserId;
				lead.TECH_Send_Email_Notification__c = true;
			}
		}

		delete lead.Owner;
		delete lead.Name;
	}

	saveLead = () => {
		this.saveLeadPre();

		return this.customLayout.saveData();
	}

	saveComplete = () => {
		let requestData = this.customLayout.sections.record;

		if (requestData.Status === 'Wrong contact information') return this.saveCompleteToListVIew();

		this.navigateTo({
			name: 'MobilityLeadDetail',
			params: {
				recordId: requestData.Id
			}
		})
	}

	saveCompleteToListVIew = () => {
		this.navigateTo({
			name: 'MobilityLeadListView'
		})
	}
}