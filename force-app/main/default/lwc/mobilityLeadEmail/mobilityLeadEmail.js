import {
	track,
	api
} from 'lwc';

import {
	MobilitySObject
} from 'c/mobilitySObject';

import getLeadEmail from '@salesforce/apex/MobilityLeadController.getLeadEmail';

export default class MobilityLeadEmail extends MobilitySObject {
	componentView = 'mobilityLeadEmail';

	@api sendCallback

	@track dataEmail = {};
	@track lead = {};
	@track currentUser = {};

	handlerEmail = {};

	connectedCallback() {
		super.connectedCallback();

		this.loadData();
	}

	hookEmail = (target) => {
		this.handlerEmail = target;
	}

	onSendEmail(){
		this.handlerEmail.onSendEmail();
	}

	onSendEmailCallback = () => {
		this.successMessage('Success', 'Email inviata con successo');
	}

	sendComplete = () => {
		if(this.sendCallback) this.sendCallback();
	}

	loadData(){
		getLeadEmail({leadId: this.params.recordId}).then((response)=>{
        	if (!response.isSuccess) throw new Error(response.errorMessage);

        	this.currentUser = response.currentUser;
        	this.lead = response.lead;

        	this.dataEmail = {
        		from: response.fromEmail,
				to: response.toEmail
			};
        }).catch((err) => {
            console.log("errChangeStatus: ", err);
            this.alertMessage('Error', '' + err.message);
        }).finally(() => {
            this.hideSpinner();
		})
	}
}