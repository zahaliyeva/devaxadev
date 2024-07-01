/* eslint-disable radix */
import {
	Model,
	ModelCollection
} from 'c/mobilityAbstractModel';

export class MobilityCampaignCollection extends ModelCollection {

	constructor(data) {
		super(data);
		
		let allData = this.getAll();
		for (let index in allData) {
			allData[index].counterObject = data.counterObject;
			allData[index].counterObjectClosed = data.counterObjectClosed;
			allData[index].counterObjectPriority = data.counterObjectPriority;
		}
	}

	_model() {
		return {
			...super._model(),
			counterObject: {},
			counterObjectClosed: {},
			counterObjectPriority: {},
		}
	}

	_childType() {
		return MobilityCampaignModel;
	}

	getAllBy() {
		let getAll = this.getAll();

		return getAll.sort((record1, record2) => {

			let weights = {
				'Agency_campaign': -1
			};

			let weight1 = weights[record1.RecordType.DeveloperName];
			let weight2 = weights[record2.RecordType.DeveloperName];

			if (!weight1) weight1 = 0;
			if (!weight2) weight2 = 0;

			return weight2 - weight1;
		})
	}

}

export class MobilityCampaignModel extends Model {

	_model() {
		return {
			Name: '',
			NumberOfContacts: 0,
			NumberOfLeads: 0,
			EndDate: null,
			NumberOfClosed__c: 0,
			NumberOfPriority__c: 0,
			RecordType: {
				DeveloperName: ''
			},
			Status: '',
			counterObject: {},
			counterObjectClosed: {},
			counterObjectPriority: {},
		}
	}

	get EndDateString() {
		if (!this.EndDate) return '';
		let dateObject = this.getDateTimeFormated(this.EndDate);
		return `${dateObject.days}/${dateObject.months}/${dateObject.years}`;
	}

	get NumberOfMembers() {
		if (!this.counterObject[this.Id]) return 0;
		return this.counterObject[this.Id];
		//return this.NumberOfContacts + this.NumberOfLeads;
	}

	get NumberOfPriority() {
		if (!this.counterObjectPriority[this.Id]) return 0;
		return this.counterObjectPriority[this.Id];
	}


	get NumberOfClosed() {
		if (!this.counterObjectClosed[this.Id]) return 0;
		return this.counterObjectClosed[this.Id];
	}

	get percentageClosed() {
		if (this.NumberOfMembers === 0) return 0;
		return parseInt((this.NumberOfClosed / this.NumberOfMembers) * 100);
	}

	

	get closedStyle() {
		let style = ['progress', 'progressCustom'];

		if(this.RecordType.DeveloperName === "Data_Enrichment_Campaign")
			style.push("progressBgAmministrativa")
		if(this.RecordType.DeveloperName === "Performa_campaign" || this.RecordType.DeveloperName === "Agency_campaign")
			style.push("progressBgAltro")
		if(this.RecordType.DeveloperName === "Marketing_campaign")
			style.push("progressBgCommerciale")
		if(this.RecordType.DeveloperName === "Informative_Campaign" || this.RecordType.DeveloperName ==="Informative_Campaign_PCC_MyAXA" )
			style.push("progressBgInformativa")
		
        
		/*if (this.RecordType.DeveloperName === 'Agency_campaign') {
			style.push('progressBgAgency')
		} else {
			style.push('progressBg')
		}*/

		return style.join(' ');
	}

	get percentageClosedWidth() {
		let width = `width: ${this.percentageClosed}%;`;
		if (this.percentageClosed === 0) width = 'width: 1rem;';

		return width;
	}

	get NumberOfMembersLabel() {
		let clientNumber = null;

		if (this.NumberOfMembers === 1) {
			clientNumber = `1 ${this._label.campaign_colNumber_customer}`;
		} else {
			clientNumber = `${this.decimalFormat(this.NumberOfMembers)} ${this._label.campaign_colNumber_customers}`;
		}

		return clientNumber;
	}

	get priorityLabel() {

		if (this.NumberOfPriority <= 0) return '';
		if (this.NumberOfPriority === 1) return this._label.campaign_priority_prior;
		if (this.NumberOfPriority >= 2) return this._label.campaign_priority_prioritary;

		return this._label.campaign_priority_prior;
	}

	get priorityNumber() {
		let number = this.NumberOfPriority;

		if (number > 999) number = this.kFormatter(number);

		return number;
	}

	decimalFormat(value) {
		if (isNaN(value)) return value;

		if (value < 9999) {
			return value;
		}

		if (value < 1000000) {
			return Math.round(value / 1000) + "K";
		}
		if (value < 10000000) {
			return (value / 1000000).toFixed(2) + "M";
		}

		if (value < 1000000000) {
			return Math.round((value / 1000000)) + "M";
		}

		if (value < 1000000000000) {
			return Math.round((value / 1000000000)) + "B";
		}

		return "1T+";
	}
}