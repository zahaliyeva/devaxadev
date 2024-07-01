@isTest
public class TestSendSMSController {
    
    @isTest
    public static void  testSendFromAccountId(){
        AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
        insert acv;
        MPS_Code_Variables__c codeVariable = new MPS_Code_Variables__c (Name = 'BusinessHours_Default', Value__c = [select id from businesshours where IsDefault=true][0].Id);
        MKT_Utility__c utility = new MKT_Utility__c(MKT_SMS_ALERT_URL__c = 'https://mkt.rest.it',MKT_SMS_URL_AUTH__c= 'https://mkt.rest.it');
        insert utility;
        insert new SMSCaringKeyword__c(Keyword__c='INFORMATIVE',Name='SMSKeyword');
        insert new SMSCaringKeyword__c(Keyword__c='INFORMATIVE',Name='SMSKeywordSTT');
        insert codeVariable;
        Map<String,Id> acc_developerIdMap = AP_Constants.getDeveloperIdMap(AP_Constants.sobjectAcc);
        Map<String,Id>  case_developerIdMap = AP_Constants.getDeveloperIdMap(AP_Constants.sobjectCas);
        Account newAccount1 = new Account(FirstName ='Jane',
                                           LastName= 'Smith',
                                                    PersonMobilePhone = '00393408798576',
                                                    Additional_Phone__c = '340 7898974',
                                                    RecordTypeId = acc_developerIdMap.get(AP_Constants.rtAccIndividualClient),
                                                    ShippingStreet='Via Veneziani 20',
                                                    ShippingCity = 'Roma',
                                                    ShippingCountry = 'ITALIA',
                                                    ShippingPostalCode = '00100',
                                                    TECH_Company__c = 'AAI'
                                                   );
        insert newAccount1;
        
        Case newCase = new Case (Last_Status_Change__c = System.now(),RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseMotor), Origin = 'Phone',Complainant__c= 'Customer',Accountid = newAccount1.id );
        insert newCase;
        
        Test.startTest();
        SendSMSCmpController.MobileOutput output = SendSMSCmpController.init(newCase.Id, newAccount1.Id);
       
        System.assertEquals(output!= null, true,'SendSMSCmpController.MobileOutput deve essere creata');
        
        Test.setMock(HttpCalloutMock.class, new MKTAuthenticationMock());
        SendSMSCmpController.sendSms(output, 'CNR', '3932393939');
        SendSMSCmpController.sendSms2(newCase.Id,output, 'CNR', '3932393939','Test');
        Test.stopTest();
        
    }

}