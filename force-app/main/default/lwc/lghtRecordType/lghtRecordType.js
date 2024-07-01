import { LightningElement, track, api, wire } from 'lwc';

import { LghtAbstract } from 'c/lghtAbstract';
import { Model, ModelCollection } from 'c/lghtAbstractModel';

class SelectCollection extends ModelCollection{
	
	_childType(){
		return SelectModel;
	}

}

class SelectModel extends Model{

	_model(){
		return {
			name: '',
			recordTypeId: '',
			selected: false,
			available: false
		}
	}

	get class(){
		let listClasses = ['item'];


		if(this.selected){
			listClasses.push('selected');
		}

		return listClasses.join(' ');
	}
}

export default class LghtRecordType extends LghtAbstract {

	@track _listRecordTypes = new SelectCollection();
	@track selectedValue;

	@api show = false;
	@api cancelCallback;
	@api confirmCallback;

	@api 
	get listRecordTypes(){
		return this._listRecordTypes;
	}
	set listRecordTypes(value){
		this.updateType('_listRecordTypes', value);
	}

	constructor(data){
		super(data);

		this.registerType('_listRecordTypes', SelectCollection)
	}

	get getData() {
		return this._listRecordTypes.getAll().filter((element, index)=>{
			return element.available;		
		});
	}

	get isDisabled(){
		return !this.selectedValue;
	}

	onShow(){
		this.show = true;
	}

	onHide(){
		this.show = false;

		if(this.cancelCallback){
			this.cancelCallback(this.selectedValue);
		}
	}

	onToggle(){
		this.show = !this.show;
	}

	onSelect = e => {
		let selectedValue = e.target.dataset.value;

		this._listRecordTypes.getAll().forEach((element)=>{
			if(selectedValue === element.Id){
				element.selected = true;
				
				this.selectedValue = element;
			}else{
				element.selected = false;
			}
		})

		this.updateType('_listRecordTypes');
	}

	onConfirm(){
		if(this.confirmCallback){
			this.confirmCallback(this.selectedValue);
		}
	}
}