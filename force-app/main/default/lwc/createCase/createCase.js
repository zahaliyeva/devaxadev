import ChangeDisplayedCategories from '@salesforce/apex/VFC26_AgentCreateCaseLightning.ChangeDisplayedCategories';
import ChangeDisplayedSub_Categories from '@salesforce/apex/VFC26_AgentCreateCaseLightning.ChangeDisplayedSub_Categories';
import SetPicklistInitialValues from '@salesforce/apex/VFC26_AgentCreateCaseLightning.SetPicklistInitialValues';
import SelectChatButtonId from '@salesforce/apex/VFC26_AgentCreateCaseLightning.SelectChatButtonId';
import CreateCaseCtrl from '@salesforce/apex/VFC26_AgentCreateCaseLightning.CreateCase';
import saveFiles from '@salesforce/apex/VFC26_AgentCreateCaseLightning.saveFiles';
import searchData from '@salesforce/apex/CommunityKnowledgeController.searchData';
import decryptData from '@salesforce/apex/CommunityKnowledgeController.decryptData';
import searchClient from '@salesforce/apex/CommunityKnowledgeControllerWithSharing.searchClient';
import searchInsurancePolicy from '@salesforce/apex/CommunityKnowledgeControllerWithSharing.searchInsurancePolicy';
import searchClientByNDG from '@salesforce/apex/CommunityKnowledgeControllerWithSharing.searchClientByNDG';
import searchPolicyByName from '@salesforce/apex/CommunityKnowledgeControllerWithSharing.searchPolicyByName';

import { LghtAbstract } from 'c/lghtAbstract';
import { track, api } from 'lwc';

export default class CreateCase extends LghtAbstract {
  @api parameters;
  @track isCaringSalute = false;
  @track areaOptions;
  @track categoryOptions;
  @track subCategoryOptions;
  @track decrypt = {};
  selectedArea;
  selectedCategory;
  categorizationId;
  agentName;
  theme;
  cPick;
  showTTP8Error;
  showModal;
  state = {};
  newCase = {};
  disableSubCategory;
  chatButtonId;
  visualizeButtons;
  listKnowledge;
  disableCreateCase = false;
  disableTriplet = false;
  selectedAccount;
  showModalAttachment = false;
  @track showTrattativeLM = false;
  @track caseIsCreated = false;
  @track filesUploaded = [];
  @track fileNames = [];
  @track warningMsg;
  MAX_FILE_SIZE = 2100000;
  MAX_SUM_FILE_SIZE = 10485760; //Max file dimension 10 MB
  sum_size_file = 0;
  showClientList = false;
  clientsOcurrences = [];
  selectedAccountName = '';
  showMessageErrorClientLookups = false;
  
  insurenceOcurrences = [];
  showInsurancePolicy = false;
  selectedInsurancePolicyNumber = '';
  selectedInsurancePolicy = '';
  hasSubCategory = false;

  get tripletDisabled() {
    return this.disableCreateCase || this.disableTriplet;
  }


  renderedCallback() {
    // const filterMenu = this.template.querySelector('lightning-button-menu');
    // console.log('have this data', filterMenu);
    // if (filterMenu) {
    //   filterMenu.classList.remove('slds-dropdown_left');
    //   filterMenu.classList.add('slds-dropdown_right');
    // }
  }

