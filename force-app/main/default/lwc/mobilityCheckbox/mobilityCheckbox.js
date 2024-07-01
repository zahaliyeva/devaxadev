import {
	MobilityAbstract
} from "c/mobilityAbstract";

import {
	api,
	track
} from "lwc";

export default class MobilityCheckbox extends MobilityAbstract {

	@api name;
	@api checked;
	@api readonly;
	@api disabled;
	@api changeCallback;

	connectedCallback() {
		this.hideSpinner();
	}
}