import { LightningElement, api } from 'lwc';
import { LghtAbstract } from 'c/lghtAbstract';

export default class LghtCaseFindAssociateModal extends LghtAbstract {

	@api recordId
	@api type
	@api caseRecordType
	@api closeCallback;

	componentView = 'LghtCaseFindAssociateModal';

	connectedCallback() {
		super.connectedCallback();
	}

	get title(){
		return `${(this.type === 'customer') ? 'Associa Cliente' : 'Associa Gestore'}`
	}
	
}