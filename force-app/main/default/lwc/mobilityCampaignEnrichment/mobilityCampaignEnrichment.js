import {
	track,
	api
} from 'lwc';

import {
	MobilityAbstract
} from 'c/mobilityAbstract';

import proccessDataEnrichment from '@salesforce/apex/MobilityCampaignDataEnrichment.proccessDataEnrichment';
import initData from '@salesforce/apex/MobilityCampaignDataEnrichment.initData';

export default class MobilityCampaignEnrichment extends MobilityAbstract {
	componentView = 'mobilityCampaignEnrichment';

	@api campaignMemberId;
	@api closeCallback;
	@api closeCallbackReload;

	@track hasOpenTask = false;
	@track campaignMember = null;
	@track accountData = {
		Fax: null,
		CIF_Phone_IntPrefix__c: '+39',
		CIF_Phone__c: '',
		CIF_Propaga_OMNIA_Phone__c: '',
		Flag_Opposizione_Tel_Princ__c: '',
		Motivo_opposizione_Tel_Princ__c: '',
		CIF_PersonMobilePhone_IntPrefix__c: '+39',
		CIF_PersonMobilePhone__c: '',
		CIF_Propaga_OMNIA_PersonMobilePhone__c: '',
		Flag_Opposizione_Tel_Cell_B2C__c: '',
		Motivo_opposizione_Tel_Cell_B2C__c: '',
		Fax_IntPrefix__c: '+39',
		CIF_Propaga_OMNIA_Fax__c: '',
		Flag_Opposizione_Fax__c: '',
		Motivo_opposizione_Fax__c: '',
		CIF_Work_phone_IntPrefix__c: '+39',
		CIF_Work_phone__c: '',
		CIF_Propaga_OMNIA_Work_Phone__c: '',
		Flag_Opposizione_Tel_Uff__c: '',
		Motivo_opposizione_Tel_Uff__c: '',
		CIF_PersonEmail__c: '',
		CIF_Propaga_OMNIA_PersonEmail__c: '',
		Flag_Opposizione_Email_Pers_B2C__c: '',
		Motivo_opposizione_Email_Pers_B2C__c: '',
		CIF_Work_email__c: '',
		CIF_Propaga_OMNIA_Work_Email__c: '',
		Flag_Opposizione_Email_Uff__c: '',
		Motivo_opposizione_Email_Uff__c: '',

		CIF_Mail_contact__c: '',
		CIF_OTP_Phone_contact__c: '',
	};

	fieldsDefinition;

	get loadCampaignMember(){
		return this.campaignMember !== null;
	}

	get accountToSave(){
		return {...this.accountData, sobjectType: 'Account'};
	}

	get prefixStrategy(){
		return {
			CIF_Phone_IntPrefix__c: {
				CIF_Phone__c: '', 
				CIF_Propaga_OMNIA_Phone__c: false, 
				Flag_Opposizione_Tel_Princ__c: false, 
				Motivo_opposizione_Tel_Princ__c: ''
			},
			CIF_PersonMobilePhone_IntPrefix__c: {
				CIF_PersonMobilePhone__c: '', 
				CIF_Propaga_OMNIA_PersonMobilePhone__c: false, 
				Flag_Opposizione_Tel_Cell_B2C__c: false, 
				Motivo_opposizione_Tel_Cell_B2C__c: ''
			},
			Fax_IntPrefix__c: {
				Fax: '', 
				CIF_Propaga_OMNIA_Fax__c: false, 
				Flag_Opposizione_Fax__c: false, 
				Motivo_opposizione_Fax__c: ''
			},
			CIF_Work_phone_IntPrefix__c: {
				CIF_Work_phone__c: '', 
				CIF_Propaga_OMNIA_Work_Phone__c: false, 
				Flag_Opposizione_Tel_Uff__c: false, 
				Motivo_opposizione_Tel_Uff__c: ''
			}
		}
	}

	get checkOpenTask(){
		if(!this.hasOpenTask){
			return {
				CIF_PersonEmail__c: false,
				CIF_Work_email__c: false,
				CIF_PersonMobilePhone__c: false
			}
		}

		return {
			CIF_PersonEmail__c: 				this.accountData.CIF_Mail_contact__c && this.accountData.CIF_Mail_contact__c === this.accountData.CIF_PersonEmail__c,
			CIF_Work_email__c: 					this.accountData.CIF_Mail_contact__c && this.accountData.CIF_Mail_contact__c === this.accountData.CIF_Work_email__c,
			CIF_PersonMobilePhone__c: 			this.accountData.CIF_OTP_Phone_contact__c && this.accountData.CIF_OTP_Phone_contact__c === this.accountData.CIF_PersonMobilePhone__c,
		}
	}

