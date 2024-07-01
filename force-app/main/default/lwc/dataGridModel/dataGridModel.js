import { 
	Model,
	ModelCollection
} from 'c/abstractModel';

import {
	MobilityPaginationModel
} from 'c/mobilityPaginationModel';


export class DataGridCellModel extends Model {

	static get TYPE() {
		return {
			URL: 'URL',
			ACTION: 'ACTION',
			BADGE: 'BADGE',
			DATE: 'DATE',
			DATETIME: 'DATETIME',
			CHECKBOX: 'CHECKBOX',
			DROPDOWN: 'DROPDOWN',
			REDIRECT: 'REDIRECT',
			COLOREDLABEL: 'COLOREDLABEL' //aggiunto tipo colore
		}
	}

	_model() {
		return {
			type: '',
			valueUrl: null,
			icon: '',
			value: null,
			valueBadge: null,
			colors: null,
			element: {},
			column: '',
			parent: {},
			encode: null,
			fixedFirst: false,
			fixedLast: false,
			valueLabel: null,
			onClick: null
		}
	}

	get isTypeBadge() {
		return this.type === DataGridCellModel.TYPE.BADGE;
	}

	get isDropdown() {
		return this.type === DataGridCellModel.TYPE.DROPDOWN;
	}

	get isTypeDate() {
		return this.type === DataGridCellModel.TYPE.DATE;
	}

	get isTypeDateTime() {
		return this.type === DataGridCellModel.TYPE.DATETIME;
	}

	get isTypeColoredLabel(){ //conferma Tipo Colore
		var toRet = this.type === DataGridCellModel.TYPE.COLOREDLABEL;
		
		return toRet;
	}

	get isTypeSelect() {
		return this.fixedFirst && this.type === DataGridCellModel.TYPE.CHECKBOX;
	}

	get isTypeCheckbox() {
		return !this.fixedFirst && this.type === DataGridCellModel.TYPE.CHECKBOX;
	}

	get isTypeSimple() {
		return !this.isTypeUrl;
	}

	get isTypeUrl() {
		return this.type === DataGridCellModel.TYPE.URL;
	}

	get isTypeRedirect(){
		return this.type === DataGridCellModel.TYPE.REDIRECT;
	}

	get valueUrlLink() {
		if (this.isTypeUrl) {
			return this.valueUrl(this.value);
		}
	}

	get valueBadgeLabel() {
		if (this.isTypeBadge) {
			return this.valueBadge(this.value);
		}
	}

	get valueDate() {
		if (this.isTypeDate) {
			if (!this.value) return '';
			let dateObject = this.getDateTimeFormated(this.value);			
					return `${dateObject.days}/${dateObject.months}/${dateObject.years}`;
		}
	}

	
	get valueDateTime() {
		if (this.isTypeDateTime) {
			if (!this.value) return '';
			let dateObject = this.getDateTimeFormated(this.value);
					return `${dateObject.days}/${dateObject.months}/${dateObject.years} ${dateObject.hours}:${dateObject.minutes}:${dateObject.seconds}`;
		}
	}

	get valueRedirect(){
		if(this.isTypeRedirect){
			return this.valueLabel(this.value);
		}
	}

	get badgeStyle() {
		if (!this.colors) return 'background: #fff';
		return 'background: ' + this.colors(this.value);
	}

	get labelStyle(){ //Stile Label
		if(this.isTypeColoredLabel){
			if(!this.value) return 'background: #fff';
			if (!this.value.color) return 'background: #fff';
			return 'background: ' + this.value.color;
		}
		return "";
	}
	get ColoredLabelValue(){ //Valore da usare
		if(!this.value) return "";
		return this.value.label || " ";
	}
	

	get selected() {
		return (this.parent.selectData[this.element.Id]);
	}

	get checked(){
		return this.value
	}

	get class() {
		let classes = [`col-${this.column}`];

		if (this.fixedFirst) classes.push('col-first-fixed');
		if (this.fixedLast) classes.push('col-last-fixed');

		return classes.join(' ');
	}

