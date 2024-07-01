import { LightningElement } from 'lwc';

import MobilityCampaignProcessing from 'c/mobilityCampaignProcessing';
import initData from '@salesforce/apex/MobilityCampaignProcessing.initData';

export default class MobilityCustomerProcessing extends MobilityCampaignProcessing {
	componentView = 'mobilityCustomerProcessing';

	availableFilters = false;

	get redirectParams() {
	    return {
	        mobilityCustomerCampaignListView: {
	            ndgId: this.params.ndgId
	        }
	    }
	}

    getInitData(){
        return initData({
            campaignId: this.params.recordId
        }).then((result)=>{
            console.log(result);
            this.recordType = result.campaign.RecordType.DeveloperName;
            this.campaignTitle = result.campaign.Name;
			this.customLayoytData = result;
			
			this.initDataGrid()
        })
    }
}