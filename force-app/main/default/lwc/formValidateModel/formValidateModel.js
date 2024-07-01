import { Model, ModelCollection } from 'c/lghtAbstractModel';

export class FormValidateCollection extends ModelCollection {

	constructor(data) {
		super(data);
	}

	_childType() {
		return FormValidateModel;
	}

	addForm(Id, target){
		this.add({Id, target})
	}

	isValid(){
		let isValid = true;

		this.getAll().forEach((element)=>{
			const checkStatus = element.target.onCheck();

			if(!checkStatus) isValid = checkStatus;
		});

		return isValid;
	}

}

export class FormValidateModel extends Model {

	_model() {
		return {
			target: null
		}
	}

}