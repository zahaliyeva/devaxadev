import {
	MobilityAbstract
} from 'c/mobilityAbstract';
import {
	api,track
} from 'lwc';

export default class MobilityPushOrariAgenzia extends MobilityAbstract {


    @api closeCallback;
    @api primaryCallback;
    @api backCallback;
    validoDal="";
    validoAl="";
    root;
    showError = false;
    @track orari ={
        lunedi: {name:"lunedi",dal1: "", al1:"", dal2: "", al2:"", isClosed:false},
        martedi:{name:"martedi",dal1: "", al1:"", dal2: "", al2:"", isClosed:false},
        mercoledi:{name:"mercoledi",dal1: "", al1:"", dal2: "", al2:"", isClosed:false},
        giovedi:{name:"giovedi",dal1: "", al1:"", dal2: "", al2:"", isClosed:false},
        venerdi:{name:"venerdi",dal1: "", al1:"", dal2: "", al2:"", isClosed:false},
        sabato:{name:"sabato",dal1: "", al1:"", dal2: "", al2:"", isClosed:false},
        validoAl: new Date(NaN),
        validoDal: new Date(NaN)
    }
    @track errori ={
        lunedi: {dal1: false, al1:false, dal2: false, al2:false, required:false},
        martedi: {dal1: false, al1:false, dal2: false, al2:false, required:false},
        mercoledi: {dal1: false, al1:false, dal2: false, al2:false, required:false},
        giovedi: {dal1: false, al1:false, dal2: false, al2:false, required:false},
        venerdi: {dal1: false, al1:false, dal2: false, al2:false, required:false},
        sabato: {dal1: false, al1:false, dal2: false, al2:false, required:false},
        validoAl: false,
        validoDal: false,
    }

    /*isNotActive = {
        lunedi: false,
        martedi:false,
        mercoledi:false,
        giovedi:false,
        venerdi:false,
        sabato:false,
    }*/

    get picklistMattinaValues(){
        return [
        {
            value : "",
            label : "-"
        },
        {
            value : "07:00",
            label : "07:00"
        },
        {
            value : "07:30",
            label : "07:30"
        },
        {
            value : "08:00",
            label : "08:00"
        },
        {
            value : "08:30",
            label : "08:30"
        },
        {
            value : "09:00",
            label : "09:00"
        },
        {
            value : "09:30",
            label : "09:30"
        },
        {
            value : "10:00",
            label : "10:00"
        },
        {
            value : "10:30",
            label : "10:30"
        },
        {
            value : "11:00",
            label : "11:00"
        },
        {
            value : "11:30",
            label : "11:30"
        },
        {
            value : "12:00",
            label : "12:00"
        },
        {
            value : "12:30",
            label : "12:30"
        },
        {
            value : "13:00",
            label : "13:00"
        },
        {
            value : "13:30",
            label : "13:30"
        },
        {
            value : "14:00",
            label : "14:00"
        }
        ]      
    }

    get picklistPomeriggioValues(){
        return [
        {
            value : "",
            label : "-"
        },
        {
            value : "14:00",
            label : "14:00"
        },
        {
            value : "14:30",
            label : "14:30"
        },
        {
            value : "15:00",
            label : "15:00"
        },
        {
            value : "15:30",
            label : "15:30"
        },
        {
            value : "16:00",
            label : "16:00"
        },
        {
            value : "16:30",
            label : "16:30"
        },
        {
            value : "17:00",
            label : "17:00"
        },
        {
            value : "17:30",
            label : "17:30"
        },
        {
            value : "18:00",
            label : "18:00"
        },
        {
            value : "18:30",
            label : "18:30"
        },
        {
            value : "19:00",
            label : "19:00"
        },
        {
            value : "19:30",
            label : "19:30"
        },
        {
            value : "20:00",
            label : "20:00"
        }
        ]
            
    }