  connectedCallback() {
   
    this.loadInitialValues();
  }
  async loadInitialValues() {
    try {
      this.showSpinner();
      const urlParams = new URLSearchParams(window.location.search);
      this.parameters = urlParams.get('parameters');
    
      this.decrypt = await decryptData({ body: this.parameters });
    
      var account ={};  
  
      if(this.parameters!= null && this.decrypt.body.ndg !='' && typeof this.decrypt.body.ndg !== undefined ){
        account = await searchClientByNDG({ndg:this.decrypt.body.ndg});      
            if(account.length >0){
              this.selectedAccount = account[0].Id;
              this.selectedAccountName = account[0].Name;
              this.template.querySelector('[data-id="inputAccountName"]').value=account[0].Name;
            }
      }
 
      var policy ={};
      if(this.parameters!= null && this.decrypt.body.polizza !='' &&  typeof this.decrypt.body.polizza !== undefined ){
        policy = await searchPolicyByName({name:this.decrypt.body.polizza});
          if(policy.length >0){
              this.selectedInsurancePolicyNumber = policy[0].Name;
              this.selectedInsurancePolicy =  policy[0].Id;
              this.showInsurancePolicy = false;
              this.template.querySelector('[data-id="inputPolicyName"]').value=policy[0].Name;
            }
      }

      const data = {
        ...this.decrypt,
        typeRequest: 'standard',
        limitData: 5
      };

      await this.setSearchData(data);
      //TODO: set area id from autoload data

      const picklistValues = await SetPicklistInitialValues();
      console.log(
        'connected',
        picklistValues,
        JSON.parse(JSON.stringify(this.decrypt))
      );
      const areaOptions = picklistValues.Lob.map((element) => ({
        label: element,
        value: element.replace(/ /g, '_').toLowerCase()
      }));
      areaOptions.unshift({ label: '--Selezionare Area--', value: '' });
      this.areaOptions = areaOptions;
      this.setLoadValues(picklistValues);
      this.hideSpinner();

      this.newCase.LOB__c = this.decrypt.body.processo.toLowerCase();
      let chossenArea = this.areaOptions.find(
        (element) => element.value == this.decrypt.body.processo.toLowerCase()
      );
      this.handleAreaChange({
        target: {
          name: chossenArea.label,
          value: this.decrypt.body.processo
        }
      });
    } catch (error) {
      console.error(error);
      this.hideSpinner();
    }
  }

  setLoadValues(picklistValues) {
    const { Agency_Code__c, Name } = picklistValues.AgentInfos;
    this.newCase.User__c = picklistValues.AgentId;
    this.newCase.Agency_Code__c = Agency_Code__c;
    this.categorizationId = picklistValues.OrgId;
    this.agentName = `${Name}, Agenzia ${Agency_Code__c}`;
    this.theme = picklistValues.Theme;
    this.chatEndpoint = picklistValues.Chat_Endpoint;
    this.catDeploymentUrl = picklistValues.Chat_deploymentUrl;
    this.chatDeploymentId = picklistValues.Chat_deploymentId;
    this.cPick = picklistValues;
  }

  get isSelectedArea() {
    return !!this.state.hasOwnProperty('area') && !!this.state.area;
  }

  handleAreaChange = async ({ target: { name, value } }) => {
    try {
      let chossenArea = this.areaOptions.find(
        (element) => element.value === value.toLowerCase()
      );
      this.showSpinner();
      this.newCase.LOB__c = value.replace(/ /g, '_').toLowerCase();
      if (value === 'Sinistri Salute') {
        this.isCaringSalute = true;
      }
      this.newCase.Category__c = '';
      this.newCase.SubCategory__c = '';
      this.selectedArea = chossenArea.label;
      await this.setCategoriesValues();
      await this.searchDataLikes();
      await this.loadChatButtonId();
      this.template.querySelector('c-live-agent-chat-button-l-w-c')?.init();
      this.hideSpinner();
    } catch (error) {
      console.error(error);
      this.hideSpinner();
    }
    // this.state = { ...this.state, [name]: value };
  };

  async setCategoriesValues() {
    const categories = await ChangeDisplayedCategories({
      Selected_Lob: this.selectedArea,
      Cpick: JSON.stringify(this.cPick)
    });
    this.cPick = categories;
    const { ShowTTP8Error } = categories;
    console.error(ShowTTP8Error);
    this.showTTP8Error = ShowTTP8Error;
    if (!!ShowTTP8Error) {
      this.showModal = true;
      return;
    }
    this.subCategoryOptions = [
      { label: '--Selezionare Sotto Categoria--', value: '' }
    ];
    const categoryOptions = categories.Category.map((element) => ({
      value: element.replace(/([ ])/, '_'),
      label: element
    }));
    categoryOptions.unshift({ label: '--Selezionare Categoria--', value: '' });
    this.categoryOptions = categoryOptions;
  }

  async searchDataLikes() {
    const data = {
      typeRequest: 'standard',
      area: this.selectedArea.replace(' ', '_'),
      // caterory: '',
      // subcategory
      // stringToSearch: '',//Oggeto
      limitData: 10
    };
    if (this.selectedCategory) {
      data.category = this.selectedCategory;
    }

    if (this.selectedSubcategory) {
      data.subCategory = this.selectedSubcategory;
    }
    if (this.stringToSearch) {
      data.stringToSearch = this.stringToSearch;
    }else  data.stringToSearch='';
    await this.setSearchData(data);
  }

