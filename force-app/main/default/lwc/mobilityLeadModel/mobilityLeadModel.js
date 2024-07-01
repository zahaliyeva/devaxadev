import {
    Model,
    ModelCollection
} from 'c/mobilityAbstractModel';

export class MobilityLeadCollection extends ModelCollection {

    _childType() {
        return MobilityLeadModel;
    }

}

export class MobilityLeadModel extends Model {

    _model() {
        return {
            Id: '',
            Gi_cliente_AXA__c: false,
            Name: '',
            Landing_Page__c: '',
            Phone: '',
            Email: '',
            Status: ''
        }
    }

    get clientIcon() {
        if (this.Gi_cliente_AXA__c === true) {
            return 'user-axa';
        }
        
        return 'user-grey';
    }

    get StatusLabel() {
        switch (this.Status) {
            case 'Appointment':
                return this._label.lead_status_appointment;
            case 'Call again':
                return this._label.lead_status_callAgain;
            case 'Does not answer':
                return this._label.lead_status_notAnswer;
            case 'Duplicated Lead':
                return this._label.lead_status_duplicatedLead;
            case 'Not interested':
                return this._label.lead_status_notInterested;
            case 'To be processed':
                return this._label.lead_status_toBeProcessed;
            case 'Wrong contact information':
                return this._label.lead_status_wrongContact;
            default:
                return '';
        }
    }

}