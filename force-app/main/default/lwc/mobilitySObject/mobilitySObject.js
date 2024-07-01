import {
	track,
	api
} from 'lwc';

import {
	MobilityAbstract
} from 'c/mobilityAbstract';

export class MobilitySObject extends MobilityAbstract {
	componentView = 'mobilitySObject';

	@track customLayout = {};

	@api title;
	@api recordType;
	@api canNotSaveData = false;
	@api typeLayout;
	@api closeCallback;
	@api saveCallback;
	@api saveConfirmCallback;
	@api recordDefault = {};
	@api recordOverride = {};
	@api fieldsOverride = {};

	objectName = 'SObject';

	connectedCallback() {
		super.connectedCallback();
		this.hideSpinner();
	}

	onHookCustomLayout = (target) => {
		this.customLayout = target;
	}

	onConfirm = () => {
		if(!this.saveConfirmCallback) return this.onSave();

		return this.onCheck().then(()=>{
			return this.saveConfirmCallback(this).then(this.onSave);
		}).catch((err)=>{
			console.log(err);
		});
	}

	onCheck = () => {
		return new Promise((resolve, reject)=>{
			if(this.customLayout.checkData()){
				resolve();
			}else{
				throw new Error('Data not valid');
			}
		})
	}

	onSave = () => {
		return this.customLayout.saveData().then(()=>{
			this.onClose();
		});
	}

	onClose = (e) => {
		if(this.closeCallback) this.closeCallback(e);
	}

}