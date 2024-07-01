@isTest
public class CompetitorContractHandlerTest{
    static testMethod void triggerCall(){
        
        AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
        insert acv; 
        
        Test.startTest();
    
        Account ag =new Account(Name ='Test',Account_email__c ='test@test.test',Agency_Code__c = '000111',Agency_Holder__c = 'test',TECH_Company__c = 'AAI', Active__c = true);
        insert ag;
        
        Group g =new Group (Type = 'Queue',Name = 'Coda_Agenzia_000111',DeveloperName = 'Coda_Agenzia_000111');
        insert g;
        
        Competitor_Contract__c c = new Competitor_Contract__c(Name = 'Test', Account__c = ag.id, Contract_Expiry_Date__c = Date.today() ,
                                                              Contract_Starting_Date__c = '2000', Premium__c = 1000, TECH_CreateTask__c = false);
        insert c;  
        c.TECH_CreateTask__c = true;
        c.Contract_Expiry_Date__c = Date.today().addDays(10);
        update c;
        c.TECH_CreateTask__c = true;
        c.Contract_Expiry_Date__c = Date.today().addDays(100);
        update c;
        delete c;                                                    
       
    }
}