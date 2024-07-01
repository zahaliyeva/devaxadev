/*------------------------------------------------------------------------
   Author:        Davide Fabris
   Company:       Deloitte
   Rewritten by:  Reply
   Class:         BulkRequestManager
   Description:   Batch that one at a time runs Bulk_Request__c
   History

   17/03/2017     Created - D.F.

   ----------------------------------------------------------------------------*/

global class BulkRequestManager implements Database.Batchable<sObject>,Schedulable, Database.Stateful {

	private static final string CLASS_NAME = 'BulkRequestManager';
	public static final Apex_Schedulation_Manager__c SCHEDULATIONSETTING = Apex_Schedulation_Manager__c.getInstance(CLASS_NAME);
	private static final string ATTACHMENT_NAME = 'attachment.txt';
	public Bulk_Request__c currentRequest {get; set;}
	public Integer recordCount {get; set;}
	public List<String> databaseErrors {get; set;}
	public static final String QUERY_BULK_REQUESTS = 'SELECT id,BulkRequestHandler__c,JsonInstance__c, Submission_date__c,Query__c,Status__c,Request_by__c, Number_of_Retry__c FROM Bulk_Request__c WHERE Status__c in (\'SUBMITTED\',\'ERROR\') Order By Submission_date__c ASC';
	global String logToSend='';


	global Database.QueryLocator start(Database.BatchableContext context) {
		try {
			 recordCount = 0;
			 databaseErrors = new List<String>();
			 currentRequest = Database.query(QUERY_BULK_REQUESTS + ' LIMIT 1');
			 system.debug('BulkRequestManager.start Current Request: ' + currentRequest);
			 system.debug('BulkRequestManager.start Query: ' + currentRequest.Query__c);
			 currentRequest.Status__c='IN PROGRESS';
			 currentRequest.Record_processed__c = 0;
			 update currentRequest;
			 System.debug('BulkRequestManager.start end');
			 return Database.getQueryLocator(currentRequest.Query__c);
		 } catch (exception e) {
			 System.debug('BulkRequestManager.start Exception:' + e.getStackTraceString());
			 System.debug('BulkRequestManager.start No Requests to process');
			 System.debug('BulkRequestManager.start end');
			 //No Bulk Requests found, but the finish method must to be executed anyway in order to reschedule this batch automatically.
			 return Database.getQueryLocator(QUERY_BULK_REQUESTS + ' LIMIT 0');
		 }
	}

	global void execute(Database.BatchableContext context, List<SObject> scope) {
		try{
			 System.debug('BulkRequestManager.execute start');
			 if(scope.isEmpty()) {
				  System.debug('BulkRequestManager.execute No Requests to process');
				  return;
			  }
			 recordCount = recordCount + scope.size();
			 databaseErrors.addAll(BulkRequestHelper.ProcessScope(currentRequest,scope));
			 System.debug('BulkRequestManager.execute end');
		 } catch(Exception e) {
			 currentRequest.Status__c='ERROR';
			 currentRequest.Error_Message__c = trimTo(e.getMessage(), 255);
			 currentRequest.Error_Detail__c = trimTo(e.getStackTraceString(),131072);
		 }
	}

	global void finish(Database.BatchableContext context){ 
		try{
			 System.debug('BulkRequestManager.start databaseErrors size ' + databaseErrors.size());
			 System.debug('BulkRequestManager.start recordCount ' + recordCount);
			 if (currentRequest!=null) {
				AsyncApexJob apexJob = [Select Id, NumberOfErrors, ExtendedStatus from AsyncApexJob where Id = :context.getJobId()];
				  if(currentRequest.Status__c == 'ERROR' || !databaseErrors.isEmpty() || apexJob.NumberOfErrors > 0) {
                      if(currentRequest.BulkRequestHandler__c=='BulkRequest_TrackLeadHistory'){
                         	currentRequest.Number_of_Retry__c = 0;
							currentRequest.Status__c='MANUAL ERROR';
                      }
					   else if(SCHEDULATIONSETTING.Maximum_number_of_retry__c != null && currentRequest.Number_of_Retry__c < SCHEDULATIONSETTING.Maximum_number_of_retry__c) {
							currentRequest.Number_of_Retry__c = currentRequest.Number_of_Retry__c == null ? 1 : currentRequest.Number_of_Retry__c + 1;
							currentRequest.Status__c='ERROR';
							if(!databaseErrors.isEmpty()){ 
								currentRequest.Error_Message__c = trimTo(databaseErrors.get(0),255);
							} else if(apexJob.NumberOfErrors > 0){
								currentRequest.Error_Message__c = trimTo(apexJob.ExtendedStatus, 255);
							}
							currentRequest.Error_Message__c = !databaseErrors.isEmpty() ? trimTo(databaseErrors.get(0),255) : currentRequest.Error_Message__c;
							for(String error: databaseErrors) { 
								 currentRequest.Error_Detail__c = currentRequest.Error_Detail__c + ' ' + trimTo(error,255);
							 }
							currentRequest.Number_of_Database_Errors__c = !databaseErrors.isEmpty() ? databaseErrors.size() : 0;
						} else {
							currentRequest.Number_of_Retry__c = 0;
							currentRequest.Status__c='MANUAL ERROR';
						}
				   }  else {
					   currentRequest.Number_of_Retry__c = 0;
					   currentRequest.Number_of_Database_Errors__c = 0; 
					   currentRequest.Status__c='PROCESSED';
					   currentRequest.Error_Message__c = null;
					   currentRequest.Error_Detail__c = null;
				   }
				  currentRequest.Completition_date__c=Datetime.Now();
				  currentRequest.Record_processed__c = recordCount;
				  update currentRequest;
			  }
			 this.autorun(context);
		 } catch(Exception e) {
			 currentRequest.Status__c='ERROR';
			 currentRequest.Error_Message__c = trimTo(e.getMessage(), 255);
			 currentRequest.Error_Detail__c = trimTo(e.getStackTraceString(),131072);
			 currentRequest.Number_of_Retry__c = currentRequest.Number_of_Retry__c + 1;
			 update currentRequest;
			 this.autorun(context);
		 }
	}

	public void autorun(Database.BatchableContext context){ 
		List<Bulk_Request__c> requests = [SELECT id,BulkRequestHandler__c,JsonInstance__c, Submission_date__c,Query__c,Status__c,Request_by__c FROM Bulk_Request__c WHERE (Status__c='SUBMITTED' or Status__c='ERROR') AND BypassAutoRun__c = false LIMIT 1];
		if(requests.isEmpty()) {
			 this.autoschedule(context);
		 } else {
			 BulkRequestManager b = new BulkRequestManager();
			 Database.ExecuteBatch(b,Integer.valueOf(SCHEDULATIONSETTING.Scope__c));
		 }
	}

	public void autoschedule(Database.BatchableContext context){

		//Plan New Execution if needed
		if (SCHEDULATIONSETTING.Autoschedule__c)
		 {
			 String sch = '';
			 if (SCHEDULATIONSETTING.Expression__c != null)
			  {
				  sch = SCHEDULATIONSETTING.Expression__c;
			  }
			 else
			  {
				  sch = ApexSchedulationManager.getScheduleString(SCHEDULATIONSETTING.Frequency__c+'');
			  }

			 //Lunch this batch only between 7-21
			 Datetime CurrentTime = Datetime.now();
			 String fromTime = SCHEDULATIONSETTING.From__c != null ? SCHEDULATIONSETTING.From__c : null;
			 String toTime = SCHEDULATIONSETTING.To__c != null ? SCHEDULATIONSETTING.To__c : null;
			 if ( fromTime == null || toTime == null || (CurrentTime.hour()>=Integer.valueOf(fromTime) && CurrentTime.hour()<=Integer.valueOf(toTime)) ) {
				  //schedule as explained by the Custom Setting
				  system.Schedule(SCHEDULATIONSETTING.name+String.ValueOf(System.currentTimeMillis()),sch,new BulkRequestManager());
			  } else {
				  //Schedule for FromTime in the morning after. the string format is 'ss min hh dd mm DOW yy'
				  sch ='00 00 ' + fromTime;
				  System.debug('BulkRequestManager.autoschedule() CurrentTime.hour(): ' + CurrentTime.hour());
				  System.debug('BulkRequestManager.autoschedule() toTime: ' + toTime);
				  if (CurrentTime.hour()>Integer.valueOf(toTime)) {//must go for tomorrow
					   sch = sch+' '+CurrentTime.addDays(1).day();
					   sch = sch+ ' ' +CurrentTime.addDays(1).month();
					   sch = sch+' ? ';//any day of the week
					   sch = sch+' '+CurrentTime.addDays(1).Year();
				   } else {//is early in the morning, just scheduling for today at FromTime
					   sch = sch+' '+CurrentTime.day();
					   sch = sch+ ' ' +CurrentTime.month();
					   sch = sch+' ? ';//any day of the week
					   sch = sch+' '+CurrentTime.Year();
				   }
				  system.Schedule(SCHEDULATIONSETTING.name+String.ValueOf(System.currentTimeMillis()),sch,new BulkRequestManager());
			  }
		 }

		//Send log if needed
		if (SCHEDULATIONSETTING.Send_Log__c == true)
		 {
			 User u = [Select id, Email From User where id = :UserInfo.getUserId() limit 1];
			 String emailObj = 'ORG=['+UserInfo.getOrganizationId()+'] JOB=['+context.getJobId()+']'+' '+SCHEDULATIONSETTING.name;
			 ApexSchedulationManager.sendMailPlus(u, ATTACHMENT_NAME, ' '+logToSend, emailObj, '');
		 }
	}

	global void execute(SchedulableContext SC) {
		System.abortJob(SC.getTriggerId());
		BulkRequestManager b = new BulkRequestManager();
		Database.ExecuteBatch(b,Integer.valueOf(SCHEDULATIONSETTING.Scope__c));
	}

	private String trimTo(String stringToTrim, Integer maxSize){
		if(stringToTrim != null && stringToTrim.length() > maxSize ) {
			 stringToTrim = stringToTrim.substring(0, maxSize);
		 }
		return stringToTrim;
	}

	public static List<String> getErrors(List<Database.SaveResult> saveResults, List<SObject> objects, List<String> errors){
        if(saveResults == null || saveResults.isEmpty()){
            return errors;
        }
        for (Integer i = 0; i < objects.size(); i++) {
            Database.SaveResult accountSaveResult = saveResults[i];
            SObject origRecord = objects[i];  
            if (!accountSaveResult.isSuccess()) {
                 for(Database.Error error : accountSaveResult.getErrors()) {
                      errors.add(' Id: ' + origRecord.Id + ' Error Message ' + error.getMessage() + ' Error Fields: ' + error.getFields());
                  }
             }
        }
        return errors;
    }

    public static List<String> getErrors(List<Database.DeleteResult> deleteResults, List<SObject> objects, List<String> errors){
        if(deleteResults == null || deleteResults.isEmpty()){
            return errors;
        }
        for (Integer i = 0; i < objects.size(); i++) {
            Database.DeleteResult deleteResult = deleteResults[i];
            SObject origRecord = objects[i];  
            if (!deleteResult.isSuccess()) {
                 for(Database.Error error : deleteResult.getErrors()) {
                      errors.add(' Id: ' + origRecord.Id + ' Error Message ' + error.getMessage() + ' Error Fields: ' + error.getFields());
                  }
             }
        }
        return errors;
    }

}