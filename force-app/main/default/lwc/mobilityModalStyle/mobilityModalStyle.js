import { LightningElement } from 'lwc';
import mobilityModalStyle from './mobilityModalStyle.css';

export default class MobilityModalStyle extends LightningElement {
    constructor() {
        super();

        if(document.getElementById('mobilityModalStyle')) {
            return;
        }

        try {
            const style = document.createElement('style');
            style.id = 'mobilityModalStyle';
            if (Array.isArray(mobilityModalStyle) && typeof mobilityModalStyle[0] === 'function') {
                style.innerText = mobilityModalStyle[0]();
            }
    
            document.getElementsByTagName('head')[0].appendChild(style);
        } catch(e) {
            console.error('Unable to load common styles for mobility modal');
        }

    }
}