import { LightningElement, api } from 'lwc';
import { LghtAbstract } from 'c/lghtAbstract';

export default class LghtSendEmailManageModal extends LghtAbstract {

	@api recordId
	@api caseData;
	@api type
	@api caseRecordType
	@api closeCallback;

	scenarios = {
		Email_Customer				: 'Email to Customer',
		Email_Agent					: 'Email To Agent',
		Email_Bank_Agent			: 'Email to Bank Agent',
		Email_Technical_Office		: 'Email to Technical Office',
		Email_IPSI					: 'Email to IPSI',
		Email_MyFox					: 'Email to MyFox',
		Email_Blue_Assistance		: 'Email to Blue Assistance',
		Email_Agency				: 'Email to Agency',
		Email_GDPR_Assistance		: 'Email for GDPR Assistance'
	};

	componentView = 'LghtSendEmailManageModal';

	get selectList(){
		const listScenarios = [];

		if(this.caseData.RecordType.DeveloperName !== 'DAC_AXA_Agenti'){
			listScenarios.push('Email_Customer');
		}

		if(!listScenarios.includes('Email_Customer')){
			listScenarios.push('Email_Agent');
		}

		if(listScenarios.includes('Email_Customer') && listScenarios.includes('Email_Agent')){
			
		}

	}

	getScenario(name){
		return {label: this.scenarios[name], value: name};
	}

	connectedCallback() {
		super.connectedCallback();
	}

}