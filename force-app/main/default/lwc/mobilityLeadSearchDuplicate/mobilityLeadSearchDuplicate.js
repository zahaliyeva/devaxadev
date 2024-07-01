import { track, api } from 'lwc';
import { MobilityAbstract } from 'c/mobilityAbstract';
import { DataGridModel } from 'c/dataGridModel';

import searchDuplicates from '@salesforce/apex/MobilityLeadController.searchDuplicates';

export default class MobilityLeadSearchDuplicate extends MobilityAbstract {
	
	@api lead = {};
	@api closeCallback;

	@track records = {};

	componentView = 'mobilityLeadSearchDuplicate';

	connectedCallback() {
		super.connectedCallback();
		this.loadData();
	}

	loadData() {
		let tableData = {};

		tableData.perPage = 6;

		tableData.encodes = {
			RecordType: value => (value.Name),
			LeadSource: value => {
				switch (value) {
					case 'Web':
						return this._label.lead_source_web;
					case 'External List':
						return this._label.lead_source_externalList;
					case 'Agency':
						return this._label.lead_source_agency;
					case 'Direct contact':
						return this._label.lead_source_directContact;
					case 'Character reference':
						return this._label.lead_source_characterReference;
					default:
						return '';
				}
			},
			Status: {
				valueBadge: value => {
					switch (value) {
						case 'Appointment':
							return this._label.lead_status_appointment;
						case 'Call again':
							return this._label.lead_status_callAgain;
						case 'Does not answer':
							return this._label.lead_status_notAnswer;
						case 'Duplicated Lead':
							return this._label.lead_status_duplicatedLead;
						case 'Not interested':
							return this._label.lead_status_notInterested;
						case 'To be processed':
							return this._label.lead_status_toBeProcessed;
						case 'Wrong contact information':
							return this._label.lead_status_wrongContact;

						default:
							return '';
					}
				},
				type: 'BADGE',
				colors: value => {
					return '#00ADC6';
				}
			},
			CreatedDate: {
				valueDate: value => (value),
				type: 'DATE'
			},
			Owner: value => (value.Name),
			Data_scadenza_polizza_c_o_concorrente__c: {
				valueDate: value => (value),
				type: 'DATE'
			}
		}

		tableData.actions = []
		
		// tableData.fixedFirst = true;
		// tableData.fixedLast = true;
		// tableData.viewSelectRow = true;

		tableData.bind = {
			origin: this,
			target: 'records',
			load: searchDuplicates
		};

		this.records = new DataGridModel(tableData);
		this.records.showSearch = false;
		
		console.log('Load', this.lead);

		const findCriterias = [];

		if(this.lead.Company) findCriterias.push(`Company = '${this.lead.Company}'`);
		if(this.lead.Fiscal_ID__c) findCriterias.push(`Fiscal_ID__c = '${this.lead.Fiscal_ID__c}'`);
		if(this.lead.AAI_Partita_IVA__c) findCriterias.push(`AAI_Partita_IVA__c = '${this.lead.AAI_Partita_IVA__c}'`);

		const filterString = `!QUERY(${findCriterias.join('OR')})`;
		console.log('filterString', filterString);

		this.records.setFilter('LeadSearch', [filterString]);

		this.records.preLoadCallback = () => {
			this.showSpinner(true);
		};

		this.records.loadCallback = (instance, result) => {
			this.showNoData(result.length === 0);
			this.hideSpinner();
		};

		this.records.errorCallback = (instance, err) => {
			console.log(err);
		};

		this.records.orderCallback = (field) => {
			if(field === 'Owner') return 'Owner.Name';
		}

		this.records.load();
	}

	onClose = (e) => {
		if(this.closeCallback) this.closeCallback(e);
	}

}