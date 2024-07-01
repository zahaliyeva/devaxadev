import { ModelCollection, Model } from 'c/lghtAbstractModel';

// Import custom labels
import VFP06_AAICustomer from '@salesforce/label/c.VFP06_AAICustomer';
import VFP06_Family_Protect from '@salesforce/label/c.VFP06_Family_Protect';
import VFP06_AMPSCustomer from '@salesforce/label/c.VFP06_AMPSCustomer';
import VFP06_AMFCustomer from '@salesforce/label/c.VFP06_AMFCustomer';

export class CaseAccountList extends ModelCollection {
	
	_childType() {
		return CaseAccount
	}

}

export class CaseAccount extends Model{

	_model(){
		return {
			FirstName: '',
			LastName: '',
			Fiscal_ID__c: '',
			Matricola__c: '',
			AAI_Codice_fiscale__c: '',
			Codice_Fiscale_AAF__c: '',
			PersonEmail: '',
			Additional_Email__c: '',
			NDG__c:'',
			AAI_Agency_Reference_Code__c : '',
			Agency_Code__c: '',

			Name: '',
			Partita_IVA__c: '',
			AAI_Partita_IVA__c: '',
			Account_email__c: '',
			TECH_Company__c: '',

			RecordType: {}
		}
	}

	get hasFiscalId(){
		return this.hasRecordTypeIndividual;
	}

	get hasAAIFiscalCode(){
		return this.RecordType.Name !== 'Individual';
	}

	get hasAAFFiscalCode(){
		return this.RecordType.Name === 'AAF_B2C';
	}

	get hasRecordTypeIndividual(){
		return this.RecordType.Name === 'Individual';
	}
	
	get hasRecordTypeCorporate(){
		return this.RecordType.Name === 'Corporate';
	}

	get recordTypeLabel(){
		if(this.RecordType.Name !== 'AAF_B2C' && this.RecordType.Name !== 'Individual' && this.RecordType.Name !== 'Corporate') return VFP06_AAICustomer;
		if(this.RecordType.Name === 'AAF_B2C') return VFP06_Family_Protect;
		if((this.RecordType.Name === 'Individual' || this.RecordType.Name === 'Corporate') && this.TECH_Company__c !== 'AMF') return VFP06_AMPSCustomer;
		if((this.RecordType.Name === 'Individual' || this.RecordType.Name === 'Corporate') && this.TECH_Company__c === 'AMF') return VFP06_AMFCustomer;

		return RecordType.Name;
	}

}