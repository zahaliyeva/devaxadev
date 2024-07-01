import {
	track,
	api
} from 'lwc';

import {
	MobilitySObject
} from 'c/mobilitySObject';

import {
	DataGridModel
} from 'c/dataGridModel';

import getOpportunityMemberGrid from '@salesforce/apex/MobilityOpportunityController.getOpportunityMemberGrid';
import createProposal from '@salesforce/apex/MobilityOpportunityController.createProposal';
import setProposal from '@salesforce/apex/MobilityOpportunityController.setProposal';

export default class MobilityCampaignNewProposal extends MobilitySObject {
	componentView = 'mobilityCampaignNewProposal';

	@api context;
	@api closeCallbackReload;

	@track opportunityData = {};

	get isNotSelected(){
		return !this.opportunityData || !this.opportunityData.hasSelected;
	}

	connectedCallback() {
		super.connectedCallback();

		this.loadData();
	}

	showWarning(){
		this.warningMessage('', 'Vuoi creare una nuova trattativa?');
	}

	onCreateProposal = () => {
		this.showSpinner(true);
        createProposal({
            campaignMemberId: this.context.campaignMember.Id
        }).then((response)=>{
        	if (!response.isSuccess) throw new Error(response.errorMessage);

            console.log('invokeCreateProposal', response);
            this.sendCreateProposal(response);
            if (this.closeCallbackReload) this.closeCallbackReload();
        }).catch((err) => {
            console.log("errChangeStatus: ", err);
            this.alertMessage('Error', '' + err.message);
        }).finally(() => {
        	this.hideSpinner();
        })
    }

    onSetProposal = () => {
    	this.showSpinner(true);

    	let selectOpportunity;
    	if(this.opportunityData.listSelected.length > 0){
    		selectOpportunity = this.opportunityData.listSelected[0];
    	}

    	let request = {
            campaignMemberId: this.context.campaignMember.Id,
            opportunityId: selectOpportunity,
        };

        setProposal(request).then((response)=>{
        	if (!response.isSuccess) throw new Error(response.errorMessage);

        	this.sendCreateProposal(response);
			this.onClose();
        }).catch((err) => {
            console.log("errChangeStatus: ", err);
            this.alertMessage('Error', '' + err.message);
        }).finally(() => {
        	this.hideSpinner();
        })
    }

	loadData() {
		return new Promise((resolve, reject)=>{
			let tableData = {};

			tableData.perPage = 10;

			tableData.encodes = {
				Queue: (value) => (value.Name),
				CreatedDate: {
				    valueDate: value => (value),
				    type: 'DATE'
				},
			}

			tableData.actions = []

			tableData.fixedFirst = true;
			tableData.fixedLast = false;
			tableData.viewSelectRow = true;
			tableData.singleSelect = true;
			tableData.maxHeight = 300;

			tableData.bind = {
				origin: this,
				target: 'opportunityData',
				load: getOpportunityMemberGrid
			};

			this.opportunityData = new DataGridModel(tableData);
			this.opportunityData.setFilter('Account.Id', [this.context.account.Id])

			this.opportunityData.preLoadCallback = () => {
				this.showSpinner(true);
			};

			this.opportunityData.loadCallback = (instance, result) => {
				this.hideSpinner();
				resolve(result);
			};
			this.opportunityData.errorCallback = (instance, result) => {
				reject(result);
			};
			this.opportunityData.orderCallback = (field) => {
	            if(field === 'Queue') return 'Queue.Name';
	        }

			this.opportunityData.load();
		})
	}
}