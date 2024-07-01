import { LightningElement, api } from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import {
	MobilityAbstract
} from 'c/mobilityAbstract';

export default class MobilityDashboardCollab extends NavigationMixin(LightningElement) {
    
    @api label;

    @api componentName;

    @api altezza;

    @api larghezza;

    @api colorepuls;

    @api colorelab;

    @api font;

    @api fontdim;

    @api iddash;
    

   

    clickHandler(){
        const navConfig = {
            type: "standard__component",
            attributes: {
                componentName: "c__mobilityEcollabCruscotto"
            },
            state: {
                c__param1: this.iddash
                
            }
        };
        this[NavigationMixin.Navigate](navConfig);
    }

}