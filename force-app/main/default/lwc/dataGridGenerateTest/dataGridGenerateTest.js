import { LightningElement } from 'lwc';

export default class DataGridGenerateTest extends LightningElement {

	onFieldRules(fieldName, fieldValue, field){
		if(fieldName === 'Name'){
			field.NameLabel = fieldValue;
			field.Name = `/${field.Id}`;
		}
	}

	onTypeColumn(fieldName, field){
		if(fieldName == 'Name'){
			field.typeAttributes = {
				label: {fieldName:'NameLabel'}
			}
		}
	}
}