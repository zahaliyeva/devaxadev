/* eslint-disable guard-for-in */
import {
	LightningElement,
	track,
	api
} from 'lwc';

import {
	MobilityMessageModel
} from 'c/mobilityMessageModel';

import {
	PostMessage
} from 'c/postMessage';

import MobilityLabels from 'c/mobilityLabels';
import getVisibility from '@salesforce/apex/MobilityAbstract.getVisibility';

export class MobilityAbstract extends LightningElement {

	@api params;
	@api postMessage;
	@api parent;
	@api hook;

	@track messages;
	@track spinner = true;
	@track spinnerOverlay = false;
	@track debug;
	@track noData = false;
	@track authorized = true;
	@track iconUpload = 'plus';
	@track iconScrollTop = 'arrow-up';
	@track iconEdit = 'edit';
	@track portalRole;
	@track deviceType = {
		width: 0,
		heigth: 0,
		type: ''
	};

	componentView;
	profile;

	_label = MobilityLabels.label;

	get currentParent() {
		return this;
	}

	get redirectParams(){
		return {}
	}

	get isVenditeAssistenza(){
		return this.profile === 'NFE - AAI - Vendite Solo Assistenza';
	}

	get isVenditeBase(){
		return this.profile === 'NFE - AAI - Vendite Base';
	}

	get isVenditeAvanzato(){
		return this.profile === 'NFE - AAI - Vendite Avanzato';
	}

	get isRoleExecutive(){
		return this.portalRole === 'Executive';
	}

	get isRoleManager(){
		return this.portalRole === 'Manager';
	}

	get isRoleWorker(){
		return this.portalRole === 'Worker';
	}

	constructor(data) {
		super(data);
		this.messages = new MobilityMessageModel();
	}

	connectedCallback() {
		if (!this.componentView) return;
		console.log('Load', this.componentView);
		this.connectPostMessage();	
		this.connectHook();	
		this.connectVisibilities();	
	}

	connectPostMessage(){
		this.postMessageConnect();
	}

	connectHook(){
		if (this.hook) {
			console.log('Hook Connect', this.componentView);
			this.hook(this);
		}
	}

	connectVisibilities(){
		getVisibility({
			componentView: this.componentView
		}).then((result) => {
			this.authorized = result.isSuccess;
			if(this.authorized){
				console.log('connectVisibilities', this.proxyData(result))
				this.profile = result.profileName;
				this.portalRole = result.portalRole;
				MobilityMessageModel.messageMap = result.messages;
			}
		}).catch((err) => {
			console.log("err", err);
		});
	}

