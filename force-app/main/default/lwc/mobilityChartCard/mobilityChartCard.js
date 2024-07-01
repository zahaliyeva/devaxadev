import { LightningElement, api, track } from 'lwc';

export default class MobilityChartCard extends LightningElement {
    @api params = {};
    @track setData;
    
    proxyData(proxyObj) {
		return JSON.parse(JSON.stringify(proxyObj));
	}
    connectedCallback(){
        
    }

}