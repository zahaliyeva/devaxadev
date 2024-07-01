import {
    Model,
    ModelCollection
} from 'c/mobilityAbstractModel';

import {
    MobilityCampaignModel
} from 'c/mobilityCampaignModel';

export class MobilityCampaignMembersCollection extends ModelCollection {

    _childType() {
        return MobilityCampaignMembersModel;
    }

}

export class MobilityCampaignMembersModel extends Model {

    _model() {
        return {
            Id: '',
            Status: '',
            Campaign: new MobilityCampaignModel(),
            Contact: {
                Account: {
                    NDG__c: ''
                }
            },
            Owner__r: {
                Name: '',
                Id: ''
            }
        }
    }

    agencyStatus() {
        return [
            'Agency_campaign'
        ]
    }

    campaignStatus() {
        return [
            'Data_Enrichment_Campaign',
            'Informative_Campaign',
            'Marketing_campaign'
        ]
    }

    get CampaignType() {

        let cType;

        if (this.agencyStatus().includes(this.Campaign.RecordType.DeveloperName) && 
            !this.Campaign.Campagna_creata_da_Direzione_Agente__c) { //Agency_campaign && Campagna_creata_da_Direzione_Agente__c = false -> da agenzia vecchia
            cType = this._label.customerCampaign_type_agency;
        }
        if (this.campaignStatus().includes(this.Campaign.RecordType.DeveloperName)&&
            this.Campaign.Campagna_creata_da_Direzione_Agente__c) { //Altri recordtype != "Agency_campaign" &&  Campagna_creata_da_Direzione_Agente__c = true -> da Agenzia dopo push2
            cType = this._label.customerCampaign_type_agency;
        }
        if (this.campaignStatus().includes(this.Campaign.RecordType.DeveloperName)&&
            !this.Campaign.Campagna_creata_da_Direzione_Agente__c) { //Altri recordtype != "Agency_campaign" && Campagna_creata_da_Direzione_Agente__c = false - > da Direzione dopo push2
            cType = this._label.customerCampaign_type_campaignManagement;
        }

        return cType;
    }

    get EndDateString() {
        if (!this.Campaign.EndDate) return '';
        let dateObject = this.getDateTimeFormated(this.Campaign.EndDate);
        return this._label.customerCampaign_endDate_expires + ' ' + `${dateObject.days}/${dateObject.months}/${dateObject.years}`;
    }

    // Get Label Background Color
    greenLabel() {
        return [
            'Interessato',
            'Lavorato',
            'Non risponde',
            'Contatto errato',
            'Non interessato'
        ]
    }

    redLabel() {
        return [
            'Da contattare',
            'Da ricontattare',
            'Da assegnare',
            'Da lavorare',
            'Richiesta informazioni'
        ]
    }

    blueLabel() {
        return [
            'In Campagna',
            'Escluso',
            'In preparazione'
        ]
    }

    get ColorLabel() {
        let colorLabel = ['badge', 'text-uppercase'];

        if (this.greenLabel().includes(this.Status)) {
            colorLabel.push('badge-green');
        } else if (this.redLabel().includes(this.Status)) {
            colorLabel.push('badge-red');
        } else if (this.blueLabel().includes(this.Status)) {
            colorLabel.push('badge-purple');
        } else {
            colorLabel.push('badge-purple');
        }

        return colorLabel.join(' ');

    }

    get StatusLabel() {
        let status = this.Status;

        switch (this.Status) {
            case 'Interessato':
                this.Status = this._label.customerCampaign_status_interested
                break;

            case 'Lavorato':
                this.Status = this._label.customerCampaign_status_worked
                break;

            case 'Non risponde':
                this.Status = this._label.customerCampaign_status_noAnswer
                break;

            case 'Contatto errato':
                this.Status = this._label.customerCampaign_status_wrongContact
                break;

            case 'Non interessato':
                this.Status = this._label.customerCampaign_status_noInterested
                break;

            case 'Da contattare':
                this.Status = this._label.customerCampaign_status_toContact
                break;

            case 'Da ricontattare':
                this.Status = this._label.customerCampaign_status_toRecontact
                break;

            case 'Da assegnare':
                this.Status = this._label.customerCampaign_status_toAssign
                break;

            case 'Da lavorare':
                this.Status = this._label.customerCampaign_status_toWork
                break;

            case 'Richiesta informazioni':
                this.Status = this._label.customerCampaign_status_infoRequest
                break;

            case 'In Campagna':
                this.Status = this._label.customerCampaign_status_inCampaign
                break;

            case 'Escluso':
                this.Status = this._label.customerCampaign_status_excluding
                break;

            case 'In preparazione':
                this.Status = this._label.customerCampaign_status_inPreparation
                break;

            default:
                this.Status = ''
                break;
        }

        return status;
    }

}