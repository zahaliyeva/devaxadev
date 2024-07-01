import { LightningElement, api, track } from "lwc";
import axaResource from "@salesforce/resourceUrl/axaResource";

import Init from '@salesforce/apex/UnsubMainCTRL.Init';
import save from '@salesforce/apex/UnsubMainCTRL.save';

export default class AxaMailUnsubscribe extends LightningElement {
  @api recordId;
  @track errorState = {};
  @track firstName = "";
  @track privacy = {};
  initWrapper ={};
  @api token;
  @track spinner = true;
  @track spinnerOverlay = true;
  
  waitCallBack = true;
  showMainCard = true;
  showConfirmModifications = false;
  preferenceState = {};

  logo = axaResource + "/images/logo/axaLogo.png";
  inboxIcon = axaResource + "/images/inbox/72dpi_x1/inbox_blue_x1.png";
  heartIcon = axaResource + "/images/heart/72dpi_x1/heart_blue_x1.png";
  facebookIcon =
    axaResource +
    "/images/social_icons/facebook/72dpi_x1/facebook_blue_circle_x1.png";
  twitterIcon =
    axaResource +
    "/images/social_icons/twitter/72dpi_x1/twitter_blue_circle_x1.png";

  linkedInIcon =
    axaResource +
    "/images/social_icons/linkedin/72dpi_x1/linkedin_blue_circle_x1.png";
  youTubeIcon =
    axaResource +
    "/images/social_icons/youtube/72dpi_x1/youtube_blue_circle_x1.png";
  instagramIcon =
    axaResource +
    "/images/social_icons/instagram/72dpi_x1/instagram_blue_circle_x1.png";

  get showTotalUnsubscribe() {
    return !this.showMainCard && !this.showConfirmModifications;
  }

  get selectedPreferences() {
    return Object.keys(this.preferenceState).filter((key) => {
      return this.preferenceState[key];
    });
  }

  get withError() {
    return Object.values(this.errorState).some((error) => !error);
  }

  get name() {
    return !!this.firstName ? this.firstName : "cliente";
  }

  renderedCallback() {
    this.evaluatePreferences();
  }

  connectedCallback() {
    /*this.errorState = {
      technicalError: false,
      linkExpired: false,
      changedPreferences: false,
      wrongRecipient: false
    };*/



    Init({tokenToReq : this.token, isUnsub: true})
    .then((result) => {
      this.spinner = false;
      this.errorState = result.errors;
      this.initWrapper = result;
      console.log(result);
      this.waitCallBack = false;
      this.privacy = result.valuesFromCIF;
      if(result.valuesFromMC)
        this.firstName = result.valuesFromMC.firstname;
    });
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
  }

  evaluatePreferences(){
    this.template.querySelectorAll(".options").forEach((option) => {
      console.log(option);
      this.preferenceState[option.value] = option.checked;
    });
  }

  handleSelection({ target: { value, checked } }) {
    if (value === "Nessuna delle precedenti") {
      if (checked) {
        this.cleanSelections();
        return;
      }
    } else {
      this.template.querySelector(".disabledOption").checked = false;
      this.preferenceState["Nessuna delle precedenti"] = false;
      this.initWrapper.editedFieldsMap[value] = checked;
      switch(value){
        case 'Comunicazioni informative':
          this.privacy.Privacy1 = checked;
          break;
        case 'Comunicazioni promozionali':
          this.privacy.Privacy2 = checked;
          break;
        case 'Ricerche di Mercato':
          this.privacy.Privacy3 = checked;
          break;
        
         
      }
    }
    this.preferenceState[value] = checked;
    //console.log(id);
    
    
    console.log(this.preferenceState);
  }

  cleanSelections() {
    Object.keys(this.preferenceState).forEach(
      (key) => (this.preferenceState[key] = false)
    );
    this.privacy.Privacy1 = false;
    this.privacy.Privacy2 = false;
    this.privacy.Privacy3 = false;
    this.template
      .querySelectorAll(".options")
      .forEach((option) => {
        if(option.checked){
          option.checked = false;
          this.initWrapper.editedFieldsMap[option.value] = option.checked;
        }
          
      });
     
  }

  handleConfirmPreferences() {

    
      console.log("test 1: ", this.initWrapper);
      console.log(save);
      this.spinner = true;
      save({i : JSON.stringify(this.initWrapper)}).then((result) => {
        console.log('Test');
        this.spinner = false;
        if(result === 'Success'){
          this.showConfirmModifications = (Object.values(this.preferenceState).some((checked) => checked)) ? true:false ;
        this.showMainCard = false;
        console.log(result);
          
        }
        else{
          this.errorState.isCIFRespOK = false;
        }
      });
      
    
  }
}