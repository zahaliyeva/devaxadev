import { api } from 'lwc';

import { MobilityAbstract } from 'c/mobilityAbstract';

import AxaIcons from '@salesforce/resourceUrl/axaIcons';

/**
 * Example include component
 * <c-mobility-icon name="user" width="28px" height="28px"></c-mobility-icon>
 *
 * List SVG Icons
 * /force-app/mobility/default/staticresources/axaIcons/
 * 
 */

export default class MobilityIcon extends MobilityAbstract {

	@api name;
	@api width = "50px";
	@api height = "50px";

	get svgPath() {
	    return `${AxaIcons}/${this.name}.svg#icon`;
	}
}