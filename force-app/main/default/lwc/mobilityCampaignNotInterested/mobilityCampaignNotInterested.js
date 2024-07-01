import {
	track,
	api
} from 'lwc';


import {
	MobilitySObject
} from 'c/mobilitySObject';

import proccessNotInterested from '@salesforce/apex/MobilityCampaignMemberController.proccessNotInterested';

export default class MobilityTask extends MobilitySObject {
	componentView = 'mobilityTask';
	objectName = 'Task';
	
	resonValue='';

	reason = [
		{ label: '--Nessuno--', value: 'Nessuno' },
		{ label: 'Non interessato al prodotto offerto', value: 'Non interessato al prodotto offerto' },
		{ label: 'Non interessato al prodotto in questo periodo dell\'anno', value: 'Non interessato al prodotto in questo periodo dell\'anno' },
		{ label: 'Prodotto già presente in portafoglio (con concorrenza)', value: 'Prodotto già presente in portafoglio (con concorrenza)' },
		{ label: 'Prodotto già presente in portafoglio (con AXA)', value: 'Prodotto già presente in portafoglio (con AXA)' },
		{ label: 'Altro', value: 'Altro' }
	];

	@api campaignMemberId;
	@api closeCallbackReload;

	connectedCallback() {
		super.connectedCallback();	
		this.hideSpinner();
		
	}

	reasonChange(e) {
		 let value = e.target.value;
		 if (value === 'Nessuno') value = '';
		
		 this.resonValue= value ;
		console.log('select value ' + this.resonValue);
	}

	onProccessNotInterested = () => {
		this.showSpinner(true);
        proccessNotInterested({
			campaignMemberId: this.campaignMemberId,
			reason: this.resonValue
        }).then((response)=>{
        	if (!response.isSuccess) throw new Error(response.errorMessage);
			console.log('onProccessNotInterested', response); 
			this.successMessage('Success','Processo eseguito con successo.');         
            //this.onClose();
        }).catch((err) => {
            console.log("errChangeStatus: ", err);
            this.alertMessage('Error', '' + err.message);
        }).finally(() => {
        	this.hideSpinner();
        })
    }
}