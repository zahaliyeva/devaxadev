@isTest
public class SollecitoPeriodicoIvass41_TEST {
    @testSetup static void setup() {
        List<Profile> listProfile = [Select id from profile where name = 'System Administrator'];
        ID RecTypeAgency = [Select id from recordtype where sobjectType = 'Account' and name = 'Agency' limit 1].id;
        Account agency = new Account(recordtypeid = RecTypeAgency, Agency_Code__c = '000127', Agency_email__c = 'Test@Test.test', Name ='TEST');
        insert agency;
        User tempUser = new User(username = 'UserNameTest@test.test',
                                 LastName = 'Test',
                                 Alias = 'Ttest',
                                 Email = 'UserNameTest@test.test',
                                 TimeZoneSidKey = 'Europe/Rome',
                                 LocaleSidKey = 'it',
                                 EmailEncodingKey = 'ISO-8859-1',
                                 ProfileId = listProfile[0].id,
                                 LanguageLocaleKey = 'it');
        insert tempUser;
        ID BusinessHoursDefault = [Select id from businesshours where isDefault = true limit 1].id;
        List<MPS_Code_Variables__c> listCustomSetting = new List<MPS_Code_Variables__c>();
        
        listCustomSetting.add(new MPS_Code_Variables__c (Name = 'Ivass41Solleciti', Value__c ='0;0;0;0;0'));
        listCustomSetting.add(new MPS_Code_Variables__c (Name = 'BusinessHours_Default', Value__c = BusinessHoursDefault));
        insert listCustomSetting;
    }
    
    static testMethod void CreateCase(){
        //List<User> ListUser = [Select id from user where username = 'UserNameTest@test.test'];
        Id RecTypeId = [Select id from recordType where DeveloperName = 'Axa_Assicurazioni' AND SobjectType = 'Case'].id;
        
        case temp = new Case(recordTypeId = recTypeId, Flag_Ivass41__c = true, Agency_Code__c = '000127', ContatoreIvass41__c = 5);
        insert temp;
        test.startTest();
        List<Case> LC = [SELECT id, 
                         Agency_Code__c, 
                         Agency_Email__c, 
                         OwnerId,
                         TECH_Primo_Sollecito_Agenti__c, 
                         TECH_Secondo_Sollecito_Agenti__c 
                         FROM Case 
                         WHERE 
                         Flag_Ivass41__c = true];
        system.assert(LC.size() == 1);
        system.assert(LC[0].Agency_Code__c == '000127');
        system.assert(LC[0].TECH_Primo_Sollecito_Agenti__c != null);
        system.assert(LC[0].TECH_Secondo_Sollecito_Agenti__c != null);
        system.assert(String.valueOf(LC[0].OwnerId).startsWith('00G'));
        system.assert(LC[0].Agency_Email__c != null);
       
        SollecitoPeriodicoIvass41.updateRecord(LC);
        test.stopTest();
        LC = [SELECT id, 
              Agency_Code__c, 
              Agency_Email__c, 
              OwnerId,
              TECH_Primo_Sollecito_Agenti__c, 
              TECH_Secondo_Sollecito_Agenti__c,
              SollecitoPeriodico20ore__c,
              ContatoreIvass41__C
              FROM Case 
              WHERE 
              Flag_Ivass41__c = true];
       	//system.assert(LC[0].SollecitoPeriodico20ore__c != null);
        system.assert(LC[0].ContatoreIvass41__c == 6);
    }
    
    static testMethod void updateUsers(){
        List<User> LU = [Select id from User where username = 'UserNameTest@test.test'];
        system.assert(LU.size() == 1);
        LU[0].Abilitazione_CTL__c = true;
        system.assert(SollecitoPeriodicoIvass41.UpdateUsers(LU));
        LU[0].LastName = '';
        system.assert(!SollecitoPeriodicoIvass41.UpdateUsers(LU));
    }
}