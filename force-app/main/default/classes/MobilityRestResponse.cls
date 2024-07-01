global virtual class MobilityRestResponse extends RestResponseAbstract {

	public static final String WEB_SERVICE_TYPE = 'WebService_rest'; 

	public static final Map<String,String> status_map = new Map<String,String>{
		'Completed' 	=> 'OK',
		'Error' 		=> 'KO',
		'In Progress' 	=> 'KO',
		'New' 			=> 'KO'
	};

	public MobilityRestResponse(IRestRequest inRequest){
		super(inRequest);
	}

	public override void logCallIn(String status, String message){
		super.logCallIn(status, message);

		DebugStart('MobilityRestResponse', 'logCallIn');
		IE_Integration_Record__c integrationRecord = new IE_Integration_Record__c();

		IE_Configuration__c currentConfig 		= this.getIEConfiguration();

		integrationRecord.Status__c 			= MobilityRestResponse.status_map.get(status);
		integrationRecord.RequestBody__c 		= JSON.serialize(this.request);
		integrationRecord.ResponseBody__c 		= JSON.serialize(this);	
		integrationRecord.URLRequest__c 		= this.request.getBaseUrl();	
		integrationRecord.ErrorMessage__c 		= message;
		integrationRecord.IE_Configuration__c 	= currentConfig.Id;
		integrationRecord.ScopeID__c 			= this.request.getScope();

		if(currentConfig.log_records_flag__c) insert integrationRecord;

		Debug('integrationRecord', integrationRecord);
		DebugEnd();
	}

	private IE_Configuration__c getIEConfiguration(){
		DebugStart('MobilityRestResponse', 'getIEConfiguration');

		String nameService = this.request.getMethod();

		IE_Configuration__c currentConfig = new IE_Configuration__c();

		Debug('config find', nameService);

		List<IE_Configuration__c> listIeConfig = [
			SELECT Id, Name, Direction__c, EndPoint__c, HTTPMethod__c, Type__c, log_records_flag__c
			FROM IE_Configuration__c 
			WHERE Name = :nameService
		];

		if(listIeConfig.size() > 0){
			Debug('config found');
			currentConfig = listIeConfig.get(0);
		}else{
			Debug('config not found');

			String pathService 					= this.request.getBaseUrl();
			String typeService 					= this.request.getType();
			String methodType 					= this.request.getMethodType();
			
			currentConfig.Name 					= nameService;
			currentConfig.Direction__c 			= typeService;
			currentConfig.EndPoint__c 			= pathService;
			currentConfig.HTTPMethod__c 		= methodType;
			currentConfig.Type__c  				= MobilityRestResponse.WEB_SERVICE_TYPE;
			currentConfig.log_records_flag__c  	= false;

			insert currentConfig;
		}

		Debug('currentConfig', currentConfig);
		DebugEnd();
		return currentConfig;
	}
}