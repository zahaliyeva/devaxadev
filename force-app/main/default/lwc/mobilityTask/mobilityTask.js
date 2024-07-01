import {
	track,
	api
} from 'lwc';

import {
	MobilitySObject
} from 'c/mobilitySObject';

export default class MobilityTask extends MobilitySObject {
	@api hideModal = false;
	componentView = 'mobilityTask';
	objectName = 'Task';
	
	connectedCallback() {
		super.connectedCallback();
	}

}