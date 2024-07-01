/*------------------------------------------------------------------------
Author:        Davide Fabris
Company:       Deloitte
Class:         ProcedureStepHandler
Description:   Interface Class for the procedure methods used by the BatchProcedure
History
 -28/07/2016   Davide Fabris - Created
 -19/08/2016   Davide Fabris - Added FinalStep
----------------------------------------------------------------------------*/

public interface ProcedureStepHandler{

    //It returns a map that for each key stores a pari "property"-"Value" For exemple uasing as key the User Id i return some KPI
    Map<String, Map<String,String>> WalkStep(Procedure_Step__c theStep, List<Sobject> scope); 
    
    // given the set of properties define what to do with them. Executed at finish of batch
    void FinalAction(Procedure_Step__c theStep, Map<String, Map<String,String>> PropertyList);
    
}