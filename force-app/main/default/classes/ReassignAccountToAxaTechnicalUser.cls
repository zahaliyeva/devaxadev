/**
 * @description PURE IT 22/05 - commentata la classe
 */
public class ReassignAccountToAxaTechnicalUser {}
/** PURE IT

global class ReassignAccountToAxaTechnicalUser implements Database.Batchable<sObject>,Schedulable
{

    /*
    
    //TO SCHEDULE:
    ReassignAccountToAxaTechnicalUser p24 = new ReassignAccountToAxaTechnicalUser();
    String sch = '0 30 01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,20,21,22,23 * * ?';
    system.schedule('ReassignAccountToAxaTechnicalUser', sch, p24);
    
    //TO LAUNCH SINGLE EXECUTION:
    ReassignAccountToAxaTechnicalUser b = new ReassignAccountToAxaTechnicalUser();
    
    //FOR ETL MIGRATION (DATE TO BE CHANGE) - START
    //b.query = 'select id, OwnerId from Account where createddate > 2015-10-05T02:00:00.000Z and createdby.name = \'Utente ETL\' and owner.name = \'Utente ETL\' order by AAI_Agency_Reference_Code__c ';
    //b.query = 'select id, OwnerId from InsurancePolicy__c where createddate > 2015-10-05T02:00:00.000Z and createdby.name = \'Utente ETL\' and owner.name = \'Utente ETL\' order by CUID__C ';
    //b.query = 'select id, OwnerId from Claim__c where createddate > 2015-10-05T02:00:00.000Z and createdby.name = \'Utente ETL\' and owner.name = \'Utente ETL\' order by Account__c, Polizza__c ';
    //FOR ETL MIGRATION (DATE TO BE CHANGE) - END
    
    //b.query = 'Select id, OwnerId from Account where id = \'00126000004LD5Y\'  ' ;
    //b.query = 'Select id, OwnerId from Lead where id = \'00Q260000010g2l\'  ' ;
    //b.NEW_OWNER_ID = '00524000000T5E3';
    Database.ExecuteBatch(b,200);  
    


    public Id NEW_OWNER_ID = (AAI_Code_Variables__c.getAll()).get('AXA_TECHNICAL_USER_ID').Value__c != null ? (AAI_Code_Variables__c.getAll()).get('AXA_TECHNICAL_USER_ID').Value__c : UserInfo.getUserId();


    public static INTEGER MAX_SCOPE = 200;
    public boolean changeOwner = true;
    public String query = 'Select id, OwnerId from Account where TECH_Company__c = \'AAI\' and OwnerId != :NEW_OWNER_ID '; 
    //public String query = 'Select id, OwnerId from Account where id = null '; 

    global String logToSend='';

    
    
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {  
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<SObject> scope)
    {   
        this.runJob(scope);
    }

    global void finish(Database.BatchableContext BC)
    {

    }
    

    global void Execute(SchedulableContext SC)
    {  
        ReassignAccountToAxaTechnicalUser b = new ReassignAccountToAxaTechnicalUser();
        Database.ExecuteBatch(b,MAX_SCOPE);      
    } 
     

    global void runJob(List<SObject> scope)
    {
        if (changeOwner)
        {
            for (SObject sOb : scope)
            {
                sOb.put('OwnerId', NEW_OWNER_ID);    
            }
        }
        update scope;
    }
    
    
    

     
}
PURE IT */