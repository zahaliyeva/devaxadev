import { LightningElement, track, api } from 'lwc';
import { LghtAbstract } from 'c/lghtAbstract';
import initComponent from '@salesforce/apex/LghtCaseActionsController.sendSMSInit';
import sendSMS from '@salesforce/apex/LghtCaseActionsController.sendSMS';

import VFP17_Mobile_Selection from "@salesforce/label/c.VFP17_Mobile_Selection"; 
import VFP17_Template_Selection from "@salesforce/label/c.VFP17_Template_Selection"; 
import VFP17_Message_Content from "@salesforce/label/c.VFP17_Message_Content"; 
import VFP17_Send_SMS from "@salesforce/label/c.VFP17_Send_SMS";
import VFP17_No_Mobile from "@salesforce/label/c.VFP17_No_Mobile";
import VFP17_Content_Missing from "@salesforce/label/c.VFP17_Content_Missing";
import VFP17_SMS_Sent from "@salesforce/label/c.VFP17_SMS_Sent";
import VFP17_SMS_Not_Sent from "@salesforce/label/c.VFP17_SMS_Not_Sent"; 

export default class LghtCaseSendSms  extends LghtAbstract {

	@api caseData;
	@api closeCallback;
	@track listViewsMobilePhone;
	@track listViewsTemplate;
	
	componentView = 'LghtCaseSendSms';
	
	 // Expose the labels to use in the template.
	 label = {
        VFP17_Mobile_Selection,
		VFP17_Template_Selection,
		VFP17_Message_Content,
		VFP17_Send_SMS
    };

    connectedCallback() {
		super.connectedCallback();
		this.loadData();
	}

	loadData(){
		console.log('loadData');

		this.showSpinner();
		initComponent({	
			UrlParameterMap:{
		   'CaseId':this.caseData.Id,
		   'CustomerId': this.caseData.AccountId
			}	
		 
		}).then((result)=>{
			if (result.isSuccess) {
				console.log('result ', result);
				this.listViewsMobilePhone = result.values.ListMobileNumbers;
				this.listViewsTemplate= result.values.ListTemplates;	

				if(this.listViewsMobilePhone.length <= 0 ){				
					this.alertMessage(VFP17_No_Mobile);
				   if(this.closeCallback) this.closeCallback(this);
			     } 
			} else {		
				console.log('result ', result);
				this.alertMessage(VFP17_No_Mobile);
			} 
						
		}).finally(()=>{
			this.hideSpinner();
		})

	}

    onConfirm (){
		this.showSpinner();
		const phone= this.template.querySelector('[data-id="select-phone-send-sms"]').value;
		const template = this.template.querySelector('[data-id="select-template-send-sms"]').value;
		const bodyMessage = this.template.querySelector('[data-id="body-message-send-sms"]').value;
	
		if(typeof template =='undefined' || template ==''){
			this.alertMessage(VFP17_Template_Selection);
			this.hideSpinner();
		}
			
		if(typeof bodyMessage =='undefined' || bodyMessage ==''){
			this.alertMessage(VFP17_Content_Missing);	
			this.hideSpinner();
		}
			

	
	if((typeof template !='undefined' && template !='') && (typeof bodyMessage !='undefined' && bodyMessage !='') )
	{
		sendSMS({	
			'MessageContent': bodyMessage,
			'CaseId': this.caseData.Id,
			'SelectedTemplateId':template,
			'CustomerId' : this.caseData.AccountId,
			'MobileNumber': phone		 
		}).then((result)=>{
			if (result.isSuccess)
			this.successMessage(VFP17_SMS_Sent);
			else 
			this.alertMessage(VFP17_SMS_Not_Sent);			
				
			if(this.closeCallback) this.closeCallback(this);
		}).finally(()=>{
			this.hideSpinner();
		})
	}

	}
	
}