import {
	LightningElement,
	track
} from 'lwc';

import MobilityBlackList from 'c/mobilityBlackList';


export default class MobilityBlackListEnrichment extends MobilityBlackList {
	componentView = 'mobilityBlackListEnrichment';

	showSave = false;
}