	get valueString() {
		if (this.isFunction(this.encode)) {
			return this.encode(this.value, this.element);
		}

		return this.value;
	}
	onclick = () => {
		
		var ndg = "";
		if(this.element.Account_NDG__c){
			ndg = this.element.Account_NDG__c;
		}
		else if(this.element.Account && this.element.Account.NDG__c){
			
			ndg = this.element.Account.NDG__c;
		}
		
		console.log("onClick: ", ndg);
		this.onClick(ndg);
	}

}

export class DataGridActionCollection extends ModelCollection {

	_model() {
		return {
			...super._model(),
			parent: {},
			fixedFirst: false,
			fixedLast: false,
			type: '',
			value: null
		}
	}

	_childType() {
		return DataGridActionModel;
	}

	get label(){
		return this.parent.actionLabel;
	}

	get icon(){
		return this.parent.actionIcon;
	}

	// get type() {
	// 	return DataGridCellModel.TYPE.ACTION;
	// }

	get isTypeAction() {
		return this.type === DataGridCellModel.TYPE.ACTION;
	}

	get isTypeDropdown() {
		return this.type === DataGridCellModel.TYPE.DROPDOWN;
	}

	get data() {
		return this.getAll();
	}

	get dropdownData(){
		let result = [];

		this.data.forEach((element)=>{
			result.push({
				value: element.devName,
				label: element.label
			})
		})

		return result;
	}

	get class() {
		let classes = [`col-${this.column}`];

		if (this.fixedFirst) classes.push('col-first-fixed');
		if (this.fixedLast) classes.push('col-last-fixed');

		return classes.join(' ');
	}

	dropdownCallback = (e) => {
		if(this.parent.actionDropDownCallback) this.parent.actionDropDownCallback(e, this.value);
	}

}

export class DataGridActionModel extends DataGridCellModel {
	_model() {
		return {
			...super._model(),
			label: '',
			icon: '',
			disabled: null,
			callback: null,
			condition: null,
			devName: null
		}
	}

	get isTypeAction() {
		return this.type === DataGridCellModel.TYPE.ACTION;
	}

	get isDisabled() {
		if (!this.disabled) return false;

		return this.disabled(this.value);
	}

	get isVisible(){
		if(!this.condition) return true;

		return this.condition(this.value);
	}

	get class() {
		let classes = ['action'];

		if (this.isDisabled) {
			classes.push('disabled');
		}

		return classes.join(' ');
	}

	actionClick = () => {
		if (this.callback && !this.isDisabled) this.callback(this.value);
	}
}

export class DataGridHeader extends Model {

	_model() {
		return {
			viewSelectRow: false,
			fixedFirst: false,
			fixedLast: false,
			parent: {},
			labels: {},
			columns: [],
			actions: []
		}
	}

	get cellSelect() {
		if (this.viewSelectRow) {
			return new DataGridHeaderCell({
				type: DataGridHeaderCell.TYPE.SELECT,
				parent: this.parent,
				viewSelectRow: this.viewSelectRow
			})
		}

		return null;
	}

	get cellSimples() {
		let result = [];

		this.columns.forEach((element, index) => {
			let label = this.labels[element] || element;

			let model = new DataGridHeaderCell({
				index,
				label,
				key: element,
				parent: this.parent
			})

			result.push(model);
		})

		return result;
	}

	get cellAction() {
		if (this.actions && this.actions.length > 0) {
			return new DataGridHeaderCell({
				index: this.columns.length,
				label: '',
				key: 'actions',
				header: true,
				parent: this.parent
			});
		}

		return null;
	}

	header() {
		let result = [];

		let cellSelect = this.cellSelect;
		if (cellSelect) result.push(cellSelect);

		let cellSimples = this.cellSimples;
		if (cellSimples && cellSimples.length > 0) result = result.concat(cellSimples);

		let cellAction = this.cellAction;
		if (cellAction) result.push(cellAction);

		if (this.fixedFirst) {
			let firstCell = result[0];

			firstCell.fixedFirst = true;
		}

		if (this.fixedLast) {
			let lastCell = result[result.length - 1];

			lastCell.fixedLast = true;

		}

		return result;
	}

}

