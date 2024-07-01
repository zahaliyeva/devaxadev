public with sharing class MobilityTestingController extends MobilityAbstract{
	
	public class MobilityTestingException extends Exception {}
	public class MobilityTestingResponse extends MobilityResponse{}

	@AuraEnabled(cacheable=true)
	public static MobilityTestingResponse getTest(String testName){
		DebugStart('MobilityTestingController', 'getTest');

		MobilityTestingResponse response = new MobilityTestingResponse();

		try {

			response.isSuccess = true;
		} catch (MobilityTestingException ex) {
			response.errorMessage = ex.getMessage();
		}

		Debug('response', response);
		DebugEnd();
		return response;
	}

}