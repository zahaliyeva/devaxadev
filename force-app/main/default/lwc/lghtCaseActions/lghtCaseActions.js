import { track, api, LightningElement } from 'lwc';

import { LghtAbstract } from 'c/lghtAbstract';
import { NavigationMixin } from 'lightning/navigation';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';

import getCase from '@salesforce/apex/LghtCaseActionsController.getCase';
import takeOver from '@salesforce/apex/LghtCaseActionsController.takeOver';
import backToQueue from '@salesforce/apex/LghtCaseActionsController.backToQueue';
import setPraticaDocumentale from '@salesforce/apex/SelfQAdVWizardController.setPraticaDocumentale';
import reopen from '@salesforce/apex/LghtCaseActionsController.reopen';
import UserId from '@salesforce/user/Id';

import SummaryPageUrl from "@salesforce/label/c.SummaryPageUrl";
import MakeAppointmentUrl from "@salesforce/label/c.MakeAppointmentUrl";
import ShowDocumentsUrl from "@salesforce/label/c.ShowDocumentsUrl"; 
import Not_ShowDocuments from "@salesforce/label/c.Not_ShowDocuments"; 
import warning_title from "@salesforce/label/c.warning_title"; 
import Take_Charge_Case from "@salesforce/label/c.Take_Charge_Case"; 
import NoAccountAssociated from "@salesforce/label/c.NoAccountAssociated"; 

export default class LghtCaseActions extends LghtAbstract {

	@api recordId;
	@api sObjectName;
	@api debugMode;

	@track url;
	@track case;
	@track survey;
	@track visibilities = {};
	
	qadvConfirmModalTest = "ATTENZIONE! Se si preme il pulsante conferma il case diventera' una pratica documentale e non sara' piu' possibile tornare indietro. Continuare?";

	connectedCallback(){
		super.connectedCallback();
		this.loadData();
    }

    get caseData(){
    	return this.case;
    }

    get caseRecordTypeId(){
    	return this.case.RecordType.Id;
    }

    loadData(){
    	getCase({recordId: this.recordId}).then((result)=>{
    		console.log('result', result);

    		this.case = result.caseData;
    		this.survey = result.survey;
    		
    		const visibilities = result.visibities;
    		const recordType = result.caseData.RecordTypeId;

    		if(visibilities && visibilities[recordType]){
    			const visibilitiesResult = visibilities[recordType];

    			let newVisibilies = {};
    			for(let index in visibilitiesResult){
    				let value = visibilitiesResult[index];

    				newVisibilies[value] = true;
    			}

    			this.visibilities = {...newVisibilies}
    		}

    		this.invokeEvent('init', result);
    		this.hideSpinner();
    	})
    }

    setVisibility = (componentName, visibily) => {
    	const visibilityEvent = new CustomEvent('visibilities', {
    		detail: {
    			componentName,
    			visibily
    		},
    	});

    	console.log('visibilityEvent', visibilityEvent);
    	
    	this.dispatchEvent(visibilityEvent); 

    	this.visibilities = {...this.visibilities, [componentName]: visibily};
    }

    onNewCommentAndAttachment(){
		if (this.case.OwnerId==UserId){
			this.setVisibility('NewCommentAndAttachmentLightning', true);
		}else{
			this.alertMessage(warning_title, Take_Charge_Case);
		}
    }

	onFindAssociateAccount(){
		if (this.case.OwnerId==UserId)
		  this.setVisibility('lghtCaseFindAssociateCustomer', true);
		else
		  this.alertMessage(warning_title, Take_Charge_Case);
		
	}

	onFindAssociateAccountClose = () => {
		this.setVisibility('lghtCaseFindAssociateCustomer', false);
		this.loadData();
		this.refreshView();
	}
 
	onFindAssociateManager(){
		this.setVisibility('lghtCaseFindAssociateManager', true);
	}

	onFindAssociateManagerClose = () => {
		this.setVisibility('lghtCaseFindAssociateManager', false);
		this.loadData();
		this.refreshView();
	}
	
