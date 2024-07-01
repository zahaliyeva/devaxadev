import { LightningElement, track, api } from 'lwc';

import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import { MobilityMessageModel } from 'c/mobilityMessageModel';

export class LghtAbstract extends NavigationMixin(LightningElement) {

	@api params;
	@api hook;

	@track messages;
	@track spinner = true;
	@track spinnerOverlay = false;
	@track debug;
	@track noData = false;
	@track authorized = true;
	@track portalRole;

	componentView;
	profile;

	_registerTypes = {};

	get hasData() {
		return !this.noData;
	}

	constructor(data) {
		super(data);
		this.messages = new MobilityMessageModel();
	}

	refreshView(){
		this.dispatchEvent(new CustomEvent('refreshview'));
	}

	invokeEvent(eventName, params){
		console.log('invokeEvent', eventName);
		console.log('invokeEvent.params', params);

		const eventPayload = new CustomEvent(eventName, {
			detail: params
		});

		console.log('eventPayload', {...eventPayload});
		
		// Fire the custom event
		this.dispatchEvent(eventPayload); 
	}

	navigate(data){
		console.log('navigate', data);
		return new Promise((resolve, reject)=>{
			this[NavigationMixin.Navigate](data)

			setTimeout(resolve, 1000);
		});
	}

	quickAction(actionName){
		this.invokeEvent('invokeaction', {
			actionName
		});
	}

	setActionValues(actionName, targetValues, actionCallback){
		const targetFields = {};
		
		for(let index in targetValues)
			targetFields[index] = {value: targetValues[index]};

		this.invokeEvent('onsetactionValue', {
			actionName,
			targetFields
		});
	}

	/**
	 * Navigate to Visualforce Page
	 * @param  {String} page 		Name Visualforce
	 * @param  {Object} params 		Params to Visualforce
	 */
	navigateToVFPage(data){
		let querySring;

		if(data.params){
			let paramSingle = [];

			for(let key in data.params){
				let value = data.params[key];

				if(value) paramSingle.push(`${key}=${value}`);
			}

			querySring = paramSingle.join('&');
		}

		return this.navigate({
			type: 'standard__webPage',
			attributes: {
			    url: `/apex/${data.page}${(querySring) ? '?'+querySring : ''}`
			}
		});
	}

	/**
	 * Navigate to Component
	 * @param  {String} component 		 Name Component
	 * @param  {String} state 			 State Component
	 */
	navigateToComponent(data){
		return this.navigate({
			type: 'standard__component',
			attributes: {
				componentName: `c__${data.component}`,
			},
			state: data.state
		});
	}

	/**
	 * Navigate to Object
	 * @param  {Object} defaultFieldValues 	Object Params
	 * @param  {String} objectApiName 		Object Api Name
	 * @param  {String} actionName 			Action Name (home, list, new)
	 */
	navigateToObjectPage(data, state){
		let defaultFieldValues = data.defaultFieldValues;

		let listDefaultFields = [];
		for(let index in defaultFieldValues){
			let value = encodeURIComponent(defaultFieldValues[index]);

			if(value) listDefaultFields.push(`${index}=${value}`);
		}

		const paramsString = listDefaultFields.join(',');

		return this.navigate({
		    type: "standard__objectPage",
		    attributes: {
		        objectApiName: data.objectApiName,
		        actionName: data.actionName,
		        recordId: data.recordId,
		    },
		    state: {
		        defaultFieldValues: paramsString,
		        ...state
		    }
		});
	}

	navigateToRecordPage(data){
		return this.navigate({
		    type: "standard__recordPage",
		    attributes: {
		        objectApiName: data.objectApiName,
		        actionName: data.actionName,
		        recordId: data.recordId,
		    }
		});
	}

