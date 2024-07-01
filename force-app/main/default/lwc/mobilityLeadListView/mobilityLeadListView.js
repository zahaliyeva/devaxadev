import {
	track,
	api
} from 'lwc';

import {
	MobilityAbstract
} from 'c/mobilityAbstract';

import {
	DataGridModel
} from 'c/dataGridModel';

import getLeadListView from '@salesforce/apex/MobilityLeadController.getLeadListView';
import proxyGetListView from '@salesforce/apex/MobilityLeadController.proxyGetListView';
import mapColors from '@salesforce/apex/MobilityLeadController.getColorsFromLead';
import { MobilityLib } from 'c/mobilityLib';
import Format from '@salesforce/schema/Report.Format';

export default class MobilityLeadListView extends MobilityAbstract {
	componentView = 'mobilityLeadListView';

	@track records = {};
	@track showLeadQueue = false;
	@track showLeadOwner = false;
	@track params1;
	@track params2;
	@track params3;
	@track showList = false;
	@track rerenderSelect = {val: "true"}; //utilizzato solo per far ripartire il template e rivalorizzare le picklist
	resetPicks1 = true;
	resetPicks2 = true;
	resetPicks3 = true;
	@api params;
	chosenFilter;
	
	
	updateCharts = true;
	leadColored = null;
	mapLeadColor = null;

	filterMaps = new Map();
	sourceMap = new Map();
	dettagliMap = new Map();
	statusMap = new Map();
	originMap = new Map();

	filters = [
		{ label: 'Tutti i Lead', value: 'All', default: true },
		{ label: 'Lead prioritari da web',value: 'Web_priority' },
		{ label: 'Di cui lead salute', value: 'Health'}
	];

	leadSource = [
		{label: this._label.leadListView_leadSource, value:'', selected : true, disabled : true },
		{ label: 'ALL', value: 'ALL', selected : false },
		{ label: this._label.lead_source_web, value: 'Web', selected : false },
		{ label: this._label.lead_source_externalList, value: 'External List', selected : false },
		{ label: this._label.lead_source_agency, value: 'Agency', selected : false},
		{ label: this._label.lead_source_directContact, value: 'Direct contact', selected : false },
		{ label: this._label.lead_source_characterReference, value: 'Character reference', selected : false },
		{ label: this._label.lead_source_Lead_Da_MPS, value: 'Lead da MPS', selected : false },
		
		// { label: this._label.lead_source_advertisement, value: 'Advertisement' },
		// { label: this._label.lead_source_employeeReferral, value: 'Employee Referral' },
		// { label: this._label.lead_source_externalReferral, value: 'External Referral' },
		// { label: this._label.lead_source_partner, value: 'Partner' },
		// { label: this._label.lead_source_purchasedList, value: 'Purchased List' },
		// { label: this._label.lead_source_tradeShow, value: 'Trade Show' },
		// { label: this._label.lead_source_wordOfMouth, value: 'Word of mouth' },
		// { label: this._label.lead_source_publicRelations, value: 'Public Relations' },
		// { label: this._label.lead_source_seminarInternal, value: 'Seminar - Internal' },
		// { label: this._label.lead_source_seminarPartner, value: 'Seminar - Partner' },
		// { label: this._label.lead_source_other, value: 'Other' },
		// { label: this._label.lead_source_infoMeeting, value: 'Info Meeting' }
	];

	dettagliFonte = [
		{label: 'Dettaglio Fonte Lead', value:'', selected : true, disabled : true },
		{label: 'ALL', value: 'ALL', selected : false },
		{label: 'Visualizza quotazione', value: 'Visualizza quotazione', selected : false},
		{label: 'Salva quotazione', value: 'Salva quotazione', selected : false},
		{label: 'Salva preventivo', value: 'Salva preventivo', selected : false},
		{label: 'Richiedi appuntamento', value: 'Richiedi appuntamento', selected : false},
		{label: 'Acquista', value: 'Acquista', selected : false},
		{label: 'Inizia pagamento', value: 'Inizia pagamento', selected : false},
		{label: 'KO pagamento', value: 'KO pagamento', selected : false},
		{label: 'KO finale banca', value: 'KO finale banca', selected : false},
		{label: 'OK pagamento', value: 'OK pagamento', selected : false},
		{label: 'Lead da AXA Caring - E-commerce Servizi Salute', value: 'Lead da AXA Caring Servizi Salute', selected : false}
	];

