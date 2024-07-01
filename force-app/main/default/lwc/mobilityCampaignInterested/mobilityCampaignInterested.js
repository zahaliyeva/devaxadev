import {
	track,
	api
} from 'lwc';

import {
	MobilitySObject
} from 'c/mobilitySObject';

import {
	DataGridModel
} from 'c/dataGridModel';

import proccessInterested from '@salesforce/apex/MobilityCampaignMemberController.proccessInterested';

export default class MobilityCampaignInterested extends MobilitySObject {
	componentView = 'mobilityCampaignInterested';

	@track handlerEvent = {};

	@track createOpportunity = true;
	@track createAppoiment = false;
	
	@track showEvent = false;

	@api campaignTitle;
	@api campaignMemberId;
	@api closeCallbackReload;

	labelWarningBack;
	labelWarningConfirmation;
	selectedAction;

	eventToSave = {sobjectType: 'Event'};

	get eventData() {
		return {
			WhoId: this.campaignMemberId
		}
	}

	get fieldsEventOverride(){
		return {
			Subject: {
				readOnly: true,
				value: `Appuntamento per campagna ${this.campaignTitle}`
			},
			Luogo_appuntamento__c: {
				value: `Presso cliente`
			}
		}
	}

	connectedCallback() {
		super.connectedCallback();
		this.hideSpinner();
	}

	sendEmailOwner() {
	    this.labelWarningBack = 'No';
	    this.labelWarningConfirmation = 'Si';

	    this.selectedAction = 'sendEmailOwner';
	    this.warningMessage('', 'Vuoi inviare una Email di notifica al nuovo Owner?');
	}

	warningConfirm = () => {
		if(this.selectedAction === 'sendEmailOwner'){
			this.onUpdateInterested(true);
		}
	}

	warningCancel = () => {
		this.onUpdateInterested();
	}

	hookEvent = (hook) => {
		this.handlerEvent = hook;
	}

	onChangeSelect = (e) => {
		let target = e.target || e.currentTarget;
		let value = target.value;
		let name = target.name;
		let type = target.type;
		let checked = target.checked;

        if (type === 'checkbox') value = checked;

        if(name === 'createOpportunity' && !value) this.createAppoiment = false;

		this[name] = value;
	}

	onUpdateInterested = (sendEmail = false) => {
		this.showSpinner();
		proccessInterested({
			campaignMemberId: this.campaignMemberId,
			createOpportunity: this.createOpportunity,
			createEvent: this.createAppoiment,
			eventData: this.eventToSave,
			sendEmail
		}).then((response)=>{
			if (!response.isSuccess) throw new Error(response.errorMessage);

            console.log('invokeCreateProposal', response);
			this.successMessage('Success','Processo eseguito con successo.');
        }).catch((err) => {
            console.log("errChangeStatus: ", err);
            this.alertMessage('Error', '' + err.message);
        }).finally(() => {
        	this.hideSpinner();
        })
	}

	toogleEvent = () => {
		this.showEvent = !this.showEvent;
	}

	onSave = (e) => {
		if(this.createAppoiment){
			this.toogleEvent();
		}else{
			this.onUpdateInterested();
		}
	}

	onSaveEvent = (eventData) => {
		this.eventToSave = eventData;
		this.sendEmailOwner();
	}

}