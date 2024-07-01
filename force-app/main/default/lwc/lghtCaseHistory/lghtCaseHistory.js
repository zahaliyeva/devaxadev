import { LightningElement, api, track } from 'lwc';
import { LghtAbstract } from 'c/lghtAbstract';

import getWorkGroups from '@salesforce/apex/LghtCaseHistoryController.getWorkGroups';

export default class LghtHistoryCaseStatus extends LghtAbstract {
    
    @api recordId;
    @api viewAll = false;
    
    @track filtersSelected = {
        Activity__c: '',
        Gruppo_di_lavoro__c: '' 
    };

    @track workGroups = {};
    @track data = [];

    componentView = 'LghtCaseHistory';
    handlerDataGrid;

    get filters(){
        const Activity__c = (this.filtersSelected.Activity__c !== '') ? [this.filtersSelected.Activity__c] : null;
        const Gruppo_di_lavoro__c = (this.filtersSelected.Gruppo_di_lavoro__c !== '') ? [this.filtersSelected.Gruppo_di_lavoro__c] : null;

        const filters = {
            Case__c: [this.recordId]
        };

        if(Activity__c) filters.Activity__c = Activity__c;
        if(Gruppo_di_lavoro__c) filters.Gruppo_di_lavoro__c = Gruppo_di_lavoro__c;

        console.log('filters', filters)
        return filters;
    }

    get workGroupsList(){
        const result = [];

        for(let Name in this.workGroups){
                result.push({ Name, Name });
        }

        return result;
    }

    get perPage(){
        return (this.viewAll) ? 3 : 9999;
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
                    year: "numeric",
                    month: "2-digit",
                    month: "2-digit",
                    day: "2-digit", 
                    day: "2-digit",
                    hour: "2-digit",
                    minute: "2-digit", 
                    second: "2-digit"
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
            component: 'lghtCaseHistory',
            state: {
                recordId: this.recordId
            }
        }, 'Case History Case')
    }

    onLoadDataGrid = (context) => {
        this.data = [...context.data];
       /* console.log('Results', this.proxyData(this.data));
        for (var i = 0; i < this.data.length; i++) {
            var row = this.data[i];
            if (row.Case__r) row.Current_Owner_Queue__c = row.Case__r.Current_Owner_Queue__c;
        }*/
        console.log('Results', this.proxyData(this.data));
    }

    async loadContext(){
        const response = await getWorkGroups({recordId: this.recordId});

        this.workGroups = response.workGroups;

        console.log('workGroups', this.proxyData(this.workGroups))
    }
    
    
}