	status = [
		{ label: this._label.leadListView_leadStatus, value:'', selected : true, disabled : true },
		{ label: 'ALL', value: 'ALL' , selected : false},
		{ label: this._label.lead_status_toBeProcessed, value: 'To be processed', selected : false },
		{ label: this._label.lead_status_notAnswer, value: 'Does not answer', selected : false },
		{ label: this._label.lead_status_callAgain, value: 'Call again', selected : false },
		{ label: this._label.lead_status_notInterested, value: 'Not interested', selected : false },
		{ label: this._label.lead_status_appointment, value: 'Appointment', selected : false }
		// { label: this._label.lead_status_wrongContact, value: 'Wrong contact information' },
		// { label: this._label.lead_status_duplicatedLead, value: 'Duplicated Lead' },
	];

	Origin = [
		{ label: 'Origine', value:'', selected : true, disabled : true },
		{label: 'ALL', value: 'ALL' , selected : false},
		{label : 'Pagina prodotto AXA', value : 'Pagina prodotto AXA', selected : false},
		{label : 'Assistenza360', value : 'Assistenza360', selected : false},
		{label : 'InGiro', value : 'InGiro', selected : false},
		{label : 'Tutta la vita', value : 'Tutta la vita', selected : false},
		{label : 'Semplicemente casa', value : 'Semplicemente casa', selected : false},
		{label : 'Centri Diagnostici', value : 'Centri Diagnostici', selected : false},
		{label : 'Per Noi', value : 'Per Noi', selected : false},
		{label : 'ConFido', value : 'ConFido', selected : false},
		{label : 'Buon Lavoro', value : 'Buon Lavoro', selected : false},
		{label : 'Previsio', value : 'Previsio', selected : false},
		{label : 'Preventivo veloce', value : 'Preventivo veloce', selected : false},
		{label : 'Trova Agente', value : 'Trova Agente', selected : false},
		{label : 'Full Quote' , value : 'Full Quote', selected : false},
		{label : 'Protezione su misura' , value : 'Protezione su misura', selected : false},
		{label : 'Preventivo Impresa' , value : 'Preventivo Impresa', selected : false},
		{label : 'Siti Agenti' , value : 'Siti Agenti', selected : false},
		{label : 'Employees Benefit' , value : 'Employees Benefit', selected : false},
		{label : 'Protezione Turismo' , value : 'Protezione Turismo', selected : false},
		{label : 'Io Domani' , value : 'Io Domani', selected : false},
		{label : 'Preventivatore Turismo' , value : 'Preventivatore Turismo', selected : false},
		{label : 'AXA Caring - E-commerce Servizi Salute' , value : 'AXA Caring Servizi Salute', selected : false},


	]
	proxyData(data){
		return JSON.parse(JSON.stringify(data));
	}

	resetPicklists(){
		//this.resetPicks1 = this.resetPicks2 = this.resetPicks3 = true;
		
		for(let pick of this.status){
			pick.selected = false;
		}
		this.status[0].selected = true;
		
		for(let pick of this.dettagliFonte){
			pick.selected = false;
		}
		this.dettagliFonte[0].selected = true;

		for(let pick of this.leadSource){
			pick.selected = false;
		}
		this.leadSource[0].selected = true;

		for(let pick of this.Origin){
			pick.selected = false;
		}
		this.Origin[0].selected = true;
	}

