/* eslint-disable guard-for-in */
/* eslint-disable default-case */
import {
    ModelCollection,
    Model
} from 'c/mobilityAbstractModel';

import {MobilityLib} from 'c/mobilityLib'
export class MobilityFieldCollection extends ModelCollection {

    constructor(data) {
        super(data);
    }

    _model() {
        return {
            ...super._model(),
            type: ''
        }
    }
    _childType() {
        return MobilityFieldModel;
    }

    get data() {
        let data = this.getAll().sort((a, b) => {
            return a.index - b.index;
        });

        let listProcced = [];

        data.forEach((field, fieldId) => {

            if(field.isFilter && field.isDate){
                //TODO aggiungere label
                let nameFrom = `${field.name} (Da)`;
                let nameTo = `${field.name} (A)`;

                let fieldFrom = new MobilityFieldModel({
                    ...field,
                    developerName: `${field.developerName}__1x`,
                    name: nameFrom
                });

                let fieldTo = new MobilityFieldModel({
                    ...field,
                    developerName: `${field.developerName}__2x`,
                    name: nameTo
                });

                listProcced.push(fieldFrom);
                listProcced.push(fieldTo);
            }else{
                listProcced.push(field);
            }
        });

        return listProcced;
    }

    updateType(type, record) {
        return this.getAll().forEach((field) => {
            field.isType = type;
            field.record = record;
            if (field.developerName.includes('.') && record) {
                let splitDeveloperName = field.developerName.split('.');
                if (splitDeveloperName.length > 1) {
                    let developerName = splitDeveloperName[0];
                    field.structure = record[developerName];
                }
            }
        })
    }
}

export class MobilityFieldModel extends Model {

    constructor(data) {
        super(data);
    }

    _model() {
        return {
            type: '',
            required: false,
            readOnly: false,
            pickListMap: {},
            name: '',
            index: 0,
            developerName: '',
            isType: '',
            structure: null,
            labelName: null,
            record: {},
            invisible: false,
            redirectURL: '',
            params: '',
            redirectLab: null
        }
    }

    get valueObject() {
        let value = this.record[this.developerName] || null;

        if (this.isDate) return (value) ? new Date(value) : null;

        return value;
    }

    get value() {
        return this.record[this.developerName] || null;
    }

    get isDetail() {
        return this.isType === 'detail';
    }

    get isEdit(){
        if(this.isFilter && this.isDate) return false;

        return this.isType === 'edit' || this.isFilter;
    }

    get canRedirect(){
        console.log(JSON.parse(JSON.stringify(this)));
        var toRet = this.redirectURL && true;

        if(this.params){
            
            for(var i = 0; i<this.params.length; i++){
                let objects = this.params[i].split(".");
                var j = 0;
                var temp = this;
                for(; j<objects.length; j++ ){
                    if(!temp[objects[j]]){
                        return false;
                    }
                    temp = temp[objects[j]];
                }
                
            }
        }
        return toRet;
    }


    

    get redirect(){
        var url = '/crm/' + this.redirectURL;
        for(var i = 0; i<this.params.length; i++){
            console.log(this.params[i]);
            console.log(JSON.parse(JSON.stringify(this)));
            let objects = this.params[i].split(".");
            console.log(objects);
            var j = 0;
            var temp = this;
            for(; j<objects.length-1; j++ ){
                temp = temp[objects[j]];
                console.log("temp",temp);
            }
            url = url.replace('{'+(i+1)+'}', temp[objects[j]]);
            
        }
        /*if(this.structure){
            for(var i = 0; i<this.params.length; i++){
                if(this.structure[this.params[i]])
                    url = url.replace('{'+(i+1)+'}', this.structure[this.params[i]]);
                else if(this.record[this.params[i]]){
                    url = url.replace('{'+(i+1)+'}', this.record[this.params[i]]);
                }
            }
        }
        else{
            for(var i = 1; i<=this.params.length; i++){
                url = url.replace('{'+(i+1)+'}', this.record[this.params[i]]);
            }
        }*/
        console.log (url);
        return url;
    }

    get redirectLabel(){
        if ( this.redirectLab ) return this.redirectLab;
        return this.valueData;
    }

    get isFilter() {
        return this.isType === 'filter';
    }

    get isReadOnly() {
        if (this.isFilter) return false;
        if (this.isReference) return true;
        if (this.isDetail) return true;

        return this.readOnly;
    }

    get isRequired() {
        if (this.isDetail) return false;
        if (this.isBoolean) return false;

        return this.required;
    }

