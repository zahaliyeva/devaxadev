import { LightningElement, api } from 'lwc';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import deploymentUrl from '@salesforce/resourceUrl/deployment'

export default class LiveAgentChatButtonLWC extends LightningElement {
    @api organizationId;
    @api deploymentUrl;
    @api endpoint;
    @api deploymentId;
    @api chatButtonId;
    @api textOnline = "Chat Now";
    @api textOffline = "Chat Unavailable";
    @api isInvalidInput;
    userSessionData = true;
    @api previousIsLiveAgentOnline;
    @api isLiveAgentOnline = false;
    @api newCase = null;
    @api agentName;
    @api isPressed = false;
    @api isOnOffEvaluationExecuted = false;
    liveagent;
    liveAgentDeployment;
    liveAgentInitiated = false;

    connectedCallback() {
        /*loadScript(this, deploymentUrl)
        .then( () => {
            this.liveagent =  liveagent;
            this.liveAgentDeployment = liveAgentDeployment;
            this.init();
        })*/
        this.init();
        
    }


    @api
    setValues(Subject, Description, Targa, Cliente, Polizza) {
        this.executeSetValues({
            detail: {
                name: "setValues",

                arguments: {
                    Subject: Subject,
                    Description: Description,
                    Targa: Targa,
                    Cliente: Cliente,
                    Polizza: Polizza
                }
            }
        });
    }


    @api
    async init() {
        
        if(this.liveagent) {
            this.liveAgentDisconnect();
        }

        await loadScript(this, deploymentUrl)
        this.liveagent = liveagent;
        this.liveAgentDeployment = liveAgentDeployment
        var isValid = this.validateComponent();
        

        this.isInvalidInput = !isValid;
        if ( isValid ){
            this.liveAgentStart();
            
            let chatBtn = this.chatButtonId+'';
            //adding this.liveagent buttons wo global array
            window._laq = []; 
            window._laq.push( () => {
                let btONline = this.template?.querySelector('[data-id="btonline"]')
                let btOFFline = this.template?.querySelector('[data-id="btoffline"]')
                this.liveagent.showWhenOnline(
                    ((chatBtn) => { return chatBtn; })(chatBtn)
                    , btONline);
                this.liveagent.showWhenOffline(
                    ( (chatBtn) => { return chatBtn; })(chatBtn)
                    , btOFFline);
            });
        }
        
        
    
    }

    liveAgentDisconnect() {
        if(this.liveAgentInitiated) {
            this.liveagent.disconnect();
            this.liveAgentInitiated = false;
            window._laq = null;
            this.template.querySelector('[data-id="btinitial"]').classList.remove('toggle'); 
            this.template.querySelector('[data-id="btoffline"]').classList.add('toggle'); 
            this.template.querySelector('[data-id="btonline"]').classList.add('toggle');
            //this.liveagent = null;
            delete this.liveagent;
            delete this.liveAgentDeployment;
            this.liveagent = null;
            this.liveAgentDeployment = null;
        }
    }

    liveAgentStart(){
        //timeout to initiate this.liveagent
        setTimeout( () => {
                let data = {};
                data.LA_chatServerURL =this.endpoint;
                data.LA_deploymentId =this.deploymentId;
                data.organizationId =this.organizationId;
                data.chatButtonId =this.chatButtonId;
                data.userSessionData =this.userSessionData;
                if (this.newCase != null){
                    data.Agentid =this.newCase.User__c;
                    data.Category=this.newCase.Category__c?.replaceAll('_', ' ');
                    data.SubCategory=this.newCase.SubCategory__c?.replaceAll('_', ' ');
                    data.Subject=this.newCase.Subject;
                    data.Description=this.newCase.Description;
                    data.Lob=this.newCase.LOB__c?.replaceAll('_', ' ');
                    data.RecType=this.newCase.RecordTypeId;
                    data.Cliente=this.newCase.AccountId;
                    data.Targa=this.newCase.Targa__c;
                    data.Polizza=this.newCase.InsurancePolicy__c;
                    data.AgencyCode=this.newCase.Agency_Code__c
                }
                    let onlineButton = this.template.querySelector('[data-id="btonline"]')
                    
                    if ((typeof this.liveagent == "object") && (onlineButton != null )){
                        this.bindLiveAgent(data);
                    }else{
                        console.log('CTRL  timeout to init live agent');
                    }
                //},500, data);
            }, 100
        );
    }


    startchat() {
        var myEvent = new CustomEvent("livechatbuttonpressevent", {
            detail: {"isPressed": true}
        });

        this.dispatchEvent(myEvent);
        this.isPressed = true;
        this.liveagent.startChat(this.chatButtonId);

        //var onlineBtn = document.getElementById('btONline');
        //var btPressed = document.getElementById('btPressed');
        this.template.querySelector('[data-id="btpressed"]').classList.remove('toggle'); 
        this.template.querySelector('[data-id="btonline"]').classList.add('toggle'); 

        //btPressed?.classList?.remove("toggle");
        //onlineBtn?.classList?.add("toggle");
    }

    executeSetValues(event) {
        console.log('@@executeSetValues@@');
        var params = event.detail.arguments;
        
        this.newCase.Subject = params.Subject;
        this.newCase.Description = params.Description;
        this.newCase.Targa__c = params.Targa;
        this.newCase.AccountId = params.Cliente;
        this.newCase.InsurancePolicy__c = params.Polizza;
        console.log('@Cliente@: ',params.Cliente);
    }



