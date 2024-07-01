/* eslint-disable guard-for-in */
import { track } from 'lwc';
import { MobilityAbstract } from 'c/mobilityAbstract';
import { DataGridModel } from 'c/dataGridModel';

import { MobilityPicklistValues } from './mobilityPicklistValues.js';

import initData from '@salesforce/apex/MobilityCampaignProcessing.initData';

import getDataEnrichment from '@salesforce/apex/MobilityCampaignDataEnrichment.getDataEnrichment';
import getMarketing from '@salesforce/apex/MobilityCampaignMarketing.getMarketing';
import getAgency from '@salesforce/apex/MobilityCampaignAgency.getAgency';
import getInformative from '@salesforce/apex/MobilityCampaignInformative.getInformative';
import getIncentive from '@salesforce/apex/MobilityCampaignIncentive.getIncentive';

import changeStatus from '@salesforce/apex/MobilityCampaignMemberController.changeStatus';
import assignMembers from '@salesforce/apex/MobilityCampaignMemberController.assignMembers';
import getUserAgency from '@salesforce/apex/MobilityUserController.getUserAgency';
import getOpportunityMember from '@salesforce/apex/MobilityOpportunityController.getOpportunityMember';
import createProposal from '@salesforce/apex/MobilityOpportunityController.createProposal';

export default class MobilityCampaignProcessing extends MobilityAbstract {
    componentView = 'mobilityCampaignProcessing';
    customLayout = {};
    selectedAction = '';
    customLayoytData = {};

    statusDataEnrichment = MobilityPicklistValues.statusDataEnrichment;
    statusInformative = MobilityPicklistValues.statusInformative;
    statusMarketing = MobilityPicklistValues.statusMarketing;
    statusAgency = MobilityPicklistValues.statusAgency;

    availableFilters = true;

    @track userList = [];
    @track recordType = '';
    //ECLEMENTE IDCRM165
    @track typeCampaign = '';
    @track campaignTitle = '';
    @track dataEnrichment = {};
    @track informative = {};
    @track incentive = {};
    @track marketing = {};
    @track agency = {};
    @track showFilter = true;
    @track labelSuccessOk;
    @track labelWarningBack;
    @track labelAlertBack;
    @track labelWarningConfirmation;
    @track selectStatus = '';
    @track selectUser = '';

    @track showCreateProposal = false;
    @track showNotInterested = false;
    @track showInterested = false;
    @track showRecontact = false;
    @track showDataEnrichment = false;

    @track contextCreateProposal = {};
    @track showInformativeCampaign = false;
    @track contextInformativeCampaign = {};

    selectCampaignMemberId;

    get fromAgency(){
        if(!this.params) return false;
        if(!this.params.fromAgency) return false;
        return this.params.fromAgency;
    }

    connectedCallback() {
        super.connectedCallback();
        this.getInitData().then(() => {
            this.getAssignUser();
        });
    }

    get redirectParams() {
        return {
            mobilityCampaignDetail: {
                recordId: this.params.recordId
            }
        }
    }

    get filtersCampaignMembers() {
        if (!this.customLayout) return {};
        if (!this.customLayout.sections) return {};

        return this.customLayout.sections.record;
    }

    get styleFilter() {
        if (!this.showFilter) return 'display: none;';
        return '';
    }

    get recordTypeAgency() {
        if (this.recordType === 'Agency_campaign') return true;
        return false;
    }

    get dataGrid() {
        if(this.customLayoytData.campaign && this.customLayoytData.campaign.IncentiveCampaign__c) return this.incentive;

        switch (this.recordType) {
            case 'Data_Enrichment_Campaign':
                return this.dataEnrichment;
            case 'Informative_Campaign':
                return this.informative;
            case 'Agency_campaign':
                return this.agency;
            case 'Marketing_campaign':
                return this.marketing;
            default:
                return '';
        }
    }

    get status() {
        switch (this.recordType) {
            case 'Data_Enrichment_Campaign':
                return this.statusDataEnrichment;
            case 'Informative_Campaign':
                return this.statusInformative;
            case 'Agency_campaign':
                return this.statusAgency;
            case 'Marketing_campaign':
                return this.statusMarketing;
            default:
                return '';
        }
    }

    get showCustomLayout() {
        return this.recordType !== '';
    }

