import {
	LightningElement,
	track,
	api,
	wire
} from 'lwc';

import {
	MobilityAbstract
} from 'c/mobilityAbstract';


export default class MobilitySpinner extends MobilityAbstract {

	@api show;
	@api showOverlay = false;

	get classString(){
		let classes = [
			'overload-contain',
			'overload-on-top'
		];

		if(this.showOverlay) classes.push('overload-overlay');

		return classes.join(' ');
	}

}