import { api, track } from 'lwc';
import { MobilityAbstract } from 'c/mobilityAbstract';
import mobilityHomepageIcons from '@salesforce/resourceUrl/mobilityHomepageIcons';
import loadCounters from '@salesforce/apex/MobilityWidgetsHomepage.feedbackCounters';

export default class MobilityWidgetFeedback extends MobilityAbstract {
    componentView = 'mobilityWidgetFeedback';
    
    @track data = {};

    get iconPath(){
        return `${mobilityHomepageIcons}/feedback.png`;
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