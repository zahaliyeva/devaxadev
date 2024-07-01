import {
    MobilityAbstract
} from "c/mobilityAbstract";
import {
    track
} from "lwc";
import {
    MobilityCampaignMembersCollection
} from "c/mobilityCampaignMembersModel";
import getCampaignCustomer from "@salesforce/apex/MobilityCampaignController.getCampaignCustomer";

export default class MobilityCustomerCampaignList extends MobilityAbstract {

    @track records = {};
    componentView = 'mobilityCustomerCampaignList';

    connectedCallback() {
        super.connectedCallback();
        this.loadData().catch((result) => {
            this.criticalMessage();
        }).finally(() => {
            this.hideSpinner();
        })
    }
    
    openCallbackEvent = (e) => {
		console.log(e.target);
		let dataSet = {};
        dataSet['recordId'] = e.currentTarget.dataset['recordId'];
        dataSet['campaignMemberId'] = e.currentTarget.dataset['campaignMemberId'];
        dataSet['ndgId'] = e.currentTarget.dataset['ndgId'];
        dataSet['recordType'] = e.currentTarget.dataset['recordType'];
        dataSet['type'] = e.currentTarget.dataset['type'];

		//let dataSet = this.proxyData(e.currentTarget.dataset);

		this.openCallbackEventDOMString(dataSet);
	}

    loadData() {
        return getCampaignCustomer({
            limitRows: this.params.limit,
            ndgId: this.params.ndgId
        }).then((result) => {
            this.records = new MobilityCampaignMembersCollection({
                collection: this.proxyData(result)
            }, true);
            this.showNoData(this.records.length === 0);
        }).catch((err) => {
            console.log("err", err);
        });
    }

    get allData() {
        if (!this.records) return [];
        if (!this.records.collection) return [];

        return this.records.getAll();
    }
}