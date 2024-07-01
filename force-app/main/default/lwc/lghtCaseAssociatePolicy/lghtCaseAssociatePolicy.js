import { LightningElement, track, api } from 'lwc';
import { LghtAbstract } from 'c/lghtAbstract';
import getPolicies from '@salesforce/apex/LghtCaseFindAssociate.searchPolicies';
import associatePolicyToCase from '@salesforce/apex/LghtCaseFindAssociate.asociatePolicyToCase';

import VFP08_Successful from '@salesforce/label/c.VFP08_Successful';
import No_Policy_Found from '@salesforce/label/c.No_Policy_Found';

export default class LghtCaseAssociatePolicy extends LghtAbstract {

	@api caseData;
	@api closeCallback;
	@track policiesResult={};

	componentView = 'LghtCaseAssociatePolicy';

	get techCompany(){
		switch(this.policiesResult.listPolicyResult.TECH_Company__c) {
			case 'AAI':
			  return 'Axa Assicurazioni';
			  break;
			case 'MPS':
			  return 'AXA MPS';
			  break;
			case 'AMF':
			  return  'AMPS Financial';
			  break;
			default:
			  return this.policiesResult.listPolicyResult.TECH_Company__c;
		  }
	}

	connectedCallback() {
		super.connectedCallback();
		this.loadData();
	}

	
	loadData(){
		console.log('loadData');

		this.showSpinner();
		getPolicies({			
			params: {
				Account: this.caseData.AccountId,
				Policy: this.caseData.LinkToPolicy__c,
				PolicyAAF: this.caseData.Insurance_Policy_AAF__c
			}
		}).then((result)=>{
			if(result.listPolicyResult.length > 0 || result.listPolicyResultAAF.length > 0 )
				this.policiesResult = result;
		    else{
				this.alertMessage(No_Policy_Found);
				if(this.closeCallback) this.closeCallback(this);	
			}
			
		}).finally(()=>{
			this.hideSpinner();
		})
	}

	onAssociate  = (e) => {
		e.preventDefault();
		const selected = e.target.dataset.index;
        this.showSpinner();
		associatePolicyToCase({
			recordId: this.caseData.Id,
			index: selected,
			params:  this.policiesResult
			
		}).then((result)=>{
			console.log(result);
			if(!result.isSuccess) throw new Error(result.errorMessage);
			
			this.successMessage(VFP08_Successful);
			if(this.closeCallback) this.closeCallback(this);
		}).catch((err)=>{
			this.alertMessage(err.message);
		}).finally(()=>{
			this.hideSpinner();
		})

	}
	
}