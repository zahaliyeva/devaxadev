import { LightningElement, api } from 'lwc';
import { MobilityAbstract } from 'c/mobilityAbstract';
import getNavigationConfiguration from '@salesforce/apex/MobilityDashboardUtility.getNavigationConfiguration';
import createNavigationConfiguration from '@salesforce/apex/MobilityDashboardUtility.createNavigationConfiguration';
import { MessageService } from 'c/messageService';

export default class MobilityDashboardStepSelection extends MobilityAbstract{

    @api results;
    @api metadata;
    @api getState;
    @api setState;
    @api setSelection;
    @api stepName;
    @api stepValue;
    @api targetPageName;
    @api targetPage;
    @api pageName;
    @api dashboardName;
    @api stepLabel;
    @api stepNumber;
    @api secondStepName;
    @api secondStepValue;
    @api metadataValue;
    @api profileName;
    @api profileFilter;
    @api variant;

    @api row;

    @api selectionCallback;

    targetPageId;
    canNavigate = false;
    infoExists = true;

    constructor(){
        super()
    }

    connectedCallback(){
        
                this.init();
        

    }

    get linkButtonClass() {
        if (this.variant === "primary") {
            return "link-button link-button--primary";
        }

        if (this.variant === "secondary") {
            return "link-button link-button--secondary";
        }
    
        return "link-button";
    }    

    async init(){
        let config = await getNavigationConfiguration({params:{
            dashboardName : this.dashboardName,
            currentPageName : this.pageName,
            targetPageName : this.targetPageName
            }
            
        });//get config from backend
        this.profileName = config.ProfileName;
        this.infoExists = config.currentPageExists
            
            //create config
        
        if(config.targetPageId){
            this.canNavigate = this.profileFilter ? this.profileFilter.includes(this.profileName) : true;
            this.targetPageId = config.targetPageId;
        }
        
    }

    navigate(event){
        if(this.selectionCallback){
            this.selectionCallback({index: this.stepNumber, pageId:this.targetPageId});
            return;
        }
        //console.log("state controllato: ", this.proxyData(this.getState()));
        var state = this.getState();
        /*var row = this.results[this.stepNumber];
        /*console.log(this.proxyData(row));
        state.state.steps[this.stepName].values = [this.proxyData(row)];//*/
        //state.state.steps[this.stepName].values = [this.proxyData(this.stepValue)];//*/
        //console.log("next state: ", this.proxyData(state))

        var rows = this.proxyData(this.results.filter( (element) =>{
            return element.Name === this.proxyData(this.stepValue);
        } ));
        if(rows){
            this.setSelection(rows)
        }

        
        //this.setSelection([this.proxyData(row)]);
        
        this.setState({pageId:this.targetPageId});
        
    }

    proxyData(data){
        return JSON.parse(JSON.stringify(data));
    }

    async createInfo(){
        let config = {
            dashboardName : this.dashboardName,
            currentPageId: this.getState().pageId,
            currentPageName: this.pageName
        }
        
        try{
            await createNavigationConfiguration({params: config});
            this.infoExists = true
        }
        catch (ex){
            this.infoExists = false;
        }
        

    }
}