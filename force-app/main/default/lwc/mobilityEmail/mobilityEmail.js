import {
	MobilityAbstract
} from "c/mobilityAbstract";

import {
	api,
	track
} from "lwc";

import getFolders from '@salesforce/apex/MobilityEmail.getFolders';
import getTemplates from '@salesforce/apex/MobilityEmail.getTemplates';
import sendEmail from '@salesforce/apex/MobilityEmail.sendEmail';

export default class MobilityEmail extends MobilityAbstract {
	componentView = 'mobilityEmail';
	
	@api disabledFrom = false;
	@api disabledTo = false;
	@api disabledCC = false;
	
	@api sendCallback;

	@api
	get defaultData() {
		return this._defaultData;
	}
	set defaultData(value) {
		this._defaultData = value
		this.setData('dataEmail', value);
	}

	_defaultData = {};

	@track dataEmail = {
		message: '',
		subject: '',
		templateId: null,
		from: '',
		fromName: '',
		to: '',
		cc: ''
	}

	get invokeGetFolders(){
		return getFolders;
	}

	get invokeGetTemplates(){
		return getTemplates;
	}

	get selectedTemplate(){
		return this.dataEmail.templateId !== null;
	}

	onSubmit = (e) => {
		e.preventDefault();

		let ccAddress = [];
		if(this.dataEmail.cc.trim() !== '') ccAddress.push(this.dataEmail.cc);

		let toAddress = [];
		if(this.dataEmail.to.trim() !== '') toAddress.push(this.dataEmail.to);

		let request = {
			targetId: this.params.recordId,
			templateId: this.dataEmail.templateId,
			fromAddress: this.dataEmail.from,
			nameFromAddress: this.dataEmail.name,
			toAddress: toAddress,
			ccAddress: ccAddress,
			subject: this.dataEmail.subject,
			body: this.dataEmail.message,
			files: []
		};

		console.log(request);

		this.showSpinner(true);
		sendEmail(request).then((result)=>{
		    if (!result.isSuccess) throw new Error(result.errorMessage);
		    if(this.sendCallback) this.sendCallback(this);
		}).catch((err) => {
		    console.log("errChangeStatus: ", err);
		    this.alertMessage('Error', '' + err.message);
		}).finally(() => {
		    this.hideSpinner();
		});
	}

	onSendEmail = (e) =>{
		this.template.querySelector('button').click();
	}

	onChangeForm = (e) => {
		if(!e.target) return;

		let name = e.target.name;
		let value = e.target.value;

		this.setData('dataEmail', {[name]: value});
	}

	templateSearch = (results) =>{
		if(results.length){
			let result = results[0];
			this.setData('dataEmail', {templateId: result.Id});
		}else{
			this.setData('dataEmail', {templateId: null});
		}
	}

	connectedCallback() {
		console.log('MobilityEmail', this.hook);
		super.connectedCallback();

		this.hideSpinner();
	}
}