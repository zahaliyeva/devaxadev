import {
	track
} from 'lwc';

import {
	MobilityAbstract
} from 'c/mobilityAbstract';

import {
	DataGridModel
} from 'c/dataGridModel';

import getCampaigns from '@salesforce/apex/MobilityCampaignController.getCampaignsTest';
import campaignsCounters from '@salesforce/apex/MobilityCampaignController.campaignsCounters';
//using ctrl class from other comp for no coding
import getPickListValues from '@salesforce/apex/MobilityCampaignController.getPickListValuesFromMTD';

export default class mobilityCampaignListView extends MobilityAbstract {
	componentView = 'mobilityCampaignListView';

	@track records = {};
	@track optionsTipologia;
	@track status = [
		{ label: 'ALL', value: 'ALL' },
		{ label: this._label.campaign_onGoing, value: 'On-going' },
		{ label: this._label.campaign_completed, value: 'Completed' },
		{ label: this._label.campaign_aborted, value: 'Aborted' },
		{ label: this._label.campaign_planned, value: 'Planned' }
	];

	connectedCallback() {
		super.connectedCallback();

		//aggiunto per filtro campagna IDCRM 018
		getPickListValues({
		})
		.then(data => {
			this.optionsTipologia = data;
		})
		.catch(error => {
			this.displayError(error);
		});

		// old code 
		this.loadData();
	}

	loadData() {
		let tableData = {};

		tableData.perPage = 6;

		tableData.encodes = {
			RecordType: value => (value.Name),
			Status: {
				valueBadge: value => {
					switch (value) {
						case 'On-going':
							return this._label.campaign_onGoing;
						case 'Completed':
							return this._label.campaign_completed;
						case 'Aborted':
							return this._label.campaign_aborted;
						case 'Planned':
							return this._label.campaign_planned;

						default:
							return '';
					}
				},
				type: 'BADGE',
				colors: value => {
					return '#00ADC6';
				}
			},
			StartDate: {
				valueDate: value => (value),
				type: 'DATE'
			},
			EndDate: {
				valueDate: value => (value),
				type: 'DATE'
			}
		}

		tableData.actions = [{
			label: '',
			icon: 'edit',
			condition: (value) => {
				return this.isVenditeAvanzato && value.RecordType.DeveloperName == 'Agency_campaign';
			},
			callback: (value) => {

				this.navigateTo({
					name: 'MobilityCampaignEdit',
					params: {
						recordId: value.Id
					}
				})
			}
		},
		{
			label: '',
			icon: 'icon-arrow-right-blue',
			callback: (value) => {
				this.navigateTo({
					name: 'MobilityCampaignDetail',
					params: {
						recordId: value.Id
					}
				})
			}
		}
		]

		tableData.fixedFirst = false;
		tableData.fixedLast = true;

		tableData.bind = {
			origin: this,
			target: 'records',
			load: getCampaigns
		};

		this.records = new DataGridModel(tableData);
		if (this.params.ndgId) this.records.setFilter('NDG__c', [this.params.ndgId]);
		
		this.records.setFilter('IncentiveCampaign__c', ['!BOOLEAN(false)']);

		if(this.params.campaignType) {
			let isCampaign = this.params.campaignType == "Agenzia" ? true : false 
			//this.records.setFilter('Campagna_creata_da_Agenzia__c ',[`!BOOLEAN(${isCampaign})`]);
			this.records.setFilter('Campagna_creata_da_Direzione_Agente__c',[`!BOOLEAN(${isCampaign})`]);
		}
		this.records.preLoadCallback = () => {
			this.showSpinner(true);
			this.records.updateAdditionalData({
				counterObject: {},
				counterObjectClosed: {},
				counterObjectPriority: {},
			})
		};

		this.records.loadCallback = (instance, result) => {
			//this.pagination = new MobilityPaginationModel(result);
			console.log('result', result);
			this.showNoData(result.length === 0);
			
			//this.records.cachedMode = false;

			const additionaldata = {
				getCampaignClosedMember: {},
				getCampaignPriority: {},
				getCampaignsCounters: {}
			};

			const promises = [];
			for(let element of result.elements){
				const promiseIstance = campaignsCounters({ids: [element.Id]}).then((resultCounter)=>{
					additionaldata.getCampaignClosedMember = {...additionaldata.getCampaignClosedMember, ...resultCounter.getCampaignClosedMember};
					additionaldata.getCampaignPriority = {...additionaldata.getCampaignPriority, ...resultCounter.getCampaignPriority};
					additionaldata.getCampaignsCounters = {...additionaldata.getCampaignsCounters, ...resultCounter.getCampaignsCounters};

					this.records.updateAdditionalData(additionaldata);
				}).catch((err)=>{
					console.log('promises.Element.catch', element.Id, err);
				})

				promises.push(promiseIstance);
			}

			Promise.all(promises).finally(()=>{
				this.hideSpinner();
			})
		};

		this.records.load();
	}

	onIncentive(e){
		const checked = e.target.checked;

		console.log('onIncentive' , checked);

		this.records.setFilter('IncentiveCampaign__c', [`!BOOLEAN(${checked})`]);
	}

	statusChange() {

		var statusSelect = this.template.querySelector('[data-id="Status_Campagna"]').value;

		//console.debug('testing - status -'+statusSelect+' tipo- '+tipologiaSelect);
		
		if (statusSelect == 'ALL') 
			statusSelect = ' ';

		this.records.setFilter('Status', [statusSelect]);
	}
	TipologiaChange() {

		var tipologiaSelect = this.template.querySelector('[data-id="Tipologia_Campagna"]').value;

		//console.debug('testing - status -'+statusSelect+' tipo- '+tipologiaSelect);

		if (tipologiaSelect == 'ALL') 
			tipologiaSelect = ' ';
			
		this.records.setFilter('RecordType.DeveloperName', tipologiaSelect.split(';'));

	}
}