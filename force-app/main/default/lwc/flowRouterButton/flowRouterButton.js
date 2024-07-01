import { LightningElement, api } from 'lwc';
import { FlowNavigationNextEvent } from 'lightning/flowSupport';

export default class FlowRouterButton extends LightningElement {

    @api variant;
    @api label;
    @api routeDirectioin;
    @api Direction;
    @api classe;

    handleClick(){
        this.Direction = this.routeDirectioin;
        const navigateNextEvent = new FlowNavigationNextEvent();
        this.dispatchEvent(navigateNextEvent);
    }
}