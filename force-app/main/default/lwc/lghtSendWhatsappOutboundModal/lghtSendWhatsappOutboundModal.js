import { track, api, LightningElement } from 'lwc';
import { LghtAbstract } from 'c/lghtAbstract';

import updateCase from '@salesforce/apex/LghtSendWhatsappOutboundApexController.updateCase';
import getMessagesTemplates from '@salesforce/apex/LghtSendWhatsappOutboundApexController.getMessagesTemplates';

export default class LghtSendWhatsappOutboundModal extends LghtAbstract {

	@api recordId;
	@api sObjectName;
	@api caseData;
	@api closeCallback;
	@track isDisabled = true;
	templateName = null;
	templateMessage = null;
	options = {};
	templates = {};
	

	@track context = {
		Case: {}
	};

	get isComboboxDisabled() {
		return !this.templateName;
	}
	
	connectedCallback(){
		super.connectedCallback();
		this.context.Case = JSON.parse(JSON.stringify(this.caseData));
		this.getTemplates();
	}

	getTemplates() {
		getMessagesTemplates({channel: 'Whatsapp'})
		.then( result => {
			this.options = result.templatesConfig.map( templateConfig => {
				return {  label: templateConfig.Label, value: templateConfig.TemplateName__c }
			})
			this.templates = result.templates;
			
		})
		.catch((err)=>{
			if(err.message.includes('FIELD_CUSTOM_VALIDATION_EXCEPTION, ')){
				var len = 'FIELD_CUSTOM_VALIDATION_EXCEPTION, '.length;
				var mess = err.message;
				this.alertMessage('Error',mess.substring(mess.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION, ')+len,mess.lastIndexOf(": [")));
			}
			else
			this.alertMessage('Error', err.message);
			
		}).finally(()=>{
			this.hideSpinner();
		})
	}

	onChange = (e) => {
		console.log('onChange');	
		this.context = {...this.context, ...e};
	}

	onValidate = (e) => {
		return true;
	}

	handleComboboxChange(event) {
		this.templateName = event.detail.value;
		const template = this.templates ? this.templates.find(template => template.DeveloperName == event.detail.value) : null;
		this.templateMessage = template ? template.Message : null;
		
	}

	onConfirm = () => {
		//console.log(JSON.stringify(this.proxyData(this.context)));

		this.context.Case.OutboundMessagingTemplate__c = this.templateName ;

		const caseData = this.context.Case;

		console.log(JSON.stringify(caseData));

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
			else
			this.alertMessage('Error', err.message);
			
		}).finally(()=>{
			this.hideSpinner();
		})
	}

}