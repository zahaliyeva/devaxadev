@IsTest
public class ButtonOnStoricoChiamateController_TEST {
  
 static testMethod void method1()
   {
       Storico_Chiamate__c sc = new Storico_Chiamate__c ();
       insert sc;
       sc.Call_ID__c='Asset';
       System.assertEquals('Asset', sc.Call_ID__c);
       ButtonOnStoricoChiamateController.getStorico_ChiamateInfos(sc.Id);
       ButtonOnStoricoChiamateController.call_SAP17_STORMSavePhoneRecording_WS(sc.Id, 'false');
       
   }
}