    get pageLayout() {
        console.log('this.customLayoytData.campaign.Type '+this.customLayoytData.campaign.Type);
        if(this.customLayoytData && this.customLayoytData.campaign && this.customLayoytData.campaign.IncentiveCampaign__c) {
            return 'Campaign.Incentive_Campaign';
        }else if(this.recordType == 'Marketing_campaign' && this.customLayoytData.campaign.Type == 'Cross Selling') {          
            return 'Campaign.Marketing_campaign.Cross_Selling';
        }else if(this.recordType == 'Informative_Campaign' && this.customLayoytData.campaign.Type != 'Email'){
            return 'Campaign.Informative_Campaign.NotEmail';
        }else if(this.recordType == 'Data_Enrichment_Campaign' && this.customLayoytData.campaign.Type != 'Data Enrichment Campaign' && this.customLayoytData.campaign.Type != 'Core/Industriale'){
            return 'Campaign.Data_Enrichment_Campaign.NotEnrichCore';
        }     
        return 'Campaign.' + this.recordType;
    }

    get isDisabledUpdate() {
        if (this.selectStatus !== '' && this.dataGrid && this.dataGrid.listSelected && this.dataGrid.listSelected.length > 0) return false;
        return true;
    }

    get isDisabledExclude() {
        if (this.dataGrid && this.dataGrid.listSelected && this.dataGrid.listSelected.length > 0) return false;
        return true;
    }

    get isDisabledChangeOwner() {
        if (this.selectUser !== '' && this.dataGrid && this.dataGrid.listSelected && this.dataGrid.listSelected.length > 0) return false;
        return true;
    }

    getInitData(){
        return initData({
            campaignId: this.params.recordId
        }).then((result)=>{
            console.log(result);
            this.recordType = result.campaign.RecordType.DeveloperName;
            this.campaignTitle = result.campaign.Name;
            this.customLayoytData = result;
            this.typeCampaign = result.campaign.Type;
        })
    }

    initDataGrid(){
        if(this.customLayoytData.campaign.IncentiveCampaign__c) return this.loadIncentive();
        
        switch (this.recordType) {
            case 'Data_Enrichment_Campaign':
                return this.loadDataEnrichment();               
            case 'Informative_Campaign':
                return this.loadInformative();
            case 'Agency_campaign':
                return this.loadAgency();
            case 'Marketing_campaign':
                return this.loadMarketing();
        }

        return Promise.reject();
    }

    onTest = () => {
        let types = ['DATE', 'DATETIME', 'PICKLIST', 'BOOLEAN'];
        let index = 0;
        clearInterval(this.testhandler);
        this.testhandler = setInterval(()=>{
            this.customLayout.changeField('Nodes__c', {type: types[index], pickListMap: {'LABELT TEST': '1234'}});
            index += 1;
            if(index > types.length)index = 0;
        }, 1000)
    }

    getAssignUser() {
        getUserAgency({}).then((result) => {
            let list = [{
                label: '-',
                value: ''
            }];

            for (let index in result) {
                list.push({
                    label: result[index].Name,
                    value: result[index].Id
                })
            }

            this.userList = list;
        })
    }

    onStatusSelect(e) {
        this.selectStatus = e.target.value;
    }

    onUserSelect(e) {
        this.selectUser = e.target.value;
    }

    statusUpdate() {
        this.labelWarningBack = 'Annulla';
        this.labelWarningConfirmation = 'Si, procedi con il cambio stato';

        this.selectedAction = 'update';
        this.warningMessage('', 'Sei sicuro di voler cambiare lo stato dei clienti campagna selezionati?');
    }

    statusExclude() {
        this.labelWarningBack = 'Annulla';
        this.labelWarningConfirmation = 'Si, procedi con l’esclusione';

        this.selectedAction = 'exclude';
        this.warningMessage('', 'Sei sicuro di voler escludere i clienti campagna selezionati?');
    }

    changeOwner() {
        this.labelWarningBack = 'Annulla';
        this.labelWarningConfirmation = 'Si, procedi con l\'assegnazione';

        this.selectedAction = 'changeOwner';
        this.warningMessage('', 'Sei sicuro di voler procedere con l\'assegnazione dei clienti campagna selezionati?');
    }

