import {
	MobilityCampaignModel
} from 'c/mobilityCampaignModel';
import {
	api,
	track
} from 'lwc';
import getCollaborators from '@salesforce/apex/MobilityCampaignController.getCollaborators';
import getCounters from '@salesforce/apex/MobilityCampaignController.getCounters';
import {
	MobilityPaginationModel
} from 'c/mobilityPaginationModel';
import {
	DataGridModel
} from 'c/dataGridModel';
import getOpportunity from '@salesforce/apex/MobilityCampaignController.getOpportunity';
import {
	MobilityAbstract
} from 'c/mobilityAbstract';
import getActivities from '@salesforce/apex/MobilityCampaignController.getActivities';
import getHistory from '@salesforce/apex/MobilityCampaignController.getHistory';

export default class MobilityCampaignEdit extends MobilityAbstract {

	@api recordType;

	@track collaborators = [];
	@track counters = [];
	@track model = new MobilityCampaignModel();
	@track iconUpload = 'plus';
	@track iconScrollTop = 'arrow-up';

	@track opportunity = {};
	@track paginationOpportunity = new MobilityPaginationModel();
	@track searchOpportunity = '';
	@track opportunityTabClass = '';
	@track opportunityPaneClass = '';
	@track CreatedDate;
	@track CloseDate;
	@track noDataOpportunity = false;

	@track activities = {};
	@track paginationActivities = new MobilityPaginationModel();
	@track searchActivities = '';
	@track activitiesTabClass = '';
	@track activitiesPaneClass = '';
	@track noDataActivities = false;

	@track history = {};
	@track paginationHistory = new MobilityPaginationModel();
	@track searchHistory = '';
	@track historyTabClass = '';
	@track historyPaneClass = '';
	@track noDataHistory = false;

	@track attachedName = 'Documento N^ AS125698BT';
	@track attachedSize = '2,5MB';
	@track attachedDate = '15/09/2019';

	@track loadDoughnut = false;

	connectedCallback() {
		this.connectVisibilities();
		this.setTabClass();

		console.time('track');
		
		Promise.all([
			this.loadCollaborator(),
		]).then(()=>{
			this.loadOpportunity(),
			this.loadActivities(),
			this.loadHistory()
				this.loadDoughnut = true;
				this.hideSpinner();
				console.timeEnd('track');
		})
		
		this.loadCounters();
	}

	setTabClass() {
		if(this.recordType === 'Informative_Campaign' || this.recordType === 'Data_Enrichment_Campaign' ){
			this.activitiesTabClass = 'nav-item active';
			this.activitiesPaneClass = 'tab-pane active';
			
			this.historyTabClass = 'nav-item';
			this.historyPaneClass = 'tab-pane';
		}else{
			this.opportunityTabClass = 'nav-item active';
			this.opportunityPaneClass = 'tab-pane active';
		
			this.activitiesTabClass = 'nav-item';
			this.activitiesPaneClass = 'tab-pane ';
			
			this.historyTabClass = 'nav-item';
			this.historyPaneClass = 'tab-pane';
		}

	}

	loadCollaborator() {
		return getCollaborators({
			campaignId: this.params.recordId
		}).then((result) => {
			let listData = [{
				value: 'ALL',
				label: this._label.campaignDetail_agency
			}];

			for (let key in result) {
				listData.push({
					label: result[key],
					value: key
				});
			}

			this.collaborators = listData;

		}).catch((err) => {
			console.log('err', this.proxyData(err));
		}).finally(() => {
			this.hideSpinner();
		});
	}

	loadCounters(collaboratorId = null) {
		if(this.isRoleWorker && this.collaborators && this.collaborators[0]){
			collaboratorId = this.collaborators[0].value;
		}

		if(!this.spinner) this.showSpinner(true);

		return getCounters({
			campaignId: this.params.recordId,
			collaboratorId: collaboratorId
		}).then((result) => {
			this.counters = this.proxyData(result);
		}).catch((err) => {
			console.log('err', this.proxyData(err));
		}).finally(() => {
			this.hideSpinner();
		});
	}

	reloadData(e) {
		let value = e.target.value;
		if (value === 'ALL') value = null;
		this.loadCounters(value);
	}

	get showOpportunity(){
	  if(this.recordType === 'Informative_Campaign' || this.recordType === 'Data_Enrichment_Campaign')
		 return false;
		 else return true;
	}

	get showAttachment(){
		return this.recordType === 'Agency_campaign';
	}

	get isInformative(){
		return this.recordType === 'Informative_Campaign';
	}

	get isDataEnrichment(){
		return this.recordType === 'Data_Enrichment_Campaign';
	}

	get isMarketing(){
		return this.recordType === 'Marketing_campaign';
	}

