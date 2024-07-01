@isTest
public class resetPasswordAccountCTRL_TEST {
    
    public class testMock implements HttpCalloutMock {
        
        public testMock(String fase, Boolean result){
            this.fase = fase;
            this.result = result;
        }
        
        private String fase;
        private Boolean result;
        
    	public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();

            Map<String, object> resp = new Map<String, Object>();

            if(this.fase == 'search'){
                if(this.result){
                    List<resetPasswordResponseWrapper.EmailWrapper> resList = new List<resetPasswordResponseWrapper.EmailWrapper>();
                    resetPasswordResponseWrapper.EmailWrapper email = new resetPasswordResponseWrapper.EmailWrapper();
                    email.email = 'test';
                    resList.add(email);
                    resp.put('email-list', resList);
                }
                    
                else{
                    resp.put('errorCode', '400');
                }
            }
            else if(this.fase =='confirm'){
                if(this.result){
                    resp.put('link', 'test');
                }
                else{
                    resp.put('errorCode', '400');
                }
            }
            res.setBody(JSON.serialize(resp));
            return res;
        }
    }

    @TestSetup
    static void init(){
        Profile AdminProfile = [SELECT Id FROM Profile WHERE Name  IN ('Amministratore del Sistema', 'System Administrator') ]; 
        UserRole role = [SELECT Id FROM UserRole where name = 'AXA Assicurazioni'];
            Id pRol = role.Id;
        Id RecordtypeId = [select id from recordtype where SObjectType = 'Account' AND DeveloperName = 'B2C_Client' limit 1].Id;


        Account ac = new Account (
                FirstName = 'test',
                LastName = 'LeadTest',
                PersonEmail = 'account@mail.test',
                Phone = '0333333333',
                PersonMobilePhone = '3333333333',
                NDG__c = '000000000',
                Nodes__c = '000828',
                AAI_Agency_Reference_Code__c='000828',
                AAI_Codice_fiscale__c='AAAAAA00A00A000A',
                RecordtypeId = RecordtypeId
            );
        insert ac;
        
        List<IE_Configuration__c> confToInsert = new List<IE_Configuration__c>();
        
        
        IE_Configuration__c integration = new IE_Configuration__c(Name = 'ResetPassword',
                                                                 	Type__c = 'WebService_rest',
                                                                	Direction__c = 'OUTBOUND',
                                                                  	HTTPMethod__c = 'POST',
                                                                  	EndPoint__c = 'resetPassword',
                                                                  	Request_compiler__c = 'resetPasswordRequestCompiler',
                                                                  	Response_parser__c = 'resetPasswordResponseParser'
                                                                 );
        
        
        confToInsert.add(integration);
        insert confToInsert;
        
        AAI_Code_Variables__c modAcc= new AAI_Code_Variables__c();
         modAcc.Name='AccountEdit_IRSavingLink';
         modAcc.Value__c='test';
         insert modAcc;
        
    }


    @isTest
    public static void TestSearchCorrect(){
        testMock mock = new testMock('search', true);
        Test.setMock(HttpCalloutMock.class, mock);
        test.startTest();
        resetPasswordAccountCTRL.ResponseWrapper resp = ResetPasswordAccountCTRL.init('AAAAAA00A00A000A');
        test.stopTest();
        system.assert(resp.isSuccess);
        system.assert(resp.emailList.size() == 1);
    }

    @isTest
    public static void TestSearchError(){
        testMock mock = new testMock('search', false);
        Test.setMock(HttpCalloutMock.class, mock);
        test.startTest();
        resetPasswordAccountCTRL.ResponseWrapper resp = ResetPasswordAccountCTRL.init('AAAAAA00A00A000A');
        test.stopTest();
        system.assert(!resp.isSuccess);
        system.assert(resp.ErrorMessage == 'Attenzione: si è verificato un errore. Riprovare più tardi');
    }

    @isTest
    public static void TestConfirmCorrect(){
        testMock mock = new testMock('confirm', true);
        Test.setMock(HttpCalloutMock.class, mock);
        test.startTest();
        resetPasswordAccountCTRL.ResponseWrapper resp = ResetPasswordAccountCTRL.confirm('AAAAAA00A00A000A', 'test');
        test.stopTest();
        system.assert(resp.isSuccess);
    }

    @isTest
    public static void TestConfirmError(){
        testMock mock = new testMock('confirm', false);
        Test.setMock(HttpCalloutMock.class, mock);
        test.startTest();
        resetPasswordAccountCTRL.ResponseWrapper resp = ResetPasswordAccountCTRL.confirm('AAAAAA00A00A000A', 'test');
        test.stopTest();
        system.assert(!resp.isSuccess);
        system.assert(resp.ErrorMessage == 'Attenzione: si è verificato un errore. Riprovare più tardi');
    }
    
    @isTest
    public static void TestConfirmError2(){
        testMock mock = new testMock('confirm', false);
        Test.setMock(HttpCalloutMock.class, mock);
        test.startTest();
        resetPasswordAccountCTRL.ResponseWrapper resp = ResetPasswordAccountCTRL.confirm('AAAAAA00A00A000B', 'test');
        test.stopTest();
        system.assert(!resp.isSuccess);
        system.assert(resp.ErrorMessage == 'Attenzione: si è verificato un errore. Riprovare più tardi');
    }
    
    @isTest
    public static void TestConfirmError3(){
        testMock mock = new testMock('confirm', false);
        List<Account> accList = [Select id from Account where AAI_Codice_fiscale__c = 'AAAAAA00A00A000A' limit 1 FOR UPDATE];
        Test.setMock(HttpCalloutMock.class, mock);
        test.startTest();
        resetPasswordAccountCTRL.ResponseWrapper resp = ResetPasswordAccountCTRL.confirm('AAAAAA00A00A000A', 'test');
        test.stopTest();
        system.assert(!resp.isSuccess);
        system.assert(resp.ErrorMessage == 'Attenzione: si è verificato un errore. Riprovare più tardi');
    }
}