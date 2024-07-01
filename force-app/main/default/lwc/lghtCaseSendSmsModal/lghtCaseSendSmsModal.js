import { LightningElement, track, api } from 'lwc';
import { LghtAbstract } from 'c/lghtAbstract';
import VFP17_Page_Label from "@salesforce/label/c.VFP17_Page_Label"; 


export default class LghtCaseSendSmsModal extends LghtAbstract {
    
	@api caseData;
	@api closeCallback;

	componentView = 'LghtCaseSendSMSModal';

	connectedCallback() {
		super.connectedCallback();
	}

	get title(){
		return VFP17_Page_Label;
	}
	
}