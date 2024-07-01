@isTest
public without sharing class lghtIniziativeMarketingCustomViewCTRL_T {

@testSetup static void setup() 
{
    Iniziative_Marketing__c temp = new Iniziative_Marketing__c();

    temp.Name = 'Temp AAI TEXT temp';
    temp.Communication_code__c = 'Temp AAI TEXT temp1';
    temp.Attiva__c = true ;
    temp.Eligibile_per_Compagnia__c = 'AAI';
    temp.Tipologia_Campagna__c = 'Commerciale';
    temp.Canale__c = 'Email';

    Iniziative_Marketing__c temp1 = new Iniziative_Marketing__c();

    temp1.Name = 'Temp AAI TEXT temp';
    temp1.Communication_code__c = 'Temp AAI TEXT temp2';
    temp1.Attiva__c = false ;
    temp1.Tipologia_Campagna__c = 'Commerciale';
    temp1.Eligibile_per_Compagnia__c = 'AAI';
    temp1.Canale__c = 'Email';

    insert temp;
    insert temp1;

    
}

@isTest
public static void test_1() {
    Iniziative_Marketing__c iniziativa1 = [Select id,Name,Versione__c, Attiva__c,Canale__c, Tipologia_Campagna__c, Eligibile_per_Compagnia__c from Iniziative_Marketing__c where Attiva__c = true limit 1];
    Iniziative_Marketing__c iniziativa2 = [Select id,Name,Versione__c, Attiva__c,Canale__c,Tipologia_Campagna__c,Eligibile_per_Compagnia__c from Iniziative_Marketing__c where Attiva__c = false limit 1];

    lghtIniziativeMarketingCustomViewCTRL constructorCover = new lghtIniziativeMarketingCustomViewCTRL();
    lghtIniziativeMarketingCustomViewCTRL.getPickListValues('Contact','Language__c');
    lghtIniziativeMarketingCustomViewCTRL.getPickListValues(null,'');
    lghtIniziativeMarketingCustomViewCTRL.getIniziativeMarketing();
    lghtIniziativeMarketingCustomViewCTRL.setIniziativeMarketingAttiveDesattive(iniziativa1.id);
    lghtIniziativeMarketingCustomViewCTRL.setIniziativeMarketingAttiveDesattive(iniziativa2.id);

    List<lghtIniziativeMarketingCustomViewCTRL.wrapperIniziativeMarketing> resultAll =lghtIniziativeMarketingCustomViewCTRL.getIniziativeMarketingFilterAll(iniziativa1.Tipologia_Campagna__c,iniziativa1.Canale__c, 'false');
    
    List<lghtIniziativeMarketingCustomViewCTRL.wrapperIniziativeMarketing> resultFilterName = lghtIniziativeMarketingCustomViewCTRL.Search('AAI TEXT','None','None','True');
    
    System.assertEquals(resultAll.size(),1);//only 1 active
    System.assertEquals(resultFilterName.size(),1);//only 2 names

}
@isTest
public static void test_2(){
    //cover errors
    lghtIniziativeMarketingCustomViewCTRL.getPickListValues('Contact',null);
    lghtIniziativeMarketingCustomViewCTRL.Search('Error','null','null','Value');
}
}