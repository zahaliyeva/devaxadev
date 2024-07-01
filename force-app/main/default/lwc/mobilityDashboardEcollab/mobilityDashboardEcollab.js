import { LightningElement, api, track ,wire} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import {
	MobilityAbstract
} from 'c/mobilityAbstract';

export default class MobilityDashboardCollab extends MobilityAbstract {
    
    @api label;
    @api componentName;
    @api colorelab;
    @api font;
    @api fontdim;
    @api iddash;
    @api fontstyle;
    @api nomeDas;

   
    
    renderedCallback(){
        if(this.label){
        this.template.querySelector("span").style.color=this.colorelab;
        this.template.querySelector("span").style.fontSize=(this.fontdim+'px');
        this.template.querySelector("span").style.fontFamily=this.font;
        this.template.querySelector("span").style.fontWeight=this.fontstyle;
}
this.params = {"Id": "MobilityDashboardEcollab",
                "dashboardId":'0FK080000000BcjGAE'}
}
clickHandler(){
    this.navigateTo({
        name: this.componentName,
        dashboardId : this.iddash,
        nomeDas : this.nomeDas,
        params : this.params
    })
}

}