import { api, track } from 'lwc';
import {
	MobilityAbstract
} from 'c/mobilityAbstract';

export default class MobilityPushShowCampaignTemplate extends MobilityAbstract {
    @api title;
    @api description;
    @api url;
    @api urlTitle;
    @api previewTitle;
    @api previewMessage;
    
    get modalColumnClass() {
        return 'modal-column modal-column--preview'
    }

    get isPreviewPush(){
        return this.previewMessage && this.previewTitle;
    }
    get isIFrame(){
        return this.url;
    }
    connectedCallback(){
        super.connectedCallback();
        
    }

    
    
    /*
   if(!this.iframe ){
            this.iframe = this.template.querySelector('iframe');
            
            this.iframe.onload = () =>{
                if(this.firstLoad){
                    this.firstLoad = false;
                    var request = new XMLHtppRequest();
                    request.open("GET",this.url,true);
                    request.send(null);
                    request.onreadystatechange = function(){
                        if(request.readyState == 4)
                            this.iframe.src = request.responseText;
                    }
                    //this.iframe.src = this.getSrc();
                }
            }
        }
    */

}