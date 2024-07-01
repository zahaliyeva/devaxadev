import {
	MobilityAbstract
} from "c/mobilityAbstract";
import {
	loadScript,
	loadStyle
} from 'lightning/platformResourceLoader';
import pikaday from '@salesforce/resourceUrl/pikaday';
import {
	api,
	track
} from "lwc";

import {
    TimeCollection,
    TimeModel
} from 'c/mobilityTimeModel';

export default class MobilityDatePicker extends MobilityAbstract {
	@api required;
	@api readonly;
	@api value;
	@api developerName;
	@api changeCallback;
	@api keydownCallback;
	@api type;
	@api rootDom;
	@api disabled;

	@track visible = false;
	@track visibleDays = false;
	@track visibleMonths = false;
	@track visibleYears = false;

	@track timeTech = new TimeModel();
	@track dateToSelect;
	@track toRight = false;

	@api minDate;

	picker;
	loadedScript = false;

	dateTech;
	timeValues = new TimeCollection();

	constructor(data) {
		super(data);

		let timeValues = [];

		for (let hour = 0; hour <= 23; hour++) {
			for (let minute = 0; minute <= 5; minute++) {
				let minuteDecimal = minute * 10;

				timeValues.push({
					hour: hour,
					minute: minuteDecimal
				})
			}
		}

		this.timeValues = new TimeCollection({
			collection: timeValues
		})
	}

	get timeValuesData(){
		let timeValues = this.timeValues.getAll();

		timeValues.forEach((time)=>{
			time.select = this.timeTech.time;
		});

		return timeValues;
	}

	get classContainer() {
		let style = ['box-container'];
		if (!this.visible) style.push('box-hidden');
		return style.join(' ');	
	}

	get classBox() {
		let style = ['box'];

		if (!this.visibleDays) style.push('box-hidden');
		if(this.toRight) style.push('box-right');

		return style.join(' ');	
	}

	get classMonths(){
		let style = ['box-months'];

		if(this.toRight) style.push('box-right');

		return style.join(' ');	
	}

	get classYears(){
		let style = ['box-years'];

		if(this.toRight) style.push('box-right');

		return style.join(' ');	
	}

	get isDatetime(){
		return this.type === 'datetime';
	}

	get isDate(){
		return this.type !== 'datetime';
	}

	get showTime(){
		return this.isDatetime;
	}

	get classRoot(){
		let classes = [];

		if(this.showTime){
			classes.push('col-6');
		}else{
			classes.push('col-12');
		}

		return classes.join(' ');
	}

	get timeSelected(){
		return this.timeTech.time;
	}

	get dateString(){
		if(!this.value) return '';
		if(!this.picker) return '';
		return this.picker.toString();
	}

	get dateMoment(){
		return moment(this.value || new Date());
	}

	get dateToSelectMoment(){
		return moment(this.dateToSelect);
	}

	get months(){
		return [
			'Gennaio',
			'Febbraio',
			'Marzo',
			'Aprile',
			'Maggio',
			'Giugno',
			'Luglio',
			'Agosto',
			'Settembre',
			'Ottobre',
			'Novembre',
			'Dicembre'
		];
	}

	get yearsRange(){
		const momentInstance = moment(this.dateToSelectMoment);
		const currentYear = momentInstance.year();

		return{
			start: currentYear - 7,
			currentYear,
			end: currentYear + 8
		}
	}

	get years(){
		const range = this.yearsRange;
		
		const years = [];
		for(let index = range.start; index <= range.end; index ++){
			years.push(index);
		}

		return years;
	}


	errorCallback(error, stack){
		console.log(error);
		console.log(stack);
	}

	connectedCallback() {
		if(typeof Pikaday === 'undefined'){
		let promises = [
			loadStyle(this, pikaday + '/pikaday.css'),
			loadStyle(this, pikaday + '/mobility-theme.css'),
			loadScript(this, pikaday + '/moment.js'),
			loadScript(this, pikaday + '/pikaday.js')
		];

		Promise.all(promises).then(this.instance);
	}
	}

