import {
	Model
} from 'c/mobilityAbstractModel';

export class MobilityMessageModel extends Model {

	static get TYPES() {
		return {
			SUCCESS: 'SUCCESS',
			WARNING: 'WARNING',
			ALERT: 'ALERT',
			CRITICAL: 'CRITICAL'
		}
	}

	static messageMap = [];

	_model() {
		return {
			show: false,
			title: '',
			message: '',
			type: MobilityMessageModel.TYPES.SUCCESS,
			confirmWarningCallback: null
		}
	}

	parseMessage(message){
		let checkResult = this.checkMessageMap(message);

		if(!checkResult) return this.salesforceParse(message);

		return checkResult;
	}

	checkMessageMap(messageIn){
		console.log('checkMessageMap test');
		let messageMap = MobilityMessageModel.messageMap;
		let validRule;

		for(let messageId in messageMap){
			let messageData = messageMap[messageId];

			if(messageData.RegExp__c && messageData.RegExp__c.trim() !== ''){			
				let ruleRegExp = new RegExp(`${messageData.RegExp__c}`, 'gm');
				let resultRegExp = ruleRegExp.exec(messageIn);

				if(resultRegExp){
					validRule = messageData
					break;
				}
			}

			if(messageData.ErrorCode__c && messageData.ErrorCode__c.trim() !== ''){			
				let ruleInclude = new RegExp(`${messageData.ErrorCode__c}`, 'gm');
				let resultInclude = ruleInclude.exec(messageIn);

				if(resultInclude){
					validRule = messageData
					break;
				}
			}

		}

		if(validRule) return this.processRule(validRule.LabelName__c);

		return null;
	}

	processRule(label){
		let regex = /\$\{([\w]+)\}/gm;
		let matchs = regex.exec(label);
		let labelName = '';
		
		if(matchs){
			labelName = matchs[1];
		}

		return label.replace(regex, this._label[labelName]);
	}

	salesforceParse(message){
		const regex = /first error: ([\w+]+), (.*)/gm;

		let match = regex.exec(message);

		if(match) return match[2];

		return message;
	}

	showModal(title, message, type) {
		this.title = title;
		this.message = this.parseMessage(message);
		this.type = type;
		this.show = true;
	}

	showSuccess(title, message) {
		this.showModal(title, message, MobilityMessageModel.TYPES.SUCCESS);
	}

	showAlert(title, message) {
		this.showModal(title, message, MobilityMessageModel.TYPES.ALERT);
	}

	showWarning(title, message) {
		this.showModal(title, message, MobilityMessageModel.TYPES.WARNING);
	}

	showWarningWithCallback(title, message, confirmCallback){
		this.confirmWarningCallback = confirmCallback;
		this.showModal(title, message, MobilityMessageModel.TYPES.WARNING);
	}

	showCritical(title, message) {
		this.showModal(title, message, MobilityMessageModel.TYPES.CRITICAL);
	}

	get isSuccess() {
		return this.type === MobilityMessageModel.TYPES.SUCCESS;
	}

	get isWarning() {
		return this.type === MobilityMessageModel.TYPES.WARNING;
	}

	get isAlert() {
		return this.type === MobilityMessageModel.TYPES.ALERT;
	}

	get isCritical() {
		return this.type === MobilityMessageModel.TYPES.CRITICAL;
	}

	get isNotCritical() {
		return !this.isCritical;
	}

	get isNotClose() {
		return !this.isCritical && !this.isSuccess;
	}

	get iconName() {
		if (this.isSuccess) {
			return 'success';
		} else if (this.isWarning) {
			return 'warning';
		} else if (this.isAlert) {
			return 'alert';
		} else if (this.isCritical) {
			if (this.isNoData) {
				return 'desert';
			}
			return 'critical';
		}
	}

}