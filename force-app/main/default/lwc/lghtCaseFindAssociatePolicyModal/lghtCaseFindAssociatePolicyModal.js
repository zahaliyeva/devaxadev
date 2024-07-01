import { LightningElement, api } from 'lwc';
import { LghtAbstract } from 'c/lghtAbstract';

export default class LghtCaseFindAssociatePolicyModal extends LghtAbstract {

	@api caseData;
	@api closeCallback;

	componentView = 'LghtCaseFindAssociatePolicyModal';

	connectedCallback() {
		super.connectedCallback();
	}

	get title(){
		return `Associa Polizza`
	}
	
}