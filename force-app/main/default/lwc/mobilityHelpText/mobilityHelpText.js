import { LightningElement, api, track } from 'lwc';

export default class MobilityHelpText extends LightningElement {

    @api text;

    @track showPop = false;

    connectedCallback(){
        console.log(this.text);
    }

    onHover = () => {
        this.showPop = true;
        
    };

    onOut = () => {
        this.showPop = false;
    }

}