	mapFilters(){

		for(const el of this.status)
			this.statusMap.set(el.value, el);
		for(const el of this.dettagliFonte)
			this.dettagliMap.set(el.value, el);
		for(const el of this.leadSource)
			this.sourceMap.set(el.value, el);
		for(const el of this.Origin)
			this.originMap.set(el.value, el);
		

	}

	connectedCallback() {
		
		console.log(JSON.parse(JSON.stringify(this.params)));
		super.connectedCallback();

		if(this.params.DefaultFilter){
			this.chosenFilter = this.params.DefaultFilter;
			console.log("chosenFilter: ", this.chosenFilter);
			for(const pick of this.filters){
				if(pick.value === this.params.DefaultFilter){
					pick.selected = true;
					
				}
			}
		}
		else{
			for(const pick of this.filters){
				if(pick.default){
					pick.selected = true;
					this.chosenFilter = pick.value;
				}
			}	
		}
		for(const filter of this.filters){
			this.filterMaps.set(filter.value, filter);
		}
		this.mapFilters();
		this.loadData();
		
	}

	onShowLeadQueue = () => {
		this.showLeadQueue = !this.showLeadQueue;
	}

	onShowLeadOwner = () => {
		this.showLeadOwner = !this.showLeadOwner;
	}

	get isDisabledChangeOwner() {
		return this.records.listSelected.length === 0;
	}

