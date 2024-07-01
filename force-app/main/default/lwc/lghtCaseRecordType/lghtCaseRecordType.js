import { LightningElement, api, wire, track } from 'lwc';

import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import OBJECT_SCHEMA from '@salesforce/schema/Case';

import { LghtAbstract } from 'c/lghtAbstract';

export default class LghtCaseRecordType extends LghtAbstract {
	
	@api loadCallback;
	@api cancelCallback;
	@api confirmCallback;

	@track listRecordTypes = [];

	@wire(getObjectInfo, { objectApiName: OBJECT_SCHEMA })
	objectInfo({data, error}){
		if(data){
			const recordsTypes = data.recordTypeInfos;

			let resultData = [];

			for(let index in recordsTypes){
				let recordType = recordsTypes[index];

				if(recordType.master) continue;

				resultData.push({...recordType, Id: recordType.recordTypeId});
			}

			console.log('resultData', resultData);
			this.listRecordTypes = resultData.sort((recordTypeA, recordTypeB)=>{
				if(recordTypeA.name < recordTypeB.name) return -1;
				if(recordTypeA.name > recordTypeB.name) return 1;

				return 0;
			});

			if(this.loadCallback) this.loadCallback();
		}
	}
}