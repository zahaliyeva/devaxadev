import { LightningElement, api, track } from "lwc";
import STATIC_RESOURCE from "@salesforce/resourceUrl/axaResource";
import Init from '@salesforce/apex/UnsubMainCTRL.Init';
import save from '@salesforce/apex/UnsubMainCTRL.createCase';

export default class AxaMailWrongRecipient extends LightningElement {
  @api recordId;
  @track errorState = {};
  @track waitCallBack = true;

  initWrapper ={};
  @api token;
  @track spinner = true;
  @track spinnerOverlay = true;

  showConfirm = true;
  showSuccessConfirm = false;
  email = "";
  sms = "";

  logo = STATIC_RESOURCE + "/images/logo/axaLogo.png";
  inboxIcon = STATIC_RESOURCE + "/images/inbox/72dpi_x1/inbox_blue_x1.png";
  tickIcon = STATIC_RESOURCE + "/images/tick/72dpi_x1/tick_blue_circle_x1.png";

  get withError() {
    return Object.values(this.errorState).some((error) => !error);
  }

  get showEmail() {
    return !this.sms;
  }

  connectedCallback() {
    
    // TODO: callback backend load data flow
    /**
         * {
                "isInCRM":BOOLEAN, --technicalError
                "isDateValid":BOOLEAN, --link caducado
                "isMCRespOK":BOOLEAN,
                "isCIFRespOK":BOOLEAN,
                "isTokenNew":BOOLEAN,
                "valuesFromMC":{
                    "ndg":STRING,
                    "accountid":STRING,
                    "expirationdate":STRING,
                    "emailaddress":STRING,
                    "firstname":STRING,
                    "mobilephone":STRING
                }
            }
         */
    Init({tokenToReq : this.token, isUnsub: false})
    .then((result) => {
      this.spinner = false;
      if(result.valuesFromMC){
        if(result.valuesFromMC.channel === 'Email')
          this.email = result.valuesFromMC.emailaddress;
        else
          this.sms = result.valuesFromMC.mobilephone;
    }
      this.errorState = result.errors;
      this.initWrapper = result;
      console.log(result);
      this.waitCallBack = false;
      //this.privacy = result.valuesFromCIF;
      
      
    });

    
  }

  handleConfirm() {
    //TODO: send backend method values
    //if{error} => error, else then
    //TYP destinatario equivocado -> apertura case a los agentes + notificacion
    this.spinner = true;
    save({i : JSON.stringify(this.initWrapper)}).then(result => {
      this.spinner = false;
      if(result === 'SUCCESS'){
    this.showSuccessConfirm = true; //show second step (flow)
    this.showConfirm = false;
      }
      else{
        this.errorState.isCIFRespOK = false;
      }
    });
    
  }
}