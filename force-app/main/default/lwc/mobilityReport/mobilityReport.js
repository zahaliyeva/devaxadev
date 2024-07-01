import { LightningElement, track, api, wire } from 'lwc';

import { MobilityLib } from 'c/mobilityLib';
import { MobilityAbstract } from 'c/mobilityAbstract';

import getReport from '@salesforce/apex/MobilityReportController.getReport';

export default class MobilityReport extends MobilityAbstract {
	@track setData = null;
	@track reportId;

	@api filterName;
	@api filterValue;
	
	@api colorStart;
	@api colorEnd;
	@api label;
	@api reportName;

	connectedCallback(){
		this.loadReport(this.reportName);
	}

	onOpenReport(){
		this.openReport(this.reportId, {fv2: this.filterValue});
	}

	loadReport(reportDeveloperName){
		const request = {
			reportDeveloperName,
			filterName: this.filterName,
			filterValue: this.filterValue
		}

		return getReport(request).then((result)=>{
			this.reportId = result.reportId;
			
			const reportData = JSON.parse(result.reportResult);

			const setData = MobilityLib.processDataFromReport(this.label, reportData);
			setData.backgroundColor = MobilityLib.generateGradient(this.colorStart, this.colorEnd, setData.data.length);

			setData.groupings.forEach((group, index)=>{
				group.backgroundColor = setData.backgroundColor[index];
				
				group.style = `background-color: ${group.backgroundColor};`;
			});

			console.log('setData', setData);
			this.setData = setData;
		}).catch((err)=>{
			console.log('err', this.proxyData(err));
		})
	}
}