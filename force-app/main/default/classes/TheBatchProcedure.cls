global class TheBatchProcedure implements Database.Batchable<sObject>,Schedulable, Database.Stateful {
    /*
    MODIFY ONLY THE PARAMETERS SHOWN ON THE FIRST PART OF THIS CLASS
    
    /////////To Launch a Batch run and schedule (or not) following the Custom Setting configuration:////////
    TheBatchProcedure TheB = new TheBatchProcedure();
    String sch = ApexSchedulationManager.getScheduleString('1');
    System.Schedule('TheBatchProcedure', sch, TheB);
    
    ////////// Launch a single Batch execution ///////////
    TheBatchProcedure TheB = new TheBatchProcedure();
    //////Optional////////
    //if you want to specify the step (not the first) Remember to manually set the field "boundle" on the procedure, otherwise the last one will be used
    List<Procedure_Step__c> CurrentStep = [Select Id,is_Active__c, Last_Execution__c, Step_Handler_Class__c, Order__c, Procedure_Definition__c  From Procedure_Step__c WHERE ... Limit 1];
    TheB.theStep = CurrentStep; //if you run it like this the steps after this one will be executed as well
    
    //If you want to execute a single step
    TheB.runAllSteps = false;
    //////Optional////////
    
    Database.ExecuteBatch(TheB);
    */
    
    /*MODIFY HERE - START*/
    private static final string CLASS_NAME = 'TheBatchProcedure';
    private static final string ATTACHMENT_NAME = 'attachment.txt';
    
    //The step that should be executed (and its execution record)
    public Procedure_Step__c theStep {get;set;}
    public Procedure_Step_Execution__c theExecution {get;set;}
    
    //Keeping trace of the records processed
    public integer RecordProcessed {get;set;}
    
    //Counting things through the jobItems
    //        theUserId,   PropertyName, Number-->In this way if you need to count more things for a single user just put another string
public Map<String, Map<String,String>> Totalcounts {get;set;}
//global Map<String, Map<String,String>> Totalcounts {get;set;}
    
    
    
    //to modify if you want to run a single step
    global boolean runAllSteps = true; 
    /*MODIFY HERE - END*/
    
    global void runJob(List<SObject> scope) {
        system.debug('##### CURRENT STEP =====>'+theStep);
        
        //Get the correct handler for this step
        ProcedureStepHandler thisHandler = (ProcedureStepHandler)Type.forName(theStep.Step_Handler_Class__c).newInstance();
        
        //Walk the step
        Map<String, Map<String,String>> currentCount = new  Map<String, Map<String,String>>();
        system.debug('++++walking'+theStep.Step_Handler_Class__c);
        currentCount = thisHandler.WalkStep(theStep, scope);
        system.debug('++++walked'+theStep.Step_Handler_Class__c);
        //Merging info from different job items
        Totalcounts = ProcedureManagement.AddMaps(currentCount,Totalcounts);//Adding currentCount tho the totalcounts
        RecordProcessed = RecordProcessed + scope.size();
    } 

    
    /*DO NOT MODIFY*/
    
    global  string QUERY = '';
    global boolean hasBeenScheduled = false;
    global String logToSend='';
    

    
    global Database.QueryLocator start(Database.BatchableContext BC) { 
        system.debug('@@@@@@@@@ START @@@@@@@@@@');
        //First I get the current step to run marked as "isnext"
        if (theStep == null) {//I should find the next step
            List<Procedure_Step__c> CurrentStep = [Select Id,is_Active__c,Query_To_Run__c, Last_Execution__c, Step_Handler_Class__c, Order__c, Procedure_Definition__c,Procedure_Definition__r.currentBoundle__c,Scope__c  From Procedure_Step__c WHERE is_Active__c=true AND Procedure_Definition__r.is_Active__c=true AND isNext__c=true LIMIT 1];
            if (CurrentStep.isEmpty()) {
                // there are no steps to run, returning empty query
                return Database.getQueryLocator('SELECT Id from Lead where Id =\''+UserInfo.getUserId()+'\''); //running impossible query to return a query locator with no elements
            }else {
                this.theStep = CurrentStep[0];
            }
        }
        //Tracing the number of records
        RecordProcessed = 0;
        Totalcounts = new Map<String,Map<String,String>>();

        //Add exception handling for when no next is defined
        this.QUERY = theStep.Query_To_Run__c;
        SYSTEM.DEBUG('##### FOUND CURRENT STEP =====>'+theStep);
        SYSTEM.DEBUG('##### RUNNING THE QUERY ======>'+QUERY);

        //Then I prepare the next Step to RUN-->Consider moving on finish method. But there is the risk of blocking the steps
        if (runAllSteps) {
            ProcedureManagement.MoveToNextStep(theStep); 
            SYSTEM.DEBUG('##### MOVED TO NEXT STEP #####');
        }  

        string theboundle = '';

        if (ProcedureManagement.IsFistStepOfProcedure(theStep)) {
            //Set the boundle tag 
            Procedure_Definition__c currentProcedure = new Procedure_Definition__c();
            currentProcedure.Id = theStep.Procedure_Definition__c;
            
            if (runAllSteps) {
                currentProcedure.currentBoundle__c = String.ValueOf(System.currentTimeMillis());
            } else {
                currentProcedure.currentBoundle__c = 'SINGLE EXECUTION';
            }
            
            theboundle = currentProcedure.currentBoundle__c;
            update currentProcedure;
        } else {//get the boundle from the procedure definition
            theboundle = theStep.Procedure_Definition__r.currentBoundle__c;
        }
        

        //trace start execution date here
        theExecution = new Procedure_Step_Execution__c();
        theExecution.Execution_Start__c = DateTime.Now();
        theExecution.Procedure_Step__c = theStep.Id;
        theExecution.Status__c = 'Started';
        theExecution.JobId__c = BC.getJobId();
        theExecution.Record_Processed__c = RecordProcessed;
        if (runAllSteps) {
            theExecution.Boundle__c = theboundle;//computed when moving steps
        } else {
            theExecution.Boundle__c = 'SINGLE EXECUTION';
        }
        
        insert theExecution;
        
        
        try {
            return Database.getQueryLocator(QUERY);
        } catch (exception e) {
            theExecution.Status__c = 'ERROR';
            theExecution.ErrorMessage__c =  'Could not run Query:'+QUERY;
            update theExecution;
            return Database.getQueryLocator('SELECT Id from Lead where Id =\''+UserInfo.getUserId()+'\''); //running impossible query to return a query locator with no elements
        }
    }
    
    global void execute(Database.BatchableContext BC, List<SObject> scope) {  
        system.debug('@@@@@@@@@ EXECUTE @@@@@@@@@@');       
        this.runJob(scope);
    }

    global void finish(Database.BatchableContext BC) {
        system.debug('@@@@@@@@@ FINISH @@@@@@@@@@');       

        if (theStep==null) {
            //just schedule for next time
            //Plan New Execution  
            Apex_Schedulation_Manager__c asm = Apex_Schedulation_Manager__c.getInstance(CLASS_NAME);
            if (asm.Autoschedule__c && hasBeenScheduled==true) { 
                String sch = '';
                if (asm.Expression__c != null) { 
                    sch = asm.Expression__c;
                } else { 
                    sch = ApexSchedulationManager.getScheduleString(asm.Frequency__c+'');
                }
                system.Schedule(asm.name,sch,new TheBatchProcedure());
                system.debug('#### scheduled next run of steps');
            } 

            //Send log to say that there are no steps running
            User u = [Select id, Email From User where id = :UserInfo.getUserId() limit 1];
            String emailObj = 'NO STEPS FPOUND - ORG=['+UserInfo.getOrganizationId()+'] JOB=['+BC.getJobId()+']'+' '+asm.name;
            ApexSchedulationManager.sendMailPlus(u, ATTACHMENT_NAME, ' '+logToSend, emailObj, '');
        } else {
            //trace end execution date here
            if (theExecution.Status__c=='Started') { //otherwise it measn i traced an error on start
                AsyncApexJob a = [SELECT Id, Status, NumberOfErrors,ExtendedStatus,  JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :BC.getJobId()];
                theExecution.Execution_end__c = DateTime.now();
                theExecution.Status__c = a.Status;
                theExecution.ErrorMessage__c= a.ExtendedStatus;
                theExecution.Record_Processed__c = RecordProcessed;
            } else {
                theExecution.Execution_end__c = DateTime.now();
            }
            update theExecution;
            
            

            if (ProcedureManagement.IsLastStepOfProcedure(theStep)) {
                //I am at the last step of a single procedure, saving last execution time
                Procedure_Definition__c theDefinitionToUpdate = new Procedure_Definition__c();
                theDefinitionToUpdate.Id = theStep.Procedure_Definition__c;
                theDefinitionToUpdate.Last_Execution__c = DateTime.Now();
                update theDefinitionToUpdate;
                system.debug('### Updated Definition with last execution');
            }
            
            system.debug('##### CURRENT STEP at finish=====>'+theStep);
            
            //Get the correct handler for this step
            ProcedureStepHandler thisHandler = (ProcedureStepHandler)Type.forName(theStep.Step_Handler_Class__c).newInstance();
            
            //finish step
            thisHandler.FinalAction(theStep, Totalcounts);
            
            
            //Now sort out what to do next (schedule or run another batch)
            if (runAllSteps) {
                Apex_Schedulation_Manager__c asm = Apex_Schedulation_Manager__c.getInstance(CLASS_NAME);
                
                //All steps are executed one after another. At the last step I schedule again
                if (ProcedureManagement.isLastStep(this.theStep)) {
                    SYSTEM.DEBUG('### check SCHEDULING BECAUSE WE ARE AT LAST STEP #####');
                    SYSTEM.DEBUG('----Last step'+theStep);
                    SYSTEM.DEBUG('----hasBeenScheduled'+hasBeenScheduled);

                    //Plan New Execution  
                    if (asm.Autoschedule__c && hasBeenScheduled==true) { 
                        String sch = '';
                        if (asm.Expression__c != null) { 
                            sch = asm.Expression__c;
                        } else { 
                            sch = ApexSchedulationManager.getScheduleString(asm.Frequency__c+'');
                        }
                        system.Schedule(asm.name+String.ValueOf(System.currentTimeMillis()),sch,new TheBatchProcedure());
                        system.debug('#### scheduled next run of steps');
                    } 

                    //Send log if needed
                    if (asm.Send_Log__c == true) { 
                        User u = [Select id, Email From User where id = :UserInfo.getUserId() limit 1];
                        String emailObj = 'ORG=['+UserInfo.getOrganizationId()+'] JOB=['+BC.getJobId()+']'+' '+asm.name;
                        ApexSchedulationManager.sendMailPlus(u, ATTACHMENT_NAME, ' '+logToSend, emailObj, '');
                    }
                } else {
                    //Execute next step
                    SYSTEM.DEBUG('### WE ARE NOT AT THE LAST STEP, EXECUTING ANOTHER BATCH');
                    SYSTEM.DEBUG('### CURRENT STEP: '+theStep);
                    
                    Procedure_Step__c nextStep = [Select Id,is_Active__c,Query_To_Run__c, Last_Execution__c, Step_Handler_Class__c, Order__c, Procedure_Definition__c,Procedure_Definition__r.currentBoundle__c,Scope__c  From Procedure_Step__c WHERE is_Active__c=true AND Procedure_Definition__r.is_Active__c=true AND isNext__c=true LIMIT 1];
                    SYSTEM.DEBUG('### NEXT STEP IS: '+nextStep);
                    
                    TheBatchProcedure TheB = new TheBatchProcedure();
                    if (hasBeenScheduled) {//Passing on the info that the batch was coming from a schedule
                        TheB.setHasBeenScheduled(true);
                    }
                    
                    if (nextStep.Scope__c!=null && nextStep.Scope__c>0) {
                        system.debug('121212### executing batch'+nextStep.Step_Handler_Class__c+' with scope:'+nextStep.Scope__c);
                        Database.ExecuteBatch(TheB, Integer.ValueOf(nextStep.Scope__c));
                    } else {
                        system.debug('### scope not found, using the one of the class');
                        Database.ExecuteBatch(TheB, Integer.ValueOf(asm.Scope__c));
                    }
                }//if-else isLastStep
            } //if(runAllSteps)
        } //if stp==null
    }
    
    global void Execute(SchedulableContext SC) {  
        system.debug('@@@@@@@@@ EXECUTE SCH @@@@@@@@@@');       

        //Abort of scheduled Job
        System.abortJob(SC.getTriggerId());   
        //Launch new execution   
        TheBatchProcedure b = new TheBatchProcedure();
        b.setHasBeenScheduled(true);
        Apex_Schedulation_Manager__c asm = Apex_Schedulation_Manager__c.getInstance(CLASS_NAME);
        
        Procedure_Step__c nextStep = [Select Id,is_Active__c,Query_To_Run__c, Last_Execution__c, Step_Handler_Class__c, Order__c, Procedure_Definition__c,Procedure_Definition__r.currentBoundle__c,Scope__c  From Procedure_Step__c WHERE is_Active__c=true AND Procedure_Definition__r.is_Active__c=true AND isNext__c=true LIMIT 1];
        SYSTEM.DEBUG('### scheduling with scope of STEP: '+nextStep);
        if (nextStep.Scope__c!=null && nextStep.Scope__c>0) {
            system.debug('### executing batch'+nextStep.Step_Handler_Class__c+' with scope:'+nextStep.Scope__c);
            Database.ExecuteBatch(b, Integer.ValueOf(nextStep.Scope__c));
        } else {
            system.debug('### scope not found, using the one of CS'+Integer.valueOf(asm.Scope__c));
            Database.ExecuteBatch(b,Integer.valueOf(asm.Scope__c));
        }
    }
    
    
    public void setHasBeenScheduled(boolean b) { 
        hasBeenScheduled = b;
    } 
    /*DO NOT MODIFY*/
}