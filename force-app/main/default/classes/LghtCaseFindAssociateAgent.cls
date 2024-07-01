public with sharing class LghtCaseFindAssociateAgent extends RLY_Behaviour{

	public class LghtCaseFindAssociateException extends Exception {}

	public class AgentResult extends LghtResponse{
		@AuraEnabled public List<User> listUsers;
	}

	public class AgentAssociateResult extends LghtResponse{
		@AuraEnabled public Case caseData;
	}

	/**
	 * Search agent by Email, FirstName, LastName, CommunityNickname
	 * @param  fieldsSearch Map with fields to search
	 * @return              List User found
	 */		
	@AuraEnabled
   	public static AgentResult searchAgent (Map<String,String> fieldsSearch){
		DebugStart('LghtCaseFindAssociateAgent', 'AgentResult');
		Debug('fieldsSearch', fieldsSearch);

		AgentResult response = new AgentResult();

		try{

			Set<String> fields = new Set<String>{
				'Id', 
				'FirstName', 
				'LastName', 
				'isActive', 
				'CommunityNickname', 
				'Account.Name', 
				'Account.Active__c'
			};

			String objectName = 'User';

			Set<String> andCondition = new Set<String>();

			for(String key : fieldsSearch.keySet()){
				String value = fieldsSearch.get(key);

				if(String.IsNotBlank(value)){
					andCondition.add(SObjectTable.whereField(key, value));
				}
			}

			String query = SObjectTable.getTableQuery(fields, objectName, andCondition, null, null, null, null);
			Debug('query', query);

			List<User> listUsers = Database.query(query);
			Debug('listUsers', listUsers);

			response.listUsers = listUsers;
			response.isSuccess = true;
		}catch(LghtCaseFindAssociateException ex){
			response.errorMessage = ex.getMessage();
		}catch(Exception ex){
			response.errorMessage = ex.getMessage();
		}

		Debug('response', response);
		DebugEnd();
		return response;
   	}

   	@AuraEnabled
   	public static AgentAssociateResult associateAgent(String caseId, String agentId){
   		DebugStart('LghtCaseFindAssociateAgent', 'associateAgent');
		Debug('caseId', caseId);
		Debug('agentId', agentId);

		AgentAssociateResult response = new AgentAssociateResult();

		try{
			Case caseData = [
				SELECT Id, User__c, OwnerId, Status,Origin,SuppliedEmail
				FROM Case
				WHERE Id = :caseId
			];

			if(UserInfo.getUserId() != caseData.OwnerId) throw new LghtCaseFindAssociateException('Access Deny');

			User agent = [
				SELECT Id, ContactId, Agency_Code__c
				FROM User
				WHERE Id = :agentId
			];

			if(String.isNotBlank(agent.Agency_Code__c)){
				List<Account> accountList = [
					SELECT Id, Agency_Code__c 
					FROM Account 
					WHERE Recordtype.Name = 'Agency' 
					AND Agency_Code__c = :agent.Agency_Code__c
				];

				if(accountList.size() == 1){
					Account currentAccount = accountList.get(0);
					caseData.Agency_Code__c = currentAccount.Agency_Code__c;
					caseData.Agenzia__c = currentAccount.Id;
				}
			}

			caseData.User__c = agentId;
			caseData.ContactId = agent.ContactId;

			update caseData;

			response.caseData = caseData;
			response.isSuccess = true;
		}catch(LghtCaseFindAssociateException ex){
			response.errorMessage = ex.getMessage();
		}catch(Exception ex){
			response.errorMessage = ex.getMessage();
		}

		Debug('response', response);
		DebugEnd();
		return response;
   	}
}