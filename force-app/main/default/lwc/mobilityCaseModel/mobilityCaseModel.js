import {
  Model,
  ModelCollection
} from 'c/mobilityAbstractModel';

export class MobilityCaseCollection extends ModelCollection {
  _childType() {
    return MobilityCaseModel;
  }
}

export class MobilityCaseModel extends Model {
  // Create a Model for Widget Object
  _model() {
    return {
      Id: '',
      Oggetto_Apertura_Case__c: '',
      CreatedDate: null,
      Category__c: '',
      SubCategory__c: '',
      Status: '',
      LastModifiedDate: null,
      User__r: {}
    }
  }

  // Create List Status
  openStatus() {
    return [
      "Open",
      "Reopened",
      "Assigned",
      "Pending",
      "Delegated",
      "Information Received",
      "Info Agente ricevute",
      "Soluzione rifiutata",
      "Info Agenzia ricevuta"
    ];
  } // Open Status - Green Color

  workingStatus() {
    return [
      "All Tasks Closed",
      "Chiusura Email",
      "Attività dispositive in attesa di verifica",
      "Verifica completamento attività dispositive",
      "In attesa verifica antiriciclaggio",
      "Informazioni antiriciclaggio ricevute",
      "Verifica stato antiriciclaggio",
      "Inviata raccomandata QADV",
      "Stornare polizza per mancanza QADV",
      "Attività DPO concluse",
      "In gestione back office Smart Center",
      "Completato da Back office Smart Center",
      "In gestione all'HD3",
      "In gestione Specialista",
      "Risposta Specialista",
      "Inoltrato a Linea di Business",
      "Inoltrato ad IT",
      "Assegnato I Livello",
      "Assegnato II Livello",
      "In gestione su Geres",
      "Inoltrato a Contabilità",
      "Inoltrato a Contenzioso",
      "In gestione specialistica Ufficio tecnico"
    ];
  } // Working Status - Purple Color

  pendingStatus() {
    return [
      "In attesa verifica DPO",
      "Attesa Info Agente",
      "Soluzione proposta",
      "In gestione all’Agenzia",
      "Mancata gestione Agenzia",
      "In attesa documento",
      "In attesa ricontatto"
    ];
  } // Pending Status - Red Color

  // Set Color by Status List Match
  get statusClass() {

    let classString = [
      "badge",
      "text-truncate"
    ];

    // Open Status - Green Color
    if (this.openStatus().includes(this.Status)) {
      classString.push('badge-green');
    }

    // Working Status - Purple Color
    else if (this.workingStatus().includes(this.Status)) {
      classString.push('badge-purple');
    }

    // Pending Status - Red Color
    else if (this.pendingStatus().includes(this.Status)) {
      classString.push('badge-red');
    }

    return classString.join(' ');
  }

  // Convert Data Format
  get LastModifiedDateString() {
    if (!this.LastModifiedDate) return '';
    let dateObject = this.getDateTimeFormated(this.LastModifiedDate);
    return `${dateObject.days}/${dateObject.months}/${dateObject.years}`;
  }

  get CreatedDateString() {
    if (!this.CreatedDate) return '';
    let dateObject = this.getDateTimeFormated(this.CreatedDate);
    return `${dateObject.days}/${dateObject.months}/${dateObject.years}`;
  }

  get StatusLabel() {
    switch (this.Status) {
      case 'Open':
        return this._label.case_status_open;
      case 'Assigned':
      case 'Preso in carico':
        return this._label.case_status_takenOver;
      case 'Info Agente ricevute':
        return this._label.case_status_agentInfoReceived;
      case 'In gestione Specialista':
        return this._label.case_status_inSpecialistManagement;
      case 'Risposta Specialista':
        return this._label.case_status_specialistResponse;
      case 'In gestione all\'HD3':
        return this._label.case_status_inManagementAtHD3;
      case 'Soluzione rifiutata':
        return this._label.case_status_solutionRejected;
      case 'Inoltrato a Linea di Business':
        return this._label.case_status_forwardingToBusinessLine;
      case 'Inoltrato ad IT':
        return this._label.case_status_forwardingToIT;
      case 'Soluzione proposta':
        return this._label.case_status_solutionOffer;
      case 'Attesa Info Agente':
        return this._label.case_status_waitingAgentInfo;
      default:
        return this.Status;
    }
  }
}