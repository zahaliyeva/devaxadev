/* eslint-disable @lwc/lwc/no-async-operation */
import {
	track,
	api
} from 'lwc';

import {
	DataGridModel
} from 'c/dataGridModel';

import {
	MobilityAbstract
} from 'c/mobilityAbstract';

export default class SObjectDataGrid extends MobilityAbstract {

	@track _pagerData = new DataGridModel();
	@track toggleIcon = 'double-arrow';

	@api ascCallback;
	@api descCallback;
	@api toggleCallback
	@api updateTime;
	@api backgroudColor = '#fff';

	@track noData = false;
	@track search = '';

	@api showDropdown = false;
	@api valuesDropdown = [];

	@api hideSelectAll = false;
	@api selectAllOverride;

	@api hideTooltip = false;

	static filtroRicercaStatic = '';

	get filtroRicerca(){
		return SObjectDataGrid.filtroRicercaStatic;
	}

	set filtroRicerca(value){
		SObjectDataGrid.filtroRicercaStatic = value;
	}

	searchHandler = null;
	selectAll = true;

	@api
	get tabledata() {
		return this._pagerData;
	}
	set tabledata(value) {
		this._pagerData = new DataGridModel(value);
		this.showNoData(this._pagerData.elements.length === 0);
	}

	get tableStyle() {
		return `background-color: ${this.backgroudColor};`;
	}

	get showFilter() {
		return this._pagerData.filtersVariables.length > 0;
	}

	onRemoveFilter(e) {
		let devName = e.currentTarget.dataset.name;
		this._pagerData.removeFilterVariable(devName);
	}

	proxyData(proxyObj) {
		return proxyObj; //JSON.parse(JSON.stringify(proxyObj));
	}

	connectedCallback() {
		super.connectedCallback();
	}

	changePage = (page) => {
		this._pagerData.onChangePage(page);
	}

	onUpdatePage = (e) => {
		this._pagerData.load();
	}

	isFunction(functionToCheck) {
		return functionToCheck && {}.toString.call(functionToCheck) === '[object Function]';
	}

	changeSearch(e) {
		let value = e.target.value;
		SObjectDataGrid.filtroRicercaStatic = value;
		
		console.log('filtroRicerca ', value);
		clearTimeout(this.searchHandler);
		// eslint-disable-next-line @lwc/lwc/no-async-operation
		this.searchHandler = setTimeout(() => {
			this._pagerData.setSearch(value)
		}, 600)
	}

	submitForm(e) {
		e.preventDefault();
	}

	_onToggle = (e) => {
		if (!this._pagerData.isVisibleFilter) return;

		let newValue = e.currentTarget.dataset.field;

		if (newValue !== this._pagerData.orderField) {
			this._pagerData.onAsc(newValue);
			//this.toggleIcon = 'double-arrow-des';

		} else if (newValue === this._pagerData.orderField) {

			if (this._pagerData.orderName === 'ASC') {
				this._pagerData.onDesc(newValue);
				//this.toggleIcon = 'double-arrow-des';

			} else if (this._pagerData.orderName === 'DESC') {
				this._pagerData.onAsc(newValue);
				//this.toggleIcon = 'double-arrow-asc';
			}
		}
	}

	showNoData(visible) {
		this.noData = visible;
	}

	_onChangeSelect = (e) => {
		let key = e.currentTarget.dataset.recordId;
		let value = e.currentTarget.checked;

		this._pagerData.changeSelect(key, value);
	}

	_onSelectAll = (e) => {
		if(this.selectAllOverride) this.selectAllOverride();
		else this._pagerData.selectAll();
	}

	_onCleanSelect = (e) => {
		this._pagerData.cleanSelect();
	}

	_onAsc = (e) => {
		this._pagerData.onAsc(e.currentTarget.dataset.field);
		if (this.ascCallback && this.isFunction(this.ascCallback)) this.ascCallback(e.currentTarget.dataset.field);
	}

	_onDesc = (e) => {
		this._pagerData.onDesc(e.currentTarget.dataset.field);
		if (this.descCallback && this.isFunction(this.descCallback)) this.descCallback(e.currentTarget.dataset.field);
	}

	@track showTooltip = false;

	toggleTooltip() {
		this.showTooltip = !this.showTooltip;
	}

	toggleOutTooltip() {
		setTimeout(() => {
			this.showTooltip = false;
		}, 3000);
	}

	get tooltipClass() {
		let classes = ['dropdown-menu'];
		classes.push('tooltip-menu');
		if (this.showTooltip) classes.push('show');

		return classes.join(' ');
	}

	changeNumberView = (e) => {
		let target = e.currentTarget;

		this._pagerData.onChangePerPage(target.dataset.value);

		/*if (target.className === 'active') {
			target.className = 'text-primary bg-white';
		} else {
			target.className = 'active text-white bg-primary';
		}*/
	}
}