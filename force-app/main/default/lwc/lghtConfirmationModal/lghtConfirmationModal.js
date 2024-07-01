import { LightningElement, api } from 'lwc';
import { LghtAbstract } from 'c/lghtAbstract';

export default class LghtConfirmationModal extends LghtAbstract {

    @api text;
    @api confirmCallback;
    @api closeCallback;

    connectedCallback(){
        this.hideSpinner();
    }

    onConfirm(){
        if(this.confirmCallback){
            
            this.confirmCallback();
            
        };
    }

    onClose(){
        if(this.closeCallback){ this.closeCallback() };
    }


}