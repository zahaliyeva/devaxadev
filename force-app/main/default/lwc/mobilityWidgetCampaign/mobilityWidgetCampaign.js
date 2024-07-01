import { api, track } from 'lwc';
import { MobilityAbstract } from 'c/mobilityAbstract';
import mobilityHomepageIcons from '@salesforce/resourceUrl/mobilityHomepageIcons';
import loadCounters from '@salesforce/apex/MobilityWidgetsHomepage.leadCounters';

export default class MobilityWidgetCampaign extends MobilityAbstract {
    componentView = 'mobilityWidgetCampaign';

    @track data = {};

    get iconPath(){
        return `${mobilityHomepageIcons}/campaign.png`;
    }

    connectedCallback() {
        super.connectedCallback();
        this.loadData();
    }
    
    refreshCallback(){
        //OVERRIDE
        console.log('refresh', this.componentView);
        this.loadData();
    }

    async loadData(){
        console.log('loadData');
        const result = await loadCounters();
        this.data = {...result};
    }
}