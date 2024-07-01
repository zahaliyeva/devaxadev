import {
	MobilityAbstract
} from "c/mobilityAbstract";

import {
	api,
	track
} from "lwc";

import {
	PostMessage
} from 'c/postMessage';

import getNDGData from '@salesforce/apex/MobilityWidgetsHomepage.getNDGData';
//IDCRM092 - Daniel Torchia START
export default class MobilityNpsInfo extends MobilityAbstract {
    
    componentView = 'mobilityNpsInfo';

    connectedCallback() {
		console.log('start connectedcallback');
		super.connectedCallback();
	}

	authRefresh = (params) => {
		console.log('start authrefresh');
		PostMessage.authRefresh(this.params.id, params);
	}

    refreshCallback(){
		console.log('start refreshcallback');
		this.loadData();
	}
	
	async loadData(){
		console.log('start loaddata');
        const ndgParam=this.params.ndg;
		const result=await getNDGData(ndgParam);
		console.log(JSON.stringify(result, null, '\t'));
		console.log('result');
		this.authRefresh(result);
	}
}