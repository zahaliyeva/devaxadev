import { LightningElement, api, track } from 'lwc';
import { LghtAbstract } from 'c/lghtAbstract';

import getCommunications from '@salesforce/apex/LghtCaseCommunicationsController.getCommunications';

export default class LghtCaseCommunications extends LghtAbstract {
    
    @api recordId;
    @api viewAll = false;
    
    @track filtersSelected = {
        Type: ''
    };

    @track data = [];

    componentView = 'LghtCaseCommunications';
    handlerDataGrid;

    get dataFiltered(){
        const formatedData = [];
        this.data.forEach((element)=>{
            formatedData.push({...element, Channel: {title: element.TypeLabel, content: element.Channel}})
        })

        const ordenedData = formatedData.sort((elementA, elementB)=>{
            return (elementA.StartDate < elementB.StartDate) ? 1 : -1;
        });

        const limitedData = (!this.viewAll) ? ordenedData : ordenedData.slice(0,5);

        if(!this.filtersSelected.Type) return limitedData;

        return limitedData.filter((element)=>{
            return element.Type === this.filtersSelected.Type;
        })
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

        this.handlerDataGrid.applyData(this.dataFiltered);
    }

    getColumn = (columns, name) => {
        const dataSearch = columns.filter((column)=>{
            return column.fieldName === name;
        })

        if(dataSearch.length === 1) return dataSearch[0];

        return null;
    }

    onColumnsDefinition = (columns) => {
        const StartDate = this.getColumn(columns, 'StartDate');

        if(StartDate){
            StartDate.typeAttributes = {
                year: "numeric",
                month: "2-digit",
                day: "2-digit",
                hour: "2-digit",
                minute: "2-digit", 
                second: "2-digit"
            }
        }
        const Image = this.getColumn(columns, 'Image');
        if(Image){
            Image.initialWidth = 80;
        }

        const Channel = this.getColumn(columns, 'Channel');
        if(Channel){
            Channel.initialWidth = 350;
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
            component: 'LghtCaseCommunications',
            state: {
                recordId: this.recordId
            }
        })
    }

    onLoadDataGrid = (context) => {
        //this.data = [...context.data];
    }

    async loadContext(){
        console.log('loadContext');
        const response = await getCommunications({recordId: this.recordId});

        this.data = response.elements;

        console.log('elements', this.proxyData(this.data))

        this.hideSpinner();
    }
    
    
}