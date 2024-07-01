import { Model, ModelCollection } from 'c/mobilityAbstractModel';

export class MobilityTaskCollection extends ModelCollection {

    _childType() {
        return MobilityTaskModel;
    }

}

export class MobilityTaskModel extends Model {

    _model() {
        return {
            Subject: '',
            ActivityDate: null,
            Who: {},
            IsHighPriority: Boolean,
        }
    }

    get WhoName() {
        if (!this.Who) return '';
        return this.Who.Name;
    }

    // Convert Data Format
    get ActivityDateString() {
        if (!this.ActivityDate) return '';
        let dateObject = this.getDateTimeFormated(this.ActivityDate);
        return `${dateObject.days}/${dateObject.months}/${dateObject.years}`;
    }
}