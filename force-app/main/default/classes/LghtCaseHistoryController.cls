public with sharing class LghtCaseHistoryController extends RLY_Behaviour {

	public class LghtCaseHistoryControllerException extends Exception {}

	public class WorkGroupData extends LghtResponse{
		@AuraEnabled public Map<String,String> workGroups;
	}
    
    @AuraEnabled 
    public static WorkGroupData getWorkGroups(String recordId){
        DebugStart('LghtCaseHistoryController', 'getWorkGroups');
        Debug('recordId', recordId);

        WorkGroupData response = new WorkGroupData();

        try{
            List<AggregateResult> listGroups = [
                SELECT Gruppo_di_lavoro__c GroupName
                FROM Milestone_Tracking__c 
                WHERE Case__c = :recordId
                GROUP BY Gruppo_di_lavoro__c
            ];
            Debug('ListGroups', listGroups);

            response.workGroups = new Map<String, String>();
            for(AggregateResult historyData : listGroups){
                response.workGroups.put((String)historyData.get('GroupName'), (String)historyData.get('GroupName'));
            }
            Debug('workGroups', response.workGroups);

            response.isSuccess = true;
        }catch(LghtCaseHistoryControllerException ex){
            response.errorMessage = ex.getMessage();
        }catch(Exception ex){
            response.errorMessage = ex.getMessage();
        }

        Debug('response', response);
        DebugEnd();
        return response;

       
    } 
}