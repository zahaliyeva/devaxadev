import { LightningElement, api } from 'lwc';
import { MobilityCampaignCollection } from 'c/mobilityCampaignModel';
import SObjectDataGrid from 'c/sObjectDataGrid';

export default class MobilityCampaignDataGrid extends SObjectDataGrid {

	@api navigateCallback;

	get hasNavigateCallback(){
		return !!this.navigateCallback;
	}

    get elements(){
        const processData = [];
        
        for(let row of this.tabledata.data){
            processData.push({
                ...row.element
            });
        }

        console.log('MobilityCampaignDataGrid', 'processData', processData);

        const collection = new MobilityCampaignCollection({
            collection: processData,
            counterObject: this.tabledata.additionalData.getCampaignsCounters || {},
            counterObjectClosed: this.tabledata.additionalData.getCampaignClosedMember || {},
            counterObjectPriority: this.tabledata.additionalData.getCampaignPriority || {},
        });
        const result = collection.getAll();

        console.log('MobilityCampaignDataGrid', 'collection', this.proxyData(collection));
        console.log('MobilityCampaignDataGrid', 'result', result)
        return result;
    }

	onNavigate(e){
		const { recordId } = e.currentTarget.dataset;

		if(this.navigateCallback){
			this.navigateCallback(recordId)
		}
	}
}