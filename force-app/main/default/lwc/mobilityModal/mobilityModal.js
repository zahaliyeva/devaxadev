import { LightningElement, api } from 'lwc';

export default class MobilityModal extends LightningElement {
    @api hideCloseButton = false;
    @api closeCallback
    handleClose() {
        if(this.closeCallback) this.closeCallback();
        else
        this.dispatchEvent(new CustomEvent('close'));
    }
}