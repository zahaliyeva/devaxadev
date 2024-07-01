import { LightningElement, api, track } from 'lwc';
import GetUrlFromRecordId from '@salesforce/apex/lghtIFrameForCustomURLCTRL.GetUrlFromRecordId';

export default class LghtIFrameForCustomURL extends LightningElement {
    @api recordId;
    @track UrlFromApex

    connectedCallback(){
       //console.debug('record id '+recordId)
       GetUrlFromRecordId({
        RecordId : this.recordId,
    })
    .then(Url => {
        this.UrlFromApex = Url;
    })

    }
    

}