	preventDefault = (e) =>{
		if (e.preventDefault) {
            e.preventDefault();
        } else {
            e.returnValue = false;
            return false;
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

	postMessageConnect() {
		if (!this.params || !this.params.id) return;
		window.addEventListener("message", this.receiveMessage, false);

		PostMessage.hookRequest(this.params.id);
	}

	refreshCallback(){
		//OVERRIDE
	}

	receiveMessage = (e) => {
		switch(e.data.action){
			case 'REFRESH':
				this.refreshCallback();
				break;
			case 'RESIZE':
				this.deviceType = {...e.data.data};
				break;
		}
	}

	navigateToEvent = (e) => {
		const dataSet = JSON.parse(JSON.stringify(e.currentTarget.dataset));
		const component = dataSet.component;
		
		if (component) {
			this.navigateTo({
				name: component,
				params: dataSet
			});
		}
	}

	navigateTo = (target) => {
		if (!target.params) target.params = {};
		if (this.params.pageLayout) target.params.pageLayout = this.params.pageLayout;

		PostMessage.navigateTo(this.params.id, target);
	}

	openCallback = () => {
		PostMessage.openCallback(this.params.id);
	}

	convertLead = (lead) => {
		let data = {
			recordId: lead.Id,
			recordData: lead,
			type: 'CONVERT_LEAD'
		};

		PostMessage.openCallback(this.params.id, data);
	}
	
	openEvent= (event) => {
		let data = {
			recordId: event.Id,
			recordType: 'Event',
			type: 'OPEN_EVENT'
		};

		PostMessage.openCallback(this.params.id, data);
	}

	openTask= (task) => {
		let data = {
			recordId: task.Id,
			recordType: 'Task',
			type: 'OPEN_TASK'
		};

		PostMessage.openCallback(this.params.id, data);
	}

	openQuot = (quote) => {
		let data = {
			recordId: quote.Id,
			recordType: 'Quotazione__c',
			type: 'OPEN_QUOT'
		};

		PostMessage.openCallback(this.params.id, data);
	}

	openOpp= (opp) => {
		let data = {
			recordId: opp.Id,
			recordType: 'Opportunity',
			type: 'OPEN_OPP'
		};

		PostMessage.openCallback(this.params.id, data);
	}

	openAccount = (ndg) => {
        let data = {
            recordId: ndg,
            type: 'OPEN_SUBJECT'
        };

        PostMessage.openCallback(this.params.id, data);
    }

	openCustom = (recordId, recordType, title) => {
		let data = {
			recordId: recordId,
			recordType: recordType,
			type: 'OPEN_CUSTOM',
			title: title
		};

		PostMessage.openCallback(this.params.id, data);
	}

	openReport= (recordId, recordData) => {
		let data = {
			recordId,
			recordType: 'Report',
			type: 'OPEN_REPORT',
			recordData
		};

		console.log('openReport', data);

		PostMessage.openCallback(this.params.id, data);
	}

	sendCreateProposal = (dataSend) => {
		let data = {
			recordData: dataSend,
			type: 'NEW_PROP'
		};

		console.log('sendCreateProposal', data);

		PostMessage.openCallback(this.params.id, data);
	}

	openCallbackEvent = (e) => {
		let dataSet = this.proxyData(e.currentTarget.dataset);

		PostMessage.openCallback(this.params.id, dataSet);
	}

	openCallbackEventDOMString = (dataSet) => {
		PostMessage.openCallback(this.params.id, dataSet);
	}

	proxyData(proxyObj) {
		return proxyObj; //JSON.parse(JSON.stringify(proxyObj));
	}

	get hasData() {
		return !this.noData;
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
		this.messages.showSuccess(title, message);
		this.messages = new MobilityMessageModel(this.messages);
	}

	alertMessage(title, message) {
		this.messages.showAlert(title, message);
		this.messages = new MobilityMessageModel(this.messages);
	}

	warningMessage(title, message) {
		this.messages.showWarning(title, message);
		this.messages = new MobilityMessageModel(this.messages);
	}

	warningMessageWithCallback(title, message, confirmCallback){
		this.messages.showWarningWithCallback(title, message, confirmCallback);
		this.messages = new MobilityMessageModel(this.messages);
	}

	criticalMessage() {
		this.messages.showCritical('Non siamo riusciti a recuperare i dati', 'Si prega di ricaricare la pagina');
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

	kFormatter(num) {
		return Math.abs(num) > 999 ? Math.sign(num) * ((Math.abs(num) / 1000).toFixed(1)) + 'k' : Math.sign(num) * Math.abs(num)
	}

	scroll() {
		window.scrollTo({
			top: 0,
			left: 0,
			behavior: 'smooth'
		});
	}

	onOverUpload() {
		this.iconUpload = 'plus-white';
	}

	onOutUpload() {
		this.iconUpload = 'plus';
	}

	onOverScrollTop() {
		this.iconScrollTop = 'arrow-up-white';
	}

	onOutScrollTop() {
		this.iconScrollTop = 'arrow-up';
	}

	onOverEdit() {
		this.iconEdit = 'edit-white';
	}

	onOutEdit() {
		this.iconEdit = 'edit';
	}
}