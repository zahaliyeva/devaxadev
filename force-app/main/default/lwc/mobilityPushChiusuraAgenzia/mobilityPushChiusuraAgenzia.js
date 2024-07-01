import {
	MobilityAbstract
} from 'c/mobilityAbstract';
import {
	api,track
} from 'lwc';

export default class MobilityPushChiusuraAgenzia extends MobilityAbstract {

    @track chiusoDal = new Date();
    @track chiusoAl = new Date();
    @api closeCallback;
    @api primaryCallback;
    @api backCallback;
    root 
    showError

    validateDate(){
        if(this.chiusoDal && this.chiusoDal < new Date()){
            this.chiusoDal = "";
            this.showError=true;
            return false;
        }
        if(this.chiusoAl && this.chiusoAl <new Date()){
            this.chiusoAl = ""
            this.showError = true;
            return false;
        }
        if(this.chiusoDal && this.chiusoAl && this.chiusoDal > this.chiusoAl){
            this.chiusoAl = "";
            this.chiusoDal = "";
            this.showError=true;
            return false;
        }
        if(!this.chiusoAl || !this.chiusoDal){
            this.showError = true;
            return false;
        }
        return true;
    }
    changeData = (e) => {
        if (!e.target && !e.currentTarget) return;

        let target = e.target || e.currentTarget;
        this.chiusoDal = target.value;

        if(this.validateDate()) {
            this.showError=false;
        }
    }
  

    changeData2 = (e) => {
        if (!e.target && !e.currentTarget) return;

        let target = e.target || e.currentTarget;
        this.chiusoAl = target.value;
        if(this.validateDate()) this.showError=false;
    }

    keydown = (e) => {
        return;
    }
    connectedCallback() {
		super.connectedCallback();
        
    }
    renderedCallback(){
        this.root= this.template.querySelector('table')
    }
    closeModal(){
        this.closeCallback() ;
    }
    primary(){
        if(!this.showError )
        this.primaryCallback({chiusoAl: this.chiusoAl, chiusoDal : this.chiusoDal}); 
    }
    backCallback(){
        this.backCallback();
    }

}