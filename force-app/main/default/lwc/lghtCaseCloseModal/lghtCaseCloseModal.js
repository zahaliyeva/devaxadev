import { track, api, LightningElement } from 'lwc';
import { LghtAbstract } from 'c/lghtAbstract';

import updateCase from '@salesforce/apex/LghtCaseCloseController.updateCase';

export default class LghtCaseCloseModel extends LghtAbstract {

	@api recordId;
	@api sObjectName;
	@api caseData;
	@api closeCallback;

	@track context = {
		Case: {}
	};
		
	connectedCallback(){
		super.connectedCallback();
		this.hideSpinner();
		}
	
	handleTRChange(event) {
        console.log('Selected Picklist Value: '+ event.detail.value);
		this.context.Case.Tag_richiesta__c = event.detail.value;
    }

	get isHD2IT(){
		if(!this.caseData) return false;
		if(!this.caseData.Current_Owner_Queue__c) return false;
		return this.caseData.Current_Owner_Queue__c.startsWith('HD2_IT');
	}
	onChange = (e) => {
		console.log('onChange');	
		this.context = {...this.context, ...e};
	}

	onValidate = (e) => {
		return true;
	}

	onConfirm = () => {
		console.log(this.proxyData(this.context));
		const caseData = this.context.Case;

		if( this.isHD2IT && !caseData.Tag_richiesta__c){
			this.alertMessage('Error','Per proseguire e\' necessario inserire un Tag Richiesta.');
			return;
		}

		this.showSpinner();
		updateCase({caseData}).then((response)=>{
			if(!response.isSuccess) throw new Error(response.errorMessage);

			this.successMessage('Case aggiornato con successo');

			if(this.closeCallback) this.closeCallback({refresh: true});
		}).catch((err)=>{
			if(err.message.includes('FIELD_CUSTOM_VALIDATION_EXCEPTION, ')){
				var len = 'FIELD_CUSTOM_VALIDATION_EXCEPTION, '.length;
				var mess = err.message;
				this.alertMessage('Error',mess.substring(mess.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION, ')+len,mess.lastIndexOf(": [")));
			}
			else {
				if(err.message.includes('Compilare i campi Nome Applicazione e Tipologia Ticket Silva')){
					this.alertMessage('Error', err.message);
					return;
				}
				this.alertMessage('Error', err.message);
				if(err.message.includes('Silva') && this.closeCallback){
					this.closeCallback({refresh: true})
				}
			}
			
			
		}).finally(()=>{
			this.hideSpinner();
		})
	}

}