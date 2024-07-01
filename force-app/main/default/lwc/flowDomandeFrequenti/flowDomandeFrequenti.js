import { LightningElement, api } from 'lwc';
import searchData from '@salesforce/apex/CommunityKnowledgeController.searchData';

export default class FlowDomandeFrequenti extends LightningElement {
    @api area;
    @api category;
    @api subCategory;
    @api searchString = '';
    articles;
    lastArea;
    lastCategory;
    lastSubcategory;

    // Utilizziamo un watcher per le proprietà per ricaricare gli articoli ogni volta che cambia un filtro
    @api
    set filters(value) {
        this.area = value.area;
        this.category = value.category;
        this.subCategory = value.subCategory;
        this.searchString = value.searchString;
        this.loadArticles();
    }
    get filters() {
        return {
            area: this.area,
            category: this.category,
            subCategory: this.subCategory,
            searchString: this.searchString
        };
    }
    connectedCallback() {
        this.loadArticles();
        this.lastArea = this.area;
        this.lastCategory = this.category;
        this.lastSubcategory = this.subCategory;
    }

    renderedCallback(){
        if(this.area !== this.lastArea || this.category !== this.lastCategory || this.subCategory !== this.lastSubcategory){
            this.loadArticles();
            this.lastArea = this.area;
            this.lastCategory = this.category;
            this.lastSubcategory = this.subCategory;
        }
    }
    loadArticles() {
        const filters = {
            area: this.area,
            category: this.category,
            subCategory: this.subCategory,
            stringToSearch: this.searchString,
            typeRequest: 'standard', // Assumendo che il tipo di richiesta sia sempre standard
            limitData: 5 // Numero di articoli da caricare, modificabile in base alle esigenze
        };
        console.log('Filters: ' + filters);
        console.log('Filters Stringhizzati: ' + JSON.stringify(filters));
        searchData({ dataMap: filters })
            .then(result => {
                this.articles = result.listKnowledge;
            })
            .catch(error => {
                console.error('Error retrieving articles:', error);
                this.articles = undefined;
            });
    }

    async searchByText({ target: { name, value } }) {
        if (value.length == 0) {
          const data = {
            typeRequest: 'standard',
            area: this.area,
            caterory: this.category,
            // subcategory
            stringToSearch: '',
            limitData: 10
          };
    
          await this.setSearchData(data);
    
        } else if (value.length > 3) {
          const data = {
            typeRequest: 'standard',
            area: this.area,
            caterory: this.category,
            // subcategory
            stringToSearch: value,
            limitData: 10
          };
    
          await this.setSearchData(data);
        }
      }
    
      async setSearchData(data) {
        const dataMap = { ...this.decrypt, ...data };
        console.log('dataMap', this.proxyData(dataMap));
        this.decrypt = await searchData({ dataMap });
        this.listKnowledge = this.decrypt.listKnowledge;
        console.log('searchData', this.proxyData(this.decrypt));
      }
 }