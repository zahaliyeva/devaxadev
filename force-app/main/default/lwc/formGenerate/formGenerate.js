import { LightningElement, api, track } from 'lwc';
import { LghtAbstract } from 'c/lghtAbstract';

import getForm from '@salesforce/apex/FormGenerateController.getForm';

export default class FormGenerate extends LghtAbstract {

	@api formName = '';
	@api recordId;
	@api sObjectName = 'Account';
	@api recordType;
	@api cols = 3;
	@api currentData;
	@api hideHeader = false;
	@api validateCallback;
	@api changeCallback;
	@api numberIdentifier;

	@api recordTypeId;
	@track mapping;

	formLoaded = false;

	componentView = 'FormGenerate';
	configs = [];
	@track data = {};
	requiredMap = null;

	@track disableMap = {};
	@api disableAll = false;


	setDisableAll(all){
		this.disableAll = all;
	}

	setDisableSingle(field, disable, clearValue){
		
		console.log("clear Value: ", clearValue);
		var required = false;
			
		this.configs.forEach((config)=>{
			if(config.Field__c === field){
				config.ReadOnly__c = disable;
				if(config.Required__c){
					required = true;
					if(!disable)
						this.requiredMap[field] = ( config.Value__c ? true:false);
					else if(disable)
						this.requiredMap[field] = true;
				}
			}	
			
		});
		
		this.disableMap[field] = disable;
		if(clearValue){
			console.log("Entrato!");
			
			this.data[field] = "";
			this.updateData({[field]: ""});
		}
		
		
		
	}

	

	

	/*renderedCallback(){ 
		let inputFields = this.template.querySelectorAll('.validate');
        inputFields.forEach(inputField => {
            
			if(inputField.disabled || inputField.value){
				inputField.reportValidity();
			}
			var fieldName = inputField.fieldName;
			if(inputField.value !== null && this.requiredMap[fieldName] === false && this.data[fieldName] === null){
				this.requiredMap[fieldName] = true;
				this.data[fieldName] = inputField.value;
			}
			
        });
		console.log(this.formLoaded)
	}*/

	get internalIdentifier(){
		if(this.numberIdentifier !== null)
			return this.numberIdentifier;
		return this.recordId;
	}

	connectedCallback() {
		super.connectedCallback();
		this.formLoaded = false;
		this.mapping = new Map([
			['Chiuso','Closed'],
			['Chiuso D\'Ufficio','Out of time'],
			['Cancellato','Cancelled']
	        ]
			);

		this.loadData();
	}

	connectHook(){
		if (this.hook) {
			this.hook(this, this.pageId);
		}
	}

	get isFormComplete(){
		console.log(this.requiredMap);

		var fieldsMap = new Map();

		let inputFields = this.template.querySelectorAll('.validate');

        inputFields.forEach(inputField => {
            
			fieldsMap.set(inputField.fieldName, inputField);
			
        });

		if(this.disableAll) return true;
		if(this.requiredMap == null) return false;
		for(var key in this.requiredMap){
			
			if(!this.requiredMap[key]){
				var field = fieldsMap.get(key);
				if(field && field.value && field.reportValidity()){
					this.updateData({[key] : field.value});
				}
				else
				return false;
		}
				
		}
		return true;
		/*
		var validForm = true;
		let inputFields = this.template.querySelectorAll('.validate');
        inputFields.forEach(inputField => {
            
			if(!inputField.readOnly && !inputField.reportValidity()){
				validForm = false;
			}
			
        });

		return validForm*/
	}

	loadData(){
		getForm({
			formName: this.formName,
			sObjectName: this.sObjectName,
			recordId: this.recordId,
			recordType: this.recordType
		}).then((response)=>{
			console.log(response);
			this.requiredMap = {};
			this.configs 		= response.configs;
			if(!this.recordTypeId)
			this.recordTypeId 	= response.recordTypeId;
			this.data 			= response.data || {};
			if(!this.currentData){
				this.currentData = this.data;
			}
			this.defaultData();
			
			this.updateData(this.currentData);
			this.startRequiredMap();
			if(this.changeCallback) this.changeCallback({[this.sObjectName]: this.data}, this);

			this.formLoaded = true;
			this.hideSpinner();
		})
	}

