import { LightningElement, api } from 'lwc';
import { FlowNavigationNextEvent } from 'lightning/flowSupport';

export default class FlowNextEventComponent extends LightningElement {

    connectedCallback(){
        this.navigateNext();
    }

    @api
    navigateNext(){
        const navigateNextEvent = new FlowNavigationNextEvent();
        this.dispatchEvent(navigateNextEvent);
    }

}