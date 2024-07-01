/**
 * @description PURE IT 22/05 - commentata la classe
 */
@isTest
public class DecodeFiscalCode_Test {
	/**PURE IT
    @TestSetup
    public static void setupMethod(){
        insert new IE_Configuration__c(
                Name= 'Integration_decodeFiscalCode',
                Direction__c= 'OUTBOUND',
                EndPoint__c= 'test',
                Request_compiler__c= 'IE_Request_CIF_EditAccount',
                Response_parser__c= 'IE_Parser_decodeFiscalCode',
                Type__c= 'WebService',
                NameSpacePrefix1__c= 'soapenv',
                NameSpacePrefix2__c= 'bean',
                NameSpaceUri1__c= 'http://schemas.xmlsoap.org/soap/envelope/',
                NameSpaceUri2__c= 'http://bean.services.jdna6ws.app.directw.it',
                HTTPMethod__c= null,
                NameSpacePrefix3__c= null,
                NameSpaceUri3__c= null,
                Named_Credential_Name__c= null,
                Named_Credential_Path__c= null,
                log_records_flag__c= true,
                Timeout__c= null,
                Insert_IR_WS__c= false,
                ClientId__c= null,
                SignedCertificatedSFDC__c= null,
                Client_Secret__c= null
			);
    }
    
    @isTest
    public static void  method1(){
        decodeFiscalCode_Mock_TEST mock = new decodeFiscalCode_Mock_TEST();
        mock.TestCase = 'Valid';
        test.setMock(HTTPCalloutMock.class, mock);
        test.startTest();
        DecodeFiscalCode.sendRequest('ZCCFMN80A41L219Y', 'FMN', 'ZCC');
        test.stopTest();
    }
    
    @isTest
    public static void  method2(){
        decodeFiscalCode_Mock_TEST mock = new decodeFiscalCode_Mock_TEST();
        mock.TestCase = 'Error';
        test.setMock(HTTPCalloutMock.class, mock);
        test.startTest();
        DecodeFiscalCode.sendRequest('123456789012345A', 'FMN', 'ZCC');
        test.stopTest();
    }
    PURE IT */
}