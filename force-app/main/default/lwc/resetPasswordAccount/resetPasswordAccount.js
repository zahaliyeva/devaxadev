import { LightningElement, api, track } from 'lwc';
import { LghtAbstract } from 'c/lghtAbstract';
import { PostMessage } from 'c/postMessage';
import init from '@salesforce/apex/resetPasswordAccountCTRL.init';
import confirm from '@salesforce/apex/resetPasswordAccountCTRL.confirm';

export default class ResetPasswordAccount extends LghtAbstract {
    @api personId;
    @api params;
    @api origin = 'NFE' //set to TRUE only when you call this lwc for advisors
    @api closeMethod;
    
    errorMessage;
    
    mail = '';
    @track mailList;

    loaded;

    @track isSuccess = true;
    @track loaded = false;

    connectedCallback(){
        super.connectedCallback();
        this.postMessageConnect();
        this.showSpinner();
        if(this.params != null && this.params.personId){
            this.personId = this.params.personId;
        }
        this.initComp();
        
    }

    postMessageConnect() {
		if (!this.params || !this.params.id) return;
		//window.addEventListener("message", this.receiveMessage, false);

		PostMessage.hookRequest(this.params.id);
	}

    handleSelect (event){
        for(var button of this.template.querySelectorAll('button')){
            if(button.disabled)
                button.disabled = false;
        }
        this.mail = event.detail.value;
    }

    
    get message(){
        return this.errorMessage ? this.errorMessage : '';
   }
                                
    get showComp(){
        return this.isSuccess && this.loaded && this.mailList != null && this.mailList.length != 0;
    }

    get isInCRM(){
        return this.origin === 'CRM';
    }

    async initComp(){
        if(this.personId){
            var resp = await init({personId:this.personId});
            console.log(resp);
            if(!resp.isSuccess){
                this.isSuccess = false;
                this.errorMessage = resp.ErrorMessage;
                this.hideSpinner();
                this.loaded = true;
            }
            else{
                this.mailList = [];
                console.log(resp);
                if(resp.emailList != null){
                resp.emailList.forEach( (el) => {
                    var option = {label: el.email, value: el.email};
                    console.log(option);
                    this.mailList.push(option);
                }); 
            } 
            if(this.mailList.length == 0){
                    this.errorMessage = 'Attenzione: il cliente non risulta registrato all’Area Clienti';
                }
                this.hideSpinner();
                this.loaded = true;
            }
        }
        else {
            this.isSuccess = false;
            this.errorMessage = 'Attenzione: si è verificato un errore. Riprovare più tardi';
            this.hideSpinner();
            this.loaded = true;
        }
    }


    async handleConfirm(){
        this.showSpinner();
        var resp = await confirm({personId:this.personId, Email: this.mail});
        if(!resp.isSuccess){
            this.isSuccess = false;
            this.hideSpinner();
            this.mailList = null;
            this.errorMessage = 'Attenzione: si è verificato un errore. Riprovare più tardi'
        }
        else{
            
            this.hideSpinner();
            this.mailList = null;
            this.errorMessage = 'Mail inviata con successo a "' + this.mail + '". Attraverso il link sarà possibile scegliere la password ed accedere all\'Area Clienti. Per motivi di sicurezza il link sarà valido per 12 ore e utilizzabile un\'unica volta.' 
            //handle close with success message

        }
    }

    handleClose(){
        if(this.closeMethod){
            this.closeMethod();
        }
        else{
            PostMessage.close_Modal();
            //dispose component
        }
    }
}