    get styleReadOnly() {
        if (this.isDetail) return 'label-readOnly';
        return '';
    }

    get fieldType() {
        switch (this.type) {
            case 'STRING':
            case 'TEXT':
                return 'text';
            case 'EMAIL':
                return 'email';
            case 'PHONE':
                return 'tel';
            case 'CURRENCY':
            case 'NUMBER':
            case 'PERCENT':
            case 'DOUBLE':
                return 'number';
            case 'URL':
                return 'url';
            case 'BOOLEAN':
            case 'CHECKBOX':
                return 'checkbox';
            case 'PICKLIST':
                return 'select';
            case 'TIME':
                return 'time';
            case 'DATETIME':
                return 'datetime';
            case 'DATE':
                return 'date';
            case 'TEXTAREA':
                return 'textarea';
        }
    }

    get pickListValue() {
        let result = [];
        for (let key in this.pickListMap) {
            let value = this.pickListMap[key];

            result.push({
                label: key,
                value,
                selected: (this.value === value)
            });
        }
        return result;
    }

    get pickListValueDetail(){
        let valueSelect = this.value;
        let reverseMap = new Map();
          
        for (let keyI in this.pickListMap){
            reverseMap.set(this.pickListMap[keyI],keyI);           
        }     

        for (let key in this.pickListMap) {
            let value = this.pickListMap[key];

            if(this.value === value){
                valueSelect = reverseMap.get(value);
            }
        }
       
        return valueSelect;
    }

    get isSelect() {
        return (this.type === 'PICKLIST');
    }

    get isBoolean() {
        return (
            this.type === 'CHECKBOX' ||
            this.type === 'BOOLEAN'
        );
    }

    get isUrl() {
        return (
            this.type === 'URL'
        );
    }

    get isText() {
        return (
            this.type === 'STRING' ||
            this.type === 'TEXT' ||
            this.type === 'EMAIL' ||
            this.type === 'PHONE' ||
            this.type === 'REFERENCE' ||
            this.type === 'COMBOBOX' ||
            this.type === 'CURRENCY' ||
            this.type === 'NUMBER' ||
            this.type === 'PERCENT' ||
            this.type === 'DOUBLE'
        );
    }

    get isTextarea() {
        return (this.type === 'TEXTAREA');
    }

    get isDate() {
        return (this.type === 'DATE' || this.type === 'DATETIME');
    }

    get isDateDetail() {
        return (this.type === 'DATE');
    }

    get isDatetimeDetail() {
        return (this.type === 'DATETIME');
    }

    get isSelectDetail() {
        return (this.type === 'PICKLIST');
    }

    get toggleDisable() {
        if (this.isType === 'detail') return true;
        return this.isReadOnly;
    }

    get isReference() {
        return this.type === 'REFERENCE';
    }

    get visible() {
        if (this.invisible === true) return false;
        return true;
    }

    get labelData() {
        if (this.labelName){
            if (this._label[this.labelName]) return this._label[this.labelName];
            return this.labelName;
        }
        return this.name;
    }

    get valueData() {
        if (this.isReference && this.structure) {
            var fieldName = this.developerName.split('\.')[1];
            console.log('Struct: ',this.structure);
            console.log(fieldName);
            if( this.structure[fieldName]){
                return this.structure[fieldName];
            }
            
            return '';
        }

        return this.value || '';
    }
   
    get valueDateEncode() {
        if(!this.value) return '';
        
        let date = new Date(this.value);      
        if(this.type=='DATETIME')       
         return (date.getDate() > 9 ? date.getDate() : ('0' + date.getDate() )) + '/' + ((date.getMonth() > 8) ? (date.getMonth() + 1) : ('0' + (date.getMonth() + 1))) + '/' + date.getFullYear() +' '+ (date.getHours() > 9 ? date.getHours() : ('0' + date.getHours() ))+ '.'+ (date.getMinutes() > 9 ? date.getMinutes() : ('0' + date.getMinutes() ))  ;
        else  if(this.type=='DATE'){
            return (date.getDate() > 9 ? date.getDate() : ('0' + date.getDate() )) + '/' + ((date.getMonth() > 8) ? (date.getMonth() + 1) : ('0' + (date.getMonth() + 1))) + '/' + date.getFullYear() ; 
        }  
    }

    get valueOfDate() {             
        return (!this.value) ?  ' ' :  this.value;       
     }


