import { LightningElement, api , track} from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import MobilityEngine from '@salesforce/resourceUrl/mobilityEngine';
import {
	MobilityAbstract
} from 'c/mobilityAbstract';

export default class MobilityCustomDetailPage extends MobilityAbstract {
    
    
    @api recordId;
    @api recordType;
    @api massiv_com_pfd_id;

    @track showFooter = false;

    customLayout;

/*renderedCallback() {
                Promise.all([
                    loadStyle(this, MobilityEngine + '/main.css')
                ]);
}*/

    connectedCallback(){
        super.connectedCallback();
        console.log('Eccomiii');
        this.recordId = this.params.recordId;
        this.recordType = this.params.recordType;
      /*
        var urlParams = new URLSearchParams(window.location.search);
        console.log(urlParams);
        if(urlParams.has('obj')){
            this.obj = urlParams.get('obj');
        }
        if(urlParams.has('chRecordId')){
            
            this.chRecordId = urlParams.get('chRecordId');
            console.log(this.chRecordId);
        }
        */
        if(this.params.recordType=='Massive_Communication__c'){    
            this.showFooter = true ;
           
         }
    }

    

    hookCustomLayout = (target) => {
		this.customLayout = target;
	}

	loadCallback = (result) => {
        if(this.params.recordType === 'Massive_Communication__c')
		{
            this.massiv_com_pfd_id = result.record.Id;
        }
	}

    get showDetail (){
        return this.recordId && this.recordType;
    }

    gotoURL = () => {
        if(this.massiv_com_pfd_id==''|| this.massiv_com_pfd_id=='undefined'){
            alert('PDF Non trovato, Visualizza documento Error');
        }else {
            let url_string = '../apex/VFP34_GetFilenetDocument?id=' + this.massiv_com_pfd_id + '';
            open(url_string);   
            console.log (url_string);
        }
	}
}