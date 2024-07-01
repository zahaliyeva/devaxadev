import {
	track,
	api
} from 'lwc';

import {
	MobilityFileCollection,
} from 'c/mobilityFileModel';

import {
	MobilityAbstract
} from 'c/mobilityAbstract';

import {
	MobilityPaginationModel
} from "c/mobilityPaginationModel";

import uploadFile from '@salesforce/apex/MobilityDocuments.uploadFile';
import getFilesList from '@salesforce/apex/MobilityDocuments.getFilesList';
import deleteContentDocuments from '@salesforce/apex/MobilityDocuments.deleteContentDocuments';
import getUploadFilePage from '@salesforce/apex/MobilityDocuments.getUploadFilePage';

const MAX_FILE_SIZE = 1500000;

export default class MobilityUploadFile extends MobilityAbstract {
	componentView = 'mobilityUploadFile';

	@api parentId;

	@api perPage = 5;
	@api maxPerPage = 10;
	@api lengthList = 2;

	@track fileList = new MobilityFileCollection();
	@track pagination = {};

	filesUploaded = [];
	file;
	fileName;
	fileContents;
	fileReader;
	fileId;

	page = 0;

	connectedCallback() {
		super.connectedCallback();
		this.loadPagination(this.page);
	}

	handleFilesChange = (e) => {
		if (e.target.files.length > 0) this.filesUploaded = e.target.files;
		if (this.filesUploaded.length > 0) this.uploadHelper();
	}

	loadPagination(page = 0) {
		this.showSpinner(true);
		return getUploadFilePage({
			recordId: this.parentId,
			page: page,
			perPage: this.perPage || this.params.perPage,
			maxPerPage: this.maxPerPage || this.params.maxPerPage,
			lengthList: this.lengthList || this.params.lengthList
		}).then((result) => {
			this.pagination = new MobilityPaginationModel(this.proxyData(result));
			this.fileList = new MobilityFileCollection({
				collection: this.proxyData(this.pagination.elements)
			}, true);
			this.showNoData(this.fileList.length === 0);
		}).catch((err) => {
			console.log('Pagination Error: ', this.proxyData(err));
		}).finally(() => {
			this.hideSpinner();
		})
	}

	onChangePage = (page) => {
		this.loadPagination(page);
	}

	/*filesList = () => {
		return getFilesList({
			recordId: this.parentId
		}).then((result) => {
			this.fileList = new MobilityFileCollection({
				collection: result
			});
		}).finally(() => {
			this.hideSpinner();
		})
	}*/

	get hasSelectedFiles() {
		return this.filesUploaded.length > 0
	}

	get data() {
		return this.fileList.getAll();
	}

	handleSave = () => {
		this.template.querySelector('input').click();
	}

	uploadHelper = () => {
		this.file = this.filesUploaded[0];
		this.fileName = this.file.name;

		if (this.file.size > MAX_FILE_SIZE) {
			console.log('File Size is to long');
			return;
		}

		this.showSpinner();
		// create a FileReader object 
		this.fileReader = new FileReader();
		// set onload function of FileReader object  
		this.fileReader.onloadend = (() => {
			let base64 = 'base64,';

			this.fileContents = this.fileReader.result;
			this.content = this.fileContents.indexOf(base64) + base64.length;
			this.fileContents = this.fileContents.substring(this.content);

			// call the uploadProcess method 
			this.saveToFile();
		});

		this.fileReader.readAsDataURL(this.file);
	}

	saveToFile = () => {
		uploadFile({
			parentId: this.parentId,
			base64: encodeURIComponent(this.fileContents),
			title: this.fileName
		}).then((result) => {
			if (!result.isSuccess) throw new Error(result.errorMessage);

			this.loadPagination(this.page);
		}).catch((err) => {
			this.alertMessage('Error', err.message);
		})
	}

	confirmWarningCallback = () => {
		this.showSpinner(true);

		deleteContentDocuments({
			recordIdList: [this.fileId]
		}).then((result) => {
			if (!result.isSuccess) throw new Error(result.errorMessage);
			this.loadPagination(this.page);
		}).catch((err) => {
			this.alertMessage('Error', err.message);
		}).finally(() => {
			this.hideSpinner();
		})
	}

	deleteFile = (e) => {
		this.warningMessage('', 'Sei sicuro di voler eliminare l\'allegato ?')
		this.fileId = e.currentTarget.dataset.id;
	}
}