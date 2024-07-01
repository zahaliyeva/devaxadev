@RestResource(urlMapping='/upsert-contacts/*')
global with sharing class MobilityRestUpsertContact extends RLY_Behaviour{

	public class MobilityUpsertContactException extends Exception {}
	public class MobilityUpsertContactEmptyException extends Exception {}

	global class RequestUpsertContact extends RestRequestAbstract{
		global Contact contact;

    	public override String getMethod(){
    		return 'Mobility_Upsert_Contact';
    	}

    	public override String getBaseUrl(){
    		return '/upsert-contacts/*';
    	}
	}

	global class ResponseUpsertContact extends MobilityRestResponse{
		//global String recordId;

		public ResponseUpsertContact(IRestRequest inRequest){
			super(inRequest);
		}
	}
	
	@HttpPost
	global static List<ResponseUpsertContact> upsertConctact(RequestUpsertContact request){
		DebugStart('MobilityRestUpsertContact', 'upsertConctact');
		Debug('request', request);

		ResponseUpsertContact response = new ResponseUpsertContact(request);

		try{
			if(request.contact == null) throw new MobilityUpsertContactEmptyException('Field contact empty');

			Contact contactUpsert = request.contact;
			Database.UpsertResult result = Database.upsert(contactUpsert, Contact.Fields.TECH_NDG__c, false);

			if(!result.isSuccess()){
				Database.Error[] upsertErrors = result.getErrors();
				Database.Error firstError = upsertErrors[0];

				throw new MobilityUpsertContactException('Error on Field: ' + firstError.getFields() + ': ' + firstError.getMessage());
			}

			//response.recordId = contactUpsert.Id;
			response.success(contactUpsert.Id);
		}catch(MobilityUpsertContactEmptyException ex){
			Debug('MobilityUpsertContactEmptyException', ex);
			response.failed(403, ex.getMessage(), ex.getStackTraceString());
		}catch(MobilityUpsertContactException ex){
			Debug('MobilityUpsertContactException', ex);
			response.failed(403, ex.getMessage(), ex.getStackTraceString());
		}
		
		Debug('response', response);
		DebugEnd();
		return new List<ResponseUpsertContact>{response};
	}

}