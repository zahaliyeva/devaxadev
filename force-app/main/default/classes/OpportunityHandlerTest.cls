@isTest
public class OpportunityHandlerTest{

@testSetup static void setup() {

         //fill custom setting MappingASA
         MappingASA__c settingASA = new MappingASA__c();
         settingASA.Name = '1';
         settingASA.Codice_ASA__c=1;
         settingASA.ASA__c='Auto';
         settingASA.ASA_Description__c='1 - Auto';
         MappingASA__c settingASA2 = new MappingASA__c();
         settingASA2.Name = '2';
         settingASA2.Codice_ASA__c=2;
         settingASA2.ASA__c='Salute';
         settingASA2.ASA_Description__c='2 - Salute';         
         
         AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
        insert acv;
         
         //fill custom setting MappingSottoASA
         MappingSottoASA__c settingSottoASA = new MappingSottoASA__c();
         settingSottoASA.Name = '2.4';
         settingSottoASA.Codice_Sotto_ASA__c=4;
         settingSottoASA.Sotto_ASA__c='MALATTIA AZIENDE';
         settingSottoASA.Sotto_ASA_Description__c='2.4 Malattia aziende';

        List<MappingASA__c> ListASA = new List<MappingASA__c>();
        ListASA.add(settingASA);
        ListASA.add(settingASA2);
        
        List<MappingSottoASA__c> ListSottoASA = new List<MappingSottoASA__c>();
        ListSottoASA.add(settingSottoASA);
        
        List<Database.SaveResult> settingMapSave= database.insert(ListASA);
        List<Database.SaveResult> settingMapSave2= database.insert(ListSottoASA);
        
        Account acc =new Account(Name ='Test1',Account_email__c ='test@test.test',Agency_Code__c ='000111',Agency_Holder__c ='test',TECH_Company__c ='AAI',Active__c=true);
        Database.insert(acc);
        
        //Id RTid=[SELECT Id, Name FROM RecordType WHERE SObjectType = 'Opportunity' AND Name='Opportunita_AXA_Assicurazioni'].Id;
        
        RecordType RTOpp = [SELECT id from RecordType where DeveloperName ='Opportunita_AXA_Assicurazioni' Limit 1];

        
        Opportunity opp = new Opportunity (StageName = 'New', Name = 'Test1', ASA_Description__c='2 - Salute', Sotto_ASA_Description__c ='2.4 Malattia aziende',AccountId = acc.id, RecordTypeId=RTOpp.Id, CloseDate = Date.today());
        Database.insert(opp);        

        


}

    static testMethod void callTrigger(){
        
        Account ag =new Account(Name ='Test',Account_email__c ='test@test.test',Agency_Code__c ='000111',Agency_Holder__c ='test',TECH_Company__c ='AAI',Active__c=true);
        insert ag;
       
        Group g =new Group (Type = 'Queue',Name = 'Coda_Agenzia_000111',DeveloperName = 'Coda_Agenzia_000111');
        insert g;
        
        
        Opportunity o = new Opportunity (StageName = 'New', Name = 'Test', AccountId = ag.id, CloseDate = Date.today());
        
        
        List<Opportunity> opps = new List<Opportunity>();
        opps.add(o);
     
        insert opps;
        update opps;
        delete opps;
        undelete opps;                                    
    }
    
    static testMethod void callTrigger2(){
    
        Account ag =new Account(Name ='Test',Account_email__c ='test@test.test',Agency_Code__c ='000111',Agency_Holder__c ='test',TECH_Company__c ='AAI',Active__c=true);
        insert ag;
    
        Opportunity o = new Opportunity (StageName = 'New', Name = 'Test', ASA_Description__c='2 - Salute', Sotto_ASA_Description__c ='2.4 Malattia aziende',AccountId = ag.id, CloseDate = Date.today());
        insert o;

        o.ASA_Description__c ='1 - Auto';
        o.Sotto_ASA_Description__c='';
        update o;
        
        o.ASA_Description__c = '';
        o.Sotto_ASA_Description__c = '';
        update o;
        
        Opportunity o2 = new Opportunity (StageName = 'New', Name = 'Test', ASA_Description__c='', Sotto_ASA_Description__c ='', Codice_ASA__c = '2', Codice_Sotto_ASA__c = '4',AccountId = ag.id, CloseDate = Date.today());
        insert o2;
        
        o2.ASA_Description__c = '2 - Salute';
        o2.Sotto_ASA_Description__c = '2.4 Malattia aziende';
        update o2;
       
    }
    
 }