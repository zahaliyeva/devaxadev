global virtual class RestResponseAbstract extends RLY_Behaviour{

    public static final String CODE_SUCCESS					= '0';
    public static final String CODE_ERROR					= '1';

    public static final String STATUS_SUCCESS				= 'Completed';
    public static final String STATUS_ERROR					= 'Failed';

    public static final Map<String,String> STATUS_MAP		= new Map<String,String>{
    	CODE_SUCCESS 	=> 		STATUS_SUCCESS,
    	CODE_ERROR 		=> 		STATUS_ERROR
	};
    
    public static final String MSG_SUCCESS_DEFAULT			= 'Success';
    public static final String MSG_ERROR_DEFAULT			= 'Error';
	
	global RestWebService.TransactionData transactionData  	= new RestWebService.TransactionData();
	global ResultData result 								= new ResultData();
	global String message 									= '';
	global String errorCode									= '';
	global Boolean success									= false;

	public transient IRestRequest request;

	global class ResultData{
		global String resultCode 							= '';
		global String resultMessage 						= '';
		global String recordId 								= '';
		global transient String resultDetail 				= '';
	}

	public RestResponseAbstract(IRestRequest inRequest){
		this.request = inRequest;
	}

	/**
	 * Success methods
	 */

	public void success(){
		this.success(RestResponseAbstract.MSG_SUCCESS_DEFAULT, '');
	}
	
	public void success(String recordId){
		this.result.recordId = recordId;
		this.success();
	}

	public void success(String message, String detail){
		this.success = true;
		this.setMessage(RestResponseAbstract.CODE_SUCCESS, message, detail);
	}

	/**
	 * Failed methods
	 */
	public void failed(){
		this.failed(500, RestResponseAbstract.MSG_ERROR_DEFAULT, '');
	}
	
	public void failed(String message, String detail){
		this.failed(500, message, detail);
	}

	public void failed(Integer errorCode, String message, String detail){
		this.success = false;
		
		RestResponse responseContext = RestContext.response;
		responseContext.statusCode = errorCode;

		this.setMessage(RestResponseAbstract.CODE_ERROR, message, detail);
	}

	/**
	 * Set Data
	 */
	private void setMessage(String code, String message, String detail){
		this.result.resultCode = code;
		this.result.resultMessage = message;
		this.result.resultDetail = detail;

		this.message = message;
		this.errorCode = code;

		//TODO: Capire se deve essere popolato con i dati nostri
		this.transactionData = this.request.getTransanctionData();

		this.logCallIn(RestResponseAbstract.STATUS_MAP.get(code), message);
	}

	/**
	 * Log callin
	 */
	public virtual void logCallIn(String status, String message){
		RLY_Log.LogInput logInput = new RLY_Log.LogInput();

		logInput.method 		= this.request.getMethod();
		logInput.request 		= this.request;
		logInput.response 		= this;
		logInput.transactionId 	= this.request.getTransanctionId();
		logInput.status 		= status;
		logInput.message 		= message;

		RLY_Log.callInSave(logInput);
	}
}