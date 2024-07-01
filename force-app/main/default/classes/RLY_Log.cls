public without sharing class RLY_Log extends RLY_Behaviour{
	
	public class LogInput{
		public String method;
		public Object request;
		public Object response;
		public String message;
		public String transactionId;
		public String type;
		public String status;
		public String debug;
	}
	/* 
	* List to collect all the Logs to insert
	* All the methods below create an Integration Log record and add it to the list
	*/
	private static List<RLY_Log__c> logToInsert =  new List<RLY_Log__c>();

	/*
	* This method must be called at the of the process to insert all the Integration Log records
	*/
	public static void insertLogs(){
		DebugStart('RLY_Log', 'insertLogs');

		try{
			if(RLY_Log.isActive()){
				if(logToInsert != null && !logToInsert.isEmpty()) insert logToInsert;
			}
		}catch(Exception ex){
			Debug('exception', ex.getMessage());
			Debug('getStackTraceString', ex.getStackTraceString());
		}

		DebugEnd();
	}

	/*
	* This method can be called to create a "Debug" type Integration Log
	* @param function --> String, it is the name of the function to debug
	* @param debug --> String, it is a debug text
	* @param transaction --> String, it is the Id of an Object
	*/
	public static void createDebugLog(LogInput logInput){
		DebugStart('RLY_Log', 'createDebugLog');
		Debug('logInput', logInput);

		try{
			RLY_Log__c newLog = new RLY_Log__c(
				Method__c	 	= logInput.method,
				Transaction__c 	= logInput.transactionId,
				Type__c 		= 'Debug',
				Status__c 		= logInput.status,
				Message__c 		= logInput.message
			);

			logToInsert.add(newLog);
		}catch(Exception ex){
			Debug('exception', ex.getMessage());
			Debug('getStackTraceString', ex.getStackTraceString());
		}

		DebugEnd();
	}

	/*
	* This method can be called to create a "Callout" type Integration Log
	* @param function --> String, it is the name of the function to debug
	* @param request --> String, it is the request, may be a JSON
	* @param response --> String, it is the response, may be a JSON
	* @param transaction --> String, it is the Id of an Object
	*/
	public static void callOut(LogInput logInput){
		DebugStart('RLY_Log', 'callOut');
		Debug('logInput', logInput);

		try{
			RLY_Log__c newLog = new RLY_Log__c(
				Method__c	 	= logInput.method,
				Transaction__c 	= logInput.transactionId,
				Type__c 		= 'CallOut',
				Status__c 		= logInput.status,
				Message__c 		= logInput.message,
				Request__c 		= JSON.serialize(logInput.request),
				Response__c 	= JSON.serialize(logInput.response),
				Debug__c		= RLY_Behaviour.getLog()
			);

			logToInsert.add(newLog);

		}catch(Exception ex){
			Debug('exception', ex.getMessage());
			Debug('getStackTraceString', ex.getStackTraceString());
		}

		DebugEnd();
	}

	public static void callOutSave(LogInput logInput){
		RLY_Log.callOut(logInput);
		RLY_Log.insertLogs();
	}

	/*
	* This method can be called to create a "Callout" type Integration Log
	* @param function --> String, it is the name of the function to debug
	* @param request --> String, it is the request, may be a JSON
	* @param response --> String, it is the response, may be a JSON
	* @param transaction --> String, it is the Id of an Object
	*/

	public static void callIn(LogInput logInput){
		DebugStart('RLY_Log', 'callIn');
		Debug('logInput', logInput);

		try{
			RLY_Log__c newLog = new RLY_Log__c(
				Method__c	 	= logInput.method,
				Transaction__c 	= logInput.transactionId,
				Type__c 		= 'CallIn',
				Status__c 		= logInput.status,
				Message__c 		= logInput.message,
				Request__c 		= JSON.serialize(logInput.request),
				Response__c 	= JSON.serialize(logInput.response),
				Debug__c		= RLY_Behaviour.getLog()
			);


			logToInsert.add(newLog);

		}catch(Exception ex){
			Debug('exception', ex.getMessage());
			Debug('getStackTraceString', ex.getStackTraceString());
		}

		DebugEnd();
	}

	public static void callInSave(LogInput logInput){
		RLY_Log.callIn(logInput);
		RLY_Log.insertLogs();
	}

	/*
	* This method can be called to create an "Error" type Integration Log
	* @param function --> String, it is the name of the function to debug
	* @param error --> String, it is an error text
	* @param transaction --> String, it is the Id of an Object
	*/
	public static void createErrorLog(LogInput logInput){
		DebugStart('RLY_Log', 'insertLogs');
		Debug('logInput', logInput);

		try{
			RLY_Log__c newLog = new RLY_Log__c(
				Method__c	 	= logInput.method,
				Transaction__c 	= logInput.transactionId,
				Type__c 		= 'Error',
				Status__c 		= 'Failed',
				Message__c 		= logInput.message
			);


			logToInsert.add(newLog);

		}catch(Exception ex){
			Debug('exception', ex.getMessage());
			Debug('getStackTraceString', ex.getStackTraceString());
		}

		DebugEnd();
	}

	/*
	* This method can be called to create a Generic Integration Log
	* @param function --> String, it is the name of the function to debug
	* @param request --> String, it is the request, may be a JSON
	* @param response --> String, it is the response, may be a JSON
	* @param message --> String, it is a debug text
	* @param transaction --> String, it is the Id of an Object
	* @param message --> String, it define the type of the log
	* @param message --> String, it define the log status
	*/
	public static void createLog(LogInput logInput){

		DebugStart('RLY_Log', 'createLog');

		try{
			RLY_Log__c newLog = new RLY_Log__c(
				Method__c	 	= logInput.method,
				Request__c 		= JSON.serialize(logInput.request),
				Response__c 	= JSON.serialize(logInput.response),
				Message__c 		= logInput.message,
				Transaction__c 	= logInput.transactionId,
				Type__c 		= logInput.type,
				Status__c 		= logInput.status
			);


			logToInsert.add(newLog);

		}catch(Exception ex){
			Debug('exception', ex.getMessage());
			Debug('getStackTraceString', ex.getStackTraceString());
		}

		DebugEnd();
	}

}