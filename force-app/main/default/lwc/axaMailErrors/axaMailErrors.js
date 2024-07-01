import { LightningElement, api } from "lwc";
import axaResource from "@salesforce/resourceUrl/axaResource";

export default class AxaMailErrors extends LightningElement {
  @api errors = {};
  @api email;
  @api sms;

  get showEmail() {
    return !this.sms;
  }

  logo = axaResource + "/images/logo/axaLogo.png";

  get technicalError(){
    return this.errors.isMCRespOK && this.errors.isCIFRespOK && this.errors.isInCRM;
  }

  connectedCallback() {
    if (!!this.email && !!this.sms) {
      throw new Error(`you can't have email and sms at the same time`);
    }
  }
}