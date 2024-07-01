import { LightningElement, track, api } from 'lwc';

export default class VendorSelect extends LightningElement {

	@api id;
	@api name = '';
	@api label = '';
	@api placeholder = '';
	@api readonly = false;
	@api limitOptions = 3;
	@api cleanSelect = false;
	@api labelWithValue = false;
	
	@api callbackInput;
	@api callbackFocus;
	@api callbackBlur;
	@api callbackSelection;
	@api callbackIcon;
	
	@api 
	get options(){
		return this._options;
	}
	set options(_items){
		this._options = [..._items];
	}

	@api
	get value(){
		return this._value;
	}
	set value(input){
		this._value = input || '';
	}
	
	@track _value = '';
	@track label = '';
	@track _optionsView = [];
	@track showSelection = false;
	
	_options = [];
	handlerInput;

	get hasLabel(){
		return !!this.label;
	}

	get showResults(){
		return this.showSelection && this._optionsView.length > 0;
	}
	optionsFilter = async () => {
		console.log('optionsFilter');
		console.time('optionsFilter')
		this._optionsView = this._options
		.filter((element)=>(
			element.value.search(new RegExp(`${this._value}`, 'i')) > -1 ||
			element.label.search(new RegExp(`${this._value}`, 'i')) > -1
		)) 
		.slice(0, this.limitOptions)
		.map((element)=>({
			value: element.value,
			label: (this.labelWithValue) ? `${element.value} - ${element.label}` : element.label,
			labelClean: element.label,
			selected: element.value === this._value
		}));

		console.timeLog('optionsFilter')
		console.timeEnd('optionsFilter')
	}

	invokeEvent(eventName, params){
		console.log('invokeEvent', eventName);
		console.log('invokeEvent.params', params);

		const eventPayload = new CustomEvent(eventName, params);
		console.log('payload: ', JSON.parse(JSON.stringify(eventPayload)));
		console.log('eventPayload', {...eventPayload});
		
		// Fire the custom event
		this.dispatchEvent(eventPayload); 
	}

	selection(value, label, enter = false){
		this._value = (!this.cleanSelect) ? label : '';
		this.showSelection = false;

		//if(this.callbackSelection) this.callbackSelection({target: {name: this.name, value, label, enter}});
		this.invokeEvent('change', {value, detail: {label, value, enter}})
	}

	onKeyUp(e){
		if(e.keyCode === 13){
			e.preventDefault();
			//if(this.callbackInput) this.callbackInput(e.currentTarget.value);
			const value = e.currentTarget.value;
			this.invokeEvent('enter', {value})
		}
	}

	onClickIcon(e){
		this.invokeEvent('enter', {value: this.value})
	}

	onInput(e){
		this._value = e.currentTarget.value;

		this.showSelection = true;
		if(this.callbackInput) this.callbackInput(this.value);

		clearTimeout(this.handlerInput);
		this.handlerInput = setTimeout(this.optionsFilter, 300);
	}

	onFocus(e){
		this.showSelection = true;
		if(this.callbackFocus) this.callbackFocus(e);
	}

	onBlur(e){
		setTimeout(()=>{this.showSelection = false}, 200);
		if(this.callbackBlur) this.callbackBlur(e);
	}

	onSelction(e){
		const { value, label } = e.currentTarget.dataset;
		this.selection(value, label)
	}
}