	get nameReport1(){
		if(this.isInformative) return 'NFE_Clienti_informative_suddivisi_per_xvi';
		return 'NFE_Clienti_suddivisi_per_stato_hTj';
	}

	get nameReport2(){
		if(this.isInformative) return 'NFE_Esito_contatto_informativo_QXt';
		return 'NFE_Trattative_suddivise_per_stato_hLV';
	}

	get titleReport1(){
		return `Clienti divisi per stato`;
	}

	get titleReport2(){
		if(this.isInformative) return 'Esito contatto informativo';
		return `Trattative divise per stato`;
	}

	get customersProcessedPercentage() {
		if (this.counters.customersInTarget === 0) return 0;
		return parseInt((this.counters.customersProcessed / this.counters.customersInTarget) * 100);
	}

	get customersPriorityProcessedPercentage() {
		if (this.counters.customersPriority === 0) return 0;
		return parseInt((this.counters.customersPriorityProcessed / this.counters.customersPriority) * 100);
	}

	get wonOpportunityPercCustomerTarget() {
		if (this.counters.customersInTarget === 0) return 0;
		return parseInt((this.counters.opportunityWon / this.counters.customersInTarget) * 100);
	}

	get wonOpportunityPercCustomerProcessed() {
		if (this.counters.customersProcessed === 0) return 0;
		return parseInt((this.counters.opportunityWon / this.counters.customersProcessed) * 100);
	}

	get wonOpportunityPercCustomerPriority() {
		if (this.counters.customersPriority === 0) return 0;
		return parseInt((this.counters.opportunityWonCustomerPriority / this.counters.customersPriority) * 100);
	}

	get createdOpportunityPercCustomerProcessed() {
		if (this.counters.customersProcessed === 0) return 0;
		return parseInt((this.counters.opportunityCreated / this.counters.customersProcessed) * 100);
	}

	get opportunityOngoing() {
		if (this.counters.opportunityOngoing === 0) return 0;
		return this.counters.opportunityOngoing;
	}

	get opportunityOngoingRevenue() {
		if (this.counters.opportunityOngoingRevenue === 0) return 0;
		if (this.counters.opportunityOngoingRevenue === -1) return 0;
		return this.counters.opportunityOngoingRevenue;
	}

	get forEmailSmsUndeliveredCustomerEmailSmsTarget(){
		if (this.counters.customersInTargetWithEmailSMS === 0) return 0;
		return parseInt((this.counters.undeliveredEmailSMS / this.counters.customersInTargetWithEmailSMS) * 100);
	}

	get forCustomerPriority(){
		if (this.counters.deliveredEmailSMS === 0) return 0;
		return parseInt((this.counters.customersPriority / this.counters.deliveredEmailSMS) * 100);
	}
	
	get forOpenEmailRecontactRequest(){
		if (this.counters.customersInTargetWithEmail === 0) return 0;
		return parseInt((this.counters.customersOpenEmailContactRequest / this.counters.customersInTargetWithEmail) * 100);
	}
	
	get forCustomerPriorityWithEmail(){
		if (this.counters.customersOpenEmailContactRequest === 0) return 0;
		return parseInt((this.counters.customersPriorityEmail / this.counters.customersOpenEmailContactRequest) * 100);
	}
	
	get forSmsOpenRecontactRequest(){
		if (this.counters.customersOpenSMSContactRequest === 0) return 0;
		return parseInt((this.counters.customersPrioritySMS / this.counters.customersOpenSMSContactRequest) * 100);
	}

	get progressWidth() {
		let width = `width: ${this.customersProcessedPercentage}%;`;
		if (this.customersProcessedPercentage < 7) width = 'width: 30px;';

		return width;
	}

	get progressStyle() {
		let style = ["progress-bar", "counter-progress-bar"];

		if (
			this.model.RecordType.DeveloperName === 'Agency_campaign') {
			style.push("counter-bar-agency");
		} else {
			style.push("counter-bar-direction");
		}

		return style.join(" ");
	}

	get priority() {
		if (this.counters.customersPriority === 1) return this._label.campaignDetail_priority_prior;

		return this._label.campaignDetail_priority_prioritary;
	}

	get priorityCustomer() {
		if (this.counters.customersPriority === 1) return 'Cliente ' + this._label.campaignDetail_priority_prior;

		return 'Clienti ' + this._label.campaignDetail_priority_prioritary;
	}

	get targetCustomer() {
		if (this.counters.customersInTarget === 1) return this._label.campaignDetail_targetCustomer;

		return this._label.campaignDetail_targetCustomers;
	}

