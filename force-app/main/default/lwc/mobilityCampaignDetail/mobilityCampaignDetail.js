import {
	track
} from 'lwc';

import {
    MobilityAbstract
} from 'c/mobilityAbstract';

export default class MobilityCampaignDetail extends MobilityAbstract {
    componentView = 'MobilityCampaignDetail';
    customLayout;

    record;

    @track recordType
    @track dataLoad = false;
    fromAgency = false;

    connectedCallback() {
        super.connectedCallback();
    }

    readyCallback = (target) => {
    	this.customLayout = target;
    }

    get canEdit(){
        return this.isVenditeAvanzato && this.recordType == 'Agency_campaign';
    }

    loadCallback = (result) => {
        
        
        this.record = result.record;
        if(this.record && this.record.Campagna_creata_da_Direzione_Agente__c){
            this.fromAgency = true;
        }
    	this.recordType = this.customLayout.sections.recordType;
    	this.dataLoad = true;
    	this.hideSpinner();
    }
}