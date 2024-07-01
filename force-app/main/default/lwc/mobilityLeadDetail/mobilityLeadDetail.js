import {
	track
} from 'lwc';

import {
	MobilityAbstract
} from 'c/mobilityAbstract';

import {
	DataGridModel
} from 'c/dataGridModel';

import getQuotations from '@salesforce/apex/MobilityLeadController.getQuotations';
import getEvent from '@salesforce/apex/MobilityLeadController.getEvent';
import getTask from '@salesforce/apex/MobilityLeadController.getTask';
import getTimeStock from '@salesforce/apex/MobilityLeadController.getTimeStock';
import canConvertLead from '@salesforce/apex/MobilityLeadController.canConvertLead';
import changeLeadOwner from '@salesforce/apex/MobilityLeadController.changeLeadOwner';

export default class MobilityLeadDetail extends MobilityAbstract {
	componentView = 'mobilityLeadDetail';

	@track quotations = {};
	@track quotationsTab = 'nav-item lead-tab active';
	@track quotationsPane = 'container tab-pane lead-pane active';

	@track task = {};
	@track taskTab = 'nav-item lead-tab';
	@track taskPane = 'container tab-pane lead-pane';

	@track event = {};
	@track eventTab = 'nav-item lead-tab';
	@track eventPane = 'container tab-pane lead-pane';

	@track iconDocument = 'document';
	@track iconEmail = 'email-blue';
	@track iconCalendar = 'calendar';
	@track iconSearchDublicate = 'people';

	@track timeStock = {};

	@track showEvent = false;
	@track showTask = false;
	@track showEmail = false;
	@track showSearchDuplicate = false;

	customLayout;

	get timeStockLabel() {
		if (!this.timeStock.stringValue) return this._label.leadDetail_timeStock_noData;
		return this.timeStock.stringValue;
	}

	get eventData() {
		return {
			WhoId: this.params.recordId
		}
	}

	get taskData() {
		return {
			WhoId: this.params.recordId,
			Status: 'Open'
		}
	}

	connectedCallback() {
		super.connectedCallback();
		this.loadQuotations();
		this.loadEvent();
		this.loadTask();
		this.loadIimeStock();
	}

	loadIimeStock() {
		getTimeStock({
			leadId: this.params.recordId
		}).then((result) => {
			this.timeStock = result;
		}).catch((errTimeStock) => {
			console.log(errTimeStock);
		})
	}

	hookCustomLayout = (target) => {
		this.customLayout = target;
	}

	loadCallback = (result) => {
		console.log(result);
	}

	get lead() {
		if (!this.customLayout) return {};
		if (!this.customLayout.sections) return {};
		if (!this.customLayout.sections.record) return {};

		return this.customLayout.sections.record;
	}

	get leadDisableConvert() {
		return this.lead.Status === 'Duplicated Lead' || this.hasOwnerQueue;
	}

	get leadCanModified() {
		return this.lead.Status !== 'Duplicated Lead';
	}

	get hasOwnerQueue() {
		return this.lead && this.lead.Owner && this.lead.Owner.Type === 'Queue';
	}

	get sendMailMashup() {
		return `apex/javascriptIntegration?component=mobilityEmail&style=true&recordId=${this.params.recordId}`;
	}

	onConvertLead = () => {
		canConvertLead({
			leadId: this.params.recordId
		}).then((result) => {
			if (!result.isSuccess) throw new Error(result.errorMessage);

			if (result.hasDuplicateLead) {
				this.warningMessage(this._label.leadEdit_warning_title, this.parse(this._label.leadDetail_warningDuplicatedLeadConversion_message, this.lead.Name));
				this.labelWarningConfirmation = this._label.leadEdit_warningDuplicatedLeadConversion_confirmation;
			} else if (result.canConvertLead) {
				changeLeadOwner(
					{
						LeadId: this.params.recordId
					}
				).then((resultchange) =>{
					if(resultchange)
				this.convertLead(this.lead);
					
				});
				
			}
		}).catch((err) => {
			this.alertMessage(this._label.leadEdit_warning_title, err.message);
		})
	}

	onConfirmConvert = () => {
		this.convertLead(this.lead);
	}

	onSendEmail = (e) =>{
		if(this.lead.Email && this.lead.Email.trim() !== ''){
			this.toggleEmail(e);
		}else{
			this.alertMessage('Error', 'Email non popolata sul Lead corrente');
		}
	}

	onSearchDuplicate = (e) => {
		if(!this.lead.Company && !this.lead.Fiscal_ID__c && !this.lead.AAI_Partita_IVA__c){
			this.alertMessage('Attenzione', 'Codice Fiscale o Partita Iva non popolati');
			return;
		}
		this.toggleSearchDuplicate(e);
	}

	toggleEmail = (e) => {
		this.showEmail = !this.showEmail;
	}

	toggleEvent = (e) => {
		this.showEvent = !this.showEvent;
	}

	toggleTask = (e) => {
		this.showTask = !this.showTask;
	}

	toggleSearchDuplicate = (e) => {
		this.showSearchDuplicate = !this.showSearchDuplicate;
	}

	closeEventLoad = (e) => {
		if (this.showEvent) this.event.load();
	}

	closeTaskLoad = (e) => {
		if (this.showTask) this.task.load();
	}

