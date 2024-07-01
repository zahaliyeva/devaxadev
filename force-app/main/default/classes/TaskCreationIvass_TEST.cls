@isTest
public without sharing class TaskCreationIvass_TEST {
    Static id userID;
    Static id AccountIdForCase;
	@testSetup static void setup() {
        List<Profile> listProfile = [Select id from profile where name = 'System Administrator'];
        ID BusinessHoursDefault = [Select id from businesshours where isDefault = true limit 1].id;
        ID RecType = [Select id from recordtype where sobjectType = 'Account' and name = 'B2C Client' limit 1].id;
        Account B2C = new Account(recordtypeid = RecType, FirstName ='TEST', LastName = 'TEST');
        insert B2C;
        List<MPS_Code_Variables__c> listCustomSetting = new List<MPS_Code_Variables__c>();
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
        userID=tempUser.ID;
        listCustomSetting.add(new MPS_Code_Variables__c (Name = 'Ivass41Solleciti', Value__c ='0;0;0;0;0'));
        listCustomSetting.add(new MPS_Code_Variables__c (Name = 'BusinessHours_Default', Value__c = BusinessHoursDefault));
        insert listCustomSetting;
    }
    public static testMethod void TaskCreation(){
        List<RecordType> RecTypeList = [select id from RecordType where DeveloperName in ('Axa_Assicurazioni','NonMotor') ];
        List<Case> CaseList = new List<Case>();
        Case temp = new Case(AccountId = AccountIdForCase, CreatedById = userID, RecordTypeId = RecTypeList[0].Id, Lob__c = 'Private Area and My Axa',Category__c = 'Richiesta codice sconto', Description = 'Test 1', SuppliedEmail = 'Test@test.it',SuppliedPhone = '11111111');
        CaseList.add(temp);
        Case temp1 = new Case (AccountId = AccountIdForCase, CreatedById = userID, RecordTypeId = RecTypeList[0].Id, Lob__c = 'Privacy',Category__c = 'test', Description = 'Test 2',SuppliedEmail = 'Test@test.it',SuppliedPhone = '11111111',Flag_Ivass41__c = true);
        CaseList.add(temp1);
        insert CaseList;
        caseList = [Select id, Voucher__c, PolicyId__c, ContactID, CaseNumber,Prodotto__c,CreatedById,LOB__c,Category__c,Description, RecordTypeId,SuppliedEmail, SuppliedPhone from Case];
        for(Case c: caseList){
            system.debug('temp: '+c);
        }
        
        
        List<Task> created = [Select id, whatId, description from Task];
     
        for(task c: created){
            system.debug('temp: '+c);
        }
        system.debug(created.size());
        //system.assert(created.size()==2);
        //
        created.get(0).description = created.get(0).description + 'test update';
        created.get(0).status = AP_Constants.taskStatusInProgress;
            
        update created;
    }
}