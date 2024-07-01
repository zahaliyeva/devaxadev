/* eslint-disable radix */
import {
	Model,
	ModelCollection
} from 'c/mobilityAbstractModel';

export class MobilityFileCollection extends ModelCollection {

	_childType() {
		return MobilityFileModel;
	}
}

export class MobilityFileModel extends Model {

	_model() {
		return {
			Title: '',
			FileExtension: '',
			CreatedDate: null,
			VersionData: '',
			ContentUrl: '',
			PathOnClient: '',
			ContentDocumentId: null,
			ContentSize: 0,
		}
	}

	get Size(){
		let bytes = Number(this.ContentSize);
		let decimals = 2;

		if (bytes === 0) return '0 Bytes';

		const k = 1024;
		const dm = decimals < 0 ? 0 : decimals;
		const sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];

		const i = Math.floor(Math.log(bytes) / Math.log(k));

		return parseFloat((bytes / Math.pow(k, i)).toFixed(dm)) + ' ' + sizes[i];
	}

	get CreateDateString() {
		if (!this.CreatedDate) return '';
		let dateObject = this.getDateTimeFormated(this.CreatedDate);
		return `${dateObject.days}/${dateObject.months}/${dateObject.years}`;
	}
}