/*-------------------------------------------------------------------------------------------------------------------------
Author:        Marco Moscatelli
Company:       Deloitte
Class:         AP15_NewSmartCenterUsrConfig_Batch
Description:   Batch that associates the new Users created for the AMPS Smart Center to the CallCenter adapter
               developed from Content Guru
History

20/12/2016     Marco Moscatelli - Created
----------------------------------------------------------------------------------------------------------------------------*/
global class AP15_NewSmartCenterUsrConfig_Batch implements Database.Batchable<sObject>,Database.Stateful,Schedulable
{
    /*
    
    //To Launch a Batch run and schedule (or not) following the Custom Setting configuration:
    AP15_NewSmartCenterUsrConfig_Batch TheB = new AP15_NewSmartCenterUsrConfig_Batch();
    String sch = ApexSchedulationManager.getScheduleString('1');
    System.Schedule('AP15_NewSmartCenterUsrConfig_Batch', sch, TheB);
    
    //Launch a single Batch execution:
    AP15_NewSmartCenterUsrConfig_Batch TheB = new AP15_NewSmartCenterUsrConfig_Batch();
    Database.ExecuteBatch(TheB);
    
    */
    
    
    global string ProfilesToSearch;
    global string CallId;
    global string performquery;
    global string CLASS_NAME = (!Test.isRunningTest())?'AP15_NewSmartCenterUsrConfig_Batch':'AP15_Test';
    public boolean hasBeenScheduled = false;
    private static final string ATTACHMENT_NAME = 'attachment.txt';
    global String logToSend='';
    
    global void Definequery()
    {
        for(New_SmartCenter_Users_Call_Center_Config__c NewUsrConfig: New_SmartCenter_Users_Call_Center_Config__c.getAll().values())
        {
            if(!(NewUsrConfig.Profile_Name_Call_Center__c).startswith('0'))
            {
                if(String.isBlank(ProfilesToSearch))
                    ProfilesToSearch = '\''+NewUsrConfig.Profile_Name_Call_Center__c+'\',';
                else
                    ProfilesToSearch += '\''+NewUsrConfig.Profile_Name_Call_Center__c+'\',';            
            }
            else
                CallId = NewUsrConfig.Profile_Name_Call_Center__c;
        }  
        system.debug(ProfilesToSearch+' '+CallId);
        
        ProfilesToSearch = ProfilesToSearch.substringBeforeLast(',');
        
        performquery = 'select id,name,profile.name,callcenterid from user where profile.name in'+' ('+ProfilesToSearch+') and CallCenterId=\'\' and IsActive='+true+'';

        if(Test.isRunningTest())
            performquery+=' limit 1';
            
		system.debug('#performquery: '+performquery+ ' CallId: '+CallId);        
    }
      
	global Database.QueryLocator start(Database.BatchableContext BC)
    {   
        Definequery();
        return Database.getQueryLocator(performquery);
    }

    global void Execute(SchedulableContext SC)
    {  
        System.abortJob(SC.getTriggerId());        
        
        AP15_NewSmartCenterUsrConfig_Batch b = new AP15_NewSmartCenterUsrConfig_Batch();
       	b.setHasBeenScheduled(true);
        
        Apex_Schedulation_Manager__c asm = Apex_Schedulation_Manager__c.getInstance(CLASS_NAME);
        
        Database.ExecuteBatch(b,Integer.valueOf(asm.Scope__c));      
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
            if (CurrentTime.hour()>=7 && CurrentTime.hour()<=21)
            {
                //schedule as explained by the Custom Setting
                system.Schedule(asm.name+String.ValueOf(System.currentTimeMillis()),sch,new AP15_NewSmartCenterUsrConfig_Batch());
            } 
            else
            {
                //Schedule for 7 in the morning after. the string format is 'ss min hh dd mm DOW yy'
                sch ='00 00 07';
                
                if (CurrentTime.hour()>21) 
                {//must go for tomorrow
                    sch = sch+' '+CurrentTime.addDays(1).day();
                    sch = sch+ ' ' +CurrentTime.addDays(1).month();
                    sch = sch+' ? ';//any day of the week
                    sch = sch+' '+CurrentTime.addDays(1).Year();
                } else 
                {//is early in the morning, just scheduling for today at 7
                    sch = sch+' '+CurrentTime.day();
                    sch = sch+ ' ' +CurrentTime.month();
                    sch = sch+' ? ';//any day of the week
                    sch = sch+' '+CurrentTime.Year();
                }
                system.Schedule(asm.name+String.ValueOf(System.currentTimeMillis()),sch,new AP15_NewSmartCenterUsrConfig_Batch());
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

    global void runJob(List<SObject> scope)
    {
        system.debug('CallCenterId: '+CallId);
        
        for (SObject sOb : scope)
        {
            sOb.put('CallCenterId', CallId);    
        }
        system.debug('scope: '+scope);
        update scope;
    }
    
    public void setHasBeenScheduled(boolean b)
    { 
        hasBeenScheduled = b;
    } 
}