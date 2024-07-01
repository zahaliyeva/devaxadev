@isTest
public class PolizzaHandlerTest{
    static testmethod void TestPolizzaHandler(){
    
        Map<string,Map<string,string>> rtypes = UtilityClass.fetchAllRTypes();
        id account_B2C = UtilityClass.getRTid(rtypes, 'Account', 'B2C_Client');
        id insurancePolicy_Motor = UtilityClass.getRTid(rtypes, 'InsurancePolicy__c', 'B2C_Motor');
        id insurancePolicy_No_Motor = UtilityClass.getRTid(rtypes, 'InsurancePolicy__c', 'B2C_No_Motor');
        
        AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
        insert acv;
    
        // Create B2C Account
        Account b2cClient1 = new Account(FirstName = 'Test',
                                        LastName = 'B2C Account',
                                        RecordTypeId = account_B2C,
                                        Nodes__c = '5014'
                                        );
                                      
        insert b2cClient1;

        Account b2cClient2 = new Account(FirstName = 'Test2',
                                        LastName = 'B2C Account2',
                                        RecordTypeId = account_B2C,
                                        Nodes__c = '5015'
                                        );
                                      
        insert b2cClient2;
        
        // Create Polizza Records
        InsurancePolicy__c contract1 = new InsurancePolicy__c(Name = 'Contract 1',
                                               Status__c = 'Active',
                                               Line__c = 'Car',
                                               RecordTypeId = insurancePolicy_Motor,
                                               TECH_Company__c = 'AAI',
                                               CUID__c = b2cClient1.Id);
        //insert contract1;
        
        InsurancePolicy__c contract2 = new InsurancePolicy__c(Name = 'Contract 2',
                                               Status__c = 'Active',
                                               Line__c = 'Savings',
                                               RecordTypeId = insurancePolicy_No_Motor,
                                               TECH_Company__c = 'AAI',
                                               CUID__c = b2cClient1.Id);
        //insert contract2;
        List<InsurancePolicy__c> contractToInsert = new List<InsurancePolicy__c>();
        contractToInsert.add(contract1);
        contractToInsert.add(contract2);
        
        insert contractToInsert;
        
        // Update Polizze
        contract1.Line__c = '1';
        contract1.TECH_Company__c = 'MPS';
        contract1.CUID__c = b2cClient2.id;
        
        //update contract1;
        contract2.Line__c = '3';
        //update contract2;
        
        List<InsurancePolicy__c> contractToUpdate = new List<InsurancePolicy__c>();
        contractToUpdate.add(contract1);
        contractToUpdate.add(contract2); 
        update contractToUpdate;
               
        //Delete and Undelete Polizze
        delete contract1;
        undelete contract1;
        
        //delete contract2;
        //undelete contract2;
        
    }   
}