    sendEmailOwner() {
        this.labelWarningBack = 'No';
        this.labelWarningConfirmation = 'Si';

        this.selectedAction = 'sendEmailOwner';
        this.warningMessage('', 'Vuoi inviare una Email di notifica al nuovo Owner?');
    }

    confirmWarningCallback = () => {
        let status = this.selectStatus;
        let customers = this.dataGrid.listSelected;
        let userSelect = this.selectUser;

        if (this.selectedAction === 'exclude' && (this.recordType === 'Agency_campaign' || this.recordType === 'Marketing_campaign')) status = 'Escluso';

        if (this.selectedAction === 'changeOwner') {
            this.sendEmailOwner();
        } else if (this.selectedAction === 'sendEmailOwner') {
            this.invokeChangeOwner(userSelect, customers, true);
        } else {
            this.invokeChangeStatus(status, customers);
        }
    }

    cancelWarningCallback = () => {
        let status = this.selectStatus;
        let customers = this.dataGrid.listSelected;
        let userSelect = this.selectUser;

        if (this.selectedAction === 'sendEmailOwner') {
            this.invokeChangeOwner(userSelect, customers, false);
        }
    }

    invokeChangeStatus(status, customers, ) {
        this.showSpinner(true);
        return changeStatus({
            customers: customers,
            status: status
        }).then((response) => {
            if (!response.isSuccess) throw new Error(response.errorMessage);
            this.successMessage('Success', 'Stato cambiato con successo');
            this.dataGrid.load();
        }).catch((err) => {
            console.log("errChangeStatus: ", err);
            this.alertMessage('Error', '' + err.message);
        }).finally(() => {
            this.hideSpinner();
        });
    }

    invokeChangeOwner(userSelect, customers, sendEmailToOwner) {
        this.showSpinner(true);
        return assignMembers({
            campaignId: this.params.recordId,
            listIdMembers: customers,
            selectUserId: userSelect,
            sendEmailToOwner: sendEmailToOwner
        }).then((response) => {
            if (!response.isSuccess) throw new Error(response.errorMessage);
            this.successMessage('Success', 'Owner cambiato con successo');
            this.dataGrid.load();
        }).catch((err) => {
            console.log("errChangeStatus: ", err);
            this.alertMessage('Error', '' + err.message);
        }).finally(() => {
            this.hideSpinner();
        });
    }

    readyCallback = (target) => {
        this.customLayout = target;
    }

    loadCallback = (target) => {
        this.initDataGrid();
    }

    filterApply = () => {
        this.showFilter = false;

        let filters = this.customLayout.sections.getFilter();

        console.log('filterApply', filters);
        this.dataGrid.setAllFilterVariable(filters);
    }

    toggleFilter() {
        this.showFilter = !this.showFilter;
    }

    filterReset() {
        console.log('filterReset');
        this.dataGrid.removeAllFiltersVariables();

        this.customLayout.reset();
    }

    checkFilters = (instance) => {
        //pthis.showFilter = instance.filtersVariables.length === 0;
    }

    toogleCreateProposal = () => {
        this.showCreateProposal = !this.showCreateProposal;
    }

    toogleNotInterested = () => {
        this.showNotInterested = !this.showNotInterested;
    }

    toogleInterested = () => {
        this.showInterested = !this.showInterested;
    }

    toogleRecontact = () => {
        this.showRecontact = !this.showRecontact;
    }

    toogleCreateProposalReload = () => {
        this.toogleCreateProposal();
        this.dataGrid.load();
    }

    toogleNotInterestedReload = () => {
        this.toogleNotInterested();
        this.dataGrid.load();
    }

    toogleInterestedReload = () => {
        this.toogleInterested();
        this.dataGrid.load();
    }

    toogleRecontactReload = () => {
        this.toogleRecontact();
        this.dataGrid.load();
    }

    onCreateProposal = (campaignMemberId) => {
        this.showSpinner(true);
        getOpportunityMember({
            campaignMemberId
        }).then((response) => {
            if (!response.isSuccess) throw new Error(response.errorMessage);

            console.log(response.listOpportunity);

            if (response.listOpportunity.length === 0) {
                this.invokeCreateProposal(campaignMemberId);
            } else {
                this.hideSpinner();
                this.contextCreateProposal = response;
                this.toogleCreateProposal();
            }
        }).catch((err) => {
            this.hideSpinner();
            console.log("errChangeStatus: ", err);
            this.alertMessage('Error', '' + err.message);
        }).finally(() => {
            //this.hideSpinner();
        });
    }

