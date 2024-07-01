/**
 * @description PURE IT 22/05 - commentata la classe
 */
public class TheBatchRecalculateVisibility {}

    /** PURE IT

global class TheBatchRecalculateVisibility implements Database.Batchable<sObject>,Schedulable, Database.Stateful
{




    private static final string QUERY = 'select id from Account where TECH_Batch_Visibility__c= true ORDER BY AAI_Agency_Reference_Code__c';
    private static final string CLASS_NAME = 'TheBatchRecalculateVisibility';
    private static final string ATTACHMENT_NAME = 'attachment.txt';
    global void runJob(List<SObject> scope)
    {
        scope = VisibilityManagementHelper.AlignVisibility_BATCH(scope);
        for (SObject s : scope)
        {
            System.debug(s);
            // s.put('TECH_Batch_Visibility__c' , false);//just switching the flag. the update sort out the visibility            
            logToSend = s + '\n';
        } 
        update scope;
    } 
    /*MODIFY HERE - END*/
    
  
  
    
    /*DO NOT MODIFY*/
    
    /*
    
    //To Launch a Batch run and schedule (or not) following the Custom Setting configuration:
    TheBatchRecalculateVisibility TheB = new TheBatchRecalculateVisibility();
    String sch = ApexSchedulationManager.getScheduleString('1');
    System.Schedule('TheBatchRecalculateVisibility', sch, TheB);
    
    //Launch a single Batch execution:
    TheBatchRecalculateVisibility TheB = new TheBatchRecalculateVisibility();
    Database.ExecuteBatch(TheB);
    

        

    public boolean hasBeenScheduled = false;
    global String logToSend='';

    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {   
        return Database.getQueryLocator(QUERY);
    }
    
    global void execute(Database.BatchableContext BC, List<SObject> scope)
    {   
        this.runJob(scope);
    }

    global void finish(Database.BatchableContext BC)
    {    
        Apex_Schedulation_Manager__c asm = Apex_Schedulation_Manager__c.getInstance(CLASS_NAME);
        
        //Plan New Execution if needed  
        if (asm.Autoschedule__c && hasBeenScheduled==true) 
        { 
            String sch = '';
            if (asm.Expression__c != null)
            { 
                sch = asm.Expression__c;
            } 
            else
            { 
                sch = ApexSchedulationManager.getScheduleString(asm.Frequency__c+'');
            }
            
            //Lunch this batch only between 7-21
            Datetime CurrentTime = Datetime.now();
            if (CurrentTime.hour()>=7 && CurrentTime.hour()<=21) {
                //schedule as explained by the Custom Setting
                system.Schedule(asm.name+String.ValueOf(System.currentTimeMillis()),sch,new TheBatchRecalculateVisibility());
            } else {
                //Schedule for 7 in the morning after. the string format is 'ss min hh dd mm DOW yy'
                sch ='00 00 07';
                if (CurrentTime.hour()>21) {//must go for tomorrow
                    sch = sch+' '+CurrentTime.addDays(1).day();
                    sch = sch+ ' ' +CurrentTime.addDays(1).month();
                    sch = sch+' ? ';//any day of the week
                    sch = sch+' '+CurrentTime.addDays(1).Year();
                } else {//is early in the morning, just scheduling for today at 7
                    sch = sch+' '+CurrentTime.day();
                    sch = sch+ ' ' +CurrentTime.month();
                    sch = sch+' ? ';//any day of the week
                    sch = sch+' '+CurrentTime.Year();
                }
                system.Schedule(asm.name+String.ValueOf(System.currentTimeMillis()),sch,new TheBatchRecalculateVisibility());
            }
        } 
        
        //Send log if needed
        if (asm.Send_Log__c == true) 
        { 
            User u = [Select id, Email From User where id = :UserInfo.getUserId() limit 1];
            String emailObj = 'ORG=['+UserInfo.getOrganizationId()+'] JOB=['+BC.getJobId()+']'+' '+asm.name;
            ApexSchedulationManager.sendMailPlus(u, ATTACHMENT_NAME, ' '+logToSend, emailObj, '');
        }
    }
    
    
    
    global void Execute(SchedulableContext SC)
    {  
        //Abort of scheduled Job
        System.abortJob(SC.getTriggerId());   
        //Launch new execution   
        TheBatchRecalculateVisibility b = new TheBatchRecalculateVisibility();
        b.setHasBeenScheduled(true);
        Apex_Schedulation_Manager__c asm = Apex_Schedulation_Manager__c.getInstance(CLASS_NAME);
        Database.ExecuteBatch(b,Integer.valueOf(asm.Scope__c));        
     } 
     
     public void setHasBeenScheduled(boolean b)
     { 
        hasBeenScheduled = b;
     }    

}   
 PURE IT */