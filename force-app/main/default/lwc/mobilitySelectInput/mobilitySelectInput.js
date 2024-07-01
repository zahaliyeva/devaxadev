import {
	track,
	api
} from 'lwc';

import {
	MobilityAbstract
} from 'c/mobilityAbstract';

/**
 * This component requires: 
 * 		- a correct structure in request: (String keyword) 
 * 		- a correct structure in response to the Aura method {results: [{Id:'', Name:''}]}
 */
export default class MobilitySelectInput extends MobilityAbstract {
	componentView = 'mobilitySelectInput';
	
	searchHandler;

	@api label;
	@api searchInvoke;
	@api searchCallback;
	@api catchCallback;
	@api searchSelect;
	@api className = "col-4";
	@api keyName = null;

	@api 
	get value(){
		return this.keyword;
	}
	set value(nValue){
		this.keyword = nValue;
	}

	@track keyword = '';
	@track searchResults = [];


	connectedCallback() {
		this.connectHook();
		this.hideSpinner();
	}

	get hasResults(){
		return this.searchResults.length > 0;
	}

	onSearch = (e) => {
		let value = e.target.value;

		this.keyword = value;

		if(value.trim().length > 1){
			clearTimeout(this.searchHandler);
			this.searchHandler = setTimeout(this.invokeSearch, 600);
		}else{
			if(this.searchSelect) this.searchSelect([]);
			this.searchResults = [];
		}
	}

	onSelect = (e) => {
		let recordId = e.target.dataset.recordId;

		if(recordId){
			let results = this.searchResults.filter((result, resultIndex) => {
				return result.Id === recordId;
			})

			if(results.length > 0){
				let result = results[0];
				if(result) this.keyword = result.Name;

				if(this.searchSelect) this.searchSelect(results);

				this.searchResults = [];
			}
		}
	}

	invokeSearch = () => {
		if(!this.searchInvoke) throw new Error('searchInvoke not defined');

		this.showSpinner(true);
		this.searchInvoke({
			keyword: this.keyword
		}).then((result)=>{
			if(!result.isSuccess) throw new Error(result.errorMessage);
			
			if(this.searchCallback) this.searchCallback(result);

			this.searchResults = (this.keyName) ? result[this.keyName] : result.results;
		}).catch((err)=>{
			if(this.catchCallback) this.catchCallback(err);
		}).finally(()=>{
			this.hideSpinner();
		})
	}
}