    invokeCreateProposal = (campaignMemberId) => {
        createProposal({
            campaignMemberId
        }).then((result) => {
            console.log('invokeCreateProposal', result);
            this.sendCreateProposal(result);
            this.dataGrid.load();
        })
    }

    /*
    START INFORMATIVE
     */
    toggleInformativeCampaign = () => {
        this.showInformativeCampaign = !this.showInformativeCampaign;
    }

    toggleInformativeCampaignReload = () => {
        this.toggleInformativeCampaign();
        this.dataGrid.load();
    }

    onInformativeCampaign = (campaignMemberId) => {
        console.log('campaignMemberId: ', campaignMemberId);
        this.selectCampaignMemberId = campaignMemberId;
        this.toggleInformativeCampaign();
    }

    /*
    START NOT INTERESTED 
     */
    onNotInterested = () => {
        this.showNotInterested = !this.showNotInterested;
    }

    onNotInterestedReload = () => {
        this.onNotInterested();
        this.dataGrid.load();
    }

    /*
    START DATA ENRICHMENT
     */
    onDataEnrichment = () => {
        this.showDataEnrichment = !this.showDataEnrichment;
    }
    
    onDataEnrichmentReload = () => {
        this.onDataEnrichment();
        this.dataGrid.load();
    }

    onSelecetDataEnrichment = (campaignMemberId) => {
        this.selectCampaignMemberId = campaignMemberId;
        this.onDataEnrichment();
    }

    overrideDatagrid = () => {
        let rulesClean = {};
        let rules = this.customLayoytData;
    
        rulesClean.Status = {
            type: 'PICKLIST',
            pickListMap: rules.campaignMemberStatus
        }

        rulesClean.Owner__c = {
            type: 'PICKLIST',
            pickListMap: rules.listOwner
        }

        let rulesNode = {};
        for(let key in rules.nodes){
            let node = rules.nodes[key];

            rulesNode[key] = `!LIKE(%${node}%)`;
        }

        rulesClean.Nodes__c = {
            type: 'PICKLIST',
            pickListMap: rulesNode
        }

        rulesClean.TECH_Client_Index__c = {
            type: 'PICKLIST',
            pickListMap: rules.clientIndices
        }


        rulesClean.Sottostato__c = {
            type: 'PICKLIST',
            pickListMap: rules.campaignMemberSubStatus
        }

        rulesClean.Stato_Opportunit_Custom__c = {
            type: 'PICKLIST',
            pickListMap: rules.opportunityValues
        }

        rulesClean.TECH_Data_Enrichment_Processed__c = {
            type: 'PICKLIST',
            pickListMap: {
                'SI': 'true',
                'NO': 'false'
            }
        }

        rulesClean.Informative_Contact_Outcome__c = {
            type: 'PICKLIST',
            pickListMap: rules.contactValues
        }

        rulesClean.Cliente_prioritario__c = {
            type: 'PICKLIST',
            required: false,
            pickListMap: {
                'SI': 'true',
                'NO': 'false'
            }
        }

        if(this.customLayout && this.customLayout.changeFields) this.customLayout.changeFields(rulesClean);
    }

