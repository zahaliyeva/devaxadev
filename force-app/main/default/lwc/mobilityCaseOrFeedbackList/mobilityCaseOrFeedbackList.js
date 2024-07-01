import { MobilityAbstract } from "c/mobilityAbstract";
import { DataGridModel } from 'c/dataGridModel';
import { track } from 'lwc';
import caseController from '@salesforce/apex/mobilityCaseOrFeedbackController.getCase';
import feedBackController from '@salesforce/apex/mobilityCaseOrFeedbackController.getFeedBacks';

export default class MobilityCaseOrFeedbackList extends MobilityAbstract {
    @track Case = {};
    @track FeedBack = {};
    @track ndgId;
    @track type;
    @track perPage;
    ShowCase = false;
    ShowFeedback = false;



    connectedCallback() {
        super.connectedCallback();
        if ([this.params.type] == 'Feedback') {
            this.ShowFeedback = true;
            this.loadFeedBack();
        } else if ([this.params.type] == 'Case') {
            this.ShowCase = true;
            this.loadcase();
        }
    }

    proxyData(proxyObj) {
        return JSON.parse(JSON.stringify(proxyObj));
    }

    redirectCase(recordId) {
        window.open('/crm/s/case/' + recordId);
    }

    redirectCasenumberToId() {
        window.open('/crm/s/case/' + this.element.Id);
    }
    redirectCasenumberToId2() {
        window.open('/crm/s/case/' + this.element.CTL_Case__c);
    }
    redirectFeedback(recordId) {
        window.open('/crm/apex/javascriptIntegration?component=mobilityCustomDetailPage&id=mobilityCustomDetailPage&showContain=true&recordId=' + recordId + '&recordType=Feedback__c&title=Feedback');
    }
    redirectFeedbackNameToId() {
        window.open('/crm/apex/javascriptIntegration?component=mobilityCustomDetailPage&id=mobilityCustomDetailPage&showContain=true&recordId=' + this.element.Id + '&recordType=Feedback__c&title=Feedback');
    }
    loadcase() {
        let tableData = {};
        tableData.showFilter = false;
        tableData.showSearch = false;
        tableData.perPage = this.params.perPage;
        tableData.encodes = {
            Owner: {
                valueBadge: value => (value.Name),
                type: 'BADGE',
                colors: value => {
                    if (value.Profile) {
                        if (value.Profile.Name) {
                            if (!value.Profile.Name.startsWith('NFE')) {
                                return '#cb3234';
                            } else {
                                return '#00ADC6'
                            }
                        } else {
                            return '#00ADC6'
                        }
                    } else if (!value.Name.toLowerCase().startsWith('Coda Agenzia Case'.toLowerCase())) {
                        return '#cb3234';
                    } else {
                        return '#00ADC6'
                    }
                }
            },
            CreatedDate: {
                valueDate: value => (value),
                type: 'DATE'
            },
            Id: {
                valueId: value => (value),
                type: 'Id'
            },
            CaseNumber: {
                valueLabel: value => {
                    if (value) {
                        return value
                    } else { return '' }
                },
                onClick: this.redirectCasenumberToId,
                type: 'REDIRECT'
            }

        }

        tableData.actions = [{
            label: '',
            icon: 'icon-arrow-right-blue',
            callback: (value) => {
                console.log('this.case = ' + value.Id),
                    this.redirectCase(value.Id)
            }
        }]

        tableData.bind = {
            origin: this,
            target: 'Case',
            load: caseController
        };

        this.Case = new DataGridModel(tableData);
        console.log('NDG' + [this.params.ndgId]);
        console.log("params", this.proxyData(this.params))
        this.Case.setFilter('Account.NDG__c', [this.params.ndgId]);

        this.Case.load();
    }

    loadFeedBack() {
        let tableData = {};
        tableData.showFilter = false;
        tableData.showSearch = false;
        tableData.perPage = this.params.perPage;
        tableData.encodes = {
            CTL_Case__r: {
                valueBadge: value => {
                    if (value) {
                        if (value.Owner) {
                            if (value.Owner.Name) {
                                return value.Owner.Name
                            } else { return '' }
                        } else { return '' }
                    }

                },
                type: 'BADGE',
                colors: value => {
                    if (value) {
                        if (value.Owner) {
                            if (value.Owner.Profile) {
                                if (value.Owner.Profile.Name) {
                                    if (!value.Owner.Profile.Name.startsWith('NFE')) {
                                        return '#cb3234';
                                    } else {
                                        return '#00ADC6'
                                    }
                                } else {
                                    return '#00ADC6'
                                }
                            } else
                            if (value.Owner.Name) {
                                if (!value.Owner.Name.startsWith('Coda Agenzia Case')) {
                                    return '#cb3234';
                                } else { return '#00ADC6' }
                            } else { return '#00ADC6' }
                        } else { return '#00ADC6' }
                    } else { return '' }
                }
            },

            CreatedDate: {
                valueDate: value => (value),
                type: 'DATE'
            },
            Id: {
                valueLabel: value => {
                    //To do :refactoring
                    var result = this.FeedBack.pagination.elementsCached.find(item => item.Id === value);
                    if (result.CTL_Case__c)
                        return result.CTL_Case__r.CaseNumber
                    else
                        return ''
                },
                onClick: this.redirectCasenumberToId2,
                type: 'REDIRECT'
            },
            Name: {
                valueLabel: value => {
                    this.i++;
                    if (value) {
                        return value
                    } else { return '' }

                },
                onClick: this.redirectFeedbackNameToId,
                type: 'REDIRECT'
            }
        }


        tableData.actions = [{
            label: '',
            icon: 'icon-arrow-right-blue',
            callback: (value) => {
                console.log('this.case = ' + value.Id),
                    this.redirectFeedback(value.Id)
            }
        }]

        tableData.bind = {
            origin: this,
            target: 'FeedBack',
            load: feedBackController
        }

        this.FeedBack = new DataGridModel(tableData);
        this.FeedBack.setFilter('NDG__c', [this.params.ndgId]);
        this.FeedBack.load();
    }
}