	loadTask() {
		let tableData = {};

		tableData.perPage = 6;

		tableData.encodes = {
			RecordType: value => (value.Name),
			ActivityDate: {
				valueDate: value => (value),
				type: 'DATE'
			},
			Owner: value => (value.Name),
			Status: {
				valueBadge: value => {
					switch (value) {
						case 'Open':
							return this._label.task_open;
						case 'In progress':
							return this._label.task_inProgress;
						case 'Pending':
							return this._label.task_pending;
						case 'Completed':
							return this._label.task_completed;
						case 'Out of Time':
							return this._label.task_outOfTime;
						case 'Information Received':
							return this._label.task_informationReceived;
						case 'In attesa per anomalia IT':
							return this._label.task_pendingFreakIt;

						default:
							return '';
					}
				},
				type: 'BADGE',
				colors: value => {
					return '#00ADC6';
				}
			}
		}

		tableData.bind = {
			origin: this,
			target: 'task',
			load: getTask
		};
		tableData.actions = [{
			label: '',
			icon: 'icon-arrow-right-blue',
			callback: (value) => {
				this.openTask(value)
			}
		}] 
		this.task = new DataGridModel(tableData);
		this.task.setFilter('WhoId', [this.params.recordId]);
		this.task.preLoadCallback = () => {
			this.showSpinner(true);
		};
		this.task.loadCallback = (instance, result) => {
			this.hideSpinner();
		};
		this.task.load();
	}

	loadEvent() {
		let tableData = {};

		tableData.perPage = 6;

		tableData.encodes = {
			RecordType: value => (value.Name),
			StartDateTime: {
				valueDate: value => (value),
				type: 'DATE'
			},
			Owner: value => (value.Name),
		}

		tableData.bind = {
			origin: this,
			target: 'event',
			load: getEvent
		};
		tableData.actions = [{
			label: '',
			icon: 'icon-arrow-right-blue',
			callback: (value) => {
				this.openEvent(value)
			}
		}] 
		this.event = new DataGridModel(tableData);
		this.event.setFilter('WhoId', [this.params.recordId]);
		this.event.preLoadCallback = () => {
			this.showSpinner(true);
		};
		this.event.loadCallback = (instance, result) => {
			this.hideSpinner();
		};
		this.event.load();
	}

	loadQuotations() {
		let tableData = {};

		tableData.perPage = 6;

		tableData.encodes = {
			RecordType: value => (value.Name),
			Origine__c: value => {
				if(!value) return '';

				if(value === 'Semplicemente casa'){
					return this._label.QuotationStatus;
				}

				return value;
			},
			CreatedDate: {
				valueDate: value => (value),
				type: 'DATE'
			}
		}

		tableData.bind = {
			origin: this,
			target: 'quotations',
			load: getQuotations
		};
		
		tableData.actions = [{
			label: '',
			icon: 'icon-arrow-right-blue',
			callback: (value) => {
				this.openQuot(value)
			}
		}] 

		this.quotations = new DataGridModel(tableData);
		this.quotations.setFilter('Lead__c', [this.params.recordId]);
		this.quotations.preLoadCallback = () => {
			this.showSpinner(true);
		};
		this.quotations.loadCallback = (instance, result) => {
			this.hideSpinner();
		};
		this.quotations.load();
	}

	activeTab(e) {
		if (e.currentTarget.dataset.target === '0') {
			this.quotationsTab = 'nav-item lead-tab active';
			this.quotationsPane = 'container tab-pane lead-pane active';

			this.taskTab = 'nav-item lead-tab';
			this.taskPane = 'container tab-pane lead-pane d-none';

			this.eventTab = 'nav-item lead-tab';
			this.eventPane = 'container tab-pane lead-pane d-none';
		} else if (e.currentTarget.dataset.target === '1') {
			this.quotationsTab = 'nav-item lead-tab';
			this.quotationsPane = 'container tab-pane lead-pane d-none';

			this.taskTab = 'nav-item lead-tab active';
			this.taskPane = 'container tab-pane lead-pane active';

			this.eventTab = 'nav-item lead-tab';
			this.eventPane = 'container tab-pane lead-pane d-none';
		} else if (e.currentTarget.dataset.target === '2') {
			this.quotationsTab = 'nav-item lead-tab';
			this.quotationsPane = 'container tab-pane lead-pane d-none';

			this.taskTab = 'nav-item lead-tab';
			this.taskPane = 'container tab-pane lead-pane d-none';

			this.eventTab = 'nav-item lead-tab active';
			this.eventPane = 'container tab-pane lead-pane active';
		}
	}

	onOverEmail() {
		this.iconEmail = 'email-white';
	}

	onOutEmail() {
		this.iconEmail = 'email-blue';
	}

	onOverDocument() {
		this.iconDocument = 'document-white';
	}

	onOutDocument() {
		this.iconDocument = 'document';
	}

	onOverCalendar() {
		this.iconCalendar = 'calendar-white';
	}

	onOutCalendar() {
		this.iconCalendar = 'calendar';
	}

	onOverSearchDublicate(){
		this.iconSearchDublicate = 'people-white'
	}

	onOutSearchDuplicate(){
		this.iconSearchDublicate = 'people'
	}
}