	renderedCallback() {
		if(typeof Pikaday !== 'undefined' && !this.picker) this.instance();
	}

	checkPosition = () => {
		if(this.rootDom){
		const rootRect = this.rootDom.getBoundingClientRect();

		const elementDom = this.template.querySelector('input');
		const elementRect = elementDom.getBoundingClientRect();

		const bordered = elementRect.x + 320;

		this.toRight = bordered > rootRect.width;
	}
	}


	instance = () => {
		if(this.isDate) this.dateTech = moment(this.value).toDate();
		if(this.isDatetime){
			this.dateTech = moment(this.value).toDate();
			
			let dateObject = this.getDateObject(this.dateTech);
			this.timeTech = new TimeModel({hour:dateObject.hours, minute:dateObject.minutes});
		}

		this.picker = new Pikaday({
			theme: 'mobility-theme',
			field: this.template.querySelector('input'),
			container: this.template.querySelector('box'),
			firstDay: 1,
			minDate: this.minDate,
			defaultDate: this.dateTech,
			setDefaultDate: true,
			showDaysInNextAndPreviousMonths: true,
			bound: false,
			keyboardInput: false,
			i18n: {
				previousMonth: this._label.datapicker_PreviousMonth,
				nextMonth: this._label.datapicker_NextMonth,
				months: [this._label.datapicker_January, this._label.datapicker_February, this._label.datapicker_March, this._label.datapicker_April, this._label.datapicker_May, this._label.datapicker_June, this._label.datapicker_July, this._label.datapicker_August, this._label.datapicker_September, this._label.datapicker_October, this._label.datapicker_November, this._label.datapicker_December],
				weekdays: [this._label.datapicker_Sunday, this._label.datapicker_Monday, this._label.datapicker_Tuesday, this._label.datapicker_Wednesday, this._label.datapicker_Thursday, this._label.datapicker_Friday, this._label.datapicker_Saturday],
				weekdaysShort: [this._label.datapicker_Sun, this._label.datapicker_Mon, this._label.datapicker_Tue, this._label.datapicker_Wed, this._label.datapicker_Thu, this._label.datapicker_Fri, this._label.datapicker_Sat]
			},
			parse: (dateString, format) => {
				const parts = dateString.split('/');
				const day = parseInt(parts[0], 10);
				const month = parseInt(parts[1], 10) - 1;
				const year = parseInt(parts[2], 10);
				return new Date(year, month, day);
			},
			toString: (date) => {
				let dateObject = this.getDateObject(date);

			    return `${dateObject.dayString}/${dateObject.monthString}/${dateObject.year}`;
			},
			onSelect: (date, target) => {
				this.dateTech = this.getDate(date);

			    this.updateTime();			    
				this.close();
			},
			onOpen: (target) =>{
				console.log('open');
			},
			onClose: (target) => {
				console.log('close');
			},
			onShowMonths: (target) => {
				console.log('onShowMonths');
				this.dateToSelect = this.value || new Date();
				this.openMonths();
			},
			onShowYears: (target) => {
				console.log('onShowYears');
				this.dateToSelect = this.value || new Date();
				this.openYears();
			}
		});
	}

	updateDate = (value) => {
		this.changeCallback({
			target: {
				value: value,
				name: this.developerName
			}
		});
	}

	changeData = (e) => {
		e.stopPropagation();
		if(e.target.value !== '') return;

		this.updateDate(e.target.value);
	}

	open = () =>{
		this.visible = true;
		this.visibleDays = true;
		this.visibleMonths = false;
		this.visibleYears = false;	

		this.checkPosition();	
	}

	close = () =>{
		this.template.querySelector('input').blur();
		this.visible = false;
		this.visibleDays = false;
		this.visibleMonths = false;
		this.visibleYears = false;
	}

