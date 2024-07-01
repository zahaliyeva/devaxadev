import {
	track,
	api
} from 'lwc';

import {
	MobilitySObject
} from 'c/mobilitySObject';

export default class MobilityEvent extends MobilitySObject {
	componentView = 'mobilityEvent';
	objectName = 'Event';

	connectedCallback() {
		super.connectedCallback();
	}
}