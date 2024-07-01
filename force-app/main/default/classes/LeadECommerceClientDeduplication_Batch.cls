/*------------------------------------------------------------------------
Author:        Francesca Marchese
Company:       Deloitte
Class:         LeadECommerceClientDeduplication_Batch
Description:   This batch's purpose is to retrieve ECommerce contracts signed on the previous day 
			   in order to get the related customers and call the method designated to customer's
			   deduplication on LeadECommerceManagement class

History

17/10/2018     Created - F.M.
----------------------------------------------------------------------------*/

global class LeadECommerceClientDeduplication_Batch implements Database.Batchable<sObject>,Schedulable, Database.AllowsCallouts, Database.Stateful
{

//*****Da definire schedulazione del Batch
/*
//TO SCHEDULE:
    LeadECommerceClientDeduplication_Batch h21 = new LeadECommerceClientDeduplication_Batch();
    String sch = '0 0 21 ? * MON-FRI'; 
    system.schedule('LeadECommerceClientDeduplication_Batch', sch, h21);
    
//TO LAUNCH SINGLE EXECUTION:
    LeadECommerceClientDeduplication_Batch b = new LeadECommerceClientDeduplication_Batch();    
    Database.ExecuteBatch(b,100); 
*/
    public boolean hasBeenScheduled = false;
    public static INTEGER MAX_SCOPE = 100;
    global string CLASS_NAME = (!Test.isRunningTest())?'LeadECommerceClientDeduplication_Batch':'testDeduplicationBatch';

    public String query = 'SELECT Id, Gi_cliente_AXA__c, Company, FirstName, LastName, AAI_Partita_IVA__c, Fiscal_ID__c '+ 
                           'FROM Lead '+
                           'WHERE Gi_cliente_AXA__c = false AND '+
                           'RecordType.DeveloperName = \'eCommerce\' AND '+
                           'Id IN (SELECT Lead__c FROM Quotazione__c WHERE TECH_Price_DueDate__c >= TODAY)';
    
    global LeadECommerceClientDeduplication_Batch() {}


    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {  
        if(Test.isRunningTest()){
            query = query + ' LIMIT 1';
        }
        return Database.getQueryLocator(query);
        
    }

 

    global void execute(Database.BatchableContext BC, List<Lead> scope) {


        System.debug('scope ===> ' + scope);
        this.runJob(scope);
        
   
    }

    global void Execute(SchedulableContext SC)
    {  
        //System.abortJob(SC.getTriggerId());        
        
        LeadECommerceClientDeduplication_Batch b = new LeadECommerceClientDeduplication_Batch();
        b.setHasBeenScheduled(true);
        
        Apex_Schedulation_Manager__c asm = Apex_Schedulation_Manager__c.getInstance(CLASS_NAME);
        
        Database.ExecuteBatch(b,Integer.valueOf(asm.Scope__c));      
    
    }

    global void finish(Database.BatchableContext BC) {
        //Apex_Schedulation_Manager__c asm = Apex_Schedulation_Manager__c.getInstance(CLASS_NAME);
        
        ////Plan New Execution if needed  
        //if (asm != null && asm.Autoschedule__c && hasBeenScheduled==true) 
        //{ 
        //    String sch = '';
        //    if (asm.Expression__c != null)
        //    { 
        //        sch = asm.Expression__c;

        //        //CAPOBIANCO_A 28/09/2017 - START
        //        if((30 <= system.now().minute()) && (system.now().minute() <= 59))
        //        {
        //            sch = asm.Expression_Bis__c;
        //        }
        //        //CAPOBIANCO_A 28/09/2017 - END
        //    } 
        //    else
        //    { 
        //        sch = ApexSchedulationManager.getScheduleString(asm.Frequency__c+'');
        //    }
            
        //    //Launch this batch only between 8-20
        //    Datetime CurrentTime = Datetime.now();
        //    if (CurrentTime.hour()>=8 && CurrentTime.hour()<=20 && !Test.isRunningTest())
        //    {
        //        //schedule as explained by the Custom Setting
        //        system.Schedule(asm.name+String.ValueOf(System.currentTimeMillis()),sch,new LeadECommerceClientDeduplication_Batch());
        //    } 
        //    else
        //    {
        //        //Schedule for 8 in the morning after. the string format is 'ss min hh dd mm DOW yy'
        //        sch ='00 00 20';
                
        //        if (CurrentTime.hour()>20) 
        //        {//must go for tomorrow
        //            sch = sch+' '+CurrentTime.addDays(1).day();
        //            sch = sch+ ' ' +CurrentTime.addDays(1).month();
        //            sch = sch+' ? ';//any day of the week
        //            sch = sch+' '+CurrentTime.addDays(1).Year();
        //        } else 
        //        {//is early in the morning, just scheduling for today at 8
        //            sch = sch+' '+CurrentTime.day();
        //            sch = sch+ ' ' +CurrentTime.month();
        //            sch = sch+' ? ';//any day of the week
        //            sch = sch+' '+CurrentTime.Year();
        //        }
        //        if(Test.isRunningTest()){
        //            sch = asm.Expression__c;
        //        }
        //        system.Schedule(asm.name+String.ValueOf(System.currentTimeMillis()),sch,new LeadECommerceClientDeduplication_Batch());
        //    }
        //} 
    }
    
    
    
    global void runJob(List<Lead> scope){
    
    system.debug('!!!'+scope);

    LeadManagementECommerce.matchLeadstoAccounts(scope); 
     
    }

     public void setHasBeenScheduled(boolean b)
    { 
        hasBeenScheduled = b;
    }

}