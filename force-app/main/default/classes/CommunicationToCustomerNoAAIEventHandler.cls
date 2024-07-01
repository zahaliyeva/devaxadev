public with sharing class CommunicationToCustomerNoAAIEventHandler implements ITrigger {
    
    private Map<String, String> accountContactMap = new Map<String,String>();
    
    public CommunicationToCustomerNoAAIEventHandler() {}

    public void bulkBefore(){}  

       

    public void bulkAfter(){
        List<String> accountIds = new List<String>();
        for(CommunicationToCustomerNoAAI__e event: (List<CommunicationToCustomerNoAAI__e>) Trigger.new){
            accountIds.add(event.AccountId__c);
        }
        List<Contact> contacts = [SELECT AccountId from Contact where AccountId = :accountIds];
        for(Contact contact: contacts){
            accountContactMap.put(contact.AccountId, contact.Id);
        }
    } 

           

    public void beforeInsert(SObject so){}
    
    public void beforeInsert(List<SObject> soList){}  
    
    public void beforeUpdate(SObject oldSo, SObject so){}  

        
    public void beforeUpdate(List<SObject> oldSoList, List<SObject> soList){}

    public void beforeDelete(SObject so){} 
    
    public void beforeDelete(List<SObject> soList){}

    public void afterInsert(SObject so){}


    public void afterInsert(List<CommunicationToCustomerNoAAI__e> events){
        String caller=null;
        String process=null;
        Id accountId=null;
        try{
            List<Communications_to_customer__c> communications = new List<Communications_to_customer__c>();
            for(CommunicationToCustomerNoAAI__e event: events) {
                Communications_to_customer__c communication = new Communications_to_customer__c();
                communication.Communication_Code__c = event.Communication_Code__c;
                communication.Communication_Description__c = event.Communication_Description__c;
                communication.Additional_Details__c = event.Body__c;
                communication.Caller__c = caller = event.Caller__c;
                communication.Process__c = process = event.Process__c;
                communication.Email__c = event.Email__c;
                communication.Mobile_Phone__c = event.Mobile_Phone__c;
                communication.Notification_Typology__c = event.Channel__c;
                communication.AccountId__c = accountId =event.AccountId__c;
                communication.Contact__c = accountContactMap.get(event.AccountId__c);
                communication.RecordTypeId = RecordTypeUtility.getRecordTypeIdByDeveloperName('Communications_to_customer__c', 'Standard_Communication');
                communication.Insurance_Contract_Number__c = event.Insurance_Contract_Number__c;
                communication.Status__c = 'Ready';

                // ID- push notification add fields
                communication.Fiscal_Code__c = event.Fiscal_Code__c;
                communication.Driving_Licence_Exp_Date__c = event.Driving_Licence_Exp_Date__c ;
                communication.Roadworthiness_Exp_Date__c = event.Roadworthiness_Exp_Date__c ;
                communication.Message__c = event.Message__c ; //message on event is 32.000 by error
                communication.Message_Push_Notification__c = event.Contenuto__c ;
                communication.Short_Message__c = event.Short_Message__c ;
                communication.Titolo__c = event.Titolo__c ;
                communication.Sottotitolo__c = event.Sottotitolo__c ;
                communication.Tipo_notifica_su_Centro_Notifiche__c = event.Tipo_notifica_su_Centro_Notifiche__c ;
                communication.Nome_Id__c = event.Nome_ID__c ;
                communication.Valore_Id__c = event.Valore_ID__c ;
                communication.Letto_Non_Letto__c = event.Letto_Non_Letto__c ;
                communication.Archiviato__c = event.Archiviato__c ;
                communication.VAT__c = event.VAT__c ;
                communication.Testo_CTA__c = event.Testo_CTA__c ;
                communication.URL_CTA__c = event.URL_CTA__c ;
                communication.Visibilita_nel_centro_notifiche__c = event.Visibilita_nel_centro_notifiche__c ;
                communication.Invio_push__c = event.Invio_push__c ;
                communication.Numero_Sinistro__c = event.Numero_Sinistro__c;
                communication.Tipologia_Destinatario__c = event.Tipologia_Destinatario__c;
                communication.CaseId__c = event.CaseId__c;

                if ('SCADENZA PATENTE'.equalsIgnoreCase(communication.Process__c)
                || 'REVISIONE VEICOLO'.equalsIgnoreCase(communication.Process__c)
                || 'SINISTRI SOL'.equalsIgnoreCase(communication.Process__c)){
                    communication.RecordTypeId = RecordTypeUtility.getRecordTypeIdByDeveloperName('Communications_to_customer__c', 'Migrazione_Processi_Digital');
                }
                
                communications.add(communication);
            }
            insert communications;
            CustomerEventsManagement.insertEventInHistory(events);
        } catch(Exception ex){
            ApplicationLogHelper.ERROR('CommunicationToCustomerEventHandler', ex.getmessage()+
            '\nEvent Caller: '+caller+'\nEvent Process: '+process+'\nAccountId: '+accountId, ex.getStackTraceString());
        }
    }

    public void afterUpdate(SObject oldSo, SObject so){}

    public void afterUpdate(List<SObject> oldSoList, List<SObject> soList){} 

    public void afterDelete(SObject so){} 
    
    public void afterUndelete(SObject so){} 
    
    public void afterDelete(List<SObject> soList){}  

    public void afterUndelete(List<SObject> soList){}         

    public void andFinally(){}  

}