	get checkPrefix(){
		let result = {
			CIF_Phone_IntPrefix__c: 				(!this.accountData.CIF_Phone_IntPrefix__c || this.accountData.CIF_Phone_IntPrefix__c.trim() === ''),
			CIF_PersonMobilePhone_IntPrefix__c: 	(!this.accountData.CIF_PersonMobilePhone_IntPrefix__c || this.accountData.CIF_PersonMobilePhone_IntPrefix__c.trim() === ''),
			Fax_IntPrefix__c: 						(!this.accountData.Fax_IntPrefix__c || this.accountData.Fax_IntPrefix__c.trim() === ''),
			CIF_Work_phone_IntPrefix__c: 			(!this.accountData.CIF_Work_phone_IntPrefix__c || this.accountData.CIF_Work_phone_IntPrefix__c.trim() === ''),
		}

		if(this.checkOpenTask.CIF_PersonMobilePhone__c) 		result.CIF_PersonMobilePhone_IntPrefix__c = true;

		return result;
	}

	get checkContact(){
		let result = {
			CIF_Phone__c: 					(!this.accountData.CIF_Phone__c || this.accountData.CIF_Phone__c.trim() === ''),
			CIF_PersonMobilePhone__c: 		(!this.accountData.CIF_PersonMobilePhone__c || this.accountData.CIF_PersonMobilePhone__c.trim() === ''),
			Fax: 							(!this.accountData.Fax || this.accountData.Fax.trim() === ''),
			CIF_Work_phone__c: 				(!this.accountData.CIF_Work_phone__c || this.accountData.CIF_Work_phone__c.trim() === ''),
			CIF_PersonEmail__c: 			(!this.accountData.CIF_PersonEmail__c || this.accountData.CIF_PersonEmail__c.trim() === ''),
			CIF_Work_email__c: 				(!this.accountData.CIF_Work_email__c || this.accountData.CIF_Work_email__c.trim() === '')
		}

		if(this.checkOpenTask.CIF_PersonEmail__c) 				result.CIF_PersonEmail__c = true;
		if(this.checkOpenTask.CIF_Work_email__c) 				result.CIF_Work_email__c = true;
		if(this.checkOpenTask.CIF_PersonMobilePhone__c) 		result.CIF_PersonMobilePhone__c = true;

		return result;
	}

	get strategyOMNIA(){
		return {
			CIF_Phone__c: 					'CIF_Propaga_OMNIA_Phone__c',
			CIF_PersonMobilePhone__c: 		'CIF_Propaga_OMNIA_PersonMobilePhone__c',
			Fax: 							'CIF_Propaga_OMNIA_Fax__c',
			CIF_Work_phone__c: 				'CIF_Propaga_OMNIA_Work_Phone__c',
			CIF_PersonEmail__c: 			'CIF_Propaga_OMNIA_PersonEmail__c',
			CIF_Work_email__c: 				'CIF_Propaga_OMNIA_Work_Email__c'
		}
	}

	get strategyResetOMNIA(){
		return {
			CIF_Phone__c: {
				CIF_Propaga_OMNIA_Phone__c: false, 
				Flag_Opposizione_Tel_Princ__c: false, 
				Motivo_opposizione_Tel_Princ__c: ''
			},
			CIF_PersonMobilePhone__c: {
				CIF_Propaga_OMNIA_PersonMobilePhone__c: false, 
				Flag_Opposizione_Tel_Cell_B2C__c: false, 
				Motivo_opposizione_Tel_Cell_B2C__c: ''
			},
			Fax: {
				CIF_Propaga_OMNIA_Fax__c: false, 
				Flag_Opposizione_Fax__c: false, 
				Motivo_opposizione_Fax__c: ''
			},
			CIF_Work_phone__c: {
				CIF_Propaga_OMNIA_Work_Phone__c: false, 
				Flag_Opposizione_Tel_Uff__c: false, 
				Motivo_opposizione_Tel_Uff__c: ''
			},
			CIF_PersonEmail__c: {
				CIF_Propaga_OMNIA_PersonEmail__c: false, 
				Flag_Opposizione_Email_Pers_B2C__c: false, 
				Motivo_opposizione_Email_Pers_B2C__c: ''
			},
			CIF_Work_email__c: {
				CIF_Propaga_OMNIA_Work_Email__c: false, 
				Flag_Opposizione_Email_Uff__c: false, 
				Motivo_opposizione_Email_Uff__c: ''
			}
		}
	}

	get checkMotivation(){
		return {
			Flag_Opposizione_Tel_Princ__c: 			!(this.accountData.Flag_Opposizione_Tel_Princ__c),
			Flag_Opposizione_Tel_Cell_B2C__c: 		!(this.accountData.Flag_Opposizione_Tel_Cell_B2C__c),
			Flag_Opposizione_Fax__c: 				!(this.accountData.Flag_Opposizione_Fax__c),
			Flag_Opposizione_Tel_Uff__c: 			!(this.accountData.Flag_Opposizione_Tel_Uff__c),
			Flag_Opposizione_Email_Pers_B2C__c: 	!(this.accountData.Flag_Opposizione_Email_Pers_B2C__c),
			Flag_Opposizione_Email_Uff__c: 			!(this.accountData.Flag_Opposizione_Email_Uff__c),
		}
	}

