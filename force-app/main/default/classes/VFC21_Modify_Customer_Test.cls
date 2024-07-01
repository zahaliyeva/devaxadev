@IsTest
public class VFC21_Modify_Customer_Test {

	@TestSetup
	static void makeData(){
        ServiceUtilsClass.populateCustomSettingsForTests();
        Map<String,Id> developerIdMap; 
        developerIdMap = AP_Constants.getDeveloperIdMap(AP_Constants.sobjectAcc);
        String accIndividualId = developerIdMap.get(AP_Constants.rtAccIndividualClient);
        Account accTest = new Account(
                FirstName ='Jane',
                LastName= 'Smith', 
                PersonEmail = '', 
                RecordTypeId = accIndividualId, 
                Fiscal_ID__c ='5345'
            );
            insert accTest;
            Case c = new Case(Phone_Call_Ids__c='123|456|202122|101112',AccountId=accTest.Id);
            insert c;
    }
    
    @isTest 
    public static void testVFC21_Modify_Customer_Test(){
        Case c = [SELECT id from Case limit 1]; 
        ApexPages.StandardController caseController = new ApexPages.StandardController(c);
        VFC21_Modify_Customer ctrl = new VFC21_Modify_Customer(caseController);
    }
 
}