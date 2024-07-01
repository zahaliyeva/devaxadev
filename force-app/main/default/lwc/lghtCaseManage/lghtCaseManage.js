import { LightningElement, api, track } from 'lwc';
import { LghtAbstract } from 'c/lghtAbstract';

import caseCreateContext from '@salesforce/apex/LghtCaseManageController.caseCreateContext';

import ConfigNotValid from "@salesforce/label/c.ConfigNotValid";

export default class LghtCaseManage extends LghtAbstract {

	@api recordId;
	@api sObjectName;

	@track selectedRecordType;
	@track visibilites = {
		hasCaseNewStandard: false,
		hasCaseNewCustom: false,
		hasCaseNewSurvey: false
	}
	@track availableActions = {};
	@track newType;
	@track showError = false;

	get selectRecordType(){
		return this.visibilites.hasCaseNewStandard || this.visibilites.hasCaseNewCustom || this.visibilites.hasCaseNewSurvey;
	}

	async connectedCallback(){
		super.connectedCallback();
		console.log('awaiting context');
		await this.loadContext();
		console.log('context loaded');
    }

	loadContext(){ 
		return caseCreateContext().then((result)=>{
			console.log('caseCreateContext', {...result});
			this.visibilites 			= {...result};
			this.availableActions 		= {...result.availableActions};
			this.newType 				= result.newType;

			this.hideSpinner();
		})
	}

	loadRecordTypeCallback = () => {
		this.hideSpinner();
	}

	confirmCallback = (recordTypeSelected) => {
		console.log('confirmCallback');

		this.selectedRecordType = {...recordTypeSelected};

		const recordTypeId = this.selectedRecordType.Id;
		let availableActions = this.availableActions[recordTypeId];

		if(!availableActions){
			availableActions = this.availableActions.All;
		}

		if(!availableActions || availableActions.length === 0){
			this.alertMessage(ConfigNotValid)
			this.showError = true;
			return;
		}

		console.log('availableActions', availableActions);
		
		if(this.visibilites.hasCaseNewStandard && availableActions.includes('CASE_NEW_STANDARD')){
			this.redirectDispatch(this.closeStandardCallback, 'CASE_NEW_STANDARD');
		}else if(this.visibilites.hasCaseNewCustom  && availableActions.includes('CASE_NEW_CUSTOM')){
			this.redirectDispatch(this.customCallback, 'CASE_NEW_CUSTOM');
		}else if(this.visibilites.hasCaseNewSurvey && availableActions.includes('CASE_NEW_SURVEY')){
			this.redirectDispatch(this.customCallback, 'CASE_NEW_SURVEY');
		}else{
			this.alertMessage(ConfigNotValid);
			this.showError = true;
			return;
		}
	}

	redirectDispatch(callback, caseNewAction){
		if(this.sObjectName === 'Case'){
			this.closeTab(callback(caseNewAction));
		}else{
			callback(caseNewAction);
		}
	}

	cancelCallback = () => {
		this.closeTab();
	}

	customCallback = (caseNewAction) => {
		console.log('Selected Record Type Id: ' + this.selectedRecordType.Id);
		console.log('Selected Record Type name: ' + this.selectedRecordType.name);
		console.log('Selected Form Type: ' + this.newType);
		this.navigateToComponent({
			component: 'SearchAccountAndCreateCase',	
			state: {
				c__FormType: this.newType,
				c__SelectedCaseType: this.selectedRecordType.Id,
				c__SelectedCaseTypeName: this.selectedRecordType.name,
				c__CaseNewAction: caseNewAction,
				TECH_Voice_Call__c: this.recordId
			}
		}); 
	} 

	closeStandardCallback = () => {
		console.log('closeStandardCallback');
 
		const attributes = {
			objectApiName: 'Case',
			actionName: 'new',
		};

		if(this.sObjectName === 'Account'){
			attributes.defaultFieldValues = {
				AccountId: this.recordId
			}
		}

		if(this.sObjectName === 'VoiceCall'){
			attributes.defaultFieldValues = {
				TECH_Voice_Call__c: this.recordId
			}
		}

		const state = {
			nooverride: '1',
			recordTypeId: this.selectedRecordType.Id,
		};

		return this.navigateToObjectPage(attributes, state);
	}

}