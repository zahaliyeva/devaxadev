@isTest
public class ClaimHandlerTest{
    static testmethod void TestClaimHandler(){
    
        Map<string,Map<string,string>> rtypes = UtilityClass.fetchAllRTypes();
        id claim_rt = UtilityClass.getRTid(rtypes, 'Claim__c', 'Claim_Record_Type');
        
        AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
        insert acv;
    
        //Create Claim Records
        Claim__c claim1 = new Claim__c(Name = 'claim1',
                                       City__c = 'Milano',
                                       TECH_Company__c = 'AAI',
                                       RecordTypeId = claim_rt);               
        insert claim1;
        
        Claim__c claim2 = new Claim__c(Name = 'claim1',
                                       City__c = 'Milano',
                                       TECH_Company__c = 'AAI',
                                       RecordTypeId = claim_rt);               
        insert claim2;
        
        //PETRECCHIA_M 05042016: EVO46-----START
        Claim__c claim3 = new Claim__c(Name = 'claim3',
                                       City__c = 'Milano',
                                       TECH_Company__c = 'MPS',
                                       RecordTypeId = claim_rt);               
        insert claim3;
		//PETRECCHIA_M 05042016: EVO46-----STOP
        
        //Update Claim
        claim1.city__c = 'Verona';
        update claim1;
        //PETRECCHIA_M 05042016: EVO46-----START
        claim3.city__c= 'Parigi';
        update claim3;
        //PETRECCHIA_M 05042016: EVO46-----STOP
        
        //Delete Claim
        delete claim2;
        
        //Undelete Claim
        undelete claim2;
        
    }
}