import {
	api
} from 'lwc';

import {
	MobilityAbstract
} from 'c/mobilityAbstract';

import AxaImg from '@salesforce/resourceUrl/axaImg';

/**
 * Example include component
 * <c-mobility-img name="desert" class="desert"></c-mobility-img>
 *
 * List Img
 * /force-app/mobility/default/staticresources/axaImg/
 *
 */

export default class MobilityImg extends MobilityAbstract {

	@api name;
	@api height = "100%";
	@api width = "100%";

	get imgPath() {
		return `${AxaImg}/${this.name}.png#img`;
	}
}