@isTest
public class StoricoConversazioni_TEST {

    static testMethod void testmethod1() 
    {
    	//MDANTONIO 09/04/2019 popolamento custom settings per classi di test - start
        ServiceUtilsClass.populateCustomSettingsForTests();
        //MDANTONIO 09/04/2019 popolamento custom settings per classi di test - end
        insert new MPS_Code_Variables__c(Name = 'CaseManagement_CaseStatus_OCR', value__c = 'Chiuso in autonomia;Risolto;Soluzione proposta;');
       	Case cCase = new Case(Status = 'Open', Phone_Call_Ids__c='', Origin='Portale Assistenza', Category__c='ATR', SubCategory__c='', recordtypeid =  [SELECT id from RecordType WHERE DeveloperName = 'Assistenza_Agenti'].Id);
        insert cCase;
        String rTId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Agente'].Id; 
        Storico_conversazioni__c sc = new Storico_conversazioni__c ( Description__c = 'descrizione', Connected_case__c = cCase.Id, CaseStatus__c = 'Chiuso in autonomia', Type__c = 'Annullamento richiesta', RecordTypeId = rTId, Profilo_utente__c = 'Agente', Ruolo_utente__c = '-' );
        insert sc;
        sc.Description__c='prova';
        update sc;
        list<Storico_conversazioni__c>lsc=new  list<Storico_conversazioni__c>();
        insert lsc;
        delete lsc;
        undelete lsc;
       
    }
}