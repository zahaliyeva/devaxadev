public with sharing class SObjectTable {

	public static final String ORDER_DESC = 'DESC';
	public static final String ORDER_ASC = 'ASC';
	
	public static final Integer LIMIT_MAX = 20000;
	public static final Boolean CHACHED_MODE_DEFAULT = true;

	public class QueryType{
		@AuraEnabled public String querySelect;
		@AuraEnabled public String queryFrom;
		@AuraEnabled public String queryWhere;
		@AuraEnabled public String querySearch;
		@AuraEnabled public String queryOrder;
		@AuraEnabled public String queryLimit;
		@AuraEnabled public String queryGroup;
		@AuraEnabled public String queryOffset;

		public Set<String> fieldsSet;
		public String sobjectName;
		public Set<String> andCondition;
		public Set<String> orderBy;
		public Set<String> groupBy;
		public Set<String> searchBy;
		public Integer limitRecords;
		public Integer offsetRecords;

		public QueryType(
			Set<String> fieldsSet,
			String sobjectName,
			Set<String> andCondition,
			Set<String> orderBy,
			Set<String> searchBy,
			Integer limitRecords,
			Integer offsetRecords
		){
			this.fieldsSet = fieldsSet;
			this.sobjectName = sobjectName;
			this.andCondition = andCondition;
			this.orderBy = orderBy;
			this.searchBy = searchBy;
			this.limitRecords = limitRecords;
			this.offsetRecords = offsetRecords;
		}

		public void setData(){
			String selectTemplate = 'SELECT {0}';
			String fromTemplate = 'FROM {0}';
			String whereTemplate = 'WHERE {0}';
			String searchTemplate = 'AND ({0})';
			String searchOnlyTemplate = 'WHERE ({0})';
			String orderByTemplate = 'ORDER BY {0} NULLS LAST';
			String limitTemplate = 'LIMIT {0}';
			String offsetTemplate = 'OFFSET {0}';
			String groupTemplate = 'GROUP BY {0}';

			this.querySelect = SObjectTable.applyTemplate(this.fieldsSet, selectTemplate, ', ');
			this.queryFrom = SObjectTable.applyTemplate(this.sobjectName, fromTemplate, ', ');

			if (this.andCondition != null && this.andCondition.size() > 0) {
				this.queryWhere = SObjectTable.applyTemplate(this.andCondition, whereTemplate, ' AND ');

				if(this.searchBy != null && this.searchBy.size() > 0){
					this.querySearch = SObjectTable.applyTemplate(this.searchBy, searchTemplate, ' OR ');
				}
			}

			if (this.andCondition != null && this.andCondition.size() == 0) {			
				if(this.searchBy != null && this.searchBy.size() > 0){
					this.querySearch = SObjectTable.applyTemplate(this.searchBy, searchOnlyTemplate, ' OR ');
				}
			}

			if (this.orderBy != null && this.orderBy.size() > 0) {
				this.queryOrder = SObjectTable.applyTemplate(this.orderBy, orderByTemplate, ', ');
			}

			if (this.limitRecords != null && this.limitRecords > 0) {
				this.queryLimit = SObjectTable.applyTemplate(this.limitRecords, limitTemplate, ', ');
			}

			if (this.offsetRecords != null && this.offsetRecords > -1) {
				this.queryOffset = SObjectTable.applyTemplate(this.offsetRecords, offsetTemplate, ', ');
			}

			if (this.groupBy != null && this.groupBy.size() > 0) {
				this.queryGroup = SObjectTable.applyTemplate(this.groupBy, groupTemplate, ', ');
			}
		}

		public String getQuery(){
			this.setData();

			List < String > queryElements = new List < String > ();
			
			queryElements.add(this.querySelect);
			queryElements.add(this.queryFrom);

			if (String.isNotBlank(this.queryWhere)){
				queryElements.add(this.queryWhere);

				if(String.isNotBlank(this.querySearch)){
					queryElements.add(this.querySearch);
				}
			}

			if (String.isBlank(this.queryWhere)) {			
				if(String.isNotBlank(this.querySearch)){
					queryElements.add(this.querySearch);
				}
			}

			if (String.isNotBlank(this.queryOrder)) {
				queryElements.add(this.queryOrder);
			}

			if (String.isNotBlank(this.queryLimit)) {
				queryElements.add(this.queryLimit);
			}

			if (String.isNotBlank(this.queryOffset)) {
				queryElements.add(this.queryOffset);
			}

			if (String.isNotBlank(this.queryGroup)) {
				queryElements.add(this.queryGroup);
			}

			String queryString = String.join(queryElements, ' ');
			System.debug('+++ queryString: ' + queryString);
			return queryString;
		}
	}

	public class TablePagination {
		@AuraEnabled public Boolean cachedMode;
		@AuraEnabled public Integer maxRecords = LIMIT_MAX;

		@AuraEnabled public Integer prevPage;
		@AuraEnabled public Integer nextPage;
		@AuraEnabled public Integer maxPage;
		@AuraEnabled public Integer page;
		@AuraEnabled public Integer perPage;
		@AuraEnabled public Boolean hasPrevPage;
		@AuraEnabled public Boolean hasNextPage;
		@AuraEnabled public Integer length;
		@AuraEnabled public Integer total;
		@AuraEnabled public Integer startPage;
		@AuraEnabled public Integer endPage;
		@AuraEnabled public Integer lengthList;
		@AuraEnabled public String 	Message;
		@AuraEnabled public List < Object > elements;
		@AuraEnabled public List < Object > elementsCached;
		@AuraEnabled public List < Integer > prevPages = new List < Integer > ();
		@AuraEnabled public List < Integer > nextPages = new List < Integer > ();

		@AuraEnabled public List < String > columns = new List < String > ();
		@AuraEnabled public Map < String, String > labels = new Map < String, String > ();
		@AuraEnabled public Map < String, Object > additionalData = new Map < String, Object > ();

		@AuraEnabled
		public String baseUrl {get; set;}

		public TablePagination(){}

		public TablePagination(List < Object > elements, Integer total, Integer page, Integer perPage, Integer maxPerPage, Integer lengthList) {
			this(elements, total, page, perPage, maxPerPage, lengthList, false, CHACHED_MODE_DEFAULT);
		}

		public TablePagination(List < Object > elements, Integer total, Integer page, Integer perPage, Integer maxPerPage, Integer lengthList, Boolean hasFullData) {
			this(elements, total, page, perPage, maxPerPage, lengthList, hasFullData, CHACHED_MODE_DEFAULT);
		}

		public TablePagination(List < Object > elements, Integer total, Integer page, Integer perPage, Integer maxPerPage, Integer lengthList, Boolean hasFullData, Boolean cachedMode) {
			this.cachedMode = cachedMode;
			this.lengthList = lengthList;
			this.page = page;
			this.perPage = perPage;
			this.total = total;

			if (this.perPage > maxPerPage) this.perPage = maxPerPage;

			this.prevPage = page - 1;
			if (this.prevPage < 0) this.prevPage = -1;

			this.hasPrevPage = (page > 0);

			this.maxPage = Integer.valueOf((total - 1) / this.perPage);

			if (this.prevPage > this.maxPage) this.prevPage = this.maxPage;

			this.nextPage = page + 1;
			if (this.nextPage > this.maxPage) this.nextPage = -1;

			this.hasNextPage = page < this.maxPage;

			this.startPage = page * this.perPage;
			this.endPage = this.startPage + this.perPage;

			if (hasFullData || this.cachedMode) {
				this.elementsCached = elements;
				this.elements = new List < Object > ();

				for (Integer index = this.startPage; index < this.endPage; index++) {
					if (index < elements.size()) {
						this.elements.add(elements.get(index));
					}
				}
			} else {
				this.elements = elements;
				//System.debug('elements: ' + this.elements);
			}
			//System.debug('hasFullData: ' + hasFullData);

			this.length = this.elements.size();

			this.prevPages = new List < Integer > ();
			Integer prevPagesMax = page - lengthList;
			if (prevPagesMax < 0) prevPagesMax = 0;
			for (Integer i = prevPagesMax; i <= page - 1; i++) this.prevPages.add(i);

			this.nextPages = new List < Integer > ();
			Integer nextPagesMax = page + lengthList;
			if (nextPagesMax > this.maxPage) nextPagesMax = this.maxPage;
			for (Integer i = page + 1; i <= nextPagesMax; i++) nextPages.add(i);
		}
	}

	public class SObjectStrategy{
		@AuraEnabled public Boolean cachedMode					= CHACHED_MODE_DEFAULT;
		@AuraEnabled public String sobjectName					= '';
		@AuraEnabled public Integer page						= 0;
		@AuraEnabled public Integer perPage						= 1;
		@AuraEnabled public String searchString					= '';

		public Set<String> searchColumns 						= new Set<String>();

		public Set<String> fieldsSet 							= new Set<String>();
		public Map<String, Set<Object>> andCondition 			= new Map<String, Set<Object>>();
		public Set<String> orderBy								= new Set<String>();

		private Map<String, Set<Object>> variableAndCondition 	= new Map<String, Set<Object>>();
		private Set<String> variableOrderBy						= new Set<String>();

		public SObjectStrategy(){}
		
		public SObjectStrategy(
			Set < String > fieldsSet,
			String sobjectName,
			Map<String, Set<Object>> andCondition,
			Set < String > orderBy,
			Integer page,
			Integer perPage
		){
			this(fieldsSet, sobjectName, andCondition, orderBy, page, perPage, CHACHED_MODE_DEFAULT);
		}

		public SObjectStrategy(
			Set < String > fieldsSet,
			String sobjectName,
			Map<String, Set<Object>> andCondition,
			Set < String > orderBy,
			Integer page,
			Integer perPage,
			Boolean cachedMode
		){
			this.fieldsSet = fieldsSet;
			this.sobjectName = sobjectName;
			this.andCondition = andCondition;
			this.orderBy = orderBy;
			this.page = page;
			this.perPage = perPage;
			this.cachedMode = cachedMode;
		}

		public integer offsetStart(){
			return this.page * this.perPage;
		}

		public void addFilters(Map<String, List<Object>> filters){
			this.addFilters(filters, false);
		}

		public void addFilters(Map<String, List<Object>> filters, Boolean variable){
			if(filters != null){
				for(String key : filters.keySet()){
					this.addFilter(key, new Set<Object>(filters.get(key)), variable);
				}
			}
		}

		public void addFilter(String field, Set<Object> values){
			this.addFilter(field, values, false);
		}

		public void addFilter(String field, Set<Object> values, Boolean variable){
			Set<Object> andCondition = null;

			if(variable){
				andCondition = this.variableAndCondition.get(field);
			}else{
				andCondition = this.andCondition.get(field);
			}

			if(andCondition == null) andCondition = new Set<Object>();

			for(Object value : values){
				andCondition.add(value);
			}

			if(variable){
				this.variableAndCondition.put(field, andCondition);
			}else{
				this.andCondition.put(field, andCondition);
			}
		}

		public void setOrderDesc(String field){
			this.setOrder(field, SObjectTable.ORDER_DESC, false);
		}

		public void setOrderDesc(String field, Boolean variable){
			this.setOrder(field, SObjectTable.ORDER_DESC, variable);
		}

		public void setOrderAsc(String field){
			this.setOrder(field, SObjectTable.ORDER_ASC, false);
		}

		public void setOrderAsc(String field, Boolean variable){
			this.setOrder(field, SObjectTable.ORDER_ASC, variable);
		}

		public void setOrder(String field, String order){
			this.setOrder(field, order, false);
		}

		public void setOrder(String field, String order, Boolean variable){
			if(String.isBlank(field) || String.isBlank(order)) return;

			if(variable){
				this.variableOrderBy = new Set<String>{SObjectTable.orderByIn(field, order)};
			}else{
				this.orderBy = new Set<String>{SObjectTable.orderByIn(field, order)};
			}
		}

		public Set<String> filter(){
			Set<String> andCondition = new Set<String>();

			for(String field : this.andCondition.keySet()){
				Set<Object> valuesIn = this.andCondition.get(field);
				andCondition.add(SObjectTable.whereIn(field, valuesIn));
			}

			for(String field : this.variableAndCondition.keySet()){
				Set<Object> valuesIn = this.variableAndCondition.get(field);
				andCondition.add(SObjectTable.whereIn(field, valuesIn));
			}

			return andCondition;
		}

		public Set<String> order(){
			if(this.variableOrderBy.size() > 0){
				return this.variableOrderBy;
			}

			return this.orderBy;
		}

		public Set<String> search(){
			Set<String> searchData = new Set<String>();

			if(!String.isBlank(this.searchString)){
				for(String column : this.searchColumns){
					searchData.add(column + ' LIKE \'%' + this.searchString +'%\'');
				}
			}

			return searchData;
		}

		public SObjectTable.QueryType getQueryType(){
			Integer perPage = this.perPage;
			Integer offsetStart = this.offsetStart();
			
			if(CHACHED_MODE_DEFAULT){
				perPage = LIMIT_MAX;
				offsetStart = null;
			}

			return new SObjectTable.QueryType(
				this.fieldsSet, 
				this.sobjectName, 
				this.filter(), 
				this.order(), 
				this.search(), 
				perPage,//this.perPage, 
				offsetStart//this.offsetStart()
			);
		}

	}

	public static void getFields(String sobjectName) {
		// sObject types to describe
		String[] types = new String[] {
			sobjectName
		};

		// Make the describe call
		Schema.DescribeSobjectResult[] results = Schema.describeSObjects(types);

		Map < String, Object > mapFields = results[0].fields.getMap();

		//System.debug(mapFields);

	}

	public static TablePagination paginationData(
		Set < String > fieldsSet,
		String sobjectName,
		Map<String, Set<Object>> andCondition,
		Set < String > orderBy,
		Integer page,
		Integer perPage
	){
		SObjectTable.SObjectStrategy strategy = new SObjectTable.SObjectStrategy(fieldsSet, sobjectName, andCondition, orderBy, page, perPage, CHACHED_MODE_DEFAULT);
		
		return SObjectTable.paginationData(strategy);
	}

	public static TablePagination paginationData(
		SObjectTable.SObjectStrategy strategy
	) {

		SObjectTable.QueryType queryType = strategy.getQueryType();
		
		String queryData = queryType.getQuery();
		String queryDataCount = SObjectTable.getTableQueryCount(strategy.sobjectName, strategy.filter(), strategy.search());

		System.debug('queryData: ' + queryData);
		System.debug('queryDataCount: ' + queryDataCount);

		List < sObject > elements = Database.query(queryData);
		//System.debug('result: ' + elements);

		AggregateResult elementsCount = Database.query(queryDataCount);

		Integer countData = Integer.valueOf(elementsCount.get('countData'));
		//System.debug('countData: ' + countData);

		TablePagination tableData = new TablePagination(elements, countData, strategy.page, strategy.perPage, 100, 2, false, strategy.cachedMode);
		//System.debug('tableData: ' + tableData);

		return tableData;
	}

	public static String getTableQueryCount(
		String sobjectName,
		Set < String > andCondition,
		Set < String > searchBy
	) {
		String field = 'COUNT(Id) countData';
		Set < String > fieldsSet = new Set < String > {
			field
		};

		return SObjectTable.getTableQuery(fieldsSet, sobjectName, andCondition, null, searchBy, null, null);
	}

	public static SObject getById(String sobjectName, List<String> fields, String recordId){
		return SObjectTable.getById(sobjectName, new Set<String>(fields), recordId);
	}

	public static SObject getById(String sobjectName, Set<String> fieldsSet, String recordId){
		Set<String> andCondition = new Set <String>{
		    SObjectTable.whereField('Id', recordId)
		};

		String query = SObjectTable.getTableQuery(fieldsSet, sobjectName, andCondition, null, null, 1, null);
		return Database.query(query);
	}

	public static String getTableQuery(Set < String > fieldsSet, String sobjectName) {
		return SObjectTable.getTableQuery(fieldsSet, sobjectName, null, null, null,  null, null);
	}

	public static String getTableQuery(
		Set < String > fieldsSet,
		String sobjectName,
		Set < String > andCondition,
		Set < String > orderBy,
		Set < String > searchBy,
		Integer limitRecords,
		Integer offsetRecords
	) {

		SObjectTable.QueryType queryType = new SObjectTable.QueryType(
			fieldsSet,
			sobjectName,
			andCondition,
			orderBy,
			searchBy,
			limitRecords,
			offsetRecords
		);

		return queryType.getQuery();
	}

	public static String whereField(String field, Object value ) {
		return String.format('{0} = \'\'{1}\'\'', new List < Object > {
			field,
			value
		});
	}

	public static String whereIn(String field, Set < Object > values) {
		if (values.size() == 0) return null;
		if (values.size() == 1) return SObjectTable.whereField(field, (new list<Object>(values))[0]);

		String inFields = String.join(new List < Object > (values), '\', \'');

		return String.format('{0} IN (\'\'{1}\'\')', new List < Object > {
			field,
			inFields
		});
	}

	public static String whereNotIn(String field, Set < Object > values) {
		if (values.size() == 0) return null;

		String inFields = String.join(new List < Object > (values), '\', \'');

		return String.format('{0} NOT IN (\'\'{1}\'\')', new List < Object > {
			field,
			inFields
		});
	}

	public static String orderByIn(String field, String order) {
		return String.format('{0} {1}', new List < Object > {
			field,
			order
		});
	}

	public static String applyTemplate(Integer setData, String template, String separator) {
		return SObjectTable.applyTemplate(new Set < String > {
			String.valueOf(setData)
		}, template, separator);
	}

	public static String applyTemplate(String setData, String template, String separator) {
		return SObjectTable.applyTemplate(new Set < String > {
			setData
		}, template, separator);
	}

	public static String applyTemplate(Set < String > setData, String template, String separator) {
		String joinedData = String.join(new List < String > (setData), separator);
		
		String dataString = joinedData.replaceAll('\'(true|false)\'', '$1');
		dataString = SObjectTable.formatEngine(dataString);

		return String.format(template, new List < String > {
			dataString
		});
	}

	public static String formatEngine(String value){
		//APPLY OPERATORS
		value = SObjectTable.operatorsEngine(value);
		String regex = '\'?!([\\w]+)\\(([\\w\\-\\:\\+\\.]+)\\)\'?';
		System.debug('formatEngine.value: ' + value);

		Pattern pattern = Pattern.compile(regex);
		Matcher matcher = pattern.matcher(value);

		List<String> commands = new List<String>();
		List<String> values = new List<String>();
		while (matcher.find()) {
		    if(matcher.groupCount() == 2){
    			String commandSelect = matcher.group();
		    	String operationName = matcher.group(1);
		    	String extractValue = matcher.group(2);
		    	String valueToAdd = null;

	    		System.debug('formatEngine.value-pre: ' + value);
		    	System.debug('formatEngine.operationName: ' + operationName);
		    	System.debug('formatEngine.extractValue: ' + extractValue);

				extractValue = SObjectTable.formatEngine(extractValue);

		    	if('NUMBER'.equalsIgnoreCase(operationName)){
		    		valueToAdd = extractValue;
		    	}else if('BOOLEAN'.equalsIgnoreCase(operationName)){
		    		valueToAdd = extractValue;
		    	}else if('DATE'.equalsIgnoreCase(operationName)){
		    		valueToAdd = extractValue;
		    	}else if('DATETIME'.equalsIgnoreCase(operationName)){
		    		valueToAdd = extractValue;
		    	}

	    		System.debug('valueToAdd: ' + valueToAdd);
	    		System.debug('commandSelect: ' + commandSelect);
		    	if(String.isNotBlank(valueToAdd)){
		    		values.add(valueToAdd);
		    		commands.add(commandSelect);
		    	}
		    }
		}

		System.debug('formatEngine.commands: ' + commands);
		System.debug('formatEngine.values: ' + values);

    	String valuePost = SObjectTable.proccessValues(commands, values, value);

		System.debug('value-post: ' + valuePost);

	    return valuePost;
	}

	public static String operatorsEngine(String value){
		String regex = '([\\w]+) = \'!([\\w]+)\\((.*?)\\)\'';
		System.debug('operatorsEngine.value: ' + value);

		Pattern pattern = Pattern.compile(regex);
		Matcher matcher = pattern.matcher(value);

		//System.debug('operatorsEngine.matcher: ' + matcher);
		//System.debug('operatorsEngine.matches: ' + matcher.matches());

		List<String> commands = new List<String>();
		List<String> values = new List<String>();
		while (matcher.find()) {
		    if(matcher.groupCount() == 3){
    			System.debug('operatorsEngine.group: ' + matcher.group());
    			String commandSelect = matcher.group();
		    	String developerName = matcher.group(1);
		    	String operationName = matcher.group(2);
		    	String extractValue = matcher.group(3);
		    	String valueToAdd;

				System.debug('operatorsEngine.developerName: ' + developerName);
				System.debug('operatorsEngine.value-pre: ' + value);
		    	System.debug('operatorsEngine.operationName: ' + operationName);
		    	System.debug('operatorsEngine.extractValue: ' + extractValue);

		    	if('GT'.equalsIgnoreCase(operationName)){
		    		valueToAdd = ' ' + developerName + ' > ' + extractValue;
		    	}else if('LT'.equalsIgnoreCase(operationName)){
		    		valueToAdd = ' ' + developerName + ' < ' + extractValue;
		    	}else if('GTE'.equalsIgnoreCase(operationName)){
		    		valueToAdd = ' ' + developerName + ' >= ' + extractValue;
		    	}else if('LTE'.equalsIgnoreCase(operationName)){
		    		valueToAdd = ' ' + developerName + ' <= ' + extractValue;
		    	}else if('ISNULL'.equalsIgnoreCase(operationName)){
		    		valueToAdd = ' ' + developerName + ' = Null';
		    	}else if('ISNOTNULL'.equalsIgnoreCase(operationName)){
		    		valueToAdd = ' ' + developerName + ' != Null';
		    	}else if('NOT'.equalsIgnoreCase(operationName)){
		    		valueToAdd = ' ' + developerName + ' != ' + extractValue;
		    	}else if('BETWEEN'.equalsIgnoreCase(operationName)){
		    		String[] valuesSplit = extractValue.split(',');
		    		System.debug('extractValue: ' + valuesSplit );

		    		valueToAdd = ' (' + developerName + ' > ' + valuesSplit[0] + ' AND ' + developerName + ' < ' + valuesSplit[1] + ') ';
		    	}else if('LIKE'.equalsIgnoreCase(operationName)){
		    		valueToAdd = ' ' + developerName + ' LIKE \'' + extractValue + '\' ';
				}else if('QUERY'.equalsIgnoreCase(operationName)){
		    		valueToAdd = ' (' + extractValue + ') ';
				}else if('QUERYIN'.equalsIgnoreCase(operationName)){
		    		valueToAdd = developerName + ' IN (' + extractValue + ') ';
		    	}

		    	System.debug('valueToAdd: ' + valueToAdd);
		    	System.debug('commandSelect: ' + commandSelect);
		    	if(String.isNotBlank(valueToAdd)){
		    		commands.add(commandSelect);
		    		values.add(valueToAdd);
		    	}
		    }
		}
		System.debug('operatorsEngine.commands: ' + commands);
		System.debug('operatorsEngine.values: ' + values);

    	String valuePost = SObjectTable.proccessValues(commands, values, value);

		System.debug('value-post: ' + valuePost);

	    return valuePost;
	}

	public static String proccessValues(List<String> commands, List<String> values, String value){
		String valueProccesed = value;
		Integer index = 0;
		for(String command : commands){
			valueProccesed = valueProccesed.replace(command, '{' + index + '}');
			index ++;
		}

		//valueProccesed = String.escapeSingleQuotes(valueProccesed);
		valueProccesed = valueProccesed.replaceAll('\'','\'\'');
		System.debug('operatorsEngine.value-proccesed: ' + valueProccesed);
		
		return String.format(valueProccesed, values);
	}
}