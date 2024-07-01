import { LightningElement, api } from 'lwc';
import { FlowNavigationNextEvent } from 'lightning/flowSupport';

export default class FlowRouterScript extends LightningElement {

    @api routeDirection;
    @api Direction;
    @api listIDs;

    renderedCallback(){
        if(this.listIDs !== this.lastListIDs ){
            this.lastListIDs = this.listIDs;
            this.Direction = this.routeDirection;
            const navigateNextEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(navigateNextEvent);
        }
    }
}