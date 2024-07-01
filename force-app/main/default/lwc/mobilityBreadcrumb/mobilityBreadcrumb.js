import {
	api,
	track
} from 'lwc';

import {
	MobilityAbstract
} from 'c/mobilityAbstract';

import {
	Model,
	ModelCollection
} from 'c/mobilityAbstractModel';

class BreadcrumbCollection extends ModelCollection {

	_model() {
		return {
			...super._model(),
			start: null,
			current: null,
			map: []
		}
	}

	get data() {
		if (!this.start) return [];
		if (!this.current) return [];

		let result = [];
		let current = this.getByName(this.current.developerName);

		if (!current) return [];
		result.push(current)

		let search = (name) => {
			let parent = this.getParent(name);

			if (parent) {
				result.push(parent)

				search(parent.developerName);
			}

		}

		search(current.name);

		return result.reverse();

	}
	
	_childType() {
		return BreadcrumbModel;
	}

	setStart(name) {
		this.start = this.getByName(name.toLowerCase());
	}

	setCurrent(name, currentIsClickable = false) {
		this.current = this.getByName(name.toLowerCase());

		this.getAll().forEach((element) => {
			element.active = (!currentIsClickable && element.developerName === name.toLowerCase());
		})
	}

	getParent(name) {
		let current = this.getByName(name);

		if (current && current.parent && current.parent !== name.toLowerCase()) {
			return this.getByName(current.parent);
		}
	}

	getChilds(name) {
		return this.getAll().filter((element) => {
			return element.parent === name.toLowerCase();
		})
	}

	getByName(name) {
		let result = this.getAll().filter((element) => {
			return element.developerName === name.toLowerCase();
		})

		if (result.length > 0) {
			return result[0];
		}

		return null;
	}

	redirectParams(data){
		for(let name in data){
			let value = data[name];

			let current = this.getByName(name);
			current.params = value;
		}
	}

}

class BreadcrumbModel extends Model {

	_model() {
		return {
			name: '',
			label: '',
			action: '',
			parent: null,
			active: false,
			params: {}
		}
	}

	get developerName() {
		return this.name.toLowerCase();
	}

	get class() {
		let classes = ['breadcrumb-item'];

		if (this.active) {
			classes.push('active');
		}

		return classes.join(' ');
	}

	get ariaCurrent() {
		return (this.active) ? 'page' : '';
	}

}

export default class MobilityBreadcrumb extends MobilityAbstract {
	componentView = 'MobilityBreadcrumb';

	@track breadcrumb = new BreadcrumbCollection();
	
	@api current;
	@api redirectParams;
	@api fromAgency;

	@api currentIsClickable = false;
	@api sameComponentFaultPreventCallback;
	@api oldDashboardId;

	breadcrumbLabels = [];

	connectedCallback() {
		super.connectHook();

		this.breadcrumbLabels = (this.params.breadcrumbLabels) ? this.params.breadcrumbLabels.split(',') : [];

		this.breadcrumb.add({
			name: 'homepage',
			label: this.breadcrumbLabels[0] || 'Homepage',
			action: 'homepageCallback'
		})

		this.breadcrumb.add({
			name: 'customer',
			label: this.breadcrumbLabels[1] || 'Scheda Cliente',
			action: 'customerCallback',
			parent: 'homepage'
		})

		/**
		 * CAMPAIGN CUSTOMER
		 */
		this.breadcrumb.add({
			name: 'mobilityCustomerCampaignListView',
			label: 'Lista Campagne',
			parent: 'customer'
		})

		this.breadcrumb.add({
			name: 'MobilityCustomerProcessing',
			label: 'Lavorazione',
			parent: 'mobilityCustomerCampaignListView'
		})

		/**
		 * CAMPAIGN
		 */
		this.breadcrumb.add({
			name: 'mobilityCampaignListView',
			label: 'Lista Campagne',
			parent: 'mobilityPushHomepage'
		})

		this.breadcrumb.add({
			name: 'mobilityCampaignAgencyListView',
			label: 'Lista Campagne',
			parent: 'mobilityPushHomePage'
		})

		this.breadcrumb.add({
			name: 'mobilityCampaignDetail',
			label: 'Dettaglio Campagna',
			parent: this.fromAgency === true || this.fromAgency === 'true'? 'mobilityCampaignAgencyListView' : 'mobilityCampaignListView'
		})


		this.breadcrumb.add({
			name: 'mobilityCampaignNew',
			label: 'Nuova Campagna',
			parent: 'mobilityCampaignListView'
		})

		this.breadcrumb.add({
			name: 'mobilityCampaignEdit',
			label: 'Modifica Campagna',
			parent: 'mobilityCampaignListView'
		})

		this.breadcrumb.add({
			name: 'mobilityCampaignProcessing',
			label: 'Lavorazione',
			parent: 'mobilityCampaignDetail'
		})

		this.breadcrumb.add({
			name: 'mobilityCampaignEnrichment',
			label: 'Data Enrichment',
			parent: 'mobilityCampaignProcessing'
		})

		/**
		 * LEAD
		 */
		this.breadcrumb.add({
			name: 'mobilityLeadListView',
			label: 'Lista Lead',
			parent: 'homepage'
		})

		this.breadcrumb.add({
			name: 'mobilityLeadDetail',
			label: 'Dettaglio Lead',
			parent: 'mobilityLeadListView'
		})

		this.breadcrumb.add({
			name: 'mobilityLeadNew',
			label: 'Nuova Lead',
			parent: 'mobilityLeadListView'
		})

		this.breadcrumb.add({
			name: 'mobilityLeadEdit',
			label: 'Modifica Lead',
			parent: 'mobilityLeadListView'
		})

		this.breadcrumb.add({
			name: 'mobilityLeadEmail',
			label: 'Invia email al Lead',
			parent: 'mobilityLeadDetail'
		})

		this.breadcrumb.add({
			name: 'mobilityPushHomepage',
			label: 'Campagne',
			parent: 'homepage'
		})

		this.breadcrumb.add({
			name: 'mobilityEcollabCruscotto',
			label: 'Cruscotto Clienti',
			parent: 'homepage'
		})

		this.breadcrumb.setStart('homepage');
		this.breadcrumb.setCurrent(this.current, this.currentIsClickable);
		this.breadcrumb.redirectParams(this.redirectParams);
	}

	onClick(e) {
		let target = e.currentTarget.dataset.name;

		let breadcrumbTarget = this.breadcrumb.getByName(target);

		let clickable = breadcrumbTarget ?  this.currentIsClickable ? true : breadcrumbTarget !== this.breadcrumb.current : false
		
		if(clickable){
			let target = breadcrumbTarget._getModel();	
			target.params = JSON.parse(JSON.stringify(target.params));

			
			this.navigateTo(target);
			if(breadcrumbTarget === this.breadcrumb.current && this.sameComponentFaultPreventCallback){
					this.sameComponentFaultPreventCallback(this.oldDashboardId);
			}
		}

	}
}