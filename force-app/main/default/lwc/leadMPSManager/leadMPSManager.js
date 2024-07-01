import { LightningElement, api, track } from 'lwc';
import { LghtAbstract } from 'c/lghtAbstract';

export default class leadMPSManager extends LghtAbstract{
    
    @api recordId;
    openModal = false;

    OpenModal = () => {
        this.openModal = true;
    }

    OnCloseModal = () => {
        //alert("try");
        this.openModal = false;
    }
}