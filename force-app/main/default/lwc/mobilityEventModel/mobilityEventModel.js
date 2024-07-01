import { LightningElement } from 'lwc';

import { Model, ModelCollection } from 'c/mobilityAbstractModel';

import { MobilityLib } from 'c/mobilityLib';

export class MobilityEventCollection extends ModelCollection {

	_childType() {
		return MobilityEventModel;
	}

}

export class MobilityEventModel extends Model {

	_model() {
		return {
			Subject: '',
			StartDateTime: null,
			EndDateTime: null,
			Who: {}
		}
	}

	get WhoName() {
		if (!this.Who) return '';
		return this.Who.Name;
	}

	get dateString(){
		if (!this.StartDateTime) return '';
		let dateObject = this.getDateTimeFormated(this.StartDateTime);		
		return `${dateObject.days}/${dateObject.months}/${dateObject.years}`;
	}

	get StartTime() {
		if (!this.StartDateTime) return '';
		let dateObject = this.getDateTimeFormated(this.StartDateTime);
		return `${dateObject.hours}:${dateObject.minutes}`;
	}

	get EndTime() {
		if (!this.EndDateTime) return '';
		let dateObject = this.getDateTimeFormated(this.EndDateTime);
		return `${dateObject.hours}:${dateObject.minutes}`;
	}

}