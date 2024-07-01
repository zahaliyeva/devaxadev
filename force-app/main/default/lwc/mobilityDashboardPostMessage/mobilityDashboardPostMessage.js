import { LightningElement, api } from 'lwc';
import {
	MobilityAbstract
} from 'c/mobilityAbstract';

export default class MobilityDashboardPostMessage extends MobilityAbstract {
    
    @api label;

    @api componentName;
    

    connectedCallback(){
        this.params = {"Id": "MobilityDashboardPostMessage"}
    }

    clickHandler(){
        this.navigateTo({
			name: this.componentName
        })
    }

}