    loadDataEnrichment() {
        let tableData = {};
        tableData.perPage = 6;

        tableData.encodes = {
            TECH_Account_Name__c:{
                valueLabel: value => (value),
                 onClick: this.openAccount,
                 type: 'REDIRECT'
             },
            Data_Enrichment_Target_Phone__c: {type: 'CHECKBOX'},
            Data_Enrichment_Target_Email__c: {type: 'CHECKBOX'},
            Data_Enrichment_Target_Consensus__c: {type: 'CHECKBOX'},
            Data_Enrichment_Target_Other__c: {type: 'CHECKBOX'},
            TECH_First_expiration_date__c: {
                valueDate: value => (value),
                type: 'DATE'
            },
            LastModifiedDate: {
                valueDateTime: value => (value),
                type: 'DATETIME'
            },
            Owner__r: value => {
                if (!value) return '';
                return value.Name;
            },
            Status: {
                valueBadge: value => (value),
                type: 'BADGE',
                colors: value => {
                    return '#00ADC6';
                }
            }
        }

        if(this.typeCampaign === 'Core/Industriale' || this.typeCampaign === 'Data Enrichment Campaign'){
            tableData.actions = [{
                label: '',
                icon: 'edit',
                callback: (value) => {
                   this.onSelecetDataEnrichment(value.Id);
                }
            }]
        }else{
            tableData.actions = [{
                label: 'Interessato',
                devName: 'interested',
            }, {
                label: 'Da ricontattare',
                devName: 'toBeRecontacted',
            }, {
                label: 'Non interessato',
                devName: 'notInterested',
            }, {
                label: 'Crea proposta',
                devName: 'createProposal',
            }]
    
            tableData.actionType = 'DROPDOWN';
            tableData.actionIcon = 'dots';
            tableData.actionDropDownCallback = (action, value) => {
                console.log(action, value);
                this.selectCampaignMemberId = value.Id;
    
                if (action === 'createProposal') this.onCreateProposal(value.Id);
                if (action === 'interested') this.toogleInterested();
                if (action === 'notInterested') this.toogleNotInterested();
                if (action === 'toBeRecontacted') this.toogleRecontact();
            };
        }
        

        tableData.fixedFirst = true;
        tableData.fixedLast = true;
        tableData.viewSelectRow = true;

        tableData.bind = {
            origin: this,
            target: 'dataEnrichment',
            load: getDataEnrichment
        };

        this.dataEnrichment = new DataGridModel(tableData);
        if (this.params.recordId) this.dataEnrichment.setFilter('CampaignId', [this.params.recordId], false);
        if (this.params.campaignMemberId) this.dataEnrichment.setFilter('Id', [this.params.campaignMemberId], false);

        this.dataEnrichment.preLoadCallback = () => {
            this.showSpinner(true);
        };

        this.dataEnrichment.loadCallback = (instance, result) => {
            this.showNoData(result.length === 0);
            this.overrideDatagrid();
            this.hideSpinner();
        };

        this.dataEnrichment.errorCallback = (instance, err) => {
            this.alertMessage('Error', err.statusText);
            this.hideSpinner();
        };

        this.dataEnrichment.filtersVariablesRemoveCallback = this.checkFilters;
        this.dataEnrichment.filtersVariablesCallback = this.checkFilters;
        this.dataEnrichment.orderCallback = (field) => {
            if(field === 'Owner__r') return 'Owner__r.Name';
        }

        this.dataEnrichment.load();
    }

    loadInformative() {
        let tableData = {};
        tableData.perPage = 6;

        tableData.encodes = {
            TECH_Account_Name__c:{
                valueLabel: value => (value),
                 onClick: this.openAccount,
                 type: 'REDIRECT'
             },
            TECH_First_expiration_date__c: {
                valueDate: value => (value),
                type: 'DATE'
            },
            LastModifiedDate: (value, row ) => {
             if (row.CreatedDate === value){
                 return '';
             }else {
                let dateObject  = this.dataGrid.getDateTimeFormated(value);
                return `${dateObject.days}/${dateObject.months}/${dateObject.years} ${dateObject.hours}:${dateObject.minutes}:${dateObject.seconds}`;
             }
                
            },
            Owner__r: value => {
                if (!value) return '';
                return value.Name;
            },
            Status: {
                valueBadge: value=> (value),
                type: 'BADGE',
                colors: value => {
                    return '#00ADC6';
                }
            }
        }
        

        if(this.typeCampaign === 'Email'){
            tableData.actions = [{
                label: '',
                icon: 'edit',
                callback: (value) => {
                    this.onInformativeCampaign(value.Id);
                }
            }]
        }else{
            tableData.actions = [{
                label: 'Interessato',
                devName: 'interested',
            }, {
                label: 'Da ricontattare',
                devName: 'toBeRecontacted',
            }, {
                label: 'Non interessato',
                devName: 'notInterested',
            }, {
                label: 'Crea proposta',
                devName: 'createProposal',
            }]
    
            tableData.actionType = 'DROPDOWN';
            tableData.actionIcon = 'dots';
            tableData.actionDropDownCallback = (action, value) => {
                console.log(action, value);
                this.selectCampaignMemberId = value.Id;
    
                if (action === 'createProposal') this.onCreateProposal(value.Id);
                if (action === 'interested') this.toogleInterested();
                if (action === 'notInterested') this.toogleNotInterested();
                if (action === 'toBeRecontacted') this.toogleRecontact();
            };
        }
        

        tableData.fixedFirst = true;
        tableData.fixedLast = true;
        tableData.viewSelectRow = true;

        tableData.bind = {
            origin: this,
            target: 'informative',
            load: getInformative
        };

        this.informative = new DataGridModel(tableData);
        if (this.params.recordId) this.informative.setFilter('CampaignId', [this.params.recordId], false);
        if (this.params.campaignMemberId) this.informative.setFilter('Id', [this.params.campaignMemberId], false);

        this.informative.preLoadCallback = () => {
            this.showSpinner(true);
        };

        this.informative.loadCallback = (instance, result) => {
            this.showNoData(result.length === 0);
            this.overrideDatagrid();
            this.hideSpinner();
        };

        this.informative.errorCallback = (instance, err) => {
            this.alertMessage('Error', err.statusText);
            this.hideSpinner();
        };

        this.informative.filtersVariablesRemoveCallback = this.checkFilters;
        this.informative.filtersVariablesCallback = this.checkFilters;
        this.informative.orderCallback = (field) => {
            if(field === 'Owner__r') return 'Owner__r.Name';
        }

        this.informative.load();
    }

