import { track, api, LightningElement } from 'lwc';
import { LghtAbstract } from 'c/lghtAbstract';

export default class LghtCaseClose extends LghtAbstract {
	
	@api recordId;
	@api sObjectName;
	@api caseData;
	@api caseRecordType;
	@api closeCallback;

	connectedCallback(){
		super.connectedCallback();
	}

}