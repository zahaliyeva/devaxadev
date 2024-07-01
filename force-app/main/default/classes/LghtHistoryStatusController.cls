public with sharing class LghtHistoryStatusController extends RLY_Behaviour {

	public class LghtHistoryStatusException extends Exception {}

	public class WorkGroupData extends LghtResponse{
		@AuraEnabled public Map<String,String> workGroups;
	}
    
    @AuraEnabled
    public static WorkGroupData getWorkGroups(String recordId){
        DebugStart('LghtHistoryStatusController', 'getWorkGroups');
        Debug('recordId', recordId);

        WorkGroupData response = new WorkGroupData();

        try{
            List<AggregateResult> listGroups = [
                SELECT CaseOwner__r.Id GroupId, CaseOwner__r.Name GroupName
                FROM History_Case_Status__c 
                WHERE Case__c = :recordId
                GROUP BY CaseOwner__r.Id, CaseOwner__r.Name
            ];
            Debug('ListGroups', listGroups);

            response.workGroups = new Map<String, String>();
            for(AggregateResult historyData : listGroups){
                response.workGroups.put((String)historyData.get('GroupId'), (String)historyData.get('GroupName'));
            }
            Debug('workGroups', response.workGroups);

            response.isSuccess = true;
        }catch(LghtHistoryStatusException ex){
            response.errorMessage = ex.getMessage();
        }catch(Exception ex){
            response.errorMessage = ex.getMessage();
        }

        Debug('response', response);
        DebugEnd();
        return response;

       
    }
}