    loadIncentive() {
        let tableData = {};
        tableData.perPage = 6;

        tableData.encodes = {
        	Name:{
                valueLabel: value => (value),
                 onClick: this.openAccount,
                 type: 'REDIRECT'
             },
            ndg_certificato__c: (value)=>((value) ? 'SI' : 'NO'),
            flg_attivo__c: (value)=>((value) ? 'SI' : 'NO'),
            target_2018__c: (value)=>((value) ? 'SI' : 'NO'),
            stop_carta_2018__c: (value)=>((value) ? 'SI' : 'NO'),
            firma_digitale_2018__c: (value)=>((value) ? 'SI' : 'NO'),
            LastModifiedDate: {
				valueDate: value => (value),
				type: 'DATE'
			}
        }

        tableData.actions = []

        tableData.fixedFirst = true
        tableData.viewSelectRow = true;

        tableData.bind = {
            origin: this,
            target: 'incentive',
            load: getIncentive
        };

        this.incentive = new DataGridModel(tableData);
        if (this.params.recordId) this.incentive.setFilter('CampaignId', [this.params.recordId], false);
        if (this.params.campaignMemberId) this.incentive.setFilter('Id', [this.params.campaignMemberId], false);

        this.incentive.preLoadCallback = () => {
            this.showSpinner(true);
        };

        this.incentive.loadCallback = (instance, result) => {
            this.showNoData(result.length === 0);
            this.overrideDatagrid();
            this.hideSpinner();
        };

        this.incentive.errorCallback = (instance, err) => {
            this.alertMessage('Error', err.statusText);
            this.hideSpinner();
        };

        this.incentive.filtersVariablesRemoveCallback = this.checkFilters;
        this.incentive.filtersVariablesCallback = this.checkFilters;
        this.incentive.orderCallback = (field) => {
            if(field === 'Owner__r') return 'Owner__r.Name';
        }

        this.incentive.load();
    }

