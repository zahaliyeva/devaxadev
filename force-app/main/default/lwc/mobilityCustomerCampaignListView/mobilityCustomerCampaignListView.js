import { LightningElement } from 'lwc';

import {
	DataGridModel
} from 'c/dataGridModel';

import MobilityCampaignListView from 'c/mobilityCampaignListView';
import getCampaigns from '@salesforce/apex/MobilityCampaignController.getCampaignsTest';
import campaignsCounters from '@salesforce/apex/MobilityCampaignController.campaignsCounters';
import navitateByCustomer from '@salesforce/apex/MobilityCampaignController.navitateByCustomer';

export default class MobilityCustomerCampaignListView extends MobilityCampaignListView {
	componentView = 'mobilityCustomerCampaignListView';

	onNavigateContext = (campaignId) => {
		this.showSpinner();
		navitateByCustomer({
			ndgId: this.params.ndgId,
			campaignId
		}).then((response)=>{
        	if (!response.isSuccess) throw new Error(response.errorMessage);

            this.navigateTo({
            	name: 'MobilityCustomerProcessing',
            	params: {
            		recordId: campaignId,
            		campaignMemberId: response.campaignMemberId,
            		ndgId: this.params.ndgId
            	}
            })
        }).catch((err) => {
            console.log("errChangeStatus: ", err);
            this.alertMessage('Error', '' + err.message);
        }).finally(() => {
        	this.hideSpinner();
        })
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
			icon: 'icon-arrow-right-blue',
			callback: (value) => {
				this.onNavigateContext(value.Id)
			}
		}]

		tableData.fixedFirst = false;
		tableData.fixedLast = true;


		tableData.bind = {
			origin: this,
			target: 'records',
			load: getCampaigns
		};

		this.records = new DataGridModel(tableData);

		if (this.params.ndgId) this.records.setFilter('NDG__c', [this.params.ndgId]);

		this.records.load();
		this.records.preLoadCallback = () => {
			this.showSpinner(true);
		};

		this.records.preLoadCallback = () => {
			this.showSpinner(true);
			this.records.updateAdditionalData({
				counterObject: {},
				counterObjectClosed: {},
				counterObjectPriority: {},
				loaded: {}
			})
		};

		this.records.loadCallback = (instance, result) => {
			//this.pagination = new MobilityPaginationModel(result);
			this.showNoData(result.length === 0);
			this.hideSpinner();

			const additionaldata = {
				getCampaignClosedMember: {},
				getCampaignPriority: {},
				getCampaignsCounters: {},
				loaded: {}
			};

			const promises = [];
			for(let element of result.elements){
				const promiseIstance = campaignsCounters({ids: [element.Id]}).then((resultCounter)=>{
					additionaldata.getCampaignClosedMember = {...additionaldata.getCampaignClosedMember, ...resultCounter.getCampaignClosedMember};
					additionaldata.getCampaignPriority = {...additionaldata.getCampaignPriority, ...resultCounter.getCampaignPriority};
					additionaldata.getCampaignsCounters = {...additionaldata.getCampaignsCounters, ...resultCounter.getCampaignsCounters};
					additionaldata.loaded = {...additionaldata.loaded, [element.Id]: true};
					
					this.records.updateAdditionalData(additionaldata);
				}).catch((err)=>{
					console.log('promises.Element.catch', element.Id, err);
				})

				promises.push(promiseIstance);
			}

			Promise.all(promises).finally(()=>{
				
			})
		};
	}
}