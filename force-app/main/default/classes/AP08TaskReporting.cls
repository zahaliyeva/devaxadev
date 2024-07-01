public without sharing class AP08TaskReporting {
/* 
----------------------------------------------------------------------
-- - Name          : AP08TaskReporting
-- - Author        : Spoon Consulting
-- - Description   : Task Reporting fields 
--
-- Maintenance History: 
--
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  ---------------------------------------
-- 24-MAR-2015	HDU	   1.0     Initial version (Set task and case 
--								created date diff :setDaysBetweenTaskAndCaseCreation)
----------------------------------------------------------------------
***********************************************************************/
	//Get the default business hours
    public static BusinessHours defaultHours = [select Id from BusinessHours where IsDefault=true];

	public static void setDaysBetweenTaskAndCaseCreation(list<Task> listTask,set<Id>setCaseId){
		Long durationInMillisec;
		map<id,Case> mapIdToCase = new map<id,Case>();
		list<Task> listNewTask = new list <Task>();
		
		for(Case c :   [SELECT 	Id,createdDate 
						FROM 	Case
						WHERE 	Id IN :setCaseId] ){
			mapIdToCase.put(c.Id , c);
		} //end of loop case
		system.debug('>>> mapIdToCase: '+mapIdToCase);
		for( Task t:listTask ){
			Datetime caseCreateDate =  mapIdToCase.get( t.whatId ).createdDate;
			if( Test.isRunningTest() ){
				String caseJSON = '{"attributes":{"type":"CasSe","url":"/services/data/v25.0/sobjects/Case/'+mapIdToCase.get( t.whatId ).id+'"},"Id":"'+mapIdToCase.get( t.whatId ).id+'","Status":"Open","CreatedDate":"2012-10-04T00:00:00.000+0000"}'; 
				Case c = (Case) JSON.deserialize(caseJSON, Case.class ); 
				caseCreateDate = c.CreatedDate;
				system.debug('###Test AP08TaskReporting caseCreateDate :'+caseCreateDate);
			}
			durationInMillisec = BusinessHours.diff(defaultHours.id , caseCreateDate ,  t.CreatedDate);
			listNewTask.add( new task (id = t.id , Hours_to_open_an_activity__c = durationInMillisec/(60*60*1000))); 
		}//end of loop task
		
		update listNewTask;
	}//end of method
	
	public static void trackTaskPendingStatus(list<Task> listTask){
		Long durationOfPendingStatusInMillisec;
		for(Task t:listTask ){
			if(t.Pending_Status_Checked_In__c != null){
				durationOfPendingStatusInMillisec = BusinessHours.diff(defaultHours.id , t.Pending_Status_Checked_In__c ,  system.now());
				if(t.Pending_status_duration__c != null)
					t.Pending_status_duration__c += durationOfPendingStatusInMillisec/(60*60*1000) ;
				else
					t.Pending_status_duration__c = durationOfPendingStatusInMillisec/(60*60*1000) ;
			}//end of check null 
		}//end loop task
		
	}//end of method
	
	
	public static void trackTaskWithoutPendingStatus(list<Task> listTask,set<Id>setCaseId){
		Id bh;
		Long durationInMillisec;
		Decimal durationInHour;
		map<id,Case> mapIdToCase = new map<id,Case>();
		list<Task> listNewTask = new list <Task>();
		
		for(Case c :   [SELECT 	Id,createdDate, BusinessHoursId
						FROM 	Case
						WHERE 	Id IN :setCaseId] ){
			mapIdToCase.put(c.Id , c);
		} //end of loop case
		system.debug('>>> mapIdToCase: '+mapIdToCase);
		
		for( Task t:listTask ){
			Case ca = mapIdToCase.get( t.whatId );
		 	if(ca.BusinessHoursId!=null){
                bh = ca.BusinessHoursId;
            }
            else{
                bh = defaultHours.Id;
            }
            if( t.CreatedDate != null ){
	            durationInMillisec = BusinessHours.diff(bh , t.CreatedDate ,  system.now());
	            
	            if(t.Pending_status_duration__c != null)
	           		durationInHour = (durationInMillisec/(60*60*1000))- t.Pending_status_duration__c;
	           	else
	           		durationInHour = durationInMillisec/(60*60*1000);
            }else{
            	durationInHour = 0;
            }
           	 system.debug('### t.durationInHour :'+durationInHour);	
           	//t.Day_activities_without_pending__c = durationInHour/10;//divide by 10 for days
           	t.ActivitiesWithoutPendingHours__c = durationInHour;///10;//divide by 10 for days
		}//end loop
	}//end method
}//end of class