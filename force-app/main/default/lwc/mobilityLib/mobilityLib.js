import { LightningElement } from 'lwc';

export class MobilityLib {

	static baseUrl = '';

	static setBaseUrl(value){
		MobilityLib.baseUrl = value;
	}

	static getFromDateTime(dateString){
		const regex = /([0-9]{4})-([0-9]{2})-([0-9]{2})T([0-9]{2}):([0-9]{2}):([0-9]{2}).([0-9]{3})Z/gm;

		let match = regex.exec(dateString);

		if(match){
			return {
				year: match[1],
				month: match[2],
				day: match[3],
				hour: match[4],
				minute: match[5],
				second: match[6],
				millisecond: match[7] 
			}
		}

		return null;
	}

	static getFromDate(dateString){
		const regex = /([0-9]{4})-([0-9]{2})-([0-9]{2})/gm;

		let match = regex.exec(dateString);

		if(match){
			return {
				year: match[1],
				month: match[2],
				day: match[3]
			}
		}

		return null;
	}

	static hex (c) {
		var s = "0123456789abcdef";
		var i = parseInt (c);
		if (i == 0 || isNaN (c))
			return "00";
		i = Math.round (Math.min (Math.max (0, i), 255));
		return s.charAt ((i - i % 16) / 16) + s.charAt (i % 16);
	}

	/* Convert an RGB triplet to a hex string */
	static convertToHex (rgb) {
		return MobilityLib.hex(rgb[0]) + MobilityLib.hex(rgb[1]) + MobilityLib.hex(rgb[2]);
	}

	/* Remove '#' in color hex string */
	static trim (s) { return (s.charAt(0) == '#') ? s.substring(1, 7) : s }

	/* Convert a hex string to an RGB triplet */
	static convertToRGB (hex) {
		let color = [];
		color[0] = parseInt ((MobilityLib.trim(hex)).substring (0, 2), 16);
		color[1] = parseInt ((MobilityLib.trim(hex)).substring (2, 4), 16);
		color[2] = parseInt ((MobilityLib.trim(hex)).substring (4, 6), 16);
		return color;
	}

	static generateGradient(colorStart, colorEnd, colorCount = 5){

		// The beginning of your gradient
		var start = MobilityLib.convertToRGB(colorStart);    

		// The end of your gradient
		var end   = MobilityLib.convertToRGB(colorEnd);    

		// The number of colors to compute
		var len = colorCount;

		//Alpha blending amount
		var alpha = 0.0;

		var saida = [];
		
		for (let i = 0; i < len; i++) {
			var c = [];
			alpha += (1.0/len);
			
			c[0] = start[0] * alpha + (1 - alpha) * end[0];
			c[1] = start[1] * alpha + (1 - alpha) * end[1];
			c[2] = start[2] * alpha + (1 - alpha) * end[2];

			saida.push(`#${MobilityLib.convertToHex (c)}`);
			
		}
		
		return saida;
		
	}


	static processDataFromReport(label, reportData){
		let setData = {}

		setData.data = [];
		setData.backgroundColor = [];
		setData.total = 0;
		setData.label = label;
		setData.labels = [];
		setData.groupings = [];
		
		reportData.groupingsDown.groupings.slice().reverse().forEach((group)=>{
			setData.labels.push(group.label);
			setData.groupings.push({...group});
		});

		for(let key in reportData.factMap){
			const regex = /[0-9]+!T/gm;
			let factMap = reportData.factMap[key];
			if(regex.exec(key)){
				factMap.aggregates.forEach((aggregate)=>{
					setData.data.push(aggregate.value);
				})
			}else if(key == 'T!T'){
				factMap.aggregates.forEach((aggregate)=>{
					setData.total = aggregate.value;
				})
			}
		}

		setData.groupings.forEach((group, index)=>{
			group.value = setData.data[index];
		});

		return setData;
	}

	static processDataForLeadChart(label, LeadWrapper){
		let setData = {}

		setData.data = [];
		setData.backgroundColor = [];
		setData.total = LeadWrapper.length;
		setData.label = label;
		setData.labels = [];
		setData.groupings = [];
		setData.noData = true;
		let colorMap = new Map();
		let groupsMap = new Map();

		for(const element of LeadWrapper){
			setData.noData = false;
			
			if(element.colorCode){
				var temp
				if(colorMap.has(element.colorCode)){
					temp = colorMap.get(element.colorCode);
				}

				else{
					temp = new Map();
					colorMap.set(element.colorCode, temp);
				}
					
				if(element.leadData.Dettaglio__c){
					if(temp.has(element.leadData.Dettaglio__c)){
						temp.set(element.leadData.Dettaglio__c, temp.get(element.leadData.Dettaglio__c) + 1 );
					}
					else{
						temp.set(element.leadData.Dettaglio__c, 1);
					}
					if(groupsMap.has(element.leadData.Dettaglio__c)){
						groupsMap.set(element.leadData.Dettaglio__c, groupsMap.get(element.leadData.Dettaglio__c) + 1 );
					}
					else{
						groupsMap.set(element.leadData.Dettaglio__c, 1);
					}
				}
				else if(element.leadData.LeadSource){
					if(temp.has(element.leadData.LeadSource)){
						temp.set(element.leadData.LeadSource, temp.get(element.leadData.LeadSource) + 1 );
					}
					else{
						temp.set(element.leadData.LeadSource, 1);
					}
					if(groupsMap.has(element.leadData.LeadSource)){
						groupsMap.set(element.leadData.LeadSource, groupsMap.get(element.leadData.LeadSource) + 1 );
					}
					else{
						groupsMap.set(element.leadData.LeadSource, 1);
					}
				}
				
			}
		}
		if(!setData.noData){
			for(const[key, value] of colorMap){
				var label = '';
				var num = 0;
				for(const[key1, value1] of value){
					label += key1 + ' : ' + value1 + '\n';
					num += value1;
				}
				setData.labels.push(label);
				setData.data.push(num);
				setData.backgroundColor.push(key);
			}
			for(const[key, value] of groupsMap){
				var group = {label : ''+value+' '+key, count : value};
				var n = -1;
				var isSet = false;
				for(var i = 0; i < setData.groupings.length && !isSet; i++){
					if(setData.groupings[i].count <= value){
						n = i;
						isSet = true;
					}
					
				}
				if(n === -1){
				setData.groupings.push(group);
			}
				else{
					setData.groupings.splice(n, 0, group);
				}
				
			}
		}
		else{
			setData.backgroundColor.push("#C0C0C0");
			setData.data.push(1);
			setData.labels.push("no Data");
			setData.borderWidth = 0;
		}
		
		return setData;
	}

}