export class DataGridHeaderCell extends Model {

	static get TYPE() {
		return {
			SELECT: 'SELECT',
			SIMPLE: 'SIMPLE',
			ACTION: 'ACTION'
		}
	}

	_model() {
		return {
			viewSelectRow: false,
			index: '',
			label: '',
			key: '',
			type: '',
			parent: null,
			header: false,
			fixedFirst: false,
			fixedLast: false
		}
	}

	get isSelect() {
		return (this.type === DataGridHeaderCell.TYPE.SELECT);
	}

	get isSimple() {
		return (this.type === DataGridHeaderCell.TYPE.SIMPLE);
	}

	get isAction() {
		return (this.type === DataGridHeaderCell.TYPE.ACTION);
	}

	get class() {
		let classes = [`table-header-${this.key}`];

		if (this.fixedFirst) classes.push('col-first-fixed');
		if (this.fixedLast) classes.push('col-last-fixed');

		return classes.join(' ');
	}

	get icon() {
		return (this.key !== this.parent.orderField) ? 'double-arrow' : (this.parent.orderName === 'DESC') ? 'double-arrow-des' : 'double-arrow-asc'
	}

}

export class DataGridRow extends Model {
	_model() {
		return {
			row: [],
			element: null,
			parent: null
		}
	}

	get class() {
		let classes = [];

		if (this.element && this.parent && this.parent.selectData[this.element.Id]) {
			classes.push('row-select');
		}

		return classes.join(' ');
	}
}

export class DataGridRecords extends Model {

	_model() {
		return {
			parent: {},
			elements: [],
			viewSelectRow: false,
			columns: [],
			encodes: {},
			actions: []
		}
	}

	cellSelect(element) {
		if (!this.viewSelectRow) return null;

		return new DataGridCellModel({
			type: DataGridCellModel.TYPE.CHECKBOX,
			parent: this.parent,
			element,
		})
	}

	cellSimples(element) {
		let rusult = [];

		this.columns.forEach((column, columnId) => {
			let value = element[column];
			let data = {};

			if (this.encodes[column] && !this.isFunction(this.encodes[column]) && this.encodes[column].type) {
				data = this.encodes[column];
			}

			let record = new DataGridCellModel({
				value,
				element,
				column,
				parent: this.parent,
				encode: this.encodes[column],
				...data
			});

			rusult.push(record);
		})


		return rusult;
	}

	cellAction(element) {
		if (this.actions && this.actions.length > 0) {

			let actions = [];
			this.actions.forEach((action, actionId) => {

				action.value = element;
				action.type = DataGridCellModel.TYPE.ACTION;

				actions.push(action);
			})

			let result = new DataGridActionCollection({
				collection: actions,
				parent: this.parent,
				type: this.parent.actionType,
				value: element
			});

			return result;
		}

		return null;
	}

	records() {
		let result = [];

		this.elements.forEach((element, elementId) => {
			let row = [];

			let cellSelect = this.cellSelect(element);
			if (cellSelect) row.push(cellSelect);

			let cellSimples = this.cellSimples(element);
			if (cellSimples && cellSimples.length > 0) row = row.concat(cellSimples);

			let cellAction = this.cellAction(element);
			if (cellAction) row.push(cellAction);

			if (this.parent.fixedFirst) {
				let firstCell = row[0];

				firstCell.fixedFirst = true;
			}

			if (this.parent.fixedLast) {
				let lastCell = row[row.length - 1];

				lastCell.fixedLast = true;
			}

			result.push(new DataGridRow({
				row,
				parent: this.parent,
				element
			}))
		})



		return result;
	}
}

export class DataGridModel extends Model {

