import {
    ModelCollection,
    Model
} from 'c/mobilityAbstractModel';

export class TimeCollection extends ModelCollection{
	
	_model() {
	    return {
	        hour: 0,
	        minute: 0
	    }
	}

	_childType() {
	    return TimeModel;
	}

}

export class TimeModel extends Model{

	_model() {
	    return {
	        hour: 0,
	        minute: 0,
	        select: ''
	    }
	}

	get hoursString(){
		if(this.hour < 10) return `0${this.hour}`;
		return `${this.hour}` 
	}

	get minutesString(){
		if(this.minute < 10) return `0${this.minute}`;
		return `${this.minute}` 
	}

	get time(){
		return `${this.hoursString}:${this.minutesString}`;
	}

	get selected(){
		return this.time === this.select;
	}

}