    validateComponent() {
        var valid = true;
        
        valid =  ( this.chatButtonId != undefined && this.chatButtonId != '') && 
        ( ( this.endpoint != undefined && this.endpoint != '')
        || ( this.deploymentId != undefined && this.deploymentId != '')
        || ( this.deploymentUrl != undefined && this.deploymentUrl != '')
        || ( this.organizationId != undefined && this.organizationId != '') );

        return valid;
    }

    bindLiveAgent(data) {
        //custom handler for online/offline update     
        this.isLiveAgentOnline = false;
        let chatBtn    = data.chatButtonId;
        console.log('@@chatBtn: '+chatBtn);
        

        this.liveagent.addButtonEventHandler(chatBtn, (e) => {
            console.log(e);
            if (e == this.liveagent.BUTTON_EVENT.BUTTON_AVAILABLE) {
                this.isLiveAgentOnline = true;
            } else if (e == this.liveagent.BUTTON_EVENT.BUTTON_UNAVAILABLE) {
                this.isLiveAgentOnline = false;
            }
            if (this.previousIsLiveAgentOnline == null){
                this.previousIsLiveAgentOnline = false;
            }else {
                this.previousIsLiveAgentOnline = this.isLiveAgentOnline;
            }
            
            
            this.updateLiveAgentButton();
        });
        
      
        if (this.userSessionData){
            this.liveagent.addCustomDetail('Case Origin', 'Chat',false);

            this.liveagent.addCustomDetail('Case Status', 'Assigned', false);

            this.liveagent.addCustomDetail('Chiamante', 'Agente',false);

        
            if(data.Subject!=undefined)
            {
            	this.liveagent.addCustomDetail('Oggetto', data.Subject);
            }
            else
            {
				this.liveagent.addCustomDetail('Oggetto', '');	                    
            }
        
            if(data.Description!=undefined)
            {
            	this.liveagent.addCustomDetail('Descrizione', data.Description);
            }
            else
            {
				this.liveagent.addCustomDetail('Descrizione', '',false);	                    
            } 
        
            if(data.Cliente!=undefined)
            {
                this.liveagent.addCustomDetail('Cliente', data.Cliente);
            }
            else
            {
                this.liveagent.addCustomDetail('Cliente', '',false);
            }
        
            if(data.Targa!=undefined)
            {
                this.liveagent.addCustomDetail('Targa', data.Targa);
            }
            else
            {
                this.liveagent.addCustomDetail('Targa', '',false);
            }
        
            if(data.Polizza!=undefined)
            {
                this.liveagent.addCustomDetail('Polizza', data.Polizza);
            }
            else
            {
                this.liveagent.addCustomDetail('Polizza', '',false);
            }
            
            if(data.Lob) {
                this.liveagent.addCustomDetail('Lob', data.Lob);
            }

            if(data.Category) {
                this.liveagent.addCustomDetail('Categoria', data.Category);
            }

            if(data.SubCategory) {
                this.liveagent.addCustomDetail('SottoCategoria', data.SubCategory);
            }
            if(data.RecType) {
                this.liveagent.addCustomDetail('TipoCase', data.RecType);
            }
            if(data.Agentid) {
                this.liveagent.addCustomDetail('Agente',data.Agentid);
            }
            if(data.AgencyCode) {
                this.liveagent.addCustomDetail('Agenzia',data.AgencyCode);
            }

            this.liveagent.addCustomDetail('Distribution','Axa Assicurazioni');
			this.liveagent.findOrCreate('Case').map('Agency_Code__c','Agenzia',false,false,true).map('Internal_LOB__c','Lob',false,false,true).map('Internal_Category__c','Categoria',false,false,true).map('Internal_SubCategory__c','SottoCategoria',false,false,true).map('InsurancePolicy__c','Polizza',false,false,true).map('AccountId','Cliente',false,false,true).map('Targa__c','Targa',false,false,true).map('Description','Descrizione',false,false,true).map('LOB__c','Lob',false,false,true).map('Distribution_Network__c','Distribution',false,false,true).map('Oggetto_Apertura_Case__c','Oggetto',false,false,true).map('Category__c','Categoria',false,false,true).map('SubCategory__c','SottoCategoria',false,false,true).map('RecordTypeId','TipoCase',false,false,true).map('Complainant__c','Chiamante',false,false,true).map('Status', 'Case Status', false, false, true).map('Origin', 'Case Origin', false, false, true).map('User__c', 'Agente', false, false, true).showOnCreate().saveToTranscript('CaseId');
            //set the visitor's name to the value of the contact's first and last name
            this.liveagent.setChatWindowHeight(538);
			this.liveagent.setChatWindowWidth(490);
            console.log(this.agentName);
            this.liveagent.setName(this.agentName);
            
        }
           
            
        this.liveagent.init( data.LA_chatServerURL, data.LA_deploymentId,  data.organizationId);
        this.liveAgentInitiated = true
       
    }

    updateLiveAgentButton() {
        console.log('agent online: '+this.isLiveAgentOnline);
        let onlineBtn = this.template.querySelector('[data-id="btonline"]')
        let offlineBtn = this.template.querySelector('[data-id="btoffline"]')
        
        if( onlineBtn  && offlineBtn ) {
            if ( this.isLiveAgentOnline){
                this.template.querySelector('[data-id="btinitial"]').classList.add('toggle'); 
                this.template.querySelector('[data-id="btoffline"]').classList.add('toggle'); 
                this.template.querySelector('[data-id="btonline"]').classList.remove('toggle');
                
            }else{                       
                this.template.querySelector('[data-id="btonline"]').classList.add('toggle'); 
                this.template.querySelector('[data-id="btinitial"]').classList.add('toggle'); 
                this.template.querySelector('[data-id="btoffline"]').classList.remove('toggle');
            }
        }
        
    }
}