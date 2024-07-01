import { LightningElement, api } from 'lwc';

import { loadStyle } from 'lightning/platformResourceLoader';
import MobilityEngine from '@salesforce/resourceUrl/mobilityDashboardAnalytics';



export default class MobilityNotifyChangePage extends LightningElement {

    @api pageName;
    @api results;
    @api setSelection;
    @api hasDashboard;
    @api metadata;
    @api getState;
    @api setState;
    @api selection;
    

    connectedCallback(){

        if(this.pageName === 'Home' && (window.location.href.includes('/crm/') || window.location.href.includes('/tabs/'))){
            Promise.all([
                loadStyle(this, MobilityEngine)
            ]);
        }
        
        console.log(JSON.parse(JSON.stringify(this.results)))
        let res = this.results.filter( (element) => {
            return element.Page_Name__c === this.pageName;
        } );

        console.log(JSON.parse(JSON.stringify(res)));
        
        this.setSelection(JSON.parse(JSON.stringify(res)));

    }

}