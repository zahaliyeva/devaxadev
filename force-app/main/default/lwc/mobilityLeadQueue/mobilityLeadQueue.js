import {
	track,
	api
} from 'lwc';

import {
	MobilityAbstract
} from 'c/mobilityAbstract';

import {
	DataGridModel
} from 'c/dataGridModel';

import getAgencyUsers from '@salesforce/apex/MobilityLeadController.getAgencyUsers';
import saveAgencyUsers from '@salesforce/apex/MobilityLeadController.saveAgencyUsers';
import setAgencyPhone from '@salesforce/apex/agencyQueueManagerCTRL.setAgencyPhone';

export default class MobilityLeadQueue extends MobilityAbstract {
	componentView = 'mobilityLeadQueue';

	@track leadData;
	agencyPhone;
	@api closeCallback;

	authUser = true;
	connectedCallback() {
		super.connectedCallback();

		this.loadLeadData();
	}

	loadLeadData() {
		let tableData = {};

		tableData.perPage = 6;

		tableData.encodes = {}

		tableData.actions = []

		tableData.fixedFirst = true;
		tableData.fixedLast = false;
		tableData.viewSelectRow = true;
		tableData.simpleMode = true;
		tableData.selectField = 'isInQueue';

		tableData.bind = {
			origin: this,
			target: 'leadData',
			load: getAgencyUsers
		};

		this.records = new DataGridModel(tableData);

		this.records.load();
		this.records.preLoadCallback = () => {
			this.showSpinner(true);
		};

		this.records.loadCallback = (instance, result) => {
			if(result.Message  === 'Unauthorized user'){
				this.alertMessage('Error', 'Non si dispone dei privilegi necessari!');
				this.authUser = false;
			}
			else{
				console.log(result);
				if(result.additionalData && result.additionalData['MobilePhone']){
					this.agencyPhone = result.additionalData['MobilePhone'];
				}
				this.showNoData(result.length === 0);
			}
			
			
			this.hideSpinner();
		};
	}

	onClose(e){
		if(this.closeCallback) this.closeCallback(e);
	}

	onSave(){
		let selectData = this.leadData.selectData;

		this.showSpinner();

		saveAgencyUsers({
			selectedIds: selectData
		}).then((result)=>{
			if(!result.isSuccess) throw new Error(result.errorMessage);

			this.successMessage('Success', 'La richiesta di modifica della coda è stata presa in carico e verrà completata a breve');
		}).catch((err)=>{
			this.alertMessage('Error', err.message);
		}).finally(()=>{
			this.hideSpinner();
		})
	}

	onConfirmSuccess = (e) => {
		if(this.parent){
			this.parent.onShowLeadQueue();
		}
	}

	changePhone(event){
		this.agencyPhone= event.target.value;
	}

	showWarning(){
		this.warningMessageWithCallback('Attenzione!', "All'interno di questo campo, si chiede di inserire un numero di cellulare valido e non un telefono fisso.<br/>Il numero di cellulare inserito sarà usato esclusivamente per inviare al destinatario <b>notifiche SMS</b> ogni volta che viene assegnato all'agenzia <b>un nuovo lead per i prodotti Salute</b>.<br/>Se non viene inserito nessun numero di telefono, nessuna persona in agenzia riceverà l'avviso via SMS.", this.savePhone);
	}

	savePhone = () => {
		console.log(this);
		this.showSpinner();
		setAgencyPhone({
			phone: this.agencyPhone
		}).then((result)=>{
			console.log(result);

			if(!result.isSuccess) {
				console.log(result.message);
				var message = result.message;
				this.alertMessage('Errore!', message);
			}
				
			else
				this.successMessage('Success', 'Il numero di telefono è stato salvato correttamente.');
		}).catch((err)=>{
			this.alertMessage('Errore!', err.message);
		}).finally((e) => {
			this.hideSpinner();
		})
		
	}
}