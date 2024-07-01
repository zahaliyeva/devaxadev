/*------------------------------------------------------------------------
Author:        Francesca Marchese
Company:       Deloitte
Class:         BatchICFIntegration
Description:   This batch's purpose is to call the the ICFIntegration in order
               to send the records' information to Sandsiv

History

14/12/2016     Created - F.M.
----------------------------------------------------------------------------*/
/**
 * @description PURE IT 22/05 - commentata la classe
 */
public class BatchICFIntegration {}

/*
global class BatchICFIntegration implements Database.Batchable<sObject>,Schedulable, Database.AllowsCallouts, Database.Stateful
{
   

//TO SCHEDULE:
    BatchICFIntegration h21 = new BatchICFIntegration();
    String sch = '0 0 21 ? * MON-FRI';
    system.schedule('BatchICFIntegration', sch, h21);
    
//TO LAUNCH SINGLE EXECUTION:
    BatchICFIntegration b = new BatchICFIntegration();    
*/
/** PURE IT
 
    public static INTEGER MAX_SCOPE = 100;
    //public List<Interazione__c> Interactions = [SELECT Id, Account__c, Account__r.NDG__c, Account__r.FirstName, Account__r.LastName, Account__r.Gender__c, Account__r.Age__c, Account__r.AAI_Codice_fiscale__c, Account__r.CIF_PersonEmail__c, Account__r.CIF_PersonMobilePhone__c, Account__r.Promotional_privacy__c, Account__r.Market_research_privacy__c, Account__r.AAI_Agency_Reference_Code__c, CreatedDate, Tipologia__c, CreatedById, TECH_Da_inviare__c, Stato__c FROM Interazione__c  WHERE TECH_Da_inviare__c=true AND Limite_massimo_invio_survey__c >=TODAY AND  (Account__r.CIF_PersonEmail__c!=null OR Account__r.CIF_PersonMobilePhone__c !=null) LIMIT 100];
    public String query = 'SELECT Id, Account__c, Account__r.NDG__c, Account__r.FirstName, Account__r.LastName, Account__r.Gender__c, Account__r.Age__c, Account__r.AAI_Codice_fiscale__c, Account__r.CIF_PersonEmail__c, Account__r.CIF_PersonMobilePhone__c, Account__r.Promotional_privacy__c, Account__r.Market_research_privacy__c, Account__r.AAI_Agency_Reference_Code__c, CreatedDate, Tipologia__c,Tipologia_Prodotto__c, CreatedById, TECH_Da_inviare__c, Stato__c, Questionario_richiesto_da__c, Created_By__c FROM Interazione__c  WHERE TECH_Da_inviare__c=true AND Limite_massimo_invio_survey__c >=TODAY AND (Account__r.CIF_PersonEmail__c!=null OR Account__r.CIF_PersonMobilePhone__c !=null) AND Stato__c=\'Questionario inviato\''; 

    global BatchICFIntegration() {}


    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {  
        
        return Database.getQueryLocator(query);
        
    }

 

    global void execute(Database.BatchableContext BC, List<Interazione__c> scope) {

        this.runJob(scope);
        
   
    }

 

    global void finish(Database.BatchableContext BC) {}
    
    global void Execute(SchedulableContext SC)
    {  
        //BatchICFIntegration b = new BatchICFIntegration();
        //Database.ExecuteBatch(b,MAX_SCOPE); 
    } 
    
    
    
    global void runJob(List<Interazione__c> scope)
    {
    
    system.debug('!!!'+scope);
    
    List <ICFManagement.XMLInformation> result = new List <ICFManagement.XMLInformation>();
    
    result = ICFManagement.ICFSendSurveys((List <Interazione__c>)scope);
    
    ICFManagement.UpdateRecords(result); 
     
    }
    PURE IT */