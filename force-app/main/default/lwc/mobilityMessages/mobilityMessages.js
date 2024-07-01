import {
	api
} from 'lwc';
import {
	MobilityAbstract
} from 'c/mobilityAbstract';
import {
	MobilityMessageModel
} from 'c/mobilityMessageModel';

export default class MobilityMessages extends MobilityAbstract {

	@api model;
	@api confirmSuccessCallback;
	@api confirmWarningCallback;
	@api cancelAlertCallback;
	@api cancelWarningCallback;

	@api labelSuccessOk;
	@api labelAlertBack;
	@api labelWarningBack;
	@api labelWarningConfirmation;

	onToogle() {
		this.model.show = !this.model.show;
		this.model = new MobilityMessageModel(this.model);
	}

	onCancelAlert(e) {
		if (this.cancelAlertCallback) this.cancelAlertCallback(e);
		this.onHide(e);
	}

	onCancelWarning(e) {
		if (this.cancelWarningCallback) this.cancelWarningCallback(e);
		this.onHide(e);
	}

	onHide(e) {
		this.onToogle();
	}

	onConfirmSuccess(e) {
		if (this.confirmSuccessCallback) this.confirmSuccessCallback(e);
		this.onToogle();
	}

	onConfirmWarning(e) {
		if (this.confirmWarningCallback) this.confirmWarningCallback(e);
		else if( this.model.confirmWarningCallback) this.model.confirmWarningCallback(e);
		this.onToogle();
	}

	get labelOk() {
		if (this.labelSuccessOk) return this.labelSuccessOk;
		return this._label.messages_ok;
	}

	get labelBack() {
		if (this.labelWarningBack) return this.labelWarningBack;
		return this._label.messages_back;
	}

	get labelBackAlert() {
		if (this.labelAlertBack) return this.labelAlertBack;
		return this._label.messages_back;
	}

	get labelConfirmation() {
		if (this.labelWarningConfirmation) return this.labelWarningConfirmation;
		return this._label.messages_confirmation;
	}
}