	filterChange(event){

		let value = event.target.value;
		if(value != this.chosenFilter){
			this.rerenderSelect = null;
			this.resetPicklists();
			
			
			this.filterMaps.get(this.chosenFilter).selected = false;
			this.filterMaps.get(value).selected = true;
			console.log(JSON.parse(JSON.stringify(this.template.querySelectorAll('reset'))));
			
			/*this.updateCharts = true;
			this.leadColored = null;*/
			this.chosenFilter = value;
			this.loadData();
			
			
		}
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
					case 'Lead da MPS':
						return this._label.lead_source_Lead_Da_MPS;
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
							return value;
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
			},
			Dettaglio__c: {
				valueLabel: value => (value),
				colors: value=>(value),
				type: 'COLOREDLABEL'
			}
		}

		tableData.actions = [{
			label: '',
			icon: 'edit',
			disabled: value => (value.Status === 'Duplicated Lead'),
			callback: value => {
				this.navigateTo({
					name: 'MobilityLeadEdit',
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
					name: 'MobilityLeadDetail',
					params: {
						recordId: value.Id
					}
				})
			}
		}
		]

		tableData.fixedFirst = true;
		tableData.fixedLast = true;
		tableData.viewSelectRow = true;

		tableData.bind = {
			origin: this,
			target: 'records',
			load: this.getLeads,
			
			chosenFilter: this.chosenFilter
		};

		this.records = new DataGridModel(tableData);
		//this.records = 

		console.log("records: ", this.records);
		this.records.preLoadCallback = () => {
			this.showSpinner(true);
		};

		this.records.loadCallback = (instance, result) => {
			this.showNoData(result.length === 0);
			
			this.mapLeadColors(result);
			
			
		};

		this.records.errorCallback = (instance, err) => {
			console.log(err);
		};

		this.records.orderCallback = (field) => {
			if(field === 'Owner') return 'Owner.Name';
		}

		this.records.load();
		
	}

	leadSourceChange(e) {
		this.resetPicks2 = false;
		
		let value = e.target.value;
		this.sourceMap.get(value).selected = true;
		this.leadSource[0].selected = false;
		/*this.updateCharts = true;
		this.leadColored = null;*/
		if (value === 'ALL') value = '';
		this.records.setFilter('LeadSource', [value]);
	}

	leadDettaglioChange(e){
		this.resetPicks3 = false;
		let value = e.target.value;
		this.dettagliMap.get(value).selected = true;
		this.dettagliFonte[0].selected = false;
		/*this.updateCharts = true;
		this.leadColored = null;*/
		if (value === 'ALL') value = '';
		this.records.setFilter('Dettaglio__c', [value]);
	}

	async getLeads(params){
		
		console.log(this.chosenFilter);
		params.defaultFilter = this.chosenFilter;
		console.log(params);
		let toRet = await proxyGetListView(params);
		console.log(toRet);
		this.origin.leadColored = null;
		this.origin.updateCharts = true;
		return toRet;
	}

	async mapLeadColors(results){

			if(this.updateCharts){
			this.params1 = this.params2 = this.params3 = null;
			this.showList = false;
			var leads = results.elementsCached;
			var result;
			if(this.leadColored === null) 
			this.leadColored = result = await mapColors({leads: leads});
			
			else
				result = this.leadColored;

			
			if (!this.mapLeadColor){
				this.mapLeadColor = new Map();
			}
			let leads1 = [], leads2 = [], leads3 = [];
			console.log(result);
			for(const lw of result){
				if(!this.mapLeadColor.has(lw.leadData.Id)){
					this.mapLeadColor.set(lw.leadData.Id, lw.colorCode);
				}
				
				if(lw.leadData.Status === 'Da Lavorare' || lw.leadData.Status === 'To be processed'){
					leads1.push (lw);
				}
				else if(lw.leadData.Status === 'Da Ricontattare' || lw.leadData.Status === 'Call again'){
					leads2.push (lw);
				}
				else if(lw.leadData.Status === 'Appuntamento' || lw.leadData.Status === 'Appointment'){
					leads3.push(lw);
				}
				
			}
			this.params1 = {
				setData : MobilityLib.processDataForLeadChart('Lead',leads1),
				Title : 'Lead Da Lavorare',
				SubTitle : 'Per i lead WEB, chiamali subito e cambia lo stato di lavorazione.'
			};
			this.params2 = {
				setData : MobilityLib.processDataForLeadChart('Lead',leads2),
				Title : 'Lead Da Ricontattare',
				SubTitle : 'Hai provato a richiamarli una volta ma non ti hanno risposto? Richiamali prima della scadenza'
			};
			this.params3 = {
				setData : MobilityLib.processDataForLeadChart('Lead',leads3),
				Title : 'Lead in Appuntamento',
				SubTitle : 'Hai un appuntamento: ricordati di controllare la data in agenda. E se va a buon fine, clicca su Converti!'
			}

			for(const l of results.elements){
				if(this.mapLeadColor.has(l.Id)){
					var tempDettaglio = {
						label: l.Dettaglio__c,
						color: this.mapLeadColor.get(l.Id)
					}
					l.Dettaglio__c = tempDettaglio;
					
				}
			}
			for(const l of results.elementsCached){
				if(this.mapLeadColor.has(l.Id)){
					var tempDettaglio = {
						label: l.Dettaglio__c || "",
						color: this.mapLeadColor.get(l.Id)
					}
					l.Dettaglio__c = tempDettaglio;
				}
			}
			
			this.showList = true;
			
			this.updateCharts = false;
		}
		this.hideSpinner();
	}

	originChange(e) {
		let value = e.target.value;
		this.originMap.get(value).selected = true;
		this.Origin[0].selected = false;
		
		if (value === 'ALL') value = '';
		this.records.setFilter('Landing_Page__c', [value]);
	}

	leadStatusChange(e) {
		let value = e.target.value;
		this.statusMap.get(value).selected = true;
		this.status[0].selected = false;
		
		if (value === 'ALL') value = '';
		this.records.setFilter('Status', [value]);
	}

	leadCustomOwner(e) {
		let value = e.target.value;
		let checked = e.target.checked;
		/*this.leadColored = null;
		this.updateCharts = true;*/
		if (checked) this.records.setFilter('Custom_Lead_Owner__c', ['!ISNULL()']);
		if (!checked) this.records.setFilter('Custom_Lead_Owner__c', []);
	}

	onChangeCallback = () => {
		/*this.updateCharts = true;
		this.leadColored = null;*/
		this.records.load();
	}

	get showCharts() {
		return this.params1 && this.params2 && this.params3;
	}

	get showPick(){
		return this.rerenderSelect && true;
	}
	
}