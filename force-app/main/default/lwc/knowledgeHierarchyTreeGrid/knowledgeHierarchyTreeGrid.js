import {  api, LightningElement } from 'lwc';

export default class KnowledgeHierarchyTreeGrid extends LightningElement {
    @api params;



    connectedCallback() {
    
        // initialize component     
        const param = 'c__recordId';
        var recordId = this.getUrlParamValue(window.location.href, param);

        this.params={
            "recId"				: recordId,
            "parentFieldAPIName": 'Parent_Article__c',
            "objectAPIname"		: 'Knowledge__kav',
            "columnLabelList"	:  ['Titolo articolo','Numero articolo','Data pubblicazione','Stato pubblicazione', 'Tipo di record'],
            "fieldAPINameList"	:['Title','ArticleNumber','LastPublishedDate','PublishStatus','RecordType.DeveloperName'],
            "hyperlinkColumn"	: "Title",
            "order": 'LastPublishedDate DESC'
        }

    }

    getUrlParamValue(url, key) {
        return new URL(url).searchParams.get(key);
      }

}