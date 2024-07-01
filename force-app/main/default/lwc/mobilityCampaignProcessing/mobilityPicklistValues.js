import {
	Model,
	ModelCollection
} from 'c/mobilityAbstractModel';

export class MobilityPicklistValues extends Model {
	
	static statusDataEnrichment = [
	    {
	        label: '-',
	        value: ''
	    },
	    {
	        label: Model._label.customerCampaign_status_toAssign,
	        value: 'Da assegnare'
	    },
	    {
	        label: Model._label.customerCampaign_status_toWork,
	        value: 'Da lavorare'
	    },
	    {
	        label: Model._label.customerCampaign_status_worked,
	        value: 'Lavorato'
	    },
	    {
	        label: Model._label.customerCampaign_status_toRecontact,
	        value: 'Da ricontattare'
	    }
	];

	static statusInformative = [
	    {
	        label: '-',
	        value: ''
	    },
	    {
	        label: Model._label.customerCampaign_status_toAssign,
	        value: 'Da assegnare'
	    },
	    {
	        label: Model._label.customerCampaign_status_toWork,
	        value: 'Da lavorare'
	    },
	    {
	        label: Model._label.customerCampaign_status_worked,
	        value: 'Lavorato'
	    },
	    {
	        label: Model._label.customerCampaign_status_toRecontact,
	        value: 'Da ricontattare'
	    },
	    {
	        label: Model._label.customerCampaign_status_noAnswer,
	        value: 'Non risponde'
	    },
	    {
	        label: Model._label.customerCampaign_status_wrongContact,
	        value: 'Contatto errato'
	    }
	];

	static statusMarketing = [
	    {
	        label: '-',
	        value: ''
	    },
	    {
	        label: Model._label.customerCampaign_status_toAssign,
	        value: 'Da assegnare'
	    },
	    {
	        label: Model._label.customerCampaign_status_toWork,
	        value: 'Da lavorare'
	    },
	    {
	        label: Model._label.customerCampaign_status_noInterested,
	        value: 'Non interessato'
	    },
	    {
	        label: Model._label.customerCampaign_status_interested,
	        value: 'Interessato'
	    },
	    {
	        label: Model._label.customerCampaign_status_toRecontact,
	        value: 'Da ricontattare'
	    },
	    {
	        label: Model._label.customerCampaign_status_wrongContact,
	        value: 'Contatto errato'
	    }
	];

	static statusAgency = [
	    {
	        label: '-',
	        value: ''
	    },
	    {
	        label: Model._label.customerCampaign_status_toAssign,
	        value: 'Da assegnare'
	    },
	    {
	        label: Model._label.customerCampaign_status_toWork,
	        value: 'Da lavorare'
	    },
	    {
	        label: Model._label.customerCampaign_status_excluding,
	        value: 'Escluso'
	    },
	    {
	        label: Model._label.customerCampaign_status_noInterested,
	        value: 'Non interessato'
	    },
	    {
	        label: Model._label.customerCampaign_status_interested,
	        value: 'Interessato'
	    },
	    {
	        label: Model._label.customerCampaign_status_toRecontact,
	        value: 'Da ricontattare'
	    },
	    {
	        label: Model._label.customerCampaign_status_wrongContact,
	        value: 'Contatto errato'
	    }
	];
}