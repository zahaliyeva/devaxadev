@RestResource(urlMapping='/upsert-accounts/*')
global with sharing class MobilityRestUpsertAccount extends RLY_Behaviour{

	public class MobilityUpsertAccountException extends Exception {}
	public class MobilityUpsertAccountEmptyException extends Exception {}

	global class RequestUpsertAccount extends RestRequestAbstract{
		global Account account;

    	public override String getMethod(){
    		return 'Mobility_Upsert_Account';
    	}

    	public override String getBaseUrl(){
    		return '/upsert-accounts/*';
    	}
	}

	global class ResponseUpsertAccount extends MobilityRestResponse{
		//global String recordId;

		public ResponseUpsertAccount(IRestRequest inRequest){
			super(inRequest);
		}
	}
	
	@HttpPost
	global static List<ResponseUpsertAccount> upsertAccount(RequestUpsertAccount request){
		DebugStart('MobilityRestUpsertAccount', 'upsertAccount');
		Debug('request', request);

		ResponseUpsertAccount response = new ResponseUpsertAccount(request);

		try{
			if(request.account == null) throw new MobilityUpsertAccountEmptyException('Field account empty');

			Account accountUpsert = request.account;
			Database.UpsertResult result = Database.upsert(accountUpsert, Account.Fields.NDG__c, false);

			if(!result.isSuccess()){
				Database.Error[] upsertErrors = result.getErrors();
				Database.Error firstError = upsertErrors[0];

				throw new MobilityUpsertAccountException('Error on Field: ' + firstError.getFields() + ': ' + firstError.getMessage());
			}

			//response.recordId = accountUpsert.Id;
			response.success(accountUpsert.Id);
		}catch(MobilityUpsertAccountEmptyException ex){
			Debug('MobilityUpsertAccountEmptyException', ex);
			response.failed(403, ex.getMessage(), ex.getStackTraceString());
		}catch(MobilityUpsertAccountException ex){
			Debug('MobilityUpsertAccountException', ex);
			response.failed(403, ex.getMessage(), ex.getStackTraceString());
		}
		
		Debug('response', response);
		DebugEnd();
		return new List<ResponseUpsertAccount>{response};
	}

}