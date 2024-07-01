import { LightningElement } from 'lwc';

import {
	Model,
	ModelCollection
} from 'c/mobilityAbstractModel';


export class MobilityAccountCollection extends Model {

	_childType() {
		return MobilityAccountModel;
	}

}

export class MobilityAccountModel extends Model {

	_model() {
		return {
			Id: '',
			BlackList_Abitazione__c: false,
			BlackList_Auto__c: false,
			BlackList_Aziende__c: false,
			BlackList_Commerciale__c: false,
			BlackList_Infortuni__c: false,
			BlackList_Malattia__c: false,
			BlackList_Protection__c: false,
			BlackList_Rinnovo__c: false,
			BlackList_Saving__c: false,
			BlackList_Servizio__c: false,
			Blacklist_Processi__c: '',
			Ultima_modifica_blacklist__c: null
		}
	}

	get lastModifiedDateBlackList() {
		if (!this.Ultima_modifica_blacklist__c) return '';
		let dateObject = this.getDateTimeFormated(this.Ultima_modifica_blacklist__c);
		return `${dateObject.days}/${dateObject.months}/${dateObject.years} ${dateObject.hours}:${dateObject.minutes}`;
	}

	blackListReset() {
		this.BlackList_Abitazione__c = false;
		this.BlackList_Auto__c = false;
		this.BlackList_Aziende__c = false;
		this.BlackList_Broker__c = false;
		this.BlackList_Commerciale__c = false;
		this.BlackList_Infortuni__c = false;
		this.BlackList_Malattia__c = false;
		this.BlackList_Protection__c = false;
		this.BlackList_Rinnovo__c = false;
		this.BlackList_Saving__c = false;
		this.BlackList_Servizio__c = false;
	}

	blackListValidate(includeInAllCampaign) {
		let errorsMessages = [];

		let isOneProductSelected = (
			this.BlackList_Auto__c ||
			this.BlackList_Abitazione__c ||
			this.BlackList_Infortuni__c ||
			this.BlackList_Malattia__c ||
			this.BlackList_Protection__c ||
			this.BlackList_Saving__c ||
			this.BlackList_Aziende__c
		);

		let isOneCampaignSelected = (
			this.BlackList_Servizio__c ||
			this.BlackList_Rinnovo__c ||
			this.BlackList_Commerciale__c
		);

		if ((isOneCampaignSelected && !isOneProductSelected) || (isOneProductSelected && !isOneCampaignSelected)) {
			errorsMessages.push('Nella sezione BlackList è necessario selezionare almeno una coppia Tipologia Prodotto/Campagna, o lasciare la sezione non compilata.');
		}

		let errorMessage = errorsMessages.join(' - ');

		return {
			errorMessage,
			isSuccess: (errorsMessages.length === 0)
		}
	}
}