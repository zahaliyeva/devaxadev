import { track } from 'lwc';
import { MobilitySObject } from 'c/mobilitySObject';
import { PostMessage } from 'c/postMessage';
import getAccount from '@salesforce/apex/mobilityCreateTaskController.getAccount';
import getRecordType from '@salesforce/apex/mobilityCreateTaskController.getRecordType';
import getUserName from '@salesforce/apex/mobilityCreateTaskController.getUserName';

export default class MobilityCreateTask extends MobilitySObject {

    @track Show = false;
    @track value = '';
    @track account = {}
    @track recordTypeOb = {}
    @track Owner = {}

    handleChange(event) {
        this.value = event.detail.value;
        this.Show = true;

    }
    componentView = 'mobilityCreateTask';
    objectName = 'Task';


    connectedCallback() {
        console.log(this.customLayout)
        super.connectedCallback();
    }
    toggleTask = (e) => {
        this.Show = !this.Show;
        this.value = '';
    }
    handleClose(){
        if(this.closeMethod){
            this.closeMethod();
        }
        else{
            PostMessage.close_Modal();
            //dispose component
        }
    }
    onSave2 = () => {
        this.customLayout.re
        console.log(this.customLayout)
        return this.customLayout.saveData().then(() => {
            this.toggleTask();
        });
    }
    get taskData() {

        getAccount({ NDG: this.params.ndgId })
            .then((result) => {
                this.account = result;
            }).catch((err) => {
                console.log('err', this.proxyData(err));
            })
        if (this.value == 'General_RecordType') {
            getRecordType({ recordTypeOb: 'Generico' })
                .then((result) => {
                    this.recordTypeOb = result;
                }).catch((err) => {
                    console.log('err General_RecordType', this.proxyData(err));
                })
        } else {
            getRecordType({ recordTypeOb: this.value })
                .then((result) => {
                    this.recordTypeOb = result;
                }).catch((err) => {
                    console.log('err Else General_RecordType', this.proxyData(err));
                })

        }

        getUserName({ Contactn: this.account.Contact_Master_Id__c })
            .then((result) => {
                this.Owner = result;
            }).catch((err) => {
                console.log('err getUserName', this.proxyData(err));
            })


        return {
            RecordTypeId: this.recordTypeOb.Id,
            What: {
                Id: this.account.Id,
                Name: this.account.Name
            },
            Owner: {
                Id: this.Owner.Id,
                Name: this.Owner.Name,
            },
            WhatId: this.account.Id


        }
    }

    get options() {
        return [
            { label: 'Generico', value: 'General_RecordType' },
            { label: 'AXA Assicurazioni', value: 'AXA_Assicurazioni_Task' },
        ];
    }
}