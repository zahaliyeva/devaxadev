@isTest
public class VistaGaranzieTest {
    
    @isTest static void test() {
        Test.startTest();
        String jsonString = '{"name":"John", "age":30}';
        VistaGaranzie v = new VistaGaranzie(jsonString);
        Test.stopTest();          
    }
    
}