	get strategyMotivation(){
		return {
			Flag_Opposizione_Tel_Princ__c: 			'Motivo_opposizione_Tel_Princ__c',
			Flag_Opposizione_Tel_Cell_B2C__c: 		'Motivo_opposizione_Tel_Cell_B2C__c',
			Flag_Opposizione_Fax__c: 				'Motivo_opposizione_Fax__c',
			Flag_Opposizione_Tel_Uff__c: 			'Motivo_opposizione_Tel_Uff__c',
			Flag_Opposizione_Email_Pers_B2C__c: 	'Motivo_opposizione_Email_Pers_B2C__c',
			Flag_Opposizione_Email_Uff__c: 			'Motivo_opposizione_Email_Uff__c'
		}
	}

	get picklistValues(){
		let picklist = [
			'Motivo_opposizione_Tel_Princ__c',
			'Motivo_opposizione_Tel_Cell_B2C__c',
			'Motivo_opposizione_Fax__c',
			'Motivo_opposizione_Tel_Uff__c',
			'Motivo_opposizione_Email_Pers_B2C__c',
			'Motivo_opposizione_Email_Uff__c',
		]

		let result = {};
		picklist.forEach((name, index)=>{
			result[name] = this.getValues(name);
		})

		return result;
	}

	getValues(field){
		let result = [{label: '-', value: ''}];

		let mapCheck = this.fieldsDefinition[field].pickListMap;

		for(let label in mapCheck){
			let value = mapCheck[label];

			result.push({
				label,
				value,
				selected: value === this.accountData[field]
			})
		}

		return result;
	}

	connectedCallback() {
		super.connectedCallback();

		this.onLoad();
	}

	onLoad = () => {
		this.showSpinner();
		initData({
			campaignMemberId: this.campaignMemberId
		}).then((response)=>{
			console.log(response);
			this.setData('accountData', response.account);

			this.fieldsDefinition 	= response.fieldsDefinition;
			this.campaignMember 	= response.campaignMember;
			this.hasOpenTask 		= response.hasOpenTask;
        }).catch((err) => {
            console.log("errChangeStatus: ", err);
            this.alertMessage('Error', '' + err.message);
        }).finally(() => {
        	this.hideSpinner();
        })
	}

	onClose = () => {
		if(this.closeCallback) this.closeCallback();
	}

	onApplyStartegy = (field, value) => {
		let data = {};

		let prefixStrategy = this.prefixStrategy[field];
		if(prefixStrategy && value.trim() === ''){
			data = {...data, ...prefixStrategy};
		}

		let strategyResetOMNIA = this.strategyResetOMNIA[field];
		if(strategyResetOMNIA && !value){
			data = {...data, ...strategyResetOMNIA};
		}

		let strategyOMNIA = this.strategyOMNIA[field];
		if(strategyOMNIA && value){
			data[strategyOMNIA] = true;
		}

		let strategyMotivation = this.strategyMotivation[field];
		if(strategyMotivation && !value){
			data[strategyMotivation] = '';
		}


		return data;
	}

	onChange = (e) => {
	    let target = e.target || e.currentTarget;
	    let name = target.name;
	    let value = target.value;
	    let type = target.type;
	    let checked = target.checked;

	    if(!name) return;
	    if (type === 'checkbox') value = checked;

	    let data = this.onApplyStartegy(name, value);

	    console.log('data', data);

	    this.setData('accountData', {[name]: value, ...data});
	}

	evaluateResponse(response){
		let data = response.additionalData;

		if(data.RollbackedAccount){
			this.setData('accountData', data.RollbackedAccount);
		}
	}

	onProccessDataEnrichment = () => {
		this.showSpinner();
		console.log('lol')
		proccessDataEnrichment({
			campaignId: this.params.recordId,
			campaignMemberId: this.campaignMemberId,
			accountToSave: this.accountToSave
		}).then((response)=>{
			this.evaluateResponse(response);
			if (!response.isSuccess) throw new Error(response.errorMessage);

            console.log('onProccessDataEnrichment', response);
			this.successMessage('Success','Processo eseguito con successo.');
        }).catch((err) => {
            console.log("errChangeStatus: ", err);
            this.alertMessage('Error', '' + err.message);
        }).finally(() => {
        	this.hideSpinner();
        })
	}

	onChangeBlacklist = (data) => {
		console.log(data);
	}

	onSave = () => {
		this.onProccessDataEnrichment();
	}
}