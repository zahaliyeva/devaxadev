import { LightningElement, track, api } from 'lwc';
import { LghtAbstract } from 'c/lghtAbstract';

import searchAgent from '@salesforce/apex/LghtCaseFindAssociateAgent.searchAgent';
import associateAgent from '@salesforce/apex/LghtCaseFindAssociateAgent.associateAgent';

export default class LghtCaseFindAssociateAgent extends LghtAbstract {

	@api recordId;
	@api debugMode;
	@api visibilities;

	@track searchData = {
		Email: '',
		FirstName: '',
		LastName: '',
		Agency_Code__c: '',
		CommunityNickname: ''
	}

	@track listResults = [];

	get hasResult(){
		return this.listResults.length > 0;
	}

	connectedCallback() {
		super.connectedCallback();
		this.spinner = false;
	}

	onChange = (e) =>{
		const name = e.target.name;
		const value = e.target.value;

		console.log({name, value});

		this.searchData = {...this.searchData, [name]: value};
	}

	onSearchAgent(e){
		e.preventDefault();

		this.showSpinner();
		searchAgent({
			fieldsSearch: this.searchData
		}).then((response)=>{
			console.log(response);

			this.listResults = response.listUsers;
		}).catch((err)=>{
			this.alertMessage(err.message);
		}).finally(()=>{
			this.hideSpinner();
		});
	}

	onAssociate(e){
		e.preventDefault();

		const agentId = e.target.dataset.id;
		const caseId = this.recordId;

		this.showSpinner();
		associateAgent({
			agentId,
			caseId
		}).then((response)=>{
			console.log(response);
			this.successMessage('Cliente Associato Correttamente');
			
			if(this.visibilities)this.visibilities('lghtCaseFindAssociateAgent', false);
			this.refreshView();
		}).catch((err)=>{
			this.alertMessage(err.message);
		}).finally(()=>{
			this.hideSpinner();
		});
	}

}