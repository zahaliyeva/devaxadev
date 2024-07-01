@isTest
public class AnagraficaAssuntoreAgenziaHandlerTest {
    static testMethod void Test(){
        
        List<RecordType> RecType = [Select id from recordType where SObjectType = 'Account' and Name = 'Agency' limit 1];
        List<RecordType> RecType2 = [Select id from recordType where SObjectType = 'Anagrafica_Assuntore__c' and Name like '%Auto' limit 1];
        List<RecordType> RecType3 = [Select id from recordType where SObjectType = 'AnagraficaAssuntoreAgenzia__c' and Name like '%Auto' limit 1];
        Anagrafica_Assuntore__c AA = new Anagrafica_Assuntore__c(Name = 'AssuntoreTest', RecordTypeId = recType2[0].Id);
        List<Anagrafica_Assuntore__c> TempList = new List<Anagrafica_Assuntore__c>();
        TempList.add(AA);
        insert TempList;
        Account nuovoAccount = new Account(Active__c = true, Name ='test', Agency_Code__c = '000000', RecordTypeId = RecType[0].Id);
        insert nuovoAccount;
        system.debug('recTypeId: ' + nuovoAccount.RecordTypeId + ' Id: '+nuovoAccount.id);
        List<AnagraficaAssuntoreAgenzia__c> AAAList = new List<AnagraficaAssuntoreAgenzia__c>();
        AAAList.add(new AnagraficaAssuntoreAgenzia__c ( Name = 'Test', RecordTypeId = recType3[0].Id, Codice_Agenzia__c = nuovoAccount.Id, Nome_Assuntore__c = AA.Id));
        
        insert AAAList;
        update AAAList;
        delete AAAList;
        undelete AAAList;
        
        
    }
    
}