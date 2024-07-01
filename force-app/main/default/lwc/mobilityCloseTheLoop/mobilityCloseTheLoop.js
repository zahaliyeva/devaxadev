import { MobilityAbstract } from 'c/mobilityAbstract';
import getCounterCloseTheLoop from '@salesforce/apex/MobilityCaseListController.getCounterCloseTheLoop';
import { track } from 'lwc';

export default class MobilityCloseTheLoop extends MobilityAbstract {
    componentView = 'mobilityCloseTheLoop';

    @track closeCounter;

    timeoutHadler;

    connectedCallback() {
        super.connectedCallback();
        this.counterCloseTheLoop();
    }

    startTimeout(){
        clearTimeout(this.timeoutHadler);
        this.timeoutHadler = setTimeout(this.counterCloseTheLoop, 10000);
    }

    counterCloseTheLoop = () => {
        getCounterCloseTheLoop({}).then((result) => {
            this.closeCounter = result;
        }).catch((err) => {
            console.log("err", err);
        }).finally(()=>{
            this.startTimeout();
        })
    }

}