@isTest
public class lghtIFrameForCustomURLCTRL_Test {
@IsTest
    static void testIframe() {
        Account temp = new Account();
        temp.Name = 'Sheldon Cooper';
        insert temp;

        Communications_to_customer__c comun2cust = new Communications_to_customer__c();
        comun2cust.AccountId__c=temp.id;
        comun2cust.TECH_URL_template_MC__c = 'https://chatbotdev1.web.app/';

        insert comun2cust;

        String urlFromRecord ;

        urlFromRecord=lghtIFrameForCustomURLCTRL.GetUrlFromRecordId(comun2cust.id);

        System.assertEquals(String.isNotBlank(urlFromRecord), true);
    }
    
}