	_model() {
		return {
			cachedMode: false,
			maxRecords: -1,
			page: 0,
			perPage: 6,
			perPages: [
				10,
				20,
				50,
				100
			],
			elements: [],
			columns: [],
			labels: {},
			encodes: {},
			actions: [],
			Message: '',

			actionType: DataGridCellModel.TYPE.ACTION,
			actionIcon: '',
			actionLabel: '',
			actionDropDownCallback: null,

			viewSelectRow: false,
			selectData: {},
			pagination: new MobilityPaginationModel(),

			filters: {},
			orderFieldBackend: '',
			orderField: '',
			orderName: '',
			search: '',
			bind: null,
			loadCallback: null,
			errorCallback: null,
			finallyCallback: null,
			preLoadCallback: null,
			orderCallback: null,
			fixedFirst: false,
			fixedLast: false,
			showSearch: true,
			showFilter: true,
			simpleMode: false,
			singleSelect: false,
			selectField: null,
			maxHeight: -1,

			filtersVariables: [],
			filtersVariablesCallback: null,
			filtersVariablesRemoveCallback: null,
			filtersVariablesRemoveAllCallback: null,

			additionalData: {},
			firstLoad: false
		}
	}

	get listSelected() {
		let result = [];

		for (let key in this.selectData) {
			let value = this.selectData[key];
			if (value) result.push(key)
		}

		return result;
	}

	get selectedLength() {
		return this.listSelected.length;
	}

	get hasSelected() {
		return (this.selectedLength > 0);
	}

	get selectedAll() {
		let hasAll = true;
		let listSelected = this.listSelected;

		this.elements.forEach((element) => {
			if (!listSelected.includes(element.Id)) {
				hasAll = false;
			}
		})

		return hasAll;
	}

	get isVisibleSearch() {
		if (this.simpleMode) return false;

		return this.showSearch;
	}

	get isVisibleFilter() {
		if (this.simpleMode) return false;

		return this.showFilter;
	}

	get containerStyle() {
		let styles = ['min-height: 250px'];

		if (this.maxHeight > 0) {
			styles.push(`max-height: ${this.maxHeight}px`);
		}

		return styles.join('; ');
	}

	get hasLimitWarning(){
		return this.cachedMode && this.pagination.total > this.pagination.maxRecords;
	}

	load(chached = false) {
		this.firstLoad = true;
		if (!this.bind.load) return Promise.reject();

		if(this.pagination && chached){
			console.log('cached-mode');
			this.pagination.refresh(this.page);
			return this.loadedCached({...this.pagination});
		}

		let request = {
			page: this.page,
			perPage: this.perPage
		}

		if (!this.simpleMode) {
			request.orderField = this.orderFieldBackend;
			request.orderName = this.orderName;
			request.filters = this.filters;
			request.search = this.search;
		}

		if (this.preLoadCallback) this.preLoadCallback(this);
		return this.bind.load(request).then((result) => {
			console.log('+++ result', result);
			if(result.Message){
				console.log('Non autorizzato');
				this.Message = result.Message;
			}
			this.additionalData = result.additionalData || {};
			this._setData(result);
			
			this.cleanSelect(false);
			this.updateSelect(result.elements);

			this.pagination = new MobilityPaginationModel(result);

			
			this.update();

			if (this.loadCallback) this.loadCallback(this, result);

		}).catch((err) => {
			if (this.errorCallback) this.errorCallback(this, err);
		})
	}

	loadedCached(result){
		console.log('loadedCached', result);
		if (this.preLoadCallback) this.preLoadCallback(this);
		
		this._setData(result);
		this.cleanSelect(false);
		this.updateSelect(result.elements)
		this.pagination = new MobilityPaginationModel(result);
		
		this.update();

		if (this.loadCallback) this.loadCallback(this, result);
	}

	updateAdditionalData(additionalData){
		this._setData({additionalData})
		this.update();
	}

	updateSelect(data) {
		let dataSelect = [...data];
		
		for (let key in dataSelect) {
			let value = dataSelect[key];

			if (this.selectField && value[this.selectField]) {
				this.selectData[value.Id] = true;
			}
		}
	}

	changeSelect(key, value) {
		if (this.singleSelect) {
			this.selectData = {
				[key]: value
			};
		} else {
			this.selectData[key] = value;
		}
		this.update();
	}