	get workedNumber() {
		let worked = this.counters.customersProcessed;
		if (worked === 0) return worked = '';
		return worked;
	}

	
	activeTab(e) {
		if (e.currentTarget.dataset.target === '0') {
			this.opportunityTabClass = 'nav-item active';
			this.opportunityPaneClass = 'table-contain tab-pane active';

			this.activitiesTabClass = 'nav-item';
			this.activitiesPaneClass = 'table-contain tab-pane';

			this.historyTabClass = 'nav-item';
			this.historyPaneClass = 'table-contain tab-pane';
		} else if (e.currentTarget.dataset.target === '1') {
			this.opportunityTabClass = 'nav-item';
			this.opportunityPaneClass = 'table-contain tab-pane';

			this.activitiesTabClass = 'nav-item active';
			this.activitiesPaneClass = 'table-contain tab-pane active';

			this.historyTabClass = 'nav-item';
			this.historyPaneClass = 'table-contain tab-pane';
		} else if (e.currentTarget.dataset.target === '2') {
			this.opportunityTabClass = 'nav-item';
			this.opportunityPaneClass = 'table-contain tab-pane';

			this.activitiesTabClass = 'nav-item';
			this.activitiesPaneClass = 'table-contain tab-pane';

			this.historyTabClass = 'nav-item active';
			this.historyPaneClass = 'table-contain tab-pane active';
		}
	}

	loadOpportunity() {
		let tableData = {};

		tableData.perPage = 6;

		tableData.encodes = {
			RecordType: value => (value.Name),
			CreatedDate: {
				valueDate: value => (value),
				type: 'DATE'
			},
			CloseDate: {
				valueDate: value => (value),
				type: 'DATE'
			},
			Owner: value => (value.Name),
			Account: {
				valueLabel: value => {
				if (value) {
					return value.Name;
				}
				return '';
				},
				onClick: this.openAccount,
				type: 'REDIRECT'
			}
		}

		tableData.bind = {
			origin: this,
			target: 'opportunity',
			load: getOpportunity
		};

		tableData.actions = [{
			label: '',
			icon: 'icon-arrow-right-blue',
			callback: (value) => {				
				this.openOpp(value)
			}
		}]

		this.opportunity = new DataGridModel(tableData);

		this.opportunity.setFilter('CampaignId', [this.params.recordId]);

		this.opportunity.load();
		this.opportunity.preLoadCallback = () => {
			this.showSpinner(true);
		};

		this.opportunity.loadCallback = (instance, result) => {
			//this.paginationOpportunity = new MobilityPaginationModel(result);
			this.showNoData(result.length === 0);
			//if (result.length === 0) this.noDataOpportunity = true;
			this.hideSpinner();
		};
	}

	loadActivities() {
		let tableData = {};

		tableData.perPage = 6;

		tableData.encodes = {
			RecordType: value => (value.Name),
			ActivityDate: {
				valueDate: value => (value),
				type: 'DATE'
			},
			Owner: value => (value.Name),
			Who: value => {
				if (value) {
					return value.Name;
				}
				return '';
			}
		}

		tableData.bind = {
			origin: this,
			target: 'activities',
			load: getActivities
		};

		tableData.actions = [{
			label: '',
			icon: 'icon-arrow-right-blue',
			callback: (value) => {
				this.openTask(value)
			}
		}]

		this.activities = new DataGridModel(tableData);

		this.activities.setFilter('WhatId', [this.params.recordId]);

		this.activities.load();
		this.activities.preLoadCallback = () => {
			this.showSpinner(true);
		};

		this.activities.loadCallback = (instance, result) => {
			//this.paginationActivities = new MobilityPaginationModel(result);
			this.showNoData(result.length === 0);
			//if (result.length === 0) this.noDataActivities = true;
			this.hideSpinner();
		};
		
	}

	loadHistory() {
		let tableData = {};

		tableData.perPage = 6;

		tableData.encodes = {
			RecordType: value => (value.Name),
			ActivityDate: {
				valueDate: value => (value),
				type: 'DATE'
			},
			LastModifiedDate: {
				valueDate: value => (value),
				type: 'DATE'
			},
			Owner: value => (value.Name),
			Who: value => {
				if (value) {
					return value.Name;
				}
				return '';
			}
		}

		tableData.bind = {
			origin: this,
			target: 'history',
			load: getHistory
		};

		tableData.actions = [{
			label: '',
			icon: 'icon-arrow-right-blue',
			callback: (value) => {
				this.openTask(value)
			}
		}] 
		this.history = new DataGridModel(tableData);

		this.history.setFilter('WhatId', [this.params.recordId]);

		this.history.load();
		this.history.preLoadCallback = () => {
			this.showSpinner(true);
		};

		this.history.loadCallback = (instance, result) => {
			//this.paginationHistory = new MobilityPaginationModel(result);
			this.showNoData(result.length === 0);
			//if (result.length === 0) this.noDataHistory = true;
			this.hideSpinner();
		};
	}

	onOverUpload() {
		this.iconUpload = 'plus-white';
	}

	onOutUpload() {
		this.iconUpload = 'plus';
	}
}