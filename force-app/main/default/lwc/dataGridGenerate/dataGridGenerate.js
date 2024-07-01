import { LightningElement, api, track } from 'lwc';
import { LghtAbstract } from 'c/lghtAbstract';

import getDataGrid from '@salesforce/apex/DataGridGenerateController.getDataGrid';

export default class DataGridGenerate extends LghtAbstract {

	@api gridName = '';
	@api sObjectName = 'Account';
	@api
	set filters(_filters){
		this._filters = _filters
	}
	get filters(){
		return this._filters;
	}

	@api typeColumn;
	@api fieldRules;
	@api setData;

	@api columnsDefinitionCallback;
	@api hideCheckboxColumn;
	@api rowActionCallback;
	@api keyField = 'id';
	@api selectedRows = [];
	@api maxRowSelection = 99999;
	@api hidden = false;
	@api page = 0;
	@api perPage = 9999;
	@api orderField = null;
	@api orderName = null;
	
	@api rowSelectionCallback;
	@api loadCallback;

	@track limitData = 100;
	@track data = {};
	@track _filters;
	
	configs = [];
	componentView = 'DataGridGenerate';

	connectedCallback() {
		super.connectedCallback();

		this.loadData();
	}

	applyFilters(_filters){
		this._filters = _filters;
		return this.loadData();
	}

	addFilters(_filters){
		this._filters = {
			...this._filters,
			...filters
		};
		return this.loadData();
	}

	async loadData(){
		console.log('loadData');
		
		this.showSpinner();

		const noDataRequired = (!!this.setData);
		
		const request = {
			dataGridName: this.gridName,
			sObjectName: this.sObjectName,
			page: this.page,
			perPage: this.perPage,
			filters: this._filters,
			orderField: this.orderField,
			orderName: this.orderName,
			noDataRequired
		};

		console.log('request', this.proxyData(request));
		const response = await getDataGrid(request);

		console.log(response);
		
		this.configs 		= response.configs;
		
		if(noDataRequired){
			this.data 			= this.processData(this.setData);
		}else{
			this.data 			= this.processData(response.tableData.elements || []);
		}
		
		if(this.loadCallback) this.loadCallback(this);
		console.log('data', this.proxyData(this.data));

		this.hideSpinner();
	}

	get columns(){
		const configsSort = this.configs.sort((configA, configB)=>{
			return (configA.Index__c < configB.Index__c) ? -1 : 1;
		})

		const columns = [];
		configsSort.forEach((config)=>{
			
			const column = {
				label 			: config.Label__c,
				fieldName 		: config.Field__c,
				type 			: config.Type__c
			};

			if(this.typeColumn) this.typeColumn(column.fieldName, column);

			columns.push(column);
		});

		if(this.columnsDefinitionCallback) this.columnsDefinitionCallback(columns, this);

		console.log('columns', columns);
		return columns;
	}

	processData(data){
		if(!data) return [];

		data.forEach((element)=>{
			for(let key in element){
				const value = element[key];
				//element[key] = value;

				if(this.fieldRules) this.fieldRules(key, value, element);
			}
		});

		return data;
	}

	applyData = (data) => {
		this.data = data;
	}

}