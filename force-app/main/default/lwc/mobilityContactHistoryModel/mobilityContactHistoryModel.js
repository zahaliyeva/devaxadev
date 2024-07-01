import {
    ModelCollection,
    Model
} from "c/mobilityAbstractModel";
import {MobilityLib} from 'c/mobilityLib';

export class MobilityContactHistoryCollection extends ModelCollection {

    _childType() {
        return MobilityContactHistoryModel;
    }

    allByDate() {
        return this.getAll().sort((record1, record2) => {
            return (record2.dateAndTimeObject.getTime() - record1.dateAndTimeObject.getTime())
        })
    }

}

export class MobilityContactHistoryModel extends Model {

    

    _model() {
        return {
            title: null,
            icon: null,
            detail3: null,
            detail4: null,
            detail4Link: null,
            detail5: null,
            detail5Link: null,
            detail2: null,
            detail1: null,
            detail1Link: null,
            detail2Link: null,
            detail3Link: null,
            detail2LinkNFE: null,
            detail3LinkNFE: null,
            detail4LinkNFE: null,
            detail1LinkNFE: null,
            dateAndTime: null,
            flagSent: null,
            flagOpen: null,
            flagClick: null,
            flagHardBounce: null,
            flagSoftBounce: null,
            flagMouseoverSent: null,
            flagMouseoverOpen: null,
            flagMouseoverClick: null,
            flagMouseoverBounce: null,
            recordId: null,
            recordType: null,
            detailTitle: null,
            HideInNFE: null

        };
    }

    get iconType() {
        switch (this.icon) {
            case 'standard:event':
                return 'calendar_blue';

            case 'custom:custom28':
                return 'mobile_blue';

            case 'custom:custom11':
                return 'feedback_blue';

            case 'custom:custom16':
                return 'house_blue';

            case 'custom:custom27':
                return 'pc_badge_blue';

            case 'standard:task':
                return 'note_pen_blue';

            case 'standard:email':
                return 'email_blue';

            case 'standard:sms':
                return 'mobile_blue';

            case 'standard:call':
                return 'phone_blue';

            case 'custom:email1':
                return 'briefcase_blue'; 

            case 'custom:email_agenzia':
                return 'email_agenzia';

            case 'custom:email_direzione':
                return 'email_direzione';
                
            default:
                return '';
        }
    }

    get dateAndTimeObject() {
        return new Date(this.dateAndTime);
    }

    get dateString() {
        if (!this.dateAndTime) return '';
        let dateObject = this.getDateTimeFormated(this.dateAndTime);
        return `${dateObject.days}/${dateObject.months}/${dateObject.years}`;
    }

    get flagStatus() {
        let fStatus;

        this.flagClick = this.flagClick && !this.HideInNFE;
        this.flagOpen = this.flagOpen && !this.HideInNFE;

        if (this.flagHardBounce === true && this.flagSoftBounce === false) {

            this.flagMouseoverBounce = this._label.contactHistory_flag_flagMouseoverBounce;
            fStatus = this.flagMouseoverBounce;

        } else if (this.flagSoftBounce === true && this.flagHardBounce === false) {

            this.flagMouseoverBounce = this._label.contactHistory_flag_flagMouseoverBounce;
            fStatus = this.flagMouseoverBounce;

        } else if (this.flagClick) {

            this.flagMouseoverClick = this._label.contactHistory_flag_flagMouseoverClick
            fStatus = this.flagMouseoverClick;

        } else if (this.flagOpen === true && this.flagClick === false) {

            this.flagMouseoverOpen = this._label.contactHistory_flag_flagMouseoverOpen;
            fStatus = this.flagMouseoverOpen + ' ' + this.dateString;

        } else if (this.flagSent === true && this.flagOpen === false) {

            this.flagMouseoverSent = this._label.contactHistory_flag_flagMouseoverSent;
            fStatus = this.flagMouseoverSent;

        }

        return fStatus
    }


    standardRedirect(){
        window.open(MobilityLib.baseUrl+'/'+this.recordId, '_blank');
    }

    get flagAlert() {
        let fAlert;

        this.flagClick = this.flagClick && !this.HideInNFE;
        this.flagOpen = this.flagOpen && !this.HideInNFE;

        if (this.flagHardBounce === true && this.flagSoftBounce === false) {

            fAlert = this._label.contactHistory_status_bounce;

        } else if (this.flagSoftBounce === true && this.flagHardBounce === false) {

            fAlert = this._label.contactHistory_status_bounce;

        } else if (this.flagClick) {

            fAlert = this._label.contactHistory_status_click;

        } else if (this.flagOpen === true && this.flagClick === false) {

            fAlert = this._label.contactHistory_status_open;

        } else if (this.flagSent === true && this.flagOpen === false) {

            fAlert = this._label.contactHistory_status_sent;

        }    else      if (this.flagSent ===  true) {

            fAlert = this._label.contactHistory_status_sent;

        }

        return fAlert
    }

