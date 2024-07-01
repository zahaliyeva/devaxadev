public interface IRestRequest {
	
	String getMethod();
	String getBaseUrl();
	String getMethodType();
	String getType();
	String getScope();
	String getTransanctionId();
	RestWebService.TransactionData getTransanctionData();
}