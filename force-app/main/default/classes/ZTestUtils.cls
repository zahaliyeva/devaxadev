@isTest
public class ZTestUtils {
    
     @testSetup static void setup() {
       FiscalCodeParameter__c parameter = new FiscalCodeParameter__c(
           CFNationalCode__c = 'C615',
           CFCity__c = 'CHIARAVALLE',
           CFProvince__c = 'AN'
       );
         
         insert parameter;
    }
    
    @isTest
    public static void test_getFiscalCode(){
        Utils.getCF('Test', 'Test', '2000-01-01', 'F', 'CHIARAVALLE', 'AN');
        Utils.getCF('AAA', 'AAA', '2000-01-01', 'M', 'CHIARAVALLE', 'AN');
    }

}