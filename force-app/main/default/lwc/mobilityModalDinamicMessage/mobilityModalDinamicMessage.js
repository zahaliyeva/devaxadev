import {
	MobilityAbstract
} from 'c/mobilityAbstract';
import {
	api
} from 'lwc';

import getLayoutModal from '@salesforce/apex/mobilityModalDinamicMessageCTRL.getLayoutDefinitionModal';

export default class MobilityModalDinamicMessage extends MobilityAbstract {

    @api nameLayout;
    @api campaignName;
    @api primaryCallback;
    @api backCallback;
    @api reportDownloadLink;
    @api replaceVariables;

    customLayout={};

    @api inputLayout;

    connectedCallback() {
		super.connectedCallback();
        this.loadData();
        
		this.hideSpinner();

	}
    async loadData() {
        
        if(!this.inputLayout ){
            let result =  await getLayoutModal({
                layoutName: this.nameLayout, //this.nameLayout
                reportLink: 'temp' //this.nameLayout
            }).catch((err) => {
                console.log('err', this.proxyData(err));
            }).finally(() => {
                this.hideSpinner();
                
            })
            this.customLayout = result;
            this.handleData();
            
        }else this.customLayout = this.inputLayout;
            
        
        
        console.log(this.proxyData(this.customLayout));
    }
    primaryCallback(){
        this.actionCallback(); 
    }
    backCallback(){
        this.backCallback();
    }

    handleData(){
        try{
            let button = this.customLayout.sections[0].fields;
            button.forEach(e => {
                e.isPrimary = e.type.toLowerCase() === "back" ? false: true;
            });

            this.customLayout.sections[0].fields.sort((a,b) => (a.isPrimary ? 1 : -1));
            
            let sections = this.customLayout.sections;
            sections.forEach(e => this.handleReplacement(e));

        }catch(exc) {
            console.log(exc);
        }
        
    }


    handleReplacement(e){
        if(e && e.name && e.name.indexOf("$$") >0 ){
            e.name = this.replaceBetweenDollars(e.name);
        }
        if(e && e.subName && e.subName.indexOf("$$") >0 ){
            e.subName = this.replaceBetweenDollars(e.subName);
        }
        if(e && e.underSubName && e.underSubName.indexOf("$$") >0 ){
            e.underSubName = this.replaceBetweenDollars(e.underSubName);
        }
    }

    replaceBetweenDollars(text){
        var splitted = text.split("$$");
        var resArray = [];

        splitted.forEach((e) => { 
            resArray.push(this.replaceVariables[e] ? this.replaceVariables[e] : e);
        })

        return resArray.join("");

    }

    get sections() {
        return this.customLayout && this.customLayout.sections
            ? this.customLayout.sections.map(s => ({...s, cssClass: this.getSectionClasses(s)}))
            : []
    }

    getSectionClasses(section) {
        return section && section.isUsingIcon
            ? 'modal-style__column col-md-8 mx-auto text-center'
            : 'modal-style__column col-md-8 mx-auto'
    }
}