	get pageId(){
		return `${this.formName}_${this.sObjectName}`;
	}

	get sections(){
		const sections = {};

		const configsSort = this.configs.sort((configA, configB)=>{
			return (configA.Index__c < configB.Index__c) ? -1 : 1;
		});

		

		for(let key in configsSort){
			const config = configsSort[key];

			let section = sections[config.Section__c];
			if(!section) section = {Label__c: config.Section__c, Fields: []};

			
			if(this.disableAll){
				if(this.disableMap[config.Field__c] === false){
					config.ReadOnly__c = false;
				}
				else{
				config.ReadOnly__c = true;
			}
			
			}
			
			

			const field = {
				Label__c		: config.Label__c,
				Type__c			: config.Type__c,
				Field__c		: config.Field__c,
				ReadOnly__c		: config.ReadOnly__c,
				Required__c		: config.Required__c,
				Index__c		: config.Index__c,
				Visible__c		: config.Visible__c,
				Domain__c		: null,
			};

			
			
			//if(!this.disableMap[config.Field__c]){
			field.Value__c = this.data[config.Field__c];
			/*}
			else{
				field.Value__c = null;
			}
			/*if(config.Required__c && !config.ReadOnly__c){
				this.requiredMap[config.Field__c] = (field.Value__c != null);
			}*/

			if(config.Domain__c){
				field.Domain__c = new Array();
				var labels = config.Domain__c.split(';');
				if(config.Domain2__c){
					console.log('Domain 2: '+config.Domain2__c);
					labels = labels.concat(config.Domain2__c.split(';'));
				}
				labels.forEach(element => {
				let selection = {'value': '', 'label': ''};
			    selection.label = element;  								
				selection.value = typeof this.mapping.get(element) != 'undefined' ? this.mapping.get(element) : element;
				field.Domain__c.push(selection);
			});
			}

			section.Fields.push(field);

			sections[config.Section__c] = section;
		}

		const listSections = [];
		for(let key in sections){
			const section = sections[key];

			section.Fields = section.Fields.sort((elementA, elementB)=>{
				return (elementA.Index__c < elementB.Index__c) ? -1 : 1;
			})

			listSections.push(section);
		}

		console.log('listSections', listSections);
		return listSections;
	}

	get fieldClass(){
		const sizeCol = parseInt(12 / this.cols);

		return `form-field slds-size_${sizeCol}-of-12`
	}

	startRequiredMap(){
		this.configs.forEach((config)=>{
			if(config.Required__c && !config.ReadOnly__c){
				this.requiredMap[config.Field__c] = ( (config.Value__c != null && config.Value__c != '') ? true:false);
			}
		});
	}

	defaultData(){
		if(this.recordId) return;

		this.configs.forEach((config)=>{
			if(config.Default__c){
				config.Value__c = config.Default__c;
				this.data[config.Field__c] = config.Default__c;
			}
		});
	}

	updateData(data){
		for(let key in data){
			const value = data[key];

			this.configs.forEach((config)=>{
				if(config.Field__c === key){
					config.Value__c = value;
					if(config.Required__c && !config.ReadOnly__c){
						this.requiredMap[config.Field__c] = ( (value != null && value != '') ? true:false);
					}
				}	
				
			});


			this.data[key] = value;
		}
	}

	onChange = (e) => {
		console.log("event value: ", e);
		const name = e.target.fieldName || e.target.name;
		const value = e.target.value;
		//var valid = e.target.reportValidity();

			this.updateData({[name]: value});

		if(this.changeCallback) this.changeCallback({[this.sObjectName]: {...this.data, sobjectType: this.sObjectName}}, this);
		
	}

	onCheck(e){
		let isValid = this.template.querySelector('form').checkValidity();
		if(!isValid) this.template.querySelector('button').click();

		if(this.validateCallback) isValid = this.validateCallback({[this.sObjectName]: {...this.data, sobjectType: this.sObjectName}}, this);
		
		return isValid;
	}

	onSubmit(e){
		console.log('onSubmit');
		e.preventDefault();
	}

}