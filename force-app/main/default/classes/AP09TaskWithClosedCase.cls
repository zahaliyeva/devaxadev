public without sharing class AP09TaskWithClosedCase {
/* 
----------------------------------------------------------------------
-- - Name          : AP09_TaskWithClosedCase
-- - Author        : Spoon Consulting
-- - Description   : Task Closed  
--
-- Maintenance History: 
--
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  ---------------------------------------
-- 03-APR-2015  HDU    1.0     Initial version (add error to none closing task 
--                              assiociated with closed case)
----------------------------------------------------------------------
***********************************************************************/
    
    public static void validatedTaskAndCaseStatus(set<Id>setCaseId,list<Task> listTask){
        set<id>setClosedCaseId = new set<Id>();
        for(Case c : [  SELECT id,isclosed 
                        FROM Case
                        WHERE id IN :setCaseId  ]){
            if(c.isclosed){
                setClosedCaseId.add(c.id);
            }//end of check closed
        }//end of loop
        
        if(setClosedCaseId.size()>0){
            for(Task t : listTask){
                //MOSCATELLI_M: EVO52--START
                //if( setClosedCaseId.contains(t.whatId)
                if( setClosedCaseId.contains(t.whatId) && t.Status<> AP_Constants.taskStatusInformationReceived )
                //MOSCATELLI_M: EVO52--END
                    t.addError( System.label.ClosedCaseTaskNoneClosedError );
            }//end of loop 
        }//end of check size
    }//end of method

}//end of class