	onFindAssociateAgent(){	
	if (this.case.OwnerId==UserId)
		this.setVisibility('lghtCaseFindAssociateAgent', true);
	  else
		this.alertMessage(warning_title, Take_Charge_Case);		
	}

	onFindAssociateAgentClose = () => {
		this.setVisibility('lghtCaseFindAssociateAgent', false);
		this.loadData();
		this.refreshView();
	}

	onFindAssociatePolicy(){
	if (this.case.OwnerId==UserId){
		this.navigateToVFPage({
			page: 'VFP11_CaseFindAssociatedPolicy',
			params: {
				id: this.recordId,
				Account: this.case.AccountId
			}
		});
	  } 
	  else
	     this.alertMessage(warning_title, Take_Charge_Case);
	}

	onSurvey(){
	if (this.case.OwnerId==UserId){
		this.navigateToVFPage({
			page: 'VFP30_NewQuestionarioCAI',
			params: {
				accountId: this.case.AccountId,
				caller: 'cliente',
				caseId: this.case.Id
			}
		});
	 }
	 else
	   this.alertMessage(warning_title, Take_Charge_Case);
	}

	onCaseClose(){
		if (this.case.OwnerId==UserId){
			
				this.setVisibility('lghtCaseClose', true);
			
		}else{
			this.alertMessage(warning_title, Take_Charge_Case);
		}
    }

    onCaseCloseCallback = (data) => {
    	this.setVisibility('lghtCaseClose', false);

    	if(data && data.refresh){
	    	this.loadData();
	    	this.refreshView();
    	}
    }

	onNewCase(){
		this.navigateToComponent({
			component: 'lghtCaseManageAction'
		})
	}

	onNewCaseOld(){
		this.navigateToVFPage({
			page: 'LightningCaseEdit',
			params: {
				id: this.recordId,
				RecordType: '012240000008Z9bAAE',
				classicEdit: false,
				cas5: 'Sinistri'
			}
		})
	}

	onAllClaims(){
		this.setVisibility('GetAllClaims', true);
	}

	onTakeOver(){		
		this.showSpinner();
		takeOver({recordId: this.recordId}).then((result)=>{
			console.log('Assign', result);
			this.loadData();
			this.refreshView();
		}).finally(()=>{
			this.hideSpinner();
		})
	}

	onBackToQueue(){		
		this.showSpinner();
		backToQueue({recordId: this.recordId}).then((result)=>{
			if(!result.isSuccess){
				this.alertMessage(result.errorMessage);
			}
			this.loadData();
			this.refreshView();
		}).finally(()=>{
			this.hideSpinner();
		})
	}