	selectAll() {
		let selectAll = this.selectedAll;
		this.elements.forEach((element) => {
			this.selectData[element.Id] = !selectAll;
		})

		this.update();
	}

	cleanSelect(_update = true) {
		this.selectData = {};
		if(_update) this.update();
	}

	update() {
		if (this.bind) {
			this.bind.origin[this.bind.target] = new DataGridModel(this);
		}
	}

	onOrder(field){
		if(this.orderCallback){
			let fieldCallback = this.orderCallback(field);

			if(fieldCallback) return fieldCallback;
		}

		return field;
	}

	onAsc(field) {
		this.orderFieldBackend = this.onOrder(field);
		this.orderField = field
		this.orderName = 'ASC';

		this.load();
	}

	onDesc(field) {
		this.orderFieldBackend = this.onOrder(field);
		this.orderField = field
		this.orderName = 'DESC';

		this.load();
	}

	onChangePage(page) {
		this.page = page;
		this.load(this.cachedMode);
	}

	onChangePerPage(page) {
		this.perPage = page;
		this.load();
	}

	onFilter(filters) {
		this.filters = filters;
		this.load();
	}

	getIndexFiltersVariables(devName) {
		let result = null;
		this.filtersVariables.forEach((element, index) => {
			if (element.DeveloperName === devName) {
				result = index;
			}
		});

		return result;
	}

	removeAllFiltersVariables(load = true) {
		this.filtersVariables.forEach((element) => {
			this.removeFilterVariable(element.DeveloperName, false);
		});

		this.filtersVariables = [];
		if (this.filtersVariablesRemoveCallback) this.filtersVariablesRemoveCallback(this);
		
		if(load) this.load();
	}

	removeFilterVariable(devName, load = true) {
		let results = this.filtersVariables.filter((element)=>{
			if (element.DeveloperName === devName) {
				delete this.filters[devName];
				return false;
			}
			return true;
		});

		this.filtersVariables = results;	

		if (this.filtersVariablesRemoveCallback) this.filtersVariablesRemoveCallback(this);

		if (load && this.firstLoad) this.load();
	}

	setAllFilterVariable(listfilters) {
		this.removeAllFiltersVariables(false);
		
		listfilters.forEach((result) => {
			this.setFilterVariable(result, false)
		});

		this.load();
	}

	setFilterVariable(filterObject, load = true) {
		this.removeFilterVariable(filterObject.field, load);

		this.filtersVariables.push({
			label: filterObject.label,
			DeveloperName: filterObject.field,
			filters: filterObject.values,
			filtersString: filterObject.labelValues.join(',')
		})

		this.setFilter(filterObject.field, filterObject.values, load);

		if (this.filtersVariablesCallback) this.filtersVariablesCallback(this);
	}

	setFilter(field, values, load = true) {
		let cleanValues = [];

		for (let i in values) {
			if (values) {
				let value = values[i];

				if (value && value.trim() !== '') {
					cleanValues.push(value.trim())
				}
			}
		}

		if (cleanValues.length > 0) {
			this.filters[field] = cleanValues;
		} else {
			delete this.filters[field];
		}

		this.page = 0;
		if (load && this.firstLoad) this.load();
	}

	setFilterDirect(field, values, load = true){
		if (values.length > 0) {
			this.filters[field] = values;
		} else {
			delete this.filters[field];
		}

		this.page = 0;
		if (load && this.firstLoad) this.load();
	}

	setSearch(keyword) {
		this.search = keyword.trim();
		this.page = 0;
		this.load();
	}

	get header() {
		let result = [];

		let headerData = new DataGridHeader({
			parent: this,
			viewSelectRow: this.viewSelectRow,
			labels: this.labels,
			columns: this.columns,
			actions: this.actions,
			fixedFirst: this.fixedFirst,
			fixedLast: this.fixedLast,
		})

		return headerData.header();
	}

	get data() {
		let result = [];

		let records = new DataGridRecords({
			parent: this,
			elements: this.elements,
			viewSelectRow: this.viewSelectRow,
			columns: this.columns,
			encodes: this.encodes,
			actions: this.actions
		});

		return records.records();
	}
}