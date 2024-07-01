import { LightningElement, api, track } from 'lwc';
import { LghtAbstract } from 'c/lghtAbstract';

import getWorkGroups from '@salesforce/apex/LghtHistoryStatusController.getWorkGroups';

export default class LghtHistoryCaseStatus extends LghtAbstract {
    
    @api recordId;
    @api viewAll = false;
    
    @track filtersSelected = {
        Activity__c: '',
        CaseOwner__c: ''
    };

    @track workGroups = {};
    @track data = [];

    componentView = 'LghtHistoryCaseStatus';
    handlerDataGrid;

    get filters(){
        const Activity__c = (this.filtersSelected.Activity__c !== '') ? [this.filtersSelected.Activity__c] : null;
        const CaseOwner__c = (this.filtersSelected.CaseOwner__c !== '') ? [this.filtersSelected.CaseOwner__c] : null;

        const filters = {
            Case__c: [this.recordId]
        };

        if(Activity__c) filters.Activity__c = Activity__c;
        if(CaseOwner__c) filters.CaseOwner__c = CaseOwner__c;

        console.log('filters', filters)
        return filters;
    }

    get workGroupsList(){
        const result = [];

        for(let Id in this.workGroups){
            const Name = this.workGroups[Id];

            result.push({ Id, Name });
        }

        return result;
    }

    hookDataGrid = (target) => {
        this.handlerDataGrid = target;
    }

    onChangeFilter = (e) =>{
        const name = e.target.name;
        const value = e.target.value;

        this.filtersSelected = {
            ...this.filtersSelected,
            [name]: value
        };

        this.handlerDataGrid.applyFilters(this.filters);
    }

    onColumnsDefinition = (columns) => {
        const dataSearch = columns.filter((column)=>{
            return column.fieldName === 'CreatedDate';
        })

        if(dataSearch.length === 1){
            const CreatedDate = dataSearch[0];

            CreatedDate.typeAttributes = {
                month: "2-digit",
                day: "2-digit"
            }
        }

        console.log('columns', this.proxyData(columns));
        return columns;
    }

    connectedCallback() {
        super.connectedCallback();

        this.loadContext();
    }

    onViewAll(){
        this.navigateToLwc({
            component: 'lghtHistoryCaseStatus',
            state: {
                recordId: this.recordId
            }
        }, 'Case History Case')
    }

    onLoadDataGrid = (context) => {
        this.data = [...context.data];
    }

    async loadContext(){
        const response = await getWorkGroups({recordId: this.recordId});

        this.workGroups = response.workGroups;

        console.log('workGroups', this.proxyData(this.workGroups))
    }
    
    
}