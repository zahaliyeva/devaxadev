public class ButtonOnStoricoChiamateController {

    @AuraEnabled
    public static Storico_Chiamate__c  getStorico_ChiamateInfos(String Id) 
    {
        return [SELECT Id,Call_Historicised__c, Call_ID__c,CallDateTime__c,PhoneCallIDB__c FROM Storico_Chiamate__c WHERE Id =: Id ];
    }
    
     @AuraEnabled
    public static Boolean  call_SAP17_STORMSavePhoneRecording_WS (String ChiamataID, String TOSave) 
    {
        return AP17_STORMSavePhoneRecording_WS.SaveRecording( ChiamataID, TOSave );
    }
    

}