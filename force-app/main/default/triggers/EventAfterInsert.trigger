/**
* Trigger of the Event object
* Modification log
* ---------------------------------------------------------------------------------------------------------------------
* Id: 001
* author: Juana Valenzuela
* date: 29/05/2017
* description: Lead Management - Sprint 44: Update Lead status after event creation 
*/
trigger EventAfterInsert on Event (after insert) {
System.Debug('## >>> Start of EventAfterInsert <<< run by ' + UserInfo.getName());
  
  //CAPOBIANCO_A 10/07/2017 Commented because the logic is now on the NewEventLeadCtrl apex class

  /*
  //VALENZUELA_J 001 - Start
  List<SObject> inputEvents = Trigger.new;
  ActivitiesManagement.updateLeadStatus(inputEvents);
  //VALENZUELA_J 001 - End
  */
}