	onCreateBooking(){		
		let temp = {
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'DHPBooking__c',
                actionName: 'new'                
            },
            state : {
                nooverride: '1',
                defaultFieldValues: encodeDefaultFieldValues({
					Case__c: this.recordId,
					Account__c: this.case.AccountId
				})
            }
        };
        this[NavigationMixin.Navigate](temp);
    }

	onReopen(){
	if (this.case.OwnerId==UserId){
		this.showSpinner();
		reopen({recordId: this.recordId}).then((result)=>{
			console.log('Reopen', result);
			if(!result.isSuccess) throw new Error(result.errorMessage);

			this.loadData();
			this.refreshView();
		}).catch((err)=>{
			this.alertMessage(err.message);
		}).finally(()=>{
			this.hideSpinner();
		})
	}else{
		this.alertMessage(warning_title, Take_Charge_Case);
	}
	}

	onProponiSoluzione(){
		if (this.case.OwnerId==UserId){
			this.setVisibility('lghtCaseProponiSoluzione', true);
		}else{
			this.alertMessage(warning_title, Take_Charge_Case);
		}
	}
	onFindAssociatePolicy(){
		if (this.case.OwnerId==UserId)
		    this.setVisibility('lghtCaseFindAssociatePolicy', true);
		else
			this.alertMessage(warning_title, Take_Charge_Case);
		
	}

	onFindAssociatePolicyClose = () => {
		if (this.case.OwnerId==UserId){
			this.setVisibility('lghtCaseFindAssociatePolicy', false);
			this.loadData();
			this.refreshView();
		}
		else
		  this.alertMessage(warning_title, Take_Charge_Case);
		
	
	}


	onSendEmail(){
		if (this.case.OwnerId==UserId)
		  this.setVisibility('lghtSendEmailManageModal', true);
		else
		  this.alertMessage(warning_title, Take_Charge_Case);
	}

	onSendEmailClose = () => {
		this.setVisibility('lghtSendEmailManageModal', false);
	}

	onSummaryPage(){
		window.open(SummaryPageUrl,'_blank');	
	}

	onMakeAppointment(){
	  if (this.case.OwnerId==UserId)
		window.open(MakeAppointmentUrl,'_blank');	
	  else
		  this.alertMessage(warning_title, Take_Charge_Case);
	}

	onShowDocuments(){	
		if(this.case.Document_Unique_ID__c === '' || typeof this.case.Document_Unique_ID__c === "undefined")
			this.alertMessage(Not_ShowDocuments);
		else		
			window.open(ShowDocumentsUrl+this.case.Document_Unique_ID__c,'_blank');	
	}

	onSendDocumentValidation(){
		if (this.case.OwnerId==UserId){
			this.setVisibility('SendDocumentValidationComponent', true);
		}else{
			this.alertMessage(warning_title, Take_Charge_Case);
		}		
	}
	 
	onSendSMS(){
	if (this.case.OwnerId==UserId){
		if(typeof this.case.AccountId =='undefined' || this.case.AccountId ==' ')
		   this.alertMessage(warning_title, NoAccountAssociated);
		else
		   this.setVisibility('lghtCaseSendSmsModal', true);	
	}
	else
    	this.alertMessage(warning_title, Take_Charge_Case);
	}
	
	onSendSMSClose = () => {
		this.setVisibility('lghtCaseSendSmsModal', false);
	}

	onSendWhatsappOutbound() {
		if(this.case.OwnerId!=UserId) {
			this.alertMessage(warning_title, Take_Charge_Case)
		} else if(this.case.Origin != 'Whatsapp' || !this.case.MessagingUser__c) {
			this.alertMessage(warning_title, 'Puoi mandare messaggi in uscita solo per Case originati da canale Whatsapp');
		} else {
			this.setVisibility('lghtSendWhatsappOutbound', true);
		}
	}

	onSendWhatsappOutboundCloseCallback = () => {
		this.setVisibility('lghtSendWhatsappOutbound', false);
	}

	onConfirmQAdV(){
		console.log(this.proxyData(this.case));
		if(!this.case.Pratica_Documentale__c){
			this.setVisibility('selfQAdVWizard', true);
		}
		else{
			var temp = {
				component : 'selfQAdVWizardTab',
				state : {
					c__recordId : this.recordId,
					c__caseData : JSON.stringify(this.caseData),
					c__caseRecordType : this.caseRecordTypeId
				}
			};
			this.navigateToComponent(temp);
		}

	}

	onQAdV = () => {
		//this.setVisibility('selfQAdVWizard', true);
		this.setVisibility('selfQAdVWizard', false);
		this.showSpinner();
		setPraticaDocumentale({CaseId:this.case.Id}).then( (result) => {
			
			this.loadData();
			this.hideSpinner();
			if(result){
		var temp = {
			component : 'selfQAdVWizardTab',
			state : {
				c__recordId : this.recordId,
				c__caseData : JSON.stringify(this.caseData),
				c__caseRecordType : this.caseRecordTypeId
			}

		};
		this.navigateToComponent(temp);
				
			}
			else{
				this.alertMessage('Errore', "Non � stato possibile procedere con l'operazione!");
			}
		} )
		
	}
	onselfQAdVWizardCloseCallback = () => {
		this.setVisibility('selfQAdVWizard', false);
	}
	onSendSMSCA(){
	console.log('Record Id', this.case.Id);
	console.log('Account Id', this.case.AccountId);
	if (this.case.OwnerId==UserId){
		if(typeof this.case.AccountId =='undefined' || this.case.AccountId ==' ')
			this.alertMessage(warning_title, NoAccountAssociated);
		else
			this.navigateToComponent({
				component: 'SendSMSCmpModal',
				state: {
					c__recordId : this.case.Id,
					c__accountId: this.case.AccountId
				}
			})
	}
	else
		this.alertMessage(warning_title, Take_Charge_Case);
	}

	onAccountEdit(){
		if (this.case.OwnerId==UserId){
		if(typeof this.case.AccountId =='undefined' || this.case.AccountId ==' ')
		   this.alertMessage(warning_title, NoAccountAssociated);
		
		else{
		/*this.navigateToVFPage({
			page: 'LightningAccountEdit',
			params: {
				id: this.case.AccountId,
				CaseId: this.recordId,
				retUrl: this.recordId
			}
		})*/
		this.navigateToComponent({
			component: 'LightningAccountEdit',
			state: {
				c__recordId : this.case.AccountId,
				c__CaseId : this.recordId,
				c__retUrl: this.recordId
			}
		})
		}
	}
	else
	 this.alertMessage(warning_title, NoAccountAssociated);
		
	}

	onTest(){
		// this.navigateToLwc({
		// 	component: 'lghtCaseFindAssociate',
		// 	state: {
		// 		recordId: this.recordId,
		// 		type: 'customer',
		// 		CaseRecordType: this.case.RecordType.Id
		// 	}
		// })
		this.navigateToVFPage({
			page: 'LghtClientCallProcessing',
			params: {
				PhonecallID: "59.3722193",
				CallDateTime: "2020-03-13+10%3A57%3A0",
				Custlastn: "Jean Paul",
				RecordType: "Terze_Parti",
				PhoneCallIDB: "59.3722198",
				Phone: '0039377121212',
				LOB: "Sinistri Salute",
				Caller: "Dealer",
				Agentcode:"002901",
				Fiscalcode: "SNCJPL90M15Z605",
				Distribution: "MP",
			}

		})
	}

	//18112023 - Nikolas Capalbo START
	onSendSmsHallmarksCloseCallback = () => {
        this.setVisibility('lghtCaseSubFlow', false);
    }
 
    onSendSMSIP(){
        if (this.case.OwnerId==UserId){
            if(typeof this.case.AccountId =='undefined' || this.case.AccountId ==' '){
            	this.alertMessage(warning_title, NoAccountAssociated);
			}
            else
				this.setVisibility('lghtCaseSubFlow', true);
        }
        else
            this.alertMessage(warning_title, Take_Charge_Case);
    }
	//18112023 - Nikolas Capalbo STOP

 
    //27112023 - Salvatore Cirincione - START

	onNewSurveyIP(){
		if (this.case.OwnerId==UserId){
			   this.openNewSubTabHandler();	
		}
		else
			this.alertMessage(warning_title, Take_Charge_Case);
	}
 
    async openNewSubTabHandler() {
        let compDefination = {
            componentDef: "c:lghtFlowSubTab",
            attributes: {
                recordId: this.recordId,
                subFlowApiName: 'Crea_Questionario_IP'
            }
 
        }
        let compBase64 = btoa(JSON.stringify(compDefination));
        let foucedTabInfo = await this.invokeWorkspaceAPI('getFocusedTabInfo');
        await this.invokeWorkspaceAPI('openSubtab', {
            label: 'Crea Questionario IP',
            icon: 'standard:incident',
            parentTabId: foucedTabInfo.tabId,
            url: `#${compBase64}`,
            focus: true
        })
    }
 
    invokeWorkspaceAPI(methodName, methodArgs) {
        return new Promise((resolve, reject) => {
            const apiEvent = new CustomEvent("internalapievent", {
                bubbles: true,
                composed: true,
                cancelable: false,
                detail: {
                    category: "workspaceAPI",
                    methodName: methodName,
                    methodArgs: methodArgs,
                    callback: (err, response) => {
                        if (err) {
                            return reject(err);
                        } else {
                            return resolve(response);
                        }
                    }
                }
            });
 
            this.dispatchEvent(apiEvent);
        });
    }
 
    //27112023 - Salvatore Cirincione - STOP

}