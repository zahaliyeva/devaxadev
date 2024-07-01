import {
    track,
    api
} from 'lwc';

import {
    MobilityAbstract
} from 'c/mobilityAbstract';

import {
    MobilitySectionCollection
} from 'c/mobilityLayoutModel';

import getLayout from '@salesforce/apex/MobilityCustomLayout.getLayout';
import save from '@salesforce/apex/MobilityCustomLayout.save';
import GetUrlFromRecordId from '@salesforce/apex/lghtIFrameForCustomURLCTRL.GetUrlFromRecordId';

export default class MobilityLayout extends MobilityAbstract {
    @track sections = {};
    @track title = '';

    @api hideTitle = false;
    @api canNotSaveData = false;
    @api typeLayout;
    @api layoutName;
    @api objectName;
    @api recordId;
    @api recordType;
    @api loadCallback;
    @api saveCallback;
    @api readyCallback;
    @api changeCallback;
    @api recordDefault = {};
    @api recordOverride = {};
    @api fieldsOverride = {};
    // id for pushnotification add new type iframe an URL
    @track UrlFromApex = '';
    @track notEmptyUrl = false;


    debug = false;

    componentView = 'mobilityLayout';

    saveResolve;
    saveReject;

    connectedCallback() {

        //for push notification iframe an url only for comm2customer object
        if(this.objectName == 'Communications_to_customer__c' || this.objectName == 'et4ae5__IndividualEmailResult__c'){
            GetUrlFromRecordId({
                RecordId : this.recordId,
            })
            .then(Url => {   
                this.UrlFromApex = Url;
                if(Url != null){
                    this.notEmptyUrl = true;
                }
            })
        }

        super.connectHook();

        if (this.readyCallback) this.readyCallback(this);

        this.loadData().catch((result) => {
            this.criticalMessage();
        }).finally(() => {
            this.hideSpinner();
        })
    }

    loadData() {
        console.log('objectName '+this.objectName);
        console.log('this.recordId '+this.recordId);
        console.log('this.recordType '+this.recordType);
        console.log('this.typeLayout '+this.typeLayout);
        console.log('this.layoutName '+this.layoutName);
        return getLayout({
            objectName: this.objectName,
            recordId: this.recordId,
            recordType: this.recordType,
            typeLayout: this.typeLayout,
            nameLayout: this.layoutName
        }).then((result) => {
            this.title = result.title;
            this.sections = new MobilitySectionCollection({
                collection: this.proxyData(result.sections),
                type: this.typeLayout,
                record: this.updateRecord(result.record),
                recordType: result.recordType,
                definition: result.definition
            });
            console.log(result);
            console.log(this.sections);
            console.log('allData: ', this.allData);
            if (this.fieldsOverride) this.changeFields(this.fieldsOverride);
            if (this.loadCallback) this.loadCallback(result);
        }).catch((err) => {
            console.log('err', this.proxyData(err));
        }).finally(() => {
            this.hideSpinner();
        })
    }

    get allData() {
        if (!this.sections) return [];
        if (!this.sections.collection) return [];

        return this.sections.getAll().sort((a, b) => {
            return a.index - b.index;
        });
    }

    get rootDom(){
        return this.template.querySelector('form');
    }

    updateRecord(record) {
        let result = {};

        for (let key in this.recordDefault) {
            let value = this.recordDefault[key];

            result[key] = value;
        }

        for (let key in record) {
            let value = record[key];

            if (value !== undefined && value !== null) result[key] = value;
        }

        for (let key in this.recordOverride) {
            let value = this.recordOverride[key];

            result[key] = value;
        }

        return result;
    }

    checkField(developerName){
        const regex = /([\w]+)__([0-9])+x/gm;

        return regex.exec(developerName);
    }

    preventEnter(event){
        if(event.keyCode == 13) {
            event.preventDefault();
            return false;
        }
    }
    get showIcon (){
        return this.objectName === 'Feedback__c'
    }
    changeData = (e) => {
        //if (!e.target && !e.currentTarget) return;

        let target = e.target || e.currentTarget;
        let name = target.name;
        let value = target.value;
        let type = target.type;
        let checked = target.checked;

        if(!name) return;
        if (type === 'checkbox') value = checked;

        let checkField = this.checkField(name);
        if(checkField){
            let fieldName = checkField[1];
            let fieldKey = checkField[2];
            let targetValue = this.sections.record[fieldName];

            this.sections.record[fieldName] = {...targetValue, [fieldKey]: value}
        }
        
        this.sections.record[name] = value;

        if(this.changeCallback) this.changeCallback(name, value, this.sections);
        
        this.update();
    }

    update = () => {
        this.sections = new MobilitySectionCollection(this.sections)
    }

    changeDataDatePicker = (e) => {
        this.changeData(e);
    }

    saveData() {
        this.template.querySelector('button').click();

        return new Promise((resolve, reject) => {
            this.saveResolve = resolve;
            this.saveReject = reject;
        })
    }

    checkData(){
        let isValid = this.template.querySelector('form').checkValidity();

        if(!isValid){
            this.template.querySelector('button').click();
        }

        return isValid;
    }

    reset(_update = true){
        this.sections.record = {};

        if(_update) this.update();
    }

    changeFields = (data, _update = true) => {
        for(let key in data){
            let valueField = data[key];

            if(valueField.value){
                this.sections.record[key] = valueField.value;
            }

            this.changeField(key, valueField, false);
        }

        if(_update) this.update();
    }

    changeField = (developerName, changeData, _update = true) => {
         this.sections.changeField(developerName, changeData);

         if(_update) this.update();
    }

    get requestData(){
        let requestData = this.updateRecord(this.sections.record);
        requestData.sobjectType = this.objectName;

        return requestData;
    }

    onSubmit = (e) => {
        e.preventDefault();

        if (this.saveCallback === null) return;
        if (this.canNotSaveData){
            console.log('canNotSaveData')
            this.saveCallback(this.requestData);
            return;
        }
        this.showSpinner();

        save({
            recordToSave: this.requestData
        }).then((result) => {
            if (!result.isSuccess) throw new Error(result.errorMessage);

            if (this.saveCallback) this.saveCallback(result);
            if (this.saveResolve) this.saveResolve(result);
        }).catch((err) => {
            console.log('err saveData', this.proxyData(err));
            this.alertMessage('Error', err.message.replace(": []", ""));
            this.hideSpinner();

            if (this.saveReject) this.saveReject(err);
        })
    }

}