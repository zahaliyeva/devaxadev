/*------------------------------------------------------------------------
Author:        Davide Fabris
Company:       Deloitte
Class:         ProcedureManagement
Description:   Class that supports the procedure logics
History
-01/08/2016   Davide Fabris - Created

----------------------------------------------------------------------------*/
public class ProcedureManagement {

    public static void MoveToNextStep(Procedure_Step__c inputStep) {
        //Based on the DB current situation returns the NextStep to RUN
        system.debug('#### STARTING STEP'+inputStep);
        List<Procedure_Step__c> availableSteps = [Select Id, is_Active__c, Last_Execution__c, Step_Handler_Class__c, Order__c, Procedure_Definition__c  From Procedure_Step__c WHERE is_Active__c=true AND Procedure_Definition__r.is_Active__c=true order by Procedure_Definition__c ASC, Order__c ASC  ];
        
        Procedure_Step__c NextStep = new Procedure_Step__c();
        for (integer i=0; i<availableSteps.size(); i++) {
            if(inputStep.Id == availableSteps[i].Id) {
                if (i==availableSteps.size()-1) {
                    // Reached the end of available steps Starting again from the beginning
                    // NextStep.Id=availableSteps[0].Id;
                    NextStep=availableSteps[0];
                    system.debug('++++++reached the end');
                    system.debug('nextidis '+availableSteps[0].Id);
                } else {
                    // Setting the next step as the one to be done
                    // NextStep.Id=availableSteps[i+1].Id;
                    NextStep=availableSteps[i+1];                    
                    system.debug('+++added one more');
                    system.debug('++nextidis '+availableSteps[i+1].Id);
                }
            }
            
        }
        
        system.debug('++++currentStep-->'+inputStep);
        system.debug('++++computednextstep-->'+NextStep);
        inputStep.isNext__c = false;
        NextStep.isNext__c = true;
        
        
        List<Procedure_Step__c> stepToUpdate = new List<Procedure_Step__c>();
        stepToUpdate.add(inputStep);
        stepToUpdate.add(NextStep);
        update stepToUpdate;
        
    }
    
    public static boolean isLastStep(Procedure_Step__c currentStep) {
        system.debug('####given step:'+currentStep);
        //getting all the steps of current procedure
        List<Procedure_Step__c> availableSteps = [Select Id, is_Active__c, Last_Execution__c, Step_Handler_Class__c, Order__c, Procedure_Definition__c  From Procedure_Step__c WHERE is_Active__c=true AND Procedure_Definition__r.is_Active__c=true order by Procedure_Definition__c ASC, Order__c ASC  ];
        Id LastItemId =null;
        if (!availableSteps.isempty()){
            system.debug('###LAST ITEM'+availableSteps[availableSteps.size()-1]);
            LastItemId = availableSteps[availableSteps.size()-1].Id;
        } 
        
        system.debug('####COMPARING LAST'+LastItemId+'WITH'+currentStep.Id);
        if (LastItemId==currentStep.Id) {
            return true;
        } else {
            return false;
        }
    }
    
    public static boolean IsFistStepOfProcedure(Procedure_Step__c currentStep) {
        boolean theresult = false;
        system.debug('####given step:'+currentStep);
        //getting only the steps of current procedure
        List<Procedure_Step__c> availableSteps = [Select Id, is_Active__c, Last_Execution__c, Step_Handler_Class__c, Order__c, Procedure_Definition__c  From Procedure_Step__c WHERE is_Active__c=true AND Procedure_Definition__r.is_Active__c=true AND Procedure_Definition__c=:currentStep.Procedure_Definition__c order by Procedure_Definition__c ASC, Order__c ASC  ];
        if (!availableSteps.isEmpty()) {
            if (currentStep.Id==availableSteps[0].Id) {
                theresult = true;
            } 
        }
        
        return theresult;
    }
    
    public static boolean IsLastStepOfProcedure(Procedure_Step__c currentStep) {
        boolean theresult = false;
        system.debug('####given step:'+currentStep);
        //getting only the steps of current procedure
        List<Procedure_Step__c> availableSteps = [Select Id, is_Active__c, Last_Execution__c, Step_Handler_Class__c, Order__c, Procedure_Definition__c  From Procedure_Step__c WHERE is_Active__c=true AND Procedure_Definition__r.is_Active__c=true AND Procedure_Definition__c=:currentStep.Procedure_Definition__c order by Procedure_Definition__c ASC, Order__c ASC  ];
        if (!availableSteps.isEmpty()) {
            if (currentStep.Id==availableSteps[availableSteps.size()-1].Id) {
                theresult = true;
            } 
        }
        
        return theresult;
    }
    
    public static Map<string, Map<String,string>> AddMaps(Map<string, Map<String,string>> currentCount ,Map<string, Map<String,string>> Totalcounts) {
        system.debug('++++adding'+currentCount);
        system.debug('++++to'+Totalcounts);
        if (Totalcounts==null || Totalcounts.keyset().isempty()) {//first time counting
            return currentCount;
        } else {
            for(String thisKey : currentCount.keyset()) {
                system.debug('+++handling key-->'+ thisKey);
                
                //I need to add these properties to the total count
                Map<String,String> currentMap = currentCount.get(thisKey);
                system.debug('+++found these properties'+ currentMap);
                if (Totalcounts.keyset().contains(thisKey)) {
                    system.debug('++there was already the key');
                    Map<string,String> currenttotalMap = Totalcounts.get(thisKey);
                    system.debug('Adding'+currentMap);
                    system.debug('To'+currenttotalMap);
                    // I have to add
                    for(String thisProperty : currentMap.keyset()) {
                        system.debug('+++adding this property'+thisProperty);
                        if(currenttotalMap.keyset().contains(thisProperty)) {
                            string totalProperty = currenttotalMap.get(thisProperty);
                            string currentProperty = currentMap.get(thisProperty);
                            
                            totalProperty = (Double.valueOf(currentProperty) + Double.valueOf(totalProperty)) + ''; 
                            
                            system.debug('+++adding'+currentProperty+'++to++'+totalProperty);
                            currenttotalMap.put(thisProperty,totalProperty+'');
                        } else {//is a new property
                            currenttotalMap.put(thisProperty,currentMap.get(thisProperty));
                        }
                    }
                    Totalcounts.put(thisKey,currenttotalMap);
                } else {
                    Totalcounts.put(thisKey,currentMap);
                }
            }
        }
        
        return Totalcounts;
    }

}