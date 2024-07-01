import {
	MobilityAbstract
} from "c/mobilityAbstract";

import {
	api,
	track
} from "lwc";

export default class MobilityTesting extends MobilityAbstract {

	connectedCallback() {
		this.hideSpinner();
	}

}