	openDays = () => {
		this.visible = true;
		this.visibleDays = true;
		this.visibleMonths = false;
		this.visibleYears = false;
	}

	openMonths = () => {
		this.visible = true;
		this.visibleDays = false;
		this.visibleMonths = true;
		this.visibleYears = false;
	}

	openYears = () => {
		this.visible = true;
		this.visibleDays = false;
		this.visibleMonths = false;
		this.visibleYears = true;
	}

	changeTime = e => {
		let value = e.target.value;

		if(value){
			let timeDetail = value.split(':');

			let hours = parseInt(timeDetail[0]);
			let minutes = parseInt(timeDetail[1]);

			this.timeTech = new TimeModel({hour:hours,minute:minutes});

			this.updateTime();
		}
	}

	updateTime = () => {
		let momentInstance = moment(this.dateTech);

		if(this.isDatetime){
			momentInstance.set(this.timeTech);

			this.dateTech = momentInstance.toDate();
		}

		this.sendDate();
	}

	sendDate = () => {
		this.updateDate(this.dateTech);
	}

	getDateObject(date){
	    let day = date.getDate();
	    let month = date.getMonth() + 1;
	    let year = date.getFullYear();
	    let hours = date.getHours();
	    let minutes = date.getMinutes();
	    let seconds = date.getSeconds();

	    let dayString = day;
	    let monthString = month;
	    let hoursString = hours;
	    let minutesString = minutes;
	    let secondsString = seconds;

	    if(day<10)dayString=`0${day}`;
	    if(month<10)monthString=`0${month}`;
	    if(hours<10)hoursString=`0${hours}`;
	    if(minutes<10)minutesString=`0${minutes}`;
	    if(seconds<10)secondsString=`0${seconds}`;

	    return{
	    	day,
	    	month,
	    	year,
	    	hours,
	    	minutes,
	    	seconds,
	    	dayString,
	    	monthString,
	    	hoursString,
	    	minutesString,
	    	secondsString
	    }
	}

	getDateTimeString(date){
		let dateObject = this.getDateObject(date);
	    return `${dateObject.year}-${dateObject.monthString}-${dateObject.dayString}T${dateObject.hoursString}:${dateObject.minutesString}:${dateObject.secondsString}+00:00`;
	}

	getDate(date){
		let datetimeString = this.getDateTimeString(date);
	    return moment(datetimeString).toDate();
	}

	onNextYear = () => {
		const momentInstance = this.dateToSelectMoment;

		momentInstance.add(1, 'years');

		this.dateToSelect = momentInstance.toDate();
	}

	onPrevYear = () => {
		const momentInstance = this.dateToSelectMoment;
		
		momentInstance.subtract(1, 'years');

		this.dateToSelect = momentInstance.toDate();
	}

	onNextYears = () => {
		const momentInstance = this.dateToSelectMoment;

		momentInstance.add(16, 'years');

		this.dateToSelect = momentInstance.toDate();
	}

	onPrevYears = () => {
		const momentInstance = this.dateToSelectMoment;
		
		momentInstance.subtract(16, 'years');

		this.dateToSelect = momentInstance.toDate();
	}

	onMonthSelect = e => {
		this.preventDefault(e);

		const value = e.target.dataset.value;
		
		const momentInstance = this.dateToSelectMoment;
		momentInstance.month(value);

		this.picker.setDate(momentInstance.toDate());

		this.openDays();
	}

	onYearSelect = e => {
		this.preventDefault(e);

		const value = e.target.dataset.value;

		const momentInstance = this.dateToSelectMoment;
		momentInstance.year(value);

		this.picker.setDate(momentInstance.toDate());

		this.openDays();

	}

	onPreventBlur = e => {
		this.preventDefault(e);
	}

	focusCallback(){
		if(this.readonly) return;

		this.open();
	}

	blurCallback() {
		this.close();
	}
}