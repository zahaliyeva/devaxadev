import { LightningElement, api, track } from 'lwc';
export default class TableWithPagination extends LightningElement {
   @api pageSize;
   @api collectionData;
   @api columns;
   @api targetFilter1;
   @api targetFilter2;
   @api targetFilter3;
   @api targetFilter4;
   @api targetFilter5;
   @api targetFilter6;
   @api targetFilter7;
   @api targetFilter8;
   @api targetFilter9;
   @api filterValue1;
   @api filterValue2;
   @api filterValue3;
   @api filterValue4;
   @api filterValue5;
   @api filterValue6;
   @api filterValue7;
   @api filterValue8;
   @api filterValue9;
   @track totalRecords = 0;
   @track totalPages;
   @track pageNumber = 1;
   @track recordsToDisplay = [];
   @track previousFilterValues = {};
   @track previousFilterValue1;
   @track countStep;
   connectedCallback(){
       this.columns = this.generateColumns();
       this.paginationHelper();
   }
   renderedCallback() {
       const currentFilterValues = {
           filterValue1: this.filterValue1,
           filterValue2: this.filterValue2,
           filterValue3: this.filterValue3,
           filterValue4: this.filterValue4,
           filterValue5: this.filterValue5,
           filterValue6: this.filterValue6,
           filterValue7: this.filterValue7,
           filterValue8: this.filterValue8,
           filterValue9: this.filterValue9
       };
       //console.log('Log:', currentFilterValues);

       if (JSON.stringify(currentFilterValues) !== JSON.stringify(this.previousFilterValues)){
       //if(this.previousFilterValue1 != this.filterValue1 ){
        console.log('Log:', currentFilterValues);

        this.paginationHelper()
        this.previousFilterValues = { ...currentFilterValues };
    }
   }
   generateColumns(){
       return JSON.parse(this.columns).map(key => ({
           label: key.label,
           fieldName: key.fieldName,
           type: key.type,
           cellAttributes: key.cellAttributes,
           typeAttributes: key.typeAttributes,
           rowActions: key.rowActions,
           menuAlignment: key.menuAlignment
       }));
   }
   paginationHelper() {
        this.countStep = this.countStep + 1;

       this.recordsToDisplay = [];
       let filteredData = this.collectionData;
       console.log('filteredData: ',JSON.stringify(filteredData));
       console.log('collectionData',JSON.stringify(this.collectionData));   
       console.log('recordsToDisplay',JSON.stringify(this.recordsToDisplay));    
       // Apply filtering logic based on filterValue and targetFilter
       for (let i = 1; i <= 3; i++) {
        if (this[`filterValue${i}`] &&  this[`targetFilter${i}`]) {
           const filterValue = this[`filterValue${i}`];
           const targetFilter = this[`targetFilter${i}`];
           console.log('item['+filterValue+targetFilter);

               filteredData = filteredData.filter(item => item['CaseNumber'] === filterValue);
 
           }
           console.log('filteredData: ',JSON.stringify(filteredData));
           console.log('collectionData',JSON.stringify(this.collectionData));   
           console.log('recordsToDisplay',JSON.stringify(this.recordsToDisplay));            
           this.totalRecords = filteredData.length;
           this.totalPages = Math.ceil(this.totalRecords / this.pageSize);
           console.log('this.totalPages V1: ',this.totalPages);

           if (this.pageNumber <= 1) {
               this.pageNumber = 1;
           } else if (this.pageNumber >= this.totalPages) {
               this.pageNumber = this.totalPages;
           }
  

       }
       for (let i = (this.pageNumber - 1) * this.pageSize; i < this.pageNumber * this.pageSize; i++) {
        if (i === this.totalRecords) {
            break;
        }
        this.recordsToDisplay.push(filteredData[i]);
        console.log('filteredData: ',JSON.stringify(filteredData));
        console.log('collectionData',JSON.stringify(this.collectionData));   
        console.log('recordsToDisplay',JSON.stringify(this.recordsToDisplay)); 
    }  
    this.previousFilterValue1 = this.filterValue1;
   }
   get bDisableFirst() {
       return this.pageNumber == 1;
   }
   get bDisableLast() {
       return this.pageNumber == this.totalPages;
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