    loadMarketing() {
        let tableData = {};
        tableData.perPage = 6;
        tableData.encodes = {
        	TECH_Account_Name__c:{
                valueLabel: value => (value),
                 onClick: this.openAccount,
                 type: 'REDIRECT'
             },
            TECH_task_date_created__c: {
                valueDate: value => (value),
                type: 'DATE'
            },
            TECH_First_expiration_date__c: {
                valueDate: value => (value),
                type: 'DATE'
            },
            Owner__r: value => {
                if (!value) return '';
                return value.Name;
            },
            Status: {
                valueBadge: value => (value),
                type: 'BADGE',
                colors: value => {
                    return '#00ADC6';
                }
            }
        }

        tableData.actions = [{
            label: 'Interessato',
            devName: 'interested',
        }, {
            label: 'Da ricontattare',
            devName: 'toBeRecontacted',
        }, {
            label: 'Non interessato',
            devName: 'notInterested',
        }, {
            label: 'Crea proposta',
            devName: 'createProposal',
        }]

        tableData.actionType = 'DROPDOWN';
        tableData.actionIcon = 'dots';
        tableData.actionDropDownCallback = (action, value) => {
            console.log(action, value);
            this.selectCampaignMemberId = value.Id;

            if (action === 'createProposal') this.onCreateProposal(value.Id);
            if (action === 'interested') this.toogleInterested();
            if (action === 'notInterested') this.toogleNotInterested();
            if (action === 'toBeRecontacted') this.toogleRecontact();
        };

        tableData.fixedFirst = true;
        tableData.fixedLast = true;
        tableData.viewSelectRow = true;

        tableData.bind = {
            origin: this,
            target: 'marketing',
            load: getMarketing
        };

        this.marketing = new DataGridModel(tableData);
        if (this.params.recordId) this.marketing.setFilter('CampaignId', [this.params.recordId], false);
        if (this.params.campaignMemberId) this.marketing.setFilter('Id', [this.params.campaignMemberId], false);

        this.marketing.preLoadCallback = () => {
            this.showSpinner(true);
        };

        this.marketing.loadCallback = (instance, result) => {
            this.showNoData(result.length === 0);
            this.overrideDatagrid();
            this.hideSpinner();
        };

        this.marketing.errorCallback = (instance, err) => {
            this.alertMessage('Error', err.statusText);
            this.hideSpinner();
        };

        this.marketing.filtersVariablesRemoveCallback = this.checkFilters;
        this.marketing.filtersVariablesCallback = this.checkFilters;
        this.marketing.orderCallback = (field) => {
            if(field === 'Owner__r') return 'Owner__r.Name';
        }

        this.marketing.load();
    }

    loadAgency() {
        let tableData = {};
        tableData.perPage = 6;
        tableData.encodes = {
            TECH_Account_Name__c:{
                valueLabel: value => (value),
                 onClick: this.openAccount,
                 type: 'REDIRECT'
             },
            TECH_task_date_created__c: {
                valueDate: value => (value),
                type: 'DATE'
            },
            TECH_First_expiration_date__c: {
                valueDate: value => (value),
                type: 'DATE'
            },
            Owner__r: value => {
                if (!value) return '';
                return value.Name;
            },
            Status: {
                valueBadge: value => (value),
                type: 'BADGE',
                colors: value => {
                    return '#00ADC6';
                }
            }
        }

        tableData.actions = [{
            label: 'Interessato',
            devName: 'interested',
        }, {
            label: 'Da ricontattare',
            devName: 'toBeRecontacted',
        }, {
            label: 'Non interessato',
            devName: 'notInterested',
        }, {
            label: 'Crea proposta',
            devName: 'createProposal',
        }]

        tableData.actionType = 'DROPDOWN';
        tableData.actionIcon = 'dots';
        tableData.actionDropDownCallback = (action, value) => {
            console.log(action, value);
            this.selectCampaignMemberId = value.Id;

            if (action === 'createProposal') this.onCreateProposal(value.Id);
            if (action === 'interested') this.toogleInterested();
            if (action === 'notInterested') this.toogleNotInterested();
            if (action === 'toBeRecontacted') this.toogleRecontact();
        };

        tableData.fixedFirst = true;
        tableData.fixedLast = true;
        tableData.viewSelectRow = true;

        tableData.bind = {
            origin: this,
            target: 'agency',
            load: getAgency
        };

        this.agency = new DataGridModel(tableData);
        if (this.params.recordId) this.agency.setFilter('CampaignId', [this.params.recordId], false);
        if (this.params.campaignMemberId) this.agency.setFilter('Id', [this.params.campaignMemberId], false);

        this.agency.preLoadCallback = () => {
            this.showSpinner(true);
        };

        this.agency.loadCallback = (instance, result) => {
            this.showNoData(result.length === 0);
            this.overrideDatagrid();
            this.hideSpinner();
        };

        this.agency.errorCallback = (instance, err) => {
            this.alertMessage('Error', err.statusText);
            this.hideSpinner();
        };

        this.agency.filtersVariablesRemoveCallback = this.checkFilters;
        this.agency.filtersVariablesCallback = this.checkFilters;
        this.agency.orderCallback = (field) => {
            if(field === 'Owner__r') return 'Owner__r.Name';
        }

        this.agency.load();
    }
}