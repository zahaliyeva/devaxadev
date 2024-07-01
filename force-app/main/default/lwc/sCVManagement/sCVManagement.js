//standard import
import { LightningElement, api, track, wire } from 'lwc';
import { getRecord, getRecordNotifyChange } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';


//custom import
import init from "@salesforce/apex/lghtCreateCaseWithAttrCTRL.InitManagement";


export default class SCVManagement extends NavigationMixin(LightningElement) {


    @api recordId;
    @track resultInit;

    showError;
    initDone = false;
    connectedCallback() {
        //init with recordId
        this.initComponent();
    }

    async initComponent(){
        this.resultInit = await init({VCId: this.recordId});
        console.log(this.resultInit);
        this.initDone = true;
    }

    get showError(){
        return this.resultInit.needError;
    }

    get isAssistenzaAgenti(){
        return this.resultInit.IVR_Name === 'Assistenza Agenti';
    }

    get isGestore(){
        return this.resultInit.IVR_Name === 'Assistenza Gestori MPS';
    }

    get isClienti(){
        return !(this.isGestore || this.isAssistenzaAgenti);
    }
}