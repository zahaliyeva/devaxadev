@isTest
public class APIT00_EnviromentControllerTest {
  
    @isTest static void test() {
       Test.startTest();
        APIT00_EnviromentController a = new APIT00_EnviromentController();
       Test.stopTest();    
        a.UrlParameterJSON='Prova';
        System.assertEquals('Prova', a.UrlParameterJSON);
    }
}