	/**
	 * Navigate to LWC
	 * @param  {String} component 		 	Lwc Name Component
	 * @param  {Object} state 				State Component
	 */
	navigateToLwc(data){
		let payload = {
			componentDef: `c:${data.component}`,
			attributes: data.state
		};

		let encodedPayload = btoa(JSON.stringify(payload));

		return this.navigate({
			type: 'standard__webPage',
			attributes: {
				url: '/one/one.app#' + encodedPayload
			}
        });
	}

	/**
	 * Navigate to Path
	 * @param  {String} url			Url to redirect
	 * @return {Object} params 		Params to QueryString
	 */
	navigateToPath(data){
		let paramsList = [];
		for(let index in data.params){
			let value = encodeURIComponent(data.params[index]);

			if(value) paramsList.push(`${index}=${value}`);
		}

		const paramsString = paramsList.join('&');

		return this.navigate({
			type: 'standard__webPage',
			attributes: {
				url: `${data.url}?${paramsString}`
			}
        });
	}

	onCloseTab(e){
		this.closeTab();
	}

	closeTab(_callback){
		console.log('closeTab');

		const closeClickedEvt = new CustomEvent('closetab', {
			detail: {
				callback: _callback
			},
		});

		console.log('closeClickedEvt', {...closeClickedEvt});
		
		// Fire the custom event
		this.dispatchEvent(closeClickedEvt); 
	}

	connectedCallback() {
		if (!this.componentView) return;
		console.log('Load', this.componentView);
		this.connectHook();	
	}

	connectHook(){
		if (this.hook) {
			console.log('Hook Connect', this.componentView);
			this.hook(this);
		}
	}

	parse(str) {
		var args = [].slice.call(arguments, 1),
			i = 0;

		return str.replace(/%s/g, () => args[i++]);
	}

	renderedCallback() {
		//PostMessage.resize(this.params.id);
	}

	proxyData(proxyObj) {
		return JSON.parse(JSON.stringify(proxyObj));
	}

	showSpinner(overlay = false) {
		this.spinner = true;
		this.spinnerOverlay = overlay;
	}

	hideSpinner() {
		this.spinner = false;
	}

	showNoData(visible) {
		this.noData = visible;
	}

	successMessage(title, message) {
		const event = new ShowToastEvent({
			title,
			message,
			variant: 'success',
			mode: 'sticky'
		});

		this.dispatchEvent(event);
	}

	alertMessage(title, message) {
		const event = new ShowToastEvent({
			title,
			message,
			variant: 'error',
			mode: 'sticky'
		});

		this.dispatchEvent(event);
	}

	warningMessage(title, message) {
		const event = new ShowToastEvent({
			title,
			message,
			variant: 'warning',
			mode: 'sticky'
		});

		this.dispatchEvent(event);
	}

	criticalMessage() {
		this.messages.showCritical('Non siamo riusciti a recuperare i dati', 'Si prega di ricaricare la pagina');
		this.messages = new MobilityMessageModel(this.messages);
	}

	successMessageMobility(title, message) {
		this.messages.showSuccess(title, message);
		this.messages = new MobilityMessageModel(this.messages);
	}

	alertMessageMobility(title, message) {
		this.messages.showAlert(title, message);
		this.messages = new MobilityMessageModel(this.messages);
	}

	warningMessageMobility(title, message) {
		this.messages.showWarning(title, message);
		this.messages = new MobilityMessageModel(this.messages);
	}

	changeData(e, data) {
		let name = e.target.name;
		let value = e.target.value;
		let type = e.target.type;

		if (type === 'checkbox') value = (e.target.checked);

		data[name] = value;
	}

	setData(keyMaster, objectAppend){
		this[keyMaster] = {...this[keyMaster], ...objectAppend};
	}

	updateData(data, TypeModel) {
		return new TypeModel(data);
	}

	setState(data) {
		for (let index in data) {
			this[index] = data[index]
		}
	}

	registerType(key, type){
		this._registerTypes[key] = type;
	}

	updateType(key, data){
		let Type = this._registerTypes[key];

		if(data){
			this[key] = new Type(data);
		}else{
			this[key] = new Type(this[key]);
		}
	}
}