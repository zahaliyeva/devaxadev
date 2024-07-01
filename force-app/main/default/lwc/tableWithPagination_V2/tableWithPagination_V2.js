import { LightningElement, api, track } from 'lwc';
export default class TableWithPagination extends LightningElement {
   @api pageSize;
   @api collectionData;
   @api columns;
   @api dynamicFilters; // JSON object containing filter names and values
   @track totalRecords = 0;
   @track totalPages;
   @track pageNumber = 1;
   @track recordsToDisplay = [];
   @track previousFilters; // Track previous filters
   @track columnsToDisplay = [];

   defaultSortDirection = 'asc';
   sortDirection = 'asc';
   sortedBy;

   // Used to sort the 'Age' column
   sortBy(field, reverse, primer) {
    console.log('Sort');
       const key = primer
           ? function (x) {
                 return primer(x[field]);
             }
           : function (x) {
                 return x[field];
             };

       return function (a, b) {
           a = key(a);
           b = key(b);
           return reverse * ((a > b) - (b > a));
       };
   }

   onHandleSort(event) {

       const { fieldName: sortedBy, sortDirection } = event.detail;
       const cloneData = [...this.collectionData];

       cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
       this.collectionData = cloneData;
       this.sortDirection = sortDirection;
       this.sortedBy = sortedBy;
       this.paginationHelper();
   }


   connectedCallback(){
       this.columnsToDisplay = this.generateColumns();
       this.initFilterValues(); // Initialize filter values
       this.paginationHelper();
   }
   renderedCallback() {
       // Check if filter values have changed
       this.initFilterValues(); // Initialize filter values

       if (JSON.stringify(this.dynamicFilters) !== JSON.stringify(this.previousFilters)){
        this.columnsToDisplay = this.generateColumns();

           this.paginationHelper();
           this.previousFilters = JSON.parse(JSON.stringify(this.dynamicFilters)); // Deep copy
       }
   }
   initFilterValues() {
       // Parse JSON object for filters if provided
       if (this.dynamicFilters && typeof this.dynamicFilters === 'string') {
           try {
               this.dynamicFilters = JSON.parse(this.dynamicFilters);
               console.log('this.dynamicFilters: ',this.dynamicFilters);

           } catch (error) {
               console.error('Error parsing dynamic filters JSON:', error);
           }
       }
   }
   generateColumns(){
    /*
    console.log('Col:',this.columns);
    console.log('ParsCol:',JSON.parse(this.columns));
    const colnni = JSON.parse(this.columns).map(key => ({
        label: key.label,
        fieldName: key.fieldName,
        sortable: key.sortable,
        type: key.type,
        cellAttributes: key.cellAttributes,
        typeAttributes: key.typeAttributes,
        rowActions: key.rowActions,
        menuAlignment: key.menuAlignment
    }));
    console.log('colnni:',JSON.stringify(colnni));

       return colnni;*/
       return JSON.parse(this.columns);
   }
   paginationHelper() {
        console.log('!!!', this.collectionData);

       let filteredData = this.collectionData;
       console.log('!!!', filteredData);
       this.recordsToDisplay = [];
       console.log('filteredDataZZZ: ',JSON.stringify(filteredData),'for colonne:',this.columns);
       // Apply filtering based on filter values
       if (this.dynamicFilters) {
            console.log('What',this.columns);
           Object.keys(this.dynamicFilters).forEach(filterName => {
               const filterInfo = this.dynamicFilters[filterName];
               console.log('filterInfo: ',filterInfo);

               const targetFilter = filterInfo.targetFilter;
               console.log('targetFilter: ',targetFilter);

               const filterValue = filterInfo.filterValue;
               console.log('filterValue: ',filterValue);

               if ((targetFilter && filterValue) ) {
                   filteredData = filteredData.filter(item => item[targetFilter] === filterValue);
                   console.log('FilteredData: ',filteredData);
               }
           });
       }
       try {
       this.totalRecords = filteredData.length;
    } catch (error) {
        console.error('Error total record dynamic filters JSON:', error);
    }
       console.log('this.totalRecords: ',this.totalRecords);
       this.totalPages = Math.ceil(this.totalRecords / this.pageSize);
       console.log('this.totalPages: ',this.totalPages);

       if (this.pageNumber <= 1) {
           this.pageNumber = 1;
           console.log('this.pageNumber: ',this.pageNumber);

       } else if (this.pageNumber >= this.totalPages) {
        console.log('this.pageNumber: ',this.pageNumber);
    }
    if(this.totalRecords !== 0){

    for (let i = (this.pageNumber - 1) * this.pageSize; i < this.pageNumber * this.pageSize; i++) {
        if (i === this.totalRecords) {
            break;
        }
        this.recordsToDisplay.push(filteredData[i]);
        console.log('filteredDataZZZ: ',JSON.stringify(filteredData));
        console.log('collectionDataZZZ',JSON.stringify(this.collectionData));   
        console.log('recordsToDisplayZZZ',JSON.stringify(this.recordsToDisplay)); 
    }
    }else{
      this.columnsToDisplay = [
        { label: '', fieldName: 'Name',cellAttributes: { alignment: 'center' } },
      ];
      this.recordsToDisplay.push({Id: 1, Name: 'Non sono presenti dati da visualizzare.'});
     }
    }
   get bDisableFirst() {
       return this.pageNumber === 1;
   }
   get bDisableLast() {
       return this.pageNumber === this.totalPages;
   }
   previousPage() {
       if (!this.bDisableFirst) {
           this.pageNumber -= 1;
           this.paginationHelper();
       }
   }
   nextPage() {
       if (!this.bDisableLast) {
           this.pageNumber += 1;
           this.paginationHelper();
       }
   }
   firstPage() {
       if (!this.bDisableFirst) {
           this.pageNumber = 1;
           this.paginationHelper();
       }
   }
   lastPage() {
       if (!this.bDisableLast) {
           this.pageNumber = this.totalPages;
           this.paginationHelper();
       }
   }
}