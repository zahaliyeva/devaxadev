import { LightningElement, api, track } from 'lwc';
import { MobilityAbstract } from 'c/mobilityAbstract';
import getConfiguration from '@salesforce/apex/mobilityDashboardPaginationController.getConfiguration';

export default class MobilityDashboardPagination extends MobilityAbstract {

    @api results;
    @api type;

    @track allData;
    waitCallback = true;


    connectedCallback(){
        this.showSpinner();
        this.init();
    }

    async init(){
        
        let confResult = await getConfiguration(); //call apex to get configuration
        this.allData = [];
        if(confResult){

            for(let record of this.results){
                this.allData.push(this.configureRecord(record, confResult));
            }
                
        }
        this.waitCallback = false;
        this.hideSpinner();
        
    }


    configureRecord(record, configuration){
        let toRet = {};
        console.log("conf: ", configuration);
        console.log("record: ", record);
        toRet["Name"] = record[configuration.cardName];
        toRet["Description"] = record[configuration.cardDescription];
        toRet["Actions"] = [];
        /*for(let action of configuration.cardActions){
            let defineAction = {};
            toRet["Actions"].push(defineAction);
        }*/
        return toRet;
    }

}