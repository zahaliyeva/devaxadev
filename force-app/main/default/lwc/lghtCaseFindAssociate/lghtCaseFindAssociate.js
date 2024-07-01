import { LightningElement, track, api } from 'lwc';
import { LghtAbstract } from 'c/lghtAbstract';

import { CaseAccountList, CaseAccount} from './caseAccountList';

import initContext from '@salesforce/apex/LghtCaseFindAssociate.initContext';
import searchCustomer from '@salesforce/apex/LghtCaseFindAssociate.searchCustomer';
import asociateCustomerToCase from '@salesforce/apex/LghtCaseFindAssociate.asociateCustomerToCase';
import importAssociateCustomerToCase from '@salesforce/apex/LghtCaseFindAssociate.importAssociateCustomerToCase';
import saveCustomer from '@salesforce/apex/LghtCaseFindAssociate.saveCustomer';

import VFP08_Successful from '@salesforce/label/c.VFP08_Successful';

export default class LghtCaseFindAssociate extends LghtAbstract {

	@api recordId;
	@api type;
	@api caseRecordType;
	@api closeCallback;


	@track context = {};
	@track accountData = {
		FirstName: '',
		LastName: '',
		Fiscal_ID__c: '',
		Matricola__c: '',
		Name: '',
		Partita_IVA__c: ''
	};
	@track accountResult = new CaseAccountList();
	@track showInsert = false;
	@track notShow = false;
	@track showEmptyFound = false;

	componentView = 'LghtCaseFindAssociate';

	get title(){
		return `${(this.context.isAgent) ? 'Agente' : 'Cliente'}`;
	}

	get isNotCorporateAndAgent(){
		return !this.context.isCorporate && !this.context.isAgent;
	}

	get isAgentNotCorporate(){
		return this.context.isAgent && !this.context.isCorporate;
	}

	get data(){
		console.log(this.accountResult.getAll());
		return this.accountResult.getAll();
	}

	get hasResult(){
		return this.accountResult.length > 0;
	}

	get recordTypeInsert(){
		console.log(this.context);
		return (this.context.isCorporate) ? this.context.corporateRecordType : this.context.customerRecordType;
	}

	get submitLabel(){
		return `Crea e Inserisci ${(this.context.isAgent) ? 'Gestore' : 'Cliente'}`;
	}

	connectedCallback() {
		super.connectedCallback();

		this.loadData();
	}

	loadData(){
		console.log('loadData');

		this.showSpinner();
		initContext({
			recordId: this.recordId,
			params: {
				type: this.type,
				CaseRecordType: this.caseRecordType
			}
		}).then((result)=>{
			this.context = {...result};
		}).finally(()=>{
			this.hideSpinner();
		})
	}

	onChange = (e) =>{
		const name = e.target.name;
		const value = e.target.value;

		console.log({name, value});

		this.accountData = {...this.accountData, [name]: value};

	}

	onNew = (e) => {
		e.preventDefault();
		this.accountResult = new CaseAccountList();
		this.showInsert = true;
	}

	onSearch = (e) => {
		e.preventDefault();

		this.accountResult = new CaseAccountList();

		this.showSpinner();
		searchCustomer({
			recordId: this.recordId,
			params: {
				type: this.type,
				CaseRecordType: this.caseRecordType
			},
			searchCustomer: this.accountData
		}).then((result)=>{
			console.log(result);
			if(!result.isSuccess) throw new Error(result.errorMessage);
			
			this.context = {...this.context, ...result};
			this.accountResult = new CaseAccountList([...result.listCustomerResult]);
			this.showInsert = (this.accountResult.length === 0);
			this.showEmptyFound = (this.accountResult.length === 0);
		}).catch((err)=>{
			this.alertMessage(err.message);
		}).finally(()=>{
			this.hideSpinner();
		})
	}
	onImportAssociate  = (e) => {
		e.preventDefault();
		const index = e.target.dataset.index;
		console.log('index' , this.data[index]);
		if (this.data[index].NDG__c == '' || this.data[index].NDG__c == null){
		 this.alertMessage('Si è verificato un errore,contattare il proprio amministratore di sistema');
		return;
		}

		const selectedCustomerNDG =  this.data[index].NDG__c;
        console.log('******' + selectedCustomerNDG);
		this.showSpinner();
		importAssociateCustomerToCase({
			recordId: this.recordId,
			params: {
				type: this.type,
				CaseRecordType: this.caseRecordType,
				isCorporate : this.context.isCorporate,
                NDG : selectedCustomerNDG
			},
			
		}).then((result)=>{
			console.log(result);
			if(!result.isSuccess) throw new Error(result.errorMessage);
			
			this.successMessage(VFP08_Successful);
			if(this.closeCallback) this.closeCallback(this);
		}).catch((err)=>{
			this.alertMessage(err.message);
		}).finally(()=>{
			this.hideSpinner();
		})
	
		
	}	

	onAssociate = (e) => {
		e.preventDefault();

		const accountId = e.target.dataset.id;

		const result = this.data.filter((record, recordId)=>{
			return record.Id === accountId;
		})

		if(result.length === 0) return;

		const selectedCustomer = result[0];

		this.showSpinner();
		asociateCustomerToCase({
			recordId: this.recordId,
			params: {
				type: this.type,
				CaseRecordType: this.caseRecordType
			},
			selectedCustomer
		}).then((result)=>{
			console.log(result);
			if(!result.isSuccess) throw new Error(result.errorMessage);
			
			this.successMessage(VFP08_Successful);
			if(this.closeCallback) this.closeCallback(this);
		}).catch((err)=>{
			this.alertMessage(err.message);
		}).finally(()=>{
			this.hideSpinner();
		})
	}

	onSubmit = (e) => {
		e.preventDefault();
		
		const selectedCustomer = {...e.detail.fields, RecordTypeId: this.recordTypeInsert};
		console.log('onSubmit', selectedCustomer);

		this.showSpinner();
		saveCustomer({
			recordId: this.recordId,
			params: {
				type: this.type,
				CaseRecordType: this.caseRecordType
			},
			selectedCustomer
		}).then((result)=>{
			console.log(result);
			if(!result.isSuccess) throw new Error(result.errorMessage);
			
			this.successMessage(VFP08_Successful);
			if(this.closeCallback) this.closeCallback(this);
		}).catch((err)=>{
			this.alertMessage(err.message);
		}).finally(()=>{
			this.hideSpinner();
		})
	}
}