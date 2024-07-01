//standard import
import { LightningElement, api, track, wire } from 'lwc';
import { getRecord, getRecordNotifyChange } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';


//custom import
import init from "@salesforce/apex/lghtCreateCaseWithAttrCTRL.Init";
import searchAgent from "@salesforce/apex/lghtCreateCaseWithAttrCTRL.searchAgent";
import associateCase from "@salesforce/apex/lghtCreateCaseWithAttrCTRL.associateCase";


export default class LghtCreateCaseWithAttr extends NavigationMixin(LightningElement) {


    @api recordId;
    showError;
    showSpinner = true;
    InitWrapper = {
        needSearch : false,
        FirstName : '',
        LastName : '',
        AgencyCode : '',
        AgentCode : ''
    }
    


    @track CaseList;
    @track AgentsList;
    showCases = false;
    showAgents = false;
    CaseDefaultValues;

    

    handleChange(event){
        this.InitWrapper[event.target.name] = event.target.value;
    }

    connectedCallback() {
        //init with recordId
        this.initComponent();
    }
    
    async initComponent(){
        var result = await init({VCId : this.recordId});
        if(result != null){
            if(result.isSuccess){
                console.log('result', result);
                this.InitWrapper = result.InitWrapper;
                this.CaseList = result.CasesList;
                this.normalizeCases(this.CaseList);
                this.CaseDefaultValues = result.cToCreate;
            }
            else{
                this.showError = true;
            }
        }
        console.log(this.InitWrapper);
        this.showSpinner = false;
    }

    async handleSearch(){
        this.showSpinner = true;
        this.showCases = false;
        this.CaseList = [];
        var result = await searchAgent({VCId : this.recordId, request: this.InitWrapper});
        this.normalizeSearch(result);
        var agentList = result.listResult;
        if(agentList.length > 0){
            agentList.forEach(function(item) {                   
            item.Agenzia= result.AgentToAgencyMap[item.user.Id].Name;
            item.AgenziaAttiva= result.AgentToAgencyMap[item.user.Id].Active__c;
            item.AgenziaId= result.AgentToAgencyMap[item.user.Id].Id;
            });
            this.showAgents = true;
        }
        this.AgentsList = agentList;
        console.log(agentList);
        this.showSpinner = false;
    }
 
    handleShowCases(event){
        this.showCases = false;
        if(event.target.dataset != null){
            var userId = event.target.dataset.userid;
            //console.log(JSON.parse(JSON.stringify(this.AgentsList)));
            if(this.AgentsList != null)
                for(var item of this.AgentsList){
                    console.log(item);
                    if(item.user.Id === userId){
                        this.CaseList = item.cases;
                    }
                }
        }
        console.log(this.CaseList);
        this.showCases = true;
    }

    handleShowSearch(){
        this.showSpinner = true;
        this.InitWrapper = {
            needSearch : true,
            FirstName : '',
            LastName : '',
            AgencyCode : '',
            AgentCode : this.InitWrapper.AgentCode
        }
        this.CaseList = [];
        this.showCases = false;
        
        this.showSpinner = false;
    }
    
    normalizeCases(cases){
        for(let caseIndex in cases){
            const caseData = cases[caseIndex];
            
            const createdDate = new Date(caseData.CreatedDate);

            let day = createdDate.getDate();
            if(day < 10) day = `0${day}`;

            let month = createdDate.getMonth() + 1;
            if(month < 10) month = `0${month}`;

            let year = createdDate.getFullYear();

            let hour = createdDate.getHours();
            if(hour < 10) hour = `0${hour}`;

            let minute = createdDate.getMinutes();
            if(minute < 10) minute = `0${minute}`;

            let second = createdDate.getSeconds();
            if(second < 10) second = `0${second}`;

            caseData.CreatedDateString = `${day}/${month}/${year} ${hour}:${minute}:${second}`;
        }
    }

    normalizeSearch(result){
        for(let index in result.listResult){
            const context = result.listResult[index];
            this.normalizeCases(context.cases);
            
        }
    }

    normalizeAgentCode(code){
        return code.replace('AG', '').replace('A', '');
    }

    async handleAssociate(event){
        this.showSpinner = true;
        if(event.target.dataset){
            var CaseId = event.target.dataset.caseid;
            var result = await associateCase({VCId : this.recordId, CaseId : CaseId, Type: 'Agenti'});
            this.showSpinner = false;            
        }
        
    }

    handleCreate(event){
        if(event.target.dataset){
            if(event.target.dataset.userid){
                this.CaseDefaultValues.User__c = event.target.dataset.userid;
            }
            if(event.target.dataset.agentcode){
                this.CaseDefaultValues.TECH_Agent_Code__c = this.normalizeAgentCode(event.target.dataset.agentcode);
            }
        }
        this[NavigationMixin.Navigate](this.preparePageRef('new'));
    }

    handleRedirect(event){
        if(event.target.dataset){
            if(event.target.dataset.caseid){
                this[NavigationMixin.Navigate](this.preparePageRef('view', event.target.dataset.caseid));
            }
        }
    }

    preparePageRef(actionName, caseId){
        if(actionName === 'new'){
            const defaultValues = encodeDefaultFieldValues(this.CaseDefaultValues);
            return {
                type: 'standard__objectPage',
                attributes: {
                    objectApiName: 'Case',
                    actionName: 'new'
                },
                state: {
                    defaultFieldValues : defaultValues,
                    nooverride: '1',
                    recordTypeId: this.CaseDefaultValues.RecordTypeId
                }
            }
        }
        else if(actionName === 'view'){
            return {
                type: 'standard__recordPage',
                attributes: {
                    recordId: caseId,
                    objectApiName: 'Case', // objectApiName is optional
                    actionName: 'view'
                }
            }
        }
    }
}