import { LightningElement, track, api } from 'lwc';
//import faqContent from '@salesforce/apex/CommunityKnowledgeController.faqContent';
import decryptData from '@salesforce/apex/CommunityKnowledgeController.decryptData';
import searchData from '@salesforce/apex/CommunityKnowledgeController.searchData';
import voteArticle from '@salesforce/apex/CommunityKnowledgeController.voteArticle';
//import suggestionList from '@salesforce/apex/CommunityKnowledgeController.suggestionList';
//import suggestionSelected from '@salesforce/apex/CommunityKnowledgeController.suggestionSelected';

export default class CommunityKnowledge extends LightningElement {
  //LINK COMPONENTE
  @track urlParam;

  @track decrypt = {};
  @track dataFaq = [];
  @track options = [];
  @track showResult = false;
  @track activeSection = '';
  @track spinner = true;
  @track allowMultipleSectionsOpen = true;
  knowledgeId ='';

  @track buttons = {
    back: false,
    support: false
  };

  @track homePage = true;
  @track supportPage = false;

  get titleAccordion() {
    if (this.showResult) return 'Risultati Ricerca';
    return 'Domande più frequenti';
  }

  //SCRIPT
  connectedCallback() {
    this.initData();
  }

  //INPUT
  handleInput = (event) => {
    this.stringToSearch = event;
    this.searchInput(event, 'Suggest');
  };

  //CONNECTED CALLBACK QUERIES
  async initData() {
    this.spinner = true;
    const urlParams = new URLSearchParams(window.location.search);

    this.parameters = urlParams.get('parameters');
    this.decrypt = await decryptData({ body: this.parameters });

    console.log('parameters', this.parameters);
    console.log('decrypt', this.decrypt);
    const requestSearch = {
      dataMap: {
        ...this.decrypt,
        typeRequest: 'filter',
        limitData: 10
      }
    };

    this.decrypt = await searchData(requestSearch);
    this.updateActiveSection();
    this.spinner = false;
  }

  //SECOND QUERY FOR MAPPING
  async searchInput(stringToSearch, type) {
    if (stringToSearch.length >= 3) {
      let limit = type === 'Suggest' ? 3 : 5;
      const requestSearch = {
        dataMap: {
          ...this.decrypt,
          typeRequest: 'filter',
          limitData: limit,
          stringToSearch
        }
      };

      if (type === 'Suggest') {
        let tempDecrypt = await searchData(requestSearch);
        this.options = tempDecrypt.listKnowledge.map((element) => {
          const suggestions = {
            label: element.Title,
            value: element.Id
          };
          return suggestions;
        });
      } else if (type === 'Search') {
        this.decrypt = await searchData(requestSearch);
        this.updateActiveSection();
        this.options = [];
        this.decrypt.listKnowledge.array.forEach((element) => {
          element.disabled = false;
        });
      }
    }
  }

   updateActiveSection() {  
    this.activeSection = [];
    this.allowMultipleSectionsOpen = false;
    if(this.knowledgeId != ''){
      this.activeSection = [
        JSON.parse(JSON.stringify(this.decrypt.listKnowledge))[0].Title
      ];
      this.knowledgeId = '';
    }

    setTimeout(() => {
      this.allowMultipleSectionsOpen = true;
    }, 100);
  }

  async handleChange(event) {
    this.spinner = true;
    const pressEnter = event.target.enter;
    var knowledgeId;
    if (event.detail) {
      knowledgeId = event.detail.value;
    } else {
      knowledgeId = event.target.value;
    }
    console.log(knowledgeId);
	this.knowledgeId = knowledgeId;
    const requestSearch = {
      dataMap: {
        ...this.decrypt,
        typeRequest: 'filter',
        limitData: pressEnter ? 10 : 3
        //knowledgeId
      }
    };

    if (pressEnter) {
      requestSearch.dataMap.stringToSearch = this.stringToSearch;
    } else {
      requestSearch.dataMap.knowledgeId = knowledgeId;
    }

    this.decrypt = await searchData(requestSearch);

    console.log(JSON.parse(JSON.stringify(this.decrypt)));
    this.updateActiveSection();

    /*if (typeof this.decrypt.selectKnowledge != 'undefined' && this.decrypt.selectKnowledge != null) {
            const listResult = [];
            listResult.push(this.decrypt.selectKnowledge);
            this.activeSection = this.decrypt.selectKnowledge.Title;
            console.log(listResult);
            this.decrypt.listKnowledge = listResult;

        }*/

    this.showResult = true;
    this.buttons = {
      back: true,
      support: true
    };
    this.spinner = false;
  }

  async handleEnter(event) {
    const stringToSearch = event.target.value;
    if (stringToSearch.length >= 3) {
      this.decrypt.stringToSearch = stringToSearch;

      this.spinner = true;

      const requestSearch = {
        dataMap: {
          ...this.decrypt,
          typeRequest: 'filter',
          limitData: 10
        }
      };
      console.log('handleEnter', requestSearch);
      this.decrypt = await searchData(requestSearch);

      this.updateActiveSection();
      //this.decrypt.listKnowledge = listResult;
      this.showResult = true;
      this.buttons = {
        back: true,
        support: true
      };
      this.spinner = false;
    }
  }

  //BUTTON TORNA INDIETRO
  buttonBack() {
    this.initData();
    this.activeSection = null;
    this.buttons = {
      back: false,
      support: false
    };
  }


 //BUTTON CHIEDI ASSISTENZA
  buttonSupport() {
    var url_string = window.location.href;
    var url = new URL(url_string);
    var parametersValue = encodeURIComponent(url.searchParams.get("parameters"));
    window.location.href = '/crm/s/assistenza-nuovo-caso-new?parameters='+parametersValue;
  }
}