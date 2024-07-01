/* eslint-disable radix */
import {
	Model,
	ModelCollection
} from 'c/mobilityAbstractModel';

export class MobilityCardModel extends Model {

	configuration = {}

    _model() {

		return {
			Name: '',
			Description:'',
			IniziativaName : '',
			TargetName : '',
			IniziativaId : '',
			Nome_Messaggio__c:'',
			Descrizione_Messaggio__c:'',
			TargetId: '',
			TargetDescription: '',
			IniziativaDescription: '',
			Descrizione_dell_iniziativa__c: '',
			Titolo__c: '',
			Sottotitolo__c: '',
			Invio_push__c: '',
			Short_Message__c:'',
			Message__c: '',
			TECH_URL_template_MC__c: '',
			Categoria_Prodotto__c : ''
		}

	}


	getFieldName(field){
		return this.configuration[field] ? this.configuration[field] : field;
	}

	get toString(){
		let toRet = {...this};
		toRet._label = {}
		return JSON.stringify(toRet);
	}

	get Title(){

		return this[this.getFieldName("Title")];

	}
	get SubTitle(){

		return this[this.getFieldName("SubTitle")];

	}
	get DescriptionText(){

		return this[this.getFieldName("Description")];

	}

	get ActionList(){
		return this.getFieldName('actions')
	}

	get flagStyle() {
	/* 
			00ADC6 - Malattia
			7B61FF - Casa&Famiglia
			3D3DAA - Auto
			EF577B - Infortuni
			B5AADC - Investimento
			F07662 - Previdenza
			39443F - Altre aziende
			027180 - Protezione
			B5D0EE - Attività
			9FBEAF - Risparmio
			FCD385 - Generica
	*/
        let flagStyle = ["badge", "text-truncate"];

		switch(this.Categoria_Prodotto__c) {
			case 'Malattia': flagStyle.push('badge-malattia'); break;
			case 'Casa&Famiglia': flagStyle.push('badge-casa'); break;
			case 'Auto': flagStyle.push('badge-auto'); break;
			case 'Infortuni': flagStyle.push('badge-infortuni'); break;
			case 'Investimento': flagStyle.push('badge-investimento'); break;
			case 'Previdenza': flagStyle.push('badge-previdenza'); break;
			case 'Altre aziende': flagStyle.push('badge-aziende'); break;
			case 'Protezione': flagStyle.push('badge-protezione'); break;
			case 'Attività': flagStyle.push('badge-attività'); break;
			case 'Risparmio': flagStyle.push('badge-risparmio'); break;
			case 'Generica': flagStyle.push('badge-generica'); break;
			default: flagStyle.push('badge-red'); break;
		}
        return flagStyle.join(' ');
    }
	get flagStyleInvioPush(){
		let flagStyle = ["badge", "text-truncate"];
		if(this.Invio_push__c=='true'){
			flagStyle.push("badge-green");
		}
		if(this.Invio_push__c){
			flagStyle.push("badge-green");
		}
		return flagStyle.join(' ');
	}
	get flagTextInvioPush(){
		return this[this.getFieldName("Invio_push__c")]== 'true' ?'Con Push':this[this.getFieldName("Invio_push__c")]==true ?'Con Push':'' ;
	}
	get flagText() {
		return this[this.getFieldName("Categoria_Prodotto__c")]!= null?this[this.getFieldName("Categoria_Prodotto__c")]:'' ;
	}
}

export class MobilityCardCollection extends ModelCollection {

    constructor(data) {
		super(data);
		//console.log('config ', data.config);
		let allData = this.getAll();
		for(let index in allData){
			allData[index].configuration = data.config;
		}
	}


    _childType() {
		return MobilityCardModel;
	}

    _model() {
		return {
			...super._model()
		}
	}

}