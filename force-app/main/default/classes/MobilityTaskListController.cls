public with sharing class MobilityTaskListController extends MobilityAbstract{
    @AuraEnabled(cacheable=true) 
    public static List<Task> getTask(){
        return MobilityTaskListController.getTask(100);
    }

    @AuraEnabled(cacheable=true)
	public static List<Task> getTask(Integer limitRows){
        Date dateStart = Date.today();

		return [
			SELECT  Subject, ActivityDate, Who.Name, IsHighPriority
            FROM Task
            WHERE IsClosed = false
            AND ActivityDate >= :dateStart
            ORDER BY ActivityDate ASC, IsHighPriority DESC
            LIMIT :limitRows
		];
    }
}