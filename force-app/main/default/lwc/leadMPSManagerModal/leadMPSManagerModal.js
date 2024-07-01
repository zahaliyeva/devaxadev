import { LightningElement, api, track } from 'lwc';
import { LghtAbstract } from 'c/lghtAbstract';
import RejectLead from '@salesforce/apex/LeadMPSManagement.RejectLead';
import SendToAgency from '@salesforce/apex/LeadMPSManagement.SendToAgency';

export default class LeadMPSManagerModal extends LghtAbstract{
    
    @api recordId;
    @api closeCallback;
    opened = true;
    lead = null;
    
    connectedCallback(){
        //alert('Prova');
        this.hideSpinner();
    }

    InviaAgenzia = () => {
        this.opened = false;
        console.log("ci provo");
        this.showSpinner();
        SendToAgency({LeadID : this.recordId}).then((response)=>{
            
            eval("$A.get('e.force:refreshView').fire();");
            this.hideSpinner();

            console.log("res: ", response);
            this.closeCallback();
        });
        //leadMPSToAgency(lead);
    }

    Rifiuta = () => {
        this.opened = false;
        this.showSpinner();
        RejectLead({LeadID : this.recordId}).then((response)=>{
            
            eval("$A.get('e.force:refreshView').fire();");
            this.hideSpinner();

            console.log("res: ", response);
            this.closeCallback();
        });;
    }
}