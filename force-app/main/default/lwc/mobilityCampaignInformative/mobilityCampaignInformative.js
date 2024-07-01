import {
    track,
    api
} from 'lwc';
import {
    MobilitySObject
} from 'c/mobilitySObject';
import getContactValue from '@salesforce/apex/MobilityCampaignMemberController.getContactValue';
import proccessInformative from '@salesforce/apex/MobilityCampaignMemberController.proccessInformative';

export default class MobilityCampaignInformative extends MobilitySObject {
    componentView = 'mobilityCampaignInformative';

    @api context;
    @api campaignMemberId;
    @api campaignId;
    @api closeCallbackReload;

    @track showMemo = false;
    @track valueContact = [];
    @track dateTime;

    currentValueContact;
    currentStatus;
    labelWarningBack = 'Annulla';
    labelWarningConfirmation = 'Conferma';

    connectedCallback() {
        super.connectedCallback();
        this.contactValue();
    }

    contactValue() {
        this.showSpinner(true);
        getContactValue({
            campaignId: this.campaignId
        }).then((response) => {
            if (!response.isSuccess) throw new Error(response.errorMessage);
            this.valueContact = response.contactValues;
        }).catch((err) => {
            console.log("errContactValue: ", err);

            if(err.message !== 'CONTACT_VALUE_NOT_DEFINED'){
                this.alertMessage('Error', '' + err.message);
            }
        }).finally(() => {
            this.hideSpinner();
        });
    }

    updateValueContact = (e) => {
        this.currentValueContact = e.currentTarget.dataset.value;
        this.warningMessage('', 'Confermi la chiusura campagna con stato ' + this.currentValueContact + ' ?');
        console.log('updateStatus - currentValueContact', this.currentValueContact);
    }

    updateStatus = (e) => {
        this.currentStatus = e.currentTarget.dataset.status;

        let message = 'Ricordati che per completare la lavorazione della campagna è necessario selezionare un esito di chiusura campagna. Hai selezionato ' + this.currentStatus + ', vuoi confermare ?';
        let title = '';

        if (!this.showMemo) {
            title = 'Attenzione'
            message = 'Non è stata richiesta la creazione del promemoria.\n\n' + message;
        }

        this.warningMessage(title, message);

        console.log('updateStatus - currentStatus', this.currentStatus);
    }

    confirmWarningCallback = () => {
        this.showSpinner(true);
        console.log('confirmWarningCallback - currentValueContact', this.currentValueContact);
        console.log('confirmWarningCallback - currentStatus', this.currentStatus);

        proccessInformative({
            campaignMemberId: this.campaignMemberId,
            valueContact: this.currentValueContact,
            status: this.currentStatus,
            isReminder: this.showMemo,
            reminderDateTime: this.dateTime
        }).then((response) => {
            if (!response.isSuccess) throw new Error(response.errorMessage);
            this.successMessage('Successo', 'La campagna è stata aggiornata correttamente.')
        }).catch((err) => {
            console.log("errConfirmWarningCallback: ", err);
            this.alertMessage('Error', '' + err.message);
        }).finally(() => {
            this.hideSpinner();
        });
    }

    memoShow() {
        this.showMemo = !this.showMemo;
    }

    changeData = (e) => {
        if (!e.target && !e.currentTarget) return;

        let target = e.target || e.currentTarget;
        this.dateTime = target.value;
    }
}