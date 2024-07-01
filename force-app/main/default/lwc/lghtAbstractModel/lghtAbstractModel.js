export class Model {

	static count = 0;
	static debug = true;

	constructor(data = {}) {
		if (data.Id) {
			this.Id = data.Id;
		} else {
			this.Id = this.uniqueID();
		}

		this._setModel(data);
	}

	uniqueID() {
		if (Model.debug) return ++Model.count;

		function chr4() {
			return Math.random().toString(16).slice(-4);
		}

		return chr4() + chr4() +
			'-' + chr4() +
			'-' + chr4() +
			'-' + chr4() +
			'-' + chr4() + chr4() + chr4();
	}

	_setModel(data = {}) {
		let __model = this._model();
		let __types = this._types();

		//SET BASE MODEL
		for (let key in __model) {
			this[key] = __model[key];
		}

		//SET INPUT DATA
		for (let key in __model) {
			let value = data[key];

			if (value !== undefined) {
				this[key] = value;
			}
		}
	}

	_uniqueKey() {
		return ['id'];
	}

	_resetModel() {
		this._setModel(this._model);
	}

	_model() {
		return {};
	}

	_types() {
		return {};
	}

	_validation(object, Type) {
		let isInstanceof = (object instanceof Type);
		if (!isInstanceof) throw new TypeError("Value of argument 'Type' violates.");
	}

	_cast(object, Type) {
		let isInstanceof = (object instanceof Type);

		if (!isInstanceof) return new Type(object);

		return object;
	}

	_getModel() {
		let toExport = {};
		for (let key in this) {
			toExport[key] = this[key];
		}

		return toExport;
	}

	getById(_id) {
		let search = this.getAll().filter((item, itemId) => {
			return item.Id === _id;
		})

		if (search.length === 1) {
			return search[0];
		}

		return null;
	}

	getWithProps() {
		let returnData = {};

		for (let i in this) {
			returnData[i] = this[i];
		}

		let descriptors = Object.getOwnPropertyDescriptors(Object.getPrototypeOf(this));
		for (let i in descriptors) {
			let descriptor = descriptors[i];

			if (descriptor.get) {
				returnData[i] = this[i];
			}
		}

		return returnData;
	}

	getDateTimeFormated(date) {
		let dateObject = new Date(date);

		let clean = function (dateValue) {
			if (dateValue < 10) return `0${dateValue}`;

			return `${dateValue}`;
		}

		let days = clean(dateObject.getDate());
		let months = clean(dateObject.getMonth() + 1);
		let years = dateObject.getFullYear();

		let hours = clean(dateObject.getHours());
		let minutes = clean(dateObject.getMinutes());
		let seconds = clean(dateObject.getSeconds());

		return {
			days,
			months,
			years,
			hours,
			minutes,
			seconds
		}

	}

	_getData() {
		let __model = this._model();
		let result = {};

		//SET BASE MODEL
		for (let key in __model) {
			result[key] = this[key];
		}

		return result;
	}

	debug() {
		console.log('++++++++++++++++++++++++');
		console.log(...arguments);
		console.log('+++++++++++++++++++++++++');
	}
}

export class ModelCollection extends Model {

	collection = {};

	constructor(data) {
		super(data);

		if (data && data.collection){
			this.addAll(data.collection);
		}else if(Array.isArray(data)){
			this.addAll(data);
		}
	}

	_childType() {
		return Model
	}

	get length() {
		return Object.keys(this.collection).length;
	}

	_getUniqueId(data) {
		let dataInstance = this._cast(data, this._childType());

		let results = this.getAll().filter((element) => {
			return dataInstance.Id === element.Id;
		});

		if (results.length > 0) {
			return results[0].Id;
		}

		return null;
	}

	add(data) {
		let dataInstance = this._cast(data, this._childType());

		let uniqueId = this._getUniqueId(dataInstance) || dataInstance.Id;

		if (uniqueId) dataInstance.Id = uniqueId;

		this.collection[uniqueId] = dataInstance;

		return dataInstance.Id;
	}

	clean() {
		this.collection = {};
	}

	get(index) {
		let result = this.collection[index];

		if (result) return result;

		return this.getAll()[index];
	}

	getByName(name) {
		let searchResults = this.getAll().filter((element) => {
			return element.name == name;
		})

		if (searchResults.length == 1) return searchResults[0];

		return null;
	}

	getAll(filter) {
		if (!filter) return this._getAll(this.collection);

		return this._getAll(this.collection).filter(filter);
	}

	forEach(forFunction) {
		for (let collectionId in this.collection) {
			forFunction(this.collection[collectionId]);
		}
	}

	remove(data) {
		if (this.collection[data.Id]) {
			delete this.collection[data.Id];
		}
	}

	setAndClean(data) {
		let dataInstance = this._cast(data, this._childType());

		this.collection = {
			[dataInstance.Id]: dataInstance
		}
	}

	count() {
		return Object.keys(this.collection).length;
	}

	addAll(arrayData = []) {
		for (let arrayId in arrayData) {
			this.add(arrayData[arrayId]);
		}
	}

	pagination(page = 0, perPage = 30) {
		return Utils.pagination(this.getAll(), page, perPage);
	}

	_getAll(target) {
		let returnList = [];

		for (let targetId in target) {
			returnList.push(target[targetId]);
		}

		return returnList;
	}

	static instanceCollection(arrayData = []) {
		let instance = new this();


		instance.addAll(arrayData);

		return instance;
	}
}