   async searchByText({ target: { name, value } }) {
    if (value.length == 0) {
      const data = {
        typeRequest: 'standard',
        area: this.newCase.LOB__c,
        caterory: this.newCase.Category__c,
        // subcategory
        stringToSearch: '',
        limitData: 10
      };

      await this.setSearchData(data);

    } else if (value.length > 3) {
      const data = {
        typeRequest: 'standard',
        area: this.newCase.LOB__c,
        caterory: this.newCase.Category__c,
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

  handleCategoryChange = async ({ target: { name, value } }) => {
    try {
      this.showSpinner();
      this.hasSubCategory=false;
      this.selectedCategory = value;
      this.newCase.Category__c = value;
      this.newCase.SubCategory__c = '';
      let subCategoryInput = this.template.querySelector('[data-id="inputSubcategory"]');
      await this.setSubcategoryOptions();
      await this.searchDataLikes();
      if(subCategoryInput.checkValidity()) {
        subCategoryInput.reportValidity();
      }
      this.disableTriplet = this.subCategoryOptions.length == 1 && this.subCategoryOptions[0].value == '';
      this.template.querySelector('c-live-agent-chat-button-l-w-c')?.init();
      this.hideSpinner();
    } catch (error) {
      console.error(error);
      this.hideSpinner();
    }
  };

  async setSubcategoryOptions() {
    let chossenArea = this.areaOptions.find(
      (element) => element.value === this.newCase.LOB__c
    );

    const subCategories = await ChangeDisplayedSub_Categories({
      //      Selected_Lob: this.newCase.LOB__c,
      Selected_Lob: chossenArea.label,
      Selected_Category: this.newCase.Category__c.replaceAll('_', ' '),
      Cpick: JSON.stringify(this.cPick)
    });
    this.disableSubCategory = subCategories.DisableSubCat;
    this.cPick = subCategories;
    this.hasSubCategory = subCategories.SubCategory.length > 0;
    this.newCase.RecordTypeId = subCategories.CaseType;
    const subCategoryOptions = subCategories.SubCategory.map((subCategory) => ({
      label: subCategory,
      value: subCategory.replaceAll(' ', '_')
    }));
    subCategoryOptions.unshift({
      label: '--Selezionare Sotto Categoria--',
      value: ''
    });
    this.subCategoryOptions = subCategoryOptions;
    if (this.disableSubCategory) {
      this.newCase.SubCategory__c = '';
    }
    const selectChatButton = await SelectChatButtonId({
      //      Selected_Lob: this.newCase.LOB__c,
      Selected_Lob: chossenArea.label?.replaceAll('_', ' '),
      Selected_Category: this.newCase.Category__c ? this.newCase.Category__c.replaceAll('_', ' ') : null,
      Selected_SubCategory: this.newCase.SubCategory__c ? this.newCase.SubCategory__c.replaceAll('_', ' ') : null,
      Cpick: JSON.stringify(this.cPick)
    });
    console.log('is selected chatbutton', selectChatButton);
    // import(selectChatButton.Chat_deploymentUrl).then((data) => {
    //     console.log(data);
    // });
    this.chatButtonId = selectChatButton.ButtonId;
    this.visualizeButtons = true;
    const category = !!this.newCase.Category__c ?? '';
    const subCategory = !!this.newCase.SubCategory__c ?? '';
    const area = !!chossenArea.label ?? '';
    //    const area = !!this.newCase.LOB__c ?? '';
    // var myEvent = component.getEvent("SendCategoryToFAQCmpEvent");
    //                         myEvent.setParams({"Category": Category,
    //                                            "SubCategory" : SubCategory,
    //                                            "Lob" : Lob});
    //                         myEvent.fire();
  }

  async handleSubCategoryChange({ target: { name, value } }) {
    if (value.replaceAll('_',' ') == 'Trattative nuovi libro matricola')
      this.showTrattativeLM = true;

    this.selectedSubcategory = value;
    await this.searchDataLikes();
    await this.loadChatButtonId();
  	this.newCase.SubCategory__c = value;
    this.disableTriplet = true;
    this.template.querySelector('c-live-agent-chat-button-l-w-c')?.init();

  }

  async loadChatButtonId() {
    const selectChatButton = await SelectChatButtonId({
      Selected_Lob: this.selectedArea?.replaceAll('_', ' '),
      Selected_Category: this.newCase.Category__c ? this.newCase.Category__c.replaceAll('_', ' ') : null,
      Selected_SubCategory: this.selectedSubcategory ? this.selectedSubcategory.replaceAll('_', ' ') : null,
      Cpick: JSON.stringify(this.cPick)
    });
    this.chatButtonId = selectChatButton.ButtonId;
  }

  async handleOggettoChange(event) {
    this.newCase.Subject = event.target.value;

    if (event.target.value.length == 0) {
      this.stringToSearch = '';
      await this.searchDataLikes();

    } else if (event.target.value.length > 3) {
      this.stringToSearch = event.target.value;
      await this.searchDataLikes();
    }

  }
  
  handleAccountSelection(event) {
    this.selectedAccountName = event.currentTarget.dataset.name;
    this.template.querySelector('[data-id="inputAccountName"]').value=event.currentTarget.dataset.name;
    this.showClientList = false;
    this.selectedAccount = event.currentTarget.dataset.value;
    this.checkClientField();
  }

  handleInsurancePolicySelection(event){
	this.selectedInsurancePolicyNumber = event.currentTarget.dataset.name;
    this.template.querySelector('[data-id="inputPolicyName"]').value=event.currentTarget.dataset.name;
    this.showInsurancePolicy = false;
    this.selectedInsurancePolicy = event.currentTarget.dataset.value;
    //this.checkClientField();
  }

  newRequest() {
    window.location.href = window.location.href;
  }

  SendToSupport() {
    if (this.selectedAccount) this.newCase.AccountId = this.selectedAccount;

    if (this.selectedInsurancePolicy) this.newCase.LinkToPolicy__c = this.selectedInsurancePolicy;

    this.disableCreateCase = true;

    var cat = this.newCase.Category__c;
    var object = this.newCase.Subject;
    var description = this.newCase.Description;
    var trattativeLM = this.showTrattativeLM;
    var nomeSocieta = this.newCase.Nome_Societa__c;
    var pIva = this.newCase.P_Iva__c;
    var broker = this.newCase.Broker_Coinvolto__c;
   console.log(cat+object+description);
    if (
      (cat && object && description && !trattativeLM) ||
      (cat &&
        object &&
        description &&
        trattativeLM &&
        nomeSocieta &&
        pIva &&
        broker)
    ) {
      this.newCase.Category__c=this.newCase.Category__c.replaceAll('_', ' ');
      this.newCase.SubCategory__c =   this.newCase.SubCategory__c.replaceAll('_', ' ');
      this.newCase.LOB__c=this.newCase.LOB__c.replaceAll('_', ' ');
      console.log(' this.newCase',  this.newCase);
      this.showSpinner();
      CreateCaseCtrl({ NewCase: this.newCase })
        .then((result) => {
          console.log('CreateCase', result);
          if (result.ResultStatus != 'OK')
            throw new Error(
              "L'invio della richiesta non è andato a buon fine a causa del seguente errore: \n" +
                result.ResultMsg +
                '.\n\nRiprova più tardi, se il problema persiste contattaci telefonicamente'
            );

          var caseId = result.CaseId;
          debugger;   
          if (this.filesUploaded.length > 0) {
            let testo = JSON.stringify(this.filesUploaded);
            console.log('testo: ' + testo);
            saveFiles({
              filesToInsert: testo,
              parentId: caseId
            }).then((result) => {
              console.log('File salvato - 449');
              this.successMessage(
                '',
                'La tua richiesta è stata inviata con successo'
              );
          this.hideSpinner();    
          window.location.href = '/crm/s/assistenza';
              this.caseIsCreated = true;
              });
          }
          else{
            this.successMessage(
              '',
              'La tua richiesta è stata inviata con successo'
            );
        this.hideSpinner();    
        window.location.href = '/crm/s/assistenza';
            this.caseIsCreated = true;
          }  
          
        }) 
        .catch((err) => {
          this.alertMessage(err.message);
        }) 
        .finally(() => {
          this.disableCreateCase = false;
        });
    } else {
      this.disableCreateCase = false;
      this.alertMessage(
        'Attenzione !',
        'Per inoltrare una nuova richiesta compilare tutti i campi obbligatori indicati dal carattere *'
      );
    }
  }

  onModalAttachmentOpen = () => {
    this.showModalAttachment = true;
  };

  onModalAttachmentClose = () => {
    this.showModalAttachment = false;
  };

  // getting file
  handleFilesChange(event) {
    this.warningMsg = '';

    let files = event.target.files;

    if (files.length > 0) {
      for (let i = 0; i < files.length; i++) {
        let file = files[i];
        if (!this.fileNames.includes(file.name)) {
          if (file.size <= this.MAX_FILE_SIZE) {
            if (file.size + this.sum_size_file <= this.MAX_SUM_FILE_SIZE) {
              this.sum_size_file = this.sum_size_file + file.size;
              console.log(' this.sum_size_file' + this.sum_size_file);
              let freader = new FileReader();
              freader.onload = (f) => {
                let base64 = 'base64,';
                let content = freader.result.indexOf(base64) + base64.length;
                let fileContents = freader.result.substring(content);
                this.filesUploaded.push({
                  Title: file.name,
                  VersionData: fileContents,
                  Type: file.type,
                  Size: file.size
                });
                this.fileNames.push(file.name);
              };
              freader.readAsDataURL(file);
            } else
              this.warningMsg =
                "Attenzione, la dimensione massima consentita per l'insieme degli allegati è pari a 10 MB.";
          } else
            this.warningMsg =
              'Attenzione, la dimensione massima consentita per il singolo allegato è pari a 2 MB.';
        } else
          this.warningMsg =
            'Attenzione, il file selezionato è già stato inserito';
      }

      console.log('this.filesUploaded all', this.filesUploaded);
    }
  }

  doCancel(event) {
    let selectedFile = event.target.dataset.name;
    var sum = this.sum_size_file;
    this.filesUploaded = this.filesUploaded.filter(function (file) {
      if (file.Title == selectedFile) {
        sum = sum - file.Size;
      }
      return file.Title != selectedFile;
    });
    this.fileNames = this.fileNames.filter(function (fileName) {
      return fileName != selectedFile;
    });
    this.sum_size_file = sum;
    console.log('this.sum_size_file' + this.sum_size_file);
  }

  get showModal() {
    return this.showModal && this.showTTP8Error;
  }

  onFocusClient() {
    this.showClientList = true;
    this.checkClientField();
  }

  onBlurClient() {
    setTimeout(() => {
      this.showClientList = false;
    }, 500);
    this.checkClientField();
  }

  onChangeClient(e) {
    this.selectedAccount = '';
    if (e.target.value === '') {
      this.clientsOcurrences = [];
      return;
    }
    searchClient({ clientName: e.target.value }).then((response) => {
      this.clientsOcurrences = response;
    });
  }

  onFocusInsurance() {
    this.showInsurancePolicy = true;
    //this.checkClientField();
  }

  onBlurInsurance() {
    setTimeout(() => {
      this.showInsurancePolicy = false;
    }, 500);
    //this.checkClientField();
  }

  onChangeInsurance(e) {
    this.selectedInsurancePolicy = '';
    if (e.target.value === '') {
      this.insurenceOcurrences = [];
      return;
    }
    searchInsurancePolicy({ searchString: e.target.value }).then((response) => {
      this.insurenceOcurrences = response;
    });
  }


  checkClientField() {
    let currentAccountName = this.template.querySelector('[data-id="inputAccountName"]')?.value;
    this.showMessageErrorClientLookups =
      currentAccountName !== '' &&
      (this.selectedAccount === '' || this.selectedAccount === undefined);
  }

  handleDescriptionChange(event){
    this.newCase.Description = event.target.value;
  }

  handleNomeSocietaChange(event){
    this.newCase.Nome_Societa__c = event.target.value;
  }

  handleTargaChange(event){
    this.newCase.Targa__c = event.target.value;
  }

  handlePIvaChange(event){
    this.newCase.P_Iva__c = event.target.value;
  }

  handleBrokerChange(event){
    this.newCase.Broker_Coinvolto__c = event.target.value;
  }

  setPageToReadOnly() {
    this.disableCreateCase = true;
  }

  
}