    get flagStyle() {
        let flagStyle = ["badge", "text-truncate"];

        this.flagClick = this.flagClick && !this.HideInNFE;
        this.flagOpen = this.flagOpen && !this.HideInNFE;

        if (this.flagHardBounce === true && this.flagSoftBounce === false) {

            flagStyle.push("badge-red");

        } else if (this.flagSoftBounce === true && this.flagHardBounce === false) {

            flagStyle.push("badge-red");

        } else if (this.flagClick) {

            flagStyle.push("badge-green");

        } else if (this.flagOpen === true && this.flagClick === false) {

            flagStyle.push("badge-purple");

        } else if (this.flagSent === true && this.flagOpen === false) {

            flagStyle.push("badge-purple");

        }
        else if (this.flagSent === true) {

            flagStyle.push("badge-purple");

        }

        return flagStyle.join(' ');
    }

    isBlank(value) {
        return (value === undefined || value === null || value.trim() === '');
    }

    get detailList() {
        let listDetails = [];
        let urlStruct;
        var showLinks = this.recordType === 'Feedback__c' || this.recordType === 'Massive_Communication__c';
        if(MobilityLib.baseUrl)
            urlStruct= '<a href="'+ MobilityLib.baseUrl +'/{url}" target="_blank">{detail}</a>';
        else{
            urlStruct = '{detail}';
        }
        if (!this.isBlank(this.detail1) && this.isBlank(this.detail1LinkNFE)) { 
            if(this.detail1Link && showLinks){
                listDetails.push(urlStruct.replace('{url}', this.detail1Link).replace('{detail}', this.detail1));
                
            }
            else
                listDetails.push(this.detail1) 
            
        }
        if (!this.isBlank(this.detail1) && !this.isBlank(this.detail1LinkNFE)) { 
            if(this.detail1LinkNFE && showLinks){
                listDetails.push(urlStruct.replace('{url}', this.detail1LinkNFE).replace('{detail}', this.detail1));
                
            }
            else
                listDetails.push(this.detail1)
            
        }
        if (!this.isBlank(this.detail2) && this.isBlank(this.detail2LinkNFE)) { 
            if(this.detail2Link && showLinks)
            listDetails.push(urlStruct.replace('{url}', this.detail2Link).replace('{detail}', this.detail2));
                
            else {
                listDetails.push(this.detail2) 
                //console.log(urlStruct.replace('{url}', this.detail2Link).replace('{detail}', this.detail2))
            } 
        }
        if (!this.isBlank(this.detail2) && !this.isBlank(this.detail2LinkNFE)) { 
            if(this.detail2LinkNFE && showLinks)
            listDetails.push(urlStruct.replace('{url}', this.detail2LinkNFE).replace('{detail}', this.detail2));
                
            else {
                listDetails.push(this.detail2)
            } 
        }
        if (!this.isBlank(this.detail3) && this.isBlank(this.detail3LinkNFE)) {  
            
            if(this.detail3Link && showLinks){
                listDetails.push(urlStruct.replace('{url}', this.detail3Link).replace('{detail}', this.detail3));
            }  
            else
                listDetails.push(this.detail3) 
        }
        if (!this.isBlank(this.detail3) && !this.isBlank(this.detail3LinkNFE)) { 
            if(this.detail3LinkNFE && showLinks)
            listDetails.push(urlStruct.replace('{url}', this.detail3LinkNFE).replace('{detail}', this.detail3));

            else {
                listDetails.push(this.detail3) 
                //console.log(urlStruct.replace('{url}', this.detail2Link).replace('{detail}', this.detail2))
            } 
        }
        if (!this.isBlank(this.detail4) && this.isBlank(this.detail4LinkNFE)) {  
            
            if(this.detail4Link && showLinks){
                listDetails.push(urlStruct.replace('{url}', this.detail4Link).replace('{detail}', this.detail4));
            }  
            else
                listDetails.push(this.detail4) 
        }
        if (!this.isBlank(this.detail4) && !this.isBlank(this.detail4LinkNFE)) {  
            
            if(this.detail4LinkNFE && showLinks){
                listDetails.push(urlStruct.replace('{url}', this.detail4LinkNFE).replace('{detail}', this.detail4));
            }  
            else
                listDetails.push(this.detail4) 
        }
        if (!this.isBlank(this.detail5) && this.isBlank(this.detail5LinkNFE)) {  
            
            if(this.detail5Link && showLinks){
                listDetails.push(urlStruct.replace('{url}', this.detail5Link).replace('{detail}', this.detail5));
            }  
            else
                listDetails.push(this.detail5) 
        }
        if (!this.isBlank(this.detail5) && !this.isBlank(this.detail5LinkNFE)) {  
            
            if(this.detail5LinkNFE && showLinks){
                listDetails.push(urlStruct.replace('{url}', this.detail5LinkNFE).replace('{detail}', this.detail5));
            }  
            else
                listDetails.push(this.detail5) 
        }

        return listDetails.join(' - ');
    }

    get canRedirect(){
        return this.redirectCallback != null && this.recordId && this.recordType && this.detailTitle; //differenziare in base al tipo di oggetto
    }

    redirectCallback = null;

    redirect = () => {
        if (this.recordType === 'Task' || this.recordType === 'Event') {
            this.standardRedirect();
            return;
        }
        //console.log(this.redirectCallback);
        this.redirectCallback(this.recordId, this.recordType, this.detailTitle);
        
    }
}