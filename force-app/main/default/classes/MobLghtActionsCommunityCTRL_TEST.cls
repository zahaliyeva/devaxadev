@isTest
private  class MobLghtActionsCommunityCTRL_TEST {
   
    @IsTest 
    public static void getInfoCase(){
    Map<String,Id> case_developerIdMap=  AP_Constants.getDeveloperIdMap(AP_Constants.sobjectCas);
    Map<String,Id>  acc_developerIdMap = AP_Constants.getDeveloperIdMap(AP_Constants.sobjectAcc);
     List<Account>   tstAccountList = new List<Account>{
            new Account(FirstName ='Jane',
            LastName= 'Smith',
            PersonEmail = 'jane.smith@axa-italy-devtest.com',
            RecordTypeId = acc_developerIdMap.get(AP_Constants.rtAccIndividualClient)
           ),                      
              new Account(FirstName ='Jamie',
            LastName= 'Smith',
            PersonEmail = 'Jamie.smith@axa-italy-devtest.com',
            RecordTypeId = acc_developerIdMap.get(AP_Constants.rtAccIntermediary),
            Matricola__c='456')            							  			
        };
     Insert tstAccountList;

       Case testCase = new Case (Status = 'Assigned',
       RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseMotor),
       AccountId= tstAccountList[0].Id,
       AgentName__c=tstAccountList[1].id,
       Category__c ='Preventivi ed emissioni - polizze di auto',
       SubCategory__c = 'Emissioni polizze off line',
       SubCategoryDetail__c = 'Figure contrattuali'
      );
     insert testCase;       
       MobLghtActionsCommunityController.getInfoCase(testCase.Id);
    } 

}