    get class() {
        let classes = []

        if (this.type === 'DATETIME' && !this.isDetail) {
            classes.push('col-8');
        } else if (this.type === 'CHECKBOX' || this.type === 'BOOLEAN') {
            classes.push('col-12');
            classes.push('toggle');
            classes.push('mt-3')
        } else if (this.type === 'TEXTAREA') {
            classes.push('col-12');
        } else {
            classes.push('col-4');
        }

        return classes.join(' ');
    }
}

export class MobilitySectionCollection extends ModelCollection {

    constructor(data) {
        super(data);
        this.updateTypeSection();
    }

    _model() {
        return {
            ...super._model(),
            type: '',
            record: {},
            definition: {},
            recordType: ''
        }
    }

    _childType() {
        return MobilitySectionModel;
    }

    updateField(developerName, value) {
        this.getAll().forEach((section, sectionId) => {
            section.fields.getAll().forEach((field, fieldId) => {
                if (field.developerName === developerName) {
                    field.value = value
                }
            })
        })
    }

    updateTypeSection() {
        return this.getAll().forEach((section) => {
            section.type = this.type;
            section.updateType(this.record);
        })
    }

    getDefinition(key){
        return this.definition[key];
    }

    getValueDate(value){
        if(!value) return null;
        if(value === '') return null;

        let year = value.getFullYear();
        let month = value.getMonth() + 1;
        let day = value.getDate();

        if(month < 10) month = `0${month}`;
        if(day < 10) day = `0${day}`;

        let valueDate = `${year}-${month}-${day}`;
        let labelDate = `${day}/${month}/${year}`;

        return {
            valueDate,
            labelDate
        }
    }

    getLabelByPicklist(definition, value){
        let keyFound;
        for(let key in definition.pickListMap){
            let picklistValue = definition.pickListMap[key];

            if(picklistValue === value){
                keyFound = key;
            }
        }

        return keyFound;
    }

    getFilter = () => {
        let filters = [];

        for(let key in this.record){
            let value = this.record[key];
            if(!value) continue;

            let definition = this.getDefinition(key);
            if(!definition) continue;

            console.log('getFilter');

            if(definition.type === 'DATE'){

                let dateFrom = this.getValueDate(value['1']);
                let dateTo = this.getValueDate(value['2']);
                let filterValue;
                let labelDate;

                if(dateFrom && dateTo){
                    filterValue = `!BETWEEN(${dateFrom.valueDate},${dateTo.valueDate})`;
                    labelDate = `Da ${dateFrom.labelDate} A ${dateTo.labelDate}`
                }
                if(dateFrom && !dateTo){
                    filterValue = `!GTE(${dateFrom.valueDate})`;
                    labelDate = `Da ${dateFrom.labelDate}`
                }
                if(!dateFrom && dateTo){
                    filterValue = `!LTE(${dateTo.valueDate})`;
                    labelDate = `A ${dateTo.labelDate}`
                }

                if(filterValue){                
                    filters.push({
                        label: definition.name,
                        labelValues: [labelDate],
                        field: key,
                        values: [filterValue]
                    });
                }
            }else if(definition.type === "PICKLIST"){
                let labelValue = this.getLabelByPicklist(definition, value);
                filters.push({
                    label: definition.name,
                    labelValues: [labelValue],
                    field: key,
                    values: [`${value}`]
                })
            }else{
                console.log('definition', definition);
                filters.push({
                    label: definition.name,
                    labelValues: [value],
                    field: key,
                    values: [`${value}`]
                })
            }
        }

        return filters;
    }

    changeField(developerName, changeData){
        this.getAll().forEach((section, sectionId) => {
            section.fields.getAll().forEach((field, fieldId) => {
                if (field.developerName === developerName) {
                    section.fields.add({...field, ...changeData});
                }
            });
        })

        let definition = this.getDefinition(developerName);
        if(definition){
            this.definition = {...this.definition};
            this.definition[developerName] = {...definition, ...changeData};
        }
    }
}

export class MobilitySectionModel extends Model {

    constructor(data) {
        super(data);
        this.fields = new MobilityFieldCollection({
            collection: data.fields
        })
    }

    _model() {
        return {
            name: '',
            fields: new MobilityFieldCollection(),
            type: '',
            index: 0,
            invisible: false,
            isUsingURLpreview:false //new after id:push notification for iframe and URL *-+
        }
    }

    updateType(record) {
        this.fields.updateType(this.type, record);
    }

    get fieldsEmpty() {
        return this.fields.length === 0;
    }

    get visible() {
        if (this.invisible === true) return false;
        return true;
    }
}