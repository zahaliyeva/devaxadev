import { MobilityAbstract } from 'c/mobilityAbstract';
import { PostMessage } from 'c/postMessage';
import InitSingoloEcollaboration from '@salesforce/apex/mobilitySinglePushController.InitSingoloEcollaboration';
import createCommunicationsingle from '@salesforce/apex/mobilitySinglePushController.createCommunicationsingle';

export default class MobilityCertificaDAC extends MobilityAbstract {

    //preview Iniziativa
    iniziativaScelta;
    showIniziativaDetail; 
    title;
    description;
    iframeUrl;
    previewEmail;
    previewShortMessage;
    previewMessage;
    //set messaggio inviato
    showConfirmation;
    showModalSecond;
    modalType;
    primary;

    connectedCallback(){
        super.connectedCallback();
        this.showSpinner();
        //this.loadFilters();
        this.init();
    }

    async init(){

        var ndgid = this.params.ndgId;

        if(ndgid && ndgid !='undefined'){
            let respSingle = await InitSingoloEcollaboration({
                ndgid: ndgid
                });
                if(respSingle.isSuccess){
                    console.log('isSuccess per '+ndgid);
                    this.iniziativaScelta = respSingle.iniziative[0];
                    this.accountCliente = respSingle.AccountCliente;
                    this.initFieldsIniziativa();

                }else{
                    if(respSingle.visibility){
                        console.log('ERROR CRM TECH-'+respSingle.errorMessage);
                        this.showModalSecondary('ModalErroreTecnicoSingle');
                    }else{
                        this.showModalSecondary('ModalAbilitazioneProfiloSingle');
                        console.log('ERROR CRM TECH-'+respSingle.errorMessage);
                    }
                }
        }else{
            console.log('ndgid non popolato da RGI');
            console.log(this.params.ndgId);
        }
        this.hideSpinner();
    }
    onProcedi = async () => {
        this.showSpinner();
        let response = await createCommunicationsingle({
            AccountCliente: this.accountCliente ,
            iniziativaId: this.iniziativaScelta.Id
        }).catch((err) => {
            console.log('err', this.proxyData(err));
            this.showModalSecondary('ModalErroreTecnicoSingle');
        }).finally(() => {
            this.hideSpinner(); 
        });
        if(response.isSuccess){
            this.showModalSecondary('ModalConcludiInvioSingolo');
        }else{
            this.showModalSecondary('ModalErroreTecnicoSingle');
        }
        this.hideSpinner();
    }
    navigateSingleSumit() {
        this.showIniziativaDetail = false;
        this.showModalSecond = false;
        this.showConfirmation = true;
    }
    closePostMessage(){
        PostMessage.close_Modal();
    }
    showModalSecondary (modalType) {
        this.modalType = modalType ;
        this.showModalSecond = true;
        this.showIniziativaDetail = false;
        this.showConfirmation = false;
        //this.primary = this.navigateToHomepage();
    }
    initFieldsIniziativa(){
        if(this.iniziativaScelta){
        this.title = this.iniziativaScelta.Nome_Messaggio__c;
        this.description = this.iniziativaScelta.Descrizione_dell_iniziativa__c;
        this.iframeUrl=this.iniziativaScelta.TECH_URL_template_MC__c;
        this.previewEmail='Preview Email';
        this.previewShortMessage=this.iniziativaScelta.Short_Message__c;
        this.previewMessage=this.iniziativaScelta.Message__c;
        //show
        this.showIniziativaDetail = true;
        this.showModalSecond = false;
        this.showConfirmation = false;
        }else{
            this.showModalSecondary('ModalErroreTecnicoSingle');
            console.log('Iniziativa Mkt non trovata nel CRM controlare MPS_Code_Utils__mdt.PushFase2_Ecollab_CodeCom');
        }
    }
    showMainModal = () =>{
        this.showIniziativaDetail = true;
        this.showMessaggeSended = false;
        this.showConfirmation = false;
    }
}