    get picklistValues(){
        return [
            "00:00",
            "00:30",
            "01:00",
            "01:30",
            "02:00",
            "02:30",
            "03:00",
            "03:30",
            "04:00",
            "04:30",
            "05:00",
            "05:30",
            "06:00",
            "06:30",
            "07:00",
            "07:30",
            "08:00",
            "08:30",
            "09:00",
            "09:30",
            "10:00",
            "10:30",
            "11:00",
            "11:30",
            "12:00",
            "12:30",
            "13:00",
            "13:30",
            "14:00",
            "14:30",
            "15:00",
            "15:30",
            "16:00",
            "16:30",
            "17:00",
            "17:30",
            "18:00",
            "18:30",
            "19:00",
            "19:30",
            "20:00",
            "20:30",
            "21:00",
            "21:30",
            "22:00",
            "22:30",
            "23:00",
            "23:30",
        ]
            
    }
    connectedCallback(){
        super.connectedCallback();
        console.log('here');
    }
    closeModal(){
        this.closeCallback() ;
    }
    primary(){
        this.validateDate();
        if (this.showError) {
            return;
        }

        this.primaryCallback({orari: this.orari}); 
    }
    back(){
        this.backCallback();
    }

    lunedial1(e){
        this.orari.lunedi.al1=e.detail.value;
        this.validateDate();
            
    }
    lunedial2(e){
        this.orari.lunedi.al2=e.detail.value;
        this.validateDate();
    }
    lunedidal1(e){
        this.orari.lunedi.dal1=e.detail.value;
        this.validateDate();
    }
    lunedidal2(e){
        this.orari.lunedi.dal2=e.detail.value;
        this.validateDate();
        
    }
    martedial1(e){
        this.orari.martedi.al1=e.detail.value;
        this.validateDate();
    }
    martedial2(e){
        this.orari.martedi.al2=e.detail.value;
        this.validateDate();
    }
    martedidal1(e){
        this.orari.martedi.dal1=e.detail.value;
        this.validateDate();
    }
    martedidal2(e){
        this.orari.martedi.dal2=e.detail.value;
        this.validateDate();
        
    }
    mercoledial1(e){
        this.orari.mercoledi.al1=e.detail.value;
        this.validateDate();
    }
    mercoledial2(e){
        this.orari.mercoledi.al2=e.detail.value;
        this.validateDate();
    }
    mercoledidal1(e){
        this.orari.mercoledi.dal1=e.detail.value;
        this.validateDate();
    }
    mercoledidal2(e){
        this.orari.mercoledi.dal2=e.detail.value;
        this.validateDate();
        
    }
    giovedial1(e){
        this.orari.giovedi.al1=e.detail.value;
        this.validateDate();
    }
    giovedial2(e){
        this.orari.giovedi.al2=e.detail.value;
        this.validateDate();
    }
    giovedidal1(e){
        this.orari.giovedi.dal1=e.detail.value;
        this.validateDate();
    }
    giovedidal2(e){
        this.orari.giovedi.dal2=e.detail.value;
        this.validateDate();
        
    }
    venerdial1(e){
        this.orari.venerdi.al1=e.detail.value;
        this.validateDate();
    }
    venerdial2(e){
        this.orari.venerdi.al2=e.detail.value;
        this.validateDate();
    }
    venerdidal1(e){
        this.orari.venerdi.dal1=e.detail.value;
        this.validateDate();
    }
    venerdidal2(e){
        this.orari.venerdi.dal2=e.detail.value;
        this.validateDate();
        
    }
    sabatoal1(e){
        this.orari.sabato.al1=e.detail.value;
        this.validateDate();
    }
    sabatoal2(e){
        this.orari.sabato.al2=e.detail.value;
        this.validateDate();
    }
    sabatodal1(e){
        this.orari.sabato.dal1=e.detail.value;
        this.validateDate();
    }
    sabatodal2(e){
        this.orari.sabato.dal2=e.detail.value;
        this.validateDate();
        
    }

    validateDate(){
        // in errore se specificato 
        this.errori.validoDal = isNaN(this.orari.validoDal.valueOf());
        
        this.errori.validoAl = isNaN(this.orari.validoAl.valueOf()) || (!this.errori.validoDal && this.orari.validoAl.valueOf() < this.orari.validoDal.valueOf());

        this.showError = this.errori.validoAl || this.errori.validoDal;

        Object.keys(this.orari)
            .forEach(
                /** @param {'lunedi' | 'martedi' | 'mercoledi' | 'giovedi' | 'venerdi' | 'sabato'} key  */
                (key) => {
                if (key === 'validoAl' || key === 'validoDal') {
                    return;
        }

                const orariGiorno = this.orari[key];
                const erroriGiorno = this.errori[key];

                erroriGiorno.required = !orariGiorno.dal1 && !orariGiorno.al1 && !orariGiorno.dal2 && !orariGiorno.al2 && !orariGiorno.isClosed;

                if (erroriGiorno.required) {
                    this.showError = true;
            
                    return;
            }

                if (orariGiorno.dal1 && orariGiorno.al2 && !orariGiorno.al1 && !orariGiorno.dal2) {
                    erroriGiorno.dal1 = false;
                    erroriGiorno.al1 = false;
                    erroriGiorno.dal2 = false;
                    erroriGiorno.al2 = false;
                    return;
            } 

                erroriGiorno.dal1 = (!orariGiorno.dal1 && !!orariGiorno.al1) 
                    || (this.picklistValues.indexOf(orariGiorno.dal1) > this.picklistValues.indexOf(orariGiorno.al1));
                erroriGiorno.al1 = (!!orariGiorno.dal1 && !orariGiorno.al1)  
                    || (this.picklistValues.indexOf(orariGiorno.dal1) > this.picklistValues.indexOf(orariGiorno.al1));
                erroriGiorno.dal2 = (!orariGiorno.dal2 && !!orariGiorno.al2) 
                    || (this.picklistValues.indexOf(orariGiorno.dal2) > this.picklistValues.indexOf(orariGiorno.al2));
                erroriGiorno.al2 = (!!orariGiorno.dal2 && !orariGiorno.al2)  
                    || (this.picklistValues.indexOf(orariGiorno.dal2) > this.picklistValues.indexOf(orariGiorno.al2));

                this.showError = this.showError || erroriGiorno.dal1 || erroriGiorno.al1 || erroriGiorno.dal2 || erroriGiorno.al2;
            });
    }

    delay(time) {
        return new Promise(resolve => setTimeout(resolve,time));
    }
    resetDay1(day){
        this.resetDay(day,true,true);
    }
    resetDay(day,uno,due){
        if(uno){
            this.orari[day].dal1 = "";
            this.orari[day].al1 = "";
        }
        if(due){
            this.orari[day].dal2 = "";
            this.orari[day].al2 = "";
        }
        
    }
    proxyData(proxyObj){
        return JSON.parse(JSON.stringify(proxyObj))
    }

    changesabatoclosed(event){
        this.orari.sabato.isClosed = event.detail.checked;
        let day = "sabato"
        this.orari[day].dal1 = "";
        this.orari[day].al1 = "";
        this.orari[day].dal2 = "";
        this.orari[day].al2 = "";
        this.validateDate();
    }
    changevenerdiclosed(event){
        this.orari.venerdi.isClosed = event.detail.checked;
        let day = "venerdi"
        this.orari[day].dal1 = "";
        this.orari[day].al1 = "";
        this.orari[day].dal2 = "";
        this.orari[day].al2 = "";
        this.validateDate();
    }
    changegiovediclosed(event){
        this.orari.giovedi.isClosed = event.detail.checked;
        let day = "giovedi"
        this.orari[day].dal1 = "";
        this.orari[day].al1 = "";
        this.orari[day].dal2 = "";
        this.orari[day].al2 = "";
        this.validateDate();
    }
    changemercolediclosed(event){
        this.orari.mercoledi.isClosed = event.detail.checked;
        let day = "mercoledi"
        this.orari[day].dal1 = "";
        this.orari[day].al1 = "";
        this.orari[day].dal2 = "";
        this.orari[day].al2 = "";
        this.validateDate();
    }
    changemartediclosed(event){
        this.orari.martedi.isClosed = event.detail.checked;
        let day = "martedi"
        this.orari[day].dal1 = "";
        this.orari[day].al1 = "";
        this.orari[day].dal2 = "";
        this.orari[day].al2 = "";
        this.validateDate();
    }
    changelunediclosed(event){
        this.orari.lunedi.isClosed = event.detail.checked;
        let day = "lunedi"
        this.orari[day].dal1 = "";
        this.orari[day].al1 = "";
        this.orari[day].dal2 = "";
        this.orari[day].al2 = "";
        this.validateDate();
    }

    changeData = (e) => {
        if (!e.target && !e.currentTarget) return;

        let target = e.target || e.currentTarget;
        this.validoDal = target.value;
        this.orari.validoDal = target.value;
        this.validateDate()
    }
  

    changeData2 = (e) => {
        if (!e.target && !e.currentTarget) return;

        let target = e.target || e.currentTarget;
        this.validoAl = target.value;
        this.orari.validoAl = target.value;
        this.validateDate()
    }

    keydown = (e) => {
        return;
    }
    renderedCallback